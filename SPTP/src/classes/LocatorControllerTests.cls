@isTest
private class LocatorControllerTests {
	private static Account customer;
	private static Location__c baseLocation;
	
	testMethod static void testOnSearch() {
		setUp();
		
		LocatorController target = new LocatorController();
		target.radius = 5;
		target.baseLocation = '94306';
		target.onSearch();
	}
	
	private static void setUp() {
		customer = new Account(Name='Test',ShippingPostalCode='94306');
		insert customer;
		
		baseLocation = new Location__c(Name='94306',Latitude__c=37.418009,Longitude__c=-122.127375);
		insert baseLocation;
	}
}