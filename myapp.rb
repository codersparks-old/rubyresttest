require 'sinatra'
require 'json'
require 'rexml/document'
include REXML

set :bind, '0.0.0.0'

class ValidationResult
   attr_accessor :result, :errors

   def to_s
        s = "{ \"result\":" + result.to_s + ", \"errors\":" + errors.to_json + "}"
        return s
   end
end

get '/' do
    'Hello world!'
end

post '/xml/v1/xpathValidate' do

   jsonString = request.body

   request.body.rewind

   data = JSON.parse request.body.read

   retstring = ""

   xmlString = data['xml']
   xmlDoc = Document.new(xmlString)

   testPass = true
   errors = Array.new

   # Validation should be { "xpath": "<xpath>", "value": "<value>" }
   validations = data['validations']
   
   if validations != nil && validations.size > 0 then

        for validation in validations
            #retstring += validation.to_s
            puts validation
            xpath = validation['xpath']
            expectedValue = validation['value']

            values = XPath.match(xmlDoc, xpath)

            if values != nil && values.size > 0 then

                for value in values
                   value_s = value.to_s
                   if value_s != expectedValue then
                       testPass = false                       
                       errorString = "Fail on  xpath: " + xpath + " Value: " + value_s + " Expected: " + expectedValue.to_s
                       errors.insert(-1, errorString)
                   end
                end
            end
        end

   end

   retobject = ValidationResult.new
   retobject.result = testPass

   if testPass then
        status 200
   else
        retobject.errors = errors
        status 500
   end
   retString = retobject.to_s
   body retString
end
