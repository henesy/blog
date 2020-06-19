#include <u.h>
#include <libc.h>
#include <thread.h>

const max = 10;

void printer(void *v)
{
	Channel *printchan = (Channel*) v;
	int i, n;

	for(i = 0; i < max; i++){
		recv(printchan, &n);
		print("received → %d\n", n);
	}

	threadexits(nil);
}

void pusher(void *v)
{
	Channel *printchan = (Channel*) v;
	int i, *n;
	n = calloc(1, sizeof (int));

	for(i = 0; i < max; i++){
		*n = i * i;
		send(printchan, n);
	}

	threadexits(nil);
}

void
threadmain(int, char*[]) {
	int bufsize = 2;
	Channel *printchan = chancreate(sizeof (int), 0);

	proccreate(printer,	printchan,	4096);
	proccreate(pusher,	printchan,	4096);

	sleep(100);

	threadexitsall(nil);
}
