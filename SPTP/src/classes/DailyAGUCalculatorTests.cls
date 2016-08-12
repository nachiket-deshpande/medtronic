/**
 * Test suite for <code>DailyAGUCalculator</code>
 * 
 * @author Max Rudman
 * @since 2/14/2011
 */
@isTest(SeeAllData=false)
private class DailyAGUCalculatorTests {
	private static List<Account> customers;
	private static Date day = Date.newInstance(2012,1,1);
	
	testMethod static void testExecute() {
		DateTime start = System.now();
		
		setUp();
		
		DailyAGUCalculator target = new DailyAGUCalculator(day);
		target.execute(null);
		
		AGU__c agu = [SELECT Generator_Accounts__c, Catheters_Sold__c FROM AGU__c WHERE OwnerId = :UserInfo.getUserId() AND CreatedDate >= :start];
		System.assertEquals(1, agu.Generator_Accounts__c);
		System.assertEquals(10, agu.Catheters_Sold__c);
		
		target.execute(null);
		agu = [SELECT Generator_Accounts__c, Catheters_Sold__c FROM AGU__c WHERE OwnerId = :UserInfo.getUserId() AND CreatedDate = TODAY];
	}
	
	private static void setUp() {
		customers = new List<Account>();
		customers.add(new Account(Name='Test',Date_Activated__c=day.addDays(-5),AGU_Owner__c=UserInfo.getUserId()));
		insert customers;
		
		Invoice2__c inv = new Invoice2__c(Key__c='TEST',InvoiceDate__c=day,PrimarySalesRep__c=UserInfo.getUserId(),BillTo__c=customers[0].Id);
		insert inv;
		
		Product2 p = new Product2(Name='Test Catheter',AGU_Classification__c='HALO360 Catheter',Commissionable__c=true);
		insert p;
		
		InvoiceLine__c il = new InvoiceLine__c(Key__c='TEST',Product__c=p.Id,UnitPrice__c=100,Invoice__c=inv.Id,Quantity__c=10);
		insert il;
	}
}