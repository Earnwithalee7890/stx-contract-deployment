# Builder-Rewards-V2 Deployment Options

## Problem
Your `Mainnet.toml` doesn't have a deployment mnemonic configured, so Clarinet can't deploy automatically.

## Solution Options

### Option 1: Use Hiro Platform (Recommended - Easiest)

**Steps:**
1. Go to https://platform.hiro.so/
2. Connect your Leather wallet
3. Click "Deploy Contract"
4. Upload: `f:\STX CONTRACT\stacks-builder-challenge\contracts\builder-rewards-v2.clar`
5. Contract name: `builder-rewards-v2`
6. Click "Deploy" and approve in wallet

**Pros:**
- ✅ No mnemonic needed
- ✅ Uses your connected wallet
- ✅ Simple web interface
- ✅ Safe and secure

---

### Option 2: Add Mnemonic to Mainnet.toml

**Steps:**
1. Open `f:\STX CONTRACT\stacks-builder-challenge\settings\Mainnet.toml`
2. Add your 24-word seed phrase:
   ```toml
   [accounts.deployer]
   mnemonic = "your twenty four word seed phrase here..."
   ```
3. Run:
   ```bash
   clarinet deployments apply -p deployments/default.mainnet-plan.yaml
   ```

**Pros:**
- ✅ Automated deployment
- ✅ Can deploy multiple contracts at once

**Cons:**
- ⚠️ Exposes your seed phrase in a file (keep it safe!)

---

### Option 3: Manual Deployment via Stacks Explorer

**Steps:**
1. Go to https://explorer.hiro.so/sandbox/deploy
2. Connect Leather wallet
3. Paste contract code from `builder-rewards-v2.clar`
4. Contract name: `builder-rewards-v2`
5. Deploy

---

## Recommendation

**Use Option 1** (Hiro Platform) - it's the safest and easiest method.

After deployment, your contract will be at:
`YOUR_ADDRESS.builder-rewards-v2`

The frontend is already configured to use the same address as your old contract:
`SP2F500B8DTRK1EANJQ054BRAB8DDKN6QCMXGNFBT`

So if you deploy from that same address, everything will work immediately!
