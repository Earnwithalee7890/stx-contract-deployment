'use client';

import { useState, useEffect } from 'react';
import { useConnect } from '@stacks/connect-react';
import { StacksMainnet } from '@stacks/network';

const BADGES = [
    { id: 1, name: 'First Check-in', icon: '🐣', description: 'Your journey begins!' },
    { id: 2, name: '7-Day Streaker', icon: '🔥', description: 'One week of consistency.' },
    { id: 3, name: 'Master Builder', icon: '🛠️', description: 'A true veteran of the challenge.' },
];

export default function BadgeMinter() {
    const { doContractCall } = useConnect();
    const [userAddress, setUserAddress] = useState<string | null>(null);

    const mintBadge = async (badgeId: number) => {
        await doContractCall({
            contractAddress: 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9', // Example
            contractName: 'milestone-badges',
            functionName: 'mint-badge',
            functionArgs: [
                // recipient (caller), badge-type
            ],
            // ... more args
        });
    };

    return (
        <div className="badge-minter card-premium">
            <div className="card-header">
                <h2>🏅 Milestone Badges</h2>
                <p>Unlock exclusive NFTs as you reach project milestones!</p>
            </div>

            <div className="badges-grid">
                {BADGES.map((badge) => (
                    <div key={badge.id} className="badge-card">
                        <div className="badge-icon">{badge.icon}</div>
                        <h3>{badge.name}</h3>
                        <p>{badge.description}</p>
                        <button
                            className="btn-mint"
                            onClick={() => mintBadge(badge.id)}
                        >
                            Claim Badge
                        </button>
                    </div>
                ))}
            </div>

            <style jsx>{`
                .badge-minter {
                    padding: 2rem;
                    border-radius: 1.5rem;
                    background: rgba(0, 0, 0, 0.2);
                    border: 1px solid rgba(255, 255, 255, 0.1);
                    margin-top: 2rem;
                }
                .badges-grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                    gap: 1.5rem;
                    margin-top: 2rem;
                }
                .badge-card {
                    background: rgba(255, 255, 255, 0.05);
                    padding: 1.5rem;
                    border-radius: 1.2rem;
                    text-align: center;
                    border: 1px solid rgba(255, 255, 255, 0.05);
                    transition: transform 0.3s ease;
                }
                .badge-card:hover {
                    transform: scale(1.05);
                    border-color: rgba(0, 210, 255, 0.4);
                }
                .badge-icon {
                    font-size: 3rem;
                    margin-bottom: 1rem;
                }
                .btn-mint {
                    margin-top: 1rem;
                    padding: 0.6rem 1.2rem;
                    border-radius: 0.6rem;
                    background: rgba(255, 255, 255, 0.1);
                    border: 1px solid rgba(255, 255, 255, 0.2);
                    color: white;
                    cursor: pointer;
                    font-weight: 500;
                    transition: all 0.2s;
                }
                .btn-mint:hover {
                    background: white;
                    color: black;
                }
            `}</style>
        </div>
    );
}
