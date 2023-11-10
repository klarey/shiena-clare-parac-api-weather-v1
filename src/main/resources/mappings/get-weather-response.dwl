%dw 2.0
output application/json

import indexOf from dw::core::Arrays
import substringBefore, substringAfter from dw::core::Strings

ns ns0 http://www.webserviceX.NET
var res = payload.body.ns0#GetWeatherResponse as String
fun replaceEscapedCharacters(stringValue) =
    stringValue replace "&lt;" with "<" replace "&gt;" with ">"
var xmlRes = read(replaceEscapedCharacters(res), "application/xml")

var arrayDataSet = (xmlRes.NewDataSet.*Table)
    groupBy $.Country
    pluck {
        country: $.Country[0],
        weatherDetails: $ map (item,index) ->{
            location: item.Location,
            time: item.Time,
		    wind: item.Wind,
		    visibility: item.Visibility,
		    skyConditions: item.SkyConditions,
		    temperature: item.Temperature,
		    dewPoint: item.DewPoint,
		    relativeHumidity: item.RelativeHumidity,
		    status: item.Status
        }
    }

fun getPayloadWithCountryFilter(payload, country) = (payload filter ((item) -> item.country == country))

// var countryArray = arrayDataSet.country indexOf vars.country
// var cityArray = arrayDataSet.weatherDetails[arrayDataSet.country indexOf vars.country].location indexOf vars.city
// var outputPayloadWithCountryFilter = getPayloadWithCountryFilter(arrayDataSet, vars.country)
 
fun getPayloadWithCityFilter(payload, city) = 
    if((payload.Location indexOf vars.city) != -1)
        [
            {
                country: payload[payload.Location indexOf vars.city].Country,
                weatherDetails: [
                    {
                        location: payload[payload.Location indexOf vars.city].Location,
                        time: payload[payload.Location indexOf vars.city].Time,
		                wind: payload[payload.Location indexOf vars.city].Wind,
		                visibility: payload[payload.Location indexOf vars.city].Visibility,
		                skyConditions: payload[payload.Location indexOf vars.city].SkyConditions,
		                temperature: payload[payload.Location indexOf vars.city].Temperature,
		                dewPoint: payload[payload.Location indexOf vars.city].DewPoint,
		                relativeHumidity: payload[payload.Location indexOf vars.city].RelativeHumidity,
		                status: payload[payload.Location indexOf vars.city].Status
                    }
                ]  
            }
        ]
    else
        []    

// var outputPayloadWithCityFilter = getPayloadWithCityFilter(xmlRes.NewDataSet.*Table, vars.city)

---
if(arrayDataSet == null)  []
else 
	if(vars.country == null and vars.city == null) 
    	arrayDataSet   
	else if(vars.country !=null and vars.city !=null)
		if((arrayDataSet.country indexOf vars.country) != -1)
    		if((arrayDataSet.weatherDetails[arrayDataSet.country indexOf vars.country].location indexOf vars.city) != -1)
        		[
            		{
                		country:arrayDataSet.country[arrayDataSet.country indexOf vars.country],
                		weatherDetails: [arrayDataSet[arrayDataSet.country indexOf vars.country].weatherDetails[arrayDataSet.weatherDetails[arrayDataSet.country indexOf vars.country].location indexOf vars.city]]
            		}
        		]
    		else
        		{
            		// raise error - specified city does not exist in given country
            		isError: true,
            		errorDescription: "The specified city does not exist in the given country."
        		}
    	else
    		// raise error - specified country does not exist
    		{
				isError: true,
            	errorDescription: "The specified country does not exist."
        	}
	else
    	if(vars.country != null)
        	if(sizeOf(getPayloadWithCountryFilter(arrayDataSet, vars.country)) > 0)
            	getPayloadWithCountryFilter(arrayDataSet, vars.country)     
        	else 
            	{
                	// raise error - no country with given name exists
                	isError: true,
                	errorDescription: "The specified country does not exist."
            	}
    	else 
        	if(sizeOf(getPayloadWithCityFilter(xmlRes.NewDataSet.*Table, vars.city)) > 0)
            	getPayloadWithCityFilter(xmlRes.NewDataSet.*Table, vars.city)
        	else
            	{
                	// raise error - no city with given name exists
                	isError: true,
                	errorDescription: "The specified city does not exist."
            	}