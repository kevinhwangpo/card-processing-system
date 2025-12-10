# card-processing-system

A COBOL based card transaction processing system simulating real world banking logic using JCL and z/OS.

## About

A card transaction processing system built for mainframe environments. This system processes card transactions against account master files, applies business rules, and generates updated account files, statements, and rejection reports.

## Quick Explanation

This is a batch processing program that simulates how banks process credit card transactions:

- **Input**: A file of accounts and a file of transactions
- **Process**: For each transaction, find the account, validate it, and update the balance
- **Output**: Updated account balances, account statements, and a list of rejected transactions

The program demonstrates core mainframe concepts: sequential file processing, batch logic, data validation, and error handling. It's straightforward enough to explain in an interview but shows understanding of real-world banking systems.

## Project Structure

```
card-processing-system/
├── src/
│   └── CARDPROC.cbl      # Main COBOL program
├── jcl/
│   └── CARDPROC.jcl      # JCL for compilation and execution
├── data/
│   ├── ACCOUNTS.IN       # Account master file (input)
│   ├── TXNS.IN           # Transaction file (input)
│   └── sample_outputs/   # Expected output examples
│       ├── ACCOUNTS.OUT
│       ├── STATEMENTS.OUT
│       └── REJECTS.OUT
└── README.md
```

## Business Rules

The system processes card transactions with the following validations:

1. **Account Validation**: Transactions for non-existent accounts are rejected with reason `NOACCT`
2. **Status Check**: Transactions for blocked accounts are rejected with reason `BLOCKED`
3. **Amount Validation**: Zero or negative amounts are rejected with reason `BADAMT`
4. **Transaction Types**:
   - **P (Purchase)**: Adds to balance, flags if over credit limit
   - **R (Refund)**: Reduces balance
   - **F (Fee)**: Adds to balance
   - **C (Credit/Payment)**: Reduces balance

## How It Works

The program follows a simple 3-step process:

1. **Load accounts** - Reads all accounts into memory
2. **Process transactions** - For each transaction:
   - Validates the amount and account
   - Updates the account balance based on transaction type
   - Flags accounts that go over their credit limit
3. **Write outputs** - Generates updated account file, statements, and rejection report

## How to Run

### Option 1: Python Simulator (Quick Test)
```bash
python test_simulator.py
```
This runs the same logic without needing a COBOL compiler. See `docs/LOCAL_TESTING.md` for details.

### Option 2: Mainframe Environment
1. Upload the COBOL source to your mainframe
2. Update dataset names in the JCL file to match your system
3. Upload the sample data files
4. Submit the JCL job
5. Check the output files for results

See `docs/LOCAL_TESTING.md` for more options including GnuCOBOL.

## Key Features

- Simple batch processing workflow
- Account validation and status checking
- Transaction type handling (Purchase, Refund, Fee, Credit)
- Over-limit detection
- Clear rejection reporting with reason codes

## Data Layout

### Account Record (ACCOUNTS.IN)
- Card Number: 16 chars
- Name: 20 chars
- Credit Limit: 9(7)V99
- Current Balance: S9(7)V99
- Status: X(1) - 'A'=Active, 'B'=Blocked

### Transaction Record (TXNS.IN)
- Card Number: 16 chars
- Transaction Type: X(1) - 'P'=Purchase, 'R'=Refund, 'F'=Fee, 'C'=Credit
- Amount: 9(7)V99
- Description: 20 chars
- Date: 9(8) - YYYYMMDD
