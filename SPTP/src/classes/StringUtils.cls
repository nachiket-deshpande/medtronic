/**
 * Utility methods that provide additional functionality around String handling.
 * 
 * @author Max Rudman
 * @since 7/11/2009
 */
public class StringUtils {
	
	/**
	 * Joins specified array of string values using specified separator. Optionally, 
	 */
	public static String join(List<String> values, String separator, String enclosedBy) {
		// Handle null values
		if ((values == null) || (values.size() == 0)) {
			return '';
		}
		if (separator == null) {
			separator = '';
		}
		if (enclosedBy == null) {
			enclosedBy = '';
		}
		
		String result = '';
		for (String value : values) {
			if (value == null) {
				continue;
			}
			result += (enclosedBy + value + enclosedBy + separator);
		}
		// Chop off trailing separator
		result = result.substring(0,result.length() - separator.length());
		return result;
	}
	
	/**
	 * Tests if specified value is null or an empty string.
	 */
	public static Boolean isBlank(String value) {
		return (value == null) || (value.trim().length() == 0);
	}
	
	public static String[] splitAndTrim(String value, String regExp) {
		List<String> result = new List<String>();
		for (String part : value.split(regExp)) {
			if (part != null) {
				result.add(part.trim());
			}
		}
		return result;
	}
	
	public static String capitalize(String value) {
		if (value == null) {
			return null;
		}
		value = value.trim();
		if (value.length() == 0) {
			return value;
		} else if (value.length() == 1) {
			return value.toUpperCase();
		}
		
		return value.substring(0,1).toUpperCase() + value.substring(1,value.length());
	}
}