<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"    
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt">

<!-- (c) 2012, Trimble Navigation Limited. All rights reserved.                                -->
<!-- Permission is hereby granted to use, copy, modify, or distribute this style sheet for any -->
<!-- purpose and without fee, provided that the above copyright notice appears in all copies   -->
<!-- and that both the copyright notice and the limited warranty and restricted rights notice  -->
<!-- below appear in all supporting documentation.                                             -->

<!-- TRIMBLE NAVIGATION LIMITED PROVIDES THIS STYLE SHEET "AS IS" AND WITH ALL FAULTS.         -->
<!-- TRIMBLE NAVIGATION LIMITED SPECIFICALLY DISCLAIMS ANY IMPLIED WARRANTY OF MERCHANTABILITY -->
<!-- OR FITNESS FOR A PARTICULAR USE. TRIMBLE NAVIGATION LIMITED DOES NOT WARRANT THAT THE     -->
<!-- OPERATION OF THIS STYLE SHEET WILL BE UNINTERRUPTED OR ERROR FREE.                        -->

<xsl:output method="text" omit-xml-declaration="yes" encoding="ISO-8859-1"/>

<!-- Set the numeric display details i.e. decimal point, thousands separator etc -->
<xsl:variable name="DecPt" select="'.'"/>    <!-- Change as appropriate for US/European -->
<xsl:variable name="GroupSep" select="','"/> <!-- Change as appropriate for US/European -->
<!-- Also change decimal-separator & grouping-separator in decimal-format below 
     as appropriate for US/European output -->
<xsl:decimal-format name="Standard" 
                    decimal-separator="."
                    grouping-separator=","
                    infinity="Infinity"
                    minus-sign="-"
                    NaN="?"
                    percent="%"
                    per-mille="&#2030;"
                    zero-digit="0" 
                    digit="#" 
                    pattern-separator=";" />

<xsl:variable name="DecPl0" select="'#0'"/>
<xsl:variable name="DecPl1" select="concat('#0', $DecPt, '0')"/>
<xsl:variable name="DecPl2" select="concat('#0', $DecPt, '00')"/>
<xsl:variable name="DecPl3" select="concat('#0', $DecPt, '000')"/>
<xsl:variable name="DecPl4" select="concat('#0', $DecPt, '0000')"/>
<xsl:variable name="DecPl5" select="concat('#0', $DecPt, '00000')"/>
<xsl:variable name="DecPl6" select="concat('#0', $DecPt, '000000')"/>
<xsl:variable name="DecPl8" select="concat('#0', $DecPt, '00000000')"/>

<xsl:variable name="Pi" select="3.14159265358979323846264"/>
<xsl:variable name="halfPi" select="$Pi div 2.0"/>

<xsl:variable name="fileExt" select="'dxf'"/>

<!-- User variable definitions - Appropriate fields are displayed on the       -->
<!-- Survey Controller screen to allow the user to enter specific values       -->
<!-- which can then be used within the style sheet definition to control the   -->
<!-- output data.                                                              -->
<!--                                                                           -->
<!-- All user variables must be identified by a variable element definition    -->
<!-- named starting with 'userField' (case sensitive) followed by one or more  -->
<!-- characters uniquely identifying the user variable definition.             -->
<!--                                                                           -->
<!-- The text within the 'select' field for the user variable description      -->
<!-- references the actual user variable and uses the '|' character to         -->
<!-- separate the definition details into separate fields as follows:          -->
<!-- For all user variables the first field must be the name of the user       -->
<!-- variable itself (this is case sensitive) and the second field is the      -->
<!-- prompt that will appear on the Survey Controller screen.                  -->
<!-- The third field defines the variable type - there are four possible       -->
<!-- variable types: Double, Integer, String and StringMenu.  These variable   -->
<!-- type references are not case sensitive.                                   -->
<!-- The fields that follow the variable type change according to the type of  -->
<!-- variable as follow:                                                       -->
<!-- Double and Integer: Fourth field = optional minimum value                 -->
<!--                     Fifth field = optional maximum value                  -->
<!--   These minimum and maximum values are used by the Survey Controller for  -->
<!--   entry validation.                                                       -->
<!-- String: No further fields are needed or used.                             -->
<!-- StringMenu: Fourth field = number of menu items                           -->
<!--             Remaining fields are the actual menu items - the number of    -->
<!--             items provided must equal the specified number of menu items. -->
<!--                                                                           -->
<!-- The style sheet must also define the variable itself, named according to  -->
<!-- the definition.  The value within the 'select' field will be displayed in -->
<!-- the Survey Controller as the default value for the item.                  -->

<xsl:variable name="userField1" select="'selectedBlkName|Block to use for points|StringMenu|6|Dot|Cross|Diagonal Cross|Circle|Triangle|Double triangle'"/>
<xsl:variable name="selectedBlkName" select="'Dot'"/>
<xsl:variable name="userField2" select="'splitIntoLayers|Split into layers based on point codes|StringMenu|2|Yes|No'"/>
<xsl:variable name="splitIntoLayers" select="'Yes'"/>
<xsl:variable name="userField3" select="'addNameCodeElevAsText|Add pt names, codes, descs and elevs as text|StringMenu|2|Yes|No'"/>
<xsl:variable name="addNameCodeElevAsText" select="'No'"/>
<xsl:variable name="userField4" select="'addCodedLines|Apply simple feature coding to create lines|StringMenu|2|Yes|No'"/>
<xsl:variable name="addCodedLines" select="'Yes'"/>
<xsl:variable name="userField5" select="'tempLineCodes|Codes for line joining (use vertical bar separator)|String'"/>
<xsl:variable name="tempLineCodes" select="'2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20'"/>
<!-- Need to have leading and trailing | chars in the string for matching purposes -->
<xsl:variable name="lineCodes" select="concat('|', translate($tempLineCodes,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'), '|')"/>
<xsl:variable name="userField6" select="'tempStartCode|Suffix code (space separated) for new sequence|String'"/>
<xsl:variable name="tempStartCode" select="'ST'"/>
<xsl:variable name="startCode" select="translate($tempStartCode,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
<xsl:variable name="userField7" select="'tempCloseCode|Suffix code (space separated) for closing a figure|String'"/>
<xsl:variable name="tempCloseCode" select="'SL'"/>
<xsl:variable name="closeCode" select="translate($tempCloseCode,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
<xsl:variable name="userField8" select="'tempJoinToCode|Code for joining to a point (pt name follows after space)|String'"/>
<xsl:variable name="tempJoinToCode" select="'JPT'"/>
<xsl:variable name="joinToCode" select="translate($tempJoinToCode,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
<xsl:variable name="userField9" select="'coordDecPl|Decimal places for point coordinate values|StringMenu|4|3|4|5|6'"/>
<xsl:variable name="coordDecPl" select="'3'"/>
<xsl:variable name="userField10" select="'textHt|Text height|StringMenu|6|0.5|1.0|1.5|2.0|3.0|4.0'"/>
<xsl:variable name="textHt" select="'1.0'"/>

<!-- **************************************************************** -->
<!-- Set global variables from the Environment section of JobXML file -->
<!-- **************************************************************** -->
<xsl:variable name="DistUnit"   select="/JOBFile/Environment/DisplaySettings/DistanceUnits" />
<xsl:variable name="AngleUnit"  select="/JOBFile/Environment/DisplaySettings/AngleUnits" />
<xsl:variable name="CoordOrder" select="/JOBFile/Environment/DisplaySettings/CoordinateOrder" />
<xsl:variable name="TempUnit"   select="/JOBFile/Environment/DisplaySettings/TemperatureUnits" />
<xsl:variable name="PressUnit"  select="/JOBFile/Environment/DisplaySettings/PressureUnits" />

<!-- Setup conversion factor for coordinate and distance values -->
<!-- Dist/coord values in JobXML file are always in metres -->
<xsl:variable name="DistConvFactor">
  <xsl:choose>
    <xsl:when test="$DistUnit='Metres'">1.0</xsl:when>
    <xsl:when test="$DistUnit='InternationalFeet'">3.280839895</xsl:when>
    <xsl:when test="$DistUnit='USSurveyFeet'">3.2808333333357</xsl:when>
    <xsl:otherwise>1.0</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- Setup conversion factor for angular values -->
<!-- Angular values in JobXML file are always in decimal degrees -->
<xsl:variable name="AngleConvFactor">
  <xsl:choose>
    <xsl:when test="$AngleUnit='DMSDegrees'">1.0</xsl:when>
    <xsl:when test="$AngleUnit='Gons'">1.111111111111</xsl:when>
    <xsl:when test="$AngleUnit='Mils'">17.77777777777</xsl:when>
    <xsl:otherwise>1.0</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- Setup boolean variable for coordinate order -->
<xsl:variable name="NECoords">
  <xsl:choose>
    <xsl:when test="$CoordOrder='North-East-Elevation'">true</xsl:when>
    <xsl:when test="$CoordOrder='X-Y-Z'">true</xsl:when>
    <xsl:otherwise>false</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- Setup conversion factor for pressure values -->
<!-- Pressure values in JobXML file are always in millibars (hPa) -->
<xsl:variable name="PressConvFactor">
  <xsl:choose>
    <xsl:when test="$PressUnit='MilliBar'">1.0</xsl:when>
    <xsl:when test="$PressUnit='InchHg'">0.029529921</xsl:when>
    <xsl:when test="$PressUnit='mmHg'">0.75006</xsl:when>
    <xsl:otherwise>1.0</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="lineCodesList">
  <xsl:call-template name="ExtractCodeList">
    <xsl:with-param name="codeString" select="$lineCodes"/>
  </xsl:call-template>
</xsl:variable>

<!-- Set up the $blockName variable used to write the block name to the DXF file based on the selected block name -->
<xsl:variable name="blockName">
  <xsl:choose>
    <xsl:when test="$selectedBlkName = 'Dot'">
      <xsl:value-of select="'DOT'"/>
    </xsl:when>
    <xsl:when test="$selectedBlkName = 'Cross'">
      <xsl:value-of select="'CROSS'"/>
    </xsl:when>
    <xsl:when test="$selectedBlkName = 'Diagonal Cross'">
      <xsl:value-of select="'DIAG_CROSS'"/>
    </xsl:when>
    <xsl:when test="$selectedBlkName = 'Circle'">
      <xsl:value-of select="'CIRCLE'"/>
    </xsl:when>
    <xsl:when test="$selectedBlkName = 'Triangle'">
      <xsl:value-of select="'TRIANGLE'"/>
    </xsl:when>
    <xsl:when test="$selectedBlkName = 'Double triangle'">
      <xsl:value-of select="'DOUBLE_TRIANGLE'"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="'CROSS'"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="coordDecPlStr">
  <xsl:choose>
    <xsl:when test="$coordDecPl = '3'"><xsl:value-of select="$DecPl3"/></xsl:when>
    <xsl:when test="$coordDecPl = '4'"><xsl:value-of select="$DecPl4"/></xsl:when>
    <xsl:when test="$coordDecPl = '5'"><xsl:value-of select="$DecPl5"/></xsl:when>
    <xsl:when test="$coordDecPl = '6'"><xsl:value-of select="$DecPl6"/></xsl:when>
    <xsl:otherwise><xsl:value-of select="$DecPl6"/></xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- **************************************************************** -->
<!-- ************************** Main Loop *************************** -->
<!-- **************************************************************** -->
<xsl:template match="/" >
  <xsl:call-template name="OutputHeaderSection"/>

  <xsl:call-template name="OutputClassesSection"/>

  <xsl:call-template name="OutputTablesSection"/>

  <xsl:call-template name="OutputBlocksSection"/>

  <xsl:call-template name="OutputEntititesSectionHeader"/>

  <xsl:call-template name="ExportData"/>   <!-- Exports all the reduced points then exports -->
                                           <!-- all the lines from the FieldBook node -->

  <xsl:call-template name="OutputEndOfEntititesSection"/>

  <xsl:call-template name="OutputObjectsSection"/>

  <xsl:call-template name="OutputEndOfFile"/>
</xsl:template>


<!-- **************************************************************** -->
<!-- ************* Write out all the header Section Items *********** -->
<!-- **************************************************************** -->
<xsl:template name="OutputHeaderSection">
  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>SECTION&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>HEADER&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$ACADVER&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>AC1015&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$ACADMAINTVER&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     6&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DWGCODEPAGE&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>ANSI_1252&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$INSBASE&#10;</xsl:text>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="decPlaces" select="1"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$EXTMIN&#10;</xsl:text>
  <xsl:call-template name="MinCoords"/>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$EXTMAX&#10;</xsl:text>
  <xsl:call-template name="MaxCoords"/>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$LIMMIN&#10;</xsl:text>
  <xsl:call-template name="MinCoords">
    <xsl:with-param name="threeDVals" select="0"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$LIMMAX&#10;</xsl:text>
  <xsl:call-template name="MaxCoords">
    <xsl:with-param name="threeDVals" select="0"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$ORTHOMODE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$REGENMODE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$FILLMODE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$QTEXTMODE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$MIRRTEXT&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$LTSCALE&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$ATTMODE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:choose>
    <xsl:when test="$addNameCodeElevAsText = 'Yes'">
      <xsl:text>     0&#10;</xsl:text>  <!-- Default attribute display mode off -->
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>     1&#10;</xsl:text>  <!-- Default attribute display mode on -->
    </xsl:otherwise>
  </xsl:choose>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$TEXTSIZE&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.2&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$TRACEWID&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.05&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$TEXTSTYLE&#10;</xsl:text>

  <xsl:text>  7&#10;</xsl:text>
  <xsl:text>MONOTEXT&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$CLAYER&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$CELTYPE&#10;</xsl:text>

  <xsl:text>  6&#10;</xsl:text>
  <xsl:text>ByLayer&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$CECOLOR&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>256&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$CELTSCALE&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DISPSILH&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMSCALE&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMASZ&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.18&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMEXO&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0625&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMDLI&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.38&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMRND&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMDLE&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMEXE&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.18&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMTP&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMTM&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMTXT&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.18&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMCEN&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.09&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMTSZ&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMTOL&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMLIM&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMTIH&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMTOH&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMSE1&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMSE2&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMTAD&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMZIN&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMBLK&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMASO&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMSHO&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMPOST&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMAPOST&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMALT&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMALTD&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     2&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMALTF&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>25.4&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMLFAC&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMTOFL&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMTVP&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMTIX&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMSOXD&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMSAH&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMBLK1&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMBLK2&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMSTYLE&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>STANDARD&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMCLRD&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMCLRE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMCLRT&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMTFAC&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMGAP&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.09&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMJUST&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMSD1&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMSD2&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMTOLJ&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMTZIN&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMALTZ&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMALTTZ&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMUPT&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMDEC&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     4&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMTDEC&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     4&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMALTU&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     2&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMALTTD&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     2&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMTXSTY&#10;</xsl:text>

  <xsl:text>  7&#10;</xsl:text>
  <xsl:text>MONOTEXT&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMAUNIT&#10;</xsl:text>  <!-- Angle format for angular dimensions -->

  <xsl:text> 70&#10;</xsl:text>
  <xsl:choose>
    <xsl:when test="$AngleUnit = 'DecimalDegrees'"><xsl:text>     0&#10;</xsl:text></xsl:when>
    <xsl:when test="$AngleUnit = 'DMSDegrees'"><xsl:text>     1&#10;</xsl:text></xsl:when>
    <xsl:when test="$AngleUnit = 'Gons'"><xsl:text>     2&#10;</xsl:text></xsl:when>
    <xsl:otherwise><xsl:text>     4&#10;</xsl:text></xsl:otherwise>  <!-- Surveyor's units?? -->
  </xsl:choose>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMADEC&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMALTRND&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMAZIN&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMDSEP&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMATFIT&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     3&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMFRAC&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMLDRBLK&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMLUNIT&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     2&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMLWD&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMLWE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$DIMTMOVE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$LUNITS&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:choose>
    <xsl:when test="($DistUnit = 'InternationalFeet') or ($DistUnit = 'USSurveyFeet')">
      <xsl:text>     2&#10;</xsl:text>
    </xsl:when>
    <xsl:otherwise><xsl:text>     6&#10;</xsl:text></xsl:otherwise>  <!-- Metres -->
  </xsl:choose>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$LUPREC&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     4&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$SKETCHINC&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.1&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$FILLETRAD&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$AUNITS&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:choose>
    <xsl:when test="$AngleUnit = 'DecimalDegrees'"><xsl:text>     0&#10;</xsl:text></xsl:when>
    <xsl:when test="$AngleUnit = 'DMSDegrees'"><xsl:text>     1&#10;</xsl:text></xsl:when>
    <xsl:when test="$AngleUnit = 'Gons'"><xsl:text>     2&#10;</xsl:text></xsl:when>
    <xsl:otherwise><xsl:text>     4&#10;</xsl:text></xsl:otherwise>  <!-- Surveyor's units?? -->
  </xsl:choose>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$AUPREC&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$MENU&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>ACAD&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$ELEVATION&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PELEVATION&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$THICKNESS&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$LIMCHECK&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$CHAMFERA&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$CHAMFERB&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$CHAMFERC&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$CHAMFERD&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$SKPOLY&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$TDCREATE&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:call-template name="JulianDay">
    <xsl:with-param name="timeStamp" select="/JOBFile/@TimeStamp"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$TDUCREATE&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.000000000&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$TDUPDATE&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.000000000&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$TDUUPDATE&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:call-template name="JulianDay">
    <xsl:with-param name="timeStamp" select="/JOBFile/@TimeStamp"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$TDINDWG&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.000000000&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$TDUSRTIMER&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.000000000&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$USRTIMER&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$ANGBASE&#10;</xsl:text>

  <xsl:text> 50&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$ANGDIR&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PDMODE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PDSIZE&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PLINEWID&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$SPLFRAME&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$SPLINETYPE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     6&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$SPLINESEGS&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     8&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$HANDSEED&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>6B6&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$SURFTAB1&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     6&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$SURFTAB2&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     6&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$SURFTYPE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     6&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$SURFU&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     6&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$SURFV&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     6&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$UCSBASE&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$UCSORG&#10;</xsl:text>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="decPlaces" select="1"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$UCSXDIR&#10;</xsl:text>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="east" select="1"/>
    <xsl:with-param name="decPlaces" select="1"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$UCSYDIR&#10;</xsl:text>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="north" select="1"/>
    <xsl:with-param name="decPlaces" select="1"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$UCSORTHOREF&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$UCSORTHOVIEW&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$UCSORGTOP&#10;</xsl:text>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="decPlaces" select="1"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$UCSORGBOTTOM&#10;</xsl:text>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="decPlaces" select="1"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$UCSORGLEFT&#10;</xsl:text>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="decPlaces" select="1"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$UCSORGRIGHT&#10;</xsl:text>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="decPlaces" select="1"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$UCSORGFRONT&#10;</xsl:text>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="decPlaces" select="1"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$UCSORGBACK&#10;</xsl:text>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="decPlaces" select="1"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PUCSBASE&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PUCSNAME&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PUCSORG&#10;</xsl:text>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="decPlaces" select="1"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PUCSXDIR&#10;</xsl:text>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="east" select="1"/>
    <xsl:with-param name="decPlaces" select="1"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PUCSYDIR&#10;</xsl:text>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="north" select="1"/>
    <xsl:with-param name="decPlaces" select="1"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PUCSORTHOREF&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PUCSORTHOVIEW&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PUCSORGTOP&#10;</xsl:text>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="decPlaces" select="1"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PUCSORGBOTTOM&#10;</xsl:text>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="decPlaces" select="1"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PUCSORGLEFT&#10;</xsl:text>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="decPlaces" select="1"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PUCSORGRIGHT&#10;</xsl:text>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="decPlaces" select="1"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PUCSORGFRONT&#10;</xsl:text>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="decPlaces" select="1"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PUCSORGBACK&#10;</xsl:text>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="decPlaces" select="1"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$USERI1&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$USERI2&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$USERI3&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$USERI4&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$USERI5&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$USERR1&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$USERR2&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$USERR3&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$USERR4&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$USERR5&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$WORLDVIEW&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$SHADEDGE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     3&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$SHADEDIF&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>    70&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$TILEMODE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$MAXACTVP&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>    16&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PINSBASE&#10;</xsl:text>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="decPlaces" select="1"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PLIMCHECK&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PEXTMIN&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>1.000000E+20&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>1.000000E+20&#10;</xsl:text>

  <xsl:text> 30&#10;</xsl:text>
  <xsl:text>1.000000E+20&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PEXTMAX&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>-1.000000E+20&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>-1.000000E+20&#10;</xsl:text>

  <xsl:text> 30&#10;</xsl:text>
  <xsl:text>-1.000000E+20&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PLIMMIN&#10;</xsl:text>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="decPlaces" select="1"/>
    <xsl:with-param name="threeDVals" select="0"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PLIMMAX&#10;</xsl:text>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="east" select="12"/>
    <xsl:with-param name="north" select="9"/>
    <xsl:with-param name="decPlaces" select="1"/>
    <xsl:with-param name="threeDVals" select="0"/>
  </xsl:call-template>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$UNITMODE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$VISRETAIN&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PLINEGEN&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PSLTSCALE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$TREEDEPTH&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>  3020&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$CMLSTYLE&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>STANDARD&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$CMLJUST&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$CMLSCALE&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PROXYGRAPHICS&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$MEASUREMENT&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:choose>
    <xsl:when test="$DistUnit = 'Metres'"><xsl:text>     1&#10;</xsl:text></xsl:when>
    <xsl:otherwise><xsl:text>     0&#10;</xsl:text></xsl:otherwise>
  </xsl:choose>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$CELWEIGHT&#10;</xsl:text>

  <xsl:text>370&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$ENDCAPS&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$JOINSTYLE&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$LWDISPLAY&#10;</xsl:text>

  <xsl:text>290&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$INSUNITS&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:choose>
    <xsl:when test="($DistUnit = 'InternationalFeet') or ($DistUnit = 'USSurveyFeet')">
      <xsl:text>     2&#10;</xsl:text>
    </xsl:when>
    <xsl:otherwise><xsl:text>     6&#10;</xsl:text></xsl:otherwise>  <!-- Metres -->
  </xsl:choose>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$HYPERLINKBASE&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$STYLESHEET&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$XEDIT&#10;</xsl:text>

  <xsl:text>290&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$CEPSNTYPE&#10;</xsl:text>

  <xsl:text>380&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PSTYLEMODE&#10;</xsl:text>

  <xsl:text>290&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$FINGERPRINTGUID&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$VERSIONGUID&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$EXTNAMES&#10;</xsl:text>

  <xsl:text>290&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  9&#10;</xsl:text>
  <xsl:text>$PSVPSCALE&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ENDSEC&#10;</xsl:text>

</xsl:template>


