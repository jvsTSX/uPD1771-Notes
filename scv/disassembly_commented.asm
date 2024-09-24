;   ////////////////////////////////////////////////////////////
;  ///                  SYSTEM INFORMATION                  ///
; ////////////////////////////////////////////////////////////

; entrypoint: unknown

; interrupt vectors:

; tone interrupts - triggers when N reg counts between:
; TONE 4 -  8~15  ($08~$0F) - /64 prescalar
; TONE 3 - 16~31  ($10~$1F) - /32 prescalar
; TONE 2 - 32~63  ($20~$3F) - /16 prescalar
; TONE 1 - 64~255 ($40~$FF) - /8  prescalar (same as CPU exec rate)

; RG register

; Random Generator is its name? i don't know, but likely, it's also called PNC, and there are two, PNC1/RG1 and PNC2/RG2
; PNC1/RG1 is the actual read-out from the register using the instruction 'mov x, rg' and it consists of a 7-bit XNOR LFSR
; with the same tap coefficicents as the game boy metallic noise (last two taps)

;      __
;  .-o<__((==+-+
; .|_________|_|.
; |7|6|5|4|3|2|1|->
; '"""""""""""""'

; but this register is just a random number sampler, it does nothing by itself
; it seems to clock everytime the CPU reads an instruction if "Phi 2" corresponds to a phase of XI /8

; PNC2/RG2 however is responsible for firing a 'pseudorandom' interrupt at vector $48
; this register consists of a 3-bit XNOR LFSR

;  +--+
;  v xnr
; .|_^_^.
; |3|2|1|->
; '"""""'

; but the SCV doesn't use this interrupt, only the PNC1/RG1 for sampling noise for noise osc in PSG mode

; instruction cycle timing is all instructions take 1 m-cycle, except for CALL0, CALL1 and TBLx instructions, which take 2

;   ////////////////////////////////////////////////////////////
;  ///                 COMMAND INFORMATION                  ///
; ////////////////////////////////////////////////////////////

; |-------- Shut Up command --------|
; initial byte: $0

; it simply causes any ongoing tone or noise to stop and clears all the RAM back to its initial state (of all zeroes and some pointer MSBs)
; You must use this command before starting a PCM sample, and issuing it during a PCM sample will do nothing untill it's stopped by a $FE or $FF control byte



; |-------- Waveform command -------|

; initial byte: $02 or $03
; byte 1: Timbre     - %TTTPPPPP
; byte 2: Frequency  - %FFFFFFFF
; byte 3: Volume     - %---VVVVV

; %TTTPPPPP - Timbre is received at r0 and set to r18, it's the tone's routine work pointer
; T sets the top 3 bits, effectively being the waveform select, this works because the waveform is advanced using the ADIMS instruction which is set to only add to the low 5 bits
; P sets the initial phase of the tone, everytime the wave cycle completes it reloads this value which causes the waveform to be cropped in size towards the left

; %FFFFFFFF - Frequency is received at r2 and set to r16
; a subroutine clamps this value to $20 if it's lesser than that, and masks bit 7 to set when writing to the timer
; likely so that clamping it to $20 forces it to only fire TONE 2 or 1

; %---VVVVV - Volume is received at r4 and set to r14
; it's directly used for the multiplication subroutine, as the Y value
; since Y is a 5-bit register, the top 3 bits are effectively unused



; |---------- PSG command ----------|

; initial byte: $01
; byte 1: Timbre          - %TTTPPPPP
; byte 2: Frequency       - %FFFFFFFF
; byte 3: Volume/Mode     - %---VVVVV
; byte 4: Square 1 Freq   - %FFFFFFFF
; byte 5: Square 2 Freq   - %FFFFFFFF
; byte 6: Square 3 Freq   - %FFFFFFFF
; byte 7: Square 1 Volume - %VVVVVVVV
; byte 8: Square 2 Volume - %VVVVVVVV
; byte 9: Square 3 Volume - %VVVVVVVV

; received at r10, rE, rC, rA, r8, r6, r4, r2, r0

; noise's command receiver just really leave everything in place untouched after RXing it

; %TTTPPPPP - Timbre selects a waveform from the noise saw/square morph table at $309, and phase is just initial only,
; this register isn't actively reloaded from another location

; %---VVVVV - volume/mode will define which waveset to use, if it's 0, use the tone waveforms, if 1 to FF, use noise 'sawtooth' waveforms
; just like tone volume, this is loaded into Y register, causing the 3 top bits to be cropped out

; all frequency values are uncapped because they divide a steady interrupt rate (of 64 mcycles?) using a software counter for each of the channels
; the reason for the value being $8 is likely because it's the minimum to fire TONE 4 INT

; all Square volumes are uncapped because they're just load/not load conditions, no multiplication involved to crop the 3 MSBs

; Square tonegens use the register next to them as the freq counter

; rB counts, rA presets it
; r9 counts, r8 presets it
; r7 counts, r6 presets it
; and it counts down untill overflow (using SBIS instruction)
; which is perfect! all of those counting regs are initialized to zero



; |--------- ADPCM command ---------|

; PRE INITIAL BYTE: $00 TO CLEAR RAM
; initial byte: $04 ~ $1F      - this value also acts as volume, 04 is quietest and 1F is loudest, the volume scaling maths are the same as the waveform and PSG ones
; byte 1: frequency lookup     - sets a frequency for the Ntimer, however, it does it by looking up a value from the waveform ROM ($1FE ~ $2FC)
; byte 2: size of sample block - every ADPCM block has a control byte, this value defines how many samples (in nybbles) there are in the block untill the next control byte
; byte 3: initial ADPCM mode   - defines the starting ADPCM mode (or just ends it immediately if it's $FE or $FF lmao)

; received at r2, r0 and rD if a hold mode control byte is read

; now this is the most complex mode of this thing
; first things first, the frequency lookup stage is weird because in that range you have a lot of bytes that will result in the wrong TONE interrupt range
; star speeder uses $04 and $06 for this value, resulting in a lookup of $96 and $6B respectively (4166.6hz and 5841.1hz ?)

; the size of sample block is in nybbbles and is decremented by 1 to account for the check being underflow-based, so $63 equals to $64 samples or $32 bytes of ADPCM data

; and lastly the ADPCM control byte is another weirdo thing
; $00       - freerun mode : it simply works by requesting the 7801 a new byte once a pair of samples have been processed
; $01 ~ $FC - hold mode    : it sets itself to another counter, on register rD, which will only request a new pair of samples once both counters are at $0
;                            re-reading the same sample pair over untill either the counters are both zero or untill the sample block size counts down to UF
; $FE ~ $FF - end sample   : once this control byte is read, the 1771 returns to the command receive loop



; Faux assembler directives:
; IORG   : Instruction ORG, set a memory location in instruction word units (byte * 2) 
; ORG    : just a memory location in bytes
; ROMPAD : initial value to fill the ROM to be assembled
; DB     : Define Byte

;   ////////////////////////////////////////////////////////////
;  ///                    PROGRAM START                     ///
; ////////////////////////////////////////////////////////////

rompad $00 ; pre-fill ROM with $00
iorg $0

START:
		in pa
		in pb
		db $FFFF      ; unknown instruction but also present on Firefox
		out pb
		nop
		mvi a, $0         ; clear ports
		out pb
		out pa
		call SUB_Init_RAM ; clear RAM

Wait_Port_Command:
		in pa
		mov r$1D, a
		nop
		nop
		in pa
	tsb z a, r$1D          ; only let trough if the port is stable
	jmp Wait_Port_Command

	tsbi c a, $20          ; only let trough if it's less than $20
	jmp Wait_Port_Command

	tsbi nc r$12, $1       ; if r12 is less than 1 don't decode?
	jmp Decode_Command

	tsb z a, r$12          ; reinit if r12 doesn't match
	call SUB_Init_RAM

; these two last cond skips are for the 0 command:
; when at first written, it checks if it's 0, if yes it checks if it matches r12
; r12 will not be updated to match it because it only does below in the decode stage
; therefore, it won't match and will cause a RAM reinit, leading to a tone/noise shut off
; and eventually r12 equaling 0 from the reinit sub, now leading the program
; to just loop at the wait loop untill the 7801 sends another command

Decode_Command:
		in pa       ; get port again
		mov r$12, a ; store it on r12
	tsbi c a, $4    ; if 4 or above, it's a PCM command
	jmp PCM_Command
	tsbi c a, $2    ; if 2 or 3 it's a tone command
	jmp Tone_Command
	tsbi c a, $1    ; if 1 it's a noise command
	jmp Noise_Command
	jmp Wait_Port_Command         ; if 0 the port is still unstable or you're writing too fast, oops!



;   ////////////////////////////////////////////////////////////
;  ///                  INTERRUPT VECTORS                   ///
; ////////////////////////////////////////////////////////////

iorg $20
IRQ_TONE_4: ; fired only by NOISE mode
		mov a, r$1F
		mix r$1E    ; mix the squares with noise
		out da
	jmp Tone4_Vector

iorg $24
IRQ_TONE_3: ; fired by ??? maybe badly configured ADPCM?
		adi r$18, $1
	call SUB_Tone_Volume
		adi r$18, $2
	jmp Tone3_Vector

iorg $28
IRQ_TONE_2: ; fired by TONE
	call SUB_Tone_Volume
		adi r$18, $1
		mov a, r$16 ; get the unmasked frequency
	jmp Tone2_Vector

iorg $2C
IRQ_TONE_1: ; fired by TONE and ADPCM
	tsbi c r$12, $4 ; is r12 lesser than 4? tone vec 2 if yes
	jmp Tone1_Vector_1 ; ADPCM handler
	jmp Tone1_Vector_2 ; tone



;   ////////////////////////////////////////////////////////////
;  ///                   WAVEFORM MODE                      ///
; ////////////////////////////////////////////////////////////

Tone3_Vector:
		mov a, r$16  ; frequency backup
		ral          ; amplify it
Tone2_Vector:
	tsbi nz a, $9F   ; is it equal to 9F? skip if not
		mvi a, $A0   ; or else default it
		andi a, $1E  ; only look at the bits ---%%%%-

.loop:
	sbis a, $2       ; wait 1 to 16 iterations (what??????)
	jmp .loop

; i have no idea why is this being done, maybe a time compensation for the TONE 2 divbase being twice as slow as TONE 1?
; fall to tone1, acc's value is insignificant

; TONE GENERATOR ROUTINE

Tone1_Vector_2:
	call SUB_Tone_Volume
	adims r$18, $1        ; step waveform phase
	jmp .tone_no_wrap

	tsbi z h, $3C         ; check if H equals to this flag set by the waveform prepare subrotuine
	jmp .no_tone_flag
	call SUB_Init_Organize_Tone ; in which case it will grab the stuff at r0, r2 and r4 and put into what this routine uses
	jmp .tone_done
	; THIS ACTUALLY MAKES SENSE
	; H is set to this value by the command receive subroutine for waveform mode
	; once the waveform wraps and the value of H matches this
	; the starting phase will be reloaded, creating the phase cropping behaviour described by MAME

	; from now on i am clueless as for what happens, i only see these vars used on the ADPCM routine
.tone_no_wrap:
		mov a, r$18
	tandi z a, $3    ; done if the low 2 bits of the current wave phase is non zero
	jmp .tone_done

.no_tone_flag:
		mov a, r$16  ; frequency backup
	adis a, $80      ; if even, done
	jmp .tone_done

		adi r$17, $F ; add 15 to some work var initted to 0
	adims r$17, $1   ; does it wrap?
	adis a, $1       ; if not then add 1 to it
		mov n, a     ; if that doesn't wrap, write the result to timer (what?)
.tone_done:
		adi r$D, $1  ; command receive will lock the main program untill this is incremented twice
	reti



;   ////////////////////////////////////////////////////////////
;  ///                      PSG MODE                        ///
; ////////////////////////////////////////////////////////////

Tone4_Vector:

; square 1 counter
	sbis r$B, $1
	jmp .square_1_no_overflow:
		mov a, r$A   ; preset counter
		mov r$B, a
		mov a, r$4   ; square volume
	tsbi c r$1A, $1  ; check if the output is 0
		mvi a, $0    ; if not, set it to 0, or else load r4 into it
		mov r$1A, a
.square_1_no_overflow: ; same thing with the two below

; square 2 counter
	sbis r$9, $1
	jmp .square_2_no_overflow
		mov a, r$8   ; preset
		mov r$9, a
		mov a, r$2   ; volume
	tsbi c r$1B, $1  ; if zero, skip and load volume, if non-zero set to 0, pretty much a flipflop
		mvi a, $0
		mov r$1B, a
.square_2_no_overflow:

; square 3 counter
	sbis r$7, $1
	jmp .square_3_no_overflow
		mov a, r$6   ; preset
		mov r$7, a
		mov a, r$0   ; volume
	tsbi c r$1C, $1
		mvi a, $0
		mov r$1C, a
.square_3_no_overflow:

		mov a, r$1A ; add outputs together
		ad a, r$1B
		ad a, r$1C
		mov r$1F, a ; store it in the current sample register

; Noise waveform counter
	sbis r$F, $1
	jmp .noise_no_overflow
		mov a, r$E ; preset rF count using noise master frequency
		mov r$F, a
	adims r$10, $1 ; increment master noise waveform phase
	jmp .noise_wave_didnt_wrap

		mov x, rg         ; sample the pseudorandom register
		mov y, r$11       ; this is always set to $3 (10 pointer's MSB)
		mul2              ; only one stage so basically just adding with 3 and shifting to the right once
		andi a, %00011111 ; set it as the new starting phase for noise master osc
		ad r$10, a

.noise_no_overflow:
.noise_wave_didnt_wrap:
		tbl0 x, (r$14) ; take... code data? r15 is 0-init and r14 is volume for tone command
	tsbi c r$C, $1     ; if volume parameter is 0, use whatever's from r14
		tbl0 x, (r$10) ; or else take the noise wavetable
		mov y, r$C     ; use third parameter as volume
		mvi a, $0
		mul2
		mul2
		mul2
		mul2
		mul2
		mov r$1E, a    ; current noise sample
		adi r$D, $1    ; command receive will lock the main program untill this is incremented twice
	reti



;   ////////////////////////////////////////////////////////////
;  ///                     ADPCM MODE                       ///
; ////////////////////////////////////////////////////////////

Tone1_Vector_1:
		mvi a, $0       ; clear INT1
		out pb
		sb r$1, $1      ; r1 is a samples counter
		mvi h, $1
		mov a, r$A
	tandi nz (h), $1    ; check r1 parity
	jmp .low_nybble
		andi a, $F0
		rar
		rar
		rar
.continue_adpcm:
		rar
		mvi r$18, $A
		ad r$18, a     ; index from location+A, using a 4-bit value, this is the adapt table
		mov r$9, a     ; remember the adapt step for later
		tbl0 a, (r$18) ; get table entry

		ad r$8, a      ; add it to the adaptation counter, it will either be +1, +0 or -1
	tadi nc r$8, $1    ; clear it to 0 if the counter have stepped to $FF
		mvi r$8, $0
	tsbi c r$8, $8     ; force it to 7 if it's greater than 8
		mvi r$8, $7
		mov a, r$8     ; get current adaptation step
		ral            ; set it as the high nybble
		ral
		ral
		ral
		ad a, r$9      ; put current sample value in the low nybble
		mov r$10, a    ; get a delta value from the noise data area
		tbl0 a, (r$10)

		; add the delta into the current ADPCM level counter
		ad a, r$B
		mov r$B, a
		mvi h, $B
	tandi z (h), $80 ; flip and increment ACC if MSB is set (80-FF), so it complies with the DAC's representation
		xori a, $FF
	tandi z (h), $80
		adi a, $1

		tbl0 x, (r$16) ; \.
	tandi z (h), $80   ;  i don't think these matter, X is overwritten by A anyway, if they do something it's a program area fetch (MSB=0)
		tbl0 x, (r$14) ; /

		mov x, a           ; scales sample volume, based on the command ID number you sent ($1F = loudest, $4 = quietest)
		mov y, r$12        ; r12 remembers the ID value
	call SUB_ADPCM_Volume

; output done! now there's some checks down here
	tadi nc r$1, $1        ; if r1 haven't decremented from 0, continue down to the next checks
	jmp .sample_counter_uf

		mvi h, $1
	tandi z (h), $1        ; parity check the sample counter, return on odd numbers
	reti
	tsbi c r$4, $1         ; r4 is the pcm mode flag, if it's 0 you're on free-run mode
	jmp .hold_mode
		in pa
		mov r$A, a         ; rA holds the current sample pair to be played

.fire_int1:
		mvi a, $1
		out pb
	reti

.hold_mode:
	tsbi nc r$1, $1
	tsbi c  r$D, $1
	reti
	jmp .fire_int1 ; only ask for new byte when both counters are done

; ////////////////////////////////////////////

; on first fire it will basically fall here immediately

.sample_counter_uf:
		mov a, r$0          ; reload sample counter with r0 if another block should be played
		mov r$1, a
		in pa               ; take ADPCM command from PA
	tsbi c a, $1
	jmp .pa_nonzero
		mvi r$4, $0         ; if 0 clear the r4 flag
	jmp .fire_int1

.pa_nonzero:
	tadi nc a, $2      ; sample ends if this reads $FE or $FF
	jmp .terminator

; on first fire, rD is 0 so all of this goes untill the reti there
	sbis r$D, $1      ; or else just decrement the sample block counter
	reti              ; return if it doesn't underflow
		mov r$D, a    ; reload rD with PA value
		mvi r$A, $88  ; set holder back to initial
		mvi r$4, $1   ; set weird output it checks against when it doesn't UF
	reti

.terminator:
		mvi r$6, $1   ; frees the lock loop
		mvi md0, $0   ; disable tone interrupt
	reti

; ///////////////////////////////////////////////

.low_nybble:
		andi a, $0F
		ral
		nop
	jmp .continue_adpcm



;   ////////////////////////////////////////////////////////////
;  ///                 COMMAND PROCESSING                   ///
; ////////////////////////////////////////////////////////////

PCM_Command:
		mvi h, $2     ; receive 2 bytes
	call SUB_Receive_Command
		sb r$0, $1    ; second val - 1
		mvi a, $1     ; fire INT1
		out pb
		tbl0 a, (r$2) ; take the first RXed value from tone waveform location
		mvi r$A, $88
		mvi r$8, $7
		mov n, a      ; set that something to the timer freq
		mvi md0, $2   ; enable tone interrupt

.lk_loop:
	tsbi nc r$6, $1   ; lock here while r6 is zero, this prevents the main command wait loop to run untill the sample ends
	jmp .lk_loop

	call SUB_Init_RAM
		mvi h, $0     ; receive 1 byte?
	call SUB_Receive_Command
	jmp Wait_Port_Command

; ID 4~1F
; 1 - Ntimer speed trough indirect ROM lookup (wtf?)
; 2 - decremented, for some work value
; 3 - triggered to be received

;//////////////////////////////////////////////////////////////////////////

Tone_Command:
		mvi h, $4 ; receive 3 bytes
	call SUB_Receive_Command
	call SUB_Prep_Frequency
	tsbi nc r$5, $1              ; only init the tone if r5 is 0
	call SUB_Init_Organize_Tone
	jmp Command_Done

Noise_Command:
		mvi h, $10 ; receive 9 bytes
	call SUB_Receive_Command
		mvi a, $8
		mov n, a   ; fixed frequency

Command_Done:
		mvi r$5, $1 ; cause receive command to lock untill rD is greater than 1
		mvi md0, $2 ; enable tone irq
		mov a, r$12 ; return PA's last value
		ori a, $80  ; with a little set bit? / can the uPD7801 even read the port back?
		out pa
	jmp Wait_Port_Command



;   ////////////////////////////////////////////////////////////
;  ///                    SUBROUTINES                       ///
; ////////////////////////////////////////////////////////////

SUB_Init_RAM:
		mvi md0, $0   ; disable IRQ
		mvi a, $0
		mvi r$1F, $0
		mix r$1F      ; mix with a 0 to clear the DAC sign
		out da
		mvi a, $1
		mov n, a      ; set timer range to no TONE
		mvi h, $1F    ; wipe RAM from 1F to 0
		mvi a, $0
.loop:
		mov (h), a    ; clear all the RAM from r1F to r0
	sbis h, $1
	jmp .loop

		; prepare pointer MSBs
		mvi r$11, >adpcm_delta_table+1
		mvi r$19, >data_waveform_begin+1
		mvi r$3,  >data_waveform_begin+1
		mvi r$14, $6
	ret

;///////////////////////////////////////////////
data_waveform_begin:
org $1FE
db $00, $00, $FA, $FA, $96, $BC, $6B, $7D, $53, $5E

adpcm_adapt_table:
org $208
db $FF, $FF, $00, $FF, $00, $00, $01, $01, $01, $01, $00, $00, $FF, $00, $FF, $FF, $00, $00, $00, $00, $00, $00

;/////////////////////////////////////////////// clamps received frequency to $20
SUB_Prep_Frequency:
		mov a, r$2
	tsbi nc a, $20
		mvi a, $20
		rar
		mov r$2, a
		mvi h, $3C
	ret

;/////////////////////////////////////////////// takes received values into their work regs
SUB_Init_Organize_Tone:
		mov a, r$0
		mov r$14, a   ; received volume
		mov a, r$4
		mov r$18, a   ; received timbre/offset
		mov a, r$2
		mov r$16, a   ; received freq
		mvi r$17, $0
		andi a, $7F   ; it also clamps the frequency to 7-bit
		mov n, a      ; and sets it as the main timer irq speed
	ret

;///////////////////////////////////////////////
SUB_Receive_Command:
.restart_sub:
		mvi a, $1   ; fire INT1
		out pb
		mvi r$D, $0
	tsbi nc r$5, $1 ; if r5 is 0, wait a few cycles and avoid the lock check
	jmp .wait
.lk_loop:
	tsbi nc r$D, $2 ; if rD is 0 or 1, lock here, for wave and psg modes this will force them to fire two more times untill proceeding
	jmp .lk_loop

.keep_going:
		mvi a, $0
		out pb
		in pa
		mov (h), a
	sbis h, $2
	jmp .restart_sub
	ret

.wait:
	adis r$D, $4 ; loop untill rD overflows (64 iterations?)
	jmp .wait
	jmp .keep_going

;///////////////////////////////////////////////
SUB_Tone_Volume:
		tbl0 x, (r$18) ; takes a tone byte into Xreg
		mov y, r$14    ; yreg is the volume, since Y is only 5-bit, the top bits are effectively masked out

SUB_ADPCM_Volume:
		mvi a, $0      ; mul2 is a single-step multiply done as A = X * Y
		mul2
		mul2
		mul2
		mul2
		mul2
		ral            ; amplify to cover MSB (?) could also be a sign shift
		mov r$1F, a    ; current sample
		mvi a, $0
		mix r$1F       ; mix it and output to DAC
		out da
	ret
;/////////////////////////////////////////////////

;   ////////////////////////////////////////////////////////////
;  ///                    ROM DATA AREA                     ///
; ////////////////////////////////////////////////////////////

org $26E
tone_waveform_data:
db $DF, $B3, $FF, $F5, $C9, $EE, $84, $A4, $3E, $1F, $70, $59, $7D, $7F, $5D, $73, $17, $39, $8F, $00, $0F, $87, $36, $25, $46, $41, $36, $3E, $1F, $2B, $00, $13 ; organ
db $FF, $D0, $0D, $BC, $5D, $41, $2F, $7F, $2C, $29, $37, $34, $3A, $38, $22, $3A, $44, $00, $48, $4C, $6C, $3D, $1D, $37, $27, $20, $31, $2B, $33, $32, $00, $33 ; buzzy
db $AC, $94, $D7, $C2, $F1, $E8, $FF, $F9, $F3, $FA, $D6, $E6, $B4, $C5, $88, $9B, $2E, $16, $56, $43, $72, $66, $7D, $7B, $75, $7F, $5B, $68, $33, $48, $00, $1C ; sine ~ triangle
db $F5, $CD, $E5, $FF, $82, $B5, $41, $28, $58, $54, $50, $54, $58, $52, $67, $5E, $77, $6E, $7D, $7A, $7A, $7A, $7B, $79, $7E, $7D, $7F, $7F, $76, $7D, $00, $52 ; piano

org $2FE
adpcm_delta_table:
db $B8, $95, $DA, $CC, $EE, $E5, $FD, $F6, $0A, $03, $1B, $12, $34, $26, $6B, $48
db $CE, $B6, $E6, $DC, $F4, $EE, $FE, $F9, $07, $02, $12, $0C, $24, $1A, $4A, $32
db $DC, $CB, $ED, $E6, $F7, $F3, $FF, $FB, $05, $01, $0D, $09, $1A, $13, $35, $24
db $E7, $DB, $F3, $EE, $FA, $F7, $FF, $FD, $03, $01, $09, $06, $12, $0D, $25, $19
db $EE, $E6, $F7, $F3, $FC, $FA, $00, $FE, $02, $00, $06, $04, $0D, $09, $1A, $12
db $F2, $EB, $F9, $F6, $FD, $FB, $00, $FE, $02, $00, $05, $03, $0A, $07, $15, $0E
db $F6, $F0, $FB, $F9, $FE, $FC, $00, $FF, $01, $00, $04, $02, $07, $05, $10, $0A
db $F9, $F6, $FD, $FB, $FF, $FE, $00, $00, $00, $00, $02, $01, $05, $03, $0A, $07
db $7C, $D4, $88, $FC, $D1, $61, $1B, $31, $6C, $E1, $36, $FF, $16, $BB, $F1, $39 ; and some junk noise waveforms
db $6C, $00, $8E, $D6, $F1, $4E, $90, $64, $77, $AE, $03, $DC, $F4, $61, $2E, $13
db $7F, $80, $FF, $80, $7F, $80, $FF, $80, $7F, $80, $FF, $80, $7F, $80, $FF, $80
db $7F, $80, $FF, $80, $7F, $80, $FF, $80, $7F, $80, $FF, $80, $7F, $80, $FF, $80
db $35, $B8, $65, $7F, $B9, $0F, $96, $C6, $C0, $93, $55, $91, $89, $58, $CA, $DE
db $62, $17, $A8, $3C, $C7, $E6, $3E, $0F, $1A, $27, $B0, $06, $39, $A2, $9D, $41
db $72, $44, $57, $79, $A3, $18, $DC, $CD, $A3, $C0, $57, $18, $72, $79, $80, $44
db $D5, $83, $C1, $D8, $2F, $92, $7C, $67, $2F, $67, $C1, $92, $05, $DB, $00, $B3
