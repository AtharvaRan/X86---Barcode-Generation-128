#include "stdlib.h"
#include "stdio.h"
#include "string.h"

#define	header_size		54
#define	surface_size 	90000
#define	string_limit	256
#define	barw_limit		10
#define	barh_limit		25
#define	encode_istart	105
#define	encode_start	0x1904
#define	encode_stop		0x40A4

int __cdecl encode128(
	unsigned char *dest_bitmap,
	int bar_width,
	char *text
);
const int header[header_size] = { 
	0x5FC84D42, 0x1, 0x360000, 0x280000, 0x2580000, 0x320000, 0x10000, 0x18, 0x5F920000, 0xB120001, 0xB120000, 0x0, 0x0, 0x0
};
unsigned char surface[surface_size];
char strbuf[string_limit];

const char* errors[] = {
	"String would be too wide\n",
	"String should consist of two-digit decimal numbers between 00 and 99\n",
	"String should have a proper length\n",
	"String won't fit the bitmap width\n"
};

int main(int argc, char** argv)
{
	printf("Input>");
	scanf("%s", strbuf);
	int bar_w = 0;
	printf("Bar Width>");
	scanf("%i", &bar_w);
	memset(surface, 0xFF, surface_size);	
	int er = encode128(surface, bar_w, strbuf);	
	if (er != 0) {
		printf(errors[er]);
	}
	FILE* hFile = NULL;
	hFile = fopen("output.bmp", "wb");
	fwrite(header, 1, header_size, hFile);
	fwrite(surface, 1, surface_size, hFile);
	fclose(hFile);
	return 0;
}