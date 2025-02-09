<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
        <!ENTITY ldh        "https://w3id.org/atomgraph/linkeddatahub#">
        <!ENTITY rdf        "http://www.w3.org/1999/02/22-rdf-syntax-ns#">
        <!ENTITY geo        "http://www.w3.org/2003/01/geo/wgs84_pos#">
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
version="3.0"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:json="http://www.w3.org/2005/xpath-functions"
xmlns:ldh="&ldh;"
xmlns:rdf="&rdf;"
xmlns:geo="&geo;"
exclude-result-prefixes="#all"
>

    <xsl:output indent="no" omit-xml-declaration="yes" method="text" encoding="UTF-8" media-type="application/json"/>

    <xsl:mode name="ldh:GeoJSON" on-no-match="deep-skip"/>
    <xsl:mode name="ldh:GeoJSONProperties" on-no-match="deep-skip"/>

    <xsl:template match="/" mode="ldh:GeoJSON">
        <xsl:variable name="json-xml" as="element()">
            <xsl:apply-templates mode="#current"/>
        </xsl:variable>
        <xsl:sequence select="xml-to-json($json-xml)"/>
    </xsl:template>
    
    <xsl:template match="rdf:RDF" mode="ldh:GeoJSON">
        <json:map>
            <json:string key="type">FeatureCollection</json:string>

            <json:array key="features">
                <xsl:apply-templates mode="#current"/>
            </json:array>
        </json:map>
    </xsl:template>

    <xsl:template match="rdf:Description[geo:lat][geo:long]" mode="ldh:GeoJSON">
        <json:map>
            <json:string key="type">Feature</json:string>
            <json:string key="id"><xsl:value-of select="(@rdf:about, @rdf:nodeID)[1]"/></json:string>

            <json:map key="geometry">
                <json:string key="type">Point</json:string>

                <json:array key="coordinates">
                    <json:number><xsl:value-of select="geo:long"/></json:number>
                    <json:number><xsl:value-of select="geo:lat"/></json:number>
                </json:array>
            </json:map>
            
            <json:map key="properties">
                <xsl:apply-templates select="." mode="ldh:GeoJSONProperties"/>
            </json:map>
        </json:map>
    </xsl:template>

    <xsl:template match="rdf:Description" mode="ldh:GeoJSONProperties">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="rdf:Description/*[local-name() = 'label'][1]" mode="ldh:GeoJSONProperties">
        <json:string key="{local-name()}">
            <xsl:value-of select="."/>
        </json:string>
    </xsl:template>
    
</xsl:stylesheet>
