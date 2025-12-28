'use client';

import { useState } from 'react';

const MOCK_CONTRACTS = [
    { name: 'builder-rewards-v3.clar', lines: 342, category: 'Reward' },
    { name: 'decentralized-job-board.clar', lines: 125, category: 'Utility' },
    { name: 'proposal-voting.clar', lines: 210, category: 'Governance' },
    { name: 'nft-minter-v2.clar', lines: 180, category: 'NFT' },
];

export function CodeExplorer() {
    const [selected, setSelected] = useState(MOCK_CONTRACTS[0]);

    return (
        <div className="glass-card content-animate" style={{ marginTop: '2rem', minHeight: '500px', padding: 0, overflow: 'hidden' }}>
            <div style={{ display: 'flex', height: '500px' }}>
                {/* Sidebar */}
                <div style={{ width: '250px', background: 'rgba(0,0,0,0.2)', borderRight: '1px solid rgba(255,255,255,0.05)', padding: '1.5rem' }}>
                    <h3 style={{ fontSize: '0.9rem', color: '#ff4b4b', marginBottom: '1.5rem', textTransform: 'uppercase', letterSpacing: '1px' }}>📜 Contracts</h3>
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
                        {MOCK_CONTRACTS.map(c => (
                            <button
                                key={c.name}
                                onClick={() => setSelected(c)}
                                style={{
                                    textAlign: 'left',
                                    padding: '0.8rem',
                                    borderRadius: '6px',
                                    background: selected.name === c.name ? 'rgba(255,255,255,0.1)' : 'transparent',
                                    border: 'none',
                                    color: selected.name === c.name ? 'white' : 'var(--text-muted)',
                                    cursor: 'pointer',
                                    fontSize: '0.85rem',
                                    transition: 'all 0.2s'
                                }}
                            >
                                {c.name}
                            </button>
                        ))}
                    </div>
                </div>

                {/* Editor Content */}
                <div style={{ flex: 1, padding: '2rem', position: 'relative' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1.5rem' }}>
                        <div>
                            <h2 style={{ fontSize: '1.4rem', color: 'white', marginBottom: '0.2rem' }}>{selected.name}</h2>
                            <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>{selected.category} Module • {selected.lines} lines of code</span>
                        </div>
                        <button className="btn" style={{ fontSize: '0.8rem' }}>Copy Code</button>
                    </div>

                    <div style={{
                        background: 'rgba(0,0,0,0.3)',
                        padding: '1.5rem',
                        borderRadius: '8px',
                        fontFamily: 'monospace',
                        fontSize: '0.9rem',
                        color: '#d1d5db',
                        lineHeight: '1.6',
                        height: '350px',
                        overflowY: 'auto',
                        border: '1px solid rgba(255,255,255,0.05)'
                    }}>
                        {/* Simulation of code display */}
                        <div style={{ color: '#9ca3af' }}>;; {selected.name} initialized</div>
                        <div style={{ color: '#fbbf24' }}>(define-constant CONTRACT-OWNER tx-sender)</div>
                        <div style={{ color: '#10b981' }}>(define-public (initialize)</div>
                        <div style={{ marginLeft: '1rem' }}>(begin</div>
                        <div style={{ marginLeft: '2rem' }}>(ok (print "Hello Clarity 4!"))</div>
                        <div style={{ marginLeft: '1rem' }}>))</div>
                        <div>...</div>
                        <div style={{ color: '#3b82f6' }}>;; Logic continues for {selected.lines} lines...</div>
                    </div>

                    {/* AI Tip Overlay */}
                    <div style={{
                        marginTop: '1.5rem',
                        padding: '1rem',
                        background: 'linear-gradient(135deg, rgba(59, 130, 246, 0.1) 0%, rgba(139, 92, 246, 0.1) 100%)',
                        borderRadius: '8px',
                        border: '1px solid rgba(59, 130, 246, 0.2)',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '1rem'
                    }}>
                        <span style={{ fontSize: '1.2rem' }}>💡</span>
                        <p style={{ fontSize: '0.85rem', color: '#93c5fd', margin: 0 }}>
                            AI Tip: This contract uses Clarity 4 features for optimized block height tracking.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    );
}
