trigger ResonantSupportRequestTrigger on Resonant_Support_Request__c (after insert, after update) {
     if (Trigger.isAfter) {
            ResonantSupportRequestHandler.onAfter(Trigger.new);
    }
}