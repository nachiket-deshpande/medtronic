public with sharing class CalculateDailyAGUController {
	public AGU__c startTemplate {get; set;}
	public AGU__c endTemplate {get; set;}
	
	public CalculateDailyAGUController(ApexPages.StandardSetController controller) {
		startTemplate = new AGU__c();
		endTemplate = new AGU__c();
	}
	
	public PageReference onCalculate() {
		Integer days = startTemplate.Date__c.daysBetween(endTemplate.Date__c);
		if (days > 60) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You can recalculate AGU for at most 60 days'));
			return null;
		}
		
		System.Savepoint sp = Database.setSavePoint();
		try {
			DailyAGUCalculator calc = new dailyAGUCalculator();
			for (Date day=startTemplate.Date__c;day<=endTemplate.Date__c;day=day.addDays(1)) {
				calc.day = day;
				calc.execute(null);
			}
		} catch (Exception e) {
			ApexPages.addMessages(e);
			Database.rollback(sp);
		}
		
		return new PageReference('/' + AGU__c.sObjectType.getDescribe().getKeyPrefix());
	}
}