#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

// simple program to swap the MSB and LSB of the instruction words
// if you wish to use the ROMs as a sample

int main()
{
    FILE *srcptr, *dstptr;

    srcptr = fopen("1771rom.bin","rb");
    if (srcptr == NULL)
    {
        fprintf(stderr,"Error Opening ROM Binary\n");
        return EXIT_FAILURE;
    }

    dstptr = fopen("1771rom_unswapped.bin","w");
    if (srcptr == NULL)
    {
        fprintf(stderr,"Error Creating File\n");
        return EXIT_FAILURE;
    }

    uint16_t rawbin[512];
    int dsize, idx = 0;
    int lpcnt, cidx;
    unsigned char outchar;
    int tmp_n, tmp_reg;
    uint16_t opcode;
	int16_t oplow, ophigh; 

    rewind(srcptr);
    fread(&rawbin, sizeof(rawbin), 1, srcptr);

    for(lpcnt = 512; lpcnt > 0; lpcnt--, idx = idx+1)
    {

    opcode = rawbin[idx];

    opcode = ( (((opcode >> 8) & 0x00FF)) | ((opcode << 8) & 0xFF00) );
	opcode = (opcode & 0x8000)?opcode:opcode^0xFF00+0x8000;
	opcode = (opcode & 0x0080)?opcode:opcode^0x00FF+0x0080;

    fwrite(&opcode, sizeof(opcode), 1, dstptr);

    }
    fclose(srcptr);
    fclose(dstptr);
    printf("Byte Swap successful!\n");
    return EXIT_SUCCESS;
}

