/**
 * Custom business logic that handles "locations within miles" searches.
 * 
 * @author Max Rudman
 * @since 8/16/2010
 */
public with sharing class LocationService {
	private static LocationService INSTANCE = new LocationService();
	
	public static final Double PI = 3.141592653589793;
	
	private Map<String,Location__c> cachedLocationsByName = new Map<String,Location__c>();
	
	public static LocationService getInstance() {
		return INSTANCE;
	}
	 
	public Location__c findLocationByName(String name) {
		if (cachedLocationsByName.containsKey(name)) {
			return cachedLocationsByName.get(name);
		}
		List<Location__c> locs = [SELECT Name, Longitude__c, Latitude__c FROM Location__c WHERE Name = :name];
		if (locs.size() == 0) {
			return null;
		}
		cachedLocationsByName.put(name, locs[0]);
		return locs[0];
	}
	
	public List<Location__c> findLocationsWithinMileRadius(String locationName, Integer mileRadius) {
		Location__c baseLocation = findLocationByName(locationName);
		if (baseLocation == null) {
			throw new LocationException('Location not found: ' + locationName);
		}
		if (mileRadius == null) {
			mileRadius = 5;
		}
	      
		Double meterRadius = GeoUtils.toKilometers(mileRadius) * 1000;
		
		GeoUtils.Coordinates baseCoords = 
			new GeoUtils.Coordinates(baseLocation.Latitude__c.doubleValue(), baseLocation.Longitude__c.doubleValue());
		
		GeoUtils.Coordinates n = GeoUtils.computeDestination(baseCoords, meterRadius, 0);
		GeoUtils.Coordinates w = GeoUtils.computeDestination(baseCoords, meterRadius, 270);
		GeoUtils.Coordinates e = GeoUtils.computeDestination(baseCoords, meterRadius, 90);
		GeoUtils.Coordinates s = GeoUtils.computeDestination(baseCoords, meterRadius, 180);
		
		Double minLat = s.latitude;
		Double maxLat = n.latitude;
		Double minLon = w.longitude;
		Double maxLon = e.longitude;
		//System.assert(false, minLat + '-' + maxLat + ' ' + minLon + '-' + maxLon);
		
		List<Location__c> locations = new List<Location__c>();
		for (Location__c loc : [SELECT Name, Longitude__c, Latitude__c FROM Location__c WHERE Latitude__c >= :minLat AND Latitude__c <= :maxLat AND Longitude__c >= :minLon AND Longitude__c <= :maxLon ORDER BY Name]) {
			locations.add(loc);
			cachedLocationsByName.put(loc.Name, loc);
		}
		return locations;
	}
	
	public Set<String> findLocationNamesWithinMileRadius(String locationName, Integer mileRadius) {
		Set<String> result = new Set<String>();
		for (Location__c loc : findLocationsWithinMileRadius(locationName, mileRadius)) {
			result.add(loc.Name);
		}
		return result;
	}
	
	/**
	 * Performs the calculation to determine the mileage between 2 points defined by lattitude and longitude coordinates. 
	 * This calculation is based on the code found at http://www.cryptnet.net/fsp/zipdy/
	 */
	public Decimal computeDistance(Location__c location1, Location__c location2) {
		System.debug('**** LOC1: ' + location1 + '; LOC2: ' + location2);
		
		GeoUtils.Coordinates coords1 = new GeoUtils.Coordinates(location1.Latitude__c, location1.Longitude__c);
		GeoUtils.Coordinates coords2 = new GeoUtils.Coordinates(location2.Latitude__c, location2.Longitude__c);
		return GeoUtils.toMiles(GeoUtils.computeDistance(coords1, coords2) / 1000);
	}
	
	public Decimal computeDistance(String name1, String name2) {
		return computeDistance(findLocationByName(name1), findLocationByName(name2));
	}
	
	private static Double toRadians(Decimal degrees) {
		return degrees.doubleValue() / 180.0 * PI;
	}
	
	public class LocationException extends Exception {}
}