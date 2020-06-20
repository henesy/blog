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
	chan(int)[2] bufchan;
	alloc printchan, bufchan;

	par {
		pusher(printchan);
		printer(printchan);
	}

	while(bufchan?){
		i = ++i * ++i;
		bufchan <- = i;
		print("sent %d\n", i);
	}

	while(?bufchan)
		print("received %d\n", <-bufchan);
}