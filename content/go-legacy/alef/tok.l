#include <alef.h>

#define NTOKS 9
#define MAXTOK 512
#define str "abc » 'test 1 2 3' !"

void
main(void)
{
	int n, i;
	byte *toks[MAXTOK];

	print("%s\n", str);

	n = tokenize(str, toks, NTOKS);

	for(i = 0; i < n; i++)
		print("%s\n", toks[i]);

	exits(nil);
}
