#!/usr/bin/env python3
"""
Python simulator for the COBOL card processing system
This demonstrates the same logic without needing a COBOL compiler
"""

def load_accounts(filename):
    """Load accounts from file into memory"""
    accounts = []
    try:
        with open(filename, 'r') as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                # Parse fixed-width record (52 chars total)
                # Format: 16 card + 20 name + 7 credit_limit + 8 balance(signed) + 1 status
                card_num = line[0:16]
                name = line[16:36].strip()
                credit_limit_str = line[36:43]  # 7 digits (V99 = 2 implied decimals)
                balance_str = line[43:51]  # 8 chars: 7 digits + sign
                status = line[51]
                
                # Convert to numbers (V99 means 2 decimal places - implied decimal)
                # Format: 0005000 means $5000.00, 00012345- means -$123.45
                credit_limit = int(credit_limit_str) / 100
                balance_sign = balance_str[-1]
                balance_digits = balance_str[0:7]  # First 7 digits
                balance = int(balance_digits) / 100
                if balance_sign == '-':
                    balance = -balance
                elif balance_sign == '+':
                    balance = abs(balance)
                else:
                    # If no sign, assume positive
                    balance = abs(balance)
                
                accounts.append({
                    'card_num': card_num,
                    'name': name,
                    'credit_limit': credit_limit,
                    'balance': balance,
                    'status': status,
                    'overlimit': False
                })
    except FileNotFoundError:
        print(f"Error: Could not find {filename}")
        return []
    
    print(f"Loaded {len(accounts)} accounts")
    return accounts

def load_transactions(filename):
    """Load transactions from file"""
    transactions = []
    try:
        with open(filename, 'r') as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                # Parse fixed-width record (52 chars total)
                # Format: 16 card + 1 type + 7 amount + 20 desc + 8 date
                card_num = line[0:16]
                txn_type = line[16:17]
                amount_str = line[17:24]  # 7 digits (V99 = 2 implied decimals)
                desc = line[24:44].strip()
                date = line[44:52]
                
                # Convert amount (V99 means 2 decimal places - implied decimal)
                # Format: 0000125 means $1.25, 0001250 means $12.50
                amount = int(amount_str) / 100
                
                transactions.append({
                    'card_num': card_num,
                    'type': txn_type,
                    'amount': amount,
                    'desc': desc,
                    'date': date
                })
    except FileNotFoundError:
        print(f"Error: Could not find {filename}")
        return []
    
    print(f"Loaded {len(transactions)} transactions")
    return transactions

def find_account(accounts, card_num):
    """Find account by card number"""
    for i, account in enumerate(accounts):
        if account['card_num'] == card_num:
            return i
    return -1

def process_transactions(accounts, transactions):
    """Process all transactions"""
    rejects = []
    
    print("\nProcessing transactions...")
    print("-" * 60)
    
    for txn in transactions:
        card_num = txn['card_num']
        txn_type = txn['type']
        amount = txn['amount']
        
        # Step 1: Validate amount
        if amount <= 0:
            rejects.append({
                **txn,
                'reason': 'BADAMT'
            })
            print(f"REJECTED: {txn['desc']} - Invalid amount")
            continue
        
        # Step 2: Find account
        acct_idx = find_account(accounts, card_num)
        if acct_idx == -1:
            rejects.append({
                **txn,
                'reason': 'NOACCT'
            })
            print(f"REJECTED: {txn['desc']} - Account not found")
            continue
        
        account = accounts[acct_idx]
        
        # Step 3: Check if blocked
        if account['status'] == 'B':
            rejects.append({
                **txn,
                'reason': 'BLOCKED'
            })
            print(f"REJECTED: {txn['desc']} - Account blocked")
            continue
        
        # Step 4: Apply transaction
        old_balance = account['balance']
        
        if txn_type == 'P':  # Purchase
            account['balance'] += amount
            print(f"PURCHASE: ${amount:.2f} on {account['name']} - Balance: ${old_balance:.2f} → ${account['balance']:.2f}")
        elif txn_type == 'R':  # Refund
            account['balance'] -= amount
            print(f"REFUND: ${amount:.2f} on {account['name']} - Balance: ${old_balance:.2f} → ${account['balance']:.2f}")
        elif txn_type == 'F':  # Fee
            account['balance'] += amount
            print(f"FEE: ${amount:.2f} on {account['name']} - Balance: ${old_balance:.2f} → ${account['balance']:.2f}")
        elif txn_type == 'C':  # Credit/Payment
            account['balance'] -= amount
            print(f"PAYMENT: ${amount:.2f} on {account['name']} - Balance: ${old_balance:.2f} → ${account['balance']:.2f}")
        
        # Check over limit
        if account['balance'] > account['credit_limit']:
            account['overlimit'] = True
            print(f"  ⚠️  OVER LIMIT! (Limit: ${account['credit_limit']:.2f})")
    
    print("-" * 60)
    return rejects

