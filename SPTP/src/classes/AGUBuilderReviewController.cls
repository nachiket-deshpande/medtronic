/**
 * Standard controller extension that backs "Review AGU Builder" page. Displays outstanding and completed events
 * by Contact of selected type for Account record that's in context.
 * 
 * @author Max Rudman
 * @since 1/24/2009
 */
public class AGUBuilderReviewController {
	private Account account;

	public String contactType {get; set;}
	public List<SelectOption> contactTypes {get; private set;}
	public List<Contact> contacts {get; private set;}
	public List<MilestoneRow> milestones {get; private set;}
	
	/**
	 * Default constructor.
	 */
	public AGUBuilderReviewController(ApexPages.StandardController standardController) {
		account = (Account)standardController.getRecord();
		milestones = new List<MilestoneRow>();
		contactType = 'Practicing Physician';
		
		DescribeFieldResult fdr = AGUBuilderMilestone__c.sObjectType.fields.ContactType__c.getDescribe();
		contactTypes = new List<SelectOption>();
		for (PicklistEntry entry : fdr.getPicklistValues()) {
			contactTypes.add(new SelectOption(entry.getValue(),entry.getLabel()));
		}
	}
	
	/**
	 * Action handler for initial page load.
	 */
	public PageReference onLoad() {
		contacts = [SELECT Id, Name FROM Contact WHERE RecordType.Name = :contactType AND (AccountId = :account.Id OR Hospital__c = :account.Id)];
		Set<Id> contactIds = new Set<Id>();
		for (Contact contact : contacts) {
			contactIds.add(contact.Id);
		}
		List<AGUBuilderMilestone__c> milestoneList = [SELECT Id, Name, Category__c FROM AGUBuilderMilestone__c WHERE ContactType__c = :contactType ORDER BY Sequence__c];
		
		Map<String,Event> eventsByKey = new Map<String,Event>();
		for (Event event : [SELECT Id, Subject, MilestoneId__c, WhoId, LastModifiedDate, StartDateTime, Description FROM Event WHERE WhoId IN :contactIds AND MilestoneId__c != NULL]) {
			eventsByKey.put(event.MilestoneId__c + '_' + event.WhoId, event);
		}
		
		this.milestones.clear();
		for (AGUBuilderMilestone__c milestone : milestoneList) {
			List<EventCell> cells = new List<EventCell>();
			for (Contact contact : contacts) {
				cells.add(new EventCell(contact, eventsByKey.get(milestone.Id + '_' + contact.Id)));
			}
			this.milestones.add(new MilestoneRow(milestone, cells, Math.mod(milestones.size(), 2) == 0));
		}
		
		if (this.milestones.size() > 0) {
			this.milestones.get(0).first = true;
			this.milestones.get(this.milestones.size() - 1).last = true;
		}
		return null;
	}
	
	/**
	 * Handler for "Close" button. Redirects to account detail page.
	 */
	public PageReference onClose() {
		return new PageReference('/' + account.Id);
	}
	
	/**
	 * Data structure that represents a row in milestone table. Wraps AGU Builder Milestone SObject,
	 * list of events for 
	 */
	public class MilestoneRow {
		public AGUBuilderMilestone__c milestone {get; private set;}
		public List<EventCell> cells {get; private set;}
		public Boolean even {get; set;}
		public Boolean first {get; set;}
		public Boolean last {get; set;}
		
		private MilestoneRow(AGUBuilderMilestone__c milestone, List<EventCell> cells, Boolean even) {
			this.milestone = milestone;
			this.cells = cells;
			this.even = even;
			this.first = true;
			this.last = true;
		}
		
		public String getName() {
			return milestone.Name;
		}
		
		public String getCategory() {
			return milestone.Category__c;
		}
		
		public String getClassModifiers() {
			String result = even ? 'even' : 'odd';
			if (first) {
				result = result + ' first';
			}
			if (last) {
				result = result + ' last';
			}
			return result;
		}
	}
	
	/**
	 * Data structure that represents status of milestone for a given Contact.
	 */
	public class EventCell {
		public Contact contact {get; private set;}
		public Event event {get; set;}
		public Boolean eventExists { get{return (event != null);} }
		
		public EventCell(Contact contact, Event event) {
			this.contact = contact;
			this.event = event;
		}
	}
}