const test=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const {exportRows}=require('./export-pilot-metrics.cjs');
test('dataset is synthetic and has 120 unique pending cases',()=>{
  const rows=fs.readFileSync(path.join(__dirname,'rag-evaluation/dataset.base.jsonl'),'utf8').trim().split('\n').map(JSON.parse);
  assert.equal(rows.length,120); assert.equal(new Set(rows.map(r=>r.query)).size,120);
  assert(rows.every(r=>r.synthetic===true&&r.approved===false&&r.response===null));
});
test('metric exports are pseudonymous, consent-filtered and exclude content',()=>{
  const sample={userId:'synthetic-user',consentGiven:true,eventType:'task_completed',createdAt:'2026-01-01T00:00:00Z',email:'never-export',metadata:{note:'never-export',duration_ms:123}};
  const rows=exportRows([sample,{...sample,consentGiven:false},{...sample,eventType:'arbitrary_private_text'}],'synthetic-test-key-at-least-32-characters');
  assert.equal(rows.length,1); assert.equal(rows[0].duration_ms,123);
  assert.equal(rows[0].participant_id.length,64);
  assert(!JSON.stringify(rows).includes('synthetic-user')); assert(!JSON.stringify(rows).includes('never-export'));
});
test('exports require a pseudonym key',()=>assert.throws(()=>exportRows([],'')));
