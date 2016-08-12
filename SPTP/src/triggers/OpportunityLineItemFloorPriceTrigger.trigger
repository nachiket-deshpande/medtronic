trigger OpportunityLineItemFloorPriceTrigger on OpportunityLineItem (before insert, before update) {

    List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
    List<Id> pricebookEntryIds = new List<Id>();
    date d = system.today().adddays(-365);
    
    Map<id,opportunity> opps = new map<id,opportunity>();
    for(opportunitylineitem oli:trigger.new) {
    opps.put(oli.opportunityid,null);
    }
    opps.putall([select id,CloseDate from opportunity where id in :opps.keyset()]);

    for( OpportunityLineItem lineItem : Trigger.new ) {
        if( lineItem.PricebookEntryId == null ) {
            continue;   
        }
        if (opps.get(lineitem.opportunityid).CloseDate >d){
        lineItems.add(lineItem);
        pricebookEntryIds.add( lineItem.PricebookEntryId );
        }    
    }
    if( lineItems.size() == 0 ) {
        return;
    }
  
    Map<Id,PricebookEntry> pricebookEntries = new Map<Id,PricebookEntry>( [SELECT Id, Product2.Floor_Price__c, Product2.ProductCode, pricebookEntry.Pricebook2ID from PricebookEntry where Id IN :pricebookEntryIds] );

 //  for( OpportunityLineItem lineItem : lineItems ) {
  for (integer i=0; i < lineItems.size(); i++)  {
        PricebookEntry pricebookEntry = pricebookEntries.get( lineItems[i].PricebookEntryId );
 
    if (( pricebookEntry.Product2.Floor_Price__c  > 0) && (lineItems[i].UnitPrice < pricebookEntry.Product2.Floor_Price__c )) 
    {
     trigger.new[i].UnitPrice.addError('Sorry! ' + pricebookEntry.Product2.ProductCode +' product sales price cannot dip below $'+ pricebookEntry.Product2.Floor_Price__c +'.');
    }
   }
 }