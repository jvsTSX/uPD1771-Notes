#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

// HUGE THANKS TO COLTON AND AXIOM ON ES DISCORD FOR HELPING ME OUT FIGURE HOW TEXT WORKS IN C

int main()
{
    FILE *srcptr, *dstptr;

    srcptr = fopen("rom.bin","rb");
    if (srcptr == NULL)
    {
        fprintf(stderr,"Error Opening ROM Binary\n");
        return EXIT_FAILURE;
    }

    dstptr = fopen("dis.asm","w");
    if (srcptr == NULL)
    {
        fprintf(stderr,"Error Creating Disasm\n");
        return EXIT_FAILURE;
    }

    uint16_t rawbin[512];
    int dsize, idx = 0;
    int lpcnt, cidx;
    unsigned char outchar;
    int tmp_n, tmp_reg;
    uint16_t opcode;

	uint8_t labels[512] = {0};

    rewind(srcptr);
    fread(&rawbin, sizeof(rawbin), 1, srcptr);



// it works without the label step so i assume i'm fucking up the opcode or rawbin


	for(lpcnt = 512; lpcnt > 0; lpcnt--, ++idx) // get labels loop
	{
	opcode = rawbin[idx];
    opcode = ( ((opcode >> 8) & 0x00FF) | ((opcode << 8) & 0xFF00) );
		
	if ((opcode & 0b1111000000000000) == 0b0110000000000000) {if ((opcode & 0b0000111111111111) < 511) labels[opcode & 0b0000000111111111] = 1;}
	if ((opcode & 0b1111000000000000) == 0b0111000000000000) {if ((opcode & 0b0000111111111111) < 511) labels[opcode & 0b0000000111111111] = 2;}
	}



    for(lpcnt = 512, idx = 0; lpcnt > 0; lpcnt--, idx = idx+1) // decode and print loop
    {
	if (labels[idx] != 0)
	{
		if (labels[idx] == 1) fprintf(dstptr, "LOC_$%X: ", idx);
		if (labels[idx] == 2) fprintf(dstptr, "SUB_$%X: ", idx);
	}
	
	
    opcode = rawbin[idx];

    opcode = ( ((opcode >> 8) & 0x00FF) | ((opcode << 8) & 0xFF00) );

    if ((opcode & 0b1000000000000000) == 0)
    {
        // non-alu ops
        switch((opcode >> 12) & 0b0000000000000111)
        {
            case 0:
                { // misc, no fields, another switch here
				
				// 0000IIII----IIII - in theory 256 instructions but it decodes less than that
				
                switch(opcode)
                {
                    case 0b0000000000000000: fprintf(dstptr, "nop\n");       break;
                    case 0b0000000000000010: fprintf(dstptr, "out pa\n");    break;
                    case 0b0000000000000100: fprintf(dstptr, "out pb\n");    break;
                    case 0b0000000000000101: fprintf(dstptr, "stf\n");       break;
                    case 0b0000000000001000: fprintf(dstptr, "mov x, rg\n"); break;

                    case 0b0000000100000001: fprintf(dstptr, "mon\n");       break;

                    case 0b0000001000000001: fprintf(dstptr, "mov n, a\n");  break;
                    case 0b0000001000001000: fprintf(dstptr, "mov x, a\n");  break;

                    case 0b0000010000000001: fprintf(dstptr, "in pa\n");     break;
                    case 0b0000010000000010: fprintf(dstptr, "in pb\n");     break;
                    case 0b0000010000000100: fprintf(dstptr, "rar\n");       break;
                    case 0b0000010000001000: fprintf(dstptr, "ral\n");       break;

                    case 0b0000010100000001: fprintf(dstptr, "	jmpa\n");      break;
                    case 0b0000010100000010: fprintf(dstptr, "out da\n");    break;
                    case 0b0000010100000100: fprintf(dstptr, "mul1\n");      break;
                    case 0b0000010100001100: fprintf(dstptr, "mul2\n");      break;

                    case 0b0000011000000100: fprintf(dstptr, "off\n");       break;

                    case 0b0000100000000000: fprintf(dstptr, "	ret\n");       break;
                    case 0b0000100000000001: fprintf(dstptr, "	rets\n");      break;

                    case 0b0000100100001111: fprintf(dstptr, "	reti\n");        break;

                    default: fprintf(dstptr, "db $%08X\n", opcode); // if op unknown, just print the raw number as data byte
                }
                break;
            }
            case 1: // misc, R field
                tmp_reg = ((opcode & 0b0000000111110000) >> 4);
                switch (opcode & 0b0000111000001111)
                {
                    case 0b000000000000: fprintf(dstptr, "mov y, r$%X\n", tmp_reg); break;
                    case 0b000000000101: fprintf(dstptr, "mov a, r$%X\n", tmp_reg); break;
                    case 0b000000001010: fprintf(dstptr, "mov h, r$%X\n", tmp_reg); break;
                    case 0b001000000001: fprintf(dstptr, "mov r$%X, a\n", tmp_reg); break;
                    case 0b001000000010: fprintf(dstptr, "mov r$%X, h\n", tmp_reg); break;
                    case 0b001000000101: fprintf(dstptr, "xchg r$%X, a\n",tmp_reg); break;
                    case 0b001000001010: fprintf(dstptr, "xchg r$%X, h\n",tmp_reg); break;

                    case 0b010000000101: fprintf(dstptr, "mov a, (h)\n");      break;
                    case 0b010000001001: fprintf(dstptr, "mix r$%X\n", tmp_reg); break;
                    case 0b011000000001: fprintf(dstptr, "mov (h), a\n");      break;
                    case 0b011000000101: fprintf(dstptr, "xchg (h), a\n");     break;

                    case 0b100000000001: fprintf(dstptr, "tbl0 a, (r$%X)\n", tmp_reg); break;
                    case 0b100000000010: fprintf(dstptr, "tbl0 x, (r$%X)\n", tmp_reg); break;
                    case 0b100000000100: fprintf(dstptr, "tbl0 y, (r$%X)\n", tmp_reg); break;
                    case 0b100000001000: fprintf(dstptr, "	call0 (r$%X)\n", tmp_reg);   break;
                    case 0b101000000001: fprintf(dstptr, "tbl1 a, (r$%X)\n", tmp_reg); break;
                    case 0b101000000010: fprintf(dstptr, "tbl1 x, (r$%X)\n", tmp_reg); break;
                    case 0b101000000100: fprintf(dstptr, "tbl1 y, (r$%X)\n", tmp_reg); break;
                    case 0b101000001000: fprintf(dstptr, "	call1 (r$%X)\n", tmp_reg);   break;
                    default: fprintf(dstptr, "db $%08X\n", opcode); // if op unknown, just print the raw number as data byte
                }
                break;

            case 2: // misc, N middle-field
            case 3: // misc, N middle-field
                tmp_n = (opcode & 0b0000000011111111);
                switch((opcode & 0b0001111100000000) >> 8)
                {
                    case 0b00000: fprintf(dstptr, "	jps $%X\n", tmp_n); break;
                    case 0b00001: fprintf(dstptr, "mvi md0, $%X\n", tmp_n); break;
                    case 0b01000: fprintf(dstptr, "	jmpfz $%X\n", tmp_n); break;

                    case 0b10001: fprintf(dstptr, "mvi md1, $%X\n", tmp_n); break;
                    case 0b10010: fprintf(dstptr, "mvi (h), $%X\n", tmp_n); break;
                    case 0b10100: fprintf(dstptr, "mvi a, $%X\n", tmp_n); break;
                    case 0b11000: fprintf(dstptr, "mvi h, $%X\n", tmp_n); break;
                    default: fprintf(dstptr, "db $%08X\n", opcode);
                }
                break;

            case 4: // mvi rN, imm
            case 5: // also mvi
                tmp_n = (opcode & 0b0000000011111111);
                tmp_reg = ((opcode & 0b0001111100000000) >> 8);
                fprintf(dstptr, "mvi r$%X, $%X\n", tmp_reg, tmp_n);
                break;

            case 6: // jump a12
                tmp_n = (opcode & 0b0000111111111111);
                fprintf(dstptr, "	jmp LOC_$%X\n", tmp_n);    
                break;

            case 7: // call a12
                tmp_n = (opcode & 0b0000111111111111);
                fprintf(dstptr, "	call SUB_$%X\n", tmp_n);
                break;

        }

    }
    else
    {
        // alu ops
        // first figure out which group to use, 8~D is group P and E~F is group K 
        // (no they're not like this on the datasheet i just accidentally called them like that and it stuck)
        if (((opcode & 0xF000) >> 12) >= 0x0E) //
        {
            // then group K
            tmp_reg = ((opcode & 0b0000000111110000) >> 4);
            tmp_n = (opcode & 0b0000000000001111);
            switch((opcode & 0b0001111000000000) >> 9)
            {
                case 0x0: fprintf(dstptr, "adi r$%X, $%X\n", tmp_reg, tmp_n); break;
                case 0x1: fprintf(dstptr, "	adis r$%X, $%X\n", tmp_reg, tmp_n); break;
                case 0x2: fprintf(dstptr, "sb r$%X, $%X\n", tmp_reg, tmp_n); break;
                case 0x3: fprintf(dstptr, "	sbis r$%X, $%X\n", tmp_reg, tmp_n); break;
                case 0x4: fprintf(dstptr, "tadi nc r$%X, $%X\n", tmp_reg, tmp_n); break;
                case 0x5: fprintf(dstptr, "tadi c r$%X, $%X\n", tmp_reg, tmp_n); break;
                case 0x6: fprintf(dstptr, "	tsbi nc r$%X, $%X\n", tmp_reg, tmp_n); break;
                case 0x7: fprintf(dstptr, "	tsbi c r$%X, $%X\n", tmp_reg, tmp_n); break;
                case 0x8: fprintf(dstptr, "adi5 r$%X, $%X\n", tmp_reg, tmp_n); break;
                case 0x9: fprintf(dstptr, "	adims r$%X, $%X\n", tmp_reg, tmp_n); break;
                case 0xC: fprintf(dstptr, "	tadi5 r$%X, $%X\n", tmp_reg, tmp_n); break;
                default:  fprintf(dstptr, "db $%08X\n", opcode);
            }
        }
        else // else group P
        {
            switch((opcode & 0b0001111000000000)>> 9)
            {
                case 0x0: ((opcode & 0x6000) == 0x4000)?fprintf(dstptr, "ad "):fprintf(dstptr, "adi "); break;
                case 0x1: ((opcode & 0x6000) == 0x4000)?fprintf(dstptr, "and "):fprintf(dstptr, "andi "); break;
                case 0x2: ((opcode & 0x6000) == 0x4000)?fprintf(dstptr, "sb "):fprintf(dstptr, "sbi "); break;
                case 0x3: ((opcode & 0x6000) == 0x4000)?fprintf(dstptr, "or "):fprintf(dstptr, "ori "); break;
                case 0x4: ((opcode & 0x6000) == 0x4000)?fprintf(dstptr, "	ads "):fprintf(dstptr, "	adis "); break;
                case 0x5: ((opcode & 0x6000) == 0x4000)?fprintf(dstptr, "	ands "):fprintf(dstptr, "	andis "); break;
                case 0x6: ((opcode & 0x6000) == 0x4000)?fprintf(dstptr, "	sbs "):fprintf(dstptr, "	sbis "); break;
                case 0x7: ((opcode & 0x6000) == 0x4000)?fprintf(dstptr, "xor "):fprintf(dstptr, "xori "); break;
                case 0x8: ((opcode & 0x6000) == 0x4000)?fprintf(dstptr, "	tad nc "):fprintf(dstptr, "	tadi nc "); break;
                case 0x9: ((opcode & 0x6000) == 0x4000)?fprintf(dstptr, "	tand nz "):fprintf(dstptr, "	tandi nz "); break;
                case 0xA: ((opcode & 0x6000) == 0x4000)?fprintf(dstptr, "	tsb nc "):fprintf(dstptr, "	tsbi nc "); break;
                case 0xB: ((opcode & 0x6000) == 0x4000)?fprintf(dstptr, "	tsb nz "):fprintf(dstptr, "	tsbi nz "); break;
                case 0xC: ((opcode & 0x6000) == 0x4000)?fprintf(dstptr, "	tad c "):fprintf(dstptr, "	tadi c "); break;
                case 0xD: ((opcode & 0x6000) == 0x4000)?fprintf(dstptr, "	tand z "):fprintf(dstptr, "	tandi z "); break;
                case 0xE: ((opcode & 0x6000) == 0x4000)?fprintf(dstptr, "	tsb c "):fprintf(dstptr, "	tsbi c "); break;
                case 0xF: ((opcode & 0x6000) == 0x4000)?fprintf(dstptr, "	tsb z "):fprintf(dstptr, "	tsbi z "); break;
            }
            switch (((opcode & 0b0110000000000000) >> 13))
            {
                case 0:
                {
                    if ((opcode & 0b0000000100000000) == 0)
                    {
                        tmp_n = (opcode & 0b0000000011111111);
                        fprintf(dstptr, "a, $%X\n", tmp_n);
                    }
                    else
                    {
                        if ((opcode & 0b0001000000000000) == 1)
                        {
                        tmp_n = (opcode & 0b0000000011111111);
                        fprintf(dstptr, "md, $%X\n", tmp_n);
                        }
                        else
                        {
                        tmp_n = ((opcode & 0b0000000011100000) >> 5);
                        fprintf(dstptr, "md1, $%X\n", tmp_n);
                        }
                    }
                    break;
                }
                case 1:
                {
                    if ((opcode & 0b0000000100000000) == 0)
                    {
                        tmp_n = (opcode & 0b0000000011111111);
                        fprintf(dstptr, "(h), $%X\n", tmp_n);
                    }
                    else
                    {
                        tmp_n = (opcode & 0b0000000011111111);
                        fprintf(dstptr, "h, $%X\n", tmp_n);
                    }
                    break;
                }
                case 2:
                {
                    switch (opcode & 0x000F)
                    {
                        case 0b0001: fprintf(dstptr, "a, (h)\n"); break;
                        case 0b1001: fprintf(dstptr, "(h), a\n"); break;
                        case 0b0000: tmp_reg = ((opcode & 0b0000000111110000) >> 4); fprintf(dstptr, "a, r$%X\n", tmp_reg); break;
                        case 0b1000: tmp_reg = ((opcode & 0b0000000111110000) >> 4); fprintf(dstptr, "r$%X, a\n", tmp_reg); break;
                        default: fprintf(dstptr, "<U/D ADDR MODE> - OP $%X\n", opcode);
                    }
                    break;
                }
            }
        }
    }
    }
    fclose(srcptr);
    fclose(dstptr);
    printf("Disassembly Ready!\n");
    return EXIT_SUCCESS;
}

