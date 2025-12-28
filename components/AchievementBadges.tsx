'use client';

const BADGES = [
    { id: 1, title: 'Early Builder', desc: 'Joined during the first week of launch.', icon: '🏗️', color: '#3b82f6' },
    { id: 2, title: 'Hiro Specialist', desc: 'Successfully integrated Hiro Chainhooks.', icon: '🪝', color: '#ff4b4b' },
    { id: 3, title: 'Daily Committer', desc: 'Maintained a 7-day check-in streak.', icon: '🔥', color: '#fbbf24' },
    { id: 4, title: 'Clarity Master', desc: 'Deployed over 50 Clarity contracts.', icon: '📜', color: '#10b981' },
    { id: 5, title: 'DAO Member', desc: 'Voted on more than 5 governance proposals.', icon: '🏛️', color: '#8b5cf6' },
    { id: 6, title: 'Reward Expert', desc: 'Claimed over 10 STX in rewards.', icon: '💰', color: '#ec4899' },
];

export function AchievementBadges() {
    return (
        <div className="glass-card content-animate" style={{ marginTop: '2rem' }}>
            <h2 style={{ fontSize: '1.8rem', marginBottom: '0.2rem', color: 'white' }}>🏆 Builder Achievements</h2>
            <p style={{ color: 'var(--text-muted)', marginBottom: '2rem' }}>Your on-chain milestones and collectible badges.</p>

            <div className="grid" style={{ gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: '1.5rem' }}>
                {BADGES.map(badge => (
                    <div key={badge.id} className="glass-card badge-card" style={{
                        padding: '2rem',
                        textAlign: 'center',
                        position: 'relative',
                        overflow: 'hidden',
                        background: 'rgba(255,255,255,0.02)',
                        border: '1px solid rgba(255,255,255,0.05)',
                        transition: 'all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275)'
                    }}>
                        <div style={{
                            position: 'absolute',
                            top: '-20px',
                            right: '-20px',
                            width: '80px',
                            height: '80px',
                            background: badge.color,
                            filter: 'blur(40px)',
                            opacity: 0.15
                        }}></div>

                        <div style={{ fontSize: '3.5rem', marginBottom: '1rem', filter: 'drop-shadow(0 10px 15px rgba(0,0,0,0.3))' }}>
                            {badge.icon}
                        </div>
                        <h3 style={{ fontSize: '1.2rem', color: 'white', marginBottom: '0.5rem' }}>{badge.title}</h3>
                        <p style={{ fontSize: '0.9rem', color: 'var(--text-muted)', lineHeight: '1.5' }}>{badge.desc}</p>

                        <div style={{
                            marginTop: '1.5rem',
                            padding: '4px 12px',
                            borderRadius: '20px',
                            background: 'rgba(255,255,255,0.05)',
                            fontSize: '0.75rem',
                            display: 'inline-block',
                            color: 'var(--text-muted)',
                            border: '1px solid rgba(255,255,255,0.1)'
                        }}>
                            UNLOCKED
                        </div>
                    </div>
                ))}
            </div>

            <style jsx>{`
                .badge-card:hover {
                    transform: translateY(-8px);
                    border-color: rgba(255,255,255,0.15);
                    background: rgba(255,255,255,0.04);
                }
            `}</style>
        </div>
    );
}