<!-- **************************************************************** -->
<!-- ************* Write our all the header Section Items *********** -->
<!-- **************************************************************** -->
<xsl:template name="OutputClassesSection">
  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>SECTION&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>CLASSES&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>CLASS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>LWPOLYLINE&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>AcDbPolyline&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>AutoCAD 2000&#10;</xsl:text>

  <xsl:text> 90&#10;</xsl:text>
  <xsl:text>    32768&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>CLASS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>IMAGE&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>AcDbRasterImage&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>ISM&#10;</xsl:text>

  <xsl:text> 90&#10;</xsl:text>
  <xsl:text>    32895&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>CLASS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>OLE2FRAME&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>AcDbOle2Frame&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>AutoCAD 2000&#10;</xsl:text>

  <xsl:text> 90&#10;</xsl:text>
  <xsl:text>    32768&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>CLASS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>HATCH&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>AcDbHatch&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>AutoCAD 2000&#10;</xsl:text>

  <xsl:text> 90&#10;</xsl:text>
  <xsl:text>    32768&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>CLASS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>DICTIONARYVAR&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>AcDbDictionaryVar&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>AutoCAD 2000&#10;</xsl:text>

  <xsl:text> 90&#10;</xsl:text>
  <xsl:text>    32768&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>CLASS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>RASTERVARIABLES&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>AcDbRasterVariables&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>ISM&#10;</xsl:text>

  <xsl:text> 90&#10;</xsl:text>
  <xsl:text>    32768&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>CLASS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>IMAGEDEF&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>AcDbRasterImageDef&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>ISM&#10;</xsl:text>

  <xsl:text> 90&#10;</xsl:text>
  <xsl:text>    32768&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>CLASS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>IMAGEDEF_REACTOR&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>AcDbRasterImageDefReactor&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>ISM&#10;</xsl:text>

  <xsl:text> 90&#10;</xsl:text>
  <xsl:text>    32769&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>CLASS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>IDBUFFER&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>AcDbIdBuffer&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>AutoCAD 2000&#10;</xsl:text>

  <xsl:text> 90&#10;</xsl:text>
  <xsl:text>    32768&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>CLASS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>SPATIAL_FILTER&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>AcDbSpatialFilter&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>AutoCAD 2000&#10;</xsl:text>

  <xsl:text> 90&#10;</xsl:text>
  <xsl:text>    32768&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>CLASS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>XRECORD&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>AcDbXrecord&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>AutoCAD 2000&#10;</xsl:text>

  <xsl:text> 90&#10;</xsl:text>
  <xsl:text>    32768&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>CLASS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>SORTENTSTABLE&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>AcDbSortentsTable&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>AutoCAD 2000&#10;</xsl:text>

  <xsl:text> 90&#10;</xsl:text>
  <xsl:text>    32768&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>CLASS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>LAYER_INDEX&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>AcDbLayerIndex&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>AutoCAD 2000&#10;</xsl:text>

  <xsl:text> 90&#10;</xsl:text>
  <xsl:text>    32768&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>CLASS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>SPATIAL_INDEX&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>AcDbSpatialIndex&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>AutoCAD 2000&#10;</xsl:text>

  <xsl:text> 90&#10;</xsl:text>
  <xsl:text>    32768&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>CLASS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>OBJECT_PTR&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>CAseDLPNTableRecord&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>&quot;ASE-LPNTableRecord&quot;&#10;</xsl:text>

  <xsl:text> 90&#10;</xsl:text>
  <xsl:text>    32769&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>CLASS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>LAYOUT&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>AcDbLayout&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>AutoCAD 2000&#10;</xsl:text>

  <xsl:text> 90&#10;</xsl:text>
  <xsl:text>        0&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>CLASS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>PLOTSETTINGS&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>AcDbPlotSettings&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>AutoCAD 2000&#10;</xsl:text>

  <xsl:text> 90&#10;</xsl:text>
  <xsl:text>    32768&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>CLASS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>ACDBDICTIONARYWDFLT&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>AcDbDictionaryWithDefault&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>AutoCAD 2000&#10;</xsl:text>

  <xsl:text> 90&#10;</xsl:text>
  <xsl:text>        0&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>CLASS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>ACDBPLACEHOLDER&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>AcDbPlaceHolder&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>AutoCAD 2000&#10;</xsl:text>

  <xsl:text> 90&#10;</xsl:text>
  <xsl:text>        0&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>CLASS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>VBA_PROJECT&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>AcDbVbaProject&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>acadvba&#10;</xsl:text>

  <xsl:text> 90&#10;</xsl:text>
  <xsl:text>    32768&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>CLASS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>WIPEOUT&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>AcDbWipeout&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>WipeOut|AutoCAD Express Tool|expresstools@autodesk.com&#10;</xsl:text>

  <xsl:text> 90&#10;</xsl:text>
  <xsl:text>    32895&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>CLASS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>WIPEOUTVARIABLES&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>AcDbWipeoutVariables&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>WipeOut|AutoCAD Express Tool|expresstools@autodesk.com&#10;</xsl:text>

  <xsl:text> 90&#10;</xsl:text>
  <xsl:text>        0&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>CLASS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>RTEXT&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>RText&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>RText|AutoCAD Express Tool|expresstools@autodesk.com&#10;</xsl:text>

  <xsl:text> 90&#10;</xsl:text>
  <xsl:text>    32768&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>CLASS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>ARCALIGNEDTEXT&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>AcDbArcAlignedText&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>ATEXT|AutoCAD Express Tool|expresstools@autodesk.com&#10;</xsl:text>

  <xsl:text> 90&#10;</xsl:text>
  <xsl:text>    32768&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ENDSEC&#10;</xsl:text>

</xsl:template>


<!-- **************************************************************** -->
<!-- ************* Write out all the Table Section Items ************ -->
<!-- **************************************************************** -->
<xsl:template name="OutputTablesSection">

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>SECTION&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>TABLES&#10;</xsl:text>

  <!-- Write out the Viewport (VPORT) table details -->
  <xsl:call-template name="OutputVPORTTable"/>
  
  <!-- Write out the Linetype (LTYPE) table details -->
  <xsl:call-template name="OutputLTYPETable"/>

  <!-- Write out the Layer (LAYER) table details -->
  <xsl:call-template name="OutputLAYERTable"/>

  <!-- Write out the Style (STYLE) table details -->
  <xsl:call-template name="OutputSTYLETable"/>

  <!-- Write out the View (VIEW) table details -->
  <xsl:call-template name="OutputVIEWTable"/>

  <!-- Write out the User Coordinate System (UCS) table details -->
  <xsl:call-template name="OutputUCSTable"/>

  <!-- Write out the APPID (APPID) table details -->
  <xsl:call-template name="OutputAPPIDTable"/>

  <!-- Write out the Dimension Style (DIMSTYLE) table details -->
  <xsl:call-template name="OutputDIMSTYLETable"/>

  <!-- Write out the Block Record (BLOCK_RECORD) table details -->
  <xsl:call-template name="OutputBLOCKRECORDTable"/>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ENDSEC&#10;</xsl:text>

</xsl:template>


<!-- **************************************************************** -->
<!-- **************** Write out the VPORT Table Items *************** -->
<!-- **************************************************************** -->
<xsl:template name="OutputVPORTTable">

  <!-- Write out the Viewport (VPORT) table details -->
  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>TABLE&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>VPORT&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>8&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTable&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>VPORT&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>25D&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTableRecord&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbViewportTableRecord&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>*ACTIVE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 11&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text> 21&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text> 12&#10;</xsl:text>
  <xsl:call-template name="AverageEast"/>

  <xsl:text> 22&#10;</xsl:text>
  <xsl:call-template name="AverageNorth"/>

  <xsl:text> 13&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 23&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 14&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text> 24&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text> 15&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 25&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 16&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 26&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 36&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text> 17&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 27&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 37&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.000003&#10;</xsl:text>

  <xsl:text> 41&#10;</xsl:text>
  <xsl:text>1.852941&#10;</xsl:text>

  <xsl:text> 42&#10;</xsl:text>
  <xsl:text>50.0&#10;</xsl:text>

  <xsl:text> 43&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 44&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 50&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 51&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 71&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 72&#10;</xsl:text>
  <xsl:text>   100&#10;</xsl:text>

  <xsl:text> 73&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text> 74&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text> 75&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 76&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 77&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 78&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 65&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>110&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>120&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>130&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>111&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>121&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>131&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>112&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>122&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>132&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>345&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>346&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text> 79&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>146&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ENDTAB&#10;</xsl:text>

</xsl:template>


<!-- **************************************************************** -->
<!-- **************** Write out the LTYPE Table Items *************** -->
<!-- **************************************************************** -->
<xsl:template name="OutputLTYPETable">

  <!-- Write out the Linetype (LTYPE) table details -->
  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>TABLE&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>LTYPE&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>5&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTable&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     3&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>LTYPE&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>13&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTableRecord&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbLinetypeTableRecord&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>ByBlock&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>    64&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text> 72&#10;</xsl:text>
  <xsl:text>    65&#10;</xsl:text>

  <xsl:text> 73&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>LTYPE&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>14&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTableRecord&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbLinetypeTableRecord&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>ByLayer&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>    64&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text> 72&#10;</xsl:text>
  <xsl:text>    65&#10;</xsl:text>

  <xsl:text> 73&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>LTYPE&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>15&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTableRecord&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbLinetypeTableRecord&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>CONTINUOUS&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>    64&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>Solid line&#10;</xsl:text>

  <xsl:text> 72&#10;</xsl:text>
  <xsl:text>    65&#10;</xsl:text>

  <xsl:text> 73&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ENDTAB&#10;</xsl:text>

</xsl:template>


