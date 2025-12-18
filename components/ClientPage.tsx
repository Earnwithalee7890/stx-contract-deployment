'use client';

// Robust Polyfill for Vercel/Next.js environment
import { Buffer } from 'buffer';

if (typeof window !== 'undefined') {
    if (typeof (window as any).global === 'undefined') {
        (window as any).global = window;
    }
    if (typeof (window as any).Buffer === 'undefined') {
        (window as any).Buffer = Buffer;
    }
}

import { useState, useCallback } from 'react';
import { CheckInFeed } from './CheckInFeed';
import { ContractDeployer } from './ContractDeployer';
import SocialLinks from './SocialLinks';

/**
 * The main client-side entry point for the STX Builder Hub.
 * Manages wallet connection, navigation, and core dashboard actions.
 * 
 * Week 2: Integrated Hiro branding and real-time status tracking.
 */
export default function ClientPage() {
    /** The authenticated user's Stacks address */
    const [userAddress, setUserAddress] = useState('');

    /** Current active navigation tab */
    const [activeTab, setActiveTab] = useState<'dashboard' | 'deploy' | 'activity'>('dashboard');

    // Dashboard state
    /** Total number of successful check-ins detected locally */
    const [checkInCount, setCheckInCount] = useState(0);
    const [loading, setLoading] = useState(false);
    const [message, setMessage] = useState('');

    const handleConnect = useCallback(async () => {
        if (typeof window === 'undefined') return;

        // Dynamic import to ensure polyfill runs first
        const { showConnect } = await import('@stacks/connect');

        showConnect({
            appDetails: {
                name: 'STX Builder Hub',
                icon: '/logo.png',
            },
            onFinish: (data) => {
                setUserAddress(data.userSession.loadUserData().profile.stxAddress.mainnet);
                setMessage('✅ Wallet connected!');
            },
            onCancel: () => {
                setMessage('❌ Connection cancelled');
            },
        });
    }, []);

    const handleCheckIn = async () => {
        if (!userAddress) {
            setMessage('❌ Please connect wallet first');
            return;
        }

        setLoading(true);
        setMessage('');

        try {
            const { openContractCall } = await import('@stacks/connect');
            const { AnchorMode, PostConditionMode } = await import('@stacks/transactions');

            await openContractCall({
                contractAddress: 'SP2F500B8DTRK1EANJQ054BRAB8DDKN6QCMXGNFBT',
                contractName: 'builder-rewards-v3', // V3 with 0.1 STX fees
                functionName: 'daily-check-in',
                functionArgs: [],
                network: 'mainnet',
                anchorMode: AnchorMode.Any,
                postConditionMode: PostConditionMode.Allow, // Allow 0.1 STX fee payment
                onFinish: (data) => {
                    setMessage(`✅ Check-in successful! Fee paid: 0.1 STX | TX: ${data.txId}`);
                    setCheckInCount(prev => prev + 1);
                    setLoading(false);
                },
                onCancel: () => {
                    setMessage('❌ Transaction cancelled');
                    setLoading(false);
                },
            });
        } catch (error) {
            setMessage(`❌ Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
            setLoading(false);
        }
    };

    const handleClaimReward = async () => {
        if (!userAddress) {
            setMessage('❌ Please connect wallet first');
            return;
        }

        setLoading(true);
        setMessage('');

        try {
            const { openContractCall } = await import('@stacks/connect');
            const { AnchorMode, PostConditionMode } = await import('@stacks/transactions');

            await openContractCall({
                contractAddress: 'SP2F500B8DTRK1EANJQ054BRAB8DDKN6QCMXGNFBT',
                contractName: 'builder-rewards-v3',
                functionName: 'claim-daily-reward',
                functionArgs: [],
                network: 'mainnet',
                anchorMode: AnchorMode.Any,
                postConditionMode: PostConditionMode.Allow,
                onFinish: (data) => {
                    setMessage(`✅ Reward claimed! You got 0.1 STX! Fee paid: 0.1 STX | TX: ${data.txId}`);
                    setLoading(false);
                },
                onCancel: () => {
                    setMessage('❌ Transaction cancelled');
                    setLoading(false);
                },
            });
        } catch (error) {
            setMessage(`❌ Error: ${error instanceof Error ? error.message : 'Unknown error'}`);
            setLoading(false);
        }
    };

    return (
        <div className="container">
            <header style={{ textAlign: 'center', marginBottom: '2rem', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '1rem', marginBottom: '0.5rem' }}>
                    <img src="/logo.png" alt="STX Builder Hub Logo" style={{ width: '40px', height: '40px', borderRadius: '8px' }} />
                    <h1 style={{ margin: 0 }}>STX Builder Hub</h1>
                </div>
                <p style={{ color: 'var(--text-muted)', fontSize: '1.1rem' }}>
                    Check-in daily, deploy contracts, and track activity
                </p>
                <div style={{
                    display: 'inline-flex',
                    alignItems: 'center',
                    gap: '0.5rem',
                    background: 'rgba(255, 75, 75, 0.1)',
                    padding: '0.3rem 0.8rem',
                    borderRadius: '20px',
                    border: '1px solid rgba(255, 75, 75, 0.2)',
                    fontSize: '0.85rem',
                    color: '#ff4b4b',
                    marginTop: '0.5rem'
                }}>
                    <span className="pulse-dot" style={{
                        width: '8px',
                        height: '8px',
                        background: '#ff4b4b',
                        borderRadius: '50%',
                        boxShadow: '0 0 8px #ff4b4b'
                    }}></span>
                    Hiro Chainhook: ACTIVE (v3)
                </div>
            </header>

            {/* Connection & Navigation */}
            <div className="glass-card" style={{ marginBottom: '2rem', textAlign: 'center' }}>
                {!userAddress ? (
                    <button className="btn btn-primary" onClick={handleConnect}>
                        🔗 Connect Leather Wallet
                    </button>
                ) : (
                    <div>
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
                            <span style={{ fontFamily: 'monospace', fontSize: '0.9rem' }}>{userAddress}</span>
                            <span style={{ color: '#10b981' }}>● Connected</span>
                        </div>

                        <div style={{ display: 'flex', gap: '1rem', justifyContent: 'center' }}>
                            <button
                                className={`btn ${activeTab === 'dashboard' ? 'btn-primary' : ''}`}
                                onClick={() => setActiveTab('dashboard')}
                                style={{ opacity: activeTab === 'dashboard' ? 1 : 0.6 }}
                            >
                                📊 Dashboard
                            </button>
                            <button
                                className={`btn ${activeTab === 'deploy' ? 'btn-primary' : ''}`}
                                onClick={() => setActiveTab('deploy')}
                                style={{ opacity: activeTab === 'deploy' ? 1 : 0.6 }}
                            >
                                🛠️ Deployer
                            </button>
                            <button
                                className={`btn ${activeTab === 'activity' ? 'btn-primary' : ''}`}
                                onClick={() => setActiveTab('activity')}
                                style={{ opacity: activeTab === 'activity' ? 1 : 0.6 }}
                            >
                                👀 Activity
                            </button>
                        </div>
                    </div>
                )}
            </div>

            {userAddress && (
                <>
                    {activeTab === 'dashboard' && (
                        <div>
                            <div className="grid">
                                <div className="glass-card stat-card">
                                    <h2>📅 Check-Ins</h2>
                                    <div className="stat-value">{checkInCount}</div>
                                    <div className="stat-label">Total Check-Ins</div>
                                </div>



                                <div className="glass-card stat-card">
                                    <h2>💰 Rewards</h2>
                                    <div className="stat-value">0</div>
                                    <div className="stat-label">STX Claimed</div>
                                </div>
                            </div>

                            <div className="glass-card" style={{ marginTop: '2rem' }}>
                                <h2>🎯 Daily Actions</h2>
                                <div style={{ display: 'flex', gap: '1rem', flexWrap: 'wrap', marginTop: '1.5rem' }}>
                                    <button
                                        className="btn btn-primary"
                                        onClick={handleCheckIn}
                                        disabled={loading}
                                    >
                                        {loading ? <span className="loading"></span> : '📝'} Daily Check-In (0.1 STX)
                                    </button>
                                    <button
                                        className="btn btn-primary"
                                        onClick={handleClaimReward}
                                        disabled={loading}
                                        style={{ background: 'linear-gradient(135deg, #10b981 0%, #059669 100%)' }}
                                    >
                                        {loading ? <span className="loading"></span> : '🎁'} Claim 0.1 STX Reward (One-Time Bonus!)
                                    </button>
                                </div>
                                {message && (
                                    <div className={message.includes('✅') ? 'success-message' : 'error-message'}>
                                        {message}
                                    </div>
                                )}
                            </div>

                            <CheckInFeed />
                        </div>
                    )}

                    {activeTab === 'deploy' && <ContractDeployer />}

                    {activeTab === 'activity' && <CheckInFeed />}
                </>
            )}

            {!userAddress && <CheckInFeed />}

            <SocialLinks />

            <footer style={{ textAlign: 'center', marginTop: '2rem', paddingTop: '2rem', color: 'var(--text-muted)' }}>
                <p>Built for Stacks Builder Challenge Week 2 🏆 | Powered by <a href="https://hiro.so/chainhooks" target="_blank" rel="noopener noreferrer" style={{ color: '#ff4b4b', textDecoration: 'none', fontWeight: 'bold' }}>Hiro Chainhooks</a></p>
            </footer>
        </div>
    );
}
