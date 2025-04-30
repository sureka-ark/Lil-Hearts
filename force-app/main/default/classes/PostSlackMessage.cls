/*--------------------------------------------------------------------------------------------------------------------------
* Author: Lil Hearts
* Description: This class Posts the image attached image to the slack channel
* Input: List of Ids 
* Return Type: void
* Created Date: 29-04-2025
* -------------------------------------------------------------------------------------------------------------------------- */
public without sharing class PostSlackMessage {
    @InvocableMethod(label = 'Call Slack API' description = 'To send file as a message to the slack channel')
    //Request to slack  for upload file
    public static void getUploadUrl(List<Id> contentdocumentid) {
        String endpoint = 'https://slack.com/api/files.getUploadURLExternal';
		String contentdoc = contentdocumentid[0];
        
        ContentDocument contentdocRecord = [Select id, ContentSize from ContentDocument where id =:contentdoc LIMIT 1];
        ContentVersion contentVersion = [SELECT Id, Title, VersionData FROM ContentVersion WHERE ContentDocumentId = :contentdoc LIMIT 1];
		String fileBase64 = EncodingUtil.base64Encode(contentVersion.VersionData);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + ''); //sorry :-(
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');


        // Slack API expects the body as form-urlencoded
        String requestBody = 'filename=' + EncodingUtil.urlEncode(contentVersion.Title, 'UTF-8') +
                             '&length=' + contentdocRecord.ContentSize;
        req.setBody(requestBody);


        Http http = new Http();
        HttpResponse res = http.send(req);


        if (res.getStatusCode() == 200) {
            // Parse the response to get the upload URL and file ID
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if ((Boolean) responseMap.get('ok')) {
                String uploadUrl = (String) responseMap.get('upload_url');
                String fileId = (String) responseMap.get('file_id');
                uploadFileToSlack(uploadUrl,fileBase64,contentVersion.Title,fileid);
            } else {
                throw new AuraHandledException('Error: ' + responseMap.get('error'));
            }
        } else {
            throw new AuraHandledException('HTTP Request failed: ' + res.getStatus());
        }
    }
    
    //uploads the image to the slack channel
    public static void uploadFileToSlack(String uploadUrl, String fileBase64, String filename,String fileid) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(uploadUrl);
        req.setMethod('POST');
       
        // Use a unique boundary for each request
        String boundary = '----WebKitFormBoundary' + System.currentTimeMillis();
        req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);


        // Prepare file data
        String headerPart = '--' + boundary + '\r\n' +
                            'Content-Disposition: form-data; name="file"; filename="' + filename + '"\r\n' +
                            'Content-Type: ' + getContentType(filename) + '\r\n\r\n';


        String footerPart = '\r\n--' + boundary + '--';


        // Convert the base64 string to a Blob
        Blob fileBlob = EncodingUtil.base64Decode(fileBase64);
        Blob headerBlob = Blob.valueOf(headerPart);
        Blob footerBlob = Blob.valueOf(footerPart);


        // Combine the parts using hex conversion
        String combinedDataAsHex = EncodingUtil.convertToHex(headerBlob) + EncodingUtil.convertToHex(fileBlob) + EncodingUtil.convertToHex(footerBlob);
        Blob bodyBlob = EncodingUtil.convertFromHex(combinedDataAsHex);


        req.setBodyAsBlob(bodyBlob);


        Http http = new Http();
        HttpResponse res = http.send(req);
		
        if(res.getStatusCode() == 200)
        {
        completeUpload(fileid,'C08HCF8R2RX'); 
        }

        if (res.getStatusCode() != 200) {
            throw new AuraHandledException('Failed to upload file to Slack: ' + res.getStatus() + ' ' + res.getBody());
        }
    }
    
    //complete the uploading process
    public static void completeUpload(String fileId, String selectedChannel) {
        String endpoint = 'https://slack.com/api/files.completeUploadExternal';
		String slackMessage = 'File Attached with the case';
	
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + '');
        req.setHeader('Content-Type', 'application/json');


        // Form the request body as JSON
        Map<String, Object> requestBodyMap = new Map<String, Object>();
        List<Map<String, Object>> filesList = new List<Map<String, Object>>();
        Map<String, Object> fileMap = new Map<String, Object>();
        fileMap.put('id', fileId);
        filesList.add(fileMap);
        requestBodyMap.put('files', filesList);
        requestBodyMap.put('channel_id', selectedChannel);
        requestBodyMap.put('initial_comment', slackMessage);


        // Convert the map to JSON string
        String requestBody = JSON.serialize(requestBodyMap);
        req.setBody(requestBody);


        Http http = new Http();
        HttpResponse res = http.send(req);
		system.debug(res.getBody());

        if (res.getStatusCode() != 200 || !res.getBody().contains('"ok":true')) {
            throw new AuraHandledException('File upload completion failed: ' + res.getStatus());
        }
    }


    private static String getContentType(String filename) {
        String extension = filename.substringAfterLast('.');
        if (extension.equalsIgnoreCase('jpg') || extension.equalsIgnoreCase('jpeg')) {
            return 'image/jpeg';
        } else if (extension.equalsIgnoreCase('png')) {
            return 'image/png';
        } else if (extension.equalsIgnoreCase('gif')) {
            return 'image/gif';
        } else if (extension.equalsIgnoreCase('bmp')) {
            return 'image/bmp';
        } else {
            return 'application/octet-stream';
        }
    }
    

}