<!-- **************************************************************** -->
<!-- **************** Write out the LAYER Table Items *************** -->
<!-- **************************************************************** -->
<xsl:template name="OutputLAYERTable">

  <!-- Write out the Layer (LAYER) table details -->
  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>TABLE&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>LAYER&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>2&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTable&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>LAYER&#10;</xsl:text>   <!-- Create the layer named 0 -->

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>F&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTableRecord&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbLayerTableRecord&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>       <!-- The layer name itself -->

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>     7&#10;</xsl:text>

  <xsl:text>  6&#10;</xsl:text>
  <xsl:text>CONTINUOUS&#10;</xsl:text>

  <xsl:text>290&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>370&#10;</xsl:text>
  <xsl:text>    -3&#10;</xsl:text>

  <xsl:text>390&#10;</xsl:text>
  <xsl:text>25E&#10;</xsl:text>

  <xsl:variable name="initialCounter" select="300"/>
  <!-- Add a reference for the Point_Names, Point_Codes, Point_Elevations and Point_Descriptions layers if being written -->
  <xsl:if test="$addNameCodeElevAsText = 'Yes'">
    <!-- Add the Point_Names layer reference -->
    <xsl:text>  0&#10;</xsl:text>
    <xsl:text>LAYER&#10;</xsl:text>   <!-- Create the layer -->

    <xsl:text>  5&#10;</xsl:text>
    <xsl:value-of select="format-number($initialCounter, $DecPl0, 'Standard')"/>  <!-- Unique ID -->
    <xsl:text>&#10;</xsl:text>

    <xsl:text>100&#10;</xsl:text>
    <xsl:text>AcDbSymbolTableRecord&#10;</xsl:text>

    <xsl:text>100&#10;</xsl:text>
    <xsl:text>AcDbLayerTableRecord&#10;</xsl:text>

    <xsl:text>  2&#10;</xsl:text>
    <xsl:text>Point_Names&#10;</xsl:text>       <!-- The layer name itself -->

    <xsl:text> 70&#10;</xsl:text>
    <xsl:text>     0&#10;</xsl:text>

    <xsl:text> 62&#10;</xsl:text>
    <xsl:text>     7&#10;</xsl:text>

    <xsl:text>  6&#10;</xsl:text>
    <xsl:text>CONTINUOUS&#10;</xsl:text>

    <xsl:text>290&#10;</xsl:text>
    <xsl:text>     1&#10;</xsl:text>

    <xsl:text>370&#10;</xsl:text>
    <xsl:text>    -3&#10;</xsl:text>

    <xsl:text>390&#10;</xsl:text>
    <xsl:text>25E&#10;</xsl:text>

    <!-- Add the Point_Codes layer reference -->
    <xsl:text>  0&#10;</xsl:text>
    <xsl:text>LAYER&#10;</xsl:text>   <!-- Create the layer -->

    <xsl:text>  5&#10;</xsl:text>
    <xsl:value-of select="format-number($initialCounter + 1, $DecPl0, 'Standard')"/>  <!-- Unique ID -->
    <xsl:text>&#10;</xsl:text>

    <xsl:text>100&#10;</xsl:text>
    <xsl:text>AcDbSymbolTableRecord&#10;</xsl:text>

    <xsl:text>100&#10;</xsl:text>
    <xsl:text>AcDbLayerTableRecord&#10;</xsl:text>

    <xsl:text>  2&#10;</xsl:text>
    <xsl:text>Point_Codes&#10;</xsl:text>       <!-- The layer name itself -->

    <xsl:text> 70&#10;</xsl:text>
    <xsl:text>     0&#10;</xsl:text>

    <xsl:text> 62&#10;</xsl:text>
    <xsl:text>     7&#10;</xsl:text>

    <xsl:text>  6&#10;</xsl:text>
    <xsl:text>CONTINUOUS&#10;</xsl:text>

    <xsl:text>290&#10;</xsl:text>
    <xsl:text>     1&#10;</xsl:text>

    <xsl:text>370&#10;</xsl:text>
    <xsl:text>    -3&#10;</xsl:text>

    <xsl:text>390&#10;</xsl:text>
    <xsl:text>25E&#10;</xsl:text>

    <!-- Add the Point_Elevations layer reference -->
    <xsl:text>  0&#10;</xsl:text>
    <xsl:text>LAYER&#10;</xsl:text>   <!-- Create the layer -->

    <xsl:text>  5&#10;</xsl:text>
    <xsl:value-of select="format-number($initialCounter + 2, $DecPl0, 'Standard')"/>  <!-- Unique ID -->
    <xsl:text>&#10;</xsl:text>

    <xsl:text>100&#10;</xsl:text>
    <xsl:text>AcDbSymbolTableRecord&#10;</xsl:text>

    <xsl:text>100&#10;</xsl:text>
    <xsl:text>AcDbLayerTableRecord&#10;</xsl:text>

    <xsl:text>  2&#10;</xsl:text>
    <xsl:text>Point_Elevations&#10;</xsl:text>       <!-- The layer name itself -->

    <xsl:text> 70&#10;</xsl:text>
    <xsl:text>     0&#10;</xsl:text>

    <xsl:text> 62&#10;</xsl:text>
    <xsl:text>     7&#10;</xsl:text>

    <xsl:text>  6&#10;</xsl:text>
    <xsl:text>CONTINUOUS&#10;</xsl:text>

    <xsl:text>290&#10;</xsl:text>
    <xsl:text>     1&#10;</xsl:text>

    <xsl:text>370&#10;</xsl:text>
    <xsl:text>    -3&#10;</xsl:text>

    <xsl:text>390&#10;</xsl:text>
    <xsl:text>25E&#10;</xsl:text>

    <!-- Add the Point_Descriptions layer reference -->
    <xsl:text>  0&#10;</xsl:text>
    <xsl:text>LAYER&#10;</xsl:text>   <!-- Create the layer -->

    <xsl:text>  5&#10;</xsl:text>
    <xsl:value-of select="format-number($initialCounter + 3, $DecPl0, 'Standard')"/>  <!-- Unique ID -->
    <xsl:text>&#10;</xsl:text>

    <xsl:text>100&#10;</xsl:text>
    <xsl:text>AcDbSymbolTableRecord&#10;</xsl:text>

    <xsl:text>100&#10;</xsl:text>
    <xsl:text>AcDbLayerTableRecord&#10;</xsl:text>

    <xsl:text>  2&#10;</xsl:text>
    <xsl:text>Point_Descriptions&#10;</xsl:text>       <!-- The layer name itself -->

    <xsl:text> 70&#10;</xsl:text>
    <xsl:text>     0&#10;</xsl:text>

    <xsl:text> 62&#10;</xsl:text>
    <xsl:text>     7&#10;</xsl:text>

    <xsl:text>  6&#10;</xsl:text>
    <xsl:text>CONTINUOUS&#10;</xsl:text>

    <xsl:text>290&#10;</xsl:text>
    <xsl:text>     1&#10;</xsl:text>

    <xsl:text>370&#10;</xsl:text>
    <xsl:text>    -3&#10;</xsl:text>

    <xsl:text>390&#10;</xsl:text>
    <xsl:text>25E&#10;</xsl:text>
  </xsl:if>

  <xsl:if test="count(/JOBFile/FieldBook/ComputeAreaRecord) != 0">
    <xsl:text>  0&#10;</xsl:text>
    <xsl:text>LAYER&#10;</xsl:text>   <!-- Create the layer -->

    <xsl:text>  5&#10;</xsl:text>
    <xsl:value-of select="format-number($initialCounter + 4, $DecPl0, 'Standard')"/>  <!-- Unique ID -->
    <xsl:text>&#10;</xsl:text>

    <xsl:text>100&#10;</xsl:text>
    <xsl:text>AcDbSymbolTableRecord&#10;</xsl:text>

    <xsl:text>100&#10;</xsl:text>
    <xsl:text>AcDbLayerTableRecord&#10;</xsl:text>

    <xsl:text>  2&#10;</xsl:text>
    <xsl:text>Computed Areas&#10;</xsl:text>       <!-- The layer name itself -->

    <xsl:text> 70&#10;</xsl:text>
    <xsl:text>     0&#10;</xsl:text>

    <xsl:text> 62&#10;</xsl:text>
    <xsl:text>     7&#10;</xsl:text>

    <xsl:text>  6&#10;</xsl:text>
    <xsl:text>CONTINUOUS&#10;</xsl:text>

    <xsl:text>290&#10;</xsl:text>
    <xsl:text>     1&#10;</xsl:text>

    <xsl:text>370&#10;</xsl:text>
    <xsl:text>    -3&#10;</xsl:text>

    <xsl:text>390&#10;</xsl:text>
    <xsl:text>25E&#10;</xsl:text>
  </xsl:if>

  <xsl:if test="count(/JOBFile/FieldBook/ComputeAreaRecord) != 0">
    <xsl:text>  0&#10;</xsl:text>
    <xsl:text>LAYER&#10;</xsl:text>   <!-- Create the layer -->

    <xsl:text>  5&#10;</xsl:text>
    <xsl:value-of select="format-number($initialCounter + 5, $DecPl0, 'Standard')"/>  <!-- Unique ID -->
    <xsl:text>&#10;</xsl:text>

    <xsl:text>100&#10;</xsl:text>
    <xsl:text>AcDbSymbolTableRecord&#10;</xsl:text>

    <xsl:text>100&#10;</xsl:text>
    <xsl:text>AcDbLayerTableRecord&#10;</xsl:text>

    <xsl:text>  2&#10;</xsl:text>
    <xsl:text>Subdivided Areas&#10;</xsl:text>       <!-- The layer name itself -->

    <xsl:text> 70&#10;</xsl:text>
    <xsl:text>     0&#10;</xsl:text>

    <xsl:text> 62&#10;</xsl:text>
    <xsl:text>     7&#10;</xsl:text>

    <xsl:text>  6&#10;</xsl:text>
    <xsl:text>CONTINUOUS&#10;</xsl:text>

    <xsl:text>290&#10;</xsl:text>
    <xsl:text>     1&#10;</xsl:text>

    <xsl:text>370&#10;</xsl:text>
    <xsl:text>    -3&#10;</xsl:text>

    <xsl:text>390&#10;</xsl:text>
    <xsl:text>25E&#10;</xsl:text>
  </xsl:if>

  <!-- Add a reference for all the layers that will be created based on the point codes if splitting into layers -->
  <xsl:if test="$splitIntoLayers = 'Yes'">
    <xsl:variable name="layerNames">
      <xsl:for-each select="/JOBFile/Reductions/Point">
        <xsl:variable name="ptCode" select="Code"/>
        <xsl:if test="count(preceding-sibling::Point[Code = $ptCode]) = 0">
          <xsl:variable name="layerName">
            <xsl:variable name="tempLayer">
              <xsl:choose>
                <xsl:when test="contains($ptCode, ' ')"><xsl:value-of select="substring-before($ptCode, ' ')"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="$ptCode"/></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:value-of select="translate($tempLayer, '&lt;&gt;/\&quot;:;?*|,=` ', '______________')"/>  <!-- Replace any invalid layer characters (<>/\":;?*|,=`) chars with _ character -->
          </xsl:variable>
          <xsl:if test="$layerName != ''">
            <xsl:element name="name">
              <xsl:value-of select="$layerName"/>
            </xsl:element>
          </xsl:if>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:for-each select="msxsl:node-set($layerNames)/name">
      <xsl:text>  0&#10;</xsl:text>
      <xsl:text>LAYER&#10;</xsl:text>   <!-- Create the layer -->

      <xsl:text>  5&#10;</xsl:text>
      <xsl:value-of select="format-number($initialCounter + 6 + position(), $DecPl0, 'Standard')"/>  <!-- Unique ID -->
      <xsl:text>&#10;</xsl:text>

      <xsl:text>100&#10;</xsl:text>
      <xsl:text>AcDbSymbolTableRecord&#10;</xsl:text>

      <xsl:text>100&#10;</xsl:text>
      <xsl:text>AcDbLayerTableRecord&#10;</xsl:text>

      <xsl:text>  2&#10;</xsl:text>
      <xsl:value-of select="."/><xsl:text>&#10;</xsl:text>       <!-- The layer name itself -->

      <xsl:text> 70&#10;</xsl:text>
      <xsl:text>     0&#10;</xsl:text>

      <xsl:text> 62&#10;</xsl:text>
      <xsl:text>     7&#10;</xsl:text>

      <xsl:text>  6&#10;</xsl:text>
      <xsl:text>CONTINUOUS&#10;</xsl:text>

      <xsl:text>290&#10;</xsl:text>
      <xsl:text>     1&#10;</xsl:text>

      <xsl:text>370&#10;</xsl:text>
      <xsl:text>    -3&#10;</xsl:text>

      <xsl:text>390&#10;</xsl:text>
      <xsl:text>25E&#10;</xsl:text>
    </xsl:for-each>
  </xsl:if>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ENDTAB&#10;</xsl:text>

</xsl:template>


<!-- **************************************************************** -->
<!-- **************** Write out the STYLE Table Items *************** -->
<!-- **************************************************************** -->
<xsl:template name="OutputSTYLETable">

  <!-- Write out the Style (STYLE) table details -->
  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>TABLE&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>STYLE&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>3&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTable&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     2&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>STYLE&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>10&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTableRecord&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbTextStyleTableRecord&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>STANDARD&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 41&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text> 50&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 71&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 42&#10;</xsl:text>
  <xsl:text>0.2&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>txt&#10;</xsl:text>

  <xsl:text>  4&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>STYLE&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>1E&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTableRecord&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbTextStyleTableRecord&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>MONOTEXT&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>    64&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 41&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text> 50&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 71&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 42&#10;</xsl:text>
  <xsl:text>0.2&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>txt&#10;</xsl:text>

  <xsl:text>  4&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ENDTAB&#10;</xsl:text>

</xsl:template>


<!-- **************************************************************** -->
<!-- **************** Write out the VIEW Table Items **************** -->
<!-- **************************************************************** -->
<xsl:template name="OutputVIEWTable">

  <!-- Write out the View (VIEW) table details -->
  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>TABLE&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>VIEW&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>6&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTable&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ENDTAB&#10;</xsl:text>

</xsl:template>


<!-- **************************************************************** -->
<!-- ***************** Write out the UCS Table Items **************** -->
<!-- **************************************************************** -->
<xsl:template name="OutputUCSTable">

  <!-- Write out the User Coordinate System (UCS) table details -->
  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>TABLE&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>UCS&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>7&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTable&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ENDTAB&#10;</xsl:text>

</xsl:template>


<!-- **************************************************************** -->
<!-- *************** Write out the APPID Table Items **************** -->
<!-- **************************************************************** -->
<xsl:template name="OutputAPPIDTable">

  <!-- Write out the APPID (APPID) table details -->
  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>TABLE&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>APPID&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>9&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTable&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>APPID&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>11&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTableRecord&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbRegAppTableRecord&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>ACAD&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ENDTAB&#10;</xsl:text>

</xsl:template>


<!-- **************************************************************** -->
<!-- ************** Write out the DIMSTYLE Table Items ************** -->
<!-- **************************************************************** -->
<xsl:template name="OutputDIMSTYLETable">

  <!-- Write out the Dimension Style (DIMSTYLE) table details -->
  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>TABLE&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>DIMSTYLE&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>A&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTable&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbDimStyleTable&#10;</xsl:text>

  <xsl:text> 71&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>DIMSTYLE&#10;</xsl:text>

  <xsl:text>105&#10;</xsl:text>
  <xsl:text>256&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTableRecord&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbDimStyleTableRecord&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>STANDARD&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  4&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text> 41&#10;</xsl:text>
  <xsl:text>0.18&#10;</xsl:text>

  <xsl:text> 42&#10;</xsl:text>
  <xsl:text>0.0625&#10;</xsl:text>

  <xsl:text> 43&#10;</xsl:text>
  <xsl:text>0.38&#10;</xsl:text>

  <xsl:text> 44&#10;</xsl:text>
  <xsl:text>0.18&#10;</xsl:text>

  <xsl:text> 45&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 46&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 47&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 48&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 71&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 72&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 73&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text> 74&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text> 75&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 76&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 77&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 78&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 79&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>140&#10;</xsl:text>
  <xsl:text>0.18&#10;</xsl:text>

  <xsl:text>141&#10;</xsl:text>
  <xsl:text>0.09&#10;</xsl:text>

  <xsl:text>142&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>143&#10;</xsl:text>
  <xsl:text>25.4&#10;</xsl:text>

  <xsl:text>144&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>145&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>146&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>147&#10;</xsl:text>
  <xsl:text>0.09&#10;</xsl:text>

  <xsl:text>148&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>170&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>171&#10;</xsl:text>
  <xsl:text>     2&#10;</xsl:text>

  <xsl:text>172&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>173&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>174&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>175&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>176&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>177&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>178&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>179&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>271&#10;</xsl:text>
  <xsl:text>     4&#10;</xsl:text>

  <xsl:text>272&#10;</xsl:text>
  <xsl:text>     4&#10;</xsl:text>

  <xsl:text>273&#10;</xsl:text>
  <xsl:text>     2&#10;</xsl:text>

  <xsl:text>274&#10;</xsl:text>
  <xsl:text>     2&#10;</xsl:text>

  <xsl:text>275&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>276&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>277&#10;</xsl:text>
  <xsl:text>     2&#10;</xsl:text>

  <xsl:text>278&#10;</xsl:text>
  <xsl:text>    46&#10;</xsl:text>

  <xsl:text>279&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>282&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>283&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>284&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>285&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>286&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>288&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>340&#10;</xsl:text>
  <xsl:text>10&#10;</xsl:text>

  <xsl:text>341&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>342&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>343&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>344&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>371&#10;</xsl:text>
  <xsl:text>    -2&#10;</xsl:text>

  <xsl:text>372&#10;</xsl:text>
  <xsl:text>    -2&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ENDTAB&#10;</xsl:text>

</xsl:template>


<!-- **************************************************************** -->
<!-- ************* Write out the BLOCKRECORD Table Items ************ -->
<!-- **************************************************************** -->
<xsl:template name="OutputBLOCKRECORDTable">

  <!-- Write out the Block Record (BLOCK_RECORD) table details -->
  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>TABLE&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>BLOCK_RECORD&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>1&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTable&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     4&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>BLOCK_RECORD&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>19&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTableRecord&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbBlockTableRecord&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>*MODEL_SPACE&#10;</xsl:text>

  <xsl:text>340&#10;</xsl:text>
  <xsl:text>261&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>BLOCK_RECORD&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>16&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTableRecord&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbBlockTableRecord&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>*PAPER_SPACE&#10;</xsl:text>

  <xsl:text>340&#10;</xsl:text>
  <xsl:text>262&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>BLOCK_RECORD&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>21&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTableRecord&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbBlockTableRecord&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>DOT&#10;</xsl:text>

  <xsl:text>340&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <!-- Reference to Cross block -->
  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>BLOCK_RECORD&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>25&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTableRecord&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbBlockTableRecord&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>CROSS&#10;</xsl:text>

  <xsl:text>340&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <!-- Reference to Diagonal Cross block -->
  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>BLOCK_RECORD&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>2A&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTableRecord&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbBlockTableRecord&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>DIAG_CROSS&#10;</xsl:text>

  <xsl:text>340&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <!-- Reference to Circle block -->
  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>BLOCK_RECORD&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>36&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTableRecord&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbBlockTableRecord&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>CIRCLE&#10;</xsl:text>

  <xsl:text>340&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <!-- Reference to Triangle block -->
  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>BLOCK_RECORD&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>63&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTableRecord&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbBlockTableRecord&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>TRIANGLE&#10;</xsl:text>

  <xsl:text>340&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <!-- Reference to Double Triangle block -->
  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>BLOCK_RECORD&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>69&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbSymbolTableRecord&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbBlockTableRecord&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>DOUBLE_TRIANGLE&#10;</xsl:text>

  <xsl:text>340&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <!-- End of the Table -->
  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ENDTAB&#10;</xsl:text>

</xsl:template>


<!-- **************************************************************** -->
<!-- ****************** Output the Blocks Section ******************* -->
<!-- **************************************************************** -->
<xsl:template name="OutputBlocksSection">

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>SECTION&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>BLOCKS&#10;</xsl:text>

  <xsl:call-template name="OutputDefaultBlocks"/>

  <xsl:call-template name="OutputDotBlock"/>            <!-- Dot symbol -->

  <xsl:call-template name="OutputCrossBlock"/>          <!-- Cross symbol -->
  
  <xsl:call-template name="OutputDiagonalCrossBlock"/>  <!-- Diagonal cross symbol -->

  <xsl:call-template name="OutputCircleBlock"/>         <!-- Circle symbol -->

  <xsl:call-template name="OutputTriangleBlock"/>       <!-- Triangle symbol -->

  <xsl:call-template name="OutputDoubleTriangleBlock"/> <!-- Double Triangle symbol -->

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ENDSEC&#10;</xsl:text>

</xsl:template>


<!-- **************************************************************** -->
<!-- ****************** Output the Default Blocks ******************* -->
<!-- **************************************************************** -->
<xsl:template name="OutputDefaultBlocks">

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>BLOCK&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>1A&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbBlockBegin&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>*MODEL_SPACE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 30&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>*MODEL_SPACE&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ENDBLK&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>1B&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbBlockEnd&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>BLOCK&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>17&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text> 67&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbBlockBegin&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>*PAPER_SPACE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 30&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>*PAPER_SPACE&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ENDBLK&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>18&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text> 67&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbBlockEnd&#10;</xsl:text>

</xsl:template>


<!-- **************************************************************** -->
<!-- ********************* Output the Dot Block ********************* -->
<!-- **************************************************************** -->
<xsl:template name="OutputDotBlock">

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>BLOCK&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>22&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbBlockBegin&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>DOT&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>    66&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text> 30&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>DOT&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ATTDEF&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>266&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbText&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbAttributeDefinition&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>Name&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>NAME&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ATTDEF&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>267&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbText&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbAttributeDefinition&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>Feature Code&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>FEATURE_CODE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>POINT&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>23&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbPoint&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ENDBLK&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>24&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbBlockEnd&#10;</xsl:text>

</xsl:template>


<!-- **************************************************************** -->
<!-- ******************** Output the Cross Block ******************** -->
<!-- **************************************************************** -->
<xsl:template name="OutputCrossBlock">

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>BLOCK&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>26&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbBlockBegin&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>CROSS&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>    66&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text> 30&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>CROSS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ATTDEF&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>268&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbText&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbAttributeDefinition&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>Name&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>NAME&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ATTDEF&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>269&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbText&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbAttributeDefinition&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>Feature Code&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>FEATURE_CODE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>LINE&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>27&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbLine&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text> 11&#10;</xsl:text>
  <xsl:text>200.0&#10;</xsl:text>

  <xsl:text> 21&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>LINE&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>28&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbLine&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>200.0&#10;</xsl:text>

  <xsl:text> 11&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text> 21&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ENDBLK&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>29&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbBlockEnd&#10;</xsl:text>

</xsl:template>


<!-- **************************************************************** -->
<!-- *************** Output the Diagonal Cross Block **************** -->
<!-- **************************************************************** -->
<xsl:template name="OutputDiagonalCrossBlock">

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>BLOCK&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>2B&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbBlockBegin&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>DIAG_CROSS&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>    66&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text> 30&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>DIAG_CROSS&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ATTDEF&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>26A&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbText&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbAttributeDefinition&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>Name&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>NAME&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ATTDEF&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>26B&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbText&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbAttributeDefinition&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>Feature Code&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>FEATURE_CODE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>LINE&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>2C&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbLine&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>200.0&#10;</xsl:text>

  <xsl:text> 11&#10;</xsl:text>
  <xsl:text>200.0&#10;</xsl:text>

  <xsl:text> 21&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>LINE&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>2D&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbLine&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 11&#10;</xsl:text>
  <xsl:text>200.0&#10;</xsl:text>

  <xsl:text> 21&#10;</xsl:text>
  <xsl:text>200.0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ENDBLK&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>2E&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbBlockEnd&#10;</xsl:text>

</xsl:template>


<!-- **************************************************************** -->
<!-- ******************* Output the Circle Block ******************** -->
<!-- **************************************************************** -->
<xsl:template name="OutputCircleBlock">

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>BLOCK&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>37&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbBlockBegin&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>CIRCLE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>    66&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text> 30&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>CIRCLE&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ATTDEF&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>26E&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbText&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbAttributeDefinition&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>Name&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>NAME&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ATTDEF&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>26F&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbText&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbAttributeDefinition&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>Feature Code&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>FEATURE_CODE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ARC&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>38&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbCircle&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbArc&#10;</xsl:text>

  <xsl:text> 50&#10;</xsl:text>
  <xsl:text>270.0&#10;</xsl:text>

  <xsl:text> 51&#10;</xsl:text>
  <xsl:text>90.0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ARC&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>39&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbCircle&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbArc&#10;</xsl:text>

  <xsl:text> 50&#10;</xsl:text>
  <xsl:text>90.0&#10;</xsl:text>

  <xsl:text> 51&#10;</xsl:text>
  <xsl:text>270.0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ENDBLK&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>3A&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbBlockEnd&#10;</xsl:text>

</xsl:template>


<!-- **************************************************************** -->
<!-- ****************** Output the Triangle Block ******************* -->
<!-- **************************************************************** -->
<xsl:template name="OutputTriangleBlock">

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>BLOCK&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>64&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbBlockBegin&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>TRIANGLE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>    66&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>80.0&#10;</xsl:text>

  <xsl:text> 30&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>TRIANGLE&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ATTDEF&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>274&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbText&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbAttributeDefinition&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>Name&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>NAME&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ATTDEF&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>275&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbText&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbAttributeDefinition&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>Feature Code&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>FEATURE_CODE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>LINE&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>65&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbLine&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>20.0&#10;</xsl:text>

  <xsl:text> 11&#10;</xsl:text>
  <xsl:text>200.0&#10;</xsl:text>

  <xsl:text> 21&#10;</xsl:text>
  <xsl:text>20.0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>LINE&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>66&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbLine&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>20.0&#10;</xsl:text>

  <xsl:text> 11&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text> 21&#10;</xsl:text>
  <xsl:text>190.0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>LINE&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>67&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbLine&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>190.0&#10;</xsl:text>

  <xsl:text> 11&#10;</xsl:text>
  <xsl:text>200.0&#10;</xsl:text>

  <xsl:text> 21&#10;</xsl:text>
  <xsl:text>20.0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ENDBLK&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>68&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbBlockEnd&#10;</xsl:text>

</xsl:template>


<!-- **************************************************************** -->
<!-- ************** Output the Double Triangle Block **************** -->
<!-- **************************************************************** -->
<xsl:template name="OutputDoubleTriangleBlock">

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>BLOCK&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>6A&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbBlockBegin&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>DOUBLE_TRIANGLE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>    66&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>80.0&#10;</xsl:text>

  <xsl:text> 30&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>DOUBLE_TRIANGLE&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ATTDEF&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>276&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbText&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbAttributeDefinition&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>Name&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>NAME&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ATTDEF&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>277&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbText&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbAttributeDefinition&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>Feature Code&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>FEATURE_CODE&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>LINE&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>6B&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbLine&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>190.0&#10;</xsl:text>

  <xsl:text> 11&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 21&#10;</xsl:text>
  <xsl:text>20.0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>LINE&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>6C&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbLine&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>200.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>20.0&#10;</xsl:text>

  <xsl:text> 11&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text> 21&#10;</xsl:text>
  <xsl:text>190.0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>LINE&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>6D&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbLine&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>20.0&#10;</xsl:text>

  <xsl:text> 11&#10;</xsl:text>
  <xsl:text>200.0&#10;</xsl:text>

  <xsl:text> 21&#10;</xsl:text>
  <xsl:text>20.0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>LINE&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>6E&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbLine&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>52.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>50.0&#10;</xsl:text>

  <xsl:text> 11&#10;</xsl:text>
  <xsl:text>148.0&#10;</xsl:text>

  <xsl:text> 21&#10;</xsl:text>
  <xsl:text>50.0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>LINE&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>6F&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbLine&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>52.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>50.0&#10;</xsl:text>

  <xsl:text> 11&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text> 21&#10;</xsl:text>
  <xsl:text>134.0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>LINE&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>70&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbLine&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>100.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>134.0&#10;</xsl:text>

  <xsl:text> 11&#10;</xsl:text>
  <xsl:text>148.0&#10;</xsl:text>

  <xsl:text> 21&#10;</xsl:text>
  <xsl:text>50.0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ENDBLK&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>71&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbBlockEnd&#10;</xsl:text>

</xsl:template>


<!-- **************************************************************** -->
<!-- ********* Output the header for the Entities Section *********** -->
<!-- **************************************************************** -->
<xsl:template name="OutputEntititesSectionHeader">

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>SECTION&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>ENTITIES&#10;</xsl:text>

</xsl:template>


<!-- **************************************************************** -->
<!-- ***************** Output an empty Objects Section ************** -->
<!-- **************************************************************** -->
<xsl:template name="OutputObjectsSection">

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>SECTION&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>OBJECTS&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>DICTIONARY&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>C&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbDictionary&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>ACAD_GROUP&#10;</xsl:text>

  <xsl:text>350&#10;</xsl:text>
  <xsl:text>D&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>ACAD_MLINESTYLE&#10;</xsl:text>

  <xsl:text>350&#10;</xsl:text>
  <xsl:text>E&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>ACAD_LAYOUT&#10;</xsl:text>

  <xsl:text>350&#10;</xsl:text>
  <xsl:text>25F&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>ACAD_PLOTSETTINGS&#10;</xsl:text>

  <xsl:text>350&#10;</xsl:text>
  <xsl:text>263&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>ACAD_PLOTSTYLENAME&#10;</xsl:text>

  <xsl:text>350&#10;</xsl:text>
  <xsl:text>260&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>ACAD_WIPEOUT_VARS&#10;</xsl:text>

  <xsl:text>350&#10;</xsl:text>
  <xsl:text>264&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>DICTIONARY&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>D&#10;</xsl:text>

  <xsl:text>102&#10;</xsl:text>
  <xsl:text>{ACAD_REACTORS&#10;</xsl:text>

  <xsl:text>330&#10;</xsl:text>
  <xsl:text>C&#10;</xsl:text>

  <xsl:text>102&#10;</xsl:text>
  <xsl:text>}&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbDictionary&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>DICTIONARY&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>E&#10;</xsl:text>

  <xsl:text>102&#10;</xsl:text>
  <xsl:text>{ACAD_REACTORS&#10;</xsl:text>

  <xsl:text>330&#10;</xsl:text>
  <xsl:text>C&#10;</xsl:text>

  <xsl:text>102&#10;</xsl:text>
  <xsl:text>}&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbDictionary&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>STANDARD&#10;</xsl:text>

  <xsl:text>350&#10;</xsl:text>
  <xsl:text>1C&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>MLINESTYLE&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>1C&#10;</xsl:text>

  <xsl:text>102&#10;</xsl:text>
  <xsl:text>{ACAD_REACTORS&#10;</xsl:text>

  <xsl:text>330&#10;</xsl:text>
  <xsl:text>E&#10;</xsl:text>

  <xsl:text>102&#10;</xsl:text>
  <xsl:text>}&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbMlineStyle&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>STANDARD&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 51&#10;</xsl:text>
  <xsl:text>90.0&#10;</xsl:text>

  <xsl:text> 52&#10;</xsl:text>
  <xsl:text>90.0&#10;</xsl:text>

  <xsl:text> 71&#10;</xsl:text>
  <xsl:text>     2&#10;</xsl:text>

  <xsl:text> 49&#10;</xsl:text>
  <xsl:text>0.5&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>   256&#10;</xsl:text>

  <xsl:text>  6&#10;</xsl:text>
  <xsl:text>ByLayer&#10;</xsl:text>

  <xsl:text> 49&#10;</xsl:text>
  <xsl:text>-0.5&#10;</xsl:text>

  <xsl:text> 62&#10;</xsl:text>
  <xsl:text>   256&#10;</xsl:text>

  <xsl:text>  6&#10;</xsl:text>
  <xsl:text>ByLayer&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ACDBDICTIONARYWDFLT&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>260&#10;</xsl:text>

  <xsl:text>102&#10;</xsl:text>
  <xsl:text>{ACAD_REACTORS&#10;</xsl:text>

  <xsl:text>330&#10;</xsl:text>
  <xsl:text>C&#10;</xsl:text>

  <xsl:text>102&#10;</xsl:text>
  <xsl:text>}&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbDictionary&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>Normal&#10;</xsl:text>

  <xsl:text>350&#10;</xsl:text>
  <xsl:text>25E&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbDictionaryWithDefault&#10;</xsl:text>

  <xsl:text>340&#10;</xsl:text>
  <xsl:text>25E&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ACDBPLACEHOLDER&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>25E&#10;</xsl:text>

  <xsl:text>102&#10;</xsl:text>
  <xsl:text>{ACAD_REACTORS&#10;</xsl:text>

  <xsl:text>330&#10;</xsl:text>
  <xsl:text>260&#10;</xsl:text>

  <xsl:text>102&#10;</xsl:text>
  <xsl:text>}&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>LAYOUT&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>261&#10;</xsl:text>

  <xsl:text>102&#10;</xsl:text>
  <xsl:text>{ACAD_REACTORS&#10;</xsl:text>

  <xsl:text>330&#10;</xsl:text>
  <xsl:text>25F&#10;</xsl:text>

  <xsl:text>102&#10;</xsl:text>
  <xsl:text>}&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbPlotSettings&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  4&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  6&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 41&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 42&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 43&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 44&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 45&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 46&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 47&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 48&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 49&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>140&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>141&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>142&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>143&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>  1024&#10;</xsl:text>

  <xsl:text> 72&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 73&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 74&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  7&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text> 75&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>147&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>148&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>149&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbLayout&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>Model&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 71&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 11&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 21&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 12&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 22&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 32&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 14&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 24&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 34&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 15&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 25&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 35&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>146&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 13&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 23&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 33&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 16&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 26&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 36&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 17&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 27&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 37&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 76&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>330&#10;</xsl:text>
  <xsl:text>19&#10;</xsl:text>

  <xsl:text>331&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>345&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>346&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>LAYOUT&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>262&#10;</xsl:text>

  <xsl:text>102&#10;</xsl:text>
  <xsl:text>{ACAD_REACTORS&#10;</xsl:text>

  <xsl:text>330&#10;</xsl:text>
  <xsl:text>25F&#10;</xsl:text>

  <xsl:text>102&#10;</xsl:text>
  <xsl:text>}&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbPlotSettings&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  2&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  4&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text>  6&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text> 40&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 41&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 42&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 43&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 44&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 45&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 46&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 47&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 48&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 49&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>140&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>141&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>142&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>143&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 72&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 73&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 74&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>  7&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>

  <xsl:text> 75&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>147&#10;</xsl:text>
  <xsl:text>1.0&#10;</xsl:text>

  <xsl:text>148&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>149&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbLayout&#10;</xsl:text>

  <xsl:text>  1&#10;</xsl:text>
  <xsl:text>Layout1&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 71&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text> 10&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 20&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 11&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 21&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 12&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 22&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 32&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 14&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 24&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 34&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 15&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 25&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 35&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text>146&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 13&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 23&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 33&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 16&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 26&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 36&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 17&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 27&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 37&#10;</xsl:text>
  <xsl:text>0.0&#10;</xsl:text>

  <xsl:text> 76&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>330&#10;</xsl:text>
  <xsl:text>16&#10;</xsl:text>

  <xsl:text>331&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>345&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>346&#10;</xsl:text>
  <xsl:text>0&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>DICTIONARY&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>25F&#10;</xsl:text>

  <xsl:text>102&#10;</xsl:text>
  <xsl:text>{ACAD_REACTORS&#10;</xsl:text>

  <xsl:text>330&#10;</xsl:text>
  <xsl:text>C&#10;</xsl:text>

  <xsl:text>102&#10;</xsl:text>
  <xsl:text>}&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbDictionary&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>Layout1&#10;</xsl:text>

  <xsl:text>350&#10;</xsl:text>
  <xsl:text>262&#10;</xsl:text>

  <xsl:text>  3&#10;</xsl:text>
  <xsl:text>Model&#10;</xsl:text>

  <xsl:text>350&#10;</xsl:text>
  <xsl:text>261&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>DICTIONARY&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>263&#10;</xsl:text>

  <xsl:text>102&#10;</xsl:text>
  <xsl:text>{ACAD_REACTORS&#10;</xsl:text>

  <xsl:text>330&#10;</xsl:text>
  <xsl:text>C&#10;</xsl:text>

  <xsl:text>102&#10;</xsl:text>
  <xsl:text>}&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbDictionary&#10;</xsl:text>

  <xsl:text>280&#10;</xsl:text>
  <xsl:text>     0&#10;</xsl:text>

  <xsl:text>281&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>WIPEOUTVARIABLES&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:text>264&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbWipeoutVariables&#10;</xsl:text>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     1&#10;</xsl:text>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ENDSEC&#10;</xsl:text>

</xsl:template>


<!-- **************************************************************** -->
<!-- ************ Output the end of the Entities Section ************ -->
<!-- **************************************************************** -->
<xsl:template name="OutputEndOfEntititesSection">

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ENDSEC&#10;</xsl:text>

</xsl:template>


<!-- **************************************************************** -->
<!-- ************ Output the end of the Entities Section ************ -->
<!-- **************************************************************** -->
<xsl:template name="OutputEndOfFile">

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>EOF&#10;</xsl:text>

</xsl:template>


<!-- **************************************************************** -->
<!-- ************** Output the minimum Coord values **************** -->
<!-- **************************************************************** -->
<xsl:template name="MinCoords">
  <xsl:param name="threeDVals" select="1"/>
  
  <xsl:variable name="pointsSortN">
    <xsl:for-each select="/JOBFile/Reductions/Point[Grid/North != '']">
      <xsl:sort data-type="number" order="ascending" select="Grid/North"/>
      <xsl:copy>
        <xsl:copy-of select="Grid/North" />
      </xsl:copy>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="minN">
    <xsl:value-of select="msxsl:node-set($pointsSortN)/Point[1]/North"/>
  </xsl:variable>

  <xsl:variable name="pointsSortE">
    <xsl:for-each select="/JOBFile/Reductions/Point[Grid/East != '']">
      <xsl:sort data-type="number" order="ascending" select="Grid/East"/>
      <xsl:copy>
        <xsl:copy-of select="Grid/East" />
      </xsl:copy>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="minE">
    <xsl:value-of select="msxsl:node-set($pointsSortE)/Point[1]/East"/>
  </xsl:variable>

  <xsl:variable name="pointsSortElev">
    <xsl:for-each select="/JOBFile/Reductions/Point[Grid/Elevation != '']">
      <xsl:sort data-type="number" order="ascending" select="Grid/Elevation"/>
      <xsl:copy>
        <xsl:copy-of select="Grid/Elevation" />
      </xsl:copy>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="minElev">
    <xsl:value-of select="msxsl:node-set($pointsSortElev)/Point[1]/Elevation"/>
  </xsl:variable>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="east" select="$minE * $DistConvFactor"/>
    <xsl:with-param name="north" select="$minN * $DistConvFactor"/>
    <xsl:with-param name="elev" select="$minElev * $DistConvFactor"/>
    <xsl:with-param name="decPlaces" select="3"/>
    <xsl:with-param name="threeDVals" select="$threeDVals"/>
  </xsl:call-template>
</xsl:template>


<!-- **************************************************************** -->
<!-- ************** Output the maximum Coord values **************** -->
<!-- **************************************************************** -->
<xsl:template name="MaxCoords">
  <xsl:param name="threeDVals" select="1"/>

  <xsl:variable name="pointsSortN">
    <xsl:for-each select="/JOBFile/Reductions/Point[Grid/North != '']">
      <xsl:sort data-type="number" order="descending" select="Grid/North"/>
      <xsl:copy>
        <xsl:copy-of select="Grid/North" />
      </xsl:copy>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="maxN">
    <xsl:value-of select="msxsl:node-set($pointsSortN)/Point[1]/North"/>
  </xsl:variable>

  <xsl:variable name="pointsSortE">
    <xsl:for-each select="/JOBFile/Reductions/Point[Grid/East != '']">
      <xsl:sort data-type="number" order="descending" select="Grid/East"/>
      <xsl:copy>
        <xsl:copy-of select="Grid/East" />
      </xsl:copy>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="maxE">
    <xsl:value-of select="msxsl:node-set($pointsSortE)/Point[1]/East"/>
  </xsl:variable>

  <xsl:variable name="pointsSortElev">
    <xsl:for-each select="/JOBFile/Reductions/Point[Grid/Elevation != '']">
      <xsl:sort data-type="number" order="descending" select="Grid/Elevation"/>
      <xsl:copy>
        <xsl:copy-of select="Grid/Elevation" />
      </xsl:copy>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="maxElev">
    <xsl:value-of select="msxsl:node-set($pointsSortElev)/Point[1]/Elevation"/>
  </xsl:variable>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="east" select="$maxE * $DistConvFactor"/>
    <xsl:with-param name="north" select="$maxN * $DistConvFactor"/>
    <xsl:with-param name="elev" select="$maxElev * $DistConvFactor"/>
    <xsl:with-param name="decPlaces" select="3"/>
    <xsl:with-param name="threeDVals" select="$threeDVals"/>
  </xsl:call-template>
</xsl:template>


<!-- **************************************************************** -->
<!-- *************** Return the Average North value ***************** -->
<!-- **************************************************************** -->
<xsl:template name="AverageNorth">

  <xsl:variable name="pointsSortN">
    <xsl:for-each select="/JOBFile/Reductions/Point[Grid/North != '']">
      <xsl:sort data-type="number" order="ascending" select="Grid/North"/>
      <xsl:copy>
        <xsl:copy-of select="Grid/North" />
      </xsl:copy>
    </xsl:for-each>
  </xsl:variable>

  <xsl:value-of select="format-number((msxsl:node-set($pointsSortN)/Point[1]/North +
                                       msxsl:node-set($pointsSortN)/Point[last()]/North) div 2 * $DistConvFactor, $coordDecPlStr, 'Standard')"/>
  <xsl:text>&#10;</xsl:text>  <!-- Output new line -->

