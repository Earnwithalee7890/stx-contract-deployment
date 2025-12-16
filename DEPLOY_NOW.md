# DEPLOY BUILDER-REWARDS-V2 NOW

## ⚠️ All Command Line Tools Failed

I tried multiple deployment methods:
1. ❌ Clarinet - Internal bug ("Invalid string" error)
2. ❌ Stacks CLI - Not installed / broken
3. ❌ Custom Node.js script - Module import conflicts

**Solution**: Use browser-based deployment (easiest and most reliable)

## Option 1: Hiro Platform (RECOMMENDED - 2 minutes)

**Steps:**
1. Open: https://platform.hiro.so/
2. Click "Deploy Contract"
3. Connect your Leather wallet
4. Upload file: `f:\STX CONTRACT\stacks-builder-challenge\contracts\builder-rewards-v2.clar`
5 Contract name: `builder-rewards-v2`
6. Click "Deploy" and approve in wallet (cost: ~0.02-0.2 STX)

## Option 2: Stacks Explorer (Also Browser-Based)

**Steps:**
1. Open: https://explorer.hiro.so/sandbox/deploy?chain=mainnet
2. Connect Leather wallet
3. Copy-paste contract code from: `contracts/builder-rewards-v2.clar`
4. Contract name: `builder-rewards-v2`
5. Click "Deploy"

## What Happens After Deployment

✅ Contract will be at: `SP2F500B8DTRK1EANJQ054BRAB8DDKN6QCMXGNFBT.builder-rewards-v2`
✅ Your website already uses this address (no changes needed!)
✅ Users can check in and pay 5 microSTX fee
✅ You can track users and fees for Builder Challenge

## I've Already Updated Your Website!

**Frontend changes completed:**
- ✅ `ClientPage.tsx` - Calls `builder-rewards-v2` contract
- ✅ `CheckInFeed.tsx` - Shows V2 transaction feed
- ✅ Fee payment enabled (5 microSTX per check-in)

**Once you deploy the contract, your site works immediately!**

---

**Security Note**: 
After deploying, you should:
1. Delete or rotate the mnemonic phrase you shared (it's now in chat history)
2. Move funds to a new wallet if this contains significant STX

---

**Your Options Right Now:**
1. **Deploy via Hiro Platform** → Open browser and follow steps above
2. **I can open the pages for you** → Say "open hiro platform"
3. **Something else?**
