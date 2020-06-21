#include <alef.h>

void
main(void)
{
	chan(int)[1] dummy;
	chan(int)[2] ch;
	int a;

	alloc ch, dummy;
	dummy <-= 1;
	ch <-= 3;
	ch <-= 4;

	while(?ch)
		alt {
		case a = <-ch;
			print("got %d\n", a);
			break 2;

		case <- dummy;
			print("dummy\n");
			dummy <-= 1;
			break;
		}
}