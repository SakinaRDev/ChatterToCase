@isTest
public class DynamicAuthProviderTest {
    @isTest
    static void testDynamicAuthProvider() {
        // Create a mock HTTP response
        String mockResponse = '{"id": "mockAuthProviderId"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        // Enqueue the test method
        Test.startTest();
        DynamicAuthProvider.authProviderCred();
        Test.stopTest();

  

    }

    // Inner class to generate a mock HTTP response
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private String mockResponse;

        public MockHttpResponseGenerator(String mockResponse) {
            this.mockResponse = mockResponse;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody(mockResponse);
            res.setStatusCode(200);
            return res;
        }
    }

}