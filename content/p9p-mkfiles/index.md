+++
title = "Using Plan9Port Mkfiles"
date = "2018-03-03"
tags = [
	"p9p",
]
+++

# Using Plan9Port Mkfiles

Recently I decided to play with the idea of porting Nemo's semfs (from Ch13 of his book) to \*nix as a learning exercise.

As a goal I wanted to change as little of the original code as possible. Even with the plan9port 9c/9l bindings however, some portions of the source (unnamed struct members, mostly) did not build and required changing.

A notable point of change was the mkfile for semfs, originally using the mkone file, I needed to find the equivalent mkfile in plan9port.

The original mkfile looked something like this:

```text
</$objtype/mkfile

TARG = semfs

OFILES = \
	sem.$O \
	semfs.$O

HFILES = \
	sem.h

BIN = $home/bin/$objtype

</sys/src/cmd/mkone
```

After a bit of digging, a suitable replacement was found in plan9port:

```text
<$PLAN9/src/mkhdr

TARG = semfs

OFILES = \
	sem.$O \
	semfs.$O

HFILES = \
	sem.h

BIN = $home/bin/$objtype

<$PLAN9/src/mkone
```

Assuming that a functional plan9port install exists and $PLAN9 is set to the root of said install, the mkfile works exactly as one would expect. Pleasantly, the nature of the mkhdr file means that the output binary will be named o.\* in a similar pattern to the 6.out or 8.out style produced by the Plan 9 C compilers. 

