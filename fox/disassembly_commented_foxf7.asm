
; WARNING THIS DISASSEMBLY IS A

; WW      WW  IIIIII  PPPPPP
; WW      WW    II    PP    PP
; WW  WW  WW    II    PPPPPP
; WWWW  WWWW    II    PP
; WW      WW  IIIIII  PP

; things may change depending on what is later figured out
; i just need a little break from this firm disasm

; this firmware is reponsible solely for SFX generation and connects to the larger piezoelectric speaker
; all the melody beeps comes from the main 7500 microcontroller that runs the gameplay and controls the VFD screen

; so far it got 7 commands and they all must be preceded by a prefix of any so long as bit 3 is clear ($00)
; followed by the command number of 1~7 with bit 3 being set, a command of 0 (8) will result in going back to the wait loop

; $-0 $-9 - tone  - PING
; $-0 $-A - noise - 
; $-0 $-B - noise - 
; $-0 $-C - noise - 
; $-0 $-D - tone  - SIREN
; $-0 $-E - tone  - SIREN 3X
; $-0 $-F - noise - 


; /////////////////// TONE-TYPE //////////////////

; NOTING THAT TBL0 INSTRUCTION IS LAGGING BY 1 WORD ALWAYS

; -> (1) PING
; FREQ - 44 44 BF BF
; FLEN - 73 E6 00 FF - 159
; VOLU - 00 1F 02 0F 08 06 04 03 02 05 00 00
; VLEN - 1F 0D 1D 0D 0E 2B 1D 1D 56 1D 00 1D

; -> (5) SIREN
; FREQ - 00 62 5F ; what??? N Timer 0? that should set no TONE vectors
; FLEN - FF 7D FF
; VOLU - 00 1F 5F
; VLEN - 00 7D 00

; -> (6) SIREN 3X
; same as SIREN, but replays twice after a long wait period

;  ///////////////// NOISE-TYPE //////////////////

; -> () RUMBLE

; -> () FLYBY

; -> () SHOOT

; -> () EXPLODE

; NOISE type sounds operate their macro updates inside NOISE and TIME interrupt vectors
; TONE type sounds operate their macro updates inside TONEx and 


START:
		in pa
		in pb
		db $FFFF
		out pb
		nop
		mvi md0, $0   ; interrupts off, ADIMS is 5
		mvi md1, $C0  ; EXT and TIME interrupts enabled
		mvi a, $E0
		out pb       ; reset Port B
		mvi a, $0
		mvi r$B, $0
		mix r$B      ; reset DAC
		out da
		mvi a, $1    ; sets N timer in a range no TONE interrupts trigger
		mov n, a

Retry_Command:
		mvi r$1D, $0 ; enters main loop directly into the prefix wait sub
Command_Loop:
	tsbi c r$1D, $1 ; if r1D is not 0 then go back to CMD 5 after a 40K+ cycles wait
	jmp Wait_A_Ton_And_Goto_Command_5
	call SUB_Wait_For_Valid_Cmd ; will only exit if you send $1F

get_byte:
	call SUB_Receive_Byte ; bit 3 must be set
	jmp get_byte
	andis a, $7       ; %00000xxx - total of 7 commands?
	jmp Init_Pointers
	jmp Retry_Command ; Command_0 is invalid and will retry immediately

Init_Pointers:
		mvi r$1B, $2
		mvi r$19, $2
		mvi r$3, $2
		mvi r$5, $3
		mvi r$F, $3
		mvi r$11, $2
	jmp Weird_Jumptable



;   ////////////////////////////////////////////////////////////
;  ///                  INTERRUPT VECTORS                   ///
; ////////////////////////////////////////////////////////////

iorg $20
IRQ_TONE_4
	adims r$0, $8
	jmp Calculate_Volume_Exit
	jmp Wave_Pointer_Overflow

iorg $24
IRQ_TONE_3:
	adims r$0, $4
	jmp Calculate_Volume_Exit
	jmp Wave_Pointer_Overflow

iorg $28
IRQ_TONE_2:
	adims r$0, $2
	jmp Calculate_Volume_Exit
	jmp Wave_Pointer_Overflow

