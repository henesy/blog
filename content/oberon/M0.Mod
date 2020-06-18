MODULE M0;

(* 

A rewrite of Wirth's Using Oberon M0.Mod:

https://inf.ethz.ch/personal/wirth/ProjectOberon/UsingOberon.pdf

*)

IMPORT Texts, Oberon;

VAR W: Texts.Writer;       

PROCEDURE      P0*;      
	VAR sum: INTEGER; 
	S: Texts.Scanner; 

BEGIN
	sum := 0;             
	Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos); 
	Texts.Scan(S); 
	WHILE S.class = Texts.Int 
	DO    
		Texts.WriteInt(W, S.i, 6); 
		sum := sum + S.i; 
		Texts.Scan(S)             
	END;
      
	Texts.WriteInt(W, sum, 8); 
	Texts.WriteLn(W); 
	Texts.Append(Oberon.Log, W.buf)       
END P0;      

BEGIN 
	Texts.OpenWriter(W) 
END M0. 
