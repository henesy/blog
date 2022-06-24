+++
title = "Go Patterns - Fanning"
date = "2022-06-18"
tags = [
	"go",
]
+++

# Go Patterns - Fanning

## Background

The summer of 2022 I had the chance to explain Go programming patterns I - and I assume others - use regularly in writing concurrent systems to my three interns.

Although many university courses will talk about threading, they do not necessarily discuss concurrency, rarely if ever Go, and rarely go in depth on polymorphism.

The state of affairs is unfortunate, because it means that although Go and plenty of other 'current generation' programming languages have been publicly available for years, [Go since at least 2012](https://tip.golang.org/doc/devel/release#go1), the situation in many computer science programs is not very different from the state of affairs ten years ago.

Fortunately, Go comes with a broad set of thorough documentation with plenty of examples, which is great, but when you want to introduce multiple concepts at the same time, composed, that are foreign to an audience, you need comprehensive demonstrations.

This series will hopefully a composition of examples I have given my interns in one form or another.

## Fanning

Fanning is a handwave-y term for 'taking a lot of stuff, using it in a variety of different places, and consolidating it all back to one place.'

In mathematical terms, we could make some kind of definition like 'one to many' then 'many to one' relationships, but I am unfortunately not a mathematician.

There are a vast number of ways to go about fulfilling the preceding definitions, but in Go our scenario is typically that we want to write a program which is [concurrent](https://go.dev/blog/waza-talk), [does not share memory](https://go.dev/blog/codelab-share), [and nowadays](https://go.dev/blog/go1.18) - [might use polymorphism](https://go.dev/doc/tutorial/generics).

For the record, I do not particularly like the examples given in the Go generics documentation, so I reject them and substitute my own. This is probably because most of my polymorphic programming was in [Limbo](https://seh.dev/limbgo/) where I ended up [also writing my own examples](https://github.com/henesy/limbobyexample).

So, here's an example very similar to one I gave my interns:

[fanning.go](./fanning.go) | [playground](https://go.dev/play/p/-wuQYKzHgaM)
```go
package main

import (
	"fmt"
	"time"

	"golang.org/x/exp/constraints"
	"golang.org/x/exp/slices"
)

type Numeric interface {
	constraints.Integer | constraints.Float
}

type Empty struct{}

var Nothing = Empty{}

func fill[N Numeric](c chan N, n N, f func(N) N) {
	for i := N(0); i < n; i++ {
		c <- f(i)
	}
	close(c)
}

func drain[T Numeric](chans []chan T, results chan T) {
	var res T
	for len(chans) > 0 {
		for i, c := range chans {
			select {
			case x, ok := <-c:
				if !ok {
					chans = slices.Delete(chans, max(0, i), min(i+1, len(chans)))
				}
				res += square(x)
			default:
				time.Sleep(2 * time.Millisecond)
			}
		}
	}
	results <- res
	close(results)
}

func printer[T any](c chan T, done chan Empty) {
	for {
		x, ok := <-c
		if !ok {
			break
		}
		fmt.Println(x)
	}
	done <- Nothing
}

func main() {
	n := 5
	var chans []chan int
	fin := make(chan Empty)
	results := make(chan int)

	for i := 0; i < n; i++ {
		c := make(chan int, n)
		go fill(c, n, square[int])
		chans = append(chans, c)
	}

	go printer(results, fin)
	go drain(chans, results)

	<-fin
}

func square[T Numeric](x T) T {
	return x * x
}

func min[T Numeric](a, b T) T {
	if a <= b {
		return a
	}
	return b
}

func max[T Numeric](a, b T) T {
	if a >= b {
		return a
	}
	return b
}
```

There's a lot to unpack here!

A bunch of different Go patterns floating around, from the top!

The experimental polymorphic packages, providing [premade type constraints](godocs.io/golang.org/x/exp/constraints) and [generic slice utilities, respectively](https://godocs.io/golang.org/x/exp/slices).

```go
	"golang.org/x/exp/constraints"
	"golang.org/x/exp/slices"
```

We define our own interface for 'numbers', mostly to make a visible example:

```go
type Numeric interface {
	constraints.Integer | constraints.Float
}
```

[The empty struct pattern](https://dave.cheney.net/2014/03/25/the-empty-struct) [applied to channels](https://dave.cheney.net/2013/04/30/curious-channels):

```go
type Empty struct{}
var Nothing = Empty{}
```

```go
fin := make(chan Empty)
```

```go
done <- Nothing
```

Fill operates on a channel of numbers `c`, a number `n`, and a function of numbers `f`. For 'n' iterations, write the output of `f` of `i` to `c`. Finally, [close](https://tip.golang.org/ref/spec#Close) `c`.

```go
func fill[N Numeric](c chan N, n N, f func(N) N) {
	for i := N(0); i < n; i++ {
		c <- f(i)
	}
	close(c)
}
```

Drain takes a slice of input channels, `chans`, and a channel for a final value, `results`. While there are channels in `chans`, for every channel in `chans`, if said channel has a value `x` in it, sum the square of `x` to the final value `res`, if the channel is closed, remove the channel from `chans`. If a channel isn't ready to be read from, sleep for `2ms`. After all channels have been exhausted, write the final value to `results` and close the channel `results`.

```go
func drain[T Numeric](chans []chan T, results chan T) {
	var res T
	for len(chans) > 0 {
		for i, c := range chans {
			select {
			case x, ok := <-c:
				if !ok {
					chans = slices.Delete(chans, max(0, i), min(i+1, len(chans)))
				}
				res += square(x)
			default:
				time.Sleep(2 * time.Millisecond)
			}
		}
	}
	results <- res
	close(results)
}
```

Printer work on any type `T`, takes a channel of type `T` and a channel of empty structs. Continuously, until `c` is closed, read and print a value `x` out of `c`. After `c` is closed, write an empty struct instance, `Nothing`, to `done`.

```go
func printer[T any](c chan T, done chan Empty) {
	for {
		x, ok := <-c
		if !ok {
			break
		}
		fmt.Println(x)
	}
	done <- Nothing
}
```

Main initializes our `n` for number of channels to make and then values for each channel to write by `fill`. Two unbuffered channels are initialized, `fin` and `results`. For `n` iterations, create a channel, concurrently dispatch an instance of `fill` with `c` and `square` coerced to operate on `int` types, and add `c` to the slice of channels. `Printer` and `drain` are concurrently dispatched with copies of the channels necessarily for them to complete their roles, respectively.

The `main` goroutine is kept alive until `printer` finishes, which requires `drain` to finish, which requires all instances of `fill` to complete. If the `main` goroutine exits, [all child goroutines will be ended](https://tip.golang.org/ref/spec#Program_execution). Reading from an unbuffered channel [blocks](https://tip.golang.org/ref/spec#Channel_types) until a value is written to the channel. Buffered channel reads and writes do not block unless the buffer is empty or full, respectively.

```go
func main() {
	n := 5
	var chans []chan int
	fin := make(chan Empty)
	results := make(chan int)

	for i := 0; i < n; i++ {
		c := make(chan int, n)
		go fill(c, n, square[int])
		chans = append(chans, c)
	}

	go printer(results, fin)
	go drain(chans, results)

	<-fin
}
```

A handful of utility programs are provided at the end of the program. `Square` returns the square of a number `x`. `Min` returns a lesser of `a` or `b`. `Max` returns the greater of `a` or `b`.

```go
func square[T Numeric](x T) T {
	return x * x
}

func min[T Numeric](a, b T) T {
	if a <= b {
		return a
	}
	return b
}

func max[T Numeric](a, b T) T {
	if a >= b {
		return a
	}
	return b
}
```

## Conclusion

In the preceding program, we fanned out `n` `fill` coroutines which each provided `n` values to their respective channels.

Our fan-in was consolidating values through `drain` and then passing the final result to `printer`.

We made sure the program would run to total completion by using channel closure and the blocking properties of unbuffered channels to synchronize between goroutines.
