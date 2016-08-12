/**
 * Unit tests for CollectionUtils class.
 * 
 * @author Max Rudman
 * @since 11/22/2009
 */
public class CollectionUtilsTests {
	testMethod static void testSort() {
		SortableObject[] values = new SortableObject[]{new SortableObject('Zach'),new SortableObject('Bob'),new SortableObject('John'),new SortableObject('Adam')};
		CollectionUtils.sort(values);
		System.assertEquals('Adam',values[0].value);
		System.assertEquals('Bob',values[1].value);
		System.assertEquals('John',values[2].value);
		System.assertEquals('Zach',values[3].value);
		
		//values = new SortableObject[]{new SortableObject('John'),new SortableObject('Adam')};
		//CollectionUtils.sort(values, (CollectionUtils.Comparator<Object>)new TestComparator());
		//System.assertEquals('Adam',values[0].value);
		CollectionUtils.sort(null);
	}
	
	/* public class TestComparator implements CollectionUtils.Comparator<SortableObject> {
		public Integer compare(SortableObject v1, SortableObject v2) {
			return v1.value.compareTo(v2.value);
		}
	} */
	
	public class SortableObject implements CollectionUtils.Comparable {
		public String value;
		
		public SortableObject(String value) {
			this.value = value;
		}
		
		public Integer compareTo(Object other) {
			return compareTo((SortableObject)other);
		}
		
		public Integer compareTo(SortableObject other) {
			return value.compareTo(other.value);
		}
	}
}