</xsl:template>


<!-- **************************************************************** -->
<!-- **************** Return the Average East value ***************** -->
<!-- **************************************************************** -->
<xsl:template name="AverageEast">

  <xsl:variable name="pointsSortE">
    <xsl:for-each select="/JOBFile/Reductions/Point[Grid/East != '']">
      <xsl:sort data-type="number" order="ascending" select="Grid/East"/>
      <xsl:copy>
        <xsl:copy-of select="Grid/East" />
      </xsl:copy>
    </xsl:for-each>
  </xsl:variable>

  <xsl:value-of select="format-number((msxsl:node-set($pointsSortE)/Point[1]/East +
                                       msxsl:node-set($pointsSortE)/Point[last()]/East) div 2 * $DistConvFactor, $coordDecPlStr, 'Standard')"/>
  <xsl:text>&#10;</xsl:text>  <!-- Output new line -->

</xsl:template>


<!-- **************************************************************** -->
<!-- **************** Output the Coordinate Records ***************** -->
<!-- **************************************************************** -->
<xsl:template name="OutputCoordVals">
  <xsl:param name="east" select="0"/>
  <xsl:param name="north" select="0"/>
  <xsl:param name="elev" select="0"/>
  <xsl:param name="decPlaces" select="6"/>
  <xsl:param name="threeDVals" select="1"/>
  <xsl:param name="endPoint" select="0"/>

  <xsl:variable name="decPl">
    <xsl:choose>
      <xsl:when test="$decPlaces = 1"><xsl:value-of select="$DecPl1"/></xsl:when>
      <xsl:when test="$decPlaces = 2"><xsl:value-of select="$DecPl2"/></xsl:when>
      <xsl:when test="$decPlaces = 3"><xsl:value-of select="$DecPl3"/></xsl:when>
      <xsl:when test="$decPlaces = 4"><xsl:value-of select="$DecPl4"/></xsl:when>
      <xsl:when test="$decPlaces = 5"><xsl:value-of select="$DecPl5"/></xsl:when>
      <xsl:when test="$decPlaces = 6"><xsl:value-of select="$DecPl6"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$DecPl3"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:if test="not($endPoint)"><xsl:text> 10&#10;</xsl:text></xsl:if>
  <xsl:if test="$endPoint"><xsl:text> 11&#10;</xsl:text></xsl:if>
  <xsl:value-of select="format-number($east, $decPl, 'Standard')"/><xsl:text>&#10;</xsl:text>

  <xsl:if test="not($endPoint)"><xsl:text> 20&#10;</xsl:text></xsl:if>
  <xsl:if test="$endPoint"><xsl:text> 21&#10;</xsl:text></xsl:if>
  <xsl:value-of select="format-number($north, $decPl, 'Standard')"/><xsl:text>&#10;</xsl:text>

  <xsl:if test="$threeDVals and (string(number($elev)) != 'NaN')">
    <xsl:if test="not($endPoint)"><xsl:text> 30&#10;</xsl:text></xsl:if>
    <xsl:if test="$endPoint"><xsl:text> 31&#10;</xsl:text></xsl:if>
    <xsl:value-of select="format-number($elev, $decPl, 'Standard')"/><xsl:text>&#10;</xsl:text>
  </xsl:if>
</xsl:template>


<!-- **************************************************************** -->
<!-- ********** Function to export all the reduced points *********** -->
<!-- **************************************************************** -->
<xsl:template name="ExportData">

  <!-- Set up a node variable to contain all the reduced points - include extra elements -->
  <!-- to hold the name and code as they need to have unique IDs assigned to them and    -->
  <!-- the position() function can be used to provide this.                              -->

  <xsl:variable name="pointData">
    <xsl:for-each select="/JOBFile/Reductions/Point">
      <xsl:element name="Coords">
        <xsl:copy-of select="Grid"/>
        <xsl:copy-of select="Name"/>
        <xsl:copy-of select="Code"/>
      </xsl:element>
      
      <xsl:copy-of select="Name"/>

      <xsl:if test="Code != ''">
        <xsl:copy-of select="Code"/>
      </xsl:if>

      <xsl:if test="string(number(Grid/Elevation)) != 'NaN'">
        <xsl:copy-of select="Grid/Elevation"/>
      </xsl:if>

      <xsl:copy-of select="Description1"/>

      <xsl:copy-of select="Description2"/>

      <xsl:for-each select="Features/Feature">
        <xsl:copy-of select="Attribute"/>
      </xsl:for-each>

      <xsl:element name="Counter">
      </xsl:element>

      <xsl:element name="textName">
        <xsl:value-of select="Name"/>
      </xsl:element>

      <xsl:if test="Code != ''">
        <xsl:element name="textCode">
          <xsl:value-of select="Code"/>
        </xsl:element>
      </xsl:if>

      <xsl:if test="string(number(Grid/Elevation)) != 'NaN'">
        <xsl:element name="textElev">
          <xsl:value-of select="Grid/Elevation"/>
        </xsl:element>
      </xsl:if>

      <xsl:if test="Description1">
        <xsl:element name="textDesc1">
          <xsl:value-of select="Description1"/>
        </xsl:element>
      </xsl:if>

      <xsl:if test="Description2">
        <xsl:element name="textDesc2">
          <xsl:value-of select="Description2"/>
        </xsl:element>
      </xsl:if>

    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="elementStartCount" select="800"/>  <!-- Set a reasonably high initial start count -->

  <xsl:for-each select="msxsl:node-set($pointData)/*">

    <xsl:choose>
      <xsl:when test="name(.) = 'Coords'">
        <xsl:if test="(string(number(Grid/East)) != 'NaN') and (string(number(Grid/North)) != 'NaN')">  <!-- Coords not null -->
          <xsl:text>  0&#10;</xsl:text>
          <xsl:text>INSERT&#10;</xsl:text>

          <xsl:text>  5&#10;</xsl:text>
          <xsl:value-of select="format-number($elementStartCount + position(), '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbEntity&#10;</xsl:text>

          <xsl:variable name="layer">
            <xsl:if test="$splitIntoLayers = 'Yes'">
              <xsl:variable name="tempLayer">
                <xsl:choose>
                  <xsl:when test="contains(Code, ' ')"><xsl:value-of select="substring-before(Code, ' ')"/></xsl:when>
                  <xsl:when test="Code = ''"><xsl:value-of select="'0'"/></xsl:when>
                  <xsl:otherwise><xsl:value-of select="Code"/></xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:value-of select="translate($tempLayer, '&lt;&gt;/\&quot;:;?*|,=` ', '______________')"/>  <!-- Replace any invalid layer characters (<>/\":;?*|,=`) chars with _ character -->
            </xsl:if>
            <xsl:if test="$splitIntoLayers != 'Yes'">
              <xsl:value-of select="'0'"/>  <!-- Use layer 0 -->
            </xsl:if>
          </xsl:variable>

          <xsl:text>  8&#10;</xsl:text>
          <xsl:value-of select="$layer"/><xsl:text>&#10;</xsl:text>  <!-- Inserted into layer $layer -->

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbBlockReference&#10;</xsl:text>

          <xsl:text> 66&#10;</xsl:text>
          <xsl:text>     1&#10;</xsl:text>

          <xsl:text>  2&#10;</xsl:text>
          <xsl:value-of select="$blockName"/><xsl:text>&#10;</xsl:text>

          <xsl:text> 10&#10;</xsl:text>
          <xsl:value-of select="format-number(Grid/East * $DistConvFactor, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:text> 20&#10;</xsl:text>
          <xsl:value-of select="format-number(Grid/North * $DistConvFactor, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:if test="Grid/Elevation != ''">
            <xsl:text> 30&#10;</xsl:text>
            <xsl:value-of select="format-number(Grid/Elevation * $DistConvFactor, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>
          </xsl:if>

          <xsl:text> 41&#10;</xsl:text>          <!-- X scale factor -->
          <xsl:text>0.01&#10;</xsl:text>

          <xsl:text> 42&#10;</xsl:text>          <!-- Y scale factor -->
          <xsl:text>0.01&#10;</xsl:text>

          <xsl:text> 43&#10;</xsl:text>          <!-- Z scale factor -->
          <xsl:text>0.01&#10;</xsl:text>
        </xsl:if>
      </xsl:when>

      <!-- Output the name attribute if not null coordinates for point -->
      <xsl:when test="name(.) = 'Name'">
        <xsl:variable name="east">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/East"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="north">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/North"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="elevation">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/Elevation"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:if test="(string(number($east)) != 'NaN') and (string(number($north)) != 'NaN')">  <!-- Coords are not null -->
          <xsl:text>  0&#10;</xsl:text>
          <xsl:text>ATTRIB&#10;</xsl:text>

          <xsl:text>  5&#10;</xsl:text>
          <xsl:value-of select="format-number($elementStartCount + position(), '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbEntity&#10;</xsl:text>

          <xsl:text>  8&#10;</xsl:text>
          <xsl:text>0&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbText&#10;</xsl:text>

          <xsl:text> 10&#10;</xsl:text>   <!-- East value for name attribute - offset 0.4 -->
          <xsl:value-of select="format-number($east * $DistConvFactor + 0.4, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:text> 20&#10;</xsl:text>   <!-- North value for name attribute - offset 0.4 -->
          <xsl:value-of select="format-number($north * $DistConvFactor + 0.4, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:if test="string(number($elevation)) != 'NaN'">
            <xsl:text> 30&#10;</xsl:text>
            <xsl:value-of select="format-number($elevation * $DistConvFactor, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>
          </xsl:if>

          <xsl:text> 40&#10;</xsl:text>
          <xsl:text>1.0&#10;</xsl:text>

          <xsl:text>  1&#10;</xsl:text>
          <xsl:value-of select="."/><xsl:text>&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbAttribute&#10;</xsl:text>

          <xsl:text>  2&#10;</xsl:text>
          <xsl:text>NAME&#10;</xsl:text>

          <xsl:text> 70&#10;</xsl:text>
          <xsl:text>     0&#10;</xsl:text>
        </xsl:if>
      </xsl:when>

      <!-- Output the feature code attribute if present -->
      <xsl:when test="name(.) = 'Code'">
        <xsl:variable name="east">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/East"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="north">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/North"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="elevation">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/Elevation"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:if test="(string(number($east)) != 'NaN') and (string(number($north)) != 'NaN')">  <!-- Coords are not null -->
          <xsl:text>  0&#10;</xsl:text>
          <xsl:text>ATTRIB&#10;</xsl:text>

          <xsl:text>  5&#10;</xsl:text>
          <xsl:value-of select="format-number($elementStartCount + position(), '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbEntity&#10;</xsl:text>

          <xsl:text>  8&#10;</xsl:text>
          <xsl:text>0&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbText&#10;</xsl:text>

          <xsl:text> 10&#10;</xsl:text>   <!-- East value for code attribute - offset 0.4 -->
          <xsl:value-of select="format-number($east * $DistConvFactor + 0.4, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:variable name="vertOffset">
            <xsl:variable name="prevNamePos">
              <xsl:for-each select="preceding-sibling::*">
                <xsl:if test="name(.) = 'Name'">
                  <xsl:element name="posn">
                    <xsl:value-of select="position()"/>
                  </xsl:element>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:value-of select="(position() - msxsl:node-set($prevNamePos)/posn[last()]) * 1.4"/>
          </xsl:variable>
          
          <xsl:text> 20&#10;</xsl:text>   <!-- North value for code attribute - offset to allow for preceding attributes -->
          <xsl:value-of select="format-number($north * $DistConvFactor - $vertOffset, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:if test="string(number($elevation)) != 'NaN'">
            <xsl:text> 30&#10;</xsl:text>
            <xsl:value-of select="format-number($elevation * $DistConvFactor, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>
          </xsl:if>

          <xsl:text> 40&#10;</xsl:text>
          <xsl:text>1.0&#10;</xsl:text>

          <xsl:text>  1&#10;</xsl:text>
          <xsl:value-of select="."/><xsl:text>&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbAttribute&#10;</xsl:text>

          <xsl:text>  2&#10;</xsl:text>
          <xsl:text>FEATURE_CODE&#10;</xsl:text>

          <xsl:text> 70&#10;</xsl:text>
          <xsl:text>     0&#10;</xsl:text>
        </xsl:if>
      </xsl:when>

      <!-- Output the elevation attribute if present -->
      <xsl:when test="(name(.) = 'Elevation') and
                      (string(number(preceding-sibling::Coords[1]/Grid/Elevation)) != 'NaN')">
        <xsl:variable name="east">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/East"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="north">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/North"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="elevation">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/Elevation"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:if test="(string(number($east)) != 'NaN') and (string(number($north)) != 'NaN')">  <!-- Coords are not null -->
          <xsl:text>  0&#10;</xsl:text>
          <xsl:text>ATTRIB&#10;</xsl:text>

          <xsl:text>  5&#10;</xsl:text>
          <xsl:value-of select="format-number($elementStartCount + position(), '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbEntity&#10;</xsl:text>

          <xsl:text>  8&#10;</xsl:text>
          <xsl:text>0&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbText&#10;</xsl:text>

          <xsl:text> 10&#10;</xsl:text>   <!-- East value for elevation attribute - offset 0.4 -->
          <xsl:value-of select="format-number($east * $DistConvFactor + 0.4, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:variable name="vertOffset">
            <xsl:variable name="prevNamePos">
              <xsl:for-each select="preceding-sibling::*">
                <xsl:if test="name(.) = 'Name'">
                  <xsl:element name="posn">
                    <xsl:value-of select="position()"/>
                  </xsl:element>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:value-of select="(position() - msxsl:node-set($prevNamePos)/posn[last()]) * 1.4"/>
          </xsl:variable>

          <xsl:text> 20&#10;</xsl:text>   <!-- North value for elevation attribute - offset to allow for preceding attributes -->
          <xsl:value-of select="format-number($north * $DistConvFactor - $vertOffset, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:if test="string(number($elevation)) != 'NaN'">
            <xsl:text> 30&#10;</xsl:text>
            <xsl:value-of select="format-number($elevation * $DistConvFactor, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>
          </xsl:if>

          <xsl:text> 40&#10;</xsl:text>
          <xsl:text>1.0&#10;</xsl:text>

          <xsl:text>  1&#10;</xsl:text>
          <xsl:value-of select="format-number($elevation * $DistConvFactor, $DecPl3, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbAttribute&#10;</xsl:text>

          <xsl:text>  2&#10;</xsl:text>
          <xsl:text>ELEVATION&#10;</xsl:text>

          <xsl:text> 70&#10;</xsl:text>
          <xsl:text>     0&#10;</xsl:text>
        </xsl:if>
      </xsl:when>

      <!-- Output the Description1 attribute if present -->
      <xsl:when test="name(.) = 'Description1'">
        <xsl:variable name="east">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/East"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="north">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/North"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="elevation">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/Elevation"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:if test="(string(number($east)) != 'NaN') and (string(number($north)) != 'NaN')">  <!-- Coords are not null -->
          <xsl:text>  0&#10;</xsl:text>
          <xsl:text>ATTRIB&#10;</xsl:text>

          <xsl:text>  5&#10;</xsl:text>
          <xsl:value-of select="format-number($elementStartCount + position(), '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbEntity&#10;</xsl:text>

          <xsl:text>  8&#10;</xsl:text>
          <xsl:text>0&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbText&#10;</xsl:text>

          <xsl:text> 10&#10;</xsl:text>   <!-- East value for Description1 attribute - offset 0.4 -->
          <xsl:value-of select="format-number($east * $DistConvFactor + 0.4, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:variable name="vertOffset">
            <xsl:variable name="prevNamePos">
              <xsl:for-each select="preceding-sibling::*">
                <xsl:if test="name(.) = 'Name'">
                  <xsl:element name="posn">
                    <xsl:value-of select="position()"/>
                  </xsl:element>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:value-of select="(position() - msxsl:node-set($prevNamePos)/posn[last()]) * 1.4"/>
          </xsl:variable>

          <xsl:text> 20&#10;</xsl:text>   <!-- North value for Description1 attribute - offset to allow for preceding attributes -->
          <xsl:value-of select="format-number($north * $DistConvFactor - $vertOffset, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:if test="string(number($elevation)) != 'NaN'">
            <xsl:text> 30&#10;</xsl:text>
            <xsl:value-of select="format-number($elevation * $DistConvFactor, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>
          </xsl:if>

          <xsl:text> 40&#10;</xsl:text>
          <xsl:text>1.0&#10;</xsl:text>

          <xsl:text>  1&#10;</xsl:text>
          <xsl:value-of select="."/><xsl:text>&#10;</xsl:text>  <!-- Output Description1 element value -->

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbAttribute&#10;</xsl:text>

          <xsl:text>  2&#10;</xsl:text>
          <xsl:value-of select="@Name"/><xsl:text>&#10;</xsl:text>  <!-- Set attribute name to name assigned to Description1 -->

          <xsl:text> 70&#10;</xsl:text>
          <xsl:text>     0&#10;</xsl:text>
        </xsl:if>
      </xsl:when>

      <!-- Output the Description2 attribute if present -->
      <xsl:when test="name(.) = 'Description2'">
        <xsl:variable name="east">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/East"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="north">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/North"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="elevation">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/Elevation"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:if test="(string(number($east)) != 'NaN') and (string(number($north)) != 'NaN')">  <!-- Coords are not null -->
          <xsl:text>  0&#10;</xsl:text>
          <xsl:text>ATTRIB&#10;</xsl:text>

          <xsl:text>  5&#10;</xsl:text>
          <xsl:value-of select="format-number($elementStartCount + position(), '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbEntity&#10;</xsl:text>

          <xsl:text>  8&#10;</xsl:text>
          <xsl:text>0&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbText&#10;</xsl:text>

          <xsl:text> 10&#10;</xsl:text>   <!-- East value for Description2 attribute - offset 0.4 -->
          <xsl:value-of select="format-number($east * $DistConvFactor + 0.4, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:variable name="vertOffset">
            <xsl:variable name="prevNamePos">
              <xsl:for-each select="preceding-sibling::*">
                <xsl:if test="name(.) = 'Name'">
                  <xsl:element name="posn">
                    <xsl:value-of select="position()"/>
                  </xsl:element>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:value-of select="(position() - msxsl:node-set($prevNamePos)/posn[last()]) * 1.4"/>
          </xsl:variable>

          <xsl:text> 20&#10;</xsl:text>   <!-- North value for Description2 attribute - offset to allow for preceding attributes -->
          <xsl:value-of select="format-number($north * $DistConvFactor - $vertOffset, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:if test="string(number($elevation)) != 'NaN'">
            <xsl:text> 30&#10;</xsl:text>
            <xsl:value-of select="format-number($elevation * $DistConvFactor, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>
          </xsl:if>

          <xsl:text> 40&#10;</xsl:text>
          <xsl:text>1.0&#10;</xsl:text>

          <xsl:text>  1&#10;</xsl:text>
          <xsl:value-of select="."/><xsl:text>&#10;</xsl:text>  <!-- Output Description2 element value -->

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbAttribute&#10;</xsl:text>

          <xsl:text>  2&#10;</xsl:text>
          <xsl:value-of select="@Name"/><xsl:text>&#10;</xsl:text>  <!-- Set attribute name to name assigned to Description2 -->

          <xsl:text> 70&#10;</xsl:text>
          <xsl:text>     0&#10;</xsl:text>
        </xsl:if>
      </xsl:when>

      <xsl:when test="name(.) = 'Attribute'">
        <xsl:variable name="east">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/East"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="north">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/North"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="elevation">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/Elevation"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:if test="(string(number($east)) != 'NaN') and (string(number($north)) != 'NaN')">  <!-- Coords are not null -->
          <xsl:text>  0&#10;</xsl:text>
          <xsl:text>ATTRIB&#10;</xsl:text>

          <xsl:text>  5&#10;</xsl:text>
          <xsl:value-of select="format-number($elementStartCount + position(), '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbEntity&#10;</xsl:text>

          <xsl:text>  8&#10;</xsl:text>
          <xsl:text>0&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbText&#10;</xsl:text>

          <xsl:text> 10&#10;</xsl:text>   <!-- East value for elevation attribute - offset 0.4 -->
          <xsl:value-of select="format-number($east * $DistConvFactor + 0.4, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:text> 20&#10;</xsl:text>   <!-- North value for attribute - offset to allow for preceding attributes -->
          <xsl:variable name="vertOffset">
            <xsl:variable name="prevNamePos">
              <xsl:for-each select="preceding-sibling::*">
                <xsl:if test="name(.) = 'Name'">
                  <xsl:element name="posn">
                    <xsl:value-of select="position()"/>
                  </xsl:element>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:value-of select="(position() - msxsl:node-set($prevNamePos)/posn[last()]) * 1.4"/>
          </xsl:variable>
          <xsl:value-of select="format-number($north * $DistConvFactor - $vertOffset, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:if test="string(number($elevation)) != 'NaN'">
            <xsl:text> 30&#10;</xsl:text>
            <xsl:value-of select="format-number($elevation * $DistConvFactor, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>
          </xsl:if>

          <xsl:text> 40&#10;</xsl:text>
          <xsl:text>1.0&#10;</xsl:text>

          <xsl:text>  1&#10;</xsl:text>
          <xsl:value-of select="Value"/><xsl:text>&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbAttribute&#10;</xsl:text>

          <xsl:text>  2&#10;</xsl:text>
          <xsl:value-of select="Name"/><xsl:text>&#10;</xsl:text>

          <xsl:text> 70&#10;</xsl:text>
          <xsl:text>     0&#10;</xsl:text>
        </xsl:if>
      </xsl:when>

      <!-- Output the end records for the point -->
      <xsl:when test="name(current()) = 'Counter'">
        <xsl:variable name="east">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/East"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="north">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/North"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:if test="(string(number($east)) != 'NaN') and (string(number($north)) != 'NaN')">  <!-- Coords are not null -->
          <xsl:text>  0&#10;</xsl:text>
          <xsl:text>SEQEND&#10;</xsl:text>

          <xsl:text>  5&#10;</xsl:text>
          <xsl:value-of select="format-number($elementStartCount + position(), '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbEntity&#10;</xsl:text>

          <xsl:text>  8&#10;</xsl:text>
          <xsl:text>0&#10;</xsl:text>
        </xsl:if>
      </xsl:when>
      
      <!-- Output the point name as a text entity -->
      <xsl:when test="($addNameCodeElevAsText = 'Yes') and (name(current()) = 'textName')">
        <xsl:variable name="east">
        <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/East"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="north">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/North"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="elevation">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/Elevation"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:if test="(string(number($east)) != 'NaN') and (string(number($north)) != 'NaN')">  <!-- Coords are not null -->
          <xsl:text>  0&#10;</xsl:text>
          <xsl:text>MTEXT&#10;</xsl:text>

          <xsl:text>  5&#10;</xsl:text>
          <xsl:value-of select="format-number($elementStartCount + position(), '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbEntity&#10;</xsl:text>

          <xsl:text>  8&#10;</xsl:text>
          <xsl:text>Point_Names&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbMText&#10;</xsl:text>

          <xsl:text> 10&#10;</xsl:text>   <!-- East value for name text - offset 0.4 -->
          <xsl:value-of select="format-number($east * $DistConvFactor + 0.4, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:text> 20&#10;</xsl:text>   <!-- North value for name text - offset 0.4 -->
          <xsl:value-of select="format-number($north * $DistConvFactor + 0.4, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:if test="string(number($elevation)) != 'NaN'">
            <xsl:text> 30&#10;</xsl:text>
            <xsl:value-of select="format-number($elevation * $DistConvFactor, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>
          </xsl:if>

          <xsl:text> 40&#10;</xsl:text>
          <xsl:value-of select="$textHt"/><xsl:text>&#10;</xsl:text>

          <xsl:text> 41&#10;</xsl:text>
          <xsl:value-of select="string-length(.)"/><xsl:text>&#10;</xsl:text>

          <xsl:text> 71&#10;</xsl:text>
          <xsl:text>     7&#10;</xsl:text> <!-- Bottom left insertion point -->

          <xsl:text> 72&#10;</xsl:text>
          <xsl:text>     1&#10;</xsl:text>

          <xsl:text>  1&#10;</xsl:text>
          <xsl:value-of select="translate(., ' ', '_')"/><xsl:text>&#10;</xsl:text>  <!-- Translate spaces to underscores to stop new lines being inserted -->

          <xsl:text>  7&#10;</xsl:text>
          <xsl:text>MONOTEXT&#10;</xsl:text>

          <xsl:text> 44&#10;</xsl:text>
          <xsl:text>1.0&#10;</xsl:text>
        </xsl:if>
      </xsl:when>

      <!-- Output the point code as a text entity if present -->
      <xsl:when test="($addNameCodeElevAsText = 'Yes') and (name(current()) = 'textCode')">
        <xsl:variable name="east">
        <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/East"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="north">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/North"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="elevation">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/Elevation"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:if test="(string(number($east)) != 'NaN') and (string(number($north)) != 'NaN')">  <!-- Coords are not null -->
          <xsl:text>  0&#10;</xsl:text>
          <xsl:text>MTEXT&#10;</xsl:text>

          <xsl:text>  5&#10;</xsl:text>
          <xsl:value-of select="format-number($elementStartCount + position(), '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbEntity&#10;</xsl:text>

          <xsl:text>  8&#10;</xsl:text>
          <xsl:text>Point_Codes&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbMText&#10;</xsl:text>

          <xsl:text> 10&#10;</xsl:text>   <!-- East value for code text - offset 0.4 -->
          <xsl:value-of select="format-number($east * $DistConvFactor + 0.4, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:variable name="vertOffset">
            <xsl:variable name="prevTextNamePos">
              <xsl:for-each select="preceding-sibling::*">
                <xsl:if test="name(.) = 'textName'">
                  <xsl:element name="posn">
                    <xsl:value-of select="position()"/>
                  </xsl:element>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>  <!-- Allow for initial 0.4 offset and then ($textHt + 0.4) for each preceding text item after the point name -->
            <xsl:value-of select="0.4 + ((position() - msxsl:node-set($prevTextNamePos)/posn[last()]) - 1) * ($textHt + 0.4)"/>
          </xsl:variable>

          <xsl:text> 20&#10;</xsl:text>   <!-- North value for code text - offset to allow for preceding text items -->
          <xsl:value-of select="format-number($north * $DistConvFactor - $vertOffset, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:if test="string(number($elevation)) != 'NaN'">
            <xsl:text> 30&#10;</xsl:text>
            <xsl:value-of select="format-number($elevation * $DistConvFactor, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>
          </xsl:if>

          <xsl:text> 40&#10;</xsl:text>
          <xsl:value-of select="$textHt"/><xsl:text>&#10;</xsl:text>

          <xsl:text> 41&#10;</xsl:text>
          <xsl:value-of select="string-length(.)"/><xsl:text>&#10;</xsl:text>

          <xsl:text> 71&#10;</xsl:text>
          <xsl:text>     1&#10;</xsl:text>  <!-- Top left insertion point -->

          <xsl:text> 72&#10;</xsl:text>
          <xsl:text>     1&#10;</xsl:text>

          <xsl:text>  1&#10;</xsl:text>
          <xsl:value-of select="translate(., ' ', '_')"/><xsl:text>&#10;</xsl:text>  <!-- Translate spaces to underscores to stop new lines being inserted -->

          <xsl:text>  7&#10;</xsl:text>
          <xsl:text>MONOTEXT&#10;</xsl:text>

          <xsl:text> 44&#10;</xsl:text>
          <xsl:text>1.0&#10;</xsl:text>
        </xsl:if>
      </xsl:when>

      <!-- Output the point elevation as a text entity if present -->
      <xsl:when test="($addNameCodeElevAsText = 'Yes') and (name(current()) = 'textElev') and
                      (string(number(preceding-sibling::Coords[1]/Grid/Elevation)) != 'NaN')">
        <xsl:variable name="east">
        <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/East"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="north">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/North"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="elevation">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/Elevation"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:if test="(string(number($east)) != 'NaN') and (string(number($north)) != 'NaN')">  <!-- Coords are not null -->
          <xsl:text>  0&#10;</xsl:text>
          <xsl:text>MTEXT&#10;</xsl:text>

          <xsl:text>  5&#10;</xsl:text>
          <xsl:value-of select="format-number($elementStartCount + position(), '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbEntity&#10;</xsl:text>

          <xsl:text>  8&#10;</xsl:text>
          <xsl:text>Point_Elevations&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbMText&#10;</xsl:text>

          <xsl:text> 10&#10;</xsl:text>   <!-- East value for elevation text - offset 0.4 -->
          <xsl:value-of select="format-number($east * $DistConvFactor + 0.4, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:variable name="vertOffset">
            <xsl:variable name="prevTextNamePos">
              <xsl:for-each select="preceding-sibling::*">
                <xsl:if test="name(.) = 'textName'">
                  <xsl:element name="posn">
                    <xsl:value-of select="position()"/>
                  </xsl:element>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>  <!-- Allow for initial 0.4 offset and then ($textHt + 0.4) for each preceding text item after the point name -->
            <xsl:value-of select="0.4 + ((position() - msxsl:node-set($prevTextNamePos)/posn[last()]) - 1) * ($textHt + 0.4)"/>
          </xsl:variable>

          <xsl:text> 20&#10;</xsl:text>   <!-- North value for elevation text - offset to allow for preceding text items -->
          <xsl:value-of select="format-number($north * $DistConvFactor - $vertOffset, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:if test="string(number($elevation)) != 'NaN'">
            <xsl:text> 30&#10;</xsl:text>
            <xsl:value-of select="format-number($elevation * $DistConvFactor, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>
          </xsl:if>

          <xsl:text> 40&#10;</xsl:text>
          <xsl:value-of select="$textHt"/><xsl:text>&#10;</xsl:text>

          <xsl:text> 41&#10;</xsl:text>
          <xsl:value-of select="string-length(format-number($elevation * $DistConvFactor, $DecPl3, 'Standard'))"/><xsl:text>&#10;</xsl:text>

          <xsl:text> 71&#10;</xsl:text>
          <xsl:text>     1&#10;</xsl:text>  <!-- Top left insertion point -->

          <xsl:text> 72&#10;</xsl:text>
          <xsl:text>     1&#10;</xsl:text>

          <xsl:text>  1&#10;</xsl:text>
          <xsl:value-of select="format-number($elevation * $DistConvFactor, $DecPl3, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:text>  7&#10;</xsl:text>
          <xsl:text>MONOTEXT&#10;</xsl:text>

          <xsl:text> 44&#10;</xsl:text>
          <xsl:text>1.0&#10;</xsl:text>
        </xsl:if>
      </xsl:when>

      <!-- Output the Description1 as a text entity if present -->
      <xsl:when test="($addNameCodeElevAsText = 'Yes') and (name(current()) = 'textDesc1')">
        <xsl:variable name="east">
        <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/East"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="north">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/North"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="elevation">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/Elevation"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:if test="(string(number($east)) != 'NaN') and (string(number($north)) != 'NaN')">  <!-- Coords are not null -->
          <xsl:text>  0&#10;</xsl:text>
          <xsl:text>MTEXT&#10;</xsl:text>

          <xsl:text>  5&#10;</xsl:text>
          <xsl:value-of select="format-number($elementStartCount + position(), '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbEntity&#10;</xsl:text>

          <xsl:text>  8&#10;</xsl:text>
          <xsl:text>Point_Descriptions&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbMText&#10;</xsl:text>

          <xsl:text> 10&#10;</xsl:text>   <!-- East value for Description1 text - offset 0.4 -->
          <xsl:value-of select="format-number($east * $DistConvFactor + 0.4, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:variable name="vertOffset">
            <xsl:variable name="prevTextNamePos">
              <xsl:for-each select="preceding-sibling::*">
                <xsl:if test="name(.) = 'textName'">
                  <xsl:element name="posn">
                    <xsl:value-of select="position()"/>
                  </xsl:element>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>  <!-- Allow for initial 0.4 offset and then ($textHt + 0.4) for each preceding text item after the point name -->
            <xsl:value-of select="0.4 + ((position() - msxsl:node-set($prevTextNamePos)/posn[last()]) - 1) * ($textHt + 0.4)"/>
          </xsl:variable>

          <xsl:text> 20&#10;</xsl:text>   <!-- North value for Description1 text - offset to allow for preceding text items -->
          <xsl:value-of select="format-number($north * $DistConvFactor - $vertOffset, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:if test="string(number($elevation)) != 'NaN'">
            <xsl:text> 30&#10;</xsl:text>
            <xsl:value-of select="format-number($elevation * $DistConvFactor, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>
          </xsl:if>

          <xsl:text> 40&#10;</xsl:text>
          <xsl:value-of select="$textHt"/><xsl:text>&#10;</xsl:text>

          <xsl:text> 41&#10;</xsl:text>
          <xsl:value-of select="string-length(.)"/><xsl:text>&#10;</xsl:text>

          <xsl:text> 71&#10;</xsl:text>
          <xsl:text>     1&#10;</xsl:text>  <!-- Top left insertion point -->

          <xsl:text> 72&#10;</xsl:text>
          <xsl:text>     1&#10;</xsl:text>

          <xsl:text>  1&#10;</xsl:text>
          <xsl:value-of select="."/><xsl:text>&#10;</xsl:text>

          <xsl:text>  7&#10;</xsl:text>
          <xsl:text>MONOTEXT&#10;</xsl:text>

          <xsl:text> 44&#10;</xsl:text>
          <xsl:text>1.0&#10;</xsl:text>
        </xsl:if>
      </xsl:when>

      <!-- Output the Description2 as a text entity if present -->
      <xsl:when test="($addNameCodeElevAsText = 'Yes') and (name(current()) = 'textDesc2')">
        <xsl:variable name="east">
        <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/East"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="north">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/North"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="elevation">
          <xsl:for-each select="preceding-sibling::Coords[1]">
            <xsl:value-of select="Grid/Elevation"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:if test="(string(number($east)) != 'NaN') and (string(number($north)) != 'NaN')">  <!-- Coords are not null -->
          <xsl:text>  0&#10;</xsl:text>
          <xsl:text>MTEXT&#10;</xsl:text>

          <xsl:text>  5&#10;</xsl:text>
          <xsl:value-of select="format-number($elementStartCount + position(), '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbEntity&#10;</xsl:text>

          <xsl:text>  8&#10;</xsl:text>
          <xsl:text>Point_Descriptions&#10;</xsl:text>

          <xsl:text>100&#10;</xsl:text>
          <xsl:text>AcDbMText&#10;</xsl:text>

          <xsl:text> 10&#10;</xsl:text>   <!-- East value for Description2 text - offset 0.4 -->
          <xsl:value-of select="format-number($east * $DistConvFactor + 0.4, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:variable name="vertOffset">
            <xsl:variable name="prevTextNamePos">
              <xsl:for-each select="preceding-sibling::*">
                <xsl:if test="name(.) = 'textName'">
                  <xsl:element name="posn">
                    <xsl:value-of select="position()"/>
                  </xsl:element>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>  <!-- Allow for initial 0.4 offset and then ($textHt + 0.4) for each preceding text item after the point name -->
            <xsl:value-of select="0.4 + ((position() - msxsl:node-set($prevTextNamePos)/posn[last()]) - 1) * ($textHt + 0.4)"/>
          </xsl:variable>

          <xsl:text> 20&#10;</xsl:text>   <!-- North value for Description2 text - offset to allow for preceding text items -->
          <xsl:value-of select="format-number($north * $DistConvFactor - $vertOffset, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

          <xsl:if test="string(number($elevation)) != 'NaN'">
            <xsl:text> 30&#10;</xsl:text>
            <xsl:value-of select="format-number($elevation * $DistConvFactor, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>
          </xsl:if>

          <xsl:text> 40&#10;</xsl:text>
          <xsl:value-of select="$textHt"/><xsl:text>&#10;</xsl:text>

          <xsl:text> 41&#10;</xsl:text>
          <xsl:value-of select="string-length(.)"/><xsl:text>&#10;</xsl:text>

          <xsl:text> 71&#10;</xsl:text>
          <xsl:text>     1&#10;</xsl:text>  <!-- Top left insertion point -->

          <xsl:text> 72&#10;</xsl:text>
          <xsl:text>     1&#10;</xsl:text>

          <xsl:text>  1&#10;</xsl:text>
          <xsl:value-of select="."/><xsl:text>&#10;</xsl:text>

          <xsl:text>  7&#10;</xsl:text>
          <xsl:text>MONOTEXT&#10;</xsl:text>

          <xsl:text> 44&#10;</xsl:text>
          <xsl:text>1.0&#10;</xsl:text>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:for-each>

  <xsl:variable name="nbrElements">
    <xsl:value-of select="count(msxsl:node-set($pointData)/*)"/>
  </xsl:variable>

  <xsl:call-template name="ExportLines"> <!-- Now export all the lines from the FieldBook node -->
    <xsl:with-param name="elementStartCount" select="$elementStartCount + $nbrElements + 1"/>
    <xsl:with-param name="pointData" select="$pointData"/>
  </xsl:call-template>
  
</xsl:template>


<!-- **************************************************************** -->
<!-- *********** Function to export all the defined lines *********** -->
<!-- **************************************************************** -->
<xsl:template name="ExportLines">
  <xsl:param name="elementStartCount"/>
  <xsl:param name="pointData"/>

  <xsl:for-each select="/JOBFile/FieldBook/LineRecord">
    <xsl:if test="(Deleted = 'false') and (Method = 'TwoPoints')">
      <xsl:variable name="startPt" select="StartPoint"/>
      <xsl:variable name="endPt" select="EndPoint"/>

      <!-- Write out line if the start and end points exist -->
      <xsl:if test="(count(msxsl:node-set($pointData)/Coords[Name = $startPt]) != 0) and
                    (count(msxsl:node-set($pointData)/Coords[Name = $endPt]) != 0)">
        <xsl:variable name="start">
          <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $startPt]">
            <east><xsl:value-of select="Grid/East"/></east>
            <north><xsl:value-of select="Grid/North"/></north>
            <elev><xsl:value-of select="Grid/Elevation"/></elev>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="end">
          <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $endPt]">
            <east><xsl:value-of select="Grid/East"/></east>
            <north><xsl:value-of select="Grid/North"/></north>
            <elev><xsl:value-of select="Grid/Elevation"/></elev>
          </xsl:for-each>
        </xsl:variable>

        <!-- If the start and end points have non-null coordinates then write them out -->
        <xsl:if test="(string(number(msxsl:node-set($start)/east)) != 'NaN') and (string(number(msxsl:node-set($start)/north)) != 'NaN') and
                      (string(number(msxsl:node-set($end)/east)) != 'NaN') and (string(number(msxsl:node-set($end)/north)) != 'NaN')">
          <xsl:call-template name="WriteLineData">
            <xsl:with-param name="elementNbr" select="$elementStartCount + position()"/>
            <xsl:with-param name="startE" select="msxsl:node-set($start)/east"/>
            <xsl:with-param name="startN" select="msxsl:node-set($start)/north"/>
            <xsl:with-param name="startElev" select="msxsl:node-set($start)/elev"/>
            <xsl:with-param name="endE" select="msxsl:node-set($end)/east"/>
            <xsl:with-param name="endN" select="msxsl:node-set($end)/north"/>
            <xsl:with-param name="endElev" select="msxsl:node-set($end)/elev"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:for-each>

  <!-- Output any ArcRecords -->
  <xsl:call-template name="ExportArcs">
    <xsl:with-param name="elementStartCount" select="$elementStartCount + count(/JOBFile/FieldBook/LineRecord) + 1"/>
    <xsl:with-param name="pointData" select="$pointData"/>
  </xsl:call-template>
