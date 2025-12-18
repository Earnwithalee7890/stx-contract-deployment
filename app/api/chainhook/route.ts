/**
 * Chainhook Webhook Endpoint
 * 
 * This API route receives POST requests from Hiro Chainhooks when
 * users interact with the builder-rewards-v3 contract.
 * 
 * Week 2 Requirement: Event processing for on-chain activity tracking.
 */

import { NextRequest, NextResponse } from 'next/server';

// Event types we track
interface ChainhookEvent {
    chain: string;
    uuid: string;
    apply: Array<{
        type: string;
        contract_identifier: string;
        method: string;
        sender: string;
        tx_id: string;
        block_identifier: {
            index: number;
            hash: string;
        };
        timestamp?: number;
    }>;
}

// Track event statistics (in-memory for demo, use DB in production)
const eventStats = {
    totalEvents: 0,
    checkIns: 0,
    claims: 0,
    scoreSubmissions: 0,
    lastEventTime: null as number | null,
    recentEvents: [] as any[]
};

export async function POST(request: NextRequest) {
    try {
        // Parse the incoming chainhook event
        const event: ChainhookEvent = await request.json();

        console.log('🔔 Chainhook Event Received:', {
            chain: event.chain,
            uuid: event.uuid,
            eventsCount: event.apply?.length || 0
        });

        // Verify this is from Hiro (optional - add auth header check)
        const authHeader = request.headers.get('authorization');
        const expectedAuth = process.env.CHAINHOOK_AUTH_SECRET;

        if (expectedAuth && authHeader !== `Bearer ${expectedAuth}`) {
            console.warn('⚠️  Unauthorized chainhook request');
            return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
        }

        // Process each event in the payload
        if (event.apply && Array.isArray(event.apply)) {
            for (const tx of event.apply) {
                await processContractCall(tx);
            }
        }

        // Update stats
        eventStats.totalEvents += event.apply?.length || 0;
        eventStats.lastEventTime = Date.now();

        // Return success response
        return NextResponse.json({
            success: true,
            processed: event.apply?.length || 0,
            stats: {
                totalEvents: eventStats.totalEvents,
                checkIns: eventStats.checkIns,
                claims: eventStats.claims,
                scores: eventStats.scoreSubmissions
            }
        });

    } catch (error) {
        console.error('❌ Error processing chainhook event:', error);
        return NextResponse.json(
            { error: 'Internal server error' },
            { status: 500 }
        );
    }
}

/**
 * Process individual contract call events
 */
async function processContractCall(tx: any) {
    const { method, sender, tx_id, block_identifier } = tx;

    console.log(`📊 Processing ${method} from ${sender.substring(0, 10)}...`);
    console.log(`   Tx: ${tx_id}`);
    console.log(`   Block: ${block_identifier.index}`);

    // Track event by method
    switch (method) {
        case 'daily-check-in':
            eventStats.checkIns++;
            console.log('   ✅ Daily check-in recorded');
            // Here you could:
            // - Update user leaderboard
            // - Send notifications
            // - Trigger rewards
            break;

        case 'claim-daily-reward':
            eventStats.claims++;
            console.log('   💰 Reward claim recorded');
            // Here you could:
            // - Track total rewards distributed
            // - Update analytics dashboard
            break;

        case 'record-score':
            eventStats.scoreSubmissions++;
            console.log('   🎯 Score submission recorded');
            // Here you could:
            // - Update user scores
            // - Recalculate rankings
            break;

        default:
            console.log(`   ℹ️  Unknown method: ${method}`);
    }

    // Store recent event for debugging
    eventStats.recentEvents.unshift({
        method,
        sender,
        tx_id,
        block: block_identifier.index,
        timestamp: Date.now()
    });

    // Keep only last 10 events
    if (eventStats.recentEvents.length > 10) {
        eventStats.recentEvents.pop();
    }
}

/**
 * GET endpoint to check webhook status
 */
export async function GET() {
    return NextResponse.json({
        status: 'active',
        message: 'Chainhook webhook endpoint is running',
        stats: {
            totalEvents: eventStats.totalEvents,
            checkIns: eventStats.checkIns,
            claims: eventStats.claims,
            scoreSubmissions: eventStats.scoreSubmissions,
            lastEventTime: eventStats.lastEventTime,
            recentEvents: eventStats.recentEvents.slice(0, 5)
        },
        contract: 'SP2F500B8DTRK1EANJQ054BRAB8DDKN6QCMXGNFBT.builder-rewards-v3',
        network: 'mainnet'
    });
}
