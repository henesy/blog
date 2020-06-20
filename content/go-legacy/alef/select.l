#include <alef.h>

int max = 2;

void
selector(chan(int) prodchan, chan(int) recchan, int n)
{
	int i;

	for(;;)
		alt{
		case i =<- prodchan:
			print("case recv	← %d\n", i);

		case recchan <-= n:
			print("case send	→ %d\n", n);
		}
}

void
producer(int n, chan(int) prodchan)
{
	int i;
	for(i = 0; i < max; i++){
		print("pushed	→ %d\n", n);
		prodchan <-= n;
	}
}

void
receiver(chan(int) recchan)
{
	int i;
	for(i = 0; i < max; i++){
		int n;
		n = <- recchan;
		print("received	→ %d\n", n);
	}
}

void
main(void)
{
	chan(int) prodchan;
	chan(int) recchan;
	alloc prodchan;
	alloc recchan;

	proc producer(123, prodchan);
	proc receiver(recchan);
	proc selector(prodchan, recchan, 456);

	sleep(15);
}
