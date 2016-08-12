public with sharing class LocatorController {
	public String baseLocation {get; set;}
	public Integer radius {get; set;}
	public List<ResultRow> resultRows {get; private set;}
	public Boolean searched {get; private set;}
	public Boolean empty { get{return (resultRows == null) || (resultRows.size() == 0);} }
	
	public LocatorController() {
		radius = 5;
		searched = false;
	}
	
	public PageReference onSearch() {
		if (StringUtils.isBlank(baseLocation)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must enter base zip code'));
			return null;
		}
		resultRows = new List<ResultRow>();
		try {
			Map<String,String> filters = new Map<String,String>();
			Set<String> nearLocations = LocationService.getInstance().findLocationNamesWithinMileRadius(baseLocation, radius);
			for (SObject rec : SearchService.getInstance().findRecords(nearLocations, filters)) {
				Double distance = LocationService.getInstance().computeDistance(baseLocation, ((Contact)rec).MailingPostalCode);
				if (distance <= radius) {
					resultRows.add(new ResultRow(rec, Decimal.valueOf(distance).setScale(1)));
				}
			}
			CollectionUtils.sort(resultRows);
		} catch (Exception e) {
			ApexPages.addMessages(e);
			return null;
		}
		searched = true;
		return null;
	}
	
	public class ResultRow implements CollectionUtils.Comparable {
		public SObject record {get; private set;}
		public Decimal distance {get; private set;}
		public Contact contact {get{return (Contact)record;}}
		
		public ResultRow(SObject record, Decimal distance) {
			this.record = record;
			this.distance = distance;
		}
		
		public Integer compareTo(Object value) {
			ResultRow other = (ResultRow)value;
			if (distance == other.distance) {
				String otherValue = other.contact.LastName != null ? other.contact.LastName : '';
        		String thisValue = contact.LastName != null ? contact.LastName : '';
        
				return thisValue.compareTo(otherValue);
			}
			return (distance > other.distance) ? 1 : -1;
		}
	}
}