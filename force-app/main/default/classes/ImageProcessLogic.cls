/*--------------------------------------------------------------------------------------------------------------------------
* Author: Lil Hearts
* Description: This class gets the id of medical prescription record to get the attached image's content version data and 
* 			   Convert it into base64 string and passes it to CallvisionaAPI class and gets the return string (descripton).
* Input: List of Ids 
* Return Type: List of Strings
* Created Date: 29-04-2025
* -------------------------------------------------------------------------------------------------------------------------- */
public without sharing class ImageProcessLogic {
//Declare a medical prescription id static var
    private static Id medicalPrescriptionId;
    
    //Gets the Id and convert it to Base64 String 
    @InvocableMethod(label='Image Processing via API' description='Responsible for fetching the record and calling the Vision API')
    public static List<String> getImageInfo(List<Id> ids) {
        
        Medical_Prescription__c mp = [Select id,ContentVersionLink__c from Medical_Prescription__c where id =: ids[0] LIMIT 1];
        
        //Callout to Update ContentDocumentLink
        calloutToUpdate(mp.ContentVersionLink__c);
        
        medicalPrescriptionId = ids[0];
        ContentVersion cv = [Select VersionData from ContentVersion where FirstPublishLocationId =: ids[0] LIMIT 1];
        getBase64(cv.VersionData);
        
        List<String> returnList = new List<String>{'No Return'};
        return returnList;
    }
    
    //Convertion of base string happens here and the CallVisionAPI class gets called by passing the value.
    public static void getBase64(Blob imageFile)
    {   try {
        String image64String = EncodingUtil.base64Encode(imageFile);
        
        //call Vision Api Class
        String descriptionFromImage = CallVisionAPI.visionMethod(image64String);
        
        if(descriptionFromImage != 'No Medicines Found!'){
            //call Medical Prescription Products method
            createMedicalPrescriptionProd(descriptionFromImage);
        }
    }
     catch (Exception ex) {
         System.debug('Image conversion failed ' + ex.getMessage());
     }  
    }
    
    //Updates the description on Medical Prescription record for internal reference.
    public static void updateDescriptionOnMedicalPres(String productsString)
    {
        Medical_Prescription__c mp = [Select id, Detected_Text__c from Medical_Prescription__c where id =: medicalPrescriptionId LIMIT 1];
        mp.Detected_Text__c = productsString;
        update mp;
    }
    
    // This method created the child objects for medical prescription record by using the product names of the returned description
    public static void createMedicalPrescriptionProd(String productsString)
    {
        String description = productsString;
        String finalDescription = '';
        List<String> medicineLst = (description.substring(description.indexOf('LH'))).split('\n');
        Map<String,String> medicinesWithQty = new Map<String,String>();
        for(String s: medicineLst)
        {	
            if(s.startsWith('LH'))
            {	
                List<String> temp = new List<String>();
                temp.addAll(s.substring(3).split('-'));
                finalDescription += temp[0] + ' Quantity:' + temp[1].right(1) +' ' + ';';
                medicinesWithQty.put(temp[0],temp[1].right(1));
            }
        }
        //update medical prescripton record
        updateDescriptionOnMedicalPres(finalDescription);
        
        List<Medicine_Product__c> mps = new List<Medicine_Product__c>();
        for(Medicine__c m: [Select id,Name,Price__c from Medicine__c where Name =: medicinesWithQty.keyset()])
        {
            Medicine_Product__c mp = new Medicine_Product__c();
            mp.Medicine__c = m.Id;
            mp.Medical_Prescription__c = medicalPrescriptionId;
            mp.Quantity__c = Decimal.valueOf(medicinesWithQty.get(m.Name));
            mp.Total_Price__c = m.Price__c * Decimal.valueOf(medicinesWithQty.get(m.Name));
            mps.add(mp);
            system.debug(medicalPrescriptionId);
        }
        try
        {
            if(!mps.isEmpty())
            {
                insert mps;
            }
        }
        catch (Exception ex)
        {
            System.debug('Error Occured: ' + ex.getMessage());
        }
    }
    
    //Sends a callout to share the content with agentforce user
    public static void calloutToUpdate(Id docId)
    {
        String accessToken = getToken();
        String endpoint = '/services/data/v60.0/sobjects/ContentDocumentLink';
        String userid = '005dL00000HmemyQAB';
        String documentId = (String) docId;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(URL.getOrgDomainURL().toExternalForm() + endpoint);
        request.setMethod('POST');
        request.setHeader('Content-type','application/json');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        Map<String,String> bodyMap = new Map<String,String>{
            'contentDocumentId' => docId,
                'linkedEntityId' => userId,
                'shareType' => 'C',
                'visibility' => 'AllUsers'
                };
                    String requestBody = json.serialize(bodyMap);
        request.setBody(requestBody);
        
        try {
            HttpResponse response = http.send(request);
            system.debug(response.getStatusCode() + response.getStatus());
            
        } catch (Exception e) {
            system.debug(e.getMessage());
        }
        
    }
    
    //Generates the access token and returns it to the method
    public static String getToken()
    {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://login.salesforce.com/services/oauth2/token'); //label
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        String clientId = '3MVG9VTfpJmxg1yjuQd.QmGXMJTs63kDuEY6um0XjPKBArVB9XdUbLUMr3qH8OvANmWmFc3wo7NH2xEbG27zr';
        String clientSecret = '34A79993AC5F6927585A26DD5A4B6E1FFF9E7EC1E070953A4FB7DFC9968A5E21';
        String username = 'vishwa01@infosys.com58';
        String password = 'Vishwa123'; //if you see this, forget this.
        
        String body = 'grant_type=password' +
            '&client_id=' + clientId +
            '&client_secret=' + clientSecret +
            '&username=' + username +
            '&password=' + password;
        
        req.setBody(body);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            // Parse the response to get the access token
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) results.get('access_token');
        } else {
            // Handle the error
            throw new CalloutException('Failed to obtain access token: ' + res.getBody());
        }
    }
}