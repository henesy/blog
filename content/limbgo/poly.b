implement Poly;

include "sys.m";
	sys: Sys;

include "draw.m";

Poly: module {
	init: fn(nil: ref Draw->Context, nil: list of string);
};


Integer: type ref Integral;

Integral: adt {
	n: int;
	Equals:		fn(a, b: ref Integral): int;
	String:		fn(x: self ref Integral): string;
};

Integral.Equals(a, b: ref Integral): int {
	return a.n == b.n;
}

Integral.String(x: self ref Integral): string {
	return sys->sprint("%d", x.n);
}

double(x: Integer): Integer {
	return Integer(2 * x.n);
}

square(x: Integer): Integer {
	return Integer(x.n ** 2);
}

isfourable(x: Integer): int {
	return x.n % 4 == 0;
}


init(nil: ref Draw->Context, nil: list of string) {
	sys = load Sys Sys->PATH;

	i: int;
	a₀ := array[6] of Integer;

	for(i = 0; i < len a₀; i++)
		a₀[i] = Integer(i ** 2);

	aprint(a₀);

	aprint(map(double, a₀));

	aprint(filter(isfourable, a₀));

	a₁ := pair(map(double, a₀), map(square, a₀));

	sys->print("[");
	for(i = 0; i < len a₁; i++){
		(x₀, x₁) := a₁[i];
		sys->print("(%d, %d) ", x₀.n, x₁.n);
	}
	sys->print("]\n");

	aprint(find(Integer(16), a₀));

	aprint(prepend(Integer(9), a₀));

	aprint(append(Integer(99), a₀));

	aprint(tail(a₀));
}

filter[T](p: ref fn(x: T): int, a: array of T): array of T {
	if(a == nil)
		return nil;

	if(p(a[0]))
		return prepend(a[0], filter(p, tail(a)));

	if(len a < 2)
		return nil;

	return filter(p, tail(a));
}

map[T](f: ref fn(x: T): T, a₀: array of T): array of T {
	if(a₀ == nil)
		return nil;

	a₁ := array[len a₀] of T;

	for(i := 0; i < len a₀; i++)
		a₁[i] = f(a₀[i]);

	return a₁;
}

pair[T₁, T₂](a₁: array of T₁, a₂: array of T₂): array of (T₁, T₂) {
	if(a₁ == nil || a₂ == nil || len a₁ != len a₂)
		return nil;

	a₃ := array[len a₁] of (T₁, T₂);

	for(i := 0; i < len a₁; i++)
		a₃[i] = (a₁[i], a₂[i]);

	return a₃;
}

# find instance of x in l, return tail of l from x
find[T](x: T, a: array of T): array of T
	for {
		T =>	Equals:	fn(a, b: T): int;
	}
{
	for(i := 0; i < len a; i++)
		if(T.Equals(x, a[i]))
			return tail(a[i:]);

	return nil;
}

prepend[T](x: T, a₀: array of T): array of T {
	if(a₀ == nil)
		return array[1] of { * => x };

	a₁ := array[len a₀ + 1] of T;
	a₁[0] = x;

	for(i := 1; i < len a₁; i++)
		a₁[i] = a₀[i-1];

	return a₁;
}

append[T](x: T, a₀: array of T): array of T {
	if(a₀ == nil)
		return array[1] of { * => x };

	a₁ := array[len a₀ + 1] of T;
	a₁[len a₁ - 1] = x;

	for(i := 0; i < len a₁ -1; i++)
		a₁[i] = a₀[i];

	return a₁;
}

tail[T](a: array of T): array of T {
	if(a == nil || len a < 2)
		return nil;

	return a[1:];
}

aprint[T](a: array of T)
	for {
		T =>	String:	fn(a: self T): string;
	}
{
	if(a == nil) {
		sys->print("[]\n");
		return;
	}

	sys->print("[");

	for(i := 0; i < len a; i++) {
		sys->print("%s", a[i].String());

		if(i < len a - 1)
			sys->print(", ");
	}

	sys->print("]\n");

}
