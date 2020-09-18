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

<func:function name="zf:formatmoney">
  <xsl:param name="x" select="."/>
  <func:result select="translate(format-number(round($x * 100) div 100, '0.00'), '.', ',')" />
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
\begin{tabular}[t]{lcr}
\scalebox{0.7}{\kontakt} &amp; \scalebox{0.7}{\taxid} &amp; \scalebox{0.7}{\bank} \\
\end{tabular} \\
\centerline{Seite \thepage\ von \pageref{LastPage}}
}%

\newcommand{\itemtable}{%
\begin{tabular}{lllllll}
\textbf{Pos.} &amp; \textbf{Artikelnummer} &amp; \textbf{Bezeichnung} &amp; \textbf{Umsatzsteuer} &amp; \textbf{Menge} &amp; \textbf{Einzelpreis} &amp; \textbf{Gesamtpreis}
<xsl:for-each select="$positions"> \\<xsl:value-of select="ram:AssociatedDocumentLineDocument/ram:LineID"/>&amp;<xsl:value-of select="ram:SpecifiedTradeProduct/ram:SellerAssignedID"/>&amp;<xsl:value-of select="ram:SpecifiedTradeProduct/ram:Name"/> &amp;<xsl:value-of select="round(ram:SpecifiedSupplyChainTradeSettlement/ram:ApplicableTradeTax/ram:ApplicablePercent)"/>\% &amp; <xsl:value-of select="round(ram:SpecifiedSupplyChainTradeDelivery/ram:BilledQuantity)"/> &amp; <xsl:value-of select="zf:formatmoney(ram:SpecifiedSupplyChainTradeAgreement/ram:NetPriceProductTradePrice/ram:ChargeAmount)"/> &amp; <xsl:value-of select="translate(format-number(round(ram:SpecifiedSupplyChainTradeSettlement/ram:SpecifiedTradeSettlementMonetarySummation/ram:LineTotalAmount * 100) div 100, '0.00'), '.', ',')"/> <xsl:value-of select="ram:SpecifiedSupplyChainTradeSettlement/ram:SpecifiedTradeSettlementMonetarySummation/ram:LineTotalAmount/@currencyID"/>
  </xsl:for-each>
\end{tabular}
}

\newcommand{\taxsum}{%
\begin{tabular}{lll}
\textbf{Steuersatz} &amp; \textbf{Basispreis} &amp; \textbf{Steuern}
<xsl:for-each select="$taxsum">\\<xsl:value-of select="round(ram:ApplicablePercent)"/>&amp;<xsl:value-of select="ram:LineTotalBasisAmount"/>&amp;<xsl:value-of select="translate(format-number(round(ram:CalculatedAmount * 100) div 100, '0.00'), '.', ',')"/></xsl:for-each>
\\\textbf{Steuersumme} &amp; &amp; <xsl:value-of select="$sums/ram:TaxTotalAmount"/>
\end{tabular}
}

\newcommand{\sums}{%
\begin{tabular}{lr}
\textbf{Nettosumme:} &amp; <xsl:value-of select="$sums/ram:TaxBasisTotalAmount"/> \\
\textbf{Zuschläge:} &amp; +<xsl:value-of select="$sums/ram:ChargeTotalAmount"/> \\
\textbf{Abschläge:} &amp; -<xsl:value-of select="$sums/ram:AllowanceTotalAmount"/> \\
\textbf{Steuern:} &amp; <xsl:value-of select="$sums/ram:TaxTotalAmount"/> \\
\textbf{Bruttosumme:} &amp; <xsl:value-of select="$sums/ram:GrandTotalAmount"/> \\
\textbf{Anzahlung:} &amp; <xsl:value-of select="$sums/ram:TotalPrepaidAmount"/> \\
\textbf{Zahlbetrag:} &amp; <xsl:value-of select="$sums/ram:DuePayableAmount"/> \\
\end{tabular}
}

\date{<xsl:value-of select="substring($datistr,7,2)"/>.<xsl:value-of select="substring($datistr,5,2)"/>.<xsl:value-of select="substring($datistr,1,4)"/>}

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




\scalebox{0.7}{\itemtable}
\scalebox{0.7}{\sums}

\scalebox{0.7}{\taxsum}



\closing{Mit freundlichen Grußen}

\encl{Lieferschein}

\end{letter}
\end{document}

</xsl:template>
</xsl:stylesheet>

