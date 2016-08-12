public class CommissionReportControllerTests {
	testMethod static void testOnGenerate() {
		/*
		List<User> reps = [SELECT Id, Name FROM User WHERE IsActive = TRUE AND UserRole.Name LIKE '%Region TM' LIMIT 2];
		//System.assert(reps.size() == 2, 'Not enough users?');
		if(reps.size() >= 2){
		MonthlyQuota__c q1 = new MonthlyQuota__c(Month__c=1,Year__c=1980,SalesRep__c=reps.get(0).Id,Amount__c=10000,Disposable_Amount__c=300);
		MonthlyQuota__c q2 = new MonthlyQuota__c(Month__c=1,Year__c=1980,SalesRep__c=reps.get(1).Id,Amount__c=20000,Disposable_Amount__c=700);
		insert new List<MonthlyQuota__c>{q1,q2};
		
		Commission__c c1_1 = new Commission__c(Key__c='c1_1',SalesRep__c=reps.get(0).Id,Period__c=Date.newInstance(1980,2,1),CommissionedSales__c=500,DisposableSales__c=300,Quota__c=q1.Id);
		Commission__c c1_2 = new Commission__c(Key__c='c1_2',SalesRep__c=reps.get(0).Id,Period__c=Date.newInstance(1980,7,1),CommissionedSales__c=450,DisposableSales__c=400,Quota__c=q1.Id);
		Commission__c c1_3 = new Commission__c(Key__c='c1_3',SalesRep__c=reps.get(0).Id,Period__c=Date.newInstance(1980,9,1),CommissionedSales__c=500,DisposableSales__c=350,Quota__c=q1.Id);
		Commission__c c2 = new Commission__c(Key__c='c2',SalesRep__c=reps.get(1).Id,Period__c=Date.newInstance(1980,9,1),CommissionedSales__c=21000,Quota__c=q2.Id);
		insert new List<Commission__c>{c1_1,c1_2,c1_3,c2};
		
		CommissionReportController target = new CommissionReportController();
		target.year = 1980;
		PageReference pref = target.onGenerate();
		System.assert(pref == null, 'Unexpected page: ' + pref);
		
		List<CommissionReportController.RepCommissions> rows = target.commissions;
		System.assertEquals(2, rows.size(), 'Wrong # of rows');
		
		CommissionReportController.RepCommissions row1 = rows.get(0);
		System.assertEquals(12, row1.periods.size(), 'Wrong # of periods in row #1');
		// Minimum 6K commission in first half year
		//System.assertEquals(6000, row1.periods[1].getTotalAmount());
		//System.assertEquals((450 * 0.08), row1.periods[6].getTotalAmount());
		//System.assertEquals(500 * 0.08, row1.periods[8].getStandardAmount());
		//System.assertEquals(950 * 0.02, row1.periods[8].getDisposableBonusAmount(), 'Disp Sales: ' + row1.periods[8].getDisposableSalesQTD());
	}*/
	}
}