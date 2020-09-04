+++
title = "Program development in Limbo"
date = "2020-09-02"
tags = [
	"inferno",
	"limbo",
]
+++

# Program development in Limbo

## Motivation

Resources covering software development under Inferno are fairly scarce.

As such, this post aims to provide a start-to-finish demonstration of program development in Limbo inside Inferno.

## Introduction

This post assumes you're using Inferno, specifically [purgatorio](https://code.9front.org/hg/purgatorio/), hosted under `linux/amd64` or similar.

It's also possible to use Inferno under Docker as per the `INSTALL` file.

Other platforms are supported, but steps may differ here or there.

The rune `$` indicates a unix shell command under `bash`, probably.

The rune `;` or `%` indicates a command to be run from inside Inferno.

The final source from this post: <https://github.com/henesy/socketh-limbo>

This post will be an implementation of [SocketH](https://github.com/henesy/SocketH) which was originally written in Go and has a few other implementations:

- https://github.com/henesy/socketh-myr
- https://github.com/henesy/SocketS

The original code isn't great, but it gives a target for what we want to create.

## Getting started

Many, if not all, of these development steps prior to _running_ the final Dis bytecode can be done from outside of Inferno.

The limbo compiler can be called as `limbo` and with the right workflow development may be more pleasant.

This post assumes:

- Development occurs inside of Inferno for the purpose of consistency
- Some knowledge about imperative, C-like, language programming
- Some knowledge about how unix-like systems work
- Some knowledge about how C-like compiler and linker flows work
- Knowledge about how to interact with a unix-like shell
- Vague knowledge about Inferno, such as the fact Inferno exists ☺

### Build Inferno

Steps provided are targeted for `linux/amd64` as a host for Inferno.

The official [Inferno](https://bitbucket.org/inferno-os/inferno-os/) tree is hosted over [Git](https://git-scm.com/).

The [purgatorio](https://code.9front.org/hg/purgatorio/) fork is hosted by the 9front project over [Mercurial](https://www.mercurial-scm.org/).

Cloning:

```text
$ hg clone https://code.9front.org/hg/purgatorio
destination directory: purgatorio
requesting all changes
adding changesets
adding manifests
adding file changes
added 86 changesets with 10904 changes to 10545 files
new changesets 78950db8e089:749c484c1b9c
updating to branch default
9584 files updated, 0 files merged, 0 files removed, 0 files unresolved
$ cd purgatorio/
$ ls
acme                     FreeBSD  libdynld     libprefab      mkfile       scripts
AIX                      icons    libfreetype  libsec         mkfiles      services
appl                     include  libinterp    libtk          module       Solaris
bitbucket-pipelines.yml  Inferno  libkern      limbo          NetBSD       tools
CHANGES                  INSTALL  libkeyring   Linux          NOTICE       usr
dis                      Irix     liblogfs     locale         Nt           utils
doc                      keydb    libmath      MacOSX         OpenBSD
Dockerfile               lib      libmemdraw   makemk-AIX.sh  os
DragonFly                lib9     libmemlayer  makemk.sh      Plan9
emu                      libbio   libmp        man            POSTINSTALL
fonts                    libdraw  libnandfs    mkconfig       README.md
$
```

**Read the** `INSTALL` **file!**

Update our `$HOME/.profile` to reflect the Inferno install, adapt this to your directories:

```text
export EMU='-g1280x960 -c1'
export INFERNO=$HOME/repos/purgatorio
export PATH=$PATH:$INFERNO/Linux/386/bin
```

Reload our shell currently in the purgatorio root tree:

```text
$ source $HOME/.profile
$
```

Update the `mkconfig` file to reflect our environment, adapt this as needed:

```text
ROOT=$HOME/repos/purgatorio

TKSTYLE=std

CONF=emu

SYSHOST=Linux		# build system OS type (Hp, Inferno, Irix, Linux, MacOSX, Nt, Plan9, Solaris)
SYSTARG=$SYSHOST	# target system OS type (Hp, Inferno, Irix, Linux, Nt, Plan9, Solaris)

OBJTYPE=386

OBJDIR=$SYSTARG/$OBJTYPE

<$ROOT/mkfiles/mkhost-$SYSHOST			# variables appropriate for host system
<$ROOT/mkfiles/mkfile-$SYSTARG-$OBJTYPE	# variables used to build target object type
```

Enable multi-arch support on debian-based distributions if on amd64 (64-bit) as Inferno is 32-bit only:

```text
$ dpkg --add-architecture i386
$ apt-get update
```

Install dependencies required to compile Inferno, this example shows dependencies for debian-based (Ubuntu) distributions:

```text
$ apt install libc6-dev-i386 libxext6:i386 libx11-dev:i386 libxext-dev:i386 libfontconfig1-dev:i386
…
$
```

Build `mk` which will be used to bootstrap the rest of the process:

```text
$ ./makemk.sh
…
$
```

Build and install Inferno!

```text
$ mk mkdirs
…
$ mk clean
…
$ mk install
…
$
```

### Start Inferno

```text
$ emu
; wm/wm
…
```

A graphical environment should appear.

You can make the gui window for Inferno larger by passing in a different size to `emu` as per [the manual](http://man.postnix.pw/purgatorio/1/emu):

```text
-gXsizexYsize
	Define screen width and height in pixels.  The default
	values are 640x480 and the minimum values are 64x48.
	Values smaller than the minimum or greater than the
	available display size are ignored.
```

thus:

```text
$ emu -g1280x960
; wm/wm
```

and so forth.

Some programs can be found under the start menu in the bottom left corner decorated with the [Vita Nuova](vitanuova.com/) logo:

![Vita Nuova's logo](http://www.vitanuova.com/images/vitanuova.jpg)

The `Shell` entry in the start menu will provide a shell-interpreter window from which further commands can be run inside Inferno. 

### Preparation

```text
% cd $home/appl
% os git clone https://github.com/henesy/socketh-limbo
% cd socketh-limbo
% lc
.git/     LICENSE   README.md
% touch .gitignore socketh.b
% acme socketh.b
```

`.gitignore`:

```text
*.sbl
*.dis
```

Limbo 'libraries', known as 'modules', and 'programs' are one and the same in terms of semantics, bar 'libraries' having module `.m` files which are similar to header `.h` files in C.

As such, the boilerplate for most Limbo programs is very similar. We can initialize our main file as follows.

`socketh.b`:

```c
implement SocketH;

include "sys.m";
	sys: Sys;

include "draw.m";
include "arg.m";

SocketH: module {
	init: fn(nil: ref Draw->Context, argv: list of string);
};


# An implementation of the SocketH chat protocol
init(nil: ref Draw->Context, argv: list of string) {
	sys = load Sys Sys->PATH;
	arg := load Arg Arg->PATH;
	if(arg == nil)
		raise "could not load arg";



	exit;
}
```

We can break this down a bit.

`implement` declares a module by name.

A module definition must be provided indicating exported functions from the module:

```text
SocketH: module {
	init: fn(nil: ref Draw->Context, argv: list of string);
};
```

Note how a variable name of `nil` is used to drop assignment of a value.

The `init` function is special in shell-loaded Limbo programs and its signature _must_ match what the shell expects the init function interface to be.

Functionally, `init` is equivalent to `main` in most other languages.

`include` imports an external module's definitions into our scope.

`load` performs the dynamic loading of a module at runtime.

`exit` performs the dynamic un-loading of a module at runtime.

`raise` will throw an exception with a given string as its content.

We refer to names inside a module using the `->` operator.

We can jointly assign and declare in one step using the `:=` operator.

Curly braces are optional.

Semicolons are not.

Note the absence of a reserved `main` module. This is due to each `.dis` file, potentially an independent module, being theoretically loadable in its own right. A reserved name would cause significant issues with namespaces ☺.

### Setting up a workflow

Compiling our program should be as straightforward as running the Limbo compiler against our source file:

```text
% limbo socketh.b
% lc
.git/		LICENSE		socketh.b
.gitignore	README.md	socketh.dis
% socketh.dis
%
```

This program does nothing right now, but that's fine.

Note how we can omit the `./` when running `.dis` programs.

Calling the limbo compiler each time is a bit of a pain, and if we start using commandline flags this will become tedious to type.

In acme, we could type the text we want to run in a tag or window and middle-click said text to run the compilation (or more!) on-demand. In Inferno, acme comes with a `Limbo` command in the default window tag, but that only works for one file.

We can simplify this process by writing a <s>makefile</s> [mkfile](http://doc.cat-v.org/bell_labs/mk/)!

`mkfile`:

```text
</mkconfig

DISBIN = /dis

TARG = socketh.dis

</mkfiles/mkdis
```

Mk semantics are similar to make with some changes.

How mk will behave inside Inferno using the `mkdis` mkfile as the trailing import:

- Mk can import outside mkfiles using the `<` operator
- `mk` will call `mk all` which resolves to the `all` (default) target
- `mk install` calls the `all` target and copies the `TARG` file(s) to the `DISBIN` destination directory
- `mk clean` removes files such as `.dis` and `.sbl` from the working directory
- `mk nuke` calls the `clean` target as well as delete the 'target' files such as the `/dis/socketh` binary if the `install` target has been called

A demonstration:

```text
% lc
.git/		LICENSE		mkfile
.gitignore	README.md	socketh.b
% mk
limbo -I/module -gw socketh.b
socketh.b:15: warning: argument argv not referenced
% lc
.git/		LICENSE		mkfile		socketh.dis
.gitignore	README.md	socketh.b	socketh.sbl
% mk install
rm -f /dis/socketh.dis && cp socketh.dis /dis/socketh.dis
% mk clean
rm -f *.dis *.sbl
% whatis socketh
/dis/socketh.dis
% mk nuke
rm -f *.dis *.sbl
cd /dis; rm -f socketh.dis
% whatis socketh.dis
socketh.dis: not found
% lc
.git/		LICENSE		mkfile
.gitignore	README.md	socketh.b
%
```

Note the Limbo compiler flags being passed by default now for the `all` target.

At this point, I usually add `mk clean && mk` to my acme tag and run that for multi-file or more complex Limbo programs. This flow is very similar to how I do development under Plan 9.

### Common patterns

#### Commandline flags

We can use [arg(2)](man.postnix.pw/purgatorio/2/arg) to process commandline flags:

```c
…

chatty: int	= 0;	# Verbose debug output


# An implementation of the SocketH chat protocol
init(nil: ref Draw->Context, argv: list of string) {
	sys = load Sys Sys->PATH;
	arg := load Arg Arg->PATH;
	if(arg == nil)
		raise "could not load arg";

	addr: string = "tcp!*!9090";

	arg->init(argv);
	arg->setusage("socketh [-D] [-a addr]");

	while((c := arg->opt()) != 0)
		case c {
		'D' =>
			chatty++;

		'a' =>
			addr = arg->earg();

		* =>
			arg->usage();
		}

	argv = arg->argv();



	exit;
}
```

We can see how these flags are parsed and how these functions act:

```text
% mk
mk: 'all' is up to date
% socketh -h
usage: socketh [-D] [-a addr]
% socketh -D
% socketh -a
usage: socketh [-D] [-a addr]
% socketh -a -D
% socketh -D -a
usage: socketh [-D] [-a addr]
% socketh -a tcp!*!9191
% socketh
%
```

Note how if an arugment is not passed to `earg()`, the function implicitly calls `usage()`.

#### Network listening

Leveraging [dial(2)](http://man.postnix.pw/purgatorio/2/dial), we can establish a basic TCP network listen-accept-handle flow.

An example of expanding the prior main file to include an endless echo-listener:

```c
implement SocketH;

include "sys.m";
	sys: Sys;

include "draw.m";
include "arg.m";

include "dial.m";
	dial: Dial;

SocketH: module {
	init: fn(nil: ref Draw->Context, argv: list of string);
};


maxmsg:		con int		256;	# Max message size in bytes
maxconns:	con int 	100;	# Max clients
maxusrname:	con int		25;		# Max username length

stderr:		ref sys->FD;		# Stderr shortcut
chatty: int	= 0;	# Verbose debug output


# An implementation of the SocketH chat protocol
init(nil: ref Draw->Context, argv: list of string) {
	sys = load Sys Sys->PATH;
	arg := load Arg Arg->PATH;
	if(arg == nil)
		raise "could not load arg";
	dial = load Dial Dial->PATH;
	if(dial == nil)
		raise "could not load dial";

	stderr = sys->fildes(2);
	addr: string = "tcp!*!9090";

	# Commandline flags

	arg->init(argv);
	arg->setusage("socketh [-D] [-a addr]");

	while((c := arg->opt()) != 0)
		case c {
		'D' =>
			chatty++;

		'a' =>
			addr = arg->earg();

		* =>
			arg->usage();
		}

	argv = arg->argv();

	# Network listening

	ac := dial->announce(addr);
	if(ac == nil){
		err := sys->sprint("err: could not announce - %r");
		raise err;
	}

	for(;;){
		listener := dial->listen(ac);
		if(listener == nil){
			err := sys->sprint("err: could not listen - %r");
			raise err;
		}

		conn := dial->accept(listener);
		if(conn == nil){
			err := sys->sprint("err: could not accept - %r");
			raise err;
		}

		spawn handler(conn);
	}

	exit;
}

# Handle a connection
handler(conn: ref Sys->FD) {
	buf := array[maxmsg] of byte;

	loop:
	for(;;){
		n := sys->read(conn, buf, len buf);

		# EOF
		if(n == 0) {
			break loop;
		}

		# Error
		if(n < 0) {
			sys->fprint(stderr, "fail: connection ended - %r");
			break loop;
		}

		sys->write(conn, buf, n);

		sys->sleep(5);
	}
}
```

## Debugging

### Dealing with hung processes and networks

Killing the main process for a module may be sufficient for resetting many programs, this can be done by calling `kill` with the module's name:

```text
% kill SocketH
417
%
```

Thus, printing the PID of the killed process.

If you ever have a dangling dial/listening process that needs killed, we can find the program's PID and kill it as so:

```text
% grep -i tcp /prog/*/fd
/prog/177/fd:   4 rw I    0 (0000000000020008 0 00)     0       14 /net/tcp/clone
% kill 177
%
```

and from the listening program's window we'll see:

```text
% socketh
sh: 177 "Dial":killed
%
```

The above technique works because we know that our listener will be listening on TCP and thus must have a file descriptor open to the `tcp` filesystem under the `/net` server.

We can verify the kernel device name for the `/net` server via:

```text
% pid = ${pid}; grep '\/net' /prog/$pid/ns | grep '#'
bind -a #I /net
bind -b #scs /net
bind -b #sdns /net
%
```

We can verify that `#I` is the file server for networks against the kernel's list of currently loaded drivers exposed at `/dev/drivers`:

```text
% grep '#I' /dev/drivers
#I ip
% lc '#I'/tcp
0/    1/    clone stats
% lc /net/tcp
0/    1/    clone stats
%
```

You can explicitly disconnect hung TCP connections using the [ip(3)](http://man.postnix.pw/purgatorio/3/ip) file system interface:

```text
% grep 9090 /net/tcp/*/local
/net/tcp/0/local: ::!9090
/net/tcp/1/local: 127.0.0.1!9090
% echo hangup > /net/tcp/1/ctl		# Disconnects the client
% echo hangup > /net/tcp/0/ctl		# Disconnects the server
%
```

from the main process window, due to closing the `::!9090` file:

```text
% socketh
sh: 441 "SocketH":err: could not listen - listen opening /net/tcp/0/listen: Invalid argument
%
```

Neat!

### Dealing with compiler warnings/errors

An example of some output that can be generated during development:

```text
% mk
limbo -I/module -gw socketh.b
socketh.b:136: warning: local username not referenced
% mk
mk: 'all' is up to date
% mk
mk: 'all' is up to date
% mk
limbo -I/module -gw socketh.b
socketh.b:141: near ` : ` : syntax error
mk: limbo -I/module -gw socketh.b : exit status=1006 "Sh":fail:errors
% mk
limbo -I/module -gw socketh.b
socketh.b:139: cannot receive on 'sprint("→ %s", username)' of type string
mk: limbo -I/module -gw socketh.b : exit status=1010 "Sh":fail:errors
% mk
limbo -I/module -gw socketh.b
%
```

Note how the errors are in the Plan 9-ish form of `file`:`line`: `message`.

Acme is able jump-to-line for this error format via right-click on the text as the string is a [plumb(1)](http://man.postnix.pw/purgatorio/1/plumb)-compatible form.

Warnings are explicitly denoted with `warning:` while errors are otherwise implied by the `file`:`line` combination.

Some errors are more explicit than others, syntax errors may take some thought and are probably the result of a forgotten rune, such as one of `)'(;}"{`.

Some errors are less intuitive.

The error `cannot receive on` is explicitly regarding a channel type and was the result of me typing `=<-` rather than `<-=` for passing the result of `sprint()` into a channel of strings.

## Closure

### Flushing out the program

A server that echoes its input is nice, but we're reimplementing an existing system, so let's finish that.

The final main file:

```c
implement SocketH;

include "sys.m";
	sys: Sys;

include "dial.m";
	dial: Dial;

include "draw.m";
include "arg.m";

SocketH: module {
	init: fn(nil: ref Draw->Context, argv: list of string);
};


maxmsg:		con int			256;	# Max message size in bytes
maxconns:	con int 		100;	# Max clients
maxusrname:	con int			25;		# Max username length
maxbuf:		con int			8;		# Max channel buffer size
stderr:		ref sys->FD;			# Stderr shortcut

chatty:		int				= 0;	# Verbose debug output
broadcast:	chan of string;			# Input for message broadcast
pool:		chan of ref Sys->FD;	# Input for adding connections


# An implementation of the SocketH chat protocol
init(nil: ref Draw->Context, argv: list of string) {
	sys = load Sys Sys->PATH;
	arg := load Arg Arg->PATH;
	if(arg == nil)
		raise "could not load arg";
	dial = load Dial Dial->PATH;
	if(dial == nil)
		raise "could not load dial";

	stderr = sys->fildes(2);

	broadcast = chan[maxbuf] of string;
	pool = chan[maxbuf] of ref Sys->FD;

	addr: string = "tcp!*!9090";

	# Commandline flags

	arg->init(argv);
	arg->setusage("socketh [-D] [-a addr]");

	while((c := arg->opt()) != 0)
		case c {
		'D' =>
			chatty++;

		'a' =>
			addr = arg->earg();

		* =>
			arg->usage();
		}

	argv = arg->argv();

	# Network listening

	spawn manager();

	ac := dial->announce(addr);
	if(ac == nil){
		err := sys->sprint("err: could not announce - %r");
		raise err;
	}

	for(;;){
		listener := dial->listen(ac);
		if(listener == nil){
			err := sys->sprint("err: could not listen - %r");
			raise err;
		}

		conn := dial->accept(listener);
		if(conn == nil){
			err := sys->sprint("err: could not accept - %r");
			raise err;
		}

		spawn handler(conn);
	}

	exit;
}

# Manage connections and messages
manager() {
	conns := array[maxconns] of ref Sys->FD;

	loop:
	for(;;)
		alt{
			fd := <- pool =>
				# Add a new connection
				for(i := 0; i < len conns; i++) {
					if(conns[i] != nil)
						continue;

					conns[i] = fd;
					continue loop;
				}

				sys->fprint(stderr, "fail: max conns reached");

			msg := <- broadcast =>
				msg += "\n";
				sys->print("%s", string msg);

				# Incoming message to chat
				for(i := 0; i < len conns; i++) {
					if(conns[i] == nil)
						continue;

					buf := array of byte msg;

					sys->write(conns[i], buf, len buf);
				}

			* =>
				sys->sleep(5);
		}
}

# Handle a connection
handler(conn: ref Sys->FD) {
	sprint: import sys;
	namebuf := array[maxmsg] of byte;
	s := array of byte "What is your username?: ";

	sys->write(conn, s, len s);
	n := sys->read(conn, namebuf, len namebuf);

	username := minimize(string namebuf[:n]);

	broadcast <-= sprint("→ %s", username);

	pool <-= conn;

	loop:
	for(;;){
		buf := array[maxmsg] of byte;
		n = sys->read(conn, buf, len buf);
		msg := minimize(string buf[:n]);

		# EOF
		if(n == 0){
			break loop;
		}

		# Error
		if(n < 0){
			sys->fprint(stderr, "fail: connection ended - %r");
			break loop;
		}

		case msg {
		"!quit" =>
			break loop;

		* =>
			broadcast <-= sprint("%s → %s", username, msg);
		}

		sys->sleep(1);
	}

	broadcast <-= sprint("← %s", username);
}

# Truncate up to and not including {\n \r}
minimize(s: string): string {
	for(i := 0; i < len s; i++)
		if(s[i] == '\n' || s[i] == '\r')
			break;

	return s[:i];
}

```

We have a few new keywords:

`import` allows us to explicitly import a given name into our module's namespace from another module's namespace as a first-class name.

`break TAG` and `continue TAG` allow us to break/continue to a given tag allowing ease of control flow in more complex logical hierarchies.

The `<-` operator combined with a `=` potentially on one side or the other allows operations over channels to send/receive depending on the context.

The `alt` structure allows C-alike `switch` structure behavior over channels for sending/receiving depending on context.

Slicing over an array using the `[:n]` syntax which is logically similar to Go's slicing syntax of `[from:before]` where the resultant slice is mathematically denoted as the set contents `[from, before)`.

Function declarations have a return type as their type denoted with a colon as per:

```text
minimize(s: string): string {
…
}
```

The `case` structure allows behavior much like the C-alike `switch` structure with limited pattern matching available.

### Installing and finishing up

To wrap up, we'll install and commit the work we've done.

```text
% mk
limbo -I/module -gw socketh.b
% mk install
rm -f /dis/socketh.dis && cp socketh.dis /dis/socketh.dis
% whatis socketh
/dis/socketh.dis
% socketh -h
usage: socketh [-D] [-a addr]
%
```

From unix terminals on the host machine:

```text
$ telnet localhost 9090
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
What is your username?: sean
hello
sean → hello
→ ana
ana → hi! ☺
ahoy!
sean → ahoy!
!quit
← sean
← ana
^]
telnet> q
Connection closed.
$
```

and

```text
$ telnet localhost 9090
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
What is your username?: ana
hi! ☺
ana → hi! ☺
sean → ahoy!
← sean
!quit
← ana
^]
telnet> q
Connection closed.
$
```

with the server output being:

```text
% socketh
→ sean
sean → hello
→ ana
ana → hi! ☺
sean → ahoy!
← sean
← ana
```

At this point, there's lots of expansion that could be done, but this program is more or less complete as a chat server compatible with the original SocketH clients.

## Further reading

- [Limbo by Example](https://github.com/henesy/limbobyexample)
- [Awesome Inferno resources](https://github.com/henesy/awesome-inferno)
- [Pete's blog series](http://debu.gs/entries/the-inferno-operating-system-you-re-soaking-in-it)
- [Inferno programmer's notebook](http://ipn.caerwyn.com/) also at <https://github.com/caerwynj/inferno-lab/>
- [Plan 9 archive of Inferno/Limbo software](https://github.com/search?q=org%3APlan9-Archive+limbo+OR+inferno&type=Repositories)
- [Inferno Programming with Limbo](http://doc.cat-v.org/inferno/books/inferno_programming_with_limbo/)
- [A Descent into Limbo](http://doc.cat-v.org/inferno/4th_edition/limbo_language/descent)
- [The Limbo Programming Language](http://doc.cat-v.org/inferno/4th_edition/limbo_language/limbo) and [Addendum](http://doc.cat-v.org/inferno/4th_edition/limbo_language/addendum)
