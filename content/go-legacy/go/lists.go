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
