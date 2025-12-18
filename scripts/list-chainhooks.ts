/**
 * List Registered Chainhooks
 * 
 * Helper script to view currently registered chainhooks.
 * Useful for debugging and monitoring.
 * 
 * Usage:
 *   npx tsx scripts/list-chainhooks.ts
 */

console.log('📋 Registered Chainhooks for Builder Rewards V3\n');

console.log('ℹ️  To view your registered chainhooks:');
console.log('   1. Visit https://platform.hiro.so/');
console.log('   2. Navigate to Chainhooks section');
console.log('   3. View your active chainhooks\n');

console.log('📊 Expected Chainhook Configuration:');
console.log('   Name: Builder Rewards V3 Activity Monitor (mainnet)');
console.log('   Contract: SP2F500B8DTRK1EANJQ054BRAB8DDKN6QCMXGNFBT.builder-rewards-v3');
console.log('   Network: mainnet');
console.log('   Methods: daily-check-in, claim-daily-reward, record-score');
console.log('   Webhook: ' + (process.env.NEXT_PUBLIC_WEBHOOK_URL || 'Not configured'));
console.log('\n💡 Tip: Set NEXT_PUBLIC_WEBHOOK_URL in .env.local');
