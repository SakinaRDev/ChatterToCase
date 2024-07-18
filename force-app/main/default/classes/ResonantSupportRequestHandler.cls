public class ResonantSupportRequestHandler {
    
    public static void onAfter(List<Resonant_Support_Request__c> newRSRList){
   
         SendDataToSalesforce.getRSRData(JSON.serialize(newRSRList));
        
    }

}