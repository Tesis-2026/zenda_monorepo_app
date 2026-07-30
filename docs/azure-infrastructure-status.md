# Azure Infrastructure Status — Zenda Backend

> **Last updated: 2026-07-29.** This document tracks the on/off state of the Azure resources that host the Zenda backend, and the exact steps to restore them. **Keep this file updated whenever resources are stopped, started, scaled, or reconfigured.**

## Current state (as of 2026-07-29)

The cloud backend is **fully stopped / scaled down to zero fixed cost**, done intentionally to avoid charges while it is not in use. The Flutter app can still run in demo mode or against a local backend (`npm run start:dev` + Docker PostgreSQL) — see `docs/frontend-backend-integration.md`.

Subscription: **AzureZenda** (tenant `upc.edu.pe`, tenant ID `0e0cb060-09ad-49f5-a005-68b9b49aa1f6`). Resource group: **ZendaRG**.

| Resource | Type | State | Notes |
|----------|------|-------|-------|
| `zendaapilinuxtesis` | App Service (Linux, NestJS API) | **Stopped** | Always On disabled; **VNet integration removed** (see below) |
| `ASP-ZendaRG-83cb` | App Service Plan | **Downgraded B2 → F1 (Free)** | $0/month; F1 does not support VNet integration nor Always On |
| `zendaapilinuxtesis-server` | PostgreSQL Flexible Server (B1ms) | **Stopped** | ⚠ Azure auto-restarts stopped flexible servers after **7 days** (~2026-08-05) — re-stop it if still unused |
| `ZendaFoundry`, `zenda-rag-agent-resource`, `zenda-document-intelligence-v2` | Cognitive Services / AI Foundry | Active | Pay-per-use — no cost while idle, nothing to stop |
| VNets, private DNS zone, managed identities, App Insights | Networking / identity / telemetry | Active | Free or pay-per-use — left untouched |

### Changes applied on 2026-07-29

1. `az webapp stop` on `zendaapilinuxtesis`.
2. `az postgres flexible-server stop` on `zendaapilinuxtesis-server`.
3. Disabled Always On on the app (`--always-on false`).
4. **Removed VNet integration** from the app (was `vnet-dxitsoob` / subnet `subnet-wbxyywoh`) — required to downgrade to F1.
5. Downgraded plan `ASP-ZendaRG-83cb` from B2 (Basic) to F1 (Free).

## How to restore the backend

Order matters: the plan must be scaled up **before** re-adding VNet integration (F1 does not support it), and without VNet integration the API cannot reach PostgreSQL (private endpoint via `privatelink.postgres.database.azure.com`).

```bash
# 1. Scale the plan back up (B1 is enough for thesis workloads; B2 was the previous tier)
az appservice plan update -g ZendaRG -n ASP-ZendaRG-83cb --sku B1

# 2. Re-add VNet integration so the API can reach PostgreSQL
az webapp vnet-integration add -g ZendaRG -n zendaapilinuxtesis --vnet vnet-dxitsoob --subnet subnet-wbxyywoh

# 3. Re-enable Always On
az webapp config set -g ZendaRG -n zendaapilinuxtesis --always-on true

# 4. Start the API
az webapp start -g ZendaRG -n zendaapilinuxtesis

# 5. Start the database
az postgres flexible-server start -g ZendaRG -n zendaapilinuxtesis-server
```

Verify:

```bash
az webapp show -g ZendaRG -n zendaapilinuxtesis --query "state" -o tsv          # → Running
az postgres flexible-server show -g ZendaRG -n zendaapilinuxtesis-server --query "state" -o tsv  # → Ready
curl https://zendaapilinuxtesis.azurewebsites.net/api/health
```

## How to stop everything again

```bash
az webapp stop -g ZendaRG -n zendaapilinuxtesis
az postgres flexible-server stop -g ZendaRG -n zendaapilinuxtesis-server
# Optional, to drop fixed cost to $0 (requires removing VNet integration + Always On first):
az webapp config set -g ZendaRG -n zendaapilinuxtesis --always-on false
az webapp vnet-integration remove -g ZendaRG -n zendaapilinuxtesis
az appservice plan update -g ZendaRG -n ASP-ZendaRG-83cb --sku F1
```

## Notes for future Claude instances

- If an `az` command fails with `AADSTS50078` (MFA expired), the user must re-login interactively: suggest they run `! az login --tenant "0e0cb060-09ad-49f5-a005-68b9b49aa1f6" --scope "https://management.core.windows.net//.default"`.
- Stopping the App Service alone does **not** stop App Service Plan billing — the plan bills for reserved capacity. Only F1 or deletion brings it to $0.
- The PostgreSQL 7-day auto-restart is an Azure platform behavior and cannot be disabled; if the backend is meant to stay off, the server must be re-stopped every 7 days.
- After restoring, remember the Flutter app targets the backend per `docs/frontend-backend-integration.md` (demo mode vs `--dart-define` base URL).
