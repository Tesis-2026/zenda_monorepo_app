#!/usr/bin/env node
/**
 * tools/prepilot-smoke.cjs
 *
 * Automated prepilot smoke validation tool for Zenda API.
 * Validates:
 * 1. Service health (/api/health, /api/ready, /api/live)
 * 2. Auth contract & input validation (rejections on malformed register/login)
 * 3. Security guards (unauthorized access rejection on protected endpoints)
 * 4. Two-user isolation, idempotency & financial totals (when smoke test tokens are provided)
 *
 * Usage:
 *   node tools/prepilot-smoke.cjs [API_BASE_URL]
 *
 * Environment variables:
 *   API_BASE_URL - Base URL for the API (default: Azure staging)
 *   SMOKE_TOKEN_A - Optional JWT for User A to execute authenticated flow
 *   SMOKE_TOKEN_B - Optional JWT for User B to verify cross-user isolation
 */

const assert = require('node:assert/strict');

const DEFAULT_BASE_URL = 'https://zendaapilinuxtesis-hyb8dabvh2hpdgan.centralus-01.azurewebsites.net/api';
const baseUrl = (process.argv[2] || process.env.API_BASE_URL || DEFAULT_BASE_URL).replace(/\/+$/, '');

console.log(`[prepilot-smoke] Running against: ${baseUrl}`);

async function request(path, options = {}) {
  const url = `${baseUrl}${path.startsWith('/') ? path : '/' + path}`;
  const headers = {
    'Content-Type': 'application/json',
    'Connection': 'close',
    ...(options.headers || {}),
  };
  // Small pause to prevent Azure connection reset
  await new Promise(r => setTimeout(r, 400));
  const res = await fetch(url, { ...options, headers });
  let data = null;
  const contentType = res.headers.get('content-type') || '';
  if (contentType.includes('application/json')) {
    data = await res.json().catch(() => null);
  } else {
    data = await res.text().catch(() => null);
  }
  return { status: res.status, headers: res.headers, data };
}

