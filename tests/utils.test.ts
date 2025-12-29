import { describe, it, expect } from 'vitest';
import { formatSTX, truncateAddress } from '../lib/utils';

describe('Utility Functions', () => {
    it('should format microSTX to STX correctly', () => {
        expect(formatSTX(1000000)).toBe('1.00 STX');
        expect(formatSTX(500000)).toBe('0.50 STX');
    });

    it('should truncate Stacks addresses correctly', () => {
        const addr = 'SP3W92926715MNGN3P20DMN65DM5DMN66DM66060';
        expect(truncateAddress(addr)).toBe('SP3W92...6060');
    });
});
