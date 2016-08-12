public class AGUBuilderTests {
	private static final Id FELLOW_RTID = '012400000009ZZ8';
	
	private static Contact fellow;
	private static AGUBuilderMilestone__c fm1;
	private static AGUBuilderMilestone__c fm2;
	private static AGUBuilderMilestone__c ppm1;
	
	testMethod static void testAvailableTasks() {
		Integer oldCount = [SELECT count() FROM AGUBuilderMilestone__c WHERE ContactType__c = 'Fellow'];
		
		setUp();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(fellow);
		AGUTaskSelectionController target = new AGUTaskSelectionController(sc);
		PageReference pref = target.onLoad();
		System.assertEquals(null, pref);
		System.assert(target.events != null);
		System.assertEquals(oldCount + 2, target.events.size());
		
		// Test with completed task for milestone 1 but not assigned to contact
		/* Task task = new Task(Subject='Test1',MilestoneId__c=fm1.Id,Status='Completed');
		insert task;
		target.onLoad();
		System.assertEquals(oldCount + 2, target.getTasks().size(), 'Wrong # of tasks'); */
		
		// Test with completed task for milestone 1 and assigned to contact
		/* task = new Task(Subject='Test2',WhoId=fellow.Id,MilestoneId__c=fm1.Id,Status='Completed');
		insert task;
		target.onLoad();
		System.assertEquals(oldCount + 1, target.getTasks().size(), 'Wrong # of tasks'); */
	}
	
	testMethod static void testScheduleEvents() {
		setUp();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(fellow);
		AGUTaskSelectionController target = new AGUTaskSelectionController(sc);
		
		target.selectedEvents.add(new Event());
		target.selectedEvents.add(new Event());
		PageReference pref = target.onSchedule();
		System.assert(null != pref);
		System.assertEquals(Page.ScheduleAGUTask.getUrl(), pref.getUrl());
		System.assertEquals(0,target.selectedEvents.size());
		
		target.events.add(new AGUTaskSelectionController.EventRow(new Event(),null));
		target.events.add(new AGUTaskSelectionController.EventRow(new Event(),null));
		target.events.get(0).selected = true;
		target.onSchedule();
		System.assertEquals(1,target.selectedEvents.size());
	}
	
	testMethod static void testCreateEvents() {
		setUp();
		
		Integer control = [SELECT count() FROM Event WHERE MilestoneId__c IN (:fm1.Id,:fm2.Id,:ppm1.Id)];
		System.assertEquals(0,control);
		
		ApexPages.StandardController sc = new ApexPages.StandardController(fellow);
		AGUTaskSelectionController target = new AGUTaskSelectionController(sc);
		target.selectedEvents.add(new Event(Subject=fm1.Name,MilestoneId__c=fm1.Id,StartDateTime=DateTime.now(),DurationInMinutes=60));
		target.selectedEvents.add(new Event(Subject=fm2.Name,MilestoneId__c=fm2.Id,StartDateTime=DateTime.now(),DurationInMinutes=60));
		PageReference pref = target.onCreate();
		System.assert(pref != null);
		System.assertEquals('/' + fellow.Id, pref.getUrl());
	}
	
	testMethod static void testReview() {
		setUp();
		
		Integer mc = [SELECT count() FROM AGUBuilderMilestone__c WHERE ContactType__c = 'Fellow'];
		
		Account hospital = new Account(Name='Hospital');
		insert hospital;
		
		fellow.AccountId = hospital.Id;
		update fellow;
		
		Contact fellow2 = new Contact(LastName='Fellow2',RecordTypeId=FELLOW_RTID,AccountId=hospital.Id);
		insert fellow2;
		
		Event e1 = new Event(Subject=fm1.Name,WhoId=fellow.Id,MilestoneId__c=fm1.Id,StartDateTime=DateTime.now(),DurationInMinutes=60);
		Event e2 = new Event(Subject=fm1.Name,WhoId=fellow2.Id,MilestoneId__c=fm1.Id,StartDateTime=DateTime.now(),DurationInMinutes=60);
		insert new List<Event>{e1,e2};
		
		ApexPages.StandardController sc = new ApexPages.StandardController(hospital);
		AGUBuilderReviewController target = new AGUBuilderReviewController(sc);
		target.contactType = 'Fellow';
		PageReference pref = target.onLoad();
		List<AGUBuilderReviewController.MilestoneRow> rows = target.milestones;
		System.assertEquals(mc, rows.size(), 'Wrong # of milestones');
		Map<String,AGUBuilderReviewController.MilestoneRow> rowsByMilestoneId = new Map<String,AGUBuilderReviewController.MilestoneRow>();
		for (AGUBuilderReviewController.MilestoneRow row : rows) {
			rowsByMilestoneId.put(row.milestone.Id, row);
		}
		
		AGUBuilderReviewController.MilestoneRow row1 = rowsByMilestoneId.get(fm1.Id);
		System.assertEquals(2, row1.cells.size(),'Wrong # of contacts for milestone: ' + rows.get(0).getName());
		System.assertEquals(true, row1.cells.get(0).eventExists);
		System.assertEquals(true, row1.cells.get(1).eventExists);
		
		AGUBuilderReviewController.MilestoneRow row2 = rowsByMilestoneId.get(fm2.Id);
		System.assertEquals(false, row2.cells.get(0).eventExists);
		System.assertEquals(false, row2.cells.get(1).eventExists);
		
	}
	
	
	@isTest
	private static void setUp() {
		fm1 = new AGUBuilderMilestone__c(Name='Milestone1',ContactType__c='Fellow');
		fm2 = new AGUBuilderMilestone__c(Name='Milestone2',ContactType__c='Fellow');
		ppm1 = new AGUBuilderMilestone__c(Name='Milestone3',ContactType__c='Practicing Physician');
		insert new List<AGUBuilderMilestone__c>{fm1,fm2,ppm1};
		
		fellow = new Contact(LastName='Fellow1',RecordTypeId=FELLOW_RTID);
		insert fellow;
	}
}