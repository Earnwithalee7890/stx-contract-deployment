# Utility Library

Shared helper functions for the Stacks Builder Challenge frontend.

## Key Utilities

### [utils.ts](./utils.ts)
- `formatSTX(microstx)`: Converts microSTX to a human-readable STX string.
- `truncateAddress(address)`: Formats Stacks addresses for UI display (e.g., SP12...3456).
- `formatPercent(value)`: Formats decimal values as percentages.

## Usage
Import these utilities into your components to ensure consistent formatting across the app:
```typescript
import { formatSTX } from '@/lib/utils';
```
