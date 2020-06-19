#include <u.h>
#include <libc.h>

double π = 3.14;

typedef struct Point Point;
typedef struct Circle Circle;
typedef struct Number Number;
typedef struct Value Value;

struct Number {
	union {
		double dval;
		float  fval;
		long   lval;
	};
};

struct Value {
	Number;
};

struct Point {
	int	x;
	int	y;
};

struct Circle {
	Point;
	int	radius;
};

Point
mirror(Point p)
{
	return (Point) {-1 * p.x, -1 * p.y};
}

void
main(int, char*[])
{
	Point p₀ = {.x = 3, .y = -1};

	Circle c = {p₀, 12};

	Point p₁ = c.Point;

	print("p₀ = (%d,%d)\nradius = %d\n", c.x, c.y, c.radius);
	print("p₁ = (%d,%d)\n", p₁.x, p₁.y);

	Point p₂ = mirror((Point){c.x, c.y});

	print("p₂ = (%d,%d)\n", p₂.x, p₂.y);

	Value v = {π};

	print("value = %f\nd = %p\nf = %p\nl = %p\n",
				v.dval, &v.dval, &v.fval, &v.lval);

	exits(nil);
}
