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

import { useState } from 'react';
import { CheckInFeed } from './CheckInFeed';
import { ContractDeployer } from './ContractDeployer';

export default function ClientPage() {
    const [userAddress, setUserAddress] = useState('');
    const [activeTab, setActiveTab] = useState<'dashboard' | 'deploy' | 'activity'>('dashboard');

    // Dashboard state
    const [checkInCount, setCheckInCount] = useState(0);
    const [loading, setLoading] = useState(false);
    const [message, setMessage] = useState('');

    const handleConnect = async () => {
        if (typeof window === 'undefined') return;

        // Dynamic import to ensure polyfill runs first
        const { showConnect } = await import('@stacks/connect');

        showConnect({
            appDetails: {
                name: 'STX Builder Hub',
                icon: 'https://cryptologos.cc/logos/stacks-stx-logo.png',
            },
            onFinish: (data) => {
                setUserAddress(data.userSession.loadUserData().profile.stxAddress.mainnet);
                setMessage('✅ Wallet connected!');
            },
            onCancel: () => {
                setMessage('❌ Connection cancelled');
            },
        });
    };

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
                contractName: 'builder-rewards-v2', // Updated to V2 contract with fees
                functionName: 'daily-check-in',
                functionArgs: [],
                network: 'mainnet',
                anchorMode: AnchorMode.Any,
                postConditionMode: PostConditionMode.Allow, // Allow 5 microSTX fee payment
                onFinish: (data) => {
                    setMessage(`✅ Check-in successful! Fee paid: 5 microSTX | TX: ${data.txId}`);
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

    return (
        <div className="container">
            <header style={{ textAlign: 'center', marginBottom: '2rem' }}>
                <h1>🎯 STX Builder Hub</h1>
                <p style={{ color: 'var(--text-muted)', fontSize: '1.1rem' }}>
                    Check-in daily, deploy contracts, and track activity
                </p>
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
                                        {loading ? <span className="loading"></span> : '📝'} Daily Check-In
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

            <footer style={{ textAlign: 'center', marginTop: '3rem', color: 'var(--text-muted)' }}>
                <p>Built for Stacks Builder Challenge 🏆</p>
            </footer>
        </div>
    );
}
