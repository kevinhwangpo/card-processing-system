# How to Run Locally

There are a few ways to test this system locally:

## Option 1: Using GnuCOBOL (Recommended for Windows/Linux/Mac)

GnuCOBOL (formerly OpenCOBOL) is a free COBOL compiler that works on Windows, Linux, and Mac.

### Installation

**Windows:**
1. Download GnuCOBOL from: https://sourceforge.net/projects/gnucobol/
2. Or use Chocolatey: `choco install gnucobol`
3. Or use WSL (Windows Subsystem for Linux) and install via apt

**Linux:**
```bash
sudo apt-get install gnucobol
# or
sudo yum install gnucobol
```

**Mac:**
```bash
brew install gnucobol
```

### Running the Program

1. **Navigate to project directory:**
   ```bash
   cd card-processing-system
   ```

2. **Compile the COBOL program:**
   ```bash
   cobc -x -o cardproc src/CARDPROC.cbl
   ```

3. **Run the program:**
   ```bash
   ./cardproc
   ```
   
   The program will read from `data/ACCOUNTS.IN` and `data/TXNS.IN` and create output files.

4. **Check the outputs:**
   - `ACCOUNTS.OUT` - Updated account balances
   - `STATEMENTS.OUT` - Account statements
   - `REJECTS.OUT` - Rejected transactions

### Note on File Assignments

GnuCOBOL uses different file assignment syntax. You may need to modify the `ASSIGN TO` clauses in the COBOL program or use environment variables:

```bash
export ACCOUNTSIN=data/ACCOUNTS.IN
export TXNSIN=data/TXNS.IN
export ACCOUNTSOUT=ACCOUNTS.OUT
export STATEMENTSOUT=STATEMENTS.OUT
export REJECTSOUT=REJECTS.OUT
./cardproc
```

## Option 2: Using a Python Simulator (Quick Demo)

I've created a Python script that simulates the COBOL logic so you can demo it without a COBOL compiler.

### Running the Python Simulator

```bash
python test_simulator.py
```

This will:
- Read the same input files
- Apply the same business logic
- Generate the same outputs
- Show you step-by-step what's happening

## Option 3: Manual Walkthrough

You can manually trace through the logic:

1. **Load accounts** - Read `data/ACCOUNTS.IN` (6 accounts)
2. **Process transactions** - Read `data/TXNS.IN` one by one:
   - Transaction 1: Purchase $125.50 on card 4532123456789012
   - Transaction 2: Refund $50.00 on card 4532123456789012
   - ... and so on
3. **Check outputs** - Compare with `data/sample_outputs/`

## Option 4: Mainframe Environment

If you have access to IBM Z Xplore or a mainframe:

1. Upload `src/CARDPROC.cbl` to your PDS
2. Update `jcl/CARDPROC.jcl` with your dataset names
3. Upload data files to your datasets
4. Submit the JCL job
5. Review the output datasets

## Troubleshooting

**File not found errors:**
- Make sure you're running from the project root directory
- Check that `data/ACCOUNTS.IN` and `data/TXNS.IN` exist

**Compilation errors:**
- GnuCOBOL syntax may differ slightly from IBM Enterprise COBOL
- Some IBM-specific features may need adjustment

**Output format differences:**
- GnuCOBOL may format numbers slightly differently
- The logic should be the same

