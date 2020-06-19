#include <alef.h>

int max = 10;

void
pusher(chan(int) printchan)
{
	int i;
	for(i = 0; i < max; i++)
		printchan <-= i * i;
}

void
printer(chan(int) printchan)
{
	int n, i;

	for(i = 0; i < max; i++){
		n = <-printchan;
		print("%d\n", n);
	}
}

void
main(void)
{
	chan(int) printchan;
	alloc printchan;

	par {
		pusher(printchan);
		printer(printchan);
	}

	sleep(5);
}