</xsl:template>


<!-- **************************************************************** -->
<!-- ************* Function to write the line detailss ************** -->
<!-- **************************************************************** -->
<xsl:template name="WriteLineData">
  <xsl:param name="elementNbr"/>
  <xsl:param name="startE"/>
  <xsl:param name="startN"/>
  <xsl:param name="startElev"/>
  <xsl:param name="endE"/>
  <xsl:param name="endN"/>
  <xsl:param name="endElev"/>
  
  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>LINE&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:value-of select="format-number($elementNbr, '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>Linework&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbLine&#10;</xsl:text>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="east" select="$startE * $DistConvFactor"/>
    <xsl:with-param name="north" select="$startN * $DistConvFactor"/>
    <xsl:with-param name="elev" select="$startElev * $DistConvFactor"/>
    <xsl:with-param name="decPlaces" select="number($coordDecPl)"/>
  </xsl:call-template>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="east" select="$endE * $DistConvFactor"/>
    <xsl:with-param name="north" select="$endN * $DistConvFactor"/>
    <xsl:with-param name="elev" select="$endElev * $DistConvFactor"/>
    <xsl:with-param name="decPlaces" select="number($coordDecPl)"/>
    <xsl:with-param name="endPoint" select="1"/>
  </xsl:call-template>

</xsl:template>


<!-- **************************************************************** -->
<!-- ************ Function to export all the defined arcs *********** -->
<!-- **************************************************************** -->
<xsl:template name="ExportArcs">
  <xsl:param name="elementStartCount"/>
  <xsl:param name="pointData"/>

  <xsl:for-each select="/JOBFile/FieldBook/ArcRecord">
    <xsl:if test="Deleted = 'false'">
      <xsl:variable name="arcCentre">
        <xsl:call-template name="ArcCentrePoint">
          <xsl:with-param name="pointData" select="$pointData"/>
        </xsl:call-template>
      </xsl:variable>
      
      <xsl:variable name="radius">
        <xsl:choose>
          <xsl:when test="Radius">
            <xsl:value-of select="Radius"/>
          </xsl:when>
          <xsl:otherwise>  <!-- There is no Radius element so compute the radius -->
            <xsl:call-template name="Sqrt">
              <xsl:with-param name="num">
                <xsl:variable name="startPt" select="StartPoint"/>  <!-- If there is no Radius element then there will always be a StartPoint element -->
                <xsl:variable name="startE">
                  <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $startPt]">
                    <xsl:value-of select="Grid/East"/>
                  </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="startN">
                  <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $startPt]">
                    <xsl:value-of select="Grid/North"/>
                  </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="($startE - msxsl:node-set($arcCentre)/centreE) * ($startE - msxsl:node-set($arcCentre)/centreE) + ($startN - msxsl:node-set($arcCentre)/centreN) * ($startN - msxsl:node-set($arcCentre)/centreN)"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="azToStart">
        <xsl:choose>
          <xsl:when test="StartPoint"> <!-- Available for TwoPointsAndRadius, ArcLengthAndRadius, DeltaAngleAndRadius, TwoPointsAndCenterPoint and ThreePoints methods -->
            <xsl:call-template name="AzimuthToArcPt">
              <xsl:with-param name="pointData" select="$pointData"/>
              <xsl:with-param name="pointName" select="StartPoint"/>
              <xsl:with-param name="centreN" select="msxsl:node-set($arcCentre)/centreN"/>
              <xsl:with-param name="centreE" select="msxsl:node-set($arcCentre)/centreE"/>
            </xsl:call-template>
          </xsl:when>

          <xsl:otherwise>  <!-- Must be IntersectionPointAndTangents method -->
            <xsl:variable name="azimuth">
              <xsl:choose>
                <xsl:when test="Direction = 'Right'">
                  <xsl:value-of select="StartAzimuth * $Pi div 180.0 - $halfPi"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="StartAzimuth * $Pi div 180.0 + $halfPi"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:call-template name="AutoCADAzimuth">
              <xsl:with-param name="stdAzimuth" select="$azimuth"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="azToEnd">
        <xsl:choose>
          <xsl:when test="EndPoint"> <!-- Available for TwoPointsAndRadius, TwoPointsAndCenterPoint and ThreePoints methods -->
            <xsl:call-template name="AzimuthToArcPt">
              <xsl:with-param name="pointData" select="$pointData"/>
              <xsl:with-param name="pointName" select="EndPoint"/>
              <xsl:with-param name="centreN" select="msxsl:node-set($arcCentre)/centreN"/>
              <xsl:with-param name="centreE" select="msxsl:node-set($arcCentre)/centreE"/>
            </xsl:call-template>
          </xsl:when>

          <xsl:when test="Length or DeltaAngle"> <!-- Available for ArcLengthAndRadius and DeltaAngleAndRadius methods -->
            <xsl:variable name="deltaAngle">
              <xsl:choose>
                <xsl:when test="DeltaAngle"><xsl:value-of select="DeltaAngle * $Pi div 180.0"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="Length div Radius"/></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <!-- Got the delta angle - now apply it to the azToStart according to the arc direction -->
            <xsl:choose>
              <xsl:when test="Direction = 'Right'"><xsl:value-of select="$azToStart - $deltaAngle"/></xsl:when>
              <xsl:otherwise><xsl:value-of select="$azToStart + $deltaAngle"/></xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          
          <xsl:otherwise>  <!-- Must be IntersectionPointAndTangents method -->
            <xsl:variable name="azimuth">
              <xsl:choose>
                <xsl:when test="Direction = 'Right'">
                  <xsl:value-of select="EndAzimuth * $Pi div 180.0 - $halfPi"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="EndAzimuth * $Pi div 180.0 + $halfPi"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:call-template name="AutoCADAzimuth">
              <xsl:with-param name="stdAzimuth" select="$azimuth"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="arcDirn">
        <xsl:choose>
          <xsl:when test="Direction">
            <xsl:if test="Direction = 'Right'">right</xsl:if>
            <xsl:if test="not(Direction = 'Right')">left</xsl:if>
          </xsl:when>
          <xsl:otherwise>  <!-- ThreePoints method -->
            <!-- For the ThreePoints method then there will always be StartPoint, EndPoint and OtherPointOnArc elements -->
            <xsl:variable name="startPt" select="StartPoint"/>
            <xsl:variable name="startE">
              <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $startPt]">
                <xsl:value-of select="Grid/East"/>
              </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="startN">
              <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $startPt]">
                <xsl:value-of select="Grid/North"/>
              </xsl:for-each>
            </xsl:variable>

            <xsl:variable name="endPt" select="EndPoint"/>
            <xsl:variable name="endE">
              <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $endPt]">
                <xsl:value-of select="Grid/East"/>
              </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="endN">
              <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $endPt]">
                <xsl:value-of select="Grid/North"/>
              </xsl:for-each>
            </xsl:variable>

            <xsl:variable name="otherPt" select="OtherPointOnArc"/>
            <xsl:variable name="otherE">
              <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $otherPt]">
                <xsl:value-of select="Grid/East"/>
              </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="otherN">
              <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $otherPt]">
                <xsl:value-of select="Grid/North"/>
              </xsl:for-each>
            </xsl:variable>

            <xsl:call-template name="ArcDirection">
              <xsl:with-param name="startN" select="$startN"/>
              <xsl:with-param name="startE" select="$startE"/>
              <xsl:with-param name="endN" select="$otherN"/>
              <xsl:with-param name="endE" select="$otherE"/>
              <xsl:with-param name="pointN" select="$endN"/>
              <xsl:with-param name="pointE" select="$endE"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:if test="(string(number(msxsl:node-set($arcCentre)/centreE)) != 'NaN') and
                    (string(number(msxsl:node-set($arcCentre)/centreN)) != 'NaN') and
                    (string(number($radius)) != 'NaN') and (string(number($azToStart)) != 'NaN') and
                    (string(number($azToEnd)) != 'NaN')">
        <xsl:call-template name="WriteArcData">
          <xsl:with-param name="elementNbr" select="$elementStartCount + position()"/>
          <xsl:with-param name="centreE" select="msxsl:node-set($arcCentre)/centreE"/>
          <xsl:with-param name="centreN" select="msxsl:node-set($arcCentre)/centreN"/>
          <xsl:with-param name="centreElev" select="msxsl:node-set($arcCentre)/centreElev"/>
          <xsl:with-param name="radius" select="$radius"/>
          <xsl:with-param name="azToStart" select="$azToStart"/>
          <xsl:with-param name="azToEnd" select="$azToEnd"/>
          <xsl:with-param name="arcDirn" select="$arcDirn"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:for-each>

  <!-- Output any computed areas -->
  <xsl:call-template name="ExportAreas">
    <xsl:with-param name="elementStartCount" select="$elementStartCount + count(/JOBFile/FieldBook/LineRecord) + count(/JOBFile/FieldBook/ArcRecord) + 1"/>
    <xsl:with-param name="pointData" select="$pointData"/>
  </xsl:call-template>
  <xsl:variable name="areaElementCount" select="count(/JOBFile/FieldBook/ComputeAreaRecord/ListOfEntities/Entity) * 4 +
                                                count(/JOBFile/FieldBook/SubdivideAreaRecord/ListOfEntities/Entity) * 4 +
                                                count(/JOBFile/FieldBook/SubdivideAreaRecord/ListOfSubEntities/Entity) * 4 + 200"/>

  <!-- Now output any coded lines if this has been requested -->
  <xsl:if test="$addCodedLines = 'Yes'">
    <xsl:call-template name="AddCodedLines">
      <xsl:with-param name="elementStartCount" select="$elementStartCount + count(/JOBFile/FieldBook/LineRecord) + count(/JOBFile/FieldBook/ArcRecord) + $areaElementCount + 1"/>
      <xsl:with-param name="pointData" select="$pointData"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<!-- **************************************************************** -->
