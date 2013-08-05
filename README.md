Joddla - JobXML to DXF Converter
================================

Authored by David Pettersson.

Contributions from Britta Duve Hansen.

Idea by Anders Andersson. 

Dated 2013-08-05.

Overview
--------

Joddla is supposed to be a JobXML to DXF converter specially adapted to Lantm�teriet in Lund.

Features:

 * Minimise field work by interpolating arcs where possible.
 
Current status is that it is a prototype for arcs. It only reads JobXML and produces a rendering. No output yet.

Background
-----------

Sent in a letter to Anders:

F�rsta provskottet p� cirkelb�gar. Det �r ett Python-skript som jag k�r p� PC:n. Det �r prototypkvalit�t p� det, s� det �r inte robust n�nstans, men det visar ungef�r vad man kan f�rv�nta sig f�r utdata.

Jag har utg�tt fr�n 158.jxl (den du skickade).  Jag har skjutit in en sista punkt f�r att uppfylla kravet om att C2 m�ste f�ljas av en punkt f�r att f� dess tangent.

Algorithm
---------

* Finn tangenter f�r alla punkter [C1..C2]
* F�r varje par av punkter (a, b) inom en sekvens av [C1..C2]:
** Skapa en mittpunkt c
** Dra ut en linje vinkelr�t mot linjen mellan (a, b) som sk�r c
** Spara (a, b), deras respektive tangenter, c och linjens ekvation �t sidan som ett problem
* F�r varje problem:
** F�r ett diskret antal punkter p� linjen:
*** R�kna ut en cirkel med mittpunkt p� linjen som sk�r (a, b) 
*** R�kna ut cirkelns tangenter i punkter (a, b)
*** Ber�kna avvikelse mellan den egna och cirkelns tangent f�r a och b
*** Om den ber�knade cirkeln har mindre avvikelse �n vad vi tidigare sett, beh�ll den som b�sta l�sning f�r problemet
* F�r varje cirkel:
** R�kna ut en b�ge

I bilden nedan �r de r�da boxarna de inm�tta punkterna fr�n JobXML-filen. Cirkelkonturerna �r cirkeln mellan tv� punkter med minsta avvikelse. De bl� linjerna �r de utr�knade b�garna fr�n cirklarna.

Som synes �r passformen �verlag bra f�r f�rsta kurvan. F�r den andra �r kurvan �r passformen s�d�r f�r de tv� sista b�garna. Slutsatsen man kan dra �r att man f�r plocka in fler punktern om verkligheten har skarpa vinklar.

