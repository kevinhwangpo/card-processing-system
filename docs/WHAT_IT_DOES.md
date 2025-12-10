# What This System Does

## Overview

This is a **batch card transaction processing system** that simulates how banks process credit card transactions on mainframes. It reads account data and transactions, applies business rules, and generates updated outputs.

## Current Capabilities

### Input Files

1. **ACCOUNTS.IN** - Master file with 6 sample accounts containing:
   - Card number (16 digits)
   - Account holder name
   - Credit limit
   - Current balance (can be positive or negative)
   - Status (A=Active, B=Blocked)

2. **TXNS.IN** - Transaction file with 12 sample transactions including:
   - Valid purchases, refunds, fees, and payments
   - Test cases: invalid card, blocked account, zero amount, over-limit

### Processing Logic

For each transaction, the system:

1. **Validates the amount** - Rejects zero or negative amounts
2. **Finds the account** - Looks up the card number in the account table
3. **Checks account status** - Rejects transactions for blocked accounts
4. **Applies transaction rules**:
   - **Purchase (P)**: Adds amount to balance, flags if over credit limit
   - **Refund (R)**: Subtracts amount from balance
   - **Fee (F)**: Adds amount to balance, checks over-limit
   - **Credit/Payment (C)**: Subtracts amount from balance
5. **Tracks over-limit** - Flags accounts that exceed their credit limit

### Output Files

1. **ACCOUNTS.OUT** - Updated account master file with new balances
2. **STATEMENTS.OUT** - Summary statements showing:
   - Card number, name, final balance, status
   - Over-limit indicator if applicable
3. **REJECTS.OUT** - Rejected transactions with reason codes:
   - `NOACCT` - Account doesn't exist
   - `BLOCKED` - Account is blocked
   - `BADAMT` - Invalid amount (zero or negative)

## Example Flow

**Input Account:**
```
Card: 4532123456789012
Name: JOHN DOE
Limit: $5,000.00
Balance: -$123.45 (owes $123.45)
Status: Active
```

**Transaction 1:** Purchase of $125.50
- Validates ✓
- Finds account ✓
- Account is active ✓
- Updates balance: -$123.45 + $125.50 = **$2.05** (now owes $2.05)

**Transaction 2:** Purchase of $3,000.00
- Validates ✓
- Finds account ✓
- Account is active ✓
- Updates balance: $2.05 + $3,000.00 = **$3,002.05**
- **OVER LIMIT** (exceeds $5,000 credit limit) - Flagged!

**Transaction 3:** Invalid card number
- Validates ✓
- **Account not found** → Rejected with reason `NOACCT`

## What Makes It Impressive

- ✅ Demonstrates real-world banking batch processing
- ✅ Shows understanding of mainframe file handling
- ✅ Implements proper business rules and validation
- ✅ Handles error cases with clear rejection reporting
- ✅ Simple enough to explain, complex enough to show skills

