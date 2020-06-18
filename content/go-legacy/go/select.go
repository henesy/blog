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

