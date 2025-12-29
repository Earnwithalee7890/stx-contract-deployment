# Stacks Contracts

This directory contains the Clarity smart contracts for the Stacks Builder Challenge.

## Versions

### [builder-rewards-v3.clar](./builder-rewards-v3.clar)
- **Current Version**: 3.0.0
- **Features**: 
    - 0.1 STX check-in fee.
    - 0.1 STX reward distribution.
    - Comprehensive fee tracking and user activity monitoring.
    - Admin controls for reward funding and fee withdrawal.

### [builder-rewards-v2.clar](./builder-rewards-v2.clar)
- **Version**: 2.0.0
- **Features**: Increased pool limits and basic tracking.

### [stx-vault.clar](./stx-vault.clar)
- **Features**: Secure vault for managing STX deposits and withdrawals.

### [transaction-fee-rewards.clar](./transaction-fee-rewards.clar)
- **Features**: Distributes rewards based on transaction volume.

## Deployment

Contracts are deployed using Clarinet. To deploy locally:
```bash
clarinet console
```

To deploy to Mainnet/Testnet, use the deployment scripts in the root directory.
