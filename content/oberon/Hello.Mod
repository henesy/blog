MODULE Hello;

(* Hello World!  *)

IMPORT Texts, Oberon;

VAR W: Texts.Writer;

PROCEDURE World*;
BEGIN
	Texts.WriteString(W, "\nZa Warudo!");
	Texts.WriteLn(W);
	Texts.Append(Oberon.Log, W.buf);
END World;

BEGIN
	Texts.OpenWriter(W);
END Hello.
