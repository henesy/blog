+++
title = "Polymorphism in Limbo and Go 2"
date = "2020-09-29"
tags = [
	"limbo",
	"go",
	"inferno",
]
+++

# Polymorphism in Limbo and Go 2

## Motivation

Go has recently announced that it will be receiving a form of polymorphism through generics in Go 2.

Prior to and influencing Go (and thus Go 2), the [Limbo programming language](http://doc.cat-v.org/inferno/4th_edition/limbo_language/) from [the Inferno operating system](http://doc.cat-v.org/inferno/) had implemented a somewhat similar syntax for polymorphism.

There are very tangible and crucial differences, but for novelty the two languages are cross-referenced.

This post was primarily motivated by a discussion and linguistic adventure that occurred during [a stream exploring the Limbo language and Inferno OS](https://www.youtube.com/watch?v=6KTGM479O2Q).

**Disclaimer:** I am not an expert on Limbo or Go, if any part of this document is incorrect, please let me know ☺.

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

Examples may be operable through [the Go 2 playground](https://go2goplay.golang.org/).

References:

- [dev.go2go README](https://go.googlesource.com/go/+/refs/heads/dev.go2go/README.go2go.md)
- [Type Parameters - Draft Design](https://go.googlesource.com/proposal/+/refs/heads/master/design/go2draft-type-parameters.md)
- [Featherweight Go](https://arxiv.org/abs/2005.11710)

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
$ limbo foo.b
$ emu -r ./ -d foo.dis
```

References:

- [INSTALL](https://github.com/9mirrors/purgatorio/blob/master/INSTALL)
- [Program development in Limbo](/limbo-intro/)
- [Limbo language papers](http://doc.cat-v.org/inferno/4th_edition/limbo_language/)

## Limbo

### Lists

Lists are a first-class type in Limbo.

Some examples from the standard library's [lists(2)](http://man.postnix.pw/purgatorio/2/lists):

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
	Equals:		fn(a, b: ref Integral): int;
	String:		fn(x: self ref Integral): string;
};

Integral.Equals(a, b: ref Integral): int {
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
		T =>	Equals:	fn(a, b: T): int;
	}
{
	for(i := 0; i < len a; i++)
		if(T.Equals(x, a[i]))
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

### Summary

Limbo is picky about what kind of type or value can be considered `T` or be used in a polymorphic manner.

Specifically, only `ref` values may be used polymorphically.

Primitive types such as `int` are disallowed to be used polymorphically as a `ref int` type cannot exist in Limbo.

Practically, these constraints translate to needing to utilize and operate upon, for polymorphic purposes, `ref` types of ADT's.

Additionally, any methods which operate on a type and are intended to be used polymorphically, must operate on a `ref` type of its parent ADT (Abstract Data Type).

For ease of use, a type alias shorthand may be desirable (`Integer` above) to avoid writing `ref Integral` continuously throughout the source.

**Note:** one cannot have a `ref T` in a polymorphic function.

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

The `pair()` function is omitted as Go does not have tuples.

The `append()` and `prepend()` functions are omitted as Go can express equivalent functionality through its native `append()`.

### Summary

Go permits polymorphism over `interface` types.

Interface types require methods be present on a given fulfilling type.

Interfaces may extend and further constraint other interfaces.

The `any` interface seen in Go 2 is equivalent to `interface{}` in Go 1 and may be satisfied by **any** type.

The `comparable` interface seen above is described in the Go 2 source as:

**[$GOROOT/src/go/types/universe.go:204](https://github.com/golang/go/blob/5e60d1e8c796e40be31e51e06945d6ec4e40d3f2/src/go/types/universe.go#L204)**
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

Notably, at present, not all functionality - such as `==` and `!=` above - can be implemented directly by a user, but is limited to being defined inside the compiler proper.

## Roadblocks

**Limbo compiler errors:**

```text
; mk
limbo -I/module -gw poly.b
poly.b:66: fn(a: T, b: T): int and fn(a: Integral, b: Integral): int are not compatible wrt Equal
poly.b:66: function call type mismatch (fn[T](x: T, a: array of T): array of T vs fn[T](nil: ref Integral, nil: array of ref Integral): array of T)
mk: limbo -I/module -gw poly.b : exit status=343 "Sh":fail:errors
;
```

The `Equal()` function needs to be defined with `ref Integral`, not `Integral` ☺.

**Go 2 compiler errors:**

```text
$ go2 tool go2go run poly.go2
/tmp/go2go-run761246244/poly.go2:47:6: expected 'IDENT', found 'map'
go2: exit 1
$
```

The name `map` is reserved for Go's native `map` type.

```text
$ go2 tool go2go run poly.go2
/tmp/go2go-run190126073/poly.go2:47:10: expected ), found 'type'
go2: exit 1
$
```

I used `[type T]` instead of `[T any]` inside a function signature.

## Conclusions

Go 2 implements polymorphism over interfaces, which primitive types are permitted to fulfill.

Limbo does not have interfaces, but can somewhat mimic this behavior using constraints on methods for types, as per above:

```c
# find instance of x in l, return tail of l from x
find[T](x: T, a: array of T): array of T
	# Constraint is here ↓
	for {
		T =>	Equals:	fn(a, b: T): int;
	}
{
	# Function proper begins here ↓
	for(i := 0; i < len a; i++)
		if(T.Equals(x, a[i]))
			return tail(a[i:]);

	return nil;
}
```

Specifically - in Limbo - a type *T* may be used polymorphically if and only if the type is:

- A reference
- Can have methods

Thus, since Limbo does not permit type definitions which are references to primitives, only a reference to ADT type may be used polymorphically.

Go's interfaces show their power here, as interfaces can build upon and further constraint other, extant, interfaces, allowing a degree of composition Limbo is not able to represent formally.

Both systems constrain polymorphic types based on the presence of methods and said method's signatures, but Go permits a more flexible model of definition for what may qualify an interface and thus be used polymoprhically.

For example, in Go:

```go
type Equitable interface {
	Equals(e Equitable) bool
}

type Comparable interface {
	Equitable
	Greater(c Comparable) bool
	Lesser(c Comparable) bool
}
```

The equivalent for Limbo would resemble a function constraint in the form:

```c
# find instance of x in l, return tail of l from x
compare[T](x: T, a: array of T): array of T
	for {
		T =>
			Equals:		fn(a, b: T): int;
			Greater:		fn(a, b: T): int;
			Lesser:		fn(a, b: T): int;
	}
{ … }
```

Note that Limbo does not have the ability to group these constraints under a name or set.

Furthermore, as Go is effectively the spiritual successor to Limbo, Go's interfaces represent an evolution on the initial - spartan and limited - implementation of polymorphic type constraint from Limbo and permit a similar, but more elegant model of constraint composition.