<!-- ************** Function to write the arc detailss ************** -->
<!-- **************************************************************** -->
<xsl:template name="WriteArcData">
  <xsl:param name="elementNbr"/>
  <xsl:param name="centreE"/>
  <xsl:param name="centreN"/>
  <xsl:param name="centreElev"/>
  <xsl:param name="radius"/>
  <xsl:param name="azToStart"/>
  <xsl:param name="azToEnd"/>
  <xsl:param name="arcDirn"/>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>ARC&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:value-of select="format-number($elementNbr, '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:text>Linework&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbCircle&#10;</xsl:text>
  
  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="east" select="$centreE * $DistConvFactor"/>
    <xsl:with-param name="north" select="$centreN * $DistConvFactor"/>
    <xsl:with-param name="elev" select="$centreElev * $DistConvFactor"/>
    <xsl:with-param name="decPlaces" select="number($coordDecPl)"/>
  </xsl:call-template>

  <xsl:text> 40&#10;</xsl:text>  <!-- Output radius -->
  <xsl:value-of select="format-number($radius * $DistConvFactor, $DecPl6, 'Standard')"/><xsl:text>&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbArc&#10;</xsl:text>

  <xsl:text> 50&#10;</xsl:text>  <!-- Output start angle -->
  <xsl:choose>
    <xsl:when test="$arcDirn = 'right'">
      <xsl:value-of select="format-number($azToEnd * 180.0 div $Pi, $DecPl6, 'Standard')"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="format-number($azToStart * 180.0 div $Pi, $DecPl6, 'Standard')"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text>&#10;</xsl:text>

  <xsl:text> 51&#10;</xsl:text>  <!-- Output end angle -->
  <xsl:choose>
    <xsl:when test="$arcDirn = 'right'">
      <xsl:value-of select="format-number($azToStart * 180.0 div $Pi, $DecPl6, 'Standard')"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="format-number($azToEnd * 180.0 div $Pi, $DecPl6, 'Standard')"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text>&#10;</xsl:text>
</xsl:template>


<!-- **************************************************************** -->
<!-- ******** Function to export all the defined areas calcs ******** -->
<!-- **************************************************************** -->
<xsl:template name="ExportAreas">
  <xsl:param name="elementStartCount"/>
  <xsl:param name="pointData"/>

  <!-- First create polylines for each of the ComputeAreaRecord elements -->
  <xsl:for-each select="/JOBFile/FieldBook/ComputeAreaRecord">
    <!-- If the defined area does not include arcs then a 3D polyline can be used -->
    <!-- otherwise a 2D polyline needs to be created.                             -->
    <xsl:variable name="startCount" select="$elementStartCount + count(preceding-sibling::ComputeAreaRecord/ListOfEntities/Entity) * 4"/>
    <xsl:choose>
      <xsl:when test="count(ListOfEntities/Entity[Type = 'Arc']) = 0">  <!-- No arcs in definition -->
        <xsl:for-each select="ListOfEntities">
          <xsl:call-template name="OutputArea3DPolyLine">
            <xsl:with-param  name="elementStartCount" select="$startCount + 1"/>
            <xsl:with-param name="layer">Computed Areas</xsl:with-param>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="ListOfEntities">
          <xsl:call-template name="OutputArea2DPolyLine">
            <xsl:with-param  name="elementStartCount" select="$startCount + 1"/>
            <xsl:with-param name="layer">Computed Areas</xsl:with-param>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
    <!-- Add the area name at centre (average coords) of polyline -->
    <xsl:if test="Name != ''">
      <xsl:variable name="averageEast" select="sum(ListOfEntities/Entity/Start/East) div count(ListOfEntities/Entity)"/>
      <xsl:variable name="averageNorth" select="sum(ListOfEntities/Entity/Start/North) div count(ListOfEntities/Entity)"/>
      <xsl:text>  0&#10;</xsl:text>
      <xsl:text>MTEXT&#10;</xsl:text>

      <xsl:text>  5&#10;</xsl:text>
      <xsl:value-of select="format-number($startCount + count(ListOfEntities/Entity) * 4 + 50, '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

      <xsl:text>100&#10;</xsl:text>
      <xsl:text>AcDbEntity&#10;</xsl:text>

      <xsl:text>  8&#10;</xsl:text>
      <xsl:text>Computed Areas&#10;</xsl:text>

      <xsl:text>100&#10;</xsl:text>
      <xsl:text>AcDbMText&#10;</xsl:text>

      <xsl:text> 10&#10;</xsl:text>   <!-- Average East value -->
      <xsl:value-of select="format-number($averageEast * $DistConvFactor, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

      <xsl:text> 20&#10;</xsl:text>   <!-- Average North value -->
      <xsl:value-of select="format-number($averageNorth * $DistConvFactor, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

      <xsl:text> 40&#10;</xsl:text>
      <xsl:text>10.0&#10;</xsl:text>

      <xsl:text> 41&#10;</xsl:text>
      <xsl:value-of select="string-length(Name)"/><xsl:text>&#10;</xsl:text>

      <xsl:text> 71&#10;</xsl:text>
      <xsl:text>     5&#10;</xsl:text>  <!-- Middle Centre insertion point -->

      <xsl:text> 72&#10;</xsl:text>
      <xsl:text>     1&#10;</xsl:text>

      <xsl:text>  1&#10;</xsl:text>
      <xsl:value-of select="Name"/><xsl:text>&#10;</xsl:text>

      <xsl:text>  7&#10;</xsl:text>
      <xsl:text>MONOTEXT&#10;</xsl:text>

      <xsl:text> 44&#10;</xsl:text>
      <xsl:text>1.0&#10;</xsl:text>
    </xsl:if>
  </xsl:for-each>
  
  <xsl:variable name="computeAreaCount" select="count(/JOBFile/FieldBook/ComputeAreaRecord/ListOfEntities/Entity) * 4 + 80"/>

  <!-- Now output the Subdivided areas elements -->
  <xsl:for-each select="/JOBFile/FieldBook/SubdivideAreaRecord">
    <!-- If the defined area does not include arcs then a 3D polyline can be used -->
    <!-- otherwise a 2D polyline needs to be created.                             -->
    <xsl:variable name="startCount" select="$elementStartCount + $computeAreaCount +
                                            count(preceding-sibling::SubdivideAreaRecord/ListOfEntities/Entity) * 4 +
                                            count(preceding-sibling::SubdivideAreaRecord/ListOfSubEntities/Entity) * 4"/>
    <xsl:choose>
      <xsl:when test="count(ListOfEntities/Entity[Type = 'Arc']) = 0">  <!-- No arcs in definition -->
        <xsl:for-each select="ListOfEntities">
          <xsl:call-template name="OutputArea3DPolyLine">
            <xsl:with-param  name="elementStartCount" select="$startCount + 1"/>
            <xsl:with-param name="layer">Subdivided Areas</xsl:with-param>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="ListOfEntities">
          <xsl:call-template name="OutputArea2DPolyLine">
            <xsl:with-param  name="elementStartCount" select="$startCount + 1"/>
            <xsl:with-param name="layer">Subdivided Areas</xsl:with-param>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:variable name="origAreaEntityCount" select="count(ListOfEntities) * 4"/>

    <!-- Add the area name at centre (average coords) of polyline -->
    <xsl:if test="Name != ''">
      <xsl:variable name="averageEast" select="sum(ListOfEntities/Entity/Start/East) div count(ListOfEntities/Entity)"/>
      <xsl:variable name="averageNorth" select="sum(ListOfEntities/Entity/Start/North) div count(ListOfEntities/Entity)"/>
      <xsl:text>  0&#10;</xsl:text>
      <xsl:text>MTEXT&#10;</xsl:text>

      <xsl:text>  5&#10;</xsl:text>
      <xsl:value-of select="format-number($startCount + $origAreaEntityCount + 5, '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

      <xsl:text>100&#10;</xsl:text>
      <xsl:text>AcDbEntity&#10;</xsl:text>

      <xsl:text>  8&#10;</xsl:text>
      <xsl:text>Subdivided Areas&#10;</xsl:text>

      <xsl:text>100&#10;</xsl:text>
      <xsl:text>AcDbMText&#10;</xsl:text>

      <xsl:text> 10&#10;</xsl:text>   <!-- Average East value -->
      <xsl:value-of select="format-number($averageEast * $DistConvFactor, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

      <xsl:text> 20&#10;</xsl:text>   <!-- Average North value -->
      <xsl:value-of select="format-number($averageNorth * $DistConvFactor, $coordDecPlStr, 'Standard')"/><xsl:text>&#10;</xsl:text>

      <xsl:text> 40&#10;</xsl:text>
      <xsl:text>10.0&#10;</xsl:text>

      <xsl:text> 41&#10;</xsl:text>
      <xsl:value-of select="string-length(Name)"/><xsl:text>&#10;</xsl:text>

      <xsl:text> 71&#10;</xsl:text>
      <xsl:text>     5&#10;</xsl:text>  <!-- Middle Centre insertion point -->

      <xsl:text> 72&#10;</xsl:text>
      <xsl:text>     1&#10;</xsl:text>

      <xsl:text>  1&#10;</xsl:text>
      <xsl:value-of select="Name"/><xsl:text>&#10;</xsl:text>

      <xsl:text>  7&#10;</xsl:text>
      <xsl:text>MONOTEXT&#10;</xsl:text>

      <xsl:text> 44&#10;</xsl:text>
      <xsl:text>1.0&#10;</xsl:text>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="count(ListOfSubEntities/Entity[Type = 'Arc']) = 0">  <!-- No arcs in definition -->
        <xsl:for-each select="ListOfSubEntities">
          <xsl:call-template name="OutputArea3DPolyLine">
            <xsl:with-param  name="elementStartCount" select="$startCount + $origAreaEntityCount + 10"/>
            <xsl:with-param name="layer">Subdivided Areas</xsl:with-param>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="ListOfSubEntities">
          <xsl:call-template name="OutputArea2DPolyLine">
            <xsl:with-param  name="elementStartCount" select="$startCount + $origAreaEntityCount + 10"/>
            <xsl:with-param name="layer">Subdivided Areas</xsl:with-param>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>

</xsl:template>


<!-- **************************************************************** -->
<!-- *************** Function to output a 3D polyline *************** -->
<!-- **************************************************************** -->
<xsl:template name="OutputArea3DPolyLine">
  <xsl:param name="elementStartCount"/>
  <xsl:param name="layer"/>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>POLYLINE&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:value-of select="format-number($elementStartCount, '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:value-of select="$layer"/><xsl:text>&#10;</xsl:text>  <!-- Assign passed in layer name -->

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDb3dPolyline&#10;</xsl:text>

  <xsl:call-template name="OutputCoordVals">
    <xsl:with-param name="east">0</xsl:with-param>
    <xsl:with-param name="north">0</xsl:with-param>
    <xsl:with-param name="elev">0</xsl:with-param>
    <xsl:with-param name="decPlaces" select="number($coordDecPl)"/>
  </xsl:call-template>

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>     9&#10;</xsl:text>  <!-- 3D polyline flag - closed (by definition for an area) -->

  <xsl:for-each select="Entity">
    <xsl:text>  0&#10;</xsl:text>
    <xsl:text>VERTEX&#10;</xsl:text>

    <xsl:text>  5&#10;</xsl:text>
    <xsl:value-of select="format-number($elementStartCount + position(), '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

    <xsl:text>100&#10;</xsl:text>
    <xsl:text>AcDbEntity&#10;</xsl:text>

    <xsl:text>  8&#10;</xsl:text>
    <xsl:value-of select="$layer"/><xsl:text>&#10;</xsl:text>  <!-- Assign passed in layer name -->

    <xsl:text>100&#10;</xsl:text>
    <xsl:text>AcDbVertex&#10;</xsl:text>

    <xsl:text>100&#10;</xsl:text>
    <xsl:text>AcDb3dPolylineVertex&#10;</xsl:text>

    <xsl:call-template name="OutputCoordVals">
      <xsl:with-param name="east" select="Start/East * $DistConvFactor"/>
      <xsl:with-param name="north" select="Start/North * $DistConvFactor"/>
      <xsl:with-param name="elev" select="Start/Elevation * $DistConvFactor"/>
      <xsl:with-param name="decPlaces" select="number($coordDecPl)"/>
    </xsl:call-template>

    <xsl:text> 70&#10;</xsl:text>
    <xsl:text>    32&#10;</xsl:text> <!-- 3D polyline vertex flag -->

  </xsl:for-each>
    <xsl:text>  0&#10;</xsl:text>
    <xsl:text>SEQEND&#10;</xsl:text>

    <xsl:text>  5&#10;</xsl:text>
    <xsl:value-of select="format-number($elementStartCount + count(Entity) + 1, '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

    <xsl:text>100&#10;</xsl:text>
    <xsl:text>AcDbEntity&#10;</xsl:text>

    <xsl:text>  8&#10;</xsl:text>
    <xsl:value-of select="$layer"/><xsl:text>&#10;</xsl:text>  <!-- Assign passed in layer name -->
</xsl:template>


