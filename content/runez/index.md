+++
title = "The Runez Compression Algorithms"
date = "2020-07-03"
tags = [
	"go",
]
math = true
markup = "mmark"
+++

<!-- KaTeX stuff -->
{{ if or .Params.math .Site.Params.math }}
{{ partial "math.html" . }}
{{ end }}

{{< math.inline >}}
{{ if or .Page.Params.math .Site.Params.math }}

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.10.1/dist/katex.min.css" integrity="sha384-dbVIfZGuN1Yq7/1Ocstc1lUEm+AT+/rCkibIcC/OmWo5f0EA48Vf8CytHzGrSwbQ" crossorigin="anonymous">
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.10.1/dist/katex.min.js" integrity="sha384-2BKqo+exmr9su6dir+qCw08N2ZKRucY4PrGQPPWU1A7FtlCGjmEGFqXCv5nyM5Ij" crossorigin="anonymous"></script>
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.10.1/dist/contrib/auto-render.min.js" integrity="sha384-kWPLUVMOks5AQFrykwIup5lo0m3iMkkHrD0uJ4H5cjeGihAutqP0yW0J6dpFiVkI" crossorigin="anonymous" onload="renderMathInElement(document.body);"></script>
{{ end }}
{{</ math.inline >}}
<!-- KateX stuff -->

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

What happens if you don't truncate the file?

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

If we perform a small calculation we can see that the size of the input file is 6 int32 values, which are a total of $$ 4 * 6 = 24 $$ bytes. The output file is 3 int32 values and 9 uint8 values totalling $$ 3 * 4 + 9 = 21 $$ bytes. In total, this input yields 3 bytes of compression. 

The fatal assumption made by runez is that there are no more than $$ (\oplus uint8(0) = 255)+1 = 256 $$ total runes present in the input file. 

This implies that runez can only compress files consisting of 256 characters or less, which is not very useful. 

The following function expresses the size of the final archive size ($$\sigma$$) in bytes:

$$
\sigma = \sum \forall r\{1 + 4 + n_r\}
$$

We can apply this formula on the mac.txt example from earlier to calculate the size of the final archive. 

The file consists of one line of 39 runes repeated across 5 lines:

```text
Моето летачко возило е полно со јагули\n
```

The set of 19 unique runes:

$$
r \isin R\{nl, ␣, М, о, е, т, л, а, ч, к, в, з, и, п, с, ј, г, у, н\}
$$

$$
R \implies bookkeeping_\sigma = (1 + 4) * 19 = 95\ bytes
$$

$$
positions_\sigma = 5 * 39 = 195
$$

$$
\sigma = bookkeeping_\sigma + positions_\sigma = 95 + 195 = 290
$$

$$
\therefore 290\ bytes
$$

We can validate this manually:

```shell
$ wc -c mac.rz
290 mac.rz
$
```

### Implementation

#### Compression

Function definition: <https://github.com/henesy/runez/blob/30368d63a423af444da1017f5317482222e9a713/main.go#L57>

Runez begins compression by building a hashmap, mapping a `rune` to a list of `uint8`'s. 

```go
dict := make(map[rune]*list.List)
```

Each rune from the input file is then iterated on sequentially, with their offset from the beginning of the file, starting at 0, being indexed as `i`. 

Each rune found will be checked for presence within the map. 

```go
if dict[r] == nil {
	dict[r] = list.New()
}
```

If the rune is found in the map as existing, the current rune offset is prepended to the list for said rune. 

```go
dict[r].PushFront(uint8(i))
```

If the rune is not found in the map, a list is allocated for the rune and the current rune offset is prepended to the list for said rune. 

After all the runes have been read from the input file, the map is then iterated over and rows are generated for the output table. 

The number of positions is derived from the list length. 

The rune is derived from the map key during iteration. 

The positions are extracted starting from the front of the list. 

We can see the relevant encoding of the position count, rune, and positions respectively as per:

```go
…
err := binary.Write(w, binary.LittleEndian, pc)
…
err = binary.Write(w, binary.LittleEndian, r)
…
for p := l.Front(); p != nil; p = p.Next() {
	err := binary.Write(w, binary.LittleEndian, byte(p.Value.(uint8)))
	…
}
…
```

#### Decompression

Function definition: <https://github.com/henesy/runez/blob/30368d63a423af444da1017f5317482222e9a713/main.go#L116>

Runez begins decompression by allocated a hashmap mapping a `rune` to a slice of `uint8`'s. 

```go
dict := make(map[rune][]uint8)
```

Runez will read from the input file until EOF is reached. 