iorg $2C
IRQ_TONE_1: ; jesus christ what is this thing doing
	tandi z (h), $1 ; checks flag 0, if set go somewhere
	jmp Count_And_Raise_Frequency

Step_Wave_Pointer:
	adims r$0, $1 ; steps waveform
	jmp Calculate_Volume_Exit
Wave_Pointer_Overflow:

	sbis r$6, $1 ; frequency update routine /////////////////
	jmp .skip_freq_update

	adis r$C, $1 ; increment pC (both bytes if ovrflw)
	jmp .no_carry
		adi r$D, $1
.no_carry:

		tbl0 a, (r$C) ; frequency update wait period, stops sound if $FF
	tsbi nz a, $FF
	jmp Stop_Reset_Sound
		mov r$6, a
		adi r$2, $1
		tbl0 a, (r$2)
		mov n, a
.skip_freq_update:

	sbis r$7, $1 ; volume update routine ///////////////////
	jmp .skip_volume_update
		adi r$4, $1 ; volume parameter table
		adi r$E, $1 ; volume wait table
		tbl0 a, (r$E)
		mov r$7, a
.skip_volume_update:

	sbis r$8, $1
	jmp .skip_wave_reload
		adi r$18, $1
		mvi r$1A, $BE
	call SUB_Set_Noise_Pointer
	jmp Continue_Tone_X_Handler

; ///////////////////////////////////////
iorg $48
NOISE_IRQ:
	jmp noise_irq_handler
; ///////////////////////////////////////

Continue_Tone_X_Handler:
		adi r$10, $1
		tbl0 a, (r$10)
		mov r$8, a
.skip_wave_reload:

		mvi a, $0
	tandi nz (h), $1 ; checks flag 0, if it is 0 then DAC is cleared
		out da
	reti

Count_And_Raise_Frequency:
	sbis r$A, $1
	jmp Step_Wave_Pointer
		mvi r$A, $A0
		sbi r$12, $1
		mov a, r$12
		mov n, a

Calculate_Volume_Exit:
		tbl0 x, (r$0)
		tbl0 y, (r$4)
	call SUB_Scale_And_Output_Sample
	reti

; ///////////////////////////////////////

Stop_Reset_Sound:
		andi (h), $0 ; clears flag
	tsbi c r$1D, $1  ; subtract r1D to 0 unless it's already 0
		sb r$1D, $1
Stop_Sound:
		mvi md0, $0 ; shut up interrupts and other flags
		mvi a, $0   ; reset DAC
		out da
	reti

; ///////////////////////////////////////

SUB_Scale_And_Output_Sample:
		mvi a, $0
		mul2       ; full step volume multiply
		mul2
		mul2
		mul2
		mul2
EXT_IRQ:
		mov r$B, a ; current sample
		mvi a, $0
		mix r$B
		ral
		out da
	ret



SUB_Set_Noise_Pointer: ; local $6D
; peforms some weird lookup
; both p18 and p1A point to $01FE~$02FD

; okay so i know that r18 is always going to lookup 0, 1 or 2 when entering here

		tbl0 a, (r$18)
		ral             ; amplifies to make it word-aligned
		ad r$1A, a
		tbl0 a, (r$1A)  ; both call instances set r1A to $BE
		mov r$0, a      ; regardless of the addition, this always results in a lookup of $03 (tones come from $02FE)
		adi r$1A, $1
		tbl0 a, (r$1A) ; now it's either 80, A0, C0 and E0, sounds like a waveform selector to me
		; mr japanese guy who wrote this FW, what is this????? why all these lookups?????
		; unless that's some reason tied to the fact that this is driven by a 4-bit potato starchy little thing
		mov r$1, a ; p0 is the noise waveform pointer
	ret


; /////////////////////////////////////////////////////////////////////////

Lock_Loop: ; lock here untill the interrupts are all disabled
	tandi z md0, $16
	jmp Lock_Loop

	tandi z (h), $80 ; if flag 1 is out, the MCU is probably idle and will now wait for a new command
	jmp get_byte
	jmp Command_Loop

; /////////////////////////////////////////////////////////////////////////

iorg $79
	jmp START

iorg $80
TIME_IRQ: ; ~ 1KHz
	call SUB_Receive_Byte
	jmp .check_again
	jmp .run_sequences ; if b3 set (should be)

