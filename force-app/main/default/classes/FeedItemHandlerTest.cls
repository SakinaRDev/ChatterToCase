@isTest
public class FeedItemHandlerTest {

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
    static void testHandleFeedItems() {
        Resonant_Support_Request__c supportRequest = new Resonant_Support_Request__c(); // Assuming Resonant_Support_Request__c is a custom object
		supportRequest.Requirement_Name__c='Test12';
        insert supportRequest;
        
        List<FeedItem> newFeedItems = new List<FeedItem>();
        // Create a Chatter post
        FeedItem chatterPost = new FeedItem();
        chatterPost.Body = 'Test Chatter Post';
        chatterPost.Type = 'TextPost';
        chatterPost.ParentId = supportRequest.Id;
        newFeedItems.add(chatterPost);
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Enqueue the test method
        Test.startTest();
        insert newFeedItems;
        FeedItemHandler.handleFeedItems(newFeedItems);
        Test.stopTest();

        // Verify that the expected action was performed
        // For example, you could assert that the SendDataToSalesforce.createRecordTargetOrg method was called
        // You may also verify other side effects or perform additional assertions based on your requirements
    }
}