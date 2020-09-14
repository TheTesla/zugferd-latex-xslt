<?xml version="1.0" encoding="utf8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rsm="urn:ferd:CrossIndustryDocument:invoice:1p0" xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:12" xmlns:udt="urn:un:unece:uncefact:data:standard:UnqualifiedDataType:15" >

<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>


<xsl:variable name="seller" select="/rsm:CrossIndustryDocument/rsm:SpecifiedSupplyChainTradeTransaction/ram:ApplicableSupplyChainTradeAgreement/ram:SellerTradeParty"/>
<xsl:variable name="selleraddr" select="$seller/ram:PostalTradeAddress"/>
<xsl:variable name="buyer" select="/rsm:CrossIndustryDocument/rsm:SpecifiedSupplyChainTradeTransaction/ram:ApplicableSupplyChainTradeAgreement/ram:BuyerTradeParty"/>
<xsl:variable name="buyeraddr" select="$buyer/ram:PostalTradeAddress"/>
<xsl:variable name="header" select="/rsm:CrossIndustryDocument/rsm:HeaderExchangedDocument"/>
<xsl:variable name="datistr" select="$header/ram:IssueDateTime/udt:DateTimeString"/>
<xsl:variable name="payacc" select="/rsm:CrossIndustryDocument/rsm:SpecifiedSupplyChainTradeTransaction/ram:ApplicableSupplyChainTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans"/>
<xsl:variable name="positions" select="/rsm:CrossIndustryDocument/rsm:SpecifiedSupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem"/>

<xsl:template match="/">


\documentclass{scrlttr2}		
\KOMAoptions{}

\usepackage[ngerman]{babel}
\usepackage[T1]{fontenc}
\usepackage[utf8]{inputenc}
\usepackage{lmodern} %Type1-Schriftart für nicht-englische Texte


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


\begin{tabular}{llllll}
  Nr. &amp; Bezeichnung &amp; Umsatzsteuer &amp; Menge &amp; Einzelpreis &amp; Gesamtpreis
  <xsl:for-each select="$positions"> \\<xsl:value-of select="ram:AssociatedDocumentLineDocument/ram:LineID"/>&amp;<xsl:value-of select="ram:SpecifiedTradeProduct/ram:Name"/> &amp;<xsl:value-of select="ram:SpecifiedSupplyChainTradeSettlement/ram:ApplicableTradeTax/ram:ApplicablePercent"/>\% &amp; <xsl:value-of select="ram:SpecifiedSupplyChainTradeDelivery/ram:BilledQuantity"/> &amp; <xsl:value-of select="ram:SpecifiedSupplyChainTradeAgreement/ram:GrossPriceProductTradePrice/ram:ChargeAmount"/> &amp; <xsl:value-of select="ram:SpecifiedSupplyChainTradeSettlement/ram:SpecifiedTradeSettlementMonetarySummation/ram:LineTotalAmount"/>
  </xsl:for-each>
\end{tabular}




\begin{tabular}{lll}
  Bank &amp; BIC &amp; IBAN
  <xsl:for-each select="$payacc">
	\\  <xsl:value-of select="ram:PayeeSpecifiedCreditorFinancialInstitution/ram:Name"/> &amp;  <xsl:value-of select="ram:PayeeSpecifiedCreditorFinancialInstitution/ram:BICID"/> &amp;  <xsl:value-of select="ram:PayeePartyCreditorFinancialAccount/ram:IBANID"/>	
  </xsl:for-each>
\end{tabular}



\closing{Mit freundlichen Grußen}

\encl{Lieferschein}

\end{letter}
\end{document}

</xsl:template>
</xsl:stylesheet>

