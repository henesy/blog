implement BouncingBall;

include "sys.m";
	sys: Sys;

include "draw.m";
	draw: Draw;
	Point, Rect, Display, Image, Screen, Context: import draw;

include "tk.m";
	tk: Tk;
include "wmclient.m";
	wmclient: Wmclient;
	Window: import wmclient;

include "daytime.m";
include "rand.m";
	rand: Rand;

include "arg.m";


BouncingBall: module {
	init:	fn(ctxt: ref Context, argv: list of string);
};

NE, NW, SE, SW: con iota;		# Directions ball can move
ZP: con Point(0, 0);			# 0,0 point
delay: con 10;				# ms to draw on

bg: ref Image;				# Window background color
width: int = 600;			# Width of window

lastopt: int;				# To avoid ball getting stuck
bearing: int;				# Starting movement vector of ball
radius: int = 20;			# Radius of ball
BP: Point;					# Point of ball relative to top left corner
ballimg: ref Image;			# Image of ball
ballbg: ref Image;			# Background color to circumscribe

# Draw a bouncing ball on the screen
init(ctxt: ref Context, argv: list of string) {
	sys = load Sys Sys->PATH;

	draw = load Draw Draw->PATH;
	tk = load Tk Tk->PATH;
	wmclient = load Wmclient Wmclient->PATH;

	arg := load Arg Arg->PATH;
	rand = load Rand Rand->PATH;
	time := load Daytime Daytime->PATH;

	rand->init(time->now());

	# Commandline args
	arg->init(argv);
	arg->setusage("bb [-r radius] [-w width]");

	while((c := arg->opt()) != 0)
		case c {
		'r' =>
			radius = int arg->earg();
		'w' =>
			width = int arg->earg();
		* =>
			arg->usage();
		}

	argv = arg->argv();

	# Window setup
	sys->pctl(Sys->NEWPGRP, nil);
	wmclient->init();

	winctxt := ctxt;
	if(winctxt == nil)
		winctxt = wmclient->makedrawcontext();

	display := winctxt.display;

	w := wmclient->window(winctxt, "Bouncing Ball", Wmclient->Appl);

	# Load graphical artifacts
	bg = display.rgb(192, 192, 192);	# 0xC0C0C0FF
	ballbg = display.newimage(Rect(ZP, (radius+2,radius+2)), Draw->RGB24, 1, int 16rC0C0C0FF);	# (192, 192, 192)
	ballimg = display.newimage(Rect(ZP, (radius,radius)), Draw->RGB24, 1, Draw->Red);

	# Make the window appear
	w.reshape(Rect(ZP, (width, width)));

	# Bring the window to focus
	w.onscreen("place");

	# Start receiving input
	w.startinput("kbd" :: "ptr" :: nil);

	# Set initial ball location to above center of window
	# We don't want exact center to avoid cornering ☺
	# Windows are represented as rectangles
	# r.min in this case is top left of a window, r.max bottom right

	r := w.imager(w.image.r);
	offset := r.max.sub(r.min).div(2);
	offset = offset.sub(Point(0, offset.y/2));
	BP = r.min.add(offset);

	# Draw background and ball initially
	w.image.draw(w.image.r, bg, nil, ZP);

	bearing = rand->rand(4);	# 4 bearings

	# Kick off draw timer
	tickchan := chan of int;
	spawn ticker(tickchan);

	for(;;)
		alt {
		ctl := <-w.ctl
		or	ctl = <-w.ctxt.ctl =>
			sys->print("%s\n", ctl);
			w.wmctl(ctl);

			# Handle ctl messages as per wmclient(2)
			if(ctl == "exit")
					exit;

			# Re-draw background
			w.image.draw(w.image.r, bg, nil, ZP);

			# TODO - re-align ball properly, this jumps to middle
			r = w.imager(w.image.r);
			offset = r.max.sub(r.min).div(2);
			offset = offset.sub(Point(0, offset.y/2));
			BP = r.min.add(offset);

			# TODO - update collision borders
			drawball(w);

		p := <-w.ctxt.ptr =>
			w.pointer(*p);

		# Draw on ticks
		<-tickchan =>
			drawball(w);
		}

	exit;
}

# Draw the ball for a frame
drawball(win: ref Wmclient->Window) {
	screen := win.image;
	if(screen == nil)
		return;

	# Draw an ellipse around where we were in the bg color of thickness 2px
	# This smooths the animation
	targ := BP;
	screen.ellipse(targ, radius+2, radius+2, 2, ballbg, ZP);

	# Move circle
	mvball(win, bear(BP));

	# Draw circle
	screen.fillellipse(targ, radius, radius, ballimg, ZP);
}


# Move the ball in reference to screen corner
mvball(win: ref Wmclient->Window, p: Point) {
	screen := win.image;
	if(screen == nil)
		return;

	# Window rectangle
	r := win.imager(win.image.r);

	# Make the rectangle smaller by radius for collision
	r.min.x += radius;
	r.min.y -= radius/3;	# Oh no, is this some π shenanigans?
	r.max.x -= radius;
	r.max.y -= radius;

	# Point.add() means negative values should concatenate just fine
	targ := p;

	# Check if we're within the rectangle
	if(! targ.in(r)) {

		# Randomize a bit
		opt := rand->rand(2);
		if(opt == lastopt);
			opt = !opt;

		# We rotate our direction
		case bearing {
		NE =>
			if(opt)
				bearing = NW;
			else
				bearing = SW;
		NW =>
			if(opt)
				bearing = NE;
			else
				bearing = SE;
		SE =>
			if(opt)
				bearing = SW;
			else
				bearing = NW;
		SW =>
			if(opt)
				bearing = NE;
			else
				bearing = SE;
		}

		lastopt = opt;
		targ = BP;
	}

	BP = targ;
}

# Ticks every delay milliseconds to draw
ticker(tickchan: chan of int) {
	for(;;) {
		sys->sleep(delay);
		tickchan <-= 1;
	}
}

# Apply bearing shifts to the ball
bear(p: Point): Point {
	x := p.x;
	y := p.y;

	case bearing {
		NE =>
			x++;
			y--;
		NW =>
			x--;
			y--;
		SE =>
			x++;
			y++;
		SW =>
			x--;
			y++;
	}

	return Point(x, y);
}
