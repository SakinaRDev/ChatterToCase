public class FeedItemHandler {
    public static void handleFeedItems(List<FeedItem> newFeedItems) {
        // Collect CreatedById values
        Set<Id> createdByIds = new Set<Id>();
        for (FeedItem post : newFeedItems) {
            createdByIds.add(post.CreatedById);
        }

        // Query to get User Names for CreatedById
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN :createdByIds]);

        // Prepare the data with CreatedBy names
        List<Map<String, Object>> postDataList = new List<Map<String, Object>>();
        for (FeedItem post : newFeedItems) {
            if (post.ParentId.getSObjectType() == Resonant_Support_Request__c.sObjectType) {
                Map<String, Object> feedItemData = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(post));
                
                // Add CreatedByName to the data
                if (userMap.containsKey(post.CreatedById)) {
                    feedItemData.put('CreatedByName', userMap.get(post.CreatedById).Name);
                }

                postDataList.add(feedItemData);
            }
        }

        // Serialize the list back to JSON
        List<String> jsonStringList = new List<String>();
        for (Map<String, Object> feedItemData : postDataList) {
            jsonStringList.add(JSON.serialize(feedItemData));
        }

        // Call the method to process the data
        if (!jsonStringList.isEmpty()) {
            SendDataToSalesforce.filterRecord(jsonStringList);
        }
    }
}