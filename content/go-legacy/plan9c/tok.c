#include <u.h>
#include <libc.h>

#define NTOKS 9
#define MAXTOK 512
char *str = "abc ☺ 'test 1 2 3' !";

void
main(int, char*[])
{
	int n, i;
	char *toks[MAXTOK];
	
	print("%s\n", str);
	
	n = tokenize(str, (char**)toks, NTOKS);

	for(i = 0; i < n; i++)
		print("%s\n", toks[i]);

	exits(nil);
}
