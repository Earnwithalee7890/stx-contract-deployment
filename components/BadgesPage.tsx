'use client';

import { useState, useEffect } from 'react';
import styles from './BadgesPage.module.css';

interface BadgeData {
    day: number;
    name: string;
    emoji: string;
    earned: boolean;
}

export function BadgesPage() {
    const [userAddress, setUserAddress] = useState('');
    const [loading, setLoading] = useState(false);
    const [message, setMessage] = useState('');
    const [currentDay, setCurrentDay] = useState(0);
    const [badges, setBadges] = useState<BadgeData[]>([
        { day: 0, name: 'Monday Warrior', emoji: '⚔️', earned: false },
        { day: 1, name: 'Tuesday Titan', emoji: '💪', earned: false },
        { day: 2, name: 'Wednesday Winner', emoji: '🏆', earned: false },
        { day: 3, name: 'Thursday Thunder', emoji: '⚡', earned: false },
        { day: 4, name: 'Friday Fire', emoji: '🔥', earned: false },
        { day: 5, name: 'Saturday Star', emoji: '⭐', earned: false },
        { day: 6, name: 'Sunday Champion', emoji: '👑', earned: false },
    ]);
    const [stats, setStats] = useState({
        totalEarned: 0,
        currentStreak: 0,
        longestStreak: 0
    });

    const handleConnect = async () => {
        if (typeof window === 'undefined') return;

        const { showConnect } = await import('@stacks/connect');

        showConnect({
            appDetails: {
                name: 'STX Builder Hub - Badges',
                icon: '/logo.png',
            },
            onFinish: (data) => {
                setUserAddress(data.userSession.loadUserData().profile.stxAddress.mainnet);
                setMessage('✅ Wallet connected!');
                // TODO: Load user's earned badges
            },
            onCancel: () => {
                setMessage('❌ Connection cancelled');
            },
        });
    };

    const handleEarnBadge = async () => {
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
                contractName: 'weekly-rewards', // Deployed contract name
                functionName: 'earn-badge',
                functionArgs: [],
                network: 'mainnet',
                anchorMode: AnchorMode.Any,
                postConditionMode: PostConditionMode.Allow,
                onFinish: (data) => {
                    setMessage(`✅ Badge earned! Fee: 0.01 STX | TX: ${data.txId}`);
                    // Update badge display
                    const updatedBadges = [...badges];
                    updatedBadges[currentDay].earned = true;
                    setBadges(updatedBadges);
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

    // Simulate current day (in production, fetch from contract)
    useEffect(() => {
        const today = new Date().getDay();
        // Convert Sunday (0) to 6, and shift others
        const dayIndex = today === 0 ? 6 : today - 1;
        setCurrentDay(dayIndex);
    }, []);

    return (
        <div className={styles.container}>
            <header className={styles.header}>
                <h1>🏅 Weekly Badges</h1>
                <p>Earn unique badges for each day you check in!</p>
            </header>

            {!userAddress ? (
                <div className={styles.connectCard}>
                    <button className={styles.btnPrimary} onClick={handleConnect}>
                        🔗 Connect Wallet
                    </button>
                </div>
            ) : (
                <>
                    <div className={styles.walletInfo}>
                        <span className={styles.address}>{userAddress}</span>
                        <span className={styles.connected}>● Connected</span>
                    </div>

                    {/* Current Day Badge */}
                    <div className={styles.currentBadge}>
                        <h2>Today's Badge</h2>
                        <div className={styles.todayBadgeCard}>
                            <div className={styles.badgeEmoji}>{badges[currentDay].emoji}</div>
                            <h3>{badges[currentDay].name}</h3>
                            <p>Cost: 0.01 STX</p>
                            <button
                                className={styles.btnEarn}
                                onClick={handleEarnBadge}
                                disabled={loading || badges[currentDay].earned}
                            >
                                {loading ? 'Earning...' : badges[currentDay].earned ? '✅ Earned!' : '🎯 Earn Badge'}
                            </button>
                        </div>
                    </div>

                    {/* Stats */}
                    <div className={styles.stats}>
                        <div className={styles.statCard}>
                            <div className={styles.statValue}>{stats.totalEarned}</div>
                            <div className={styles.statLabel}>Total Badges</div>
                        </div>
                        <div className={styles.statCard}>
                            <div className={styles.statValue}>{stats.currentStreak}</div>
                            <div className={styles.statLabel}>Current Streak</div>
                        </div>
                        <div className={styles.statCard}>
                            <div className={styles.statValue}>{stats.longestStreak}</div>
                            <div className={styles.statLabel}>Best Streak</div>
                        </div>
                    </div>

                    {/* Weekly Progress */}
                    <div className={styles.weeklyGrid}>
                        <h2>This Week's Progress</h2>
                        <div className={styles.badgesGrid}>
                            {badges.map((badge) => (
                                <div
                                    key={badge.day}
                                    className={`${styles.badgeCard} ${badge.earned ? styles.earned : ''} ${badge.day === currentDay ? styles.today : ''}`}
                                >
                                    <div className={styles.badgeIcon}>{badge.emoji}</div>
                                    <div className={styles.badgeName}>{badge.name}</div>
                                    {badge.earned && <div className={styles.checkmark}>✓</div>}
                                    {badge.day === currentDay && <div className={styles.todayLabel}>Today</div>}
                                </div>
                            ))}
                        </div>
                    </div>

                    {message && (
                        <div className={message.includes('✅') ? styles.successMessage : styles.errorMessage}>
                            {message}
                        </div>
                    )}
                </>
            )}
        </div>
    );
}
