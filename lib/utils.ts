export const formatSTX = (microstx: number | bigint): string => {
    return (Number(microstx) / 1000000).toLocaleString(undefined, {
        minimumFractionDigits: 2,
        maximumFractionDigits: 6,
    }) + ' STX';
};

export const truncateAddress = (address: string): string => {
    if (!address) return '';
    return `${address.slice(0, 6)}...${address.slice(-4)}`;
};

export const formatPercent = (value: number): string => {
    return (value * 100).toFixed(2) + '%';
};
