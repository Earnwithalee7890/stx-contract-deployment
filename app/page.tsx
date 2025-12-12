'use client';

import dynamic from 'next/dynamic';

const ClientPage = dynamic(() => import('@/components/ClientPage'), {
    ssr: false,
    loading: () => (
        <div style={{
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            minHeight: '100vh',
            color: 'white'
        }}>
            Loading STX App...
        </div>
    ),
});

export default function Home() {
    return <ClientPage />;
}
