nop
in pa
in pb
db $0000FFFF
out pb
nop
mvi md0, $0
mvi md1, $C0
mvi a, $E0
out pb
mvi a, $0
mvi r$B, $0
mix r$B
out da
mvi a, $1
mov n, a
mvi r$1D, $0
tsbi c r$1D, $1
jmp $107
call $129
call $121
jmp $14
andis a, $7
jmp $19
jmp $10
mvi r$1B, $2
mvi r$19, $2
mvi r$3, $2
mvi r$5, $3
mvi r$F, $3
mvi r$11, $2
jmp $C4
adims r$0, $8
jmp $56
jmp $30
nop
adims r$0, $4
jmp $56
jmp $30
nop
adims r$0, $2
jmp $56
jmp $30
nop
tandi z (h), $1
jmp $50
adims r$0, $1
jmp $56
sbis r$6, $1
jmp $3C
adis r$C, $1
jmp $35
adi r$D, $1
tbl0 a, (r$C)
tsbi nz a, $FF
jmp $5A
mov r$6, a
adi r$2, $1
tbl0 a, (r$2)
mov n, a
sbis r$7, $1
jmp $42
adi r$4, $1
adi r$E, $1
tbl0 a, (r$E)
mov r$7, a
sbis r$8, $1
jmp $4C
adi r$18, $1
mvi r$1A, $BE
call $6D
jmp $49
jmp $136
adi r$10, $1
tbl0 a, (r$10)
mov r$8, a
mvi a, $0
tandi nz (h), $1
out da
reti
sbis r$A, $1
jmp $2E
mvi r$A, $A0
sb r$12, $1
mov a, r$12
mov n, a
tbl0 x, (r$0)
tbl0 y, (r$4)
call $61
reti
andi (h), $0
tsbi c r$1D, $1
sb r$1D, $1
mvi md0, $0
mvi a, $0
out da
reti
mvi a, $0
mul2
mul2
mul2
mul2
mul2
mov r$B, a
mvi a, $0
mix r$B
ral
out da
ret
tbl0 a, (r$18)
ral
ad r$1A, a
tbl0 a, (r$1A)
mov r$0, a
adi r$1A, $1
tbl0 a, (r$1A)
mov r$1, a
ret
tandi z md, $16
jmp $76
tandi z (h), $80
jmp $14
jmp $11
nop
nop
nop
nop
jmp $0
call $121
jmp $83
jmp $8F
mov r$1F, a
mvi r$1E, $F
sbis r$1E, $1
jmp $85
call $121
jmp $8A
jmp $8F
tsb z a, r$1F
jmp $80
ori (h), $80
mvi r$1D, $0
jmp $5D
tandi nz md, $4
reti
sbis r$6, $1
jmp $AB
sb r$13, $1
mov a, r$13
tandi z a, $3F
jmp $A1
adi r$C, $1
tbl0 a, (r$C)
tsbi nz a, $FF
jmp $5A
mov r$6, a
mov r$15, a
adi r$2, $1
tbl0 a, (r$2)
mov r$13, a
jmp $AB
mov a, r$13
tandi z a, $40
jmp $A9
tandi z a, $80
jmp $A8
adi r$12, $1
jmp $A9
sb r$12, $1
mov a, r$15
mov r$6, a
sbis r$7, $1
reti
sb r$A, $1
mov a, r$A
tandi z a, $1F
jmp $B9
adi r$E, $1
tbl0 a, (r$E)
mov r$7, a
mov r$16, a
adi r$4, $1
tbl0 a, (r$4)
mov r$A, a
reti
mov a, r$A
tandi z a, $40
jmp $C1
tandi z a, $80
jmp $C0
adi r$9, $1
jmp $C1
sb r$9, $1
mov a, r$16
mov r$7, a
reti
mvi r$1C, $C8
ad a, r$1C
mvi h, $3F
andi (h), $0
jmpa
jmp $D0
jmp $DA
jmp $EB
jmp $F3
jmp $FB
jmp $105
jmp $109
mvi r$18, $D2
mvi r$2, $DE
mvi r$4, $18
mvi r$C, $3C
mvi r$D, $3
mvi r$E, $60
mvi r$10, $C6
call $111
mvi md0, $12
jmp $76
mvi r$18, $D4
mvi r$2, $E0
mvi r$4, $24
mvi r$C, $40
mvi r$D, $3
mvi r$E, $6C
mvi r$10, $C8
mvi r$14, $0
call $111
adi r$2, $1
tbl0 a, (r$2)
mov r$13, a
adi r$4, $1
tbl0 a, (r$4)
mov r$A, a
mvi md0, $74
jmp $76
mvi r$18, $D6
mvi r$2, $E8
mvi r$4, $2C
mvi r$C, $48
mvi r$D, $3
mvi r$E, $70
mvi r$10, $CA
jmp $E1
mvi r$18, $D8
mvi r$2, $F2
mvi r$4, $32
mvi r$C, $52
mvi r$D, $3
mvi r$E, $76
mvi r$10, $CC
jmp $E1
mvi r$18, $DA
mvi r$2, $FC
mvi r$4, $38
mvi r$C, $5C
mvi r$D, $3
mvi r$E, $7C
mvi r$10, $CE
mvi r$A, $A0
ori (h), $1
jmp $D7
mvi r$1D, $3
jmp $FB
call $150
jmp $FB
mvi r$18, $DC
mvi r$2, $FE
mvi r$4, $3A
mvi r$C, $5E
mvi r$D, $3
mvi r$E, $7E
mvi r$10, $D0
jmp $E1
mvi r$1A, $BE
call $6D
tbl0 a, (r$C)
mov r$6, a
mov r$15, a
tbl0 a, (r$4)
mov r$9, a
tbl0 a, (r$E)
mov r$7, a
mov r$16, a
tbl0 a, (r$10)
mov r$8, a
tbl0 a, (r$2)
mov n, a
mov r$12, a
ret
mvi a, $40
out pb
mvi a, $E0
out pb
in pa
tandi z a, $8
rets
ret
call $121
jmp $12C
jmp $129
mov r$1F, a
mvi r$1E, $FF
sbis r$1E, $1
jmp $12E
call $121
jmp $133
jmp $129
tsb z a, r$1F
jmp $129
ret
tandi nz md, $16
reti
adims r$0, $1
jmp $142
mvi r$1F, $1F
mov y, r$1F
mov x, rg
mov a, r$14
mul2
mov r$14, a
andi a, $1F
ad r$0, a
tbl0 x, (r$0)
mov y, r$9
call $61
mov a, r$12
sbis a, $1
jmp $146
mov a, r$12
sbis a, $1
jmp $149
reti
nop
nop
nop
jmp $0
mvi md0, $10
mvi r$17, $3
mvi r$13, $FF
mvi r$14, $FF
sbis r$14, $1
jmp $154
sbis r$13, $1
jmp $153
sbis r$17, $1
jmp $152
mvi md0, $0
ret
nop
nop
jmp $0
db $00000380
db $000003A0
db $000003C0
db $000003E0
call $3E6
db $000000FF
db $000000FF
db $000000FF
db $0000007D
db $000000FF
nop
db $00000202
mon
nop
db $00000001
mon
mvi r$4, $44
tsbi z h, $BF
tsbi z h, $BF
db $00003F7F
db $0000003F
mvi r$F, $1F
sbi a, $99
db $00000304
db $00000044
nop
mvi r$1F, $5
ori md, $7
db $0000035F
out pa
nop
db $00000062
mvi r$1F, $BF
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
jmp $0
db $0000001F
db $0000020F
db $00000806
db $00000403
db $00000205
nop
mvi r$1F, $1F
tsbi nc md, $5F
andis md, $5F
nop
mvi r$1F, $1F
tsbi z md, $5F
nop
mvi r$1F, $1F
xori a, $95
nop
db $0000001F
mvi r$1F, $1F
call $3E6
db $000000FF
db $00000001
out da
jmpa
db $000000FF
db $00000109
db $00001504
db $0000FE8F
db $000000FF
nop
db $00000206
db $00000701
xori h, $D
db $000000FF
nop
db $0000FF7D
db $0000FF0C
db $00001F0D
db $00001D0D
db $00000E2B
db $00001D1D
mvi r$16, $1D
db $0000001D
db $00000116
db $0000000C
mov a, r$0
mov y, r$2
nop
db $0000080C
db $0000001F
nop
db $0000007D
db $0000000C
call $C00
tadi nc r$13, $0
mvi r$6, $D9
tadi c a, $75
tadi c a, $FF
mvi r$6, $75
tadi nc r$1D, $9
call $C30
db $0000FC00
jmp $9B0
or (h), a
db $000018F5
db $0000187E
or <U/D ADDR MODE> - OP $C6F5
jmp $959
db $0000FCB0
jmp $100
mvi r$1D, $3F
mvi h, $55
mvi r$1D, $77
tsb c a, r$10
db $0000FF92
adims r$1C, $E
tsb c <U/D ADDR MODE> - OP $DDD2
jmp $100
mvi r$1D, $3F
mvi h, $55
mvi r$1D, $77
tsb c a, r$10
db $0000FF92
adims r$1C, $E
tsb c <U/D ADDR MODE> - OP $DDD2
call $CD4
adis a, $FC
tad nc a, (h)
tbl1 a, (r$13)
jmp $CE1
db $000036FF
db $000016BB
adi5 r$13, $9
jmp $C00
xori a, $D6
adi5 r$14, $E
tadi nc a, $64
call $7AE
db $000003DC
db $0000F461
db $00002E13
db $00001700
db $00002C26
db $00003B32
mvi r$1B, $49
call $F76
jmp $776
db $00003B4F
db $0000262C
sbi md, $B
tsbi nc h, $97
tad c a, r$C
sb r$1E, $4
adi r$1E, $7
tand z <U/D ADDR MODE> - OP $DBDB
tandi z h, $D2
andis md, $9D