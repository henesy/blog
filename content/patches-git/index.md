+++
title = "Creating and Applying 9front Patches (Git Edition)"
date = "2021-08-26"
tags = [
	"plan9",
]
+++

# Creating and Applying 9front Patches (Git Edition)

## History

- October 2018, Ori [pushes the first commit to git9](https://github.com/Plan9-Archive/git9-hg/commit/22d65457a396771799379df6a8662b312be80a42).

- April 2019, Ori starts the 9fans thread ['[9fans] Git/fs: Possibly Usable'](https://9fans.topicbox.com/groups/9fans/Tfe05d23d2da2ea57-M6ff60bdc26cbe145050c6f8a/9fans-git-fs-possibly-usable).

- Late April 2019, Lufia announces [their port of unix git](https://github.com/lufia/git) on 9fans thread ['[9fans] Git client'](https://9fans.topicbox.com/groups/9fans/Te3752ec266e3a002-M7286f7236d8aab10096f7946/9fans-git-client).

- June 2019, git9 [migrates to git](https://shithub.us/ori/git9/ec28e68d5f5d72748d4b2d0be2861956b856ef4f/commit.html).

- July 2020, Atlassian deletes all Mercurial repositories without [archive](https://github.com/Plan9-Archive/git9-hg) or remorse.

- Early September 2020, Ori [summarizes the model for git9](https://orib.dev/git9.html).

- September 2020, Ori [announces git9 can serve itself](https://orib.dev/gitserve.html).

- November 2020, Ori [announces that his git9 is self-hosting](https://orib.dev/githosting.html) and [shithub](https://shithub.us/) is launched.

- September 2021, 9front [releases 'Community vs Infrastructure'](http://9front.org/releases/), migrates to git9, and removes Mercurial and Python.

## Creating

To create a patch we first pull 9front's git repo and bind our files into place:

```text
; sysupdate

; bind -a /dist/plan9front /
```

We should create our own work branch:

```text
; git/branch -n mywork
```
We can now make our changes to the system.

If we lose our way, we can see which files have changed:

```text
; git/diff -s
M sys/src/cmd/seq.c
;
```

We will commit our changes whilst inside our branch:

```text
# We make changes to seq(1)
; git/commit -m 'seq: some kind of change' /sys/src/cmd/seq.c
heads/mywork: 40d27871e341512ad69a50645e289f6b3856c528
;
```

If we need to, we can get a commit hash manually:

```text
; git/log -s | sed 1q | awk '{print $1}'
40d27871e341512ad69a50645e289f6b3856c528
```

We export our changes to a diff:

```text
; git/export 40d27871e341512ad69a50645e289f6b3856c528 > $home/mypatch.diff
```

You can export your changes to [the 9front pastebin](http://okturing.com/) for ease of linking:

```text
; git/export 40d27871e341512ad69a50645e289f6b3856c528 | webpaste
```

We can return to the default 9front branch:

```text
; git/branch front
```

## Applying

In the same way we pull and bind our files into place:

```text
; sysupdate

; bind -a /dist/plan9front /
```

For individual files you could use `ape/patch` if desired, but for most 9front patches you should use `git/import`:

```text
; git/import < $home/mypatch.diff
applying seq: some kind of change
M sys/src/cmd/seq.c
;
```

The patch is now applied!

If you wish to trash the changes from the patch, use:

```text
; git/revert /sys/src/cmd/seq.c
```

You can delete obsolete branches via:

```text
; git/branch front
; git/branch -d mywork
```

### Mail

If a patch is formatted properly and inline from an e-mail, you should be able to import from upasfs as per:

```text
; git/import < /mail/fs/mbox/4321
```
