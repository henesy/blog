+++
title = "Polymorphism in Limbo and Go 2"
date = "2020-09-28"
tags = [
	"limbo",
	"go",
	"inferno",
]
+++

# Polymorphism in Limbo and Go 2

## Motivation

Go has recently announced that it will be receiving a form of polymorphism through generics in Go 2.

Prior to and influencing Go (2), the Limbo programming language from the Inferno operating system had implemented a somewhat similar syntax for polymorphism.

There are very tangible and crucial differences, but for novelty the two languages are cross-referenced.

## Recommended prior reading

- [Go's History in Code](/go-legacy/)
- [Generics (from Limbo by Example)](https://github.com/henesy/limbobyexample/tree/master/Generics)
- [The Next Step for Generics (in Go)](https://blog.golang.org/generics-next-step)

## Running examples

Examples for both languages are provided as complete, compilable, programs.

### Go 2

Go 2 will need a custom toolchain installed:

```text
$ git clone https://github.com/golang/go/
$ git checkout dev.go2go
$ cd go/src
$ ./all.bash
# Set $GO2PATH as per GO2PATH=$GOROOT/src/cmd/go2go/testdata/go2path
# Set $GOROOT to be the root of the repository as-needed
…
$ go2 tool go2go run poly.go2
```

References:

- https://blog.golang.org/generics-next-step
- https://go.googlesource.com/go/+/refs/heads/dev.go2go/README.go2go.md
- https://go2goplay.golang.org/
- https://arxiv.org/abs/2005.11710

### Inferno

1. Acquire a copy of the Inferno source tree

Available options:

- https://bitbucket.org/inferno-os/inferno-os/ (Git)
- https://code.9front.org/hg/purgatorio/ (Mercurial)
- https://github.com/9mirrors/purgatorio (Git)

2. Clone and build

```text
$ hg clone https://code.9front.org/hg/purgatorio/	# Or equivalent Git repository
$ cd purgatorio
# Read `INSTALL`
# Edit `mkconfig`
# Update `$PATH` as per `INSTALL`
# Set $INFERNO as per `INSTALL`
$ mk mkdirs
$ mk install
$ emu					# Starts Inferno
;
; wm/wm			# Starts the Inferno GUI
…
```

3. Compile and run examples

From inside Inferno:

```text
$ emu
; cd /
; limbo foo.b
; foo			# Note the omission of the `.dis` suffix and `./` prefix
```

From a host OS:

```text
$ cd $INFERNO
$ limbo foo.b
$ emu /foo.dis
```

References:

- [INSTALL](https://github.com/9mirrors/purgatorio/blob/master/INSTALL)
- [Program development in Limbo](/limbo-intro/)
- [Limbo language papers](http://doc.cat-v.org/inferno/4th_edition/limbo_language/)

## Limbo

### Lists

Some examples from the standard library in [lists(2)](http://man.postnix.pw/purgatorio/2/lists):

**[/appl/lib/lists.b](https://github.com/9mirrors/purgatorio/blob/master/appl/lib/lists.b)**
```c
filter[T](p: ref fn(x: T): int, l: list of T): list of T {
	if(l == nil)
		return nil;

	if(p(hd l))
		return hd l :: filter(p, tl l);

	return filter(p, tl l);
}

map[T](f: ref fn(x: T): T, l: list of T): list of T {
	if(l == nil)
		return nil;

	return f(hd l) :: map(f, tl l);
}

pair[T1, T2](l1: list of T1, l2: list of T2): list of (T1, T2) {
	if(l1 == nil && l2 == nil)
		return nil;

	return (hd l1, hd l2) :: pair(tl l1, tl l2);
}

# find instance of x in l, return tail of l from x
find[T](x: T, l: list of T): list of T
	for {
		T =>	eq:	fn(a, b: T): int;
	}
{
	for(; l != nil; l = tl l)
		if(T.eq(x, hd l))
			return l;

	return nil;
}
```

The above functions reflect useful polymorphic idioms [described in depth elsewhere](https://medium.com/swlh/think-functional-with-filter-map-and-reduce-e18a189ea444).

In short:

- Filter returns a data set satisfying a function, if any
- Map applies a function across a data set
- Pair returns a data set which is composed of unions for respective entries for two data sets
- Find returns the data set following the first value satisfying a function, if any

### Arrays

Some of the functions from [lists(2)](http://man.postnix.pw/purgatorio/2/lists) re-implemented as array functions:

**[poly.b](./poly.b)**
```c
implement Poly;

include "sys.m";
	sys: Sys;

include "draw.m";

Poly: module {
	init: fn(nil: ref Draw->Context, nil: list of string);
};


Integer: type ref Integral;

Integral: adt {
	n: int;
	eq:		fn(a, b: ref Integral): int;
	String:	fn(x: self ref Integral): string;
};

Integral.eq(a, b: ref Integral): int {
	return a.n == b.n;
}

Integral.String(x: self ref Integral): string {
	return sys->sprint("%d", x.n);
}

double(x: Integer): Integer {
	return Integer(2 * x.n);
}

square(x: Integer): Integer {
	return Integer(x.n ** 2);
}

isfourable(x: Integer): int {
	return x.n % 4 == 0;
}


init(nil: ref Draw->Context, nil: list of string) {
	sys = load Sys Sys->PATH;

	i: int;
	a₀ := array[6] of Integer;

	for(i = 0; i < len a₀; i++)
		a₀[i] = Integer(i ** 2);

	aprint(a₀);

	aprint(map(double, a₀));

	aprint(filter(isfourable, a₀));

	a₁ := pair(map(double, a₀), map(square, a₀));

	sys->print("[");
	for(i = 0; i < len a₁; i++){
		(x₀, x₁) := a₁[i];
		sys->print("(%d, %d) ", x₀.n, x₁.n);
	}
	sys->print("]\n");

	aprint(find(Integer(16), a₀));

	aprint(prepend(Integer(9), a₀));

	aprint(append(Integer(99), a₀));

	aprint(tail(a₀));
}

filter[T](p: ref fn(x: T): int, a: array of T): array of T {
	if(a == nil)
		return nil;

	if(p(a[0]))
		return prepend(a[0], filter(p, tail(a)));

	if(len a < 2)
		return nil;

	return filter(p, tail(a));
}

map[T](f: ref fn(x: T): T, a₀: array of T): array of T {
	if(a₀ == nil)
		return nil;

	a₁ := array[len a₀] of T;

	for(i := 0; i < len a₀; i++)
		a₁[i] = f(a₀[i]);

	return a₁;
}

pair[T₁, T₂](a₁: array of T₁, a₂: array of T₂): array of (T₁, T₂) {
	if(a₁ == nil || a₂ == nil || len a₁ != len a₂)
		return nil;

	a₃ := array[len a₁] of (T₁, T₂);

	for(i := 0; i < len a₁; i++)
		a₃[i] = (a₁[i], a₂[i]);

	return a₃;
}

# find instance of x in l, return tail of l from x
find[T](x: T, a: array of T): array of T
	for {
		T =>	eq:	fn(a, b: T): int;
	}
{
	for(i := 0; i < len a; i++)
		if(T.eq(x, a[i]))
			return tail(a[i:]);

	return nil;
}

prepend[T](x: T, a₀: array of T): array of T {
	if(a₀ == nil)
		return array[1] of { * => x };

	a₁ := array[len a₀ + 1] of T;
	a₁[0] = x;

	for(i := 1; i < len a₁; i++)
		a₁[i] = a₀[i-1];

	return a₁;
}

append[T](x: T, a₀: array of T): array of T {
	if(a₀ == nil)
		return array[1] of { * => x };

	a₁ := array[len a₀ + 1] of T;
	a₁[len a₁ - 1] = x;

	for(i := 0; i < len a₁ -1; i++)
		a₁[i] = a₀[i];

	return a₁;
}

tail[T](a: array of T): array of T {
	if(a == nil || len a < 2)
		return nil;

	return a[1:];
}

aprint[T](a: array of T)
	for {
		T =>	String:	fn(a: self T): string;
	}
{
	if(a == nil) {
		sys->print("[]\n");
		return;
	}

	sys->print("[");

	for(i := 0; i < len a; i++) {
		sys->print("%s", a[i].String());

		if(i < len a - 1)
			sys->print(", ");
	}

	sys->print("]\n");

}
```

**Output:**

```text
; limbo poly.b
; poly
[0, 1, 4, 9, 16, 25]
[0, 2, 8, 18, 32, 50]
[0, 4, 16]
[(0, 0) (2, 1) (8, 16) (18, 81) (32, 256) (50, 625) ]
[25]
[9, 0, 1, 4, 9, 16, 25]
[0, 1, 4, 9, 16, 25, 99]
[1, 4, 9, 16, 25]
;
```

## Go 2

A re-implementation of the array functions in Limbo above:

**[poly.go2](./poly.go2)**
```go
package main

import (
	"fmt"
	"math"
)

func isfourable(n int) bool {
	return n % 4 == 0
}

func double(n int) int {
	return 2 * n
}


func main() {
	a := make([]int, 6)
	for i := 0; i < len(a); i++ {
		a[i] = int(math.Pow(float64(i), 2))
	}

	fmt.Println(a)

	fmt.Println(Map(double, a))

	fmt.Println(Filter(isfourable, a))

	fmt.Println(Find(16, a))

	fmt.Println(Tail(a))
}


func Filter[T any](f func(v T) bool, a []T) []T {
	o := make([]T, 0, len(a))

	for _, v := range a {
		if f(v) {
			o = append(o, v)
		}
	}

	return o
}

func Map[T any](f func(v T) T, a []T) []T {
	o := make([]T, len(a))

	for i, v := range a {
		o[i] = f(v)
	}

	return o
}

func Find[T comparable](x T, a []T) []T {
	for i, v := range a {
		if v == x {
			return Tail(a[i:])
		}
	}

	return nil
}

func Tail[T any](a []T) []T {
	if(a == nil || len(a) < 2) {
		return nil
	}

	return a[1:]
}
```

**Output:**

```text
$ go2 tool go2go run poly.go2
[0 1 4 9 16 25]
[0 2 8 18 32 50]
[0 4 16]
[25]
[1 4 9 16 25]
$
```

The `pair()` function is intentionally omitted as Go does not have tuples.

The `append()` and `prepend()` functions are omitted as Go has equivalents through its native `append()`.

The `comparable` interface is described in the Go 2 source as:

**$GOROOT/src/go/types/universe.go:204**
```go
// The "comparable" interface can be imagined as defined like
//
// type comparable interface {
//         == () untyped bool
//         != () untyped bool
// }
//
// == and != cannot be user-declared but we can declare
// a magic method == and check for its presence when needed.
```

## Roadblocks

**These Limbo compiler errors:**

```text
; mk
limbo -I/module -gw poly.b
poly.b:66: fn(a: T, b: T): int and fn(a: Integral, b: Integral): int are not compatible wrt Equal
poly.b:66: function call type mismatch (fn[T](x: T, a: array of T): array of T vs fn[T](nil: ref Integral, nil: array of ref Integral): array of T)
mk: limbo -I/module -gw poly.b : exit status=343 "Sh":fail:errors
;
```

The `Equal()` function needs to be defined with `ref Integral`, not `Integral` ☺.

**These Go 2 compiler errors:**

```text
$ go2 tool go2go run poly.go2
/tmp/go2go-run761246244/poly.go2:47:6: expected 'IDENT', found 'map'
go2: exit 1
$
```text

The name `map` is reserved for Go's native `map` type.

```text
$ go2 tool go2go run poly.go2
/tmp/go2go-run190126073/poly.go2:47:10: expected ), found 'type'
go2: exit 1
$
```

I used `[type T]` instead of `[T any]` inside a function signature.