Each iteration of the reading process will extract a position count, rune, and a number of positions as defined by the position count. 

```go
err := binary.Read(r, binary.LittleEndian, &pc)
…
err = binary.Read(r, binary.LittleEndian, &ru)
…
for i := uint8(0); i < pc; i++ {
	var p uint8

	err = binary.Read(r, binary.LittleEndian, &p)
	…

	dict[ru][i] = p
}
…
```

The total number of runes based on the sum of position counts is stored for later use. 

```go
sum := 0
…
sum += int(pc)
…
```

The slice is allocated in size of 'position count' number of positions. 

```go
dict[ru] = make([]uint8, pc)
```

After all runes have been read, the map is iterated over and inside said iteration, the slice of positions is iterated over. 

A `Pair` type is used to conjoin a rune to a given position. 

```go
type Pair struct {
	R rune
	P uint8
}
```

A slice of pairs is allocated proportional to the size of the aforementioned sum value. 

```go
master := make([]Pair, 0, sum)
```

Each position iterated over is placed in a `Pair` with its parent rune and the couple is appended to the master slice of pairs. 

```go
for ru, s := range dict {
	for _, p := range s {
		master = append(master, Pair{ru, p})
	}
}
```

After all position and rune pairs have been processed, the slice of all pairs is sorted by position value, starting from 0. 

```go
…
type ByPosition []Pair

func (a ByPosition) Len() int           { return len(a) }
func (a ByPosition) Swap(i, j int)      { a[i], a[j] = a[j], a[i] }
func (a ByPosition) Less(i, j int) bool { return a[i].P < a[j].P }
…
sort.Sort(ByPosition(master))
…
```

The sorted slice of pairs is then emitted to standard output. 

```go
for _, pair := range master {
	w.Write([]byte(string(pair.R)))
}
```

## Runez the second

Specification: https://github.com/henesy/runez2/blob/master/spec.md

### Design

Runez2 takes a series of valid utf-8 characters, which permits the ASCII range, and compacts them into a little-endian binary archive file. 

The file consists of two parts, a preamble which lists all the unique runes in a specific order and a body which is separated from the preamble by a null rune and consists of single byte (`uint8`) values indicating the unique rune which should be substituted into position for said single byte value. 

The archive format is thus structured as follows:

```text
[rune : int32]
…
[\0 : int32]
[N : uint8]
```

Note that the ellipses '…' implies that there can be many runes prior to the null divider. 

For example, given the string:

```text
αβξαβξ
```

The file would resemble:

```text
αβξ
\0
0 1 2 0 1 2
```

The core assumptions made by Runez2 is that the whole file can be read into memory and that there are no more than $$ (\oplus uint8(0) = 255)+1 = 256 $$ **unique** runes. 

Additionally, files compressed by runez2 cannot contain null runes (`\0`) as this is reserved as the dividing point for the preamble. 

There is an implied maximum compression ratio offered by runez2. 

The following function expresses the size of the final archive size ($$\sigma$$) in bytes:

$$
\sigma = 4 + \sum \forall r\{n_r + 4 , r \neq \empty\}
$$

Note that the function for finding the maximum potential size in bytes of the plaintext utf-8 is:

$$
\sigma = \sum \forall r \{ n_r * 4 \}
$$

Note that in practice, due to how utf-8 text encoding works, the size in bytes of the plaintext is most likely much smaller than this number. 

We can apply the former formula on the mac.txt example from earlier to calculate the size of the final archive. 

The file consists of one line of 39 runes repeated many times:

```text
Моето летачко возило е полно со јагули\n
```

The set of 19 unique runes:

$$
r \isin R\{nl, ␣, М, о, е, т, л, а, ч, к, в, з, и, п, с, ј, г, у, н\}
$$

$$
R \implies preamble_\sigma = 4 + (4 * 19) = 80\ bytes
$$

$$
body_\sigma = lines_n * linerunes_n = 50 * 39 = 2030\ bytes
$$

$$
\sigma = preamble_\sigma + body_\sigma
$$

$$
\therefore 2030\ bytes
$$

We can validate this manually:

```shell
$ wc -c mac.rz2 
2030 mac.rz2
$
```

**Disclaimer:** I am not a mathematician, these formulae are an approximation of what I remember from university ☺. 

The assumptions make runez2 insufficient for languages such as Mandarin in applications which possess a number of distinct runes greater than 256, which is most applications, but is sufficient in all applications for alphabets such as Arabic, Cyrillic, etc. 

### Implementation

#### Compression

#### Decompression

## Source

- https://github.com/henesy/runez
- https://github.com/henesy/runez2

