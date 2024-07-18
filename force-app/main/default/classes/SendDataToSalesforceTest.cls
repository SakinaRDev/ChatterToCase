@isTest
private class SendDataToSalesforceTest {
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('mesage');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testMethod1() {
        Case caseRec = new Case();
        caseRec.Status='New';
        caseRec.Origin='other';
        insert caseRec;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Version
        List<ContentVersion> cversionList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        System.assertEquals(cversionList.size(), 1);
        
        //Get Content Documents
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assertEquals(cdList.size(), 1);
                
        List<String> feedItemsJson = new List<String>();

         FeedItem feedItem = new FeedItem();
        feedItem.ParentId = caseRec.Id;
        feedItem.Body = '<p>xzczc<img src="sfdc://'+ cdList[0].Id +'\" alt='+ cv.Title +'\"></img></p>';
         feedItem.Type = 'TextPost'; 
         insert feedItem;
         String jsonBody = JSON.serialize(feedItem);
        
        Resonant_Support_Request__c RSRRec= new Resonant_Support_Request__c();
        RSRRec.Requirement_Name__c='Test123';
        RSRRec.Status__c='In Progress';
        insert RSRRec;
        
        String RSRJson = JSON.serialize(RSRRec);

        feedItemsJson.add(jsonBody);
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Call the method being tested
        Test.startTest();
        SendDataToSalesforce.createCaseRec(RSRJson);
        SendDataToSalesforce.filterRecord(feedItemsJson);
        Test.stopTest();
    }
}