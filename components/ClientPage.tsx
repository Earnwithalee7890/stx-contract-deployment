'use client';

import { useState, useEffect } from 'react';
import { showConnect, openContractCall } from '@stacks/connect';
import {
    AnchorMode,
    PostConditionMode,
} from '@stacks/transactions';

export default function ClientPage() {
    const [userAddress, setUserAddress] = useState('');
    const [checkInCount, setCheckInCount] = useState(0);
    const [loading, setLoading] = useState(false);
    const [message, setMessage] = useState('');

    const handleConnect = async () => {
        if (typeof window === 'undefined') return;

        showConnect({
            appDetails: {
                name: 'STX Daily Check-In',
                icon: typeof window !== 'undefined' ? window.location.origin + '/logo.png' : '',
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
            await openContractCall({
                contractAddress: 'SP2F500B8DTRK1EANJQ054BRAB8DDKN6QCMXGNFBT',
                contractName: 'builder-rewards',
                functionName: 'daily-check-in',
                functionArgs: [],
                network: 'mainnet',
                anchorMode: AnchorMode.Any,
                postConditionMode: PostConditionMode.Deny,
                onFinish: (data) => {
                    setMessage(`✅ Check-in successful! TX: ${data.txId}`);
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
            <header style={{ textAlign: 'center', marginBottom: '3rem' }}>
                <h1>🎯 STX Daily Check-In</h1>
                <p style={{ color: 'var(--text-muted)', fontSize: '1.1rem' }}>
                    Connect your wallet and check in daily on Stacks mainnet
                </p>
            </header>

            <div className="glass-card" style={{ marginBottom: '2rem', textAlign: 'center' }}>
                {!userAddress ? (
                    <button className="btn btn-primary" onClick={handleConnect}>
                        🔗 Connect Leather Wallet
                    </button>
                ) : (
                    <div>
                        <p style={{ color: 'var(--text-muted)', marginBottom: '1rem' }}>Connected</p>
                        <p style={{ fontFamily: 'monospace', marginBottom: '1rem', fontSize: '0.9rem' }}>
                            {userAddress}
                        </p>
                    </div>
                )}
            </div>

            {userAddress && (
                <>
                    <div className="grid">
                        <div className="glass-card stat-card">
                            <h2>📅 Check-Ins</h2>
                            <div className="stat-value">{checkInCount}</div>
                            <div className="stat-label">Total Check-Ins</div>
                        </div>

                        <div className="glass-card stat-card">
                            <h2>🚀 Deployments</h2>
                            <div className="stat-value">11</div>
                            <div className="stat-label">Contracts Deployed</div>
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

                    <div className="glass-card" style={{ marginTop: '2rem' }}>
                        <h2>📜 Deployed Contracts</h2>
                        <div style={{ display: 'grid', gap: '1rem', marginTop: '1rem' }}>
                            {['builder-rewards', 'escrow', 'message-board', 'multisig', 'nft-minter', 'reputation', 'simple-counter', 'stx-vault', 'timelock', 'token-registry', 'voting'].map((contract) => (
                                <div key={contract} style={{
                                    padding: '1rem',
                                    background: 'rgba(99, 102, 241, 0.1)',
                                    borderRadius: '8px',
                                    border: '1px solid rgba(99, 102, 241, 0.3)'
                                }}>
                                    <span style={{ fontFamily: 'monospace', fontSize: '0.9rem' }}>
                                        SP2F500B8DTRK1EANJQ054BRAB8DDKN6QCMXGNFBT.{contract}
                                    </span>
                                </div>
                            ))}
                        </div>
                    </div>
                </>
            )}

            <footer style={{ textAlign: 'center', marginTop: '3rem', color: 'var(--text-muted)' }}>
                <p>Built for Stacks Builder Challenge 🏆</p>
            </footer>
        </div>
    );
}
