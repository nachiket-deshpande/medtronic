@isTest(seeAlldata=true)
private class TestbatchCalculateADSForAccountsQTD    {
    static testMethod void unitTest() {
        Test.StartTest();
            String query = 'Select Id FROM Account WHERE SAP_Account_Name__c != \'\' and SAP_Account_Name__c != null ';
            List<sObject> scope = Database.Query(query);
            batchCalculateADSForAccountsQTD batch   =  new  batchCalculateADSForAccountsQTD ();
            Database.BatchableContext bc;
            batch.start(bc);
            
            batch.execute(bc, scope );
        
        
            batch.finish(bc);
        Test.StopTest();
        batchADSForAccountsQTDSch sch = new batchADSForAccountsQTDSch();
        SchedulableContext sc;
        sch.execute(sc);
    }
}