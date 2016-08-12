/**
 * Test suite for StringUtils class.
 * 
 * @author Max Rudman
 * @since 7/11/2009
 */
public class StringUtilsTests {
	testMethod static void testJoin() {
		List<String> values = new List<String>{'E1','E2'};
		System.assertEquals('E1E2', StringUtils.join(values,null,null));
		System.assertEquals('E1,E2', StringUtils.join(values,',',null));
		System.assertEquals('"E1","E2"', StringUtils.join(values,',','"'));
		System.assertEquals('', StringUtils.join(null,',','"'));
		System.assertEquals('"E1"', StringUtils.join(new List<String>{'E1',null},',','"'));
	}
	
	testMethod static void testSplitAndTrim() {
		List<String> result = StringUtils.splitAndTrim(' v1 ,v2',',');
		System.assertEquals(2, result.size());
		System.assertEquals('v1',result.get(0));
		System.assertEquals('v2',result.get(1));
	}
	
	testMethod static void testIsBlank() {
		System.assert(StringUtils.isBlank(null));
		System.assert(StringUtils.isBlank(' '));
		System.assert(!StringUtils.isBlank('value'));
	}
	
	testMethod static void testCapitalize() {
		System.assert(StringUtils.capitalize(null) == null);
		System.assertEquals('',StringUtils.capitalize(' '));
		System.assertEquals('John', StringUtils.capitalize('john'));
	}
}