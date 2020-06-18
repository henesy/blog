+++
title = "Creating and Applying 9front Patches"
date = "2018-09-07"
tags = [
	"plan9",
]
+++

# Creating and Applying 9front Patches

## Creating

To create a patch we first pull 9front's hg repo and bind our files into place:

```text
sysupdate

bind -a /dist/plan9front /

cd /
```

In this example we're making a patch for rio, any combination of folders should work:

```text
bind $home/src/rio /sys/src/cmd/rio
```

To get the latest commit:

```text
hg log | sed 5q
```

A first log output example might be:

```text
changeset:   6705:eecec6d3b341
user:        cinap_lenrek@felloff.net
date:        Mon Sep 03 20:54:26 2018 +0200
summary:     vt: fix plumbsel(), snarfsel()
```

The commit hash we're looking for is `eecec6d3b341` and we can use it as follows to make the diff file:

```text
hg diff -r eecec6d3b341 /sys/src/cmd/rio/wind.c > $home/mypatch.diff
```

## Applying

In the same way we pull and bind our files into place:

```text
sysupdate

bind -a /dist/plan9front /

cd /
```

For individual files you could use `ape/patch` if desired, but for most 9front patches you should use hg:

```text
hg import --no-commit -f $home/mypatch.diff
```

The patch is now applied!

If you wish to trash the changes from the patch, use:

```text
hg revert
```

