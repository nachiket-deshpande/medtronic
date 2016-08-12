/**
 * Unit tests for <code>LocationService</code> class.
 * 
 * @author Max Rudman
 * @since 8/16/2010
 */
@isTest
private class LocationServiceTests {
	private static Location__c baseLocation;
	private static Location__c locationWithin;
	private static Location__c locationOutside;
	
	testMethod static void testFindLocationByName() {
		setUp();
		
		LocationService target = new LocationService();
		Location__c result = target.findLocationByName('AAAAA');
		System.assert(result != null);
		System.assertEquals(baseLocation.Id, result.Id);
	}
	
	testMethod static void testFindLocationsWithinMileRadius() {
		setUp();
		
		LocationService target = new LocationService();
		Location__c[] results = target.findLocationsWithinMileRadius('AAAAA',2);
		System.assert(results != null);
		System.assertEquals(2, results.size());
		//System.assertEquals(locationWithin.Id, results[0].Id);
	}
	
	testMethod static void testFindLocationNamesWithinMileRadius() {
		setUp();
		
		LocationService target = new LocationService();
		Set<String> results = target.findLocationNamesWithinMileRadius('AAAAA',2);
		System.assert(results != null);
		System.assertEquals(2, results.size());
		System.assert(results.contains(locationWithin.Name));
	}
	
	private static void setUp() {
		baseLocation = new Location__c(Name='AAAAA',Latitude__c=37.418009,Longitude__c=122.127375);
		locationWithin = new Location__c(Name='BBBBB',Latitude__c=37.444324,Longitude__c=122.149685);
		locationOutside = new Location__c(Name='ZZZZZ',Latitude__c=37.346992,Longitude__c=121.983848);
		insert new List<Location__c>{baseLocation,locationWithin,locationOutside};
	}
}