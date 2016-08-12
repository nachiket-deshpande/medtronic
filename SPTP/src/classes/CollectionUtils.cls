/**
 * Various utility methods related to handling of collections.
 * 
 * @author Max Rudman
 * @since 11/22/2009
 */
public class CollectionUtils {
	/* public static void sort(List<Object> values, Comparator<Object> comparator) {
		if ((values == null) || (values.size() <= 1)) {  
	         return;
	     }
		quickSort(values,comparator,0,values.size() - 1);
	} */
	
	public static void sort(List<Comparable> values) {
		if ((values == null) || (values.size() <= 1)) {  
	         return;
	     }
		
		for (Integer i=0;i<values.size();i++) {
			for (Integer j=(i+1);j<values.size();j++) {
				Comparable v1 = values[i];
				Comparable v2 = values[j];
				if (v1.compareTo(v2) > 0) {
					Comparable temp = values[i];
					values[i] = values[j];
					values[j] = temp;
				}
			}
		}
	}
	
	/* 
	private static void quickSort(List<Object> values, Comparator<Object> comparator, Integer left, Integer right) {
		if (right > left) {
        	Integer pivotIndex = left;
        	pivotIndex = partition(values, comparator, left, right, pivotIndex);
        	quickSort(values, comparator, left, pivotIndex - 1);
        	quickSort(values, comparator, pivotIndex + 1, right);
		}
	}
	
	private static Integer partition(List<Object> values, Comparator<Object> comparator, Integer left, Integer right, Integer pivotIndex) {
		Object pivotValue = values[pivotIndex];
		values[pivotIndex] = values[right];
		values[right] = pivotValue;
		Integer storeIndex = left;
		for (Integer i=left;i<right;i++) {
			System.assert(values[i] instanceof Comparable);
			Integer result = ((Comparable)values[i]).compareTo(pivotValue);
			if (result < 0) {
				Object temp = values[i];
				values[i] = values[storeIndex];
				values[storeIndex] = temp;
				storeIndex++;
			}
		}
		// Move pivot to its final place
		Object temp = values[storeIndex];
		values[storeIndex] = values[right];
		values[right] = temp;
		return storeIndex;
	}
	*/
	
	public interface Comparator<T> {
		Integer compare(T value1, T value2);
	}
	
	public virtual interface Comparable {
		Integer compareTo(Object value);
	}
}