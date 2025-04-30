/*--------------------------------------------------------------------------------------------------------------------------
* Author: Lil Hearts
* Description: This class is responsible for calling the Google Cloud's Vision API for TEXT DETECTION
* Input: String
* Return Type: String
* Created Date: 29-04-2025
* -------------------------------------------------------------------------------------------------------------------------- */
public without sharing class CallVisionAPI {
    //This method is responsible for calling the Google Cloud's Vision API for TEXT DETECTION
    public static String visionMethod(String baseString64)
    {	String base64Image = baseString64;
        String endpoint = 'https://vision.googleapis.com/v1/images:annotate';
        String requestBody = '{"requests":[{"image":{"content":"' + base64Image + '"},"features":[{"type":"TEXT_DETECTION","maxResults":5}]}]}';

        // Create HTTP request using Named Credentials
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://vision.googleapis.com/v1/images:annotate'); // Try to migrate the endpoint to Named credential
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
     	req.setHeader('x-api-key','');
     	req.setHeader('Authorization','Bearer ya29.');
        req.setBody(requestBody);

        // Send the request
        Http http = new Http();
        HttpResponse res = http.send(req);

        // Handle the response
        if (res.getStatusCode() == 200) {
             // Return the response from Vision API
            String description = '';
            JSONParser parser = JSON.createParser(res.getBody());
            System.debug('parser: ' + parser);
            while(parser.nextToken() != null) {
                System.debug('nextToken: ' + parser.nextToken());
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String fieldName = parser.getText();
                System.debug('fieldName: ' + fieldName);
                	if (fieldName == 'description') {
                    	parser.nextToken(); // Move to the value
                    	description = parser.getText();
                    	System.debug('Description: ' + description);
                    	break;
                	}                      
        		}
            }    
            return description;
        } else {
            // Log and return error if API call fails
            system.debug( 'Error: ' + res.getStatusCode() + ' - ' + res.getBody());
            return 'No Medicines Found!';
        }
    }
}