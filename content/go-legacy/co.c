#include <u.h>
#include <libc.h>
#include <thread.h>

void
doubleN(void *n)
{
	print("%d\n", 2*(*(int*)n));
}

void
threadmain(int, char*[])
{
	int s₀ = 7, s₁ = 9;
	threadcreate(doubleN, &s₁, 4096);	// A thread
	proccreate(doubleN, &s₀, 4096);		// A process
	sleep(5);

	threadexitsall(nil);
}