<!-- **************************************************************** -->
<!-- *************** Function to output a 2D polyline *************** -->
<!-- **************************************************************** -->
<xsl:template name="OutputArea2DPolyLine">
  <xsl:param name="elementStartCount"/>
  <xsl:param name="layer"/>

  <xsl:text>  0&#10;</xsl:text>
  <xsl:text>LWPOLYLINE&#10;</xsl:text>

  <xsl:text>  5&#10;</xsl:text>
  <xsl:value-of select="format-number($elementStartCount, '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbEntity&#10;</xsl:text>

  <xsl:text>  8&#10;</xsl:text>
  <xsl:value-of select="$layer"/><xsl:text>&#10;</xsl:text>  <!-- Assign passed in layer name -->

  <xsl:text>100&#10;</xsl:text>
  <xsl:text>AcDbPolyline&#10;</xsl:text>

  <xsl:text> 90&#10;</xsl:text>
  <xsl:value-of select="count(Entity)"/><xsl:text>&#10;</xsl:text>  <!-- Number of vertices -->

  <xsl:text> 70&#10;</xsl:text>
  <xsl:text>   1&#10;</xsl:text>  <!-- Closed polyline (by definition) -->

  <xsl:for-each select="Entity">
    <xsl:choose>
      <xsl:when test="Type = 'Line'">
        <xsl:call-template name="OutputCoordVals">
          <xsl:with-param name="east" select="Start/East * $DistConvFactor"/>
          <xsl:with-param name="north" select="Start/North * $DistConvFactor"/>
          <xsl:with-param name="decPlaces" select="number($coordDecPl)"/>
          <xsl:with-param name="threeDVals" select="0"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>   <!-- Must be an arc -->
        <!-- Output the start point of the arc - effectively the end point of the previous line/arc -->
        <xsl:call-template name="OutputCoordVals">
          <xsl:with-param name="east" select="Start/East * $DistConvFactor"/>
          <xsl:with-param name="north" select="Start/North * $DistConvFactor"/>
          <xsl:with-param name="decPlaces" select="number($coordDecPl)"/>
          <xsl:with-param name="threeDVals" select="0"/>
        </xsl:call-template>

        <!-- Output the Bulge factor for the arc - Bulge = tan(IncludedAngle / 4).  Value is negative for clockwise angles -->
        <xsl:text> 42&#10;</xsl:text>
        <xsl:variable name="bulge">
          <xsl:call-template name="Tan">
            <xsl:with-param name="TheAngle" select="ScribedAngle * $Pi div 180.0 div 4.0"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="sign">
          <xsl:choose>
            <xsl:when test="Direction = 'Right'">-1</xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="format-number($bulge * $sign, $DecPl8, 'Standard')"/>
        <xsl:text>&#10;</xsl:text>
        
        <!-- If this is the last element output the End coords (otherwise they will be provided by the Start coords of next element -->
        <xsl:if test="position() = last()">
          <xsl:call-template name="OutputCoordVals">
            <xsl:with-param name="east" select="End/East * $DistConvFactor"/>
            <xsl:with-param name="north" select="End/North * $DistConvFactor"/>
            <xsl:with-param name="decPlaces" select="number($coordDecPl)"/>
            <xsl:with-param name="threeDVals" select="0"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
  
</xsl:template>


<!-- **************************************************************** -->
<!-- *********** Output Lines based on the feature codes ************ -->
<!-- **************************************************************** -->
<xsl:template name="AddCodedLines">
  <xsl:param name="elementStartCount"/>
  <xsl:param name="pointData"/>

  <xsl:variable name="lines">
    <xsl:for-each select="msxsl:node-set($pointData)/Coords">
      <xsl:variable name="lineCode">
        <xsl:call-template name="IsLineCode">       <!-- Pass in uppercase Code -->
          <xsl:with-param name="code" select="translate(Code,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:if test="$lineCode != ''">  <!-- It is a specified line code so add to the $Line variable -->
        <xsl:if test="count(preceding-sibling::Coords[contains(translate(Code,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'), $lineCode)]) != 0">
          <xsl:element name="Line">
            <!-- Only add a 'To' point if the point code does not contain the specified $startCode -->
            <xsl:if test="not(contains(translate(Code,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'), concat(' ', $startCode)))">
              <xsl:element name="ToEast">
                <xsl:value-of select="Grid/East"/>
              </xsl:element>
              <xsl:element name="ToNorth">
                <xsl:value-of select="Grid/North"/>
              </xsl:element>
              <xsl:element name="ToElevation">
                <xsl:value-of select="Grid/Elevation"/>
              </xsl:element>
            </xsl:if>

            <xsl:element name="Code">
              <xsl:value-of select="$lineCode"/>
            </xsl:element>

            <xsl:for-each select="preceding-sibling::Coords[contains(translate(Code,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'), $lineCode)][1]">
              <xsl:element name="FromEast">
                <xsl:value-of select="Grid/East"/>
              </xsl:element>
              <xsl:element name="FromNorth">
                <xsl:value-of select="Grid/North"/>
              </xsl:element>
              <xsl:element name="FromElevation">
                <xsl:value-of select="Grid/Elevation"/>
              </xsl:element>
            </xsl:for-each>
          </xsl:element>
        </xsl:if>
        
        <!-- If the Close code has been used add another line segment to the first point in the current line sequence -->
        <xsl:if test="($closeCode != '') and contains(translate(Code,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'), $closeCode)">
          <!-- The from point is our current point -->
          <xsl:element name="Line">
            <xsl:element name="FromEast">
              <xsl:value-of select="Grid/East"/>
            </xsl:element>
            <xsl:element name="FromNorth">
              <xsl:value-of select="Grid/North"/>
            </xsl:element>
            <xsl:element name="FromElevation">
              <xsl:value-of select="Grid/Elevation"/>
            </xsl:element>

            <xsl:element name="Code">
              <xsl:value-of select="$lineCode"/>
            </xsl:element>

            <xsl:variable name="precedingStartedSequenceCount" select="count(preceding-sibling::Coords[contains(translate(Code,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'), $lineCode) and
                                                                                                       contains(translate(Code,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'), $startCode)])"/>
            <xsl:choose>
              <xsl:when test="$precedingStartedSequenceCount &gt; 0">
                <xsl:for-each select="preceding-sibling::Coords[contains(translate(Code,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'), $lineCode) and
                                                                contains(translate(Code,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'), $startCode)][1]">
                  <xsl:element name="ToEast">
                    <xsl:value-of select="Grid/East"/>
                  </xsl:element>
                  <xsl:element name="ToNorth">
                    <xsl:value-of select="Grid/North"/>
                  </xsl:element>
                  <xsl:element name="ToElevation">
                    <xsl:value-of select="Grid/Elevation"/>
                  </xsl:element>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <xsl:for-each select="preceding-sibling::Coords[contains(translate(Code,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'), $lineCode)][last()]">
                  <xsl:element name="ToEast">
                    <xsl:value-of select="Grid/East"/>
                  </xsl:element>
                  <xsl:element name="ToNorth">
                    <xsl:value-of select="Grid/North"/>
                  </xsl:element>
                  <xsl:element name="ToElevation">
                    <xsl:value-of select="Grid/Elevation"/>
                  </xsl:element>
                </xsl:for-each>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
        </xsl:if>

        <!-- If the Close code has been used add another line segment to the first point in the current line sequence -->
        <xsl:if test="($joinToCode != '') and contains(translate(Code,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'), $joinToCode)">
          <!-- Get the name of the point to join to - space separated after the join to code -->
          <xsl:variable name="temp" select="normalize-space(substring-after(Code, $joinToCode))"/>
          <xsl:variable name="joinToName">
            <xsl:choose>
              <xsl:when test="contains($temp, ' ')">
                <xsl:value-of select="substring-before($temp, ' ')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$temp"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <!-- The from point is our current point -->
          <xsl:element name="Line">
            <xsl:element name="FromEast">
              <xsl:value-of select="Grid/East"/>
            </xsl:element>
            <xsl:element name="FromNorth">
              <xsl:value-of select="Grid/North"/>
            </xsl:element>
            <xsl:element name="FromElevation">
              <xsl:value-of select="Grid/Elevation"/>
            </xsl:element>

            <xsl:element name="Code">
              <xsl:value-of select="$lineCode"/>
            </xsl:element>

            <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $joinToName][1]">
              <xsl:element name="ToEast">
                <xsl:value-of select="Grid/East"/>
              </xsl:element>
              <xsl:element name="ToNorth">
                <xsl:value-of select="Grid/North"/>
              </xsl:element>
              <xsl:element name="ToElevation">
                <xsl:value-of select="Grid/Elevation"/>
              </xsl:element>
            </xsl:for-each>
          </xsl:element>
        </xsl:if>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <!-- Set up a node-set variable indicating the line sequences     -->
  <!-- The seqIDs used are: 0 = no point positions (can be ignored) -->
  <!--                      1 = start of line sequence              -->
  <!--                      2 = line segment is in current sequence -->
  <xsl:variable name="lineSequenceIDs">
    <xsl:for-each select="msxsl:node-set($lines)/Line">
      <xsl:element name="seqID">
        <xsl:choose>
          <xsl:when test="not(FromEast and ToEast)">0</xsl:when>
          <xsl:when test="((FromEast != preceding-sibling::Line[1]/ToEast) and 
                           (FromNorth != preceding-sibling::Line[1]/ToNorth)) or not(preceding-sibling::Line[1]/ToEast)">1</xsl:when>
          <xsl:otherwise>2</xsl:otherwise>
        </xsl:choose>
      </xsl:element>
    </xsl:for-each>
  </xsl:variable>
  
  <xsl:variable name="lineSequences">  <!-- Build up a node-set variable containing the line sequences -->
    <xsl:for-each select="msxsl:node-set($lineSequenceIDs)/seqID">
      <xsl:if test=". = 1">
        <xsl:element name="sequence">
          <xsl:variable name="posn" select="position()"/>
          <xsl:copy-of select="msxsl:node-set($lines)/Line[number($posn)]"/>
          <xsl:variable name="prevStartSeqCount" select="count(preceding-sibling::seqID[. = 1])"/>
          <xsl:for-each select="following-sibling::seqID[(. = 2) and 
                                                         (count(preceding-sibling::seqID[. = 1]) = ($prevStartSeqCount + 1))]">
            <xsl:variable name="newPosn" select="$posn + position()"/>
            <xsl:copy-of select="msxsl:node-set($lines)/Line[number($newPosn)]"/>
          </xsl:for-each>
        </xsl:element>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  
  <xsl:variable name="sequenceCounts">
    <xsl:for-each select="msxsl:node-set($lineSequences)/sequence">
      <xsl:element name="count">
        <xsl:value-of select="count(Line)"/>
      </xsl:element>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="sortedSequenceCounts">
    <xsl:for-each select="msxsl:node-set($sequenceCounts)/count">
      <xsl:sort data-type="number" order="descending" select="."/>
      <xsl:copy-of select="."/>
    </xsl:for-each>
  </xsl:variable>
  
  <!-- Work out the largest sequence so that we can keep the entity IDs unique - allow for 3 extra IDs required for a polyline -->
  <xsl:variable name="largestSequence" select="msxsl:node-set($sortedSequenceCounts)/count[1] + 3"/>
    
  <xsl:for-each select="msxsl:node-set($lineSequences)/sequence">
    <xsl:choose>
      <xsl:when test="count(Line) = 1">  <!-- There is a single line element - output as Line -->
        <xsl:text>  0&#10;</xsl:text>
        <xsl:text>LINE&#10;</xsl:text>

        <xsl:text>  5&#10;</xsl:text>
        <xsl:value-of select="format-number($elementStartCount + position() * $largestSequence, '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

        <xsl:text>100&#10;</xsl:text>
        <xsl:text>AcDbEntity&#10;</xsl:text>

        <xsl:text>  8&#10;</xsl:text>
        <xsl:value-of select="Line/Code"/><xsl:text>&#10;</xsl:text>  <!-- Put in layer named according to Code -->

        <xsl:text>100&#10;</xsl:text>
        <xsl:text>AcDbLine&#10;</xsl:text>

        <xsl:call-template name="OutputCoordVals">
          <xsl:with-param name="east" select="Line/FromEast * $DistConvFactor"/>
          <xsl:with-param name="north" select="Line/FromNorth * $DistConvFactor"/>
          <xsl:with-param name="elev" select="Line/FromElevation * $DistConvFactor"/>
          <xsl:with-param name="decPlaces" select="number($coordDecPl)"/>
        </xsl:call-template>

        <xsl:call-template name="OutputCoordVals">
          <xsl:with-param name="east" select="Line/ToEast * $DistConvFactor"/>
          <xsl:with-param name="north" select="Line/ToNorth * $DistConvFactor"/>
          <xsl:with-param name="elev" select="Line/ToElevation * $DistConvFactor"/>
          <xsl:with-param name="decPlaces" select="number($coordDecPl)"/>
          <xsl:with-param name="endPoint" select="1"/>
        </xsl:call-template>
      </xsl:when>
      
      <xsl:otherwise>  <!-- More than 1 line segment - output as a 3D polyline -->
        <xsl:variable name="posn" select="position()"/>
        <xsl:text>  0&#10;</xsl:text>
        <xsl:text>POLYLINE&#10;</xsl:text>

        <xsl:text>  5&#10;</xsl:text>
        <xsl:value-of select="format-number($elementStartCount + $posn * $largestSequence, '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

        <xsl:text>100&#10;</xsl:text>
        <xsl:text>AcDbEntity&#10;</xsl:text>

        <xsl:text>  8&#10;</xsl:text>
        <xsl:value-of select="Line[1]/Code"/><xsl:text>&#10;</xsl:text>  <!-- Put in layer named according to Code -->

        <xsl:text>100&#10;</xsl:text>
        <xsl:text>AcDb3dPolyline&#10;</xsl:text>

        <xsl:call-template name="OutputCoordVals">
          <xsl:with-param name="east">0</xsl:with-param>
          <xsl:with-param name="north">0</xsl:with-param>
          <xsl:with-param name="elev">0</xsl:with-param>
          <xsl:with-param name="decPlaces" select="number($coordDecPl)"/>
        </xsl:call-template>

        <xsl:text> 70&#10;</xsl:text>
        <xsl:choose>
          <xsl:when test="(Line[1]/FromEast = Line[last()]/ToEast) and (Line[1]/FromNorth = Line[last()]/ToNorth)">
            <xsl:text>     9&#10;</xsl:text>  <!-- 3D polyline flag - closed -->
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>     8&#10;</xsl:text>  <!-- 3D polyline flag - unclosed -->
          </xsl:otherwise>
        </xsl:choose>

        <xsl:for-each select="Line">
          <xsl:if test="(string(number(FromEast)) != 'NaN') and (string(number(FromNorth)) != 'NaN')">
            <xsl:text>  0&#10;</xsl:text>
            <xsl:text>VERTEX&#10;</xsl:text>

            <xsl:text>  5&#10;</xsl:text>
            <xsl:value-of select="format-number($elementStartCount + $posn * $largestSequence + position(), '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

            <xsl:text>100&#10;</xsl:text>
            <xsl:text>AcDbEntity&#10;</xsl:text>

            <xsl:text>  8&#10;</xsl:text>
            <xsl:value-of select="Code"/><xsl:text>&#10;</xsl:text>  <!-- Put in layer named according to Code -->

            <xsl:text>100&#10;</xsl:text>
            <xsl:text>AcDbVertex&#10;</xsl:text>

            <xsl:text>100&#10;</xsl:text>
            <xsl:text>AcDb3dPolylineVertex&#10;</xsl:text>

            <xsl:call-template name="OutputCoordVals">
              <xsl:with-param name="east" select="FromEast * $DistConvFactor"/>
              <xsl:with-param name="north" select="FromNorth * $DistConvFactor"/>
              <xsl:with-param name="elev" select="FromElevation * $DistConvFactor"/>
              <xsl:with-param name="decPlaces" select="number($coordDecPl)"/>
            </xsl:call-template>

            <xsl:text> 70&#10;</xsl:text>
            <xsl:text>    32&#10;</xsl:text> <!-- 3D polyline vertex flag -->
          </xsl:if>

          <xsl:if test="position() = last()">  <!-- output the To point as another vertex -->
            <xsl:text>  0&#10;</xsl:text>
            <xsl:text>VERTEX&#10;</xsl:text>

            <xsl:text>  5&#10;</xsl:text>
            <xsl:value-of select="format-number($elementStartCount + $posn * $largestSequence + position() + 1, '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

            <xsl:text>100&#10;</xsl:text>
            <xsl:text>AcDbEntity&#10;</xsl:text>
            
            <xsl:text>  8&#10;</xsl:text>
            <xsl:value-of select="Code"/><xsl:text>&#10;</xsl:text>  <!-- Put in layer named according to Code -->

            <xsl:text>100&#10;</xsl:text>
            <xsl:text>AcDbVertex&#10;</xsl:text>
            
            <xsl:text>100&#10;</xsl:text>
            <xsl:text>AcDb3dPolylineVertex&#10;</xsl:text>
            
            <xsl:call-template name="OutputCoordVals">
              <xsl:with-param name="east" select="ToEast * $DistConvFactor"/>
              <xsl:with-param name="north" select="ToNorth * $DistConvFactor"/>
              <xsl:with-param name="elev" select="ToElevation * $DistConvFactor"/>
              <xsl:with-param name="decPlaces" select="number($coordDecPl)"/>
            </xsl:call-template>
            
            <xsl:text> 70&#10;</xsl:text>
            <xsl:text>    32&#10;</xsl:text> <!-- 3D polyline vertex flag -->
          </xsl:if>
        </xsl:for-each>
        <xsl:text>  0&#10;</xsl:text>
        <xsl:text>SEQEND&#10;</xsl:text>
        
        <xsl:text>  5&#10;</xsl:text>
        <xsl:value-of select="format-number($elementStartCount + $posn * $largestSequence + count(Line) + 2, '0', 'Standard')"/><xsl:text>&#10;</xsl:text>

        <xsl:text>100&#10;</xsl:text>
        <xsl:text>AcDbEntity&#10;</xsl:text>
        
        <xsl:text>  8&#10;</xsl:text>
        <xsl:value-of select="Line[1]/Code"/><xsl:text>&#10;</xsl:text>  <!-- Put in layer named according to Code -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
  
  <xsl:for-each select="msxsl:node-set($lines)/Line">
    <xsl:if test="FromEast and ToEast">   <!-- We have both start and end points -->
    </xsl:if>
  </xsl:for-each>

</xsl:template>


<!-- **************************************************************** -->
<!-- ****** Function to check if supplied code is a line code ******* -->
<!-- **************************************************************** -->
<xsl:template name="IsLineCode">
  <xsl:param name="code"/>

  <!-- Get a node set variable of all the space separated codes within the passed in code parameter.  -->
  <!-- We want to use the first individual code that matches a line code to allow for the possibility -->
  <!-- of a non-line code preceding a line code in the code parameter.                                -->
  <xsl:variable name="sepCodes">
    <xsl:call-template name="GetSpaceSepCodes">
      <xsl:with-param name="code" select="$code"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="matchedLineCodes">
    <xsl:for-each select="msxsl:node-set($sepCodes)/code">
      <!-- There may be a string counter on the string - remove any numeric chars before checking to see if it is a line code -->
      <xsl:variable name="compCode">
        <xsl:choose>
          <xsl:when test="string(number(.)) = 'NaN'"> <!-- It is not a numeric only code -->
            <xsl:call-template name="RemoveTrailingNumbers">  <!-- Remove any trailing numbers from the code -->
              <xsl:with-param name="inCode" select="."/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:if test="contains($lineCodes, concat('|', $compCode, '|'))"> <!-- Compare with a leading and trailing | chars on the comparison code in case of single character codes -->
        <xsl:element name="lineCode">
          <xsl:value-of select="."/>   <!-- The current code from $sepCodes is a line code - add as element to node set variable -->
        </xsl:element>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <!-- Return the first matched line code from the $matchedLineCodes node set variable. -->
  <!-- If there were no matches this will return an empty string.                       -->
  <xsl:value-of select="msxsl:node-set($matchedLineCodes)/lineCode[1]"/>
</xsl:template>


<!-- **************************************************************** -->
<!-- ******** Get all the space separated individual codes ********** -->
<!-- **************************************************************** -->
<xsl:template name="GetSpaceSepCodes">
  <xsl:param name="code"/>

  <!-- Don't split into separate codes if space char is directly followed by a '-' char -->
  <xsl:variable name="tempCode">
    <xsl:call-template name="SwapMatchedCodes">
      <xsl:with-param name="code" select="$code"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="contains($tempCode, ' ')">
      <xsl:element name="code">
        <xsl:call-template name="SwapMatchedCodes">
          <xsl:with-param name="hideSpaces">false</xsl:with-param>
          <xsl:with-param name="code" select="substring-before($tempCode, ' ')"/>
        </xsl:call-template>
      </xsl:element>

      <xsl:call-template name="GetSpaceSepCodes">   <!-- Recurse function to get next space separated code -->
        <xsl:with-param name="code" select="substring-after($tempCode, ' ')"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="code">
        <xsl:call-template name="SwapMatchedCodes">
          <xsl:with-param name="hideSpaces">false</xsl:with-param>
          <xsl:with-param name="code" select="$tempCode"/>
        </xsl:call-template>
      </xsl:element>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- **************************************************************** -->
<!-- ****** Hide or reinstate the internal space chars in codes ***** -->
<!-- **************************************************************** -->
<xsl:template name="SwapMatchedCodes">
  <xsl:param name="hideSpaces" select="'true'"/>
  <xsl:param name="code"/>
  <xsl:param name="counter" select="1"/>
  
  <xsl:choose>
    <xsl:when test="$counter &lt;= count(msxsl:node-set($lineCodesList)/code)">
      <xsl:variable name="matchCode" select="msxsl:node-set($lineCodesList)/code[number($counter)]/matchCode"/>
      <xsl:variable name="replaceCode" select="msxsl:node-set($lineCodesList)/code[number($counter)]/replaceCode"/>

      <xsl:choose>
        <xsl:when test="$hideSpaces = 'true'">  <!-- Will replace any codes with internal space chars with the mid-line dot equivalent codes -->
          <xsl:choose>
            <xsl:when test="contains($code, $matchCode)">
              <xsl:call-template name="SwapMatchedCodes">
                <xsl:with-param name="hideSpaces" select="$hideSpaces"/>
                <xsl:with-param name="code" select="concat(substring-before($code, $matchCode), $replaceCode, substring-after($code, $matchCode))"/>
                <xsl:with-param name="counter" select="$counter + 1"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="SwapMatchedCodes">
                <xsl:with-param name="hideSpaces" select="$hideSpaces"/>
                <xsl:with-param name="code" select="$code"/>
                <xsl:with-param name="counter" select="$counter + 1"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        
        <xsl:otherwise>  <!-- Will replace any codes with mid-line dot codes with internal space char codes -->
          <xsl:choose>
            <xsl:when test="contains($code, $replaceCode)">
              <xsl:call-template name="SwapMatchedCodes">
                <xsl:with-param name="hideSpaces" select="$hideSpaces"/>
                <xsl:with-param name="code" select="concat(substring-before($code, $replaceCode), $matchCode, substring-after($code, $replaceCode))"/>
                <xsl:with-param name="counter" select="$counter + 1"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="SwapMatchedCodes">
                <xsl:with-param name="hideSpaces" select="$hideSpaces"/>
                <xsl:with-param name="code" select="$code"/>
                <xsl:with-param name="counter" select="$counter + 1"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>

    <xsl:otherwise>
      <xsl:value-of select="$code"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- **************************************************************** -->
<!-- ******* Extract the supplied line codes into a node set ******** -->
<!-- **************************************************************** -->
<xsl:template name="ExtractCodeList">
  <xsl:param name="codeString"/>

  <xsl:if test="$codeString != ''">
    <xsl:variable name="thisCode" select="substring-before($codeString, '|')"/>
    <xsl:if test="$thisCode != ''">
      <xsl:variable name="codeWithSwappedSpaces" select="translate($thisCode, ' ', '&#0183;')"/> <!-- Insert a mid-line dot for all space chars -->
      <xsl:element name="code">
        <xsl:element name="matchCode">
          <xsl:value-of select="$thisCode"/>
        </xsl:element>
        <xsl:element name="replaceCode">
          <xsl:value-of select="$codeWithSwappedSpaces"/>
        </xsl:element>
      </xsl:element>
    </xsl:if>

    <!-- Recurse the function -->
    <xsl:call-template name="ExtractCodeList">
      <xsl:with-param name="codeString" select="substring-after($codeString, '|')"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<!-- **************************************************************** -->
<!-- *********** Remove Any Trailing Numbers From Code ************** -->
<!-- **************************************************************** -->
<xsl:template name="RemoveTrailingNumbers">
  <xsl:param name="inCode"/>
  
  <xsl:variable name="lastChar" select="substring($inCode, string-length($inCode))"/>
  <xsl:choose>
    <xsl:when test="string(number($lastChar)) != 'NaN'"> <!-- The last character in the code is numeric -->
      <!-- Call this function recursively removing the numeric last character first -->
      <xsl:call-template name="RemoveTrailingNumbers">
        <xsl:with-param name="inCode" select="substring($inCode, 1, string-length($inCode) - 1)"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>  <!-- The last character in the code is not numeric -->
      <xsl:value-of select="$inCode"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- **************************************************************** -->
<!-- *********** Pad a string to the left with spaces *************** -->
<!-- **************************************************************** -->
<xsl:template name="PadLeft">
  <xsl:param name="StringWidth"/>
  <xsl:param name="TheString"/>
  <xsl:choose>
    <xsl:when test="$StringWidth = '0'">
      <xsl:value-of select="normalize-space($TheString)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="PaddedStr" select="concat('                                       ', $TheString)"/>
      <xsl:value-of select="substring($PaddedStr, string-length($PaddedStr) - $StringWidth + 1)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- **************************************************************** -->
<!-- ********* Return the Julian Day for a given TimeStamp ********** -->
<!-- **************************************************************** -->
<xsl:template name="JulianDay">
  <!-- The formula used in this function is valid for the years 1901 - 2099 -->
  <xsl:param name="timeStamp"/>
  
  <xsl:variable name="Y" select="substring($timeStamp, 1, 4)"/>
  <xsl:variable name="M" select="substring($timeStamp, 6, 2)"/>
  <xsl:variable name="D" select="substring($timeStamp, 9, 2)"/>
  <xsl:variable name="h" select="substring($timeStamp, 12, 2)"/>
  <xsl:variable name="m" select="substring($timeStamp, 15, 2)"/>
  <xsl:variable name="s" select="substring($timeStamp, 18, 2)"/>

  <xsl:value-of select="format-number(367 * $Y - floor(7 * ($Y + floor(($M + 9) div 12)) div 4) +
                                      floor(275 * $M div 9) + $D + 1721013.5 +
                                      ($h + $m div 60 + $s div 3600) div 24, '0.000000000')"/>
  <xsl:text>&#10;</xsl:text>  <!-- Output new line -->
</xsl:template>


<!-- **************************************************************** -->
<!-- ************** Return the Arc Centre Point Coords ************** -->
<!-- **************************************************************** -->
<xsl:template name="ArcCentrePoint">
  <xsl:param name="pointData"/>

  <xsl:if test="CenterPoint">
    <xsl:variable name="centrePt" select="CenterPoint"/>
    <xsl:variable name="centreN">
      <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $centrePt]">
        <xsl:value-of select="Grid/North"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="centreE">
      <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $centrePt]">
        <xsl:value-of select="Grid/East"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="centreElev">
      <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $centrePt]">
        <xsl:value-of select="Grid/Elevation"/>
      </xsl:for-each>
    </xsl:variable>
    <!-- Return the coords as node set variable elements -->
    <centreN><xsl:value-of select="$centreN"/></centreN>
    <centreE><xsl:value-of select="$centreE"/></centreE>
    <centreElev><xsl:value-of select="$centreElev"/></centreElev>
  </xsl:if>

  <xsl:if test="StartPoint and EndPoint and not(CenterPoint or OtherPointOnArc)">
    <xsl:variable name="startPt" select="StartPoint"/>
    <xsl:variable name="endPt" select="EndPoint"/>
    <xsl:variable name="startN">
      <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $startPt]">
        <xsl:value-of select="Grid/North"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="startE">
      <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $startPt]">
        <xsl:value-of select="Grid/East"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="startElev">
      <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $startPt]">
        <xsl:value-of select="Grid/Elevation"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="endN">
      <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $endPt]">
        <xsl:value-of select="Grid/North"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="endE">
      <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $endPt]">
        <xsl:value-of select="Grid/East"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="endElev">
      <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $endPt]">
        <xsl:value-of select="Grid/Elevation"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="deltaN" select="$endN - $startN"/>
    <xsl:variable name="deltaE" select="$endE - $startE"/>
    <!-- The mid point of the chord is the average of the start and end coords -->
    <xsl:variable name="chordMidN" select="($startN + $endN) div 2.0"/>
    <xsl:variable name="chordMidE" select="($startE + $endE) div 2.0"/>

    <xsl:variable name="chordLen">
      <xsl:call-template name="Sqrt">
        <xsl:with-param name="num" select="$deltaN * $deltaN + $deltaE * $deltaE"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="chordAz">
      <xsl:call-template name="InverseAzimuth">
        <xsl:with-param name="deltaN" select="$deltaN"/>
        <xsl:with-param name="deltaE" select="$deltaE"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- Compute the distance to the centre point from the mid point of the chord -->
    <xsl:variable name="distToCentre">
      <xsl:call-template name="Sqrt">
        <xsl:with-param name="num" select="Radius * Radius - ($chordLen div 2.0) * ($chordLen div 2.0)"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- Get the azimuth from the mid point of the arc to the centre point (right angles to chordAz) -->
    <xsl:variable name="azToCentre">
      <xsl:choose>
        <xsl:when test="Direction = 'Right'">
          <xsl:value-of select="$chordAz + $halfPi"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="$chordAz - $halfPi"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="sineVal">
      <xsl:call-template name="Sine">
        <xsl:with-param name="TheAngle" select="$azToCentre"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="cosineVal">
      <xsl:call-template name="Cosine">
        <xsl:with-param name="TheAngle" select="$azToCentre"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="centreN" select="$chordMidN + $cosineVal * $distToCentre"/>
    <xsl:variable name="centreE" select="$chordMidE + $sineVal * $distToCentre"/>
    <xsl:variable name="centreElev" select="($startElev + $endElev) div 2.0"/>  <!-- Compute average elevation -->
    
    <!-- Return the coords as node set variable elements -->
    <centreN><xsl:value-of select="$centreN"/></centreN>
    <centreE><xsl:value-of select="$centreE"/></centreE>
    <centreElev><xsl:value-of select="$centreElev"/></centreElev>
  </xsl:if>
  
  <xsl:if test="StartPoint and StartAzimuth and (Length or DeltaAngle)">
    <xsl:variable name="startPt" select="StartPoint"/>
    <xsl:variable name="startN">
      <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $startPt]">
        <xsl:value-of select="Grid/North"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="startE">
      <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $startPt]">
        <xsl:value-of select="Grid/East"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="startElev">
      <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $startPt]">
        <xsl:value-of select="Grid/Elevation"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="arcLen">
      <xsl:choose>
        <xsl:when test="Length"><xsl:value-of select="Length"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="DeltaAngle * $Pi div 180.0 * Radius"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Get the azimuth from the start point of the arc to the centre point (right angles to StartAzimuth) -->
    <xsl:variable name="azToCentre">
      <xsl:choose>
        <xsl:when test="Direction = 'Right'">
          <xsl:value-of select="StartAzimuth * $Pi div 180.0 + $halfPi"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="StartAzimuth * $Pi div 180.0 - $halfPi"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="posn">
      <xsl:call-template name="FollowAzimuth">
        <xsl:with-param name="azimuth" select="$azToCentre"/>
        <xsl:with-param name="distance" select="Radius"/>
        <xsl:with-param name="startN" select="$startN"/>
        <xsl:with-param name="startE" select="$startE"/>
        <xsl:with-param name="elev1" select="$startElev"/>
        <xsl:with-param name="length" select="$arcLen"/>
        <xsl:with-param name="grade" select="Grade"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- Return the coords as node set variable elements -->
    <centreN><xsl:value-of select="msxsl:node-set($posn)/north"/></centreN>
    <centreE><xsl:value-of select="msxsl:node-set($posn)/east"/></centreE>
    <centreElev><xsl:value-of select="msxsl:node-set($posn)/elev"/></centreElev>
  </xsl:if>
  
  <xsl:if test="IntersectionPoint">
    <xsl:variable name="intPt" select="IntersectionPoint"/>
    <xsl:variable name="intN">
      <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $intPt]">
        <xsl:value-of select="Grid/North"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="intE">
      <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $intPt]">
        <xsl:value-of select="Grid/East"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="intElev">
      <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $intPt]">
        <xsl:value-of select="Grid/Elevation"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="deflectionAngle">
      <xsl:variable name="defl1">
        <xsl:choose>
          <xsl:when test="Direction = 'Right'">
            <xsl:value-of select="(EndAzimuth - StartAzimuth) * $Pi div 180.0"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="(StartAzimuth - EndAzimuth) * $Pi div 180.0"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="defl2">
        <xsl:call-template name="RadianAngleBetweenLimits">
          <xsl:with-param name="AnAngle" select="$defl1"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="$defl2 &gt; $Pi"><xsl:value-of select="2.0 * $Pi - $defl2"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="$defl2"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="tangentLen">
      <xsl:variable name="tanVal">
        <xsl:call-template name="Tan">
          <xsl:with-param name="TheAngle" select="$deflectionAngle div 2.0"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:value-of select="Radius * $tanVal"/>
    </xsl:variable>

    <xsl:variable name="distToCentre">
      <xsl:call-template name="Sqrt">
        <xsl:with-param name="num" select="$tangentLen * $tangentLen + Radius * Radius"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="azToCentre">
      <xsl:choose>
        <xsl:when test="Direction = 'Right'">
          <xsl:value-of select="EndAzimuth * $Pi div 180.0 + ($halfPi - $deflectionAngle div 2.0)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="EndAzimuth * $Pi div 180.0 - ($halfPi - $deflectionAngle div 2.0)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="posn">
      <xsl:call-template name="FollowAzimuth">
        <xsl:with-param name="azimuth" select="$azToCentre"/>
        <xsl:with-param name="distance" select="$distToCentre"/>
        <xsl:with-param name="startN" select="$intN"/>
        <xsl:with-param name="startE" select="$intE"/>
        <xsl:with-param name="elev1" select="$intElev"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- Return the coords as node set variable elements -->
    <centreN><xsl:value-of select="msxsl:node-set($posn)/north"/></centreN>
    <centreE><xsl:value-of select="msxsl:node-set($posn)/east"/></centreE>
    <centreElev><xsl:value-of select="msxsl:node-set($posn)/elev"/></centreElev>
  </xsl:if>

  <xsl:if test="OtherPointOnArc">  <!-- Three points arc definition -->
    <xsl:variable name="startPt" select="StartPoint"/>
    <xsl:variable name="endPt" select="EndPoint"/>
    <xsl:variable name="otherPt" select="OtherPointOnArc"/>
    <xsl:variable name="startN">
      <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $startPt]">
        <xsl:value-of select="Grid/North"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="startE">
      <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $startPt]">
        <xsl:value-of select="Grid/East"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="startElev">
      <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $startPt]">
        <xsl:value-of select="Grid/Elevation"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="endN">
      <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $endPt]">
        <xsl:value-of select="Grid/North"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="endE">
      <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $endPt]">
        <xsl:value-of select="Grid/East"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="endElev">
      <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $endPt]">
        <xsl:value-of select="Grid/Elevation"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="otherN">
      <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $otherPt]">
        <xsl:value-of select="Grid/North"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="otherE">
      <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $otherPt]">
        <xsl:value-of select="Grid/East"/>
      </xsl:for-each>
    </xsl:variable>

    <!-- The mid point of each chord is the average of the start and end coords -->
    <xsl:variable name="chord1MidN" select="($startN + $otherN) div 2.0"/>
    <xsl:variable name="chord1MidE" select="($startE + $otherE) div 2.0"/>
    <xsl:variable name="chord2MidN" select="($endN + $otherN) div 2.0"/>
    <xsl:variable name="chord2MidE" select="($endE + $otherE) div 2.0"/>

    <xsl:variable name="azimuth1">  <!-- Start point to third point -->
      <xsl:call-template name="InverseAzimuth">
        <xsl:with-param name="deltaN" select="$otherN - $startN"/>
        <xsl:with-param name="deltaE" select="$otherE - $startE"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="azimuth2">  <!-- Third point to end point -->
      <xsl:call-template name="InverseAzimuth">
        <xsl:with-param name="deltaN" select="$endN - $otherN"/>
        <xsl:with-param name="deltaE" select="$endE - $otherE"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="midPtAzimuth">  <!-- Azimuth between two chord mid points -->
      <xsl:call-template name="InverseAzimuth">
        <xsl:with-param name="deltaN" select="$chord2MidN - $chord1MidN"/>
        <xsl:with-param name="deltaE" select="$chord2MidE - $chord1MidE"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="deflAngle">
      <xsl:variable name="absAngle" select="concat(substring('-',2 - (($azimuth2 - $azimuth1) &lt; 0)), '1') * ($azimuth2 - $azimuth1)"/>
      <xsl:choose>
        <xsl:when test="$absAngle &gt; $Pi">
          <xsl:value-of select="$Pi * 2.0 - $absAngle"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="$absAngle"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="deltaAngle">
      <xsl:variable name="absAngle" select="concat(substring('-',2 - (($azimuth2 - $midPtAzimuth) &lt; 0)), '1') * ($azimuth2 - $midPtAzimuth)"/>
      <xsl:choose>
        <xsl:when test="$absAngle &gt; $Pi">
          <xsl:value-of select="$Pi * 2.0 - $absAngle"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$absAngle"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="baseAngle" select="$Pi div 2.0 - $deltaAngle"/>

    <xsl:variable name="baseDist">
      <xsl:call-template name="Sqrt">
        <xsl:with-param name="num" select="($chord2MidN - $chord1MidN) * ($chord2MidN - $chord1MidN) + ($chord2MidE - $chord1MidE) * ($chord2MidE - $chord1MidE)"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- Use the Sine rule to compute the distance to the centre point from the mid point of the first chord -->
    <xsl:variable name="sinB">
      <xsl:call-template name="Sine">
        <xsl:with-param name="TheAngle" select="$baseAngle"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="sinA">
      <xsl:call-template name="Sine">
        <xsl:with-param name="TheAngle" select="$deflAngle"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="distToCentre" select="$baseDist * $sinB div $sinA"/>

    <!-- Need to determine if the arc is going left or right -->
    <xsl:variable name="arcDirn">
      <xsl:call-template name="ArcDirection">
        <xsl:with-param name="startN" select="$startN"/>
        <xsl:with-param name="startE" select="$startE"/>
        <xsl:with-param name="endN" select="$otherN"/>
        <xsl:with-param name="endE" select="$otherE"/>
        <xsl:with-param name="pointN" select="$endN"/>
        <xsl:with-param name="pointE" select="$endE"/>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="azimuth">
      <xsl:choose>
        <xsl:when test="$arcDirn = 'right'">
          <xsl:value-of select="$azimuth1 + $Pi div 2.0"/>  <!-- Add 90° -->
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$azimuth1 - $Pi div 2.0"/>  <!-- Subtract 90° -->
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="posn">
      <xsl:call-template name="FollowAzimuth">
        <xsl:with-param name="azimuth" select="$azimuth"/>
        <xsl:with-param name="distance" select="$distToCentre"/>
        <xsl:with-param name="startN" select="$chord1MidN"/>
        <xsl:with-param name="startE" select="$chord1MidE"/>
        <xsl:with-param name="elev1" select="$startElev"/>
        <xsl:with-param name="elev2" select="$endElev"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- Return the coords as node set variable elements -->
    <centreN><xsl:value-of select="msxsl:node-set($posn)/north"/></centreN>
    <centreE><xsl:value-of select="msxsl:node-set($posn)/east"/></centreE>
    <centreElev><xsl:value-of select="msxsl:node-set($posn)/elev"/></centreElev>
  </xsl:if>
