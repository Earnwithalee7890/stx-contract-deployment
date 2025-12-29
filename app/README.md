# Next.js App Directory

This folder contains the core application logic using the Next.js App Router.

## Structure

### [/api](./api)
- Contains backend routes for interacting with external services and chainhooks.
- **[chainhook](./api/chainhook)**: Handles incoming webhooks from Hiro Chainhooks to track contract events in real-time.

### Page Components
- **layout.tsx**: Global layout including headers, footers, and SEO meta tags.
- **page.tsx**: The main dashboard entry point.

## State Management
The application uses React hooks (useState, useEffect) for local state and integrates with Stacks Wallet (Leather/Xverse) via `@stacks/connect`.
