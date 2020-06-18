implement BreakContinueTag;

include "sys.m";
	sys: Sys;

include "draw.m";

BreakContinueTag: module {
	init: fn(nil: ref Draw->Context, nil: list of string);
};

init(nil: ref Draw->Context, nil: list of string) {
	sys = load Sys Sys->PATH;

	i := 0;

	loop:
	for(;;){
		i++;
		case i {
		11 =>
			break loop;
		* =>
			if(i % 2 == 0)
				continue loop;
		}

		sys->print("%d\n", i);
	}

	exit;
}
