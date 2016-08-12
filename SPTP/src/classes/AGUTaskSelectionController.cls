/**
 * Controller implementation that extends standard Contact controller to allow users to select and schedule tasks neccessary to drive AGU
 * at selected contact.
 * 
 * @author Max Rudman
 * @since 12/15/2008
 */
public class AGUTaskSelectionController {
	private String returnUrl;
	
	public Contact contact {get; private set;}
	public List<EventRow> events {get; private set;}
	public List<Event> selectedEvents {get; private set;}
	
	/**
	 * Default constructor.
	 */
	public AGUTaskSelectionController(ApexPages.StandardController standardController) {
		contact = [SELECT Id, Name, RecordTypeId, RecordType.Name FROM Contact WHERE Id = :standardController.getId()];
		returnUrl = ApexPages.currentPage().getParameters().get('retURL');
		events = new List<EventRow>();
		selectedEvents = new List<Event>();
	}
	
	/**
	 * Action hadler for initial page load.
	 */
	public PageReference onLoad() {
		events.clear();
		String contactType = contact.RecordType.Name;
		for (AGUBuilderMilestone__c milestone : [SELECT Id, Name, Category__c, Description__c FROM AGUBuilderMilestone__c WHERE ContactType__c = :contactType]) {
			events.add(new EventRow(new Event(Subject=milestone.Name,MilestoneId__c=milestone.Id,WhoId=contact.Id,Description=milestone.Description__c,DurationInMinutes=60), milestone));
		}
		return null;
	}
	
	/**
	 * Handles the action that results from user clicking on "Schedule" button.
	 */
	public PageReference onSchedule() {
		selectedEvents.clear();
		for (EventRow row : events) {
			if (row.selected == true) {
				selectedEvents.add(row.event);
			}
		}
		return Page.ScheduleAGUTask;
	}
	
	/**
	 * Handles the action that results from user clicking on "Create" button.
	 */
	public PageReference onCreate() {
		try {
			insert selectedEvents;
		} catch (DmlException dmle) {
			ApexPages.addMessages(dmle);
			return null;
		}
		
		if (returnUrl == null) {
			returnUrl = '/' + contact.Id;
		}
		return new PageReference(returnUrl);
	}
	
	/**
	 * Handles the action that results from user clicking on "Cancel" button.
	 */
	public PageReference onCancel() {
		if (returnUrl == null) {
			returnUrl = '/' + contact.Id;
		}
		return new PageReference(returnUrl);
	}
	
	/**
	 * Internal data structire used to represent selectable events.
	 */
	public class EventRow {
		private AGUBuilderMilestone__c milestone;
		
		public Event event {get; private set;}
		public Boolean selected {get; set;}
		public String category { get{return milestone.Category__c;} }
		
		/**
		 * Deafult constructor.
		 */
		public EventRow(Event event, AGUBuilderMilestone__c milestone) {
			this.event = event;
			this.milestone = milestone;
			selected = false;
		}
	}
}