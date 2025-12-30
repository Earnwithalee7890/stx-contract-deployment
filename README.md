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
- **Week 3**: Added Referral System and NFT Milestone Badges

---

## ✨ Features

- **🤝 Referral System:** Invite friends and earn extra rewards for their activity.
- **🏅 Milestone Badges:** SIP-009 compliant NFTs awarded for reaching project goals.
- **📝 Daily Check-In:** Earn points and rewards by checking in daily on the Stacks mainnet.
- **🛠️ Contract Deployer:** 
  - **Standard Mode:** Write and deploy custom Clarity contracts directly from your browser.
  - **NFT Creator:** Generate and deploy SIP-009 NFT contracts instantly without writing code.
- **💸 Revenue Share:** A 0.05 STX service fee is automatically applied to all deployments, supporting the platform.
- **👀 Live Activity Feed:** Watch real-time check-ins from the community.
- **💎 Premium Design:** Experience a state-of-the-art Glassmorphism UI with animated mesh gradients and smooth interactions.


## 📦 Clarity 4 Contract Suite (New Addition)

We have added a suite of 10 high-quality, production-ready Clarity 4 contracts covering diverse use cases:

*   **DeFi:** `advanced-vesting`, `defi-staking`, `bonding-curve-token`
*   **Governance:** `dao-governance`, `multisig-vault`
*   **Commerce:** `nft-marketplace-v2`, `subscription-payments`, `revenue-splitter`
*   **Utilities:** `prediction-market`, `identity-registry`

These contracts demonstrate advanced patterns using Clarity 4 features.

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
   Open [http://localhost:3000](http://localhost:3000) in your browser.