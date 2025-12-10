# card-processing-system

A COBOL based card transaction processing system simulating real world banking logic using JCL and z/OS.

## About

A professional-grade card transaction processing system built for mainframe environments. This system processes card transactions against account master files, applies business rules, and generates updated account files, statements, and rejection reports.

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

## Processing Flow

1. **Load Phase**: Account master file is loaded into memory (in-memory table structure)
2. **Transaction Processing**: Each transaction is validated and processed sequentially
3. **Validation**: Checks for account existence, status, and amount validity
4. **Business Logic**: Applies transaction rules based on type (Purchase, Refund, Fee, Credit)
5. **Output Generation**: Writes updated accounts, statements, and rejected transactions

## How to Run

1. Upload COBOL source (`src/CARDPROC.cbl`) to your mainframe PDS
2. Update JCL dataset names in `jcl/CARDPROC.jcl` to match your system:
   - Source library (YOUR.HLQ.SOURCE)
   - Load library (YOUR.HLQ.LOADLIB)
   - Data files (YOUR.HLQ.DATA.*)
3. Upload sample data files to your data datasets
4. Submit the JCL job `CARDPROC.jcl`
5. Review output files: `ACCOUNTS.OUT`, `STATEMENTS.OUT`, `REJECTS.OUT`

## Technical Details

- **Language**: IBM Enterprise COBOL
- **File Organization**: Sequential (QSAM)
- **Record Format**: Fixed-length (FB)
- **Processing**: Batch mode with in-memory account table
- **Error Handling**: File status checking and transaction rejection with reason codes

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
