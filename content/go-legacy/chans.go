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

