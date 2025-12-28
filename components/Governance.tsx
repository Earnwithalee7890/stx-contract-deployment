'use client';

import { useState, useEffect } from 'react';

interface Proposal {
    id: number;
    title: string;
    description: string;
    votesFor: number;
    votesAgainst: number;
    status: 'ACTIVE' | 'PASSED' | 'REJECTED';
    endTime: number;
}

export function Governance({ userAddress, setMessage }: { userAddress: string, setMessage: (m: string) => void }) {
    const [proposals, setProposals] = useState<Proposal[]>([]);
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        // Mock data for initial demo
        setProposals([
            {
                id: 1,
                title: "Increase Check-in Rewards",
                description: "Proposed increase of rewards for daily check-ins from 0.1 to 0.15 STX.",
                votesFor: 12500,
                votesAgainst: 4200,
                status: 'ACTIVE',
                endTime: Date.now() + 86400000 * 3
            },
            {
                id: 2,
                title: "Add Base-Stacks Bridge",
                description: "Implement a cross-chain bridge for seamless liquidity between Base and Stacks.",
                votesFor: 45000,
                votesAgainst: 1200,
                status: 'ACTIVE',
                endTime: Date.now() + 86400000 * 5
            }
        ]);
    }, []);

    const handleVote = (id: number, type: 'for' | 'against') => {
        if (!userAddress) {
            setMessage('❌ Please connect wallet to vote');
            return;
        }
        setMessage(`⏳ Submitting your vote ${type.toUpperCase()}...`);
        // Simulate contract call
        setTimeout(() => {
            setMessage(`✅ Vote cast successfully for Proposal #${id}!`);
        }, 1500);
    };

    return (
        <div className="glass-card content-animate" style={{ marginTop: '2rem' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2rem' }}>
                <div>
                    <h2 style={{ fontSize: '1.8rem', background: 'linear-gradient(135deg, #fff 0%, #aaa 100%)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
                        🏛️ DAO Governance
                    </h2>
                    <p style={{ color: 'var(--text-muted)' }}>Vote on the future of the STX Builder Hub.</p>
                </div>
                <button className="btn btn-primary">+ Create Proposal</button>
            </div>

            <div className="grid" style={{ gridTemplateColumns: '1fr', gap: '1.5rem' }}>
                {proposals.map(prop => (
                    <div key={prop.id} className="glass-card" style={{ padding: '1.5rem', background: 'rgba(255,255,255,0.03)', border: '1px solid rgba(255,255,255,0.05)' }}>
                        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1rem' }}>
                            <span style={{ fontSize: '0.8rem', color: '#ff4b4b', fontWeight: 'bold' }}>PROPOSAL #{prop.id}</span>
                            <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>🕒 Ends in 3 days</span>
                        </div>
                        <h3 style={{ fontSize: '1.3rem', marginBottom: '0.5rem' }}>{prop.title}</h3>
                        <p style={{ color: 'var(--text-muted)', marginBottom: '1.5rem', lineHeight: '1.6' }}>{prop.description}</p>

                        <div style={{ marginBottom: '1.5rem' }}>
                            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.9rem', marginBottom: '0.5rem' }}>
                                <span>Support</span>
                                <span style={{ color: '#10b981' }}>{((prop.votesFor / (prop.votesFor + prop.votesAgainst)) * 100).toFixed(1)}%</span>
                            </div>
                            <div style={{ width: '100%', height: '8px', background: 'rgba(255,255,255,0.1)', borderRadius: '4px', overflow: 'hidden' }}>
                                <div style={{ width: `${(prop.votesFor / (prop.votesFor + prop.votesAgainst)) * 100}%`, height: '100%', background: '#10b981' }}></div>
                            </div>
                        </div>

                        <div style={{ display: 'flex', gap: '1rem' }}>
                            <button className="btn" onClick={() => handleVote(prop.id, 'for')} style={{ flex: 1, background: 'rgba(16, 185, 129, 0.1)', color: '#10b981', border: '1px solid rgba(16, 185, 129, 0.2)' }}>
                                👍 Vote For
                            </button>
                            <button className="btn" onClick={() => handleVote(prop.id, 'against')} style={{ flex: 1, background: 'rgba(239, 68, 68, 0.1)', color: '#ef4444', border: '1px solid rgba(239, 68, 68, 0.2)' }}>
                                👎 Vote Against
                            </button>
                        </div>
                    </div>
                ))}
            </div>
        </div>
    );
}
