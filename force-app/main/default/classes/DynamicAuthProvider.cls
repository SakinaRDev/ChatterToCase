global  class DynamicAuthProvider {

     // Define the AuthProvider class
        global class CreateAuthProvider {
            public String ProviderType='Salesforce';
            public String FriendlyName='OrgSyncProvider';
            public String DeveloperName='OrgSyncProvider';
            public String ConsumerKey='3MVG9ZL0ppGP5UrCXsQJe7vL5Rs5rRPkq8Gb3wAonaTmiNZ8F__y1B5Y6mjx2I4qQAShP6MCD_YM_1K.6gCy7';
            public String ConsumerSecret='055BB8ACC5E2C3B4EC66C1178C5935D4BF6127BC9FBC20EF854017D1BD2AD1BD';
            public String AuthorizeUrl = 'https://login.salesforce.com/services/oauth2/authorize';
            public String TokenUrl = 'https://login.salesforce.com/services/oauth2/token';
            public String DefaultScopes='refresh_token full';
            public Boolean OptionsSendAccessTokenInHeader=true;
            public Boolean OptionsSendSecretInApis=true;
            public Boolean OptionsIsPkceEnabled=true;
        }
        
        // Method to create AuthProvider
        global static void  authProviderCred() {

            HttpRequest req = new HttpRequest();
			req.setHeader('Authorization', 'Bearer '+UserInfo.getSessionId());
			req.setHeader('Content-Type', 'application/json');
			req.setEndpoint(Url.getOrgDomainUrl().toExternalForm()+'/services/data/v60.0/sobjects/AuthProvider');
			req.setMethod('POST');
			//req.setBody(JSON.serialize(authProvider));
            req.setBody(JSON.serialize(new CreateAuthProvider()));
			HttpResponse res = new Http().send(req);
            system.debug(res);
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                // Deserialize the JSON response into a map
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                
                // Access the "id" field from the response
                String authProviderId = (String) responseMap.get('id');
                
               // Use the authProviderId as needed
               System.debug('Auth Provider ID: ' + authProviderId);
               if(!Test.isRunningTest()){
                	NamedCredentialRecipes.createNamedCredential(new connectApiWrapper(),'OrgSyncProvider');                
               }
            } else {
                // Handle error response
                System.debug('Error: HTTP request failed with status code ' + res.getBody());
        
            }
        }
        
    

}