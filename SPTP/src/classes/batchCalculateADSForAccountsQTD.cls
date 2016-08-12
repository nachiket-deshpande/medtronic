global class batchCalculateADSForAccountsQTD implements Database.Batchable<sObject> {
  String query;

  global batchCalculateADSForAccountsQTD () {
      if(test.isrunningtest()){
          query = 'Select Id FROM Account WHERE SAP_Account_Name__c != \'\' and SAP_Account_Name__c != null LIMIT 10';
      }else{
          query = 'Select Id FROM Account WHERE SAP_Account_Name__c != \'\' and SAP_Account_Name__c != null';
      } 
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {return Database.getQueryLocator(query);}

  global void execute(Database.BatchableContext BC, List<sObject> scope) {
    Account a;
    for(sObject s : scope){a = (Account)s;}
    //set dates for current q and prior 12 months
    Date currentDate = System.Today();
    Date d = currentDate.toStartOfMonth();
    Date prioyYearEndDate = d.addDays(-1);
    Date priorYearStartDate = d.addYears(-1);
    Date currFQStartDate;
    Date currFQEndDate;
    for (Period p : [SELECT EndDate,StartDate FROM Period WHERE Type='Quarter' and StartDate <= :currentDate and EndDate > :currentDate]){
      currFQStartDate = p.StartDate;
      currFQEndDate = p.EndDate;
    }
    
    
    //Instantiating the class BatchUtil
    BatchUtil util = new BatchUtil();
    //Instantiating the wrapperObject
    wrapperObject wrapper = new wrapperObject();
    wrapper = util.CalculateData(a.Id, 'THIS_FISCAL_QUARTER', null);
    
    a.Barrx_Disposable_QTD_Actual__c=wrapper.Barrx_Disposable_Base;
    a.Beacon_Base_QTD_Actual__c=wrapper.Beacon_Base;
    a.Pillcam_Disposable_QTD_Actual__c=wrapper.PillCam_Disposable_Base;
    a.Reflux_Disposable_QTD_Actual__c=wrapper.Reflux_Disposable_Base;
    a.Smartpill_Disposable_QTD_Actual__c=wrapper.SmartPill_Disposable_Base;
    a.PillCam_SB_QTD_Actual__c=wrapper.PillCam_SB;
    a.SmartPill_Capsules_QTD_Actual__c=wrapper.SmartPill_Capsules;
    a.RFA_Catheters_QTD_Actual__c=wrapper.RFA_Catheters;
    a.Bravo_Capsules_QTD_Actual__c=wrapper.Bravo_Capsules;
    update a;

    
  }
    
  global void finish(Database.BatchableContext BC) {
        
  }
    
}