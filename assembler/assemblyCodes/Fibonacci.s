        ; compute Fib(10) in R1
                SUB   R0, R15, R15      ; R0 = 0
                ADD   R1, R0, #1        ; R1 = 1
                ADD   R2, R0, #9       ; R2 = loop count = 10 (9-0)
fib_loop:       ADD   R3, R0, R1        ; R3 = R0 + R1
                ADD   R0, R1, #0        ; R0 ← old R1
                ADD   R1, R3, #0        ; R1 ← new fib
                SUBS  R2, R2, #1        ; decrement, set Z
                BNE   fib_loop          ; repeat while R2≠0
        ; result Fib(10)=R1=55