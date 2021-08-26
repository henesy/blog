+++
title = "Touring Blit in 2018"
date = "2018-05-30"
tags = [
	"plan9",
]
+++

# Touring Blit in 2018

Ever wondered if there was a nice way to get a VAX-grade, semi-authentic, Blit experience?

Good news! While 9front ships with a Blit emulator via `games/blit` you can also connect to UNIX from GNU/Linux with [this handy port](https://github.com/timnewsham/blit) and [plan9port](https://github.com/9fans/plan9port).

To get a connection going just run the following on your emulator of choice:

```shell
blit -t 'tcp!papnet.eu!8888'
```

Choose `ken` as your username.

To start a window manager:

```shell
. $HOME/.profile_blit
mux
```

Enjoy your authentic UNIX experience!