.check_again:
		mov r$1F, a
		mvi r$1E, $F
.wait_loop:
	sbis r$1E, $1
	jmp .wait_loop

	call SUB_Receive_Byte
	jmp .stabl_check
	jmp .run_sequences

.stabl_check:
	tsb z a, r$1F ; stability check
	jmp TIME_IRQ  ; if fail (port data changed between here and previous), go back to $80 or else stop sound

		ori (h), $80 ; sets flag 1
		mvi r$1D, $0 ; avoid going back into command 5
	jmp Stop_Sound  ; if it detects a byte of 0, current sound is stopped and the 1771 will listen to the next command


; update all automations from noise-type sounds
; count-set a literal value or ramp up/down for both frequency and volume params
.run_sequences:
	tandi nz md0, $4 ; check if NOISE interrupt is on, or else exit
	reti

	sbis r$6, $1 ; frequency updates
	jmp .freq_skip_updates
		sb r$13, $1
		mov a, r$13
	tandi z a, $3F
	jmp .ramp_freq
		adi r$C, $1
		tbl0 a, (r$C)
	tsbi nz a, $FF
	jmp Stop_Reset_Sound
		mov r$6, a
		mov r$15, a
		adi r$2, $1
		tbl0 a, (r$2)
		mov r$13, a
	jmp .freq_skip_updates

.ramp_freq:
		mov a, r$13
	tandi z a, $40
	jmp .freq_done
	tandi z a, $80
	jmp .raise_n_freq
		; else lower n freq
		adi r$12, $1
	jmp .freq_done

.raise_n_freq:
		sbi r$12, $1
.freq_done:
		mov a, r$15
		mov r$6, a
.freq_skip_updates:


	sbis r$7, $1 ; volume updates
	reti
		sb r$A, $1
		mov a, r$A
	tandi z a, $1F
	jmp .ramp_volume
		adi r$E, $1
		tbl0 a, (r$E) ; volume wait table
		mov r$7, a
		mov r$16, a
		adi r$4, $1
		tbl0 a, (r$4) ; volume level table
		mov r$A, a
	reti

.ramp_volume:
		mov a, r$A
	tandi z a, $40 ; bit 6 of rA counter
	jmp .volume_done
	tandi z a, $80 ; bit 7
	jmp .lower_volume
		; else raise volume
		adi r$9, $1
	jmp .volume_done

.lower_volume:
		sbi r$9, $1
.volume_done:
		mov a, r$16
		mov r$7, a
	reti

; /////////////////////////////////////////////////////////////////////////

Weird_Jumptable:
		mvi r$1C, $C8
		ad a, r$1C
		mvi h, $3F    ; H reg is basically this for the entire program, and serves as a flag of sorts
		andi (h), $0  ; clear it to 0
	jmpa
	jmp Command_1 ; tone
	jmp Command_2 ; noise
	jmp Command_3 ; noise
	jmp Command_4 ; noise
	jmp Command_5 ; tone
	jmp Command_6 ; tone
	jmp Command_7 ; noise



Command_1:
		mvi r$18, $D2 ; wav = 0 (ping)
		mvi r$2, $DE  ; frq = 
		mvi r$4, $18  ; vol = 00 1F 02 0F 08 06 04 03 02 05
		mvi r$C, $3C
		mvi r$D, $3
		mvi r$E, $60  ; vtm = 1F 0D 1D 0D 0E 2B 1D 1D 56 1D
		mvi r$10, $C6
Prepare_Tone:
	call SUB_Prepare_Registers_And_Vars
		mvi md0, %00010010 ; NSF2 and Tone interrupts on
	jmp Lock_Loop



Command_2:
		mvi r$18, $D4 ; wav = 2 (buzz)
		mvi r$2, $E0  ; frq = 
		mvi r$4, $24  ; vol = 
		mvi r$C, $40
		mvi r$D, $3
		mvi r$E, $6C
		mvi r$10, $C8
Prepare_Noise:
		mvi r$14, $0
	call SUB_Prepare_Registers_And_Vars
		adi r$2, $1
		tbl0 a, (r$2)
		mov r$13, a
		adi r$4, $1
		tbl0 a, (r$4)
		mov r$A, a
		mvi md0, %01110100 ; IF, OUT, NSF2 and Noise interrupt on (NOT TONE THOUGH)
	jmp Lock_Loop



