@isTest
public class ResonantSupportRequestHandlerTest { 
    
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
    static void testOnAfterInsert(){
        List<Resonant_Support_Request__c> RSRList= new List<Resonant_Support_Request__c>();
        
        Resonant_Support_Request__c supportRequest1 = new Resonant_Support_Request__c(); 
		supportRequest1.Requirement_Name__c='Test12';
        RSRList.add(supportRequest1);
        
        Resonant_Support_Request__c supportRequest2 = new Resonant_Support_Request__c(); 
		supportRequest2.Requirement_Name__c='Dummy test data';
        RSRList.add(supportRequest2);

        insert RSRList;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        	ResonantSupportRequestHandler.onAfter(RSRList);
        Test.stopTest();
        
    }
    

}