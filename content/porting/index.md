+++
title = "Porting Unix Software to Plan9"
date = "2020-02-01"
tags = [
	"plan9",
	"porting",
]
+++

# Porting Unix Software to Plan9

The original source code used in this port: <https://github.com/rswier/c4>. 

The final port source code for the port: <https://github.com/henesy/c4>.

The commits for the port starting from my history should vaguely reflect the order and rough increment of changes described in this post. It is recommended to skim the source and changes while reading ☺.

## Initial reading

- [C Programming in Plan 9](http://doc.cat-v.org/plan_9/programming/c_programming_in_plan_9)

## Porting

This post will show the process of porting a unix program, c4, to plan9. Specifically, this will target 9front/amd64. 

The goal is to have the program operate as expected and compile with as few warnings as possible under kencc as per [2c(1)](http://man.cat-v.org/9front/1/2c) and [2l(1)](http://man.cat-v.org/9front/1/2l). No portion of the ANSI/POSIX Environment (APE) should be used. 

Prior knowledge of C, at least C89, is assumed under a posix or unix context. 

Assertions are made in the context of plan9's C dialect.

### First steps

Scrap **all** of the `#include`'d headers, if plan9 uses them, we'll figure them out later.

The two main headers we'll use are `u.h` which contains platform-specific types, etc. and `libc.h` which contains the core of the plan9 libc functions, etc. 

```c
// Written by Robert Swierczek

#include <u.h>
#include <libc.h>
#define int long long

char *p, *lp, // current position
```

Create a mkfile, this will speed up our development process. 

```text
</$objtype/mkfile

BIN = $home/bin/$objtype

TARG = c4

OFILES = c4.$O \

</sys/src/cmd/mkone
```

Just to be safe, we'll make a .gitignore as well:

```text
*.[8qkv5967o]
[8qkv5967o].out
```

Since plan9 uses a split compiler and linker, we'll get from c4.c: `c4.6` and `6.c4`. In this pattern, the `*.6` file is the post-compilation file to be linked and the `6.*` file is the linked [a.out(6)](http://man.cat-v.org/9front/6/a.out) executable. 

When we compile, we get:

```text
tenshi% mk
6c -FTVw c4.c
c4.c:53 function not declared: printf
c4.c:56 function not declared: printf
c4.c:59 function not declared: printf
c4.c:59 function not declared: printf
c4.c:135 function not declared: printf
c4.c:135 function not declared: exit
c4.c:136 function not declared: next
c4.c:138 function not declared: next
c4.c:139 function not declared: next
c4.c:143 function not declared: next
c4.c:143 function not declared: next
too many errors
mk: 6c -FTVw c4.c  : exit status=rc 566432: 6c 566434: error
tenshi% 
```

## Function declarations

Functions which take no arguments, must be declared with `myfunc(void)` as the function signature.

We can get ride of all the `function not declared: next` errors by changing the declaration to:

```c
// identifier offsets (since we can't create an ident struct)
enum { Tk, Hash, Name, Class, Type, Val, HClass, HType, HVal, Idsz };

void next(void)
{
  char *pp;
```

Compiling:

```text
tenshi% mk
6c -FTVw c4.c
c4.c:53 function not declared: printf
c4.c:56 function not declared: printf
c4.c:59 function not declared: printf
c4.c:59 function not declared: printf
c4.c:135 function not declared: printf
c4.c:135 function not declared: exit
c4.c:143 function not declared: printf
c4.c:143 function not declared: exit
c4.c:146 function not declared: printf
c4.c:146 function not declared: exit
c4.c:159 function not declared: printf
too many errors
mk: 6c -FTVw c4.c  : exit status=rc 567394: 6c 567396: error
tenshi% 
```

### Exit status

When a program exits, it leaves behind a string, rather than an integer. Note that all strings in plan9's C dialect are presumed to be utf-8 by default. 

As such, we call [exits(2)](http://man.cat-v.org/9front/2/exits) instead of the posix exit(). 

We probably want to update these names manually, as it gives us the chance to create more articulate statuses.

Additionally, we probably want to use [sysfatal(2)](http://man.cat-v.org/9front/2/perror) rather than [exits(2)](http://man.cat-v.org/9front/2/exits) for errors, as [sysfatal(2)](http://man.cat-v.org/9front/2/perror) prints a message to stderr as well as sets the exit string. 

Example:

```c
void expr(int lev)
{
  int t, *d;

  if (!tk) { sysfatal("%lld: unexpected eof in expression\n", line); }
  else if (tk == Num) { *++e = IMM; *++e = ival; next(); ty = INT; }
  else if (tk == '"') {
```

Compiling:

```text
tenshi% mk
6c -FTVw c4.c
c4.c:53 function not declared: printf
c4.c:56 function not declared: printf
c4.c:59 function not declared: printf
c4.c:59 function not declared: printf
c4.c:291 function not declared: stmt
c4.c:295 function not declared: stmt
c4.c:306 function not declared: stmt
c4.c:318 function not declared: stmt
c4.c:339 function not declared: printf
c4.c:341 function not declared: printf
c4.c:344 function not declared: printf
too many errors
mk: 6c -FTVw c4.c  : exit status=rc 567790: 6c 567792: error
tenshi% 
```

### Print commands

The `*f` functions exist similarly in name, dropping the `f`. For example, printf() becomes print(). 

In acme we can correct these names via:

	Edit ,s/printf/print/g

Compiling:

```text
tenshi% mk
6c -FTVw c4.c
warning: c4.c:53 format mismatch d VLONG, arg 2
warning: c4.c:53 format mismatch '*' in .*s VLONG, arg 3
warning: c4.c:59 format mismatch d VLONG, arg 2
c4.c:291 function not declared: stmt
c4.c:295 function not declared: stmt
c4.c:306 function not declared: stmt
c4.c:318 function not declared: stmt
warning: c4.c:344 format mismatch d VLONG, arg 2
warning: c4.c:345 format mismatch d VLONG, arg 2
warning: c4.c:346 format mismatch d VLONG, arg 2
warning: c4.c:347 format mismatch d VLONG, arg 2
warning: c4.c:360 format mismatch d VLONG, arg 2
warning: c4.c:361 format mismatch d VLONG, arg 2
warning: c4.c:379 format mismatch d VLONG, arg 2
warning: c4.c:379 format mismatch d VLONG, arg 3
warning: c4.c:383 format mismatch d VLONG, arg 2
warning: c4.c:396 format mismatch d VLONG, arg 2
warning: c4.c:397 format mismatch d VLONG, arg 2
warning: c4.c:409 format mismatch d VLONG, arg 2
warning: c4.c:410 format mismatch d VLONG, arg 2
warning: c4.c:418 format mismatch d VLONG, arg 2
warning: c4.c:427 format mismatch d VLONG, arg 2
warning: c4.c:428 format mismatch d VLONG, arg 2
c4.c:438 function not declared: stmt
warning: c4.c:476 format mismatch d VLONG, arg 2
warning: c4.c:480 format mismatch d VLONG, arg 2
warning: c4.c:522 format mismatch d VLONG, arg 2
warning: c4.c:522 format mismatch d VLONG, arg 3
warning: c4.c:523 format mismatch d VLONG, arg 2
warning: c4.c:523 format mismatch d VLONG, arg 3
warning: c4.c:330 used and not set: a
mk: 6c -FTVw c4.c  : exit status=rc 567802: 6c 567804: error
tenshi% 
```

It looks like we have another `function not declared` error due to missing the void in the function declaration, let's fix that:

```c
  }
}

void stmt(void)
{
  int *a, *b;

  if (tk == If) {
```

Compiling:

```text
tenshi% mk clean && mk
rm -f *.[05678qv] [05678qv].out y.tab.? lex.yy.c y.debug y.output c4 $CLEANFILES
6c -FTVw c4.c
warning: c4.c:53 format mismatch d VLONG, arg 2
warning: c4.c:53 format mismatch '*' in .*s VLONG, arg 3
warning: c4.c:59 format mismatch d VLONG, arg 2
warning: c4.c:344 format mismatch d VLONG, arg 2
warning: c4.c:345 format mismatch d VLONG, arg 2
warning: c4.c:346 format mismatch d VLONG, arg 2
warning: c4.c:347 format mismatch d VLONG, arg 2
warning: c4.c:360 format mismatch d VLONG, arg 2
warning: c4.c:361 format mismatch d VLONG, arg 2
warning: c4.c:379 format mismatch d VLONG, arg 2
warning: c4.c:379 format mismatch d VLONG, arg 3
warning: c4.c:383 format mismatch d VLONG, arg 2
warning: c4.c:396 format mismatch d VLONG, arg 2
warning: c4.c:397 format mismatch d VLONG, arg 2
warning: c4.c:409 format mismatch d VLONG, arg 2
warning: c4.c:410 format mismatch d VLONG, arg 2
warning: c4.c:418 format mismatch d VLONG, arg 2
warning: c4.c:427 format mismatch d VLONG, arg 2
warning: c4.c:428 format mismatch d VLONG, arg 2
warning: c4.c:476 format mismatch d VLONG, arg 2
warning: c4.c:480 format mismatch d VLONG, arg 2
warning: c4.c:522 format mismatch d VLONG, arg 2
warning: c4.c:522 format mismatch d VLONG, arg 3
warning: c4.c:523 format mismatch d VLONG, arg 2
warning: c4.c:523 format mismatch d VLONG, arg 3
warning: c4.c:330 used and not set: a
6l  -o 6.out c4.6
tenshi% 
```

**Note:** the compilation command has changed to `mk clean && mk` as now, we are at exclusively warnings, hooray! ☺

### Fixing warnings

Some of the format specifiers differ as well as per [print(2)](http://man.cat-v.org/9front/2/print), so we need to correct those.

In case the way to read the errors is unclear, `format mismatch d VLONG, arg 2` can be read as:

The format specifier `d` matches to the second argument for print(), but does not match the expected type of VLONG (int was expected).

In this case, vlong is a "very long" type whose formatting specifier, as a decimal value, will be `%lld`. 

The type definition of a vlong is on amd64 is:

	/amd64/include/u.h:7: typedef	long long	vlong;

Example:

```c
sp; }
    else { print("unknown instruction = %lld! cycle = %lld\n", i, cycle); return -1; }
  }
}
```

The `used and not set` can be fixed by initializing `a` to a value:

```c
int main(int argc, char **argv)
{
  int fd, bt, ty, poolsz, *idmain;
  int *pc, *sp, *bp, a, cycle; // vm registers
  int i, *t; // temps
  
  a = 0;

  --argc; ++argv;
```

### The final warning

After fixing all of the VLONG format specifiers, there's one specifier remaining that seems troublesome:

```text
tenshi% mk clean && mk
rm -f *.[05678qv] [05678qv].out y.tab.? lex.yy.c y.debug y.output c4 $CLEANFILES
6c -FTVw c4.c
warning: c4.c:53 format mismatch '*' in .*s VLONG, arg 3
6l  -o 6.out c4.6
tenshi% 
```

Honestly, I wasn't sure what `.*s` meant exactly, so for reference from [here](http://www.cplusplus.com/reference/cstdio/printf/):

```text
The width is not specified in the format string, but as an additional integer value argument preceding the argument that has to be formatted.
```

In short, `%.*s` expects a pair of arguments in the order `int, char*`. 

This seems to be caused partially by this `#define` at the top of c4.c:

```c
#define int long long
```

This may be an architectural decision to enforce the use of the largest integer type available, which plan9 provides through the vlong type. 

If we wanted to make this a more idiomatic and warning-free port, which we still could do, then we would remove this `#define` and use vlong in place of `long long`, etc. 

For now, we'll build the program and accept our one warning. ☺

### Hello World

As a final step, let's adjust hello.c to match the plan9 style:

```c
#include <u.h>
#include <libc.h>

void
main()
{
  print("hello, world\n");
}
```

And then:

```text
tenshi% 6.out hello.c
hello, world
exit(13) cycle = 8
tenshi% 
```

We have a functioning, native, port of c4 to plan9!

## References

- [Manuals](http://man.cat-v.org/9front/)
- [APE](http://doc.cat-v.org/plan_9/4th_edition/papers/ape)
- [Plan 9 C Compilers](http://doc.cat-v.org/plan_9/4th_edition/papers/compiler)
