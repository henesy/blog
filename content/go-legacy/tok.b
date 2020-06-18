implement Tokenizing;

include "sys.m";
	sys: Sys;

include "draw.m";

Tokenizing: module {
	init: fn(nil: ref Draw->Context, nil: list of string);
};

str: con "abc ☺ 'test 1 2 3' !";

init(nil: ref Draw->Context, nil: list of string) {
	sys = load Sys Sys->PATH;

	sys->print("%s\n", str);

	(n, toks) := sys->tokenize(str, "\n\t ");

	for(; toks != nil; toks = tl toks) {
		sys->print("%s\n", hd toks);
	}

	exit;
}