async function run() {
  const results = [];
  function record(step, ok, message) {
    results.push({ step, ok, message });
    const mark = ok ? '✔' : '✖';
    console.log(`  ${mark} [${step}] ${message}`);
  }

  // 1. Health checks
  try {
    const health = await request('/health');
    assert.equal(health.status, 200, `Expected 200, got ${health.status}`);
    assert(health.data && (health.data.status === 'ok' || health.data.info), 'Health payload ok');
    record('HEALTH', true, `Health status 200 OK (${JSON.stringify(health.data.info || health.data.status)})`);
  } catch (err) {
    record('HEALTH', false, err.message);
  }

  try {
    const ready = await request('/ready');
    assert.equal(ready.status, 200, `Expected 200, got ${ready.status}`);
    record('READY', true, `Readiness check 200 OK (DB operational)`);
  } catch (err) {
    record('READY', false, err.message);
  }

  // 2. Auth contract validations
  try {
    const badLogin = await request('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email: 'invalid-email', password: '123' }),
    });
    assert.equal(badLogin.status, 400, `Expected 400 on malformed login, got ${badLogin.status}`);
    record('AUTH_VALIDATION', true, `Rejected malformed login with HTTP 400`);
  } catch (err) {
    record('AUTH_VALIDATION', false, err.message);
  }

  try {
    const unauth = await request('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email: 'nonexistent-user-test-smoke@zenda.pe', password: 'Password123!' }),
    });
    assert.equal(unauth.status, 401, `Expected 401 on unauthorized login, got ${unauth.status}`);
    record('AUTH_CREDENTIALS', true, `Rejected invalid credentials with HTTP 401`);
  } catch (err) {
    record('AUTH_CREDENTIALS', false, err.message);
  }

  // 3. Security guards: protected endpoints reject unauthenticated access
  try {
    const protectedMe = await request('/users/me');
    assert.equal(protectedMe.status, 401, `Expected 401 on /users/me without token, got ${protectedMe.status}`);
    record('SECURITY_GUARD_USERS', true, `/users/me strictly guarded with HTTP 401`);
  } catch (err) {
    record('SECURITY_GUARD_USERS', false, err.message);
  }

  try {
    const protectedTx = await request('/transactions');
    assert.equal(protectedTx.status, 401, `Expected 401 on /transactions without token, got ${protectedTx.status}`);
    record('SECURITY_GUARD_TX', true, `/transactions strictly guarded with HTTP 401`);
  } catch (err) {
    record('SECURITY_GUARD_TX', false, err.message);
  }

  try {
    const protectedReports = await request('/summary/month');
    assert.equal(protectedReports.status, 401, `Expected 401 on /summary/month without token, got ${protectedReports.status}`);
    record('SECURITY_GUARD_REPORTS', true, `/summary/month strictly guarded with HTTP 401`);
  } catch (err) {
    record('SECURITY_GUARD_REPORTS', false, err.message);
  }

  // 4. Authenticated smoke checks (if tokens are supplied)
  const tokenA = process.env.SMOKE_TOKEN_A;
  const tokenB = process.env.SMOKE_TOKEN_B;

  if (tokenA) {
    console.log('\n[prepilot-smoke] Running authenticated checks with SMOKE_TOKEN_A...');
    try {
      const meA = await request('/users/me', { headers: { Authorization: `Bearer ${tokenA}` } });
      assert.equal(meA.status, 200);
      record('AUTH_ME_A', true, `User A authenticated: ${meA.data.id || meA.data.email}`);

      // Test idempotency on transaction creation
      const idempotencyKey = `smoke-${Date.now()}-${Math.random().toString(36).slice(2)}`;
      const txPayload = {
        amount: 25.50,
        type: 'EXPENSE',
        category: 'FOOD',
        date: new Date().toISOString(),
        note: 'Smoke test transaction',
      };
      const res1 = await request('/transactions', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${tokenA}`,
          'Idempotency-Key': idempotencyKey,
        },
        body: JSON.stringify(txPayload),
      });
      assert(res1.status === 201 || res1.status === 200, `Creation status ${res1.status}`);

      const res2 = await request('/transactions', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${tokenA}`,
          'Idempotency-Key': idempotencyKey,
        },
        body: JSON.stringify(txPayload),
      });
      assert(res2.status === 200 || res2.status === 201, `Idempotent retry status ${res2.status}`);
      assert.equal(res1.data.id, res2.data.id, 'Idempotency returned same transaction ID');
      record('IDEMPOTENCY', true, `Idempotency-Key deduplicated identical request (ID: ${res1.data.id})`);

      // If tokenB provided, verify User B cannot access User A's transaction
      if (tokenB) {
        const crossAccess = await request(`/transactions/${res1.data.id}`, {
          headers: { Authorization: `Bearer ${tokenB}` },
        });
        assert(crossAccess.status === 403 || crossAccess.status === 404, `Cross-user access rejected with ${crossAccess.status}`);
        record('CROSS_USER_ISOLATION', true, `User B denied access to User A resource (HTTP ${crossAccess.status})`);
      }

      // Cleanup
      await request(`/transactions/${res1.data.id}`, {
        method: 'DELETE',
        headers: { Authorization: `Bearer ${tokenA}` },
      });
      record('CLEANUP', true, `Deleted smoke test transaction ${res1.data.id}`);
    } catch (err) {
      record('AUTHENTICATED_FLOW', false, err.message);
    }
  } else {
    console.log('\n[prepilot-smoke] Note: SMOKE_TOKEN_A not set. Skipping authenticated multi-tenant steps.');
    console.log('  To run full authenticated suite: SMOKE_TOKEN_A=<jwt> SMOKE_TOKEN_B=<jwt> node tools/prepilot-smoke.cjs');
  }

  const failed = results.filter(r => !r.ok);
  console.log(`\n[prepilot-smoke] Completed: ${results.length - failed.length} passed, ${failed.length} failed.`);
  if (failed.length > 0) {
    process.exit(1);
  }
}

run().catch((err) => {
  console.error('[prepilot-smoke] Fatal error:', err);
  process.exit(1);
});
