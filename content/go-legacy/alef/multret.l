#include <alef.h>

tuple(int, byte*, byte*)
foo()
{
	return (7, "fußbol", "skål");
}

void
main(void)
{
	int n;
	byte *game, *cheer;

	(n, game, cheer) = foo();
	print("(%d %s %s)\n", n, game, cheer);
}