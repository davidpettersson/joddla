Joddla - JobXML to DXF Converter
================================

Authored by David Pettersson.

Contributions from Britta Duve Hansen.

Idea by Anders Andersson. 

Dated 2013-08-05.

Overview
--------

Joddla is supposed to be a JobXML to DXF converter specially adapted to Lantmäteriet in Lund.

Features:

 * Minimise field work by interpolating arcs where possible.
 
Current status is that it is a prototype for arcs. It only reads JobXML and produces a rendering. No output yet.

Background
-----------

Sent in a letter to Anders:

    > Första provskottet på cirkelbågar. Det är ett Python-skript som jag kör på PC:n. Det är prototypkvalitét på det, så det är inte robust nånstans, men det visar ungefär vad man kan förvänta sig för utdata.
    
    >Jag har utgått från 158.jxl (den du skickade).  Jag har skjutit in en sista punkt för att uppfylla kravet om att C2 måste följas av en punkt för att få dess tangent.

Algorithm
---------

* Finn tangenter för alla punkter [C1..C2]
* För varje par av punkter (a, b) inom en sekvens av [C1..C2]:
    * Skapa en mittpunkt c
    * Dra ut en linje vinkelrät mot linjen mellan (a, b) som skär c
    * Spara (a, b), deras respektive tangenter, c och linjens ekvation åt sidan som ett problem
* För varje problem:
    * För ett diskret antal punkter på linjen:
        * Räkna ut en cirkel med mittpunkt på linjen som skär (a, b) 
        * Räkna ut cirkelns tangenter i punkter (a, b)
        * Beräkna avvikelse mellan den egna och cirkelns tangent för a och b
        * Om den beräknade cirkeln har mindre avvikelse än vad vi tidigare sett, behåll den som bästa lösning för problemet
* För varje cirkel:
    * Räkna ut en båge

