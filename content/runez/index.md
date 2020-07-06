+++
title = "The Runez Compression Algorithms"
date = "2020-07-03"
tags = [
	"go",
]
+++

# The Runez Compression Algorithms

In January of 2020 I set about writing a pair of lossless compression algorithms inspired by a series of conversations over coffee with a good friend. 

These algorithms are fairly naive, but simple and to that end I will attempt to convey the implementation. 

There are two algorithms, [runez](https://github.com/henesy/runez) and [runez2](https://github.com/henesy/runez2). 

The runez2 algorithm is a strictly superior successor to runez with the primary improvement being that there is no unique character limit, which will be explained later. 

The name 'runez' is inspired by the fact that this algorithm attempts to compress utf-8 characters, or, runes. The 'z' implies the compression and looks cool ☺. 

The standard archive suffix for runez is `.rz` and `.rz2` for runez2. 

## Usage

The best exposition is one you can play with yourself, presuming you have [go](https://golang.org) installed, you can play with the runez algorithms as follows using the [mac.txt](https://github.com/henesy/runez2/blob/master/mac.txt) file found in the [runez2 repository](https://github.com/henesy/runez2). 

The [plan9port](https://github.com/9fans/plan9port) [wc(1)](https://9fans.github.io/plan9port/man/man1/wc.html) is used as it supports the counting of valid utf-8 characters. The plan9port `wc` command is called explicitly using the plan9port `9` program to circumvent the standard `$PATH` calling convention. 

The runez family tools operate using standard input and standard output and compress by default. 

The runez family algorithms assume that they can read the entirety of their input file into memory. 

```shell
$ runez -h
Usage of runez:
  -D	Chatty debug mode
  -c	Explicit compress mode
  -d	De-compress mode
$ 
```
  
```shell
$ runez2 -h
Usage of runez2:
  -D	Chatty debug mode
  -c	Explicit compress mode
  -d	De-compress mode
$ 
```

### Compression

**Runez:**

Note the deliberate truncation of the larger mac.txt from the runez2 repository. 

```shell
$ sed 5q mac.txt | runez > mac.rz
$ sed 5q mac.txt | 9 wc -r
    195
$ 9 wc -c mac.rz mac.txt
    290 mac.rz
   3550 mac.txt
   3840 total
$ 
```

**Runez2:**

```shell
$ runez2 < mac.txt > mac.rz2
$ 9 wc -r mac.txt
   1950 mac.txt
$ 9 wc -c mac.txt mac.rz2
   3550 mac.txt
   2030 mac.rz2
   5580 total
$ 
```

### Decompression

**Runez:**

```shell
$ runez -d < mac.rz
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
$ 
```

**Runez2:**

```shell
$ runez2 -d < mac.rz2 
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
Моето летачко возило е полно со јагули
$ 
```

## Runez the first

### Design

Specification: https://github.com/henesy/runez/blob/master/spec.md

Runez takes a series of valid utf-8 characters, which permits the ASCII range, and compacts them into a little-endian binary archive file. 

The file consists of a table where each row encodes information about one rune, a valid utf-8 character. 

A row takes the form of at least 3 columns:

```text
[number of position : uint8] [rune : int32] [position : uint8 …]
```

Note that the ellipses '…' implies that there can be be multiple positions, or offsets, a rune can occupy within a file. 

For example, given the string:

```text
αβξαβξ
```

The table would resemble:

```text
2 α 0 3
2 β 1 4
2 ξ 2 5
```

If we perform a small calculation 

The fatal assumption made by runez is that there are no more than `(^uint8(0) = 255) + 1 = 256` total runes present in the input file. 

This implies that runez can only compress files consisting of 256 characters or less, which is not very useful. 

### Implementation

#### Compression

Function definition: <https://github.com/henesy/runez/blob/30368d63a423af444da1017f5317482222e9a713/main.go#L57>

Runez begins compression by building a hashmap, mapping a `rune` to a list of `uint8`'s. 

Each rune from the input file is then iterated on sequentially, with their offset from the beginning of the file, starting at 0, being indexed as `i`. 

Each rune found will be checked for presence within the map. 

If the rune is found in the map as existing, the current rune offset is prepended to the list for said rune. 

If the rune is not found in the map, a list is allocated for the rune and the current rune offset is prepended to the list for said rune. 

The map is defined as per:

```go
dict := make(map[rune]*list.List)
```

Map presence is checked as per:

```go
if dict[r] == nil {
	dict[r] = list.New()
}
```

The current rune offset is prepended as per:

```go
dict[r].PushFront(uint8(i))
```

The map is then iterated over and the size of the list is derived from the length of a given rune's list. 

#### Decompression



## Runez the second

Specification: https://github.com/henesy/runez2/blob/master/spec.md

## Source

- https://github.com/henesy/runez
- https://github.com/henesy/runez2

