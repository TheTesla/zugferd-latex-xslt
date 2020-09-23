<?xml version="1.0" encoding="utf8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rsm="urn:ferd:CrossIndustryDocument:invoice:1p0" xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:12" xmlns:udt="urn:un:unece:uncefact:data:standard:UnqualifiedDataType:15" xmlns:func="http://exslt.org/functions" xmlns:zf="http://entroserv.de/zf" extension-element-prefixes="func" exclude-result-prefixes="zf">

<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>


<xsl:variable name="seller" select="/rsm:CrossIndustryDocument/rsm:SpecifiedSupplyChainTradeTransaction/ram:ApplicableSupplyChainTradeAgreement/ram:SellerTradeParty"/>
<xsl:variable name="selleraddr" select="$seller/ram:PostalTradeAddress"/>
<xsl:variable name="buyer" select="/rsm:CrossIndustryDocument/rsm:SpecifiedSupplyChainTradeTransaction/ram:ApplicableSupplyChainTradeAgreement/ram:BuyerTradeParty"/>
<xsl:variable name="buyeraddr" select="$buyer/ram:PostalTradeAddress"/>
<xsl:variable name="header" select="/rsm:CrossIndustryDocument/rsm:HeaderExchangedDocument"/>
<xsl:variable name="datistr" select="$header/ram:IssueDateTime/udt:DateTimeString"/>
<xsl:variable name="payacc" select="/rsm:CrossIndustryDocument/rsm:SpecifiedSupplyChainTradeTransaction/ram:ApplicableSupplyChainTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans"/>
<xsl:variable name="sums" select="/rsm:CrossIndustryDocument/rsm:SpecifiedSupplyChainTradeTransaction/ram:ApplicableSupplyChainTradeSettlement/ram:SpecifiedTradeSettlementMonetarySummation"/>
<xsl:variable name="taxsum" select="/rsm:CrossIndustryDocument/rsm:SpecifiedSupplyChainTradeTransaction/ram:ApplicableSupplyChainTradeSettlement/ram:ApplicableTradeTax"/>
<xsl:variable name="positions" select="/rsm:CrossIndustryDocument/rsm:SpecifiedSupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem"/>
<xsl:variable name="tax" select="$seller/ram:SpecifiedTaxRegistration"/>
<xsl:variable name="ustid" select="$tax/ram:ID[@schemeID='VA']"/>
<xsl:variable name="contact" select="$seller/ram:DefinedTradeContact"/>

<func:function name="zf:formatcurrency">
	<xsl:param name="x" select="."/>
  <xsl:choose>
	  <xsl:when test="contains($x/@currencyID,'EUR')">
      <func:result select="'\ \euro'"/>
    </xsl:when>
    <xsl:otherwise>
      <func:result select="''"/>
    </xsl:otherwise>
  </xsl:choose>
</func:function>


<func:function name="zf:formatmoney">
  <xsl:param name="x" select="."/>
  <xsl:choose>
  <xsl:when test="$x">
    <func:result select="concat(translate(format-number(round($x * 100) div 100, '0.00'), '.', ','), zf:formatcurrency($x))" />
  </xsl:when>
  <xsl:otherwise>
    <func:result select="''" />
  </xsl:otherwise>
  </xsl:choose>
</func:function>

<func:function name="zf:formattax">
  <xsl:param name="x" select="."/>
  <func:result select="concat(translate(format-number(round($x * 10) div 10, '0.0'), '.', ','), '\%')" />
</func:function>

<func:function name="zf:formatallowance">
  <xsl:param name="x" select="."/>
  <xsl:choose>
  <xsl:when test="$x">
    <func:result select="concat(zf:formatmoney($x/ram:ActualAmount), '\ (', translate(format-number(round($x/ram:CalculationPercent * 100) div 100, '0.00'), '.', ','), '\%)')" />
  </xsl:when>
  <xsl:otherwise>
    <func:result select="''" />
  </xsl:otherwise>
  </xsl:choose>
</func:function>

<xsl:template match="/">


\documentclass{scrlttr2}		

\KOMAoptions{}

\usepackage[ngerman]{babel}
\usepackage[T1]{fontenc}
\usepackage[utf8]{inputenc}
\usepackage{lmodern} %Type1-Schriftart für nicht-englische Texte
\usepackage{graphicx}
\usepackage{lastpage}
\usepackage{eurosym}
\usepackage{tabularx}
\usepackage{calc}
\usepackage[a-3b]{pdfx}



