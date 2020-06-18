implement Select;

include "sys.m";
	sys: Sys;
	print: import sys;

include "draw.m";

Select: module {
	init: fn(nil: ref Draw->Context, nil: list of string);
};

max : con 2;

selector(prodChan: chan of int, recChan: chan of int, n: int) {
	for(;;)
		alt {
		i := <- prodChan =>
			print("case recv	← %d\n", i);

		recChan <-= n =>
			print("case send	→ %d\n", n);

		* =>
			break;
		}
}

producer(n: int, prodChan: chan of int) {
	for(i := 0; i < max; i++){
		print("pushed		→ %d\n", n);
		prodChan <-= n;
	}
}

receiver(recChan: chan of int) {
	for(i := 0; i < max; i++)
		print("received	→ %d\n", <- recChan);
}

init(nil: ref Draw->Context, nil: list of string) {
	sys = load Sys Sys->PATH;

	prodChan	:= chan of int;
	recChan	:= chan of int;

	spawn producer(123, prodChan);
	spawn receiver(recChan);
	spawn selector(prodChan, recChan, 456);

	sys->sleep(1000);

	exit;
}