</xsl:template>


<!-- **************************************************************** -->
<!-- ********* Follow Azimuth to Compute New Point Coords *********** -->
<!-- **************************************************************** -->
<xsl:template name="FollowAzimuth">
  <xsl:param name="azimuth"/>
  <xsl:param name="distance"/>
  <xsl:param name="startN"/>
  <xsl:param name="startE"/>
  <xsl:param name="elev1" select="''"/>
  <xsl:param name="elev2" select="''"/>
  <xsl:param name="length" select="''"/>
  <xsl:param name="grade" select="''"/>

  <xsl:variable name="sineVal">
    <xsl:call-template name="Sine">
      <xsl:with-param name="TheAngle" select="$azimuth"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="cosineVal">
    <xsl:call-template name="Cosine">
      <xsl:with-param name="TheAngle" select="$azimuth"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="newN" select="$startN + $cosineVal * $distance"/>
  <xsl:variable name="newE" select="$startE + $sineVal * $distance"/>
  <xsl:variable name="newElev">
    <xsl:choose>
      <xsl:when test="(string(number($elev1)) != 'NaN') and (string(number($elev2)) != 'NaN')">
        <xsl:value-of select="($elev1 + $elev2) div 2.0"/> <!-- Return average elevation -->
      </xsl:when>
      <xsl:when test="(string(number($elev1)) != 'NaN') and (string(number($length)) != 'NaN') and
                      (string(number($grade)) != 'NaN')">
        <xsl:value-of select="$elev1 + ($grade * $length) div 2.0"/> <!-- Average elevation of arc from grade and length -->
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$elev1"/></xsl:otherwise> <!-- Return the first elevation (in any) supplied -->
    </xsl:choose>
  </xsl:variable>

  <!-- Return the coords as node set var elements -->
  <north><xsl:value-of select="$newN"/></north>
  <east><xsl:value-of select="$newE"/></east>
  <elev><xsl:value-of select="$newElev"/></elev>
</xsl:template>


<!-- **************************************************************** -->
<!-- ********* Determine Arc Direction for Thrre Point Arc ********** -->
<!-- **************************************************************** -->
<xsl:template name="ArcDirection">
  <xsl:param name="startN"/>
  <xsl:param name="startE"/>
  <xsl:param name="endN"/>
  <xsl:param name="endE"/>
  <xsl:param name="pointN"/>
  <xsl:param name="pointE"/>

  <!-- Determine if the arc is going left or right - return 'left' or 'right' -->
  <xsl:variable name="test" select="($pointN - $startN) * ($endE - $startE) - ($pointE - $startE) * ($endN - $startN)"/>
  <xsl:choose>
    <xsl:when test="$test &lt; 0">right</xsl:when>
    <xsl:otherwise>left</xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- **************************************************************** -->
<!-- ************ Compute AutoCAD Azimuth to Arc Point ************** -->
<!-- **************************************************************** -->
<xsl:template name="AzimuthToArcPt">
  <xsl:param name="pointData"/>
  <xsl:param name="pointName"/>
  <xsl:param name="centreN"/>
  <xsl:param name="centreE"/>

  <xsl:variable name="ptN">
    <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $pointName]">
      <xsl:value-of select="Grid/North"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="ptE">
    <xsl:for-each select="msxsl:node-set($pointData)/Coords[Name = $pointName]">
      <xsl:value-of select="Grid/East"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="azimuth">
    <xsl:call-template name="InverseAzimuth">
      <xsl:with-param name="deltaN" select="$ptN - $centreN"/>
      <xsl:with-param name="deltaE" select="$ptE - $centreE"/>
    </xsl:call-template>
  </xsl:variable>
  
  <!-- Now convert to an AutoCAD type azimuth (anti-clockwise from 0° east) -->
  <xsl:call-template name="AutoCADAzimuth">
    <xsl:with-param name="stdAzimuth" select="$azimuth"/>
  </xsl:call-template>
</xsl:template>


<!-- **************************************************************** -->
<!-- ******************* Compute AutoCAD Azimuth ******************** -->
<!-- **************************************************************** -->
<xsl:template name="AutoCADAzimuth">
  <xsl:param name="stdAzimuth"/>

  <!-- Convert to an AutoCAD type azimuth (anti-clockwise from 0° east) -->
  <xsl:call-template name="RadianAngleBetweenLimits">
    <xsl:with-param name="AnAngle" select="(2.0 * $Pi - $stdAzimuth) + $halfPi"/>
  </xsl:call-template>
</xsl:template>


<!-- **************************************************************** -->
<!-- ******************* Compute Inverse Azimuth ******************** -->
<!-- **************************************************************** -->
<xsl:template name="InverseAzimuth">
  <xsl:param name="deltaN"/>
  <xsl:param name="deltaE"/>

  <!-- Compute the inverse azimuth from the deltas -->
  <xsl:variable name="absDeltaN" select="concat(substring('-',2 - ($deltaN &lt; 0)), '1') * $deltaN"/>

  <xsl:variable name="absDeltaE" select="concat(substring('-',2 - ($deltaE &lt; 0)), '1') * $deltaE"/>

  <xsl:variable name="flag">
    <xsl:choose>
      <xsl:when test="$absDeltaE &gt; $absDeltaN">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="adjDeltaN">
    <xsl:choose>
      <xsl:when test="$flag"><xsl:value-of select="$absDeltaE"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$absDeltaN"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="adjDeltaE">
    <xsl:choose>
      <xsl:when test="$flag"><xsl:value-of select="$absDeltaN"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$absDeltaE"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- Compute the raw angle value -->
  <xsl:variable name="angle">
    <xsl:choose>
      <xsl:when test="$adjDeltaN &lt; 0.000001">
        <xsl:value-of select="0"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="arcTanAngle">
          <xsl:call-template name="ArcTan">
            <xsl:with-param name="tanVal" select="$adjDeltaE div $adjDeltaN"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$flag">
            <xsl:value-of select="$halfPi - $arcTanAngle"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$arcTanAngle"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- Assemble the raw angle value into an azimuth to be returned in radians -->
  <xsl:choose>
    <xsl:when test="$deltaE &lt; 0">
      <xsl:choose>
        <xsl:when test="$deltaN &lt; 0">
          <xsl:value-of select="$Pi + $angle"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$Pi * 2 - $angle"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="$deltaN &lt; 0">
          <xsl:value-of select="$Pi - $angle"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$angle"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>


<!-- **************************************************************** -->
<!-- *************** Return the square root of a value ************** -->
<!-- **************************************************************** -->
<xsl:template name="Sqrt">
  <xsl:param name="num" select="0"/>       <!-- The number you want to find the square root of -->
  <xsl:param name="try" select="1"/>       <!-- The current 'try'.  This is used internally. -->
  <xsl:param name="iter" select="1"/>      <!-- The current iteration, checked against maxiter to limit loop count - used internally -->
  <xsl:param name="maxiter" select="20"/>  <!-- Set this up to insure against infinite loops - used internally -->

  <!-- This template uses Sir Isaac Newton's method of finding roots -->

  <xsl:choose>
    <xsl:when test="$try * $try = $num or $iter &gt; $maxiter">
      <xsl:value-of select="$try"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="Sqrt">
        <xsl:with-param name="num" select="$num"/>
        <xsl:with-param name="try" select="$try - (($try * $try - $num) div (2 * $try))"/>
        <xsl:with-param name="iter" select="$iter + 1"/>
        <xsl:with-param name="maxiter" select="$maxiter"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- **************************************************************** -->
<!-- **************************************************************** -->
<!-- *** Trig functions used in arc computations follow from here *** -->
<!-- **************************************************************** -->
<!-- **************************************************************** -->

<!-- **************************************************************** -->
<!-- ************ Return the sine of an angle in radians ************ -->
<!-- **************************************************************** -->
<xsl:template name="Sine">
  <xsl:param name="TheAngle"/>
  <xsl:variable name="NormalisedAngle">
    <xsl:call-template name="RadianAngleBetweenLimits">
      <xsl:with-param name="AnAngle" select="$TheAngle"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="TheSine">
    <xsl:call-template name="sineIter">
      <xsl:with-param name="pX2" select="$NormalisedAngle * $NormalisedAngle"/>
      <xsl:with-param name="pRslt" select="$NormalisedAngle"/>
      <xsl:with-param name="pElem" select="$NormalisedAngle"/>
      <xsl:with-param name="pN" select="1"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:value-of select="number($TheSine)"/>
</xsl:template>

<xsl:template name="sineIter">
  <xsl:param name="pX2"/>
  <xsl:param name="pRslt"/>
  <xsl:param name="pElem"/>
  <xsl:param name="pN"/>
  <xsl:param name="prec" select="0.00000001"/>
  <xsl:variable name="vnextN" select="$pN+2"/>
  <xsl:variable name="vnewElem"  select="-$pElem*$pX2 div ($vnextN*($vnextN - 1))"/>
  <xsl:variable name="vnewResult" select="$pRslt + $vnewElem"/>
  <xsl:variable name="vdiffResult" select="$vnewResult - $pRslt"/>
  <xsl:choose>
    <xsl:when test="$vdiffResult > $prec or $vdiffResult &lt; -$prec">
      <xsl:call-template name="sineIter">
        <xsl:with-param name="pX2" select="$pX2"/>
        <xsl:with-param name="pRslt" select="$vnewResult"/>
        <xsl:with-param name="pElem" select="$vnewElem"/>
        <xsl:with-param name="pN" select="$vnextN"/>
        <xsl:with-param name="prec" select="$prec"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$vnewResult"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- **************************************************************** -->
<!-- *********** Return the Cosine of an angle in radians *********** -->
<!-- **************************************************************** -->
<xsl:template name="Cosine">
  <xsl:param name="TheAngle"/>

  <!-- Use the sine function after subtracting the angle from halfPi -->
  <xsl:call-template name="Sine">
    <xsl:with-param name="TheAngle" select="$halfPi - $TheAngle"/>
  </xsl:call-template>
</xsl:template>


<!-- **************************************************************** -->
<!-- *********** Return the Tangent of an angle in radians ********** -->
<!-- **************************************************************** -->
<xsl:template name="Tan">
  <xsl:param name="TheAngle"/>
  <xsl:param name="prec" select=".00000001"/>
  <xsl:param name="abortIfInvalid" select="1"/>

  <xsl:variable name="xDivHalfPi" select="floor($TheAngle div $halfPi)"/>
  <xsl:variable name="xHalfPiDiff" select="$TheAngle - $halfPi * $xDivHalfPi"/>

  <xsl:choose>  <!-- Check for a solution -->
    <xsl:when test="(-$prec &lt; $xHalfPiDiff) and
                    ($xHalfPiDiff &lt; $prec) and
                    ($xDivHalfPi mod 2 = 1)">
      <xsl:choose>
        <xsl:when test="$abortIfInvalid">
          <xsl:message terminate="yes">
            <xsl:value-of select="concat('Function error: tan() not defined for TheAngle =', $TheAngle)"/>
          </xsl:message>
        </xsl:when>

        <xsl:otherwise>Infinity</xsl:otherwise>
      </xsl:choose>
    </xsl:when>

    <!-- Compute the sine and cosine of the angle to get the tangent value -->
    <xsl:otherwise>
      <xsl:variable name="vSin">
        <xsl:call-template name="Sine">
          <xsl:with-param name="TheAngle" select="$TheAngle"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="vCos">
        <xsl:call-template name="Cosine">
          <xsl:with-param name="TheAngle" select="$TheAngle"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:value-of select="$vSin div $vCos"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- **************************************************************** -->
<!-- ** Compute the arcTangent of value - angle returned in radians * -->
<!-- **************************************************************** -->
<xsl:template name="ArcTan">
  <xsl:param name="tanVal"/>
  <xsl:param name="prec" select="0.0000001"/>

  <!-- Solve the arctan value by using Newton's Method of solving the solution -->
  <!-- to an equation:                                                         -->
  <!--                               f(x )                                     -->
  <!--                                  n                                      -->
  <!--                 x     = x  -  ______                                    -->
  <!--                  n+1     n    f'(x )                                    -->
  <!--                                   n                                     -->
  <!--                                                                         -->
  <!-- The derivative of the tan function is:                                  -->
  <!--                                1                                        -->
  <!--                              ______                                     -->
  <!--                                    2                                    -->
  <!--                              cos(x)                                     -->
  <!--                                                                         -->
  <!-- This provides the following equation to be implemented for an arctan    -->
  <!-- function:                                                               -->
  <!--                                                          2              -->
  <!--                 x     = x  - (tan(x ) - tanVal) * cos(x )               -->
  <!--                  n+1     n         n                   n                -->
  <!--                                                                         -->

  <!-- If the tangent value is greater than 1 (45°) solve for the              -->
  <!-- complementary angle and then subtract it from 90° later                 -->

  <xsl:variable name="sign">
    <xsl:if test="$tanVal &lt; 0.0">-1</xsl:if>
    <xsl:if test="$tanVal &gt;= 0.0">1</xsl:if>
  </xsl:variable>
  <xsl:variable name="absTanVal" select="$tanVal * $sign"/>

  <xsl:variable name="tanValGreaterThan1">
    <xsl:if test="$absTanVal &gt; 1">1</xsl:if>
    <xsl:if test="not($absTanVal &gt; 1)">0</xsl:if>
  </xsl:variable>

  <xsl:variable name="tanValToUse">
    <xsl:choose>
      <xsl:when test="number($tanValGreaterThan1)">
        <xsl:value-of select="1.0 div $absTanVal"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$absTanVal"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="arcTanVal">
    <xsl:call-template name="RadianAngleBetweenLimits">  <!-- Return a normalised value between minus two Pi and two Pi -->
      <xsl:with-param name="minVal" select="-1 * $Pi * 2.0"/>
      <xsl:with-param name="AnAngle">
        <xsl:call-template name="ArcTanIter">
          <xsl:with-param name="tanVal" select="$tanValToUse"/>
          <xsl:with-param name="prec" select="$prec"/>
          <xsl:with-param name="x" select="0"/>   <!-- Start at zero as first estimate -->
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="number($tanValGreaterThan1)">
      <xsl:value-of select="$sign * ($Pi div 2.0 - $arcTanVal)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$sign * $arcTanVal"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="ArcTanIter">
  <xsl:param name="tanVal"/>
  <xsl:param name="x" select="1"/>
  <xsl:param name="iterCount" select="1"/>
  <xsl:param name="prec" select="0.0000001"/>
  <xsl:variable name="maxIter" select="100"/>

  <xsl:variable name="tanX">
    <xsl:call-template name="Tan">
      <xsl:with-param name="TheAngle" select="$x"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="cosX">
    <xsl:call-template name="Cosine">
      <xsl:with-param name="TheAngle" select="$x"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="xNew" select="$x - ($tanX - $tanVal) * $cosX * $cosX"/>

  <xsl:variable name="absDiff">
    <xsl:value-of select="concat(substring('-',2 - (($xNew - $x) &lt; 0)), '1') * ($xNew - $x)"/>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="($absDiff &lt; $prec) or ($iterCount &gt; $maxIter)">
      <xsl:value-of select="$xNew"/>  <!-- We have a solution or have run out of iterations -->
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="ArcTanIter">
        <xsl:with-param name="tanVal" select="$tanVal"/>
        <xsl:with-param name="x" select="$xNew"/>
        <xsl:with-param name="iterCount" select="$iterCount + 1"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<!-- **************************************************************** -->
<!-- ******* Return radians angle less than Specificed Maximum ****** -->
<!-- **************************************************************** -->
<xsl:template name="AngleValueLessThanMax">
  <xsl:param name="InAngle"/>
  <xsl:param name="maxVal"/>
  <xsl:param name="incVal"/>

  <xsl:choose>
    <xsl:when test="$InAngle &gt; $maxVal">
      <xsl:variable name="NewAngle">
        <xsl:value-of select="$InAngle - $incVal"/>
      </xsl:variable>
      <xsl:call-template name="AngleValueLessThanMax">
        <xsl:with-param name="InAngle" select="$NewAngle"/>
      </xsl:call-template>
    </xsl:when>

    <xsl:otherwise>
      <xsl:value-of select="$InAngle"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- **************************************************************** -->
<!-- ****** Return radians angle greater than Specified Minimum ***** -->
<!-- **************************************************************** -->
<xsl:template name="AngleValueGreaterThanMin">
  <xsl:param name="InAngle"/>
  <xsl:param name="minVal"/>
  <xsl:param name="incVal"/>

  <xsl:choose>
    <xsl:when test="$InAngle &lt; $minVal">
      <xsl:variable name="NewAngle">
        <xsl:value-of select="$InAngle + $incVal"/>
      </xsl:variable>
      <xsl:call-template name="AngleValueGreaterThanMin">
        <xsl:with-param name="InAngle" select="$NewAngle"/>
      </xsl:call-template>
    </xsl:when>

    <xsl:otherwise>
      <xsl:value-of select="$InAngle"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- **************************************************************** -->
<!-- ********* Return radians angle between Specified Limits ******** -->
<!-- **************************************************************** -->
<xsl:template name="RadianAngleBetweenLimits">
  <xsl:param name="AnAngle"/>
  <xsl:param name="minVal" select="0.0"/>
  <xsl:param name="maxVal" select="$Pi * 2.0"/>
  <xsl:param name="incVal" select="$Pi * 2.0"/>

  <xsl:variable name="Angle1">
    <xsl:call-template name="AngleValueLessThanMax">
      <xsl:with-param name="InAngle" select="$AnAngle"/>
      <xsl:with-param name="maxVal" select="$maxVal"/>
      <xsl:with-param name="incVal" select="$incVal"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="Angle2">
    <xsl:call-template name="AngleValueGreaterThanMin">
      <xsl:with-param name="InAngle" select="$Angle1"/>
      <xsl:with-param name="minVal" select="$minVal"/>
      <xsl:with-param name="incVal" select="$incVal"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:value-of select="$Angle2"/>
</xsl:template>


</xsl:stylesheet>
