# 🎯 STX Builder Hub

> The premium all-in-one platform for Stacks builders. Powered by **Hiro Chainhooks**, built for the Stacks community. Check-in daily, deploy contracts easier, and manage your assets with style.

---

## 🏆 Stacks Builder Challenge - Week 3

**Participating in Week 3** - This project demonstrates real Stacks mainnet integration with verifiable on-chain activity.

### Week 3 Deliverables

✅ **Stacks Integration**
- 75+ Clarity smart contracts deployed to mainnet
- Hiro Chainhooks monitoring contract interactions in real-time
- Wallet connection via Stacks Connect & Leather Wallet
- Mainnet transaction execution (check-in, rewards, deployments)

✅ **Proof of Work**
- **GitHub Repository**: [stx-daily-check-in](https://github.com/Earnwithalee7890/stx-daily-check-in)
- **Deployed Contracts**: [SP2F500B8DTRK1EANJQ054BRAB8DDKN6QCMXGNFBT](https://explorer.hiro.so/address/SP2F500B8DTRK1EANJQ054BRAB8DDKN6QCMXGNFBT?chain=mainnet)
- **Main Contract**: [builder-rewards-v3](https://explorer.hiro.so/txid/SP2F500B8DTRK1EANJQ054BRAB8DDKN6QCMXGNFBT.builder-rewards-v3?chain=mainnet)
- **Chainhook Config**: [builder-rewards-v3.json](./chainhooks/builder-rewards-v3.json)

✅ **Public Progress**
- Live demo: [https://stx-daily-check-in.vercel.app/](https://stx-daily-check-in.vercel.app/)
- GitHub commits tracking all development
- README documentation with setup instructions

### Build Timeline
- **Week 1**: Deployed 75 Clarity contracts to mainnet
- **Week 2**: Integrated Hiro Chainhooks for real-time event monitoring
- **Week 2**: Built check-in system with fee collection (0.1 STX)
- **Week 3**: Added contract deployer with NFT minting capability
- **Week 3**: Implemented live activity feed and enhanced wallet integration

---

![STX Builder Hub](https://i.imgur.com/example-screenshot.png)

## ✨ Featured Projects & Technical Focus

### 🏛️ Decentralized Digital Notary (Stacks)
- Built a **fully on-chain document notarization dApp** providing cryptographic proof of existence.
- Features integrity verification for digital files and secure Intellectual Property (IP) transfer logic.

### 💸 Salary Streamer & Payroll (Stacks)
- Developed a **decentralized payroll application** enabling real-time salary streaming.
- Implements block-based vesting schedules for automated, trustless fund distribution.

### 💼 Decentralized Job Board (Stacks)
- Created an end-to-end **freelance marketplace** for global job postings and high-integrity hiring.
- Integrates automated milestone payments and employer-freelancer escrow mechanics.

### 🖼️ SIP-009 Premium NFT Infrastructure (Stacks)
- Engineered an **advanced NFT Minting protocol** with metadata management and URI locking.
- Focuses on SIP-009 standard compliance and collection scalability.

### 🎖️ On-chain Reputation & Referral System (Stacks)
- Developed a multi-tier **referral and rewards engine** to drive ecosystem growth.
- Features automated streak tracking and reputation-based reward multipliers.

### 📊 Real-time Builder Analytics Dashboard
- Integrated **Hiro Chainhooks** for a live contributor analytics dashboard.
- Monitors on-chain contract interactions and protocol fee generation in real-time.

## 🚀 Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/) (v18+)
- [Leather Wallet](https://leather.io/) extension installed.

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Earnwithalee7890/stx-daily-check-in.git
   cd stx-daily-check-in
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Run locally**
   ```bash
   npm run dev
   ```
   Open [https://stx-daily-check-in.vercel.app/](https://stx-daily-check-in.vercel.app/) in your browser.

## 📜 Smart Contracts

This project interacts with the Stacks Mainnet.

- **Builder Rewards Contract (v3):** `SP2F500B8DTRK1EANJQ054BRAB8DDKN6QCMXGNFBT.builder-rewards-v3`
- **Fee Recipient:** `SP2F500B8DTRK1EANJQ054BRAB8DDKN6QCMXGNFBT`
- **Explorer:** [View on Hiro Explorer](https://explorer.hiro.so/contact/SP2F500B8DTRK1EANJQ054BRAB8DDKN6QCMXGNFBT.builder-rewards-v3?chain=mainnet)

## 🛠️ Built With

- **Next.js 16** (App Directory, Turbopack)
- **Stacks.js** (Connect, Transactions)
- **Clarity** (Smart Contracts)
- **CSS Modules** (Premium Glassmorphism)

## 🔗 Chainhooks Integration (Week 2)

This project uses **Hiro Chainhooks** to automatically track on-chain contract interactions in real-time, satisfying the **Stacks Builder Challenge Week 2** requirements.

### What We Track

The chainhook monitors three core contract functions on mainnet:
- **`daily-check-in`** - When users check in and pay fees (5 microSTX)
- **`claim-daily-reward`** - When users claim rewards (10 microSTX fee)
- **`record-score`** - When users submit scores (5 microSTX fee)

### How It Works

1. **Chainhook Registration**: A chainhook filter is registered with Hiro's service
2. **Event Detection**: When a transaction calls our contract, Chainhooks detects it instantly
3. **Webhook Trigger**: Event data is sent to `/api/chainhook` endpoint
4. **Event Processing**: Backend logs the activity, tracks fees, and updates statistics

**Contract Monitored**: `SP2F500B8DTRK1EANJQ054BRAB8DDKN6QCMXGNFBT.builder-rewards-v3`  
**Network**: Mainnet

### Setup Instructions

```bash
# 1. Install dependencies (already done during npm install)
npm install

# 2. Configure environment variables
cp .env.example .env.local
# Edit .env.local with your webhook URL and secret

# 3. Register chainhook (outputs JSON config)
npx tsx scripts/register-chainhook.ts

# 4. Visit https://platform.hiro.so/ to register the chainhook
# Paste the JSON output from step 3

# 5. [ADVANCED] Manage hooks programmatically using Hiro SDK
# Requires HIRO_API_KEY in .env.local
npx tsx scripts/manage-hooks.ts list
npx tsx scripts/manage-hooks.ts register
```

### Hiro SDK Deep Integration (Week 2 🚀)

We leverage the `@hirosystems/chainhooks-client` to manage the lifecycle of our on-chain triggers. This allows for:
- **Scalable Monitoring**: Programmatically register and scale event hooks.
- **Real-time Awareness**: The SDK ensures our backend is always in sync with Hiro's infra.
- **Superior Reliability**: Reorg-safe event delivery handled by Hiro's production-grade network.


### Monitoring Chainhook Activity

**Check webhook status:**
```bash
# Start dev server
npm run dev

# Visit in browser or curl
curl http://localhost:3000/api/chainhook
```

**Test webhook locally:**
```bash
curl -X POST http://localhost:3000/api/chainhook \
  -H "Content-Type: application/json" \
  -d '{"chain":"stacks","apply":[{"type":"contract_call","method":"daily-check-in","sender":"SP123","tx_id":"0xabc","block_identifier":{"index":12345,"hash":"0xdef"}}]}'
```

**View live events** (after deployment):
- Visit `https://your-app.vercel.app/api/chainhook` to see real-time stats
- Check server logs for detailed event processing

### Week 2 Compliance ✅

This implementation demonstrates:
- ✅ **Use of Hiro Chainhooks** - Registered chainhook monitoring contract calls
- ✅ **Users & fees generated** - Tracks real user interactions with fee collection
- ✅ **GitHub contributions** - All code committed to public repository


## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---
*Built for the Stacks Builder Challenge Week 3 🏆 Powered by [Hiro](https://hiro.so)*
