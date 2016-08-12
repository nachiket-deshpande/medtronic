trigger ProductTrigger on Product2 (before update) {
/* trigger disabled 8/11/16 to allow product updates for CPQ
 * 
 * 	List<Product2> products = new List<Product2>();
	
	for( Product2 product : Trigger.new ) {
		if( product.Description == Trigger.oldMap.get(product.Id).Description ) {
			continue;	
		}
		
		products.add(product);
	}
	
	if( products.size() == 0 ) {
		return;
	}
	
	List<PricebookEntry> entries = [SELECT Id, Product2Id from PricebookEntry where Product2Id IN :products];
	
	Map<Id,PricebookEntry> entriesMap = new Map<Id,PricebookEntry>();
	for( PricebookEntry entry : entries ) {
		entriesMap.put(entry.Product2Id, entry);
	}
	date d = system.today().addDays(-365);
	List<OpportunityLineItem> lineItems = [SELECT Id, Description, PricebookEntryId from OpportunityLineItem where PricebookEntryId IN :entries and OpportunityLineItem.opportunity.CloseDate >:d];
	
	Map<Id,OpportunityLineItem> lineItemsMap = new Map<Id,OpportunityLineItem>();
	for( OpportunityLineItem lineItem : lineItems ) {
		lineItemsMap.put(lineItem.PricebookEntryId, lineItem);
	}
	
	for( Product2 product : products ) {
		PricebookEntry entry = entriesMap.get( product.Id );
		if( entry == null ) {
			continue;
		}
		
		OpportunityLineItem lineItem = lineItemsMap.get( entry.Id );
		if( lineItem == null ) {
			continue;
		}
		
		lineItem.Description = product.Description;
	}
	
	update lineItems;

*/
}