@isTest(seeAlldata=true)
private class TestbatchCalculateADSForAccounts     {
    static testMethod void unitTest() {
        Test.StartTest();
            String query = 'Select Id FROM Account WHERE SAP_Account_Name__c != \'\' and SAP_Account_Name__c != null ';
            List<sObject> scope = Database.Query(query);
            batchCalculateADSForAccounts batch   =  new  batchCalculateADSForAccounts ();
            Database.BatchableContext bc;
            batch.start(bc);
            
            batch.execute(bc, scope );
        
        
            batch.finish(bc);
        Test.StopTest();
        batchADSForAccountsSch sch = new batchADSForAccountsSch();
        SchedulableContext sc;
        sch.execute(sc);
    }
}