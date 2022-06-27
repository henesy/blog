// https://go.dev/play/p/fU-m8_RYt2n
package main

import (
	"fmt"

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
					// Illustrative, this is O(n²)
					chans = slices.Delete(chans, max(0, i), min(i+1, len(chans)))
				}
				res += square(x)
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
