# Chainhook Configurations

Detailed JSON configurations for Hiro Chainhooks.

## Monitoring
- **[builder-rewards-v3.json](./builder-rewards-v3.json)**: Monitors all `daily-check-in` and `claim-daily-reward` transactions on the `builder-rewards-v3` contract.
- Tracks contract calls and emits webhooks to the `/api/chainhook` endpoint defined in the app.

## Importance
Chainhooks are critical for real-time leaderboards and activity feeds, ensuring the UI stays in sync with the Stacks blockchain without constant polling.
