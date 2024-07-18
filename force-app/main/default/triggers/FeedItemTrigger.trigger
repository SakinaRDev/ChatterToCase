trigger FeedItemTrigger on FeedItem (after insert) {
    
    if (Trigger.isAfter && Trigger.isInsert) {
            FeedItemHandler.handleFeedItems(Trigger.new);
    }


}