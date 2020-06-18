implement Channels;

include "sys.m";
	sys: Sys;

include "draw.m";

Channels: module {
	init: fn(nil: ref Draw->Context, nil: list of string);
};

max : con 10;

printer(c: chan of int) {
	i : int;
	for(i = 0; i < max; i++){
		n := <- c;
		sys->print("%d ", n);
	}
	sys->print("\n");
}

pusher(c: chan of int) {
	i : int;
	for(i = 0; i < max; i++){
		c <-= i * i;
	}
}

init(nil: ref Draw->Context, nil: list of string) {
	sys = load Sys Sys->PATH;

	printChan := chan of int;

	spawn printer(printChan);
	spawn pusher(printChan);

	sys->sleep(1);

	exit;
}
