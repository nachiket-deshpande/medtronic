@isTest//(seeAlldata=true)
private class TestbatchCreateSalesPlans     {
    static testMethod void unitTest() {
        Test.StartTest();
            /*String querySalesPlan = 'Select id , Account__c, Account_Name__c, ' 
                           + 'Beacon_CQ_Growth_Goal__c , PillCam_CQ_Growth_Goal__c, '
                           + 'Reflux_CQ_Growth_Goal__c, SmartPill_CQ_Growth_Goal__c , '
                           + 'Barrx_Disposable_Base__c, SmartPill_Disposable_Base__c, '
                           + ' Barrx_Total_CQ_Target__c, Beacon_Total_CQ_Target__c, PillCam_Total_CQ_Target__c, Reflux_Total_CQ_Target__c, SmartPill_Total_CQ_Target__c, '
                           + ' Reflux_Disposable_Base__c, PillCam_Disposable_Base__c, Beacon_Base__c, '
                           + ' Barrx_CQ_Growth_Goal__c,   Bravo_Capsules_QTD_Actual__c, Pillcam_Disposable_QTD_Actual__c, '
                           + ' PillCam_SB_QTD_Actual__c, Reflux_Disposable_QTD_Actual__c,RFA_Catheters_QTD_Actual__c, '
                           + ' SmartPill_Capsules_QTD_Actual__c, Smartpill_Disposable_QTD_Actual__c, '
                           + ' Barrx_Disposable_QTD_Actual__c, Beacon_Base_QTD_Actual__c '
                           + ' from Sales_Plan__c  Where Active__c = true ';
            List<sObject> scope = Database.Query(querySalesPlan);*/
            Account acc = new Account(Name = 'Test Acc');
            insert acc;
            
            Sales_Plan__c salesPlan= new Sales_Plan__c(Name = 'Test Sales Plan', Account__c = acc.Id, FQ_Start_Date__c = Date.newInstance(2014 , 03 ,20), FQ_End_Date__c = Date.newInstance(2014 , 06 ,20));
            insert salesPlan;
            System.debug('salesPlan====' + salesPlan);
            batchCreateSalesPlans batch   =  new  batchCreateSalesPlans ();
            Database.BatchableContext bc;
            batch.start(bc);
            
            batch.execute(bc, new List<Sales_Plan__c> {salesPlan});
        
        
            batch.finish(bc);
            
            //database.executeBatch(new batchCreateSalesPlans());
             //Database.executeBatch(batch,1);
        Test.StopTest();
        
    }
    
    static testMethod void unitTest2() {
        scheduleSalesPlanCreate sch = new scheduleSalesPlanCreate();
        SchedulableContext sc;
        sch.execute(sc);
    }
}