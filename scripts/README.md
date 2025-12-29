# Automation Scripts

Utility scripts for managing the project's infrastructure and deployment.

## Available Scripts

### [register-chainhook.ts](./register-chainhook.ts)
Automates the registration of Hiro Chainhooks to monitor contract activity on the Stacks mainnet. Use this to ensure your backend is always alerted when a user checks in or claims a reward.

## Running Scripts
Scripts are executed using `tsx`:
```bash
npx tsx scripts/register-chainhook.ts
```
Ensure your `.env.local` file is populated with the necessary API keys and secrets.
