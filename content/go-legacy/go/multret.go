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

