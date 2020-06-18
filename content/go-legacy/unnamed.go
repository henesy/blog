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
}
