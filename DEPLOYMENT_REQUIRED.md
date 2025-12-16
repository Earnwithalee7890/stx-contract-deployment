# ⚠️ IMPORTANT: Contract Deployment Required

## Current Status

✅ **Contract Created**: `builder-rewards-v2.clar` (fee-enabled)  
✅ **Frontend Updated**: Website now calls V2 contract  
❌ **NOT YET DEPLOYED**: Contract needs to be deployed before website will work

---

## What Changed

### 1. New Contract
- **File**: `contracts/builder-rewards-v2.clar`
- **Fees**: 5 microSTX per check-in, 10 microSTX per claim, 5 microSTX per score
- **Features**: User tracking, revenue analytics, event logging

### 2. Frontend Updates
- **File**: `components/ClientPage.tsx`
  - Changed contract name from `builder-rewards` to `builder-rewards-v2`
  - Added fee payment support (PostConditionMode.Allow)
  - Success message now shows "Fee paid: 5 microSTX"

- **File**: `components/CheckInFeed.tsx`
  - Updated API query to fetch from `builder-rewards-v2` contract

---

## ⚡ NEXT STEPS - You Must Do This

### Option 1: Deploy to Testnet (Recommended First)

1. **Check Clarinet Configuration**:
   ```bash
   # Make sure builder-rewards-v2 is in Clarinet.toml
   # If not, you need to add it
   ```

2. **Deploy to Testnet**:
   ```bash
   cd "f:\STX CONTRACT\stacks-builder-challenge"
   
   # Deploy using Clarinet
   clarinet deployments generate --testnet
   clarinet deployments apply -p deployments/default.testnet-plan.yaml
   ```

3. **Test on Website**:
   - Your website will still use mainnet address `SP2F500B8DTRK1EANJQ054BRAB8DDKN6QCMXGNFBT`
   - You need to change `network: 'mainnet'` to `network: 'testnet'` in ClientPage.tsx
   - Or deploy to mainnet directly

### Option 2: Deploy to Mainnet

1. **Fund your wallet** with enough STX for deployment fee

2. **Deploy the contract**:
   ```bash
   cd "f:\STX CONTRACT\stacks-builder-challenge"
   
   # Option A: Using Clarinet
   clarinet deployments generate --mainnet
   clarinet deployments apply -p deployments/default.mainnet-plan.yaml
   
   # Option B: Using Stacks CLI or Hiro Platform
   # Use the Hiro Platform web interface to deploy
   ```

3. **Update Frontend Address** (if needed):
   - If you deploy from a different address, update `ClientPage.tsx`:
   ```typescript
   contractAddress: 'YOUR_NEW_ADDRESS',
   ```

---

## Configuration Needed

### Check Clarinet.toml

Open `f:\STX CONTRACT\stacks-builder-challenge\Clarinet.toml` and verify:

```toml
[project.contracts.builder-rewards-v2]
path = "contracts/builder-rewards-v2.clar"
clarity_version = 2
epoch = 2.5
```

If it's not there, add it manually.

---

## What Happens When Users Click Check-In

1. Wallet popup appears
2. Transaction shows:
   - **Function**: `daily-check-in`
   - **Contract**: `builder-rewards-v2`
   - **STX Transfer**: 5 microSTX to contract
3. User approves
4. Success message: "✅ Check-in successful! Fee paid: 5 microSTX | TX: [txid]"
5. Fee goes to contract, tracked in `total-fees-collected`
6. Owner can withdraw fees later

---

## For Builder Challenge

Once deployed, you can report:

**Contract**: `YOUR_ADDRESS.builder-rewards-v2`

**Users**: Query via:
```clarity
(contract-call? .builder-rewards-v2 get-unique-user-count)
```

**Fees Generated**: Query via:
```clarity
(contract-call? .builder-rewards-v2 get-total-fees-collected)
```

---

## Summary

✅ Contract code written and validated  
✅ Frontend updated to use V2 contract  
❌ **YOU NEED TO DEPLOY THE CONTRACT NOW**  

Without deployment, the website will show errors when users try to check in because the V2 contract doesn't exist on-chain yet.