Command_3:
		mvi r$18, $D6 ; wav = 1 (square)
		mvi r$2, $E8  ; frq = 
		mvi r$4, $2C  ; vol = 
		mvi r$C, $48
		mvi r$D, $3
		mvi r$E, $70
		mvi r$10, $CA
	jmp Prepare_Noise



Command_4:
		mvi r$18, $D8 ; wav = 0 (ping)
		mvi r$2, $F2  ; frq = 
		mvi r$4, $32  ; vol = 
		mvi r$C, $52
		mvi r$D, $3
		mvi r$E, $76
		mvi r$10, $CC
	jmp Prepare_Noise



Command_5:
		mvi r$18, $DA  ; wav = 0 (ping)
		mvi r$2, $FC   ; frq = 
		mvi r$4, $38   ; vol = 
		mvi r$C, $5C
		mvi r$D, $3
		mvi r$E, $7C
		mvi r$10, $CE
		mvi r$A, $A0
		ori (h), $1 ; sets flag 0
	jmp Prepare_Tone



Command_6:
		mvi r$1D, $3
	jmp Command_5


Wait_A_Ton_And_Goto_Command_5:
	call SUB_Very_Long_Wait_Loop
	jmp Command_5


Command_7:
		mvi r$18, $DC ; wav = 1 (square)
		mvi r$2, $FE  ; frq = 
		mvi r$4, $3A  ; vol = 
		mvi r$C, $5E
		mvi r$D, $3 ; one of the tables start here (MSB 2)
		mvi r$E, $7E
		mvi r$10, $D0
	jmp Prepare_Noise

; /////////////////////////////////////////////////////////////////////////

SUB_Prepare_Registers_And_Vars:
		mvi r$1A, $BE
	call SUB_Set_Noise_Pointer
		tbl0 a, (r$C) ; MSB 3 - 3C 40 48 52 5C 5E
		mov r$6, a
		mov r$15, a
		tbl0 a, (r$4) ; MSB 3 - 18 24 2C 32 38 3A
		mov r$9, a
		tbl0 a, (r$E) ; MSB 3 - 60 6C 70 76 7C 7E - 1F 01 10 08 00 00
		mov r$7, a
		mov r$16, a
		tbl0 a, (r$10) ; MSB 2 - C6 C8 CA CE CC D0 - 73 00 00 00 00 00
		mov r$8, a
		tbl0 a, (r$2) ; MSB 2 - DE E0 E8 F2 FC FE - 44 BF 4F BF 00 5F
		mov n, a
		mov r$12, a ; r12 does something with N timer, autosweep?
	ret



SUB_Receive_Byte:
		mvi a, $40 ; fire a signal at the main CPU
		out pb
		mvi a, $E0
		out pb
		in pa      ; get whichever was last latched on PA
	tandi z a, %00001000  ; cause a skip if bit 3 is set
	rets
	ret



SUB_Wait_For_Valid_Cmd:
.retry_getbyte:
	call SUB_Receive_Byte
	jmp .value_is_good ; bit 3 must be clear
	jmp .retry_getbyte

.value_is_good:
	mov r$1F, a
	mvi r$1E, $FF

.wait_loop:
	sbis r$1E, $1
	jmp .wait_loop

	call SUB_Receive_Byte
	jmp .check_val ; bit 3 must be clear
	jmp .retry_getbyte

.check_val:
	tsb z a, r$1F ; both received bytes must match (stability check)
	jmp .retry_getbyte
	ret

; /////////////////////////////////////////////////////////////////////////

noise_irq_handler:
	tandi nz md0, %00010110 ; if all NSF2, Noise and Tone are disabled, return immediately
	; even though no TONE-type sound enables noise interrupt? it enables NSF2 which i'm not sure what it does (NS IRQ prescalar?)
	reti
	
	; all this routine appears to do is update the main waveform pointer and randomize its initial phase using RG/PNC register
	adims r$0, $1 ; step main wave pointer
	jmp .noise_wave_no_wrap
	; same procedure as SCV noise but Y is not $3, it's $1F instead: Start Address = ((31 + RG >> 1) & 0b00011111)
		mvi r$1F, $1F
		mov y, r$1F
		mov x, rg
		mov a, r$14
		mul2
		mov r$14, a
		andi a, $1F
		ad r$0, a
