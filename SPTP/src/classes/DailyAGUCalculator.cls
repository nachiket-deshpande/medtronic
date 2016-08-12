global with sharing class DailyAGUCalculator implements Schedulable {
	public transient Date day {get; set;}
	
	global DailyAGUCalculator() {
		this(System.today().addDays(-1));
	}
	
	global DailyAGUCalculator(Date day) {
		this.day = day;
	}

	global void execute(SchedulableContext ctx) {
		if (day == null) {
			day = System.today().addDays(-1);
		}
		Map<Id,AGU__c> agusByRepId = new Map<Id,AGU__c>();
		countAccounts(agusByRepId);
		countCatheters(agusByRepId);
		upsert agusByRepId.values() Key__c;
	}
	
	private void countAccounts(Map<Id,AGU__c> agusByRepId) {
		List<AggregateResult> results =
			[SELECT AGU_Owner__c, COUNT(Id) 
			 FROM Account 
			 WHERE Date_Activated__c <= :day AND (Date_Deactivated__c = null OR Date_Deactivated__c > :day)
			 GROUP BY AGU_Owner__c];
		
		Set<Id> userIds = new Set<Id>();
		for (AggregateResult ar : results) {
			Id ownerId = (Id)ar.get('AGU_Owner__c');
			userIds.add(ownerId);
		}
		Map<Id,User> usersById = new Map<Id,User>([SELECT IsActive FROM User WHERE Id IN :userIds]);
		
		for (AggregateResult ar : results) {
			Id ownerId = (Id)ar.get('AGU_Owner__c');
			Id salesRepId = ownerId;
			if (!usersById.containsKey(ownerId) || !usersById.get(ownerId).IsActive) {
				ownerId = UserInfo.getUserId();
			}
			
			AGU__c agu = agusByRepId.get(ownerId);
			if (agu == null) {
				agu = new AGU__c(OwnerId=ownerId,Sales_Rep__c=ownerId,Date__c=day);
				agu.Key__c = createKey(salesRepId,day);
				agusByRepId.put(agu.OwnerId,agu);
			}
			agu.Generator_Accounts__c = (Integer)ar.get('expr0');
		}
	}
	
	private void countCatheters(Map<Id,AGU__c> agusByRepId) {
		List<AggregateResult> results =
			[SELECT Invoice__r.BillTo__r.AGU_Owner__c, SUM(Actual_Quantity__c) 
			 FROM InvoiceLine__c 
			 WHERE Invoice__r.InvoiceDate__c = :day AND Product__c != null AND Product__r.Commissionable__c = true AND
			 	((HALO_360_Catheter__c = 'Yes') OR (HALO_90_Catheter__c = 'Yes')) AND (ExtendedPrice__c != 0) AND
			 	(Line_Type__c != 'M') AND (Invoice__r.BillTo__c != null)
			 GROUP BY Invoice__r.BillTo__r.AGU_Owner__c];
		
		Set<Id> userIds = new Set<Id>();
		for (AggregateResult ar : results) {
			Id ownerId = (Id)ar.get('AGU_Owner__c');
			userIds.add(ownerId);
		}
		Map<Id,User> usersById = new Map<Id,User>([SELECT IsActive FROM User WHERE Id IN :userIds]);
		
		for (AggregateResult ar : results) {
			Id ownerId = (Id)ar.get('AGU_Owner__c');
			Id salesRepId = ownerId;
			if (!usersById.containsKey(ownerId) || !usersById.get(ownerId).IsActive) {
				ownerId = UserInfo.getUserId();
			}
			AGU__c agu = agusByRepId.get(ownerId);
			if (agu == null) {
				agu = new AGU__c(OwnerId=ownerId,Sales_Rep__c=ownerId,Date__c=day);
				agu.Key__c = createKey(salesRepId,day);
				agusByRepId.put(agu.OwnerId,agu);
			}
			agu.Catheters_Sold__c = (Double)ar.get('expr0');
		}
	}
	
	private String createKey(Id ownerId, Date day) {
		return ownerId + '_' + day;
	}
}