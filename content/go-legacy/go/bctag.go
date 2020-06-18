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

