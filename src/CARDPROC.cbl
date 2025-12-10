       IDENTIFICATION DIVISION.
       PROGRAM-ID. CARDPROC.
       AUTHOR. Card Processing System.
       DATE-WRITTEN. 2025-12-10.
      ******************************************************************
      * Purpose: Process card transactions against account master file *
      *          Apply business rules and generate outputs             *
      ******************************************************************
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ACCOUNTS-IN
               ASSIGN TO ACCOUNTSIN
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-ACCT-IN-STATUS.
               
           SELECT TXNS-IN
               ASSIGN TO TXNSIN
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-TXN-IN-STATUS.
               
           SELECT ACCOUNTS-OUT
               ASSIGN TO ACCOUNTSOUT
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-ACCT-OUT-STATUS.
               
           SELECT STATEMENTS-OUT
               ASSIGN TO STATEMENTSOUT
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-STMT-OUT-STATUS.
               
           SELECT REJECTS-OUT
               ASSIGN TO REJECTSOUT
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-REJ-OUT-STATUS.
       
       DATA DIVISION.
       FILE SECTION.
      ******************************************************************
      * Account Master File - Input                                   *
      ******************************************************************
       FD  ACCOUNTS-IN
           RECORDING MODE IS F
           RECORD CONTAINS 52 CHARACTERS
           BLOCK CONTAINS 0 RECORDS.
       01  ACCOUNT-REC-IN.
           05  ACCT-CARD-NUM-IN     PIC X(16).
           05  ACCT-NAME-IN         PIC X(20).
           05  ACCT-CREDIT-LIMIT-IN PIC 9(7)V99.
           05  ACCT-CURR-BAL-IN     PIC S9(7)V99.
           05  ACCT-STATUS-IN       PIC X(1).
       
      ******************************************************************
      * Transaction File - Input                                      *
      ******************************************************************
       FD  TXNS-IN
           RECORDING MODE IS F
           RECORD CONTAINS 52 CHARACTERS
           BLOCK CONTAINS 0 RECORDS.
       01  TXN-REC-IN.
           05  TXN-CARD-NUM-IN      PIC X(16).
           05  TXN-TYPE-IN          PIC X(1).
           05  TXN-AMOUNT-IN        PIC 9(7)V99.
           05  TXN-DESC-IN          PIC X(20).
           05  TXN-DATE-IN          PIC 9(8).
       
      ******************************************************************
      * Account Master File - Output                                  *
      ******************************************************************
       FD  ACCOUNTS-OUT
           RECORDING MODE IS F
           RECORD CONTAINS 52 CHARACTERS
           BLOCK CONTAINS 0 RECORDS.
       01  ACCOUNT-REC-OUT.
           05  ACCT-CARD-NUM-OUT    PIC X(16).
           05  ACCT-NAME-OUT        PIC X(20).
           05  ACCT-CREDIT-LIMIT-OUT PIC 9(7)V99.
           05  ACCT-CURR-BAL-OUT    PIC S9(7)V99.
           05  ACCT-STATUS-OUT      PIC X(1).
       
      ******************************************************************
      * Statements File - Output                                      *
      ******************************************************************
       FD  STATEMENTS-OUT
           RECORDING MODE IS F
           RECORD CONTAINS 80 CHARACTERS
           BLOCK CONTAINS 0 RECORDS.
       01  STATEMENT-REC-OUT.
           05  STMT-CARD-NUM        PIC X(16).
           05  FILLER               PIC X(1) VALUE SPACE.
           05  STMT-NAME            PIC X(20).
           05  FILLER               PIC X(1) VALUE SPACE.
           05  STMT-BALANCE         PIC -9(7).99.
           05  FILLER               PIC X(1) VALUE SPACE.
           05  STMT-STATUS          PIC X(1).
           05  FILLER               PIC X(1) VALUE SPACE.
           05  STMT-OVERLIMIT-FLAG  PIC X(9).
           05  FILLER               PIC X(24).
       
      ******************************************************************
      * Rejected Transactions File - Output                           *
      ******************************************************************
       FD  REJECTS-OUT
           RECORDING MODE IS F
           RECORD CONTAINS 80 CHARACTERS
           BLOCK CONTAINS 0 RECORDS.
       01  REJECT-REC-OUT.
           05  REJ-CARD-NUM         PIC X(16).
           05  FILLER               PIC X(1) VALUE SPACE.
           05  REJ-TYPE             PIC X(1).
           05  FILLER               PIC X(1) VALUE SPACE.
           05  REJ-AMOUNT           PIC 9(7).99.
           05  FILLER               PIC X(1) VALUE SPACE.
           05  REJ-DESC             PIC X(20).
           05  FILLER               PIC X(1) VALUE SPACE.
           05  REJ-DATE             PIC 9(8).
           05  FILLER               PIC X(1) VALUE SPACE.
           05  REJ-REASON           PIC X(8).
           05  FILLER               PIC X(20).
       
       WORKING-STORAGE SECTION.
      ******************************************************************
      * File Status Fields                                            *
      ******************************************************************
       01  WS-ACCT-IN-STATUS        PIC X(2).
       01  WS-TXN-IN-STATUS         PIC X(2).
       01  WS-ACCT-OUT-STATUS       PIC X(2).
       01  WS-STMT-OUT-STATUS       PIC X(2).
       01  WS-REJ-OUT-STATUS        PIC X(2).
       
      ******************************************************************
      * End of File Flags                                             *
      ******************************************************************
       01  WS-ACCT-EOF              PIC X(1) VALUE 'N'.
           88  ACCT-EOF                        VALUE 'Y'.
           88  ACCT-NOT-EOF                    VALUE 'N'.
       01  WS-TXN-EOF               PIC X(1) VALUE 'N'.
           88  TXN-EOF                         VALUE 'Y'.
           88  TXN-NOT-EOF                     VALUE 'N'.
       
      ******************************************************************
      * Account Table - Hold accounts in memory                       *
      ******************************************************************
       01  WS-ACCOUNT-TABLE.
           05  WS-MAX-ACCOUNTS      PIC 9(4) VALUE 100.
           05  WS-ACCOUNT-COUNT     PIC 9(4) VALUE ZERO.
           05  WS-ACCOUNT-ENTRY OCCURS 100 TIMES
                  INDEXED BY WS-ACCT-IDX.
               10  WS-ACCT-CARD-NUM PIC X(16).
               10  WS-ACCT-NAME     PIC X(20).
               10  WS-ACCT-CREDIT-LIMIT PIC 9(7)V99.
               10  WS-ACCT-CURR-BAL PIC S9(7)V99.
               10  WS-ACCT-STATUS   PIC X(1).
               10  WS-ACCT-OVERLIMIT PIC X(1) VALUE 'N'.
                   88  ACCT-OVERLIMIT          VALUE 'Y'.
                   88  ACCT-NOT-OVERLIMIT      VALUE 'N'.
       
      ******************************************************************
      * Work Variables                                                *
      ******************************************************************
       01  WS-FOUND-FLAG            PIC X(1) VALUE 'N'.
           88  ACCOUNT-FOUND                  VALUE 'Y'.
           88  ACCOUNT-NOT-FOUND              VALUE 'N'.
       01  WS-MATCHED-INDEX         PIC 9(4).
       01  WS-NEW-BALANCE           PIC S9(7)V99.
       01  WS-AMOUNT-ZERO           PIC X(1) VALUE 'N'.
           88  AMOUNT-IS-ZERO                 VALUE 'Y'.
           88  AMOUNT-NOT-ZERO                VALUE 'N'.
       01  WS-REJECT-REASON         PIC X(8).
       
      ******************************************************************
      * Constants                                                     *
      ******************************************************************
       01  WS-CONSTANTS.
           05  WS-STATUS-ACTIVE     PIC X(1) VALUE 'A'.
           05  WS-STATUS-BLOCKED    PIC X(1) VALUE 'B'.
           05  WS-TXN-PURCHASE      PIC X(1) VALUE 'P'.
           05  WS-TXN-REFUND        PIC X(1) VALUE 'R'.
           05  WS-TXN-FEE           PIC X(1) VALUE 'F'.
           05  WS-TXN-CREDIT        PIC X(1) VALUE 'C'.
           05  WS-REASON-NOACCT     PIC X(8) VALUE 'NOACCT  '.
           05  WS-REASON-BLOCKED    PIC X(8) VALUE 'BLOCKED '.
           05  WS-REASON-BADAMT     PIC X(8) VALUE 'BADAMT  '.
           05  WS-OVERLIMIT-TEXT    PIC X(9) VALUE 'OVERLIMIT'.
           05  WS-NO-OVERLIMIT-TEXT PIC X(9) VALUE '         '.
       
       PROCEDURE DIVISION.
      ******************************************************************
      * Main Processing Logic                                         *
      ******************************************************************
       MAIN-PARA.
           PERFORM INIT-FILES
           PERFORM LOAD-ACCOUNTS
           PERFORM PROCESS-TRANSACTIONS
           PERFORM WRITE-FINAL-OUTPUTS
           PERFORM CLOSE-FILES
           STOP RUN.
       
      ******************************************************************
      * Initialize Files                                              *
      ******************************************************************
       INIT-FILES.
           OPEN INPUT  ACCOUNTS-IN
                       TXNS-IN
                OUTPUT ACCOUNTS-OUT
                       STATEMENTS-OUT
                       REJECTS-OUT
           
           IF WS-ACCT-IN-STATUS NOT = '00'
               DISPLAY 'ERROR OPENING ACCOUNTS-IN: ' WS-ACCT-IN-STATUS
               STOP RUN
           END-IF
           
           IF WS-TXN-IN-STATUS NOT = '00'
               DISPLAY 'ERROR OPENING TXNS-IN: ' WS-TXN-IN-STATUS
               STOP RUN
           END-IF.
       
      ******************************************************************
      * Load Account Master File into Memory                          *
      ******************************************************************
       LOAD-ACCOUNTS.
           MOVE ZERO TO WS-ACCOUNT-COUNT
           SET WS-ACCT-IDX TO 1
           
           PERFORM UNTIL ACCT-EOF
               READ ACCOUNTS-IN
                   AT END
                       SET ACCT-EOF TO TRUE
                   NOT AT END
                       IF WS-ACCOUNT-COUNT < WS-MAX-ACCOUNTS
                           ADD 1 TO WS-ACCOUNT-COUNT
                           MOVE ACCT-CARD-NUM-IN TO 
                                WS-ACCT-CARD-NUM(WS-ACCT-IDX)
                           MOVE ACCT-NAME-IN TO 
                                WS-ACCT-NAME(WS-ACCT-IDX)
                           MOVE ACCT-CREDIT-LIMIT-IN TO 
                                WS-ACCT-CREDIT-LIMIT(WS-ACCT-IDX)
                           MOVE ACCT-CURR-BAL-IN TO 
                                WS-ACCT-CURR-BAL(WS-ACCT-IDX)
                           MOVE ACCT-STATUS-IN TO 
                                WS-ACCT-STATUS(WS-ACCT-IDX)
                           SET ACCT-NOT-OVERLIMIT(WS-ACCT-IDX) TO TRUE
                           SET WS-ACCT-IDX UP BY 1
                       END-IF
               END-READ
           END-PERFORM
           
           DISPLAY 'LOADED ' WS-ACCOUNT-COUNT ' ACCOUNTS'.
       
      ******************************************************************
      * Process All Transactions                                      *
      ******************************************************************
       PROCESS-TRANSACTIONS.
           PERFORM UNTIL TXN-EOF
               READ TXNS-IN
                   AT END
                       SET TXN-EOF TO TRUE
                   NOT AT END
                       PERFORM VALIDATE-AND-PROCESS-TXN
               END-READ
           END-PERFORM.
       
      ******************************************************************
      * Validate and Process Individual Transaction                   *
      ******************************************************************
       VALIDATE-AND-PROCESS-TXN.
      *    Check if amount is zero or negative
           IF TXN-AMOUNT-IN = ZERO OR TXN-AMOUNT-IN < ZERO
               MOVE WS-REASON-BADAMT TO WS-REJECT-REASON
               PERFORM WRITE-REJECT
               EXIT PARAGRAPH
           END-IF
           
      *    Find the account
           PERFORM FIND-ACCOUNT
           
           IF ACCOUNT-NOT-FOUND
               MOVE WS-REASON-NOACCT TO WS-REJECT-REASON
               PERFORM WRITE-REJECT
               EXIT PARAGRAPH
           END-IF
           
      *    Check if account is blocked
           IF WS-ACCT-STATUS(WS-MATCHED-INDEX) = WS-STATUS-BLOCKED
               MOVE WS-REASON-BLOCKED TO WS-REJECT-REASON
               PERFORM WRITE-REJECT
               EXIT PARAGRAPH
           END-IF
           
      *    Apply transaction rules
           PERFORM APPLY-TXN-RULES.
       
      ******************************************************************
      * Find Account in Table                                         *
      ******************************************************************
       FIND-ACCOUNT.
           SET ACCOUNT-NOT-FOUND TO TRUE
           SET WS-ACCT-IDX TO 1
           
           PERFORM VARYING WS-ACCT-IDX FROM 1 BY 1
               UNTIL WS-ACCT-IDX > WS-ACCOUNT-COUNT
                   OR ACCOUNT-FOUND
               IF WS-ACCT-CARD-NUM(WS-ACCT-IDX) = TXN-CARD-NUM-IN
                   SET ACCOUNT-FOUND TO TRUE
                   MOVE WS-ACCT-IDX TO WS-MATCHED-INDEX
               END-IF
           END-PERFORM.
       
      ******************************************************************
      * Apply Transaction Business Rules                              *
      ******************************************************************
       APPLY-TXN-RULES.
           EVALUATE TXN-TYPE-IN
               WHEN WS-TXN-PURCHASE
      *            Purchase: add to balance
                   COMPUTE WS-NEW-BALANCE = 
                       WS-ACCT-CURR-BAL(WS-MATCHED-INDEX) 
                       + TXN-AMOUNT-IN
                   MOVE WS-NEW-BALANCE TO 
                        WS-ACCT-CURR-BAL(WS-MATCHED-INDEX)
                   
      *            Check if over limit
                   IF WS-ACCT-CURR-BAL(WS-MATCHED-INDEX) > 
                      WS-ACCT-CREDIT-LIMIT(WS-MATCHED-INDEX)
                       SET ACCT-OVERLIMIT(WS-MATCHED-INDEX) TO TRUE
                   END-IF
                   
               WHEN WS-TXN-REFUND
      *            Refund: subtract from balance
                   COMPUTE WS-NEW-BALANCE = 
                       WS-ACCT-CURR-BAL(WS-MATCHED-INDEX) 
                       - TXN-AMOUNT-IN
                   MOVE WS-NEW-BALANCE TO 
                        WS-ACCT-CURR-BAL(WS-MATCHED-INDEX)
                   
               WHEN WS-TXN-FEE
      *            Fee: add to balance
                   COMPUTE WS-NEW-BALANCE = 
                       WS-ACCT-CURR-BAL(WS-MATCHED-INDEX) 
                       + TXN-AMOUNT-IN
                   MOVE WS-NEW-BALANCE TO 
                        WS-ACCT-CURR-BAL(WS-MATCHED-INDEX)
                   
      *            Check if over limit
                   IF WS-ACCT-CURR-BAL(WS-MATCHED-INDEX) > 
                      WS-ACCT-CREDIT-LIMIT(WS-MATCHED-INDEX)
                       SET ACCT-OVERLIMIT(WS-MATCHED-INDEX) TO TRUE
                   END-IF
                   
               WHEN WS-TXN-CREDIT
      *            Credit/Payment: subtract from balance
                   COMPUTE WS-NEW-BALANCE = 
                       WS-ACCT-CURR-BAL(WS-MATCHED-INDEX) 
                       - TXN-AMOUNT-IN
                   MOVE WS-NEW-BALANCE TO 
                        WS-ACCT-CURR-BAL(WS-MATCHED-INDEX)
                       
               WHEN OTHER
      *            Invalid transaction type - reject
                   MOVE WS-REASON-BADAMT TO WS-REJECT-REASON
                   PERFORM WRITE-REJECT
           END-EVALUATE.
       
      ******************************************************************
      * Write Rejected Transaction                                    *
      ******************************************************************
       WRITE-REJECT.
           MOVE TXN-CARD-NUM-IN TO REJ-CARD-NUM
           MOVE TXN-TYPE-IN TO REJ-TYPE
           MOVE TXN-AMOUNT-IN TO REJ-AMOUNT
           MOVE TXN-DESC-IN TO REJ-DESC
           MOVE TXN-DATE-IN TO REJ-DATE
           MOVE WS-REJECT-REASON TO REJ-REASON
           
           WRITE REJECT-REC-OUT
           
           IF WS-REJ-OUT-STATUS NOT = '00'
               DISPLAY 'ERROR WRITING REJECTS-OUT: ' 
                       WS-REJ-OUT-STATUS
           END-IF.
       
      ******************************************************************
      * Write Final Output Files                                      *
      ******************************************************************
       WRITE-FINAL-OUTPUTS.
           SET WS-ACCT-IDX TO 1
           
           PERFORM VARYING WS-ACCT-IDX FROM 1 BY 1
               UNTIL WS-ACCT-IDX > WS-ACCOUNT-COUNT
               
      *        Write updated account record
               MOVE WS-ACCT-CARD-NUM(WS-ACCT-IDX) TO 
                    ACCT-CARD-NUM-OUT
               MOVE WS-ACCT-NAME(WS-ACCT-IDX) TO 
                    ACCT-NAME-OUT
               MOVE WS-ACCT-CREDIT-LIMIT(WS-ACCT-IDX) TO 
                    ACCT-CREDIT-LIMIT-OUT
               MOVE WS-ACCT-CURR-BAL(WS-ACCT-IDX) TO 
                    ACCT-CURR-BAL-OUT
               MOVE WS-ACCT-STATUS(WS-ACCT-IDX) TO 
                    ACCT-STATUS-OUT
               
               WRITE ACCOUNT-REC-OUT
               
               IF WS-ACCT-OUT-STATUS NOT = '00'
                   DISPLAY 'ERROR WRITING ACCOUNTS-OUT: ' 
                           WS-ACCT-OUT-STATUS
               END-IF
               
      *        Write statement record
               MOVE WS-ACCT-CARD-NUM(WS-ACCT-IDX) TO STMT-CARD-NUM
               MOVE WS-ACCT-NAME(WS-ACCT-IDX) TO STMT-NAME
               MOVE WS-ACCT-CURR-BAL(WS-ACCT-IDX) TO STMT-BALANCE
               MOVE WS-ACCT-STATUS(WS-ACCT-IDX) TO STMT-STATUS
               
               IF ACCT-OVERLIMIT(WS-ACCT-IDX)
                   MOVE WS-OVERLIMIT-TEXT TO STMT-OVERLIMIT-FLAG
               ELSE
                   MOVE WS-NO-OVERLIMIT-TEXT TO STMT-OVERLIMIT-FLAG
               END-IF
               
               WRITE STATEMENT-REC-OUT
               
               IF WS-STMT-OUT-STATUS NOT = '00'
                   DISPLAY 'ERROR WRITING STATEMENTS-OUT: ' 
                           WS-STMT-OUT-STATUS
               END-IF
           END-PERFORM
           
           DISPLAY 'PROCESSING COMPLETE'.
       
      ******************************************************************
      * Close All Files                                               *
      ******************************************************************
       CLOSE-FILES.
           CLOSE ACCOUNTS-IN
                 TXNS-IN
                 ACCOUNTS-OUT
                 STATEMENTS-OUT
                 REJECTS-OUT.