\newcommand{\bank}{%
\begin{tabular}[t]{lll}
\textbf{Bank} &amp; \textbf{BIC} &amp; \textbf{IBAN}
  <xsl:for-each select="$payacc">
	\\  <xsl:value-of select="ram:PayeeSpecifiedCreditorFinancialInstitution/ram:Name"/> &amp;  <xsl:value-of select="ram:PayeeSpecifiedCreditorFinancialInstitution/ram:BICID"/> &amp;  <xsl:value-of select="ram:PayeePartyCreditorFinancialAccount/ram:IBANID"/>	
  </xsl:for-each>
\end{tabular}
}%

\newcommand{\kontakt}{%
\begin{tabular}[t]{ll}
\textbf{Telefon:} &amp; <xsl:value-of select="$contact/ram:TelephoneUniversalCommunication/ram:CompleteNumber"/> \\
\textbf{E-Mail:} &amp; <xsl:value-of select="$contact/ram:EmailURIUniversalCommunication/ram:URIID"/>
\end{tabular}
}%

\newcommand{\taxid}{%
\begin{tabular}[t]{ll}
\textbf{USt-IdNr.:} &amp; <xsl:value-of select="$ustid"/>\\
\end{tabular}
}%

\firstfoot{%
\rule{\textwidth}{.4pt}\\
\begin{tabular}[t]{@{}lcr@{}}
\scalebox{0.65}{\kontakt} &amp; \scalebox{0.65}{\taxid} &amp; \scalebox{0.65}{\bank} \\
\end{tabular} \\
\centerline{Seite \thepage\ von \pageref{LastPage}}
}%

\newcommand{\itemtable}{%
\begin{tabularx}{\textwidth/\real{0.7}}{@{}rlXrrrrrr@{}}
\textbf{Pos.} &amp; \textbf{Art.-Nr.} &amp; \textbf{Bezeichnung} &amp; \textbf{USt.} &amp; \textbf{Menge} &amp; \textbf{EVP} &amp; \textbf{Rabatt} &amp; \textbf{EP} &amp; \textbf{GP} \\\hline
<xsl:for-each select="$positions/ram:SpecifiedTradeProduct"><xsl:value-of select="../ram:AssociatedDocumentLineDocument/ram:LineID"/>&amp;<xsl:value-of select="./ram:SellerAssignedID"/>&amp;<xsl:value-of select="./ram:Name"/> &amp;<xsl:value-of select="zf:formattax(../ram:SpecifiedSupplyChainTradeSettlement/ram:ApplicableTradeTax/ram:ApplicablePercent)"/> &amp; <xsl:value-of select="round(../ram:SpecifiedSupplyChainTradeDelivery/ram:BilledQuantity)"/> &amp; <xsl:value-of select="zf:formatmoney(../ram:SpecifiedSupplyChainTradeAgreement/ram:GrossPriceProductTradePrice/ram:ChargeAmount)"/>&amp; <xsl:value-of select="zf:formatallowance(../ram:SpecifiedSupplyChainTradeAgreement/ram:GrossPriceProductTradePrice/ram:AppliedTradeAllowanceCharge)"/> &amp; <xsl:value-of select="zf:formatmoney(../ram:SpecifiedSupplyChainTradeAgreement/ram:NetPriceProductTradePrice/ram:ChargeAmount)"/> &amp; <xsl:value-of select="zf:formatmoney(../ram:SpecifiedSupplyChainTradeSettlement/ram:SpecifiedTradeSettlementMonetarySummation/ram:LineTotalAmount)"/>\\</xsl:for-each>\hline 
\end{tabularx}
}

\newcommand{\taxsum}{%
\begin{tabular}[b]{@{}rrrrr@{}}
\textbf{Steuersatz} &amp; \textbf{Basispreis} &amp; \textbf{Rabatt} &amp; \textbf{Endpreis} &amp; \textbf{Steuern} \\\hline
<xsl:for-each select="$taxsum"> <xsl:value-of select="zf:formattax(ram:ApplicablePercent)"/>&amp;<xsl:value-of select="zf:formatmoney(ram:LineTotalBasisAmount)"/> &amp; <xsl:value-of select="zf:formatmoney(ram:AllowanceChargeBasisAmount)"/> &amp; <xsl:value-of select="zf:formatmoney(ram:BasisAmount)"/> &amp;<xsl:value-of select="zf:formatmoney(ram:CalculatedAmount)"/> \\ </xsl:for-each>\hline
Steuersumme &amp; &amp; &amp; &amp; <xsl:value-of select="zf:formatmoney($sums/ram:TaxTotalAmount)"/>
\end{tabular}
}

