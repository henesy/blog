implement MultRet;

include "sys.m";
	sys: Sys;

include "draw.m";

MultRet: module {
	init: fn(nil: ref Draw->Context, nil: list of string);
};

swap(a, b: int): (int, int) {
	return (b, a);
}

init(nil: ref Draw->Context, nil: list of string) {
	sys = load Sys Sys->PATH;

	(x, y) := swap(3, 7);

	sys->print("3, 7 → %d, %d\n", x, y);

	exit;
}
