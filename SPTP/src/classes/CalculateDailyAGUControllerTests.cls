/**
 * Unit tests for <code>CalculateDailyAGUController</code>
 * 
 * @author Max Rudman
 * @since 5/8/2011
 */
@isTest
private class CalculateDailyAGUControllerTests {
	testMethod static void testOnCalculate() {
		ApexPages.StandardSetController sc = new ApexPages.StandardSetController(new AGU__c[]{});
		CalculateDailyAGUController target = new CalculateDailyAGUController(sc);
		target.startTemplate.Date__c = System.today();
		target.endTemplate.Date__c = System.today().addDays(2);
		target.onCalculate();
	}
}