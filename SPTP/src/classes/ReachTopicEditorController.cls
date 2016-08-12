public with sharing class ReachTopicEditorController {
	private Id reachId;
	
	public List<REACH_Topics__c> topics { get; set; }
	
	public ReachTopicEditorController(ApexPages.StandardController controller) { 
		reachId = controller.getId();
		
		topics = [SELECT Id, Date_Topic_Discussed__c, Follow_Up_Notes__c, Interested__c, To_Discuss__c, Topic__c from REACH_Topics__c where REACH__c = :reachId];
	}
	
	public PageReference cancel() {
		PageReference pageRef = new PageReference( '/' + reachId );
        pageRef.setRedirect(true);
        
        return pageRef;
	}
	
	public PageReference save() {
		upsert topics;
		
		PageReference pageRef = new PageReference( '/' + reachId );
        pageRef.setRedirect(true);
        
        return pageRef;
	}
	
	public void add() {
		REACH_Topics__c topic = new REACH_Topics__c(REACH__c = reachId);
		
		topics.add(topic);
	}
}