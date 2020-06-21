#include <alef.h>

aggr Point {
	int x;
	int y;
};

aggr Line {
	Point p1;
	Point p2;
};

aggr Circle {
	Point;
	int radius;
};

aggr Shape {
	int type;
	union {
		Circle;
		Line;
	};
};

adt Person {
extern	int age;
extern	void ageup(*Person, int);
extern	Person init();
};

adt Worker {
extern	Person;
extern	byte *position;
extern	Worker init(Person);
};

Worker
Worker.init(Person p)
{
	Worker w;

	w.position = "none";
	w.Person = p;

	return w;
}

void
Person.ageup(Person *p, int n)
{
	p->age += n;
}

Person
Person.init()
{
	Person p;

	p.age = 1;

	return p;
}

int equal(Point p1, Point p2)
{
	return p1.x == p2.x && p1.y == p2.y;
}

Point
mirror(Point p)
{
	p.x *= -1;
	p.y *= -1;
	return p;
}

void
main(void)
{
	Point p0, p1;
	Circle c;
	Shape s;
	Line l;
	Person sean, ana;
	Worker engineer;

	p0 = (Point)(3, -1);

	c.Point = p0;
	p0 = c;

	p1 = mirror(c);

	if(equal(p0, c))
		print("p0 = c\n");
	else
		print("p0 ≠ c\n");

	print("c's point = (%d,%d)\n", c.x, c.y);

	print("p1 = (%d,%d)\n", p1.x, p1.y);

	l = (Line)(p0, p1);

	s.Line = l;
	s.type = 0;	/* a line */

	if(s.type == 0)
		print("Shape is line (%d,%d) → (%d,%d)\n, s.p1.x, s.p1.y, s.p2.x, s.p2.y);

	sean = .Person.init();
	engineer = .Worker.init(sean);

	engineer.ageup(2);

	print("engineer position \"%s\" is %d years old\n",
			engineer.position, engineer.age);

	ana = engineer;

	print("ana age = %d\n", ana.age);
}