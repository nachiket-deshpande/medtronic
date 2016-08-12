/**
 * Unit tests for <code>GeoCalculator</code> class.
 * 
 * @author Max Rudman
 * @since 8/16/2010
 */
@isTest
private class GeoUtilsTests {
    testMethod static void testComputeDistance() {
        GeoUtils.Coordinates zip94306 = 
            new GeoUtils.Coordinates(37.418009.doubleValue(),-122.127375.doubleValue());
        GeoUtils.Coordinates zip95051 = 
            new GeoUtils.Coordinates(37.346992.doubleValue(),-121.983848.doubleValue());
        Decimal result = Decimal.valueOf(GeoUtils.computeDistance(zip94306,zip95051)).setScale(2);
        System.assertEquals(14956.60, result);
    }
    
    testMethod static void testComputeDestination() {
        GeoUtils.Coordinates zip94306 = 
            new GeoUtils.Coordinates(37.418009.doubleValue(),-122.127375.doubleValue());
        GeoUtils.Coordinates result = GeoUtils.computeDestination(zip94306,10000,90);
        Decimal lat = Decimal.valueOf(result.latitude).setScale(2);
        Decimal lon = Decimal.valueOf(result.longitude).setScale(2);
        System.assertEquals(37.42, lat);
        System.assertEquals(-122.01, lon);
    }
}