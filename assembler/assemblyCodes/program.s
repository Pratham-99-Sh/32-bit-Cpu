MAIN:     SUB R0, R15, R15
          ADD R2, R0, #5
          ADD R3, R0, #12
          SUB R7, R3, #9
          ORR R4, R7, R2
          AND R5, R3, R4
          ADD R5, R5, R4
          SUBS R8, R5, R7
          BEQ END
          SUBS R8, R3, R4
          BGE AROUND
          ADD R5, R0, #0
AROUND:   SUBS R8, R7, R2
          ADDLT R7, R5, #1
          SUB R7, R7, R2
          STR R7, [R3, #84]
          LDR R2, [R0, #96]
          ADD R15, R15, R0
          ADD R2, R0, #14
          B END
          ADD R2, R0, #13
          ADD R2, R0, #10
END:      STR R2, [R0, #84]