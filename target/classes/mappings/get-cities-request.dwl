%dw 2.0
output application/xml
ns ns0 http://www.webserviceX.NET
---
{
	ns0#GetCitiesByCountry: {
		ns0#CountryName: attributes.queryParams.country
	}
}