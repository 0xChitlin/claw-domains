# ClawEvolution System

## Deployed Contracts (Abstract Testnet)

| Contract | Address |
|----------|---------|
| ClawRenderer v2 | `0xE80c768bBB3171aE32351e569e13e2Ee05642B93` |
| ClawRegistry v2 | `0xE230A7ED55a16DAA0A8CF3b703c4572b7E230aE6` |
| ClawEvolution v2 | `0x8517A68D1092c8fF19D68Cc21cbD967fd7eCe11d` |

## Evolution Phases

| Phase | Name | Activities | Visual |
|-------|------|-----------|--------|
| 0 | Genesis | 0 | Seed crystal, base art |
| 1 | Awakening | 1-10 | + Aura glow effect |
| 2 | Growth | 11-50 | + Extra shape layers |
| 3 | Maturity | 51-200 | + Complex turbulence, gradient mesh, concentric rings |
| 4 | Transcendence | 201+ | + SVG animations, particle dots, border glow, pulse effects |

## Activity Types
- TRANSFER, SKILL_USE, TOKEN_LAUNCH, TRADE, SOCIAL, GOVERNANCE

## Key Functions
- `evolution.recordActivity(tokenId, activityType)` — record single activity
- `evolution.recordActivities(tokenId, activityType, count)` — batch record (max 100)
- `evolution.getEvolutionPhase(tokenId)` — returns 0-4
- `evolution.addApprovedRecorder(address)` — owner only
- `registry.setEvolution(address)` — owner only
- `registry.tokenURI(tokenId)` — auto-queries evolution for phase-aware art

## Test SVGs
- `output-phase0.svg` through `output-phase4.svg` — visual comparison of all phases