def write_outputs(accounts, rejects):
    """Write output files"""
    # Write ACCOUNTS.OUT
    with open('ACCOUNTS.OUT', 'w') as f:
        for acct in accounts:
            card_num = acct['card_num']
            name = acct['name'].ljust(20)
            credit_limit = int(acct['credit_limit'] * 100)
            balance = int(abs(acct['balance']) * 100)
            balance_sign = '-' if acct['balance'] < 0 else '+'
            status = acct['status']
            
            line = f"{card_num}{name}{credit_limit:07d}{balance:07d}{balance_sign}{status}\n"
            f.write(line)
    
    # Write STATEMENTS.OUT
    with open('STATEMENTS.OUT', 'w') as f:
        for acct in accounts:
            card_num = acct['card_num']
            name = acct['name'].ljust(20)
            balance = acct['balance']
            status = acct['status']
            overlimit = "OVERLIMIT" if acct['overlimit'] else "         "
            
            line = f"{card_num} {name} {balance:>10.2f} {status} {overlimit}\n"
            f.write(line)
    
    # Write REJECTS.OUT
    with open('REJECTS.OUT', 'w') as f:
        for rej in rejects:
            card_num = rej['card_num']
            txn_type = rej['type']
            amount = rej['amount']
            desc = rej['desc'].ljust(20)
            date = rej['date']
            reason = rej['reason'].ljust(8)
            
            line = f"{card_num} {txn_type} {amount:>9.2f} {desc} {date} {reason}\n"
            f.write(line)
    
    print(f"\nOutput files created:")
    print(f"  - ACCOUNTS.OUT ({len(accounts)} records)")
    print(f"  - STATEMENTS.OUT ({len(accounts)} records)")
    print(f"  - REJECTS.OUT ({len(rejects)} records)")

def main():
    print("=" * 60)
    print("Card Processing System - Python Simulator")
    print("=" * 60)
    
    # Load data
    accounts = load_accounts('data/ACCOUNTS.IN')
    transactions = load_transactions('data/TXNS.IN')
    
    if not accounts or not transactions:
        print("Error loading input files")
        return
    
    # Process transactions
    rejects = process_transactions(accounts, transactions)
    
    # Write outputs
    write_outputs(accounts, rejects)
    
    print("\n" + "=" * 60)
    print("Processing complete!")
    print("=" * 60)
    
    # Show summary
    print("\nFinal Account Balances:")
    print("-" * 60)
    for acct in accounts:
        overlimit_flag = " ⚠️ OVER LIMIT" if acct['overlimit'] else ""
        print(f"{acct['name']:20s} Balance: ${acct['balance']:>10.2f}  Status: {acct['status']}{overlimit_flag}")
    
    if rejects:
        print(f"\nRejected Transactions: {len(rejects)}")
        for rej in rejects:
            print(f"  - {rej['desc']:20s} Reason: {rej['reason']}")

if __name__ == '__main__':
    main()

