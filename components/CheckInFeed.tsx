'use client';

import { useState, useEffect } from 'react';

interface Transaction {
    tx_id: string;
    sender_address: string;
    burn_block_time_iso: string;
    tx_status: string;
}

export function CheckInFeed() {
    const [transactions, setTransactions] = useState<Transaction[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchCheckIns = async () => {
            try {
                const response = await fetch(
                    'https://api.mainnet.hiro.so/extended/v1/tx?contract_address=SP2F500B8DTRK1EANJQ054BRAB8DDKN6QCMXGNFBT&contract_name=builder-rewards-v2&function_name=daily-check-in&limit=10'
                );
                const data = await response.json();
                const successTxs = data.results.filter((tx: any) => tx.tx_status === 'success');
                setTransactions(successTxs);
            } catch (error) {
                console.error('Error fetching check-ins:', error);
            } finally {
                setLoading(false);
            }
        };

        fetchCheckIns();
        const interval = setInterval(fetchCheckIns, 30000); // Update every 30s
        return () => clearInterval(interval);
    }, []);

    return (
        <div className="glass-card" style={{ marginTop: '2rem' }}>
            <h2>👀 Recent Check-Ins</h2>
            <div style={{ marginTop: '1rem', maxHeight: '300px', overflowY: 'auto' }}>
                {loading ? (
                    <p>Loading recent activity...</p>
                ) : transactions.length === 0 ? (
                    <p>No recent check-ins found.</p>
                ) : (
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '0.8rem' }}>
                        {transactions.map((tx) => (
                            <div key={tx.tx_id} style={{
                                padding: '0.8rem',
                                background: 'rgba(255, 255, 255, 0.05)',
                                borderRadius: '8px',
                                display: 'flex',
                                justifyContent: 'space-between',
                                alignItems: 'center'
                            }}>
                                <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                                    <span>✅</span>
                                    <div style={{ display: 'flex', flexDirection: 'column' }}>
                                        <span style={{ fontFamily: 'monospace', fontSize: '0.9rem' }}>
                                            {tx.sender_address.slice(0, 6)}...{tx.sender_address.slice(-4)}
                                        </span>
                                        <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                                            Checked In
                                        </span>
                                    </div>
                                </div>
                                <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                                    {new Date(tx.burn_block_time_iso).toLocaleTimeString()}
                                </span>
                                <a
                                    href={`https://explorer.hiro.so/txid/${tx.tx_id}?chain=mainnet`}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    style={{ textDecoration: 'none' }}
                                >
                                    ↗️
                                </a>
                            </div>
                        ))}
                    </div>
                )}
            </div>
        </div>
    );
}
