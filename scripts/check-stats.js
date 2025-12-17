/**
 * Quick script to check builder-rewards-v2 contract stats
 */

const CONTRACT_ADDRESS = 'SP2F500B8DTRK1EANJQ054BRAB8DDKN6QCMXGNFBT';
const CONTRACT_NAME = 'builder-rewards-v2';

async function getContractStats() {
    try {
        // Using Stacks API to call read-only function
        const url = `https://api.mainnet.hiro.so/v2/contracts/call-read/${CONTRACT_ADDRESS}/${CONTRACT_NAME}/get-fee-summary`;

        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                sender: CONTRACT_ADDRESS,
                arguments: []
            })
        });

        if (!response.ok) {
            throw new Error(`API error: ${response.status}`);
        }

        const data = await response.json();

        console.log('📊 Builder Rewards V2 Contract Stats\n');
        console.log('Contract:', `${CONTRACT_ADDRESS}.${CONTRACT_NAME}`);
        console.log('Network: Mainnet\n');

        // Parse the result
        if (data.okay && data.result) {
            const result = data.result;
            console.log('Stats:');
            console.log('✅ Success! Here are your stats:\n');
            console.log(result);
        } else {
            console.log('Raw response:', JSON.stringify(data, null, 2));
        }

    } catch (error) {
        console.error('❌ Error fetching stats:', error.message);
        console.log('\n💡 Alternative: Check manually at:');
        console.log(`https://explorer.hiro.so/txid/${CONTRACT_ADDRESS}.${CONTRACT_NAME}?chain=mainnet`);
    }
}

getContractStats();
