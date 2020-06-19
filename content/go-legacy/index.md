+++
title = "Go's History in Code"
date = "2020-06-16"
tags = [
	"go",
	"plan9",
	"inferno",
]
+++

# Go's History in Code

This post intends to showcase programming patterns, or _stuff_, which is common between Newsqueak, Alef, Plan9 C, Limbo, and Go.

All of these code snippets should be complete as shown and compilable/runnable in the state presented.

Articles or posts talking about Go's predecessors have a habit of referring to the languages listed above, but can fail to provide concrete resources for seeing how these languages work. This post aims to provide a reference for such languages.

Note that this reference is not intended to be exhaustive.

If I missed a feature or misreported a fact, feel free to open an issue/PR against [the blog on GitHub](http://github.com/henesy/blog).

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

[tok.l](./alef/tok.l)

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

[tok.c](./plan9c/tok.c)

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

[tok.b](./limbo/tok.b)

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

[tok.go](./go/tok.go)

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

[co.nq](./newsqueak/co.nq)

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

[co.l](./alef/co.l)

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

[co.c](./plan9c/co.c)

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

[co.b](./limbo/co.b)

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

[co.go](./go/co.go)

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

This example is partially derived from the unnamed subunion example presented in the _'Plan 9 C Compilers'_ paper. [^4]

[unnamed.c](./plan9c/unnamed.c)

```c
#include <u.h>
#include <libc.h>

double π = 3.14;

typedef struct Point Point;
typedef struct Circle Circle;
typedef struct Number Number;
typedef struct Value Value;

struct Number {
	union {
		double dval;
		float  fval;
		long   lval;
	};
};

struct Value {
	Number;
};

struct Point {
	int	x;
	int	y;
};

struct Circle {
	Point;
	int	radius;
};

Point
mirror(Point p)
{
	return (Point) {-1 * p.x, -1 * p.y};
}

void
main(int, char*[])
{
	Point p₀ = {.x = 3, .y = -1};

	Circle c = {p₀, 12};

	Point p₁ = c.Point;

	print("p₀ = (%d,%d)\nradius = %d\n", c.x, c.y, c.radius);
	print("p₁ = (%d,%d)\n", p₁.x, p₁.y);

	Point p₂ = mirror((Point){c.x, c.y});

	print("p₂ = (%d,%d)\n", p₂.x, p₂.y);

	Value v = {π};

	print("value = %f\nd = %p\nf = %p\nl = %p\n",
				v.dval, &v.dval, &v.fval, &v.lval);

	exits(nil);
}
```

#### Output

```text
p₀ = (3,-1)
radius = 12
p₁ = (3,-1)
p₂ = (-3,1)
value = 3.140000
d = 7fffffffeed0
f = 7fffffffeed0
l = 7fffffffeed0
```

### Limbo

Nope.

### Go

[unnamed.go](./go/unnamed.go)

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

[chans.nq](./newsqueak/chans.nq)

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

Note the existence, even if not demonstrated, of the `?` operator for channels as per the _"Alef User's Guide"_. [^5]

```c
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
```

#### Output

```text
0
1
4
9
16
25
36
49
64
81
```

### Plan9 C

[chans.c](./plan9c/chans.c)

```c
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
```

#### Output

```text
received → 0
received → 1
received → 4
received → 9
received → 16
received → 25
received → 36
received → 49
received → 64
received → 81
```

### Limbo

[chans.b](./limbo/chans.b)

```c
implement Channels;

include "sys.m";
	sys: Sys;

include "draw.m";

Channels: module {
	init: fn(nil: ref Draw->Context, nil: list of string);
};

max : con 10;

printer(c: chan of int) {
	i : int;
	for(i = 0; i < max; i++){
		n := <- c;
		sys->print("%d ", n);
	}
	sys->print("\n");
}

pusher(c: chan of int) {
	i : int;
	for(i = 0; i < max; i++){
		c <-= i * i;
	}
}

init(nil: ref Draw->Context, nil: list of string) {
	sys = load Sys Sys->PATH;

	printChan := chan of int;

	spawn printer(printChan);
	spawn pusher(printChan);

	sys->sleep(1);

	exit;
}
```

#### Output

```text
0 1 4 9 16 25 36 49 64 81
```

### Go

[chans.go](./go/chans.go)

```go
package main

import (
	"fmt"
)

const max = 10

func printer(c chan int, done chan bool) {
	for {
		n, ok := <- c
		if !ok {
			break
		}

		fmt.Print(n, " ")
	}

	fmt.Println()

	done <- true
}

func pusher(c chan int) {
	for i := 0; i < max; i++ {
		c <- i * i
	}

	close(c)
}

func main() {
	c := make(chan int, 2)
	done := make(chan bool)

	go printer(c, done)
	go pusher(c)

	<- done
}

```

#### Output

```text
0 1 4 9 16 25 36 49 64 81
```

## Selecting on multiple channels

### Newsqueak

[select.nq](./newsqueak/select.nq)

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

show alt in alef on send and receive

### Plan9 C

[select.c](./plan9c/select.c)

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

[select.b](./limbo/select.b)

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

[select.go](./go/select.go)

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

C in particular is an offender of not enabling returns without a named type (`struct`) or allocated memory in place to facilitate multiple values being returned to a caller.

### Newsqueak

Nope.

### Alef

show using tuple type as per user's guide

### Plan9 C

Nope.

### Limbo

[multret.b](./limbo/multret.b)

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

[multret.go](./go/multret.go)

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

This section demonstrates syntactic properties regarding lists or which are somewhat list-like.

### Newsqueak

Nope.

### Alef

show `for(each X in L){}` format

### Plan9 C

Nope.

### Limbo

This is a modified version of the _'Lists'_ example in LimboByExample. [^2]

[lists.b](./limbo/lists.b)

```c
implement Lists;

include "sys.m";
	sys: Sys;
	print: import sys;

include "draw.m";

Lists: module {
	init: fn(nil: ref Draw->Context, nil: list of string);
};

init(nil: ref Draw->Context, nil: list of string) {
	sys = load Sys Sys->PATH;

	names: list of string;
	ages: list of int;
	persons: list of (string, int);

	print("Lens: %d, %d, %d\n", len names, len ages, len persons);

	names = "Spike" :: names;
	ages = 27 :: ages;

	names = "Ed" :: "Jet" :: names;
	ages = 13 :: 36 :: ages;

	print("Lens: %d, %d, %d\n", len names, len ages, len persons);

	n := names;
	a := ages;

	while(n != nil && a != nil) {
			persons = (hd n, hd a) :: persons;
			n = tl n;
			a = tl a;
	}

	print("Persons:\n");
	for(; persons != nil; persons = tl persons) {
		(name, age) := hd persons;
		print("\t%s: %d\n", name, age);
	}

	print("Tmp lens: %d, %d\n", len n, len a);
	print("Lens: %d, %d, %d\n", len names, len ages, len persons);

	exit;
}
```

#### Output

```text
Lens: 0, 0, 0
Lens: 3, 3, 0
Persons:
	Spike: 27
	Jet: 36
	Ed: 13
Tmp lens: 0, 0
Lens: 3, 3, 0
```

### Go

[lists.go](./go/lists.go)

```go
package main

import (
	"fmt"
)

func main() {
	nums := make([]int, 0, 10)

	fmt.Printf("Length = %d\nCapacity = %d\n", len(nums), cap(nums))


	nums = append(nums, 1)
	nums = append(nums, 2, 3, 4)

	for i, n := range nums {
		fmt.Printf("%d: %d\n", i, n)
	}

	fmt.Printf("Length = %d\nCapacity = %d\n", len(nums), cap(nums))
}
```

#### Output

```text
Length = 0
Capacity = 10
0: 1
1: 2
2: 3
3: 4
Length = 4
Capacity = 10
```

## Modules / packages / separable compilation

Although the idea of separating source across files is fairly universal in modern programming languages, this section demonstrates the semantics shared between these languages.

### Newsqueak

Newsqueak can include files as text. This text can be assigned to a value or otherwise is inserted into the calling file as text and potentially interpreted as source.

[main.nq](./newsqueak/modules/main.nq)

```smalltalk
include "util.nq";

print("Hello ");
smiley();
```

[util.nq](./newsqueak/modules/util.nq)

```smalltalk
smiley := prog() {
	smile := include "smile";
	print(smile);
};

;
```

[smile](./newsqueak/modules/smile)

```text
"☺"
```

#### Output

```text
Hello
☺
```

### Alef

show `#include` and headers, etc. like C

### Plan9 C

There are several compiler features which show themselves in the header: `#pragma src` and `#pragma lib`. Further reading on these can be found in the _'Plan 9 C Compilers'_ paper. [^4]

Note that these `#pragma` directives typically are found with full system paths provided.

[main.c](./plan9c/modules/main.c)

```c
#include <u.h>
#include <libc.h>
#include "./libutil/util.h"

void
main(int, char*[])
{
	print("Hello ");
	smiley();

	exits(nil);
}
```

[util.h](./plan9c/modules/libutil/util.h)

```c
#pragma src "./libutil"
#pragma lib "./libutil/libutil.a"

void smiley(void);
```

[util.c](./plan9c/modules/libutil/util.c)

```c
#include <u.h>
#include <libc.h>
#include "util.h"

void
smiley(void)
{
	print("☺\n");
}
```

[mkfile (main)](./plan9c/modules/mkfile)

```make
</$objtype/mkfile

BIN = ./

TARG = modules-example

OFILES = main.$O

CFLAGS = $CFLAGS -I ./libutil

</sys/src/cmd/mkone
```

[mkfile (libutil)](./plan9c/modules/libutil/mkfile)

```make
</$objtype/mkfile

LIB = ./libutil.a

HFILES = util.h

OFILES = util.$O

</sys/src/cmd/mklib
```

#### Output

For this example, to build and run from 9front you'll use [mk(1)](http://man.cat-v.org/9front/1/mk):

```shell
tenshi% lc
libutil/	main.c		mkfile
tenshi% cd libutil
tenshi% mk
./libutil.a doesn't exist: assuming it will be an archive
6c -FTVw util.c
ar vu ./libutil.a util.6
ar: creating ./libutil.a
a - util.6
tenshi% cd ..
tenshi% mk
6c -FTVw -I ./libutil main.c
6l  -o 6.out main.6
tenshi% 6.out
Hello ☺
tenshi%
```

### Limbo

This is a slightly reduced version of the _'Modules'_ example in LimboByExample. [^2]

[modules.b](./limbo/modules/modules.b)

```c
implement Modules;

include "sys.m";
include "draw.m";

# Note the lack of `include "persons.m";`
include "towns.m";

sys: Sys;
print: import sys;

persons: Persons;
Person: import persons;

towns: Towns;
Town: import towns;

Modules: module {
	init: fn(nil: ref Draw->Context, nil: list of string);
};

init(nil: ref Draw->Context, nil: list of string) {
	sys = load Sys Sys->PATH;

	persons = load Persons "./persons.dis";
	towns = load Towns "./towns.dis";

	persons->init();
	towns->init();

	print("%d\n", persons->getpop());
	print("%d\n", towns->persons->getpop());

	p := persons->mkperson();
	p.name	= "Spike";
	p.age	= 27;

	print("%d\n", persons->getpop());
	print("%d\n", towns->persons->getpop());

	t := towns->mktown();
	t.pop = array[] of {p, ref Person(13, "Ed")};
	t.name = "Mars";

	print("%s\n", t.stringify());

	exit;
}
```

[persons.b](./limbo/modules/persons.b)

```c
implement Persons;

include "persons.m";

population: int;

init() {
	population = 0;
}

getpop(): int {
	return population;
}

mkperson(): ref Person {
	population++;
	return ref Person;
}

Person.stringify(p: self ref Person): string {
	return p.name;
}
```

[towns.m](./limbo/modules/towns.m)

```c
include "persons.m";

Towns: module {
	init: fn();
	mktown: fn(): ref Town;

	persons: Persons;

	Town: adt {
		pop: array of ref Persons->Person;
		name: string;
		stringify: fn(t: self ref Town): string;
	};
};
```

[towns.b](./limbo/modules/towns.b)

```c
implement Towns;

include "towns.m";

init() {
	persons = load Persons "./persons.dis";
}

mktown(): ref Town {
	return ref Town;
}

Town.stringify(t: self ref Town): string {
	Person: import persons;

	s := "Name: " + t.name + "\nSize: " + string len t.pop + "\nMembers:";

	for(i := 0; i < len t.pop; i++)
		s += "\n→ " + t.pop[i].stringify();

	return s;
}
```

[mkfile](./limbo/modules/mkfile)

```make
</mkconfig

DISBIN = ./

TARG=\
	modules.dis\
	persons.dis\
	towns.dis\

</mkfiles/mkdis
```

#### Output

For this example, to build and run from Inferno you'll use [mk(1)](http://man.cat-v.org/inferno/1/mk):

```shell
; mk
limbo -I/module -gw modules.b
limbo -I/module -gw persons.b
limbo -I/module -gw towns.b
; modules
0
0
1
0
Name: Mars
Size: 2
Members:
→ Spike
→ Ed
;
```

### Go

This example just shows including a local package.

Modern Go recommends using the module system [^3] and most public Go projects will have import paths in forms such as `"github.com/foo/bar"`.

[main.go](./go/modules/main.go)

```go
package main

import (
util	"./util"
	"fmt"
)

func main() {
	fmt.Print("Hello ")
	util.Smile()
}
```

[util.go](./go/modules/util/util.go)

```go
package util

import (
	"fmt"
)

func Smile() {
	fmt.Println("☺")
}
```

#### Output

```text
Hello ☺
```

## Break and continue to tag

### Newsqueak

Nope.

### Alef

as per user's guide, show `break n` for `n` levels of nested control

no continue

### Plan9 C

Nope.

### Limbo

[bctag.b](./limbo/bctag.b)

```c
implement BreakContinueTag;

include "sys.m";
	sys: Sys;

include "draw.m";

BreakContinueTag: module {
	init: fn(nil: ref Draw->Context, nil: list of string);
};

init(nil: ref Draw->Context, nil: list of string) {
	sys = load Sys Sys->PATH;

	i := 0;

	loop:
	for(;;){
		i++;
		case i {
		11 =>
			break loop;
		* =>
			if(i % 2 == 0)
				continue loop;
		}

		sys->print("%d\n", i);
	}

	exit;
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

### Go

[bctag.go](./go/bctag.go)

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
[^2]: https://github.com/henesy/limbobyexample
[^3]: https://blog.golang.org/using-go-modules
[^4]: http://doc.cat-v.org/plan_9/4th_edition/papers/compiler
[^5]: http://doc.cat-v.org/plan_9/2nd_edition/papers/alef/ug