public with sharing class ChatterUtilities {
    
    public  void postFeedMessageWithMention(String prefixmessage, list<string> ls_mentionUser, String suffixmessage,	String recipient)
    {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        textSegmentInput.text = prefixmessage;
        messageBodyInput.messageSegments.add(textSegmentInput);
        
        for(string userId : ls_mentionUser){  
        ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();  
        mentionSegment.id = userId;  
        messageBodyInput.messageSegments.add(mentionSegment);  
      } 
        //mentionSegmentInput.id = atmention;  // at mention
        //messageBodyInput.messageSegments.add(mentionSegmentInput);
        textSegmentInput.text = suffixmessage;
        messageBodyInput.messageSegments.add(textSegmentInput);
        
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = recipient;  //to whom
        
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput, null);
    }
    
    public  void postFeedMessage(String message, String recipient)
    { 
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), recipient, ConnectApi.FeedElementType.FeedItem, message);  
    }
    
    public  void sendPrivateMessage(String message, String recipient) 
    {
        ConnectApi.ChatterMessages.sendMessage(message, recipient);
    }    
    public  void sendMessageAs(String message, String recipient, String postAs) 
    {
        FeedItem post = new FeedItem();
        post.ParentId = recipient; 
        post.createdById = postAs;
        post.Body = message;
        insert post; 
       
        //FeedItem f = [select InsertedById from FeedItem where id =:post.Id];
	   //System.assertEquals (f.InsertedById, UserInfo.getUserId());
 
        
    } 
}