'use client';

import { useState, useEffect } from 'react';
import { useConnect } from '@stacks/connect-react';
import { StacksMainnet } from '@stacks/network';
import {
    callReadOnlyFunction,
    cvToValue,
    standardPrincipalCV
} from '@stacks/transactions';

export default function ReferralDashboard() {
    const { authOptions } = useConnect();
    const [userAddress, setUserAddress] = useState<string | null>(null);
    const [referralStats, setReferralStats] = useState({ referrals: 0, earnings: 0 });
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        if (authOptions.userSession?.isUserSignedIn()) {
            const userData = authOptions.userSession.loadUserData();
            setUserAddress(userData.profile.stxAddress.mainnet);
        }
    }, [authOptions.userSession]);

    useEffect(() => {
        if (userAddress) {
            fetchReferralStats();
        }
    }, [userAddress]);

    const fetchReferralStats = async () => {
        if (!userAddress) return;
        try {
            const network = new StacksMainnet();
            const result = await callReadOnlyFunction({
                contractAddress: 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9', // Example, should be user's deployed addr
                contractName: 'referral-system',
                functionName: 'get-referral-stats',
                functionArgs: [standardPrincipalCV(userAddress)],
                network,
                senderAddress: userAddress,
            });
            const value = cvToValue(result);
            setReferralStats({
                referrals: Number(value.referrals),
                earnings: Number(value.earnings) / 1000000,
            });
        } catch (error) {
            console.error('Error fetching referral stats:', error);
        } finally {
            setLoading(false);
        }
    };

    const copyReferralLink = () => {
        if (!userAddress) return;
        const link = `${window.location.origin}/?ref=${userAddress}`;
        navigator.clipboard.writeText(link);
        alert('Referral link copied to clipboard!');
    };

    if (!userAddress) return null;

    return (
        <div className="referral-dashboard card-premium">
            <div className="card-header">
                <h2>🤝 Referral Program</h2>
                <p>Invite friends and earn rewards when they check in!</p>
            </div>

            <div className="stats-grid">
                <div className="stat-card">
                    <span className="stat-label">Total Referrals</span>
                    <span className="stat-value">{referralStats.referrals}</span>
                </div>
                <div className="stat-card">
                    <span className="stat-label">Total Earned</span>
                    <span className="stat-value">{referralStats.earnings} STX</span>
                </div>
            </div>

            <div className="referral-link-section">
                <h3>Your Referral Link</h3>
                <div className="link-input-group">
                    <input
                        type="text"
                        readOnly
                        value={`${window.location.origin}/?ref=${userAddress}`}
                        className="referral-input"
                    />
                    <button onClick={copyReferralLink} className="btn-primary">
                        Copy Link
                    </button>
                </div>
            </div>

            <style jsx>{`
                .referral-dashboard {
                    padding: 2rem;
                    border-radius: 1.5rem;
                    background: rgba(255, 255, 255, 0.05);
                    backdrop-filter: blur(10px);
                    border: 1px solid rgba(255, 255, 255, 0.1);
                    margin-top: 2rem;
                }
                .stats-grid {
                    display: grid;
                    grid-template-columns: 1fr 1fr;
                    gap: 1.5rem;
                    margin: 2rem 0;
                }
                .stat-card {
                    background: rgba(255, 255, 255, 0.03);
                    padding: 1.5rem;
                    border-radius: 1rem;
                    text-align: center;
                    border: 1px solid rgba(255, 255, 255, 0.05);
                }
                .stat-label {
                    display: block;
                    font-size: 0.9rem;
                    color: #888;
                    margin-bottom: 0.5rem;
                }
                .stat-value {
                    font-size: 1.8rem;
                    font-weight: bold;
                    color: #fff;
                }
                .referral-link-section {
                    margin-top: 2rem;
                }
                .link-input-group {
                    display: flex;
                    gap: 1rem;
                    margin-top: 1rem;
                }
                .referral-input {
                    flex: 1;
                    background: rgba(0, 0, 0, 0.2);
                    border: 1px solid rgba(255, 255, 255, 0.1);
                    color: #888;
                    padding: 0.8rem 1rem;
                    border-radius: 0.8rem;
                    font-family: monospace;
                    font-size: 0.9rem;
                }
                .btn-primary {
                    background: linear-gradient(135deg, #5546ff 0%, #00d2ff 100%);
                    border: none;
                    color: white;
                    padding: 0.8rem 1.5rem;
                    border-radius: 0.8rem;
                    font-weight: 600;
                    cursor: pointer;
                    transition: transform 0.2s;
                }
                .btn-primary:hover {
                    transform: translateY(-2px);
                }
            `}</style>
        </div>
    );
}
