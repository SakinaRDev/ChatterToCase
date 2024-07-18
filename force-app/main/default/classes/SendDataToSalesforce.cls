public class SendDataToSalesforce {
    public static void filterRecord(List<String> postDataList){ 
         List<String> contentDocumentIds = new List<String>();
 
         for (String jsonString : postDataList) {
             // Parse JSON
             Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
             // Access ContentDocumentId
             String contentDocumentUrl = (String) parsedJson.get('Body');
 
             if(contentDocumentUrl != null && contentDocumentUrl.contains('"sfdc://')) {
                 String[] parts = contentDocumentUrl.split('"sfdc://');
                         
                 for (Integer i = 1; i < parts.size(); i++) {
                     String contentDocumentId = parts[i].substring(0, 18); // Assuming ContentDocumentId is always 18 characters
                     contentDocumentIds.add(contentDocumentId);
                 }
             }
         }
         List<ContentVersion> contentVersions = [SELECT Id,ContentDocumentId, VersionData,FileExtension, Title FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds];
        // Create a map to store replacement strings for each ContentVersion
         Map<String, String> replacementMap = new Map<String, String>();
         for (ContentVersion cv : contentVersions) {
             String replacement = '<img src="sfdc://' + cv.ContentDocumentId + '" alt="' + cv.Title + '"></img>';
             replacementMap.put(cv.ContentDocumentId, replacement);
         }
         List<String> jsonStringList = new List<String>();
         for (String jsonString : postDataList) {
             Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
             String feedItemBody = (String) parsedJson.get('Body');
             List<Map<String, String>> imageMapList= new List<Map<String, String>>();
             // Replace all occurrences of <img> tags with appropriate ContentVersion data
             for (String contentDocumentId : contentDocumentIds) {
                 if (feedItemBody.contains('"sfdc://' + contentDocumentId)) {
                     feedItemBody = feedItemBody.replace(replacementMap.get(contentDocumentId), '');
                     parsedJson.put('Body', feedItemBody);
                     imageMapList.add(getImageContentMap(contentVersions, contentDocumentId));
                 }
             }
             parsedJson.put('ImageContent', imageMapList);
             jsonStringList.add(JSON.serialize(parsedJson));
         }
 
         // Call the method to create records in the target org
         createRecordTargetOrg(jsonStringList);
 
    }
 
     
   public static Map<String, String> getImageContentMap(List<ContentVersion> contentVersions, String contentDocumentId) {
     for (ContentVersion cv : contentVersions) {
         if (cv.ContentDocumentId == contentDocumentId) {
             return new Map<String, String>{
                 'Title' => cv.Title + '.' + cv.FileExtension,
                 'VersionData' => EncodingUtil.base64Encode(cv.VersionData),
                 'FileExtension' => cv.FileExtension
             };
         }
     }
 
     return null;
 }
 
 
 
     @future(callout=true)
     public static void createRecordTargetOrg(List<String> postDataList){
         
         HttpRequest req = new HttpRequest();
         req.setEndpoint('callout:R_SC__SalesforceOAuth/services/apexrest/resonantsupport/feedItems');
         req.setHeader('Content-Type', 'application/json; charset=UTF-8');
         req.setHeader('Accept', 'application/json');
         String requestBody = '[' + String.join(postDataList, ',') + ']';
         req.setBody(requestBody);
         
         req.setMethod('POST');
         Http http = new Http();
         HttpResponse response = http.send(req);
     System.debug('response code:' + response.getStatusCode());
         System.debug('response body : ' + response.getBody());
         if (response.getStatusCode() != 200) {
             System.debug('Error: ' + response.getStatus() + ' - ' + response.getBody());
             // Handle error accordingly
         } else {
             // Case created successfully in the destination org
             System.debug('Case created successfully in the destination org.');
         }
     }
     
   
    public static void createCaseRec(String jsonString){  
             HttpRequest req = new HttpRequest();
             req.setEndpoint('callout:R_SC__SalesforceOAuth/services/apexrest/resonantsupport/cases');
             req.setHeader('content-type','application/json; charset=UTF-8');
             req.setHeader('Accept', 'application/json');
             req.setBody(jsonString);
             req.setMethod('POST');
             Http http = new Http();
             HttpResponse response = http.send(req);
             System.debug('response code:'+response.getStatusCode());
             System.debug('response body : '+response.getBody());
              if (response.getStatusCode() != 200 || response.getStatusCode() != 201) {
                 System.debug('Error: ' + response.getStatus() + ' - ' + response.getBody());
                 // Handle error accordingly
             } else {
                 // Case created successfully in the destination org
                 System.debug('Case created successfully in the destination org.');
             }
             
         
         
     }
    
    
    @future(callout=true)
    public static void getRSRData(String jsonString) {
        // fetch accountId from custom setting
        R_SC__Resonant_Cloud_Details__c RCSDetails = R_SC__Resonant_Cloud_Details__c.getInstance();
        List<Resonant_Support_Request__c> RSRDataList = (List<Resonant_Support_Request__c>) JSON.deserialize(jsonString, List<Resonant_Support_Request__c>.class);
        List<Map<String, Object>> rsrDataWithBlob = new List<Map<String, Object>>();

        if (RCSDetails.getSObjectType().getDescribe().fields.getMap().containsKey('R_SC__AccountId__c')) {
            String caseAccountId = (String)RCSDetails.get('R_SC__AccountId__c');
    
            if (!RSRDataList.isEmpty()) {
                for (Resonant_Support_Request__c rsrRec : RSRDataList) {
                Map<String, Object> rsrData = new Map<String, Object>();
                    if (rsrRec.Requirement_Description__c != null && rsrRec.Requirement_Description__c.contains('<img')) {
                        String rsrimg = rsrRec.Requirement_Description__c.substringBetween('<img', 'img>');
                        String imgsrc = rsrimg.substringBetween('src="', '"');
                        imgsrc = imgsrc.replace('amp;', '');
                        PageReference page = new PageReference(imgsrc);
                        Blob imgblob = page.getContent();
                        String strBase64 = EncodingUtil.base64Encode(imgblob);
                    
                        // Create a map to hold the data

                        if(strBase64!=null){
                            rsrData.put('Base64Image', strBase64);
                        }
                    }

                    rsrData.put('AccountId', caseAccountId);
                 	rsrData.put('OrgBaseURL',URL.getOrgDomainURL().toExternalForm());
                    // Add any other necessary fields from Resonant_Support_Request__c
                    rsrData.put('RSRObject', rsrRec);

                    // Add the map to the list
                    rsrDataWithBlob.add(rsrData);
                }
            }

            // Convert the list to JSON
            String generatedJSONString = JSON.serialize(rsrDataWithBlob);
            System.debug(generatedJSONString);
            createCaseRec(generatedJSONString);
        }
    }

 
 
 
    
 }