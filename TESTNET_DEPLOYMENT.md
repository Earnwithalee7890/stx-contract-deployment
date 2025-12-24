# 🧪 Testnet Check-In & Badges Contract

## 📋 Ready to Deploy Contract

**Contract Name:** `testnet-checkin-badges`
**Network:** Stacks Testnet
**File:** `contracts/testnet-checkin-badges.clar`

---

## ⚠️ BEFORE DEPLOYING - CHANGE THIS ADDRESS!

**Line 15 in the contract:**
```clarity
(define-constant FEE_RECIPIENT 'ST2F500B8DTRK1EANJQ054BRAB8DDKN6QCMXGNFBT)
```

**Replace with YOUR testnet wallet address!**

Your testnet address starts with **`ST...`** (not `SP...`)

---

## 🎯 What This Contract Does

### 1. **Daily Check-Ins**
- Users call `check-in` once per day
- Fee: **0.001 STX** (testnet friendly!)
- Tracks streaks automatically
- Prevents duplicate check-ins same day

### 2. **Weekly Badges**
- 7 unique badges (Monday-Sunday)
- Users call `earn-badge` to claim daily badge
- Fee: **0.001 STX** per badge
- Resets weekly

### 3. **Stats Tracking**
- User stats: total check-ins, streak, badges
- Global stats: total users, check-ins, badges
- Weekly progress per user

---

## 🚀 How to Deploy

### Option 1: Hiro Platform (Easiest)
1. Go to https://platform.hiro.so/deploy
2. **Network:** Select **"Testnet"**
3. **Contract Name:** `testnet-checkin-badges`
4. **Paste the contract** from `contracts/testnet-checkin-badges.clar`
5. **IMPORTANT:** Change line 15 to YOUR testnet address
6. Click **"Deploy to Testnet"**
7. Approve in Leather wallet (testnet mode)

### Option 2: Clarinet
```bash
clarinet deploy --testnet contracts/testnet-checkin-badges.clar
```

### Option 3: Stacks Explorer Sandbox
1. Go to https://explorer.hiro.so/sandbox/deploy?chain=testnet
2. Paste the contract
3. Change fee recipient address
4. Deploy

---

## 📊 Contract Functions

### Public Functions (Users Call These)

**`(check-in)`**
- Daily check-in (once per day)
- Fee: 0.001 STX
- Returns: check-in count, streak, day

**`(earn-badge)`**
- Earn today's badge
- Fee: 0.001 STX per badge
- Returns: day-of-week, week number, badge name

### Read-Only Functions (Free to Call)

**`(get-user-stats (user principal))`**
- Get user's total check-ins, streak, badges

**`(get-current-day-info)`**
- Get current day, day-of-week, week number

**`(has-checked-in-today (user principal))`**
- Check if user checked in today

**`(get-weekly-progress (user principal))`**
- See all 7 badges status for this week

**`(get-global-stats)`**
- Global totals: users, check-ins, badges

**`(get-badge-name (day-of-week uint))`**
- Get badge name by day (0-6)

---

## 🎮 Testing Plan

After deploying to testnet:

1. **Get testnet STX** from faucet:
   - https://explorer.hiro.so/sandbox/faucet?chain=testnet
   
2. **Test check-in:**
   ```clarity
   (contract-call? .testnet-checkin-badges check-in)
   ```

3. **Test badge earning:**
   ```clarity
   (contract-call? .testnet-checkin-badges earn-badge)
   ```

4. **Check your stats:**
   ```clarity
   (contract-call? .testnet-checkin-badges get-user-stats tx-sender)
   ```

5. **View weekly progress:**
   ```clarity
   (contract-call? .testnet-checkin-badges get-weekly-progress tx-sender)
   ```

---

## 💰 Fee Summary

- **Check-in fee:** 0.001 STX (u1000)
- **Badge fee:** 0.001 STX (u1000)
- **Total for both:** 0.002 STX per day
- **Deployment fee:** ~0.01-0.02 STX (one-time)

**All fees go to the address you set on line 15!**

---

## ✅ After Deployment

Once deployed, give me:
1. **Your deployed contract address** (format: `ST...testnet-checkin-badges`)
2. **Your testnet wallet address** (so I can update the UI)

I'll update the app to work with testnet! 🎯

---

## 📝 Badge Names

- **Day 0 (Monday):** Monday Warrior
- **Day 1 (Tuesday):** Tuesday Titan
- **Day 2 (Wednesday):** Wednesday Winner
- **Day 3 (Thursday):** Thursday Thunder
- **Day 4 (Friday):** Friday Fire
- **Day 5 (Saturday):** Saturday Star
- **Day 6 (Sunday):** Sunday Champion

---

## 🆘 Need Help?

If you have issues deploying, try:
1. Make sure Leather is in **testnet mode**
2. Check you have testnet STX (use faucet)
3. Verify fee recipient is a testnet address (`ST...`)

Ready to deploy? 🚀
