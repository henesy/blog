#include <u.h>
#include <libc.h>
#include <thread.h>

const int max = 2;

typedef struct Tuple Tuple;
struct Tuple {
	Channel *a;
	Channel *b;
};

void
selector(void *v)
{
	Tuple *t = (Tuple*)v;
	Channel *prodchan = t->a;
	Channel *recchan = t->b;
	
	// Set up vars for alt
	int pn;
	int *rn = malloc(1 * sizeof (int));
	*rn = 456;
	
	// Set up alt 
	Alt alts[] = {
		{prodchan,	&pn,	CHANRCV},
		{recchan,	rn,		CHANSND},
		{nil,		nil,	CHANEND},
	};
	
	for(;;)
		switch(alt(alts)){
		case 0:
			// prodchan open for reading
			recv(prodchan, &pn);
			print("case recv	← %d\n", pn);
			break;

		case 1:
			// recchan open for writing
			send(recchan, rn);
			print("case send	→ %d\n", *rn);
			break;

		default:
			break;
		}
}

void
producer(void *v)
{
	Channel *prodchan = (Channel*)v;
	int *n = malloc(1 * sizeof (int));
	*n = 123;

	int i;
	for(i = 0; i < max; i++){
		print("pushed		→ %d\n", *n);
		send(prodchan, n);
	}
	
	chanclose(prodchan);
}

void
receiver(void *v)
{
	Channel *recchan = (Channel*)v;
	
	int i;
	int n;
	for(i = 0; i < max; i++){
		recv(recchan, &n);
		print("received	→ %d\n", n);
	}
	
	chanclose(recchan);
}

void
threadmain(int, char*[])
{
	// Set up channels
	Channel *prodchan	= chancreate(sizeof (int), max);
	Channel *recchan	= chancreate(sizeof (int), max);
	
	Tuple *chans = malloc(1 * sizeof (Tuple));
	chans->a = prodchan;
	chans->b = recchan;

	// Start processes
	proccreate(producer, prodchan,	4096);
	proccreate(receiver, recchan,	4096);
	proccreate(selector, chans,		4096);
	
	sleep(1000);
	
	threadexitsall(nil);
}
