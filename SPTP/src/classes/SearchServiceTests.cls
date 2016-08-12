@isTest
private class SearchServiceTests {
	private static Account customer;
	
	testMethod static void testFindRecords() {
		setUp();
		
		SearchService target = new SearchService();
		target.findRecords(new Set<String>{customer.ShippingPostalCode}, null);
	}
	
	private static void setUp() {
		customer = new Account(Name='Test',ShippingPostalCode='94306');
		insert customer;
	}
}