.noise_wave_no_wrap:
		tbl0 x, (r$0) ; take current waveform position sample
		mov y, r$9    ; volume level
	call SUB_Scale_And_Output_Sample

		mov a, r$12 ; wait for X cycles stored at r12
.waitloop:
	sbis a, $1
	jmp .waitloop
		mov a, r$12 ; twice
.waitloop2:
	sbis a, $1
	jmp .waitloop2
	reti



; /////////////////////////////////////////////////////////////////////////

iorg $14F
	jmp START

iorg $150
SUB_Very_Long_Wait_Loop:
; appears to wait $40000 iterations of a loop, or roughly $80310 mcycles

		mvi md0, $10 ; enable NSF2 bit
		mvi r$17, $3
.outter:
		mvi r$13, $FF
.middle:
		mvi r$14, $FF
.inner:
	sbis r$14, $1
	jmp .inner
	sbis r$13, $1
	jmp .middle
	sbis r$17, $1
	jmp .outter
		mvi md0, $0 ; disable everything
	ret



;   ////////////////////////////////////////////////////////////
;  ///                    ROM DATA AREA                     ///
; ////////////////////////////////////////////////////////////

iorg $15D
jmp START

db $03, $80
db $03, $A0, $03, $C0, $03, $E0, $73, $E6, $00, $FF, $00, $FF, $00, $FF, $00, $7D
db $00, $FF, $00, $00, $02, $02, $01, $01, $00, $00, $00, $01, $01, $01, $44, $44
db $BF, $BF, $BF, $BF, $3F, $7F, $00, $3F, $4F, $1F, $84, $99, $03, $04, $00, $44
db $00, $00, $5F, $05, $87, $07, $03, $5F, $00, $02, $00, $00, $00, $62, $5F, $BF

org $2FE
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
db $00, $00, $00, $00, $00, $00, $60, $00, $00, $1F, $02, $0F, $08, $06, $04, $03
db $02, $05, $00, $00, $5F, $1F, $95, $5F, $8B, $5F, $00, $00, $5F, $1F, $9F, $5F
db $00, $00, $5F, $1F, $8E, $95, $00, $00, $00, $1F, $5F, $1F, $73, $E6, $00, $FF
db $00, $01, $05, $02, $05, $01, $00, $FF, $01, $09, $15, $04, $FE, $8F, $00, $FF
db $00, $00, $02, $06, $07, $01, $AF, $0D, $00, $FF, $00, $00, $FF, $7D, $FF, $0C
db $1F, $0D, $1D, $0D, $0E, $2B, $1D, $1D, $56, $1D, $00, $1D, $01, $16, $00, $0C
db $10, $05, $10, $20, $00, $00, $08, $0C, $00, $1F, $00, $00, $00, $7D, $00, $0C

org $37E ; waveform data
db $7C, $00, $E9, $30, $46, $D9, $98, $75, $98, $FF, $46, $75, $E9, $D9, $7C, $30, $FC, $00, $69, $B0, $C6, $59, $18, $F5, $18, $7E, $C6, $F5, $69, $59, $FC, $B0 ; xilophone
db $61, $00, $5D, $3F, $38, $55, $5D, $77, $DD, $00, $FF, $92, $F3, $CE, $DD, $D2, $61, $00, $5D, $3F, $38, $55, $5D, $77, $DD, $00, $FF, $92, $F3, $CE, $DD, $D2 ; filtered square
db $7C, $D4, $88, $FC, $D1, $61, $1B, $31, $6C, $E1, $36, $FF, $16, $BB, $F1, $39, $6C, $00, $8E, $D6, $F1, $4E, $90, $64, $77, $AE, $03, $DC, $F4, $61, $2E, $13 ; buzzer
db $17, $00, $2C, $26, $3B, $32, $5B, $49, $7F, $76, $67, $76, $3B, $4F, $26, $2C, $85, $0B, $B5, $97, $D8, $C0, $E5, $E4, $E1, $E7, $DB, $DB, $BB, $D2, $8B, $9D ; semisine (unused)