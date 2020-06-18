+++
title = "Go's History in Code"
date = "2020-06-16"
tags = [
	"plan9",
	"go",
]
+++

TODO -- add direct references to literature which describes the features shown

# Go's History in Code

This post intends to showcase programming patterns, or _stuff_, which is common between Newsqueak, Alef, Plan9 C, Limbo, and Go.

All of these code snippets should be complete as shown and compilable/runnable in the state presented.

Articles or posts talking about Go's predecessors have a habit of referring to the languages listed above, but can fail to provide concrete resources for seeing how these languages work. This post aims to provide a reference for such languages.

Note that this reference is not intended to be exhaustive.

## Building and running examples

### Newsqueak

The unix port of squint is probably the most straightforward method, found [here](https://github.com/rwos/newsqueak).

The papers describing Newsqueak:

- <https://swtch.com/~rsc/thread/newsqueak.pdf>
- <https://swtch.com/~rsc/thread/newsquimpl.pdf>

To run a program from a prompt:

```shell
$ squint foo.nq
# output, if any
$
```

### Alef

Your best bet at trying Alef is installing a Plan9 2nd edition (2e) virtual machine. A text guide for this process is in [a prior blog post](https://seh.dev/plan9-2e/) and [a video guide to installation](https://www.youtube.com/watch?v=W00TnQ91nj8).

Papers on Alef: <http://doc.cat-v.org/plan_9/2nd_edition/papers/alef/>

More resources on 2e: <http://9.postnix.pw/hist/2e/>

Direct download to a VirtualBox image of 2e: <http://9.postnix.pw/hist/2e/plan92e_vbox.tgz>

There's also a work-in-progress port of Alef from 2e to 9front/386 which can be found on the [public grid](http://wiki.9gridchan.org/public_grid/index.html) griddisk at `/burnzez/rep/alef/root` and maybe `/burnzez/alef`. Griddisk is accessible over 9p via `tcp!45.63.75.148!9564`. You can more easily access the grid from unix via the [gridnix scripts](https://github.com/henesy/grid-unix).

From a prompt on a complete Plan9 2e installation:

```shell
term% 8al foo.l
term% 8l co.8
term% 8.out
# output, if any
term%
```

### Plan9 C

The most actively maintained Plan9 fork [is 9front](http://9front.org/).

Papers describing the Plan9 C dialect:

- <http://doc.cat-v.org/plan_9/programming/c_programming_in_plan_9>
- <http://doc.cat-v.org/plan_9/4th_edition/papers/compiler>

The Plan9 C dialect was partially described [in a previous blog post](https://seh.dev/porting/).

From a 386 9front system:

```shell
term% 8c foo.c
term% 8l foo.8
term% 8.out
# output, if any
term%
```

From an amd64 9front system:

```shell
term% 6c foo.c
term% 6l foo.6
term% 6.out
# output, if any
term%
```

Arm uses `5c` and `5l` for compiling/linking respectively as per the manuals [2c(1)](http://man.cat-v.org/9front/1/2c) and [2l(1)](http://man.cat-v.org/9front/1/2l).

### Limbo

The official Inferno repository: <https://bitbucket.org/inferno-os/inferno-os/>

The purgatorio Inferno fork: <https://code.9front.org/hg/purgatorio>

There are a variety of other resources for Inferno and Limbo available [^1].

Papers describing Limbo:

- <http://doc.cat-v.org/inferno/4th_edition/limbo_language/descent>
- <http://doc.cat-v.org/inferno/4th_edition/limbo_language/limbo>
- <http://doc.cat-v.org/inferno/4th_edition/limbo_language/addendum>

From a prompt inside the Inferno virtual machine (or native):

```shell
; limbo foo.b
; foo
# output, if any
;
```

### Go

Go can be acquired from <https://golang.org>.

The specification for Go: <https://golang.org/ref/spec>.

To run a single file program:

```shell
$ go run foo.go
# output, if any
$
```

## Intro \- tokenizing

This section demonstrates standard library naïve tokenizing.

### Newsqueak

Nope.

### Alef

[tok.l](./tok.l)

```c
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
```

#### Output

```text
abc » 'test 1 2 3' !
abc
»
'test
1
2
3'
!
```

### Plan9 C

[tok.c](./tok.c)

```c
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
```

#### Output

```text
abc ☺ 'test 1 2 3' !
abc
☺
test 1 2 3
!
```

### Limbo

[tok.b](./tok.b)

```c
implement Tokenizing;

include "sys.m";
	sys: Sys;

include "draw.m";

Tokenizing: module {
	init: fn(nil: ref Draw->Context, nil: list of string);
};

str: con "abc ☺ 'test 1 2 3' !";

init(nil: ref Draw->Context, nil: list of string) {
	sys = load Sys Sys->PATH;

	sys->print("%s\n", str);

	(n, toks) := sys->tokenize(str, "\n\t ");

	for(; toks != nil; toks = tl toks) {
		sys->print("%s\n", hd toks);
	}

	exit;
}
```

#### Output

```text
abc ☺ 'test 1 2 3' !
abc
☺
'test
1
2
3'
!
```

### Go

[tok.go](./tok.go)

```go
package main

import (
	"fmt"
	"strings"
)

const str = "abc ☺ 'test 1 2 3' !"

func main() {
	fmt.Println(str)

	fields := strings.Fields(str)

	for _, f := range fields {
		fmt.Println(f)
	}
}
```

#### Output

```text
abc ☺ 'test 1 2 3' !
abc
☺
'test
1
2
3'
!
```

## Asynchronous spawning

Many of the languages which inspired Go contained simple abstractions for running functions in asychronous coroutines, processes, or threads.

### Newsqueak

[co.nq](./co.nq)

```smalltalk
double := prog(n : int) {
	print(2*n, "\n");
};

# Begin main logic
begin double(7);
begin double(9);
begin double(11);
```

#### Output

```text
14
18
22
```

### Alef

[co.l](./co.l)

```c
#include <alef.h>

void
double(int n)
{
	print("%d\n", 2*n);
}

void
main(void)
{
	task double(7);		/* A coroutine	*/
	proc double(9);		/* A process	*/
	par {
		double(11);		/* A process	*/
		double(13);		/* A process	*/
	}
	sleep(5);
}

```

#### Output

```text
18
26
22
14
```

### Plan9 C

[co.c](./co.c)

```c
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
```

#### Output

```text
14
18
```

### Limbo

[co.b](./co.b)

```c
implement Coroutines;

include "sys.m";
	sys: Sys;

include "draw.m";

Coroutines: module {
	init: fn(nil: ref Draw->Context, nil: list of string);
};

double(n: int) {
	sys->print("%d\n", 2*n);
}

init(nil: ref Draw->Context, nil: list of string) {
	sys = load Sys Sys->PATH;

	spawn double(7);

	sys->sleep(5);

	exit;
}
```

#### Output

```text
14
```

### Go

[co.go](./co.go)

```go
package main

import (
	"fmt"
	"time"
)

func double(n int) {
	fmt.Println(2*n)
}

func main() {
	go double(7)
	time.Sleep(5 * time.Millisecond)
}
```

#### Output

```text
14
```

## Unnamed struct members and promotion

### Newsqueak

Nope.

### Alef

as per the user's guide

### Plan9 C

as per alef and 9c compilers paper

### Limbo

maybe?

### Go

[unnamed.go](./unnamed.go)

```go
package main

import (
	"fmt"
)

type Point struct {
	x	int
	y	int
}

type Circle struct {
	Point
	radius	uint
}

func mirror(p Point) Point {
	return Point{-1*p.x, -1*p.y}
}

func (p *Point) mirror() {
	p.x *= -1
	p.y *= -1
}

func main() {
	p := Point{x: 3, y: -1}

	c := Circle{p, 12}

	p2 := c

	fmt.Println(p)
	fmt.Println(c)
	fmt.Println(p2)

	p3 := mirror(Point{c.x, c.y})

	fmt.Println(p3)
	fmt.Println(c.Point, c.Point.x, c.Point.y)

	c.mirror()

	fmt.Println(c)
}
```

#### Output

```text
{3 -1}
{{3 -1} 12}
{{3 -1} 12}
{-3 1}
{3 -1} 3 -1
{{-3 1} 12}
```

## Sending and receiving on channels

### Newsqueak

[chans.nq](./chans.nq)

```smalltalk
max := 10;

# Prints out numbers as they're received
printer := prog(c: chan of int)
{
	i : int;
	for(i = 0; i < max; i++){
		n := <- c;
		print(n, " ");
	}
	print("\n");
};

# Pushes values into the channel
pusher := prog(c: chan of int)
{
	i : int;
	for(i = 0; i < max; i++){
		c <-= i * i;
	}
};

# Begin main logic
printChan := mk(chan of int);

begin printer(printChan);
begin pusher(printChan);
```

#### Output

```text
0 1 4 9 16 25 36 49 64 81
```

### Alef

include the ?channel operator as per user's guide

### Plan9 C



### Limbo



### Go



## Selecting on multiple channels

### Newsqueak

[select.nq](./select.nq)

```smalltalk
max := 2;

# Selects on two channels for both being able to receive and send
selector := prog(prodChan : chan of int, recChan : chan of int, n : int){
	i : int;

	for(;;)
		select{
		case i =<- prodChan:
			print("case recv	← ", i, "\n");

		case recChan <-= n:
			print("case send	→ ", n, "\n");
		}
};

# Pushes `max` values into `prodChan`
producer := prog(n : int, prodChan : chan of int){
	i : int;

	for(i = 0; i < max; i++){
		print("pushed		→ ", n, "\n");
		prodChan <-= n;
	}
};

# Reads `max` values out of `recChan`
receiver := prog(recChan : chan of int){
	i : int;

	# Stop receiving, manually
	for(i = 0; i < max; i++)
		print("received	→ ", <- recChan, "\n");
};

# Begin main logic
prodChan := mk(chan of int);

recChan := mk(chan of int);

begin producer(123, prodChan);
begin receiver(recChan);
begin selector(prodChan, recChan, 456);
```

#### Output

```text
pushed		→ 123
pushed		→ 123
case recv	← 123
case send	→ 456
received	→ 456
case send	→ 456
received	→ 456
case recv	← 123
```

### Alef



### Plan9 C

[select.c](./select.c)

```c
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
```

#### Output

```text
pushed		→ 123
received	→ 456
case send	→ 456
pushed		→ 123
received	→ 456
case send	→ 456
case recv	← 123
case send	→ 456
case recv	← 123
```

### Limbo

[select.b](./select.b)

```c
implement Select;

include "sys.m";
	sys: Sys;
	print: import sys;

include "draw.m";

Select: module {
	init: fn(nil: ref Draw->Context, nil: list of string);
};

max : con 2;

selector(prodChan: chan of int, recChan: chan of int, n: int) {
	for(;;)
		alt {
		i := <- prodChan =>
			print("case recv	← %d\n", i);

		recChan <-= n =>
			print("case send	→ %d\n", n);

		* =>
			break;
		}
}

producer(n: int, prodChan: chan of int) {
	for(i := 0; i < max; i++){
		print("pushed		→ %d\n", n);
		prodChan <-= n;
	}
}

receiver(recChan: chan of int) {
	for(i := 0; i < max; i++)
		print("received	→ %d\n", <- recChan);
}

init(nil: ref Draw->Context, nil: list of string) {
	sys = load Sys Sys->PATH;

	prodChan	:= chan of int;
	recChan	:= chan of int;

	spawn producer(123, prodChan);
	spawn receiver(recChan);
	spawn selector(prodChan, recChan, 456);

	sys->sleep(1000);

	exit;
}

```

#### Output

```text
pushed		→ 123
case send	→ 456
received	→ 456
case recv	← 123
pushed		→ 123
case recv	← 123
case send	→ 456
received	→ 456
```

### Go

[select.go](./select.go)

```go
package main

import (
	"fmt"
	"time"
)

func printer(intChan chan int, strChan chan string, stopChan chan bool) {
	strClosed := false

	loop:
	for {
		select {
		case n := <- intChan:
			fmt.Println(n)

		case s, ok := <- strChan:
			if !ok {
				strClosed = true
			} else {
				fmt.Println(s)
			}

		case stopChan <- true:
			if strClosed {
				break loop
			}
		}
	}

	fmt.Println("done.")
}

func makeInts(intChan chan int, stopChan chan bool) {
	for i := 0; i < 3; i++ {
		intChan <- i*i
	}

	<- stopChan
}

func makeStrings(strChan chan string) {
	strings := []string{"a", "b", "☺"}

	for _, s := range strings {
		strChan <- s
	}

	close(strChan)
}

func main() {
	stopChan := make(chan bool, 1)
	stopChan <- true

	intChan := make(chan int)

	size := 3
	strChan := make(chan string, size)

	go printer(intChan, strChan, stopChan)
	go makeInts(intChan, stopChan)
	go makeStrings(strChan)

	time.Sleep(10 * time.Millisecond)
}
```

#### Output

```text
0
a
1
b
☺
4
done.
```

## Multiple returns

### Newsqueak

show using tuples

### Alef

show using tuple type as per user's guide

### Plan9 C

Nope.

### Limbo

[multret.b](./multret.b)

```c
implement MultRet;

include "sys.m";
	sys: Sys;

include "draw.m";

MultRet: module {
	init: fn(nil: ref Draw->Context, nil: list of string);
};

swap(a, b: int): (int, int) {
	return (b, a);
}

init(nil: ref Draw->Context, nil: list of string) {
	sys = load Sys Sys->PATH;

	(x, y) := swap(3, 7);

	sys->print("3, 7 → %d, %d\n", x, y);

	exit;
}
```

#### Output

```text
3, 7 → 7, 3
```

### Go

[multret.go](./multret.go)

```go
package main

import (
	"fmt"
)

func foo()(n int, s string) {
	n = 4
	s = "☺"
	return
}

func bar() (a, b, c string) {
	return "a", "b", "c"
}

func main() {
	n, s := foo()

	a, b, c := bar()

	fmt.Println(n, s, a, b, c)
}
```

#### Output

```text
4 ☺ a b c
```

## Lists

### Newsqueak

???

### Alef

show `for(each X in L){}` format

### Plan9 C

show generic C linked list style

```
List *l;
for(l = mylist; l != nil; l = l->next)
	print("%d ", *(int*)l->datum);
```

### Limbo

show list :: operation and iteration style

### Go

show `for p, v := range X`

## Modules / packages / separable compilation

### Newsqueak

???

### Alef

show `#include` and headers, etc. like C

### Plan9 C

show C, maybe with the `#pragma` src thing used by libraries

### Limbo

show importing of a .dis using a .m file and then loading a .dis to run as/by the shell module

### Go

show packages

## Break and continue to tag

### Newsqueak

probably not

### Alef



### Plan9 C



### Limbo



### Go

[bctag.go](./bctag.go)

```go
package main

import (
	"fmt"
)

func main() {
	i := 0

	loop:
	for {
		i++
		switch {
		case i % 2 == 0:
			continue loop

		case i > 10:
			break loop
		}

		fmt.Println(i)
	}
}
```

#### Output

```text
1
3
5
7
9
```

## References

[^1]: https://github.com/henesy/awesome-inferno
