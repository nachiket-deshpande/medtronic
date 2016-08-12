trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert) {
	List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
	List<Id> pricebookEntryIds = new List<Id>();
	
	for( OpportunityLineItem lineItem : Trigger.new ) {
		if( lineItem.PricebookEntryId == null ) {
			continue;	
		}
		
		lineItems.add(lineItem);
		
		pricebookEntryIds.add( lineItem.PricebookEntryId );
	}
		
	if( lineItems.size() == 0 ) {
		return;
	}
	
	Map<Id,PricebookEntry> pricebookEntries = new Map<Id,PricebookEntry>( [SELECT Id, Product2.Description from PricebookEntry where Id IN :pricebookEntryIds] );
	
	for( OpportunityLineItem lineItem : lineItems ) {
		PricebookEntry pricebookEntry = pricebookEntries.get( lineItem.PricebookEntryId );
		
		lineItem.Description = pricebookEntry.Product2.Description;
	}
}