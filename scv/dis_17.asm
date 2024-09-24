in pa
in pb
db $0000FFFF
out pb
nop
mvi a, $0
out pb
out pa
call $ED
in pa
mov r$1D, a
nop
nop
in pa
tsb z a, r$1D
jmp $A
tsbi c a, $20
jmp $A
tsbi nc r$12, $1
jmp $17
tsb z a, r$12
call $ED
in pa
mov r$12, a
tsbi c a, $4
jmp $CD
tsbi c a, $2
jmp $DD
tsbi c a, $1
jmp $E3
jmp $A
mov a, r$1F
mix r$1E
out da
jmp $49
adi r$18, $1
call $132
adi r$18, $2
jmp $2F
call $132
adi r$18, $1
mov a, r$16
jmp $31
tsbi c r$12, $4
jmp $7D
jmp $36
mov a, r$16
ral
tsbi nz a, $9F
mvi a, $A0
andi a, $1E
sbis a, $2
jmp $34
call $132
adims r$18, $1
jmp $3D
tsbi z h, $3C
jmp $40
call $117
jmp $47
mov a, r$18
tandi z a, $3
jmp $47
mov a, r$16
adis a, $80
jmp $47
adi r$17, $F
adims r$17, $1
adis a, $1
mov n, a
adi r$D, $1
reti
sbis r$B, $1
jmp $51
mov a, r$A
mov r$B, a
mov a, r$4
tsbi c r$1A, $1
mvi a, $0
mov r$1A, a
sbis r$9, $1
jmp $59
mov a, r$8
mov r$9, a
mov a, r$2
tsbi c r$1B, $1
mvi a, $0
mov r$1B, a
sbis r$7, $1
jmp $61
mov a, r$6
mov r$7, a
mov a, r$0
tsbi c r$1C, $1
mvi a, $0
mov r$1C, a
mov a, r$1A
ad a, r$1B
ad a, r$1C
mov r$1F, a
sbis r$F, $1
jmp $70
mov a, r$E
mov r$F, a
adims r$10, $1
jmp $70
mov x, rg
mov y, r$11
mul2
andi a, $1F
ad r$10, a
tbl0 x, (r$14)
tsbi c r$C, $1
tbl0 x, (r$10)
mov y, r$C
mvi a, $0
mul2
mul2
mul2
mul2
mul2
mov r$1E, a
adi r$D, $1
reti
mvi a, $0
out pb
sb r$1, $1
mvi h, $1
mov a, r$A
tandi nz (h), $1
jmp $C9
andi a, $F0
rar
rar
rar
rar
mvi r$18, $A
ad r$18, a
mov r$9, a
tbl0 a, (r$18)
ad r$8, a
tadi nc r$8, $1
mvi r$8, $0
tsbi c r$8, $8
mvi r$8, $7
mov a, r$8
ral
ral
ral
ral
ad a, r$9
mov r$10, a
tbl0 a, (r$10)
ad a, r$B
mov r$B, a
mvi h, $B
tandi z (h), $80
xori a, $FF
tandi z (h), $80
adi a, $1
tbl0 x, (r$16)
tandi z (h), $80
tbl0 x, (r$14)
mov x, a
mov y, r$12
call $134
tadi nc r$1, $1
jmp $B7
mvi h, $1
tandi z (h), $1
reti
tsbi c r$4, $1
jmp $B3
in pa
mov r$A, a
mvi a, $1
out pb
reti
tsbi nc r$1, $1
tsbi c r$D, $1
reti
jmp $B0
mov a, r$0
mov r$1, a
in pa
tsbi c a, $1
jmp $BE
mvi r$4, $0
jmp $B0
tadi nc a, $2
jmp $C6
sbis r$D, $1
reti
mov r$D, a
mvi r$A, $88
mvi r$4, $1
reti
mvi r$6, $1
mvi md0, $0
reti
andi a, $F
ral
nop
jmp $88
mvi h, $2
call $121
sb r$0, $1
mvi a, $1
out pb
tbl0 a, (r$2)
mvi r$A, $88
mvi r$8, $7
mov n, a
mvi md0, $2
tsbi nc r$6, $1
jmp $D7
call $ED
mvi h, $0
call $121
jmp $A
mvi h, $4
call $121
call $110
tsbi nc r$5, $1
call $117
jmp $E7
mvi h, $10
call $121
mvi a, $8
mov n, a
mvi r$5, $1
mvi md0, $2
mov a, r$12
ori a, $80
out pa
jmp $A
mvi md0, $0
mvi a, $0
mvi r$1F, $0
mix r$1F
out da
mvi a, $1
mov n, a
mvi h, $1F
mvi a, $0
mov (h), a
sbis h, $1
jmp $F6
mvi r$11, $3
mvi r$19, $2
mvi r$3, $2
mvi r$14, $6
ret
nop
nop
nop
db $0000FAFA
tsbi nz a, $BC
jmp $B7D
mvi r$13, $5E
db $0000FFFF
db $000000FF
nop
mon
mon
nop
db $0000FF00
db $0000FFFF
nop
nop
nop
mov a, r$2
tsbi nc a, $20
mvi a, $20
rar
mov r$2, a
mvi h, $3C
ret
mov a, r$0
mov r$14, a
mov a, r$4
mov r$18, a
mov a, r$2
mov r$16, a
mvi r$17, $0
andi a, $7F
mov n, a
ret
mvi a, $1
out pb
mvi r$D, $0
tsbi nc r$5, $1
jmp $12F
tsbi nc r$D, $2
jmp $126
mvi a, $0
out pb
in pa
mov (h), a
sbis h, $2
jmp $121
ret
adis r$D, $4
jmp $12F
jmp $128
tbl0 x, (r$18)
mov y, r$14
mvi a, $0
mul2
mul2
mul2
mul2
mul2
ral
mov r$1F, a
mvi a, $0
mix r$1F
out da
ret
tsb z <U/D ADDR MODE> - OP $DFB3
db $0000FFF5
ads <U/D ADDR MODE> - OP $C9EE
sbi a, $A4
db $00003E1F
call $59
call $D7F
mvi r$1D, $73
db $00001739
xori md, $0
db $00000F87
db $00003625
mvi r$6, $41
db $0000363E
db $00001F2B
db $00000013
db $0000FFD0
db $00000DBC
mvi r$1D, $41
db $00002F7F
db $00002C29
db $00003734
db $00003A38
db $0000223A
mvi r$4, $0
mvi r$8, $4C
jmp $C3D
db $00001D37
db $00002720
mvi md1, $2B
db $00003332
db $00000033
sbis (h), $94
tsb nz <U/D ADDR MODE> - OP $D7C2
adi5 r$1E, $8
db $0000FFF9
adims r$1F, $A
tsb nz <U/D ADDR MODE> - OP $D6E6
tsbi nc (h), $C5
adis a, $9B
db $00002E16
mvi r$16, $43
call $266
call $D7B
call $57F
mvi r$1B, $68
db $00003348
db $0000001C
db $0000F5CD
sb r$1F, $F
andi a, $B5
mvi r$1, $28
mvi r$18, $54
mvi r$10, $54
mvi r$18, $52
jmp $75E
call $76E
call $D7A
call $A7A
call $B79
call $E7D
call $F7F
call $67D
db $00000052
tadi c (h), $95
tand z <U/D ADDR MODE> - OP $DACC
tsbi c r$E, $5
db $0000FDF6
db $00000A03
tbl1 x, (r$11)
mvi a, $26
jmp $B48
xor <U/D ADDR MODE> - OP $CEB6
sbis r$D, $C
db $0000F4EE
db $0000FEF9
db $00000702
db $0000120C
db $0000241A
mvi r$A, $32
tsb c <U/D ADDR MODE> - OP $DCCB
tsbi nc r$1E, $6
db $0000F7F3
db $0000FFFB
jmpa
db $00000D09
db $00001A13
db $00003524
sbis r$1D, $B
adims r$1E, $E
db $0000FAF7
db $0000FFFD
db $00000301
db $00000906
db $0000120D
db $00002519
tsbi c r$E, $6
db $0000F7F3
db $0000FCFA
db $000000FE
db $00000200
off
db $00000D09
tbl1 x, (r$1)
adims r$E, $B
tadi5 r$1F, $6
db $0000FDFB
db $000000FE
db $00000200
db $00000503
db $00000A07
db $0000150E
db $0000F6F0
db $0000FBF9
db $0000FEFC
db $000000FF
db $00000100
in pb
db $00000705
mov h, r$0
tadi5 r$1F, $6
db $0000FDFB
db $0000FFFE
nop
nop
mov n, a
db $00000503
db $00000A07
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
call $F80
db $0000FF80
call $F80
db $0000FF80
call $F80
db $0000FF80
call $F80
db $0000FF80
call $F80
db $0000FF80
call $F80
db $0000FF80
call $F80
db $0000FF80
call $F80
db $0000FF80
db $000035B8
jmp $57F
tadi c h, $F
tsbi nz a, $C6
ad <U/D ADDR MODE> - OP $C093
mvi r$15, $91
adis md, $58
ands <U/D ADDR MODE> - OP $CADE
jmp $217
adis (h), $3C
or <U/D ADDR MODE> - OP $C7E6
db $00003E0F
db $00001A27
tadi nc (h), $6
db $000039A2
tsbi c md, $41
call $244
mvi r$17, $79
andi h, $18
tsb c <U/D ADDR MODE> - OP $DCCD
andi h, $C0
mvi r$17, $18
call $279
adi a, $44
tsb nc <U/D ADDR MODE> - OP $D583
ad r$1D, a
db $00002F92
call $C67
db $00002F67
ad <U/D ADDR MODE> - OP $C192
db $000005DB
db $000000B3
nop
