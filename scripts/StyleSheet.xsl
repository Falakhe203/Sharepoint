<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" >
<xsl:output method="text" omit-xml-declaration="yes" indent="no"/>
<xsl:template match="/">Reporting_Date|GL_Account|Cost_Centre|Recon_Amount|Comment|Username|Date_Created
<xsl:for-each select="//properties">
<xsl:value-of select="concat(Reporting_x0020_Date,'|',GL_x0020_Account,'|',Cost_x0020_Centre,'|',Recon_x0020_Amount,'|',Comment,'|',Username,'|',Date_x0020_Created,'&#xA;')"/>
</xsl:for-each>
</xsl:template>
</xsl:stylesheet>
