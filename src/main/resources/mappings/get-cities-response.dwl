%dw 2.0
output application/json
ns ns0 http://www.webserviceX.NET
var res = payload.body.ns0#GetCitiesByCountryResponse as String
fun replaceEscapedCharacters(stringValue) =
    stringValue replace "&lt;" with "<" replace "&gt;" with ">"
var xmlRes = read(replaceEscapedCharacters(res), "application/xml")

var tempPayload = (xmlRes.NewDataSet.*Table)
    groupBy $.Country
    pluck {
        country: $.Country[0],
        cities: $.City
    }

fun getOutputPayload(tempPayload, country) = (tempPayload filter ((item, index) -> item.country == country))

var outputPayload = getOutputPayload(tempPayload, vars.country)

---
if(tempPayload == null) []
else
	if(vars.country != null)
		if(sizeOf(outputPayload) > 0)
        	outputPayload
    	else 
    		{
    			isError:true,
    			errorDescription: "The specified country does not exist."
    		}
	else tempPayload