\newcommand{\sums}{%
\begin{tabular}[b]{@{}lcr@{}}
Nettosumme &amp; &amp; <xsl:value-of select="zf:formatmoney($sums/ram:TaxBasisTotalAmount)"/> \\
Zuschläge &amp; + &amp;<xsl:value-of select="zf:formatmoney($sums/ram:ChargeTotalAmount)"/> \\
Abschläge &amp; -- &amp;<xsl:value-of select="zf:formatmoney($sums/ram:AllowanceTotalAmount)"/> \\
Steuern &amp; &amp;<xsl:value-of select="zf:formatmoney($sums/ram:TaxTotalAmount)"/> \\
Bruttosumme &amp; &amp;<xsl:value-of select="zf:formatmoney($sums/ram:GrandTotalAmount)"/> \\
Anzahlung &amp; &amp;<xsl:value-of select="zf:formatmoney($sums/ram:TotalPrepaidAmount)"/> \\\hline
\textbf{Zahlbetrag} &amp; &amp;\textbf{<xsl:value-of select="zf:formatmoney($sums/ram:DuePayableAmount)"/>} \\
\end{tabular}
}

\date{Rechnungsdatum: <xsl:value-of select="substring($datistr,7,2)"/>.<xsl:value-of select="substring($datistr,5,2)"/>.<xsl:value-of select="substring($datistr,1,4)"/>}

\setkomavar{fromname}{<xsl:value-of select="$seller/ram:Name"/>}
\setkomavar{fromaddress}{<xsl:value-of select="$selleraddr/ram:LineOne"/>\\<xsl:if test="$selleraddr/ram:LineTwo"><xsl:value-of select="$selleraddr/ram:LineTwo"/>\\</xsl:if><xsl:value-of select="$selleraddr/ram:PostcodeCode"/>\ <xsl:value-of select="$selleraddr/ram:CityName"/>}
\setkomavar{fromphone}{(+49177) 8506921}
\setkomavar{fromemail}{helme@hrz.tu-chemnitz.de}
\setkomavar{backaddress}{<xsl:value-of select="$seller/ram:Name"/>, <xsl:value-of select="$selleraddr/ram:LineOne"/>, <xsl:if test="$selleraddr/ram:LineTwo"><xsl:value-of select="$selleraddr/ram:LineTwo"/>, </xsl:if><xsl:value-of select="$selleraddr/ram:PostcodeCode"/>\ <xsl:value-of select="$selleraddr/ram:CityName"/>}
\setkomavar{signature}{<xsl:value-of select="$seller/ram:Name"/>}

\setkomavar{subject}{<xsl:value-of select="$header/ram:Name"/> -- Nr.: <xsl:value-of select="$header/ram:ID"/>}
\begin{document}
\begin{letter}{ <xsl:value-of select="$buyer/ram:Name"/>\\
		<xsl:value-of select="$buyeraddr/ram:LineOne"/>\\
		<xsl:if test="$buyeraddr/ram:LineTwo"><xsl:value-of select="$buyeraddr/ram:LineTwo"/>\\</xsl:if>
		<xsl:value-of select="$buyeraddr/ram:PostcodeCode"/>\ <xsl:value-of select="$buyeraddr/ram:CityName"/>
	}

\opening{Sehr geehrte}



\scalebox{0.7}{
\begin{tabularx}{\textwidth/\real{0.7}}{@{}X@{}}
\itemtable
\end{tabularx}
}
\\
\noindent
\scalebox{0.7}{
\begin{tabularx}{\textwidth/\real{0.7}}{@{}lXr@{}}
\taxsum &amp; &amp; \sums
\end{tabularx}
}


\closing{Mit freundlichen Grußen}

\encl{Lieferschein}

\end{letter}
\end{document}

</xsl:template>
</xsl:stylesheet>

