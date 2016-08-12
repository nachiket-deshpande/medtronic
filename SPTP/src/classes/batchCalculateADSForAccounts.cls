global class batchCalculateADSForAccounts implements Database.Batchable<sObject> {
  String query;

  global batchCalculateADSForAccounts () {
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
    /*
    //aggregate sales data and counts
    Decimal Barrx_Disposable_Base=0;
    Decimal Beacon_Base=0;
    Decimal PillCam_Disposable_Base=0;
    Decimal Reflux_Disposable_Base=0;
    Decimal SmartPill_Disposable_Base=0;
    Integer PillCam_SB=0;
    Integer SmartPill_Capsules=0;
    Integer RFA_Catheters=0;
    Integer Bravo_Capsules=0;

    for (InvoiceLine__c il : [SELECT Product__r.Product_Group__c,ExtendedPrice__c,Product__r.Product_Category__c 
                                FROM InvoiceLine__c
                               WHERE Invoice__r.InvoiceDate__c >= :priorYearStartDate and 
                                     Invoice__r.InvoiceDate__c <= :prioyYearEndDate and 
                                     Invoice__r.SAPSoldTo__c = :a.Id]){
      if(il.Product__r.Product_Group__c=='PillCam Disposables') {PillCam_Disposable_Base+=il.ExtendedPrice__c;}
      else if(il.Product__r.Product_Group__c=='SmartPill Disposables') {SmartPill_Disposable_Base+=il.ExtendedPrice__c;}
      else if(il.Product__r.Product_Group__c=='Barrx Disposables') {Barrx_Disposable_Base+=il.ExtendedPrice__c;}
      else if(il.Product__r.Product_Group__c=='Reflux Disposables') {Reflux_Disposable_Base+=il.ExtendedPrice__c;}
      else if(il.Product__r.Product_Group__c=='Beacon Disposables') {Beacon_Base+=il.ExtendedPrice__c;}

      if(il.Product__r.Product_Category__c=='PillCam_SB Capsules'){PillCam_SB++;}
      else if(il.Product__r.Product_Category__c=='PillCam_Patency Capsules'){PillCam_SB++;}
      else if(il.Product__r.Product_Category__c=='SmartPill_Capsules'){SmartPill_Capsules++;}
      else if(il.Product__r.Product_Category__c=='Reflux_Bravo Capsules '){Bravo_Capsules++;}
      else if(il.Product__r.Product_Group__c=='Ablation Balloon'){RFA_Catheters++;}
      else if(il.Product__r.Product_Group__c=='Barrx Focal'){RFA_Catheters++;}
      else if(il.Product__r.Product_Group__c=='Barrx_Channel'){RFA_Catheters++;}
      
    }*/
    
    //Instantiating the class BatchUtil
    BatchUtil util = new BatchUtil();
    //Instantiating the wrapperObject
    wrapperObject wrapper = new wrapperObject();
    wrapper = util.CalculateData(a.Id, 'LAST_N_MONTHS:12', null);
    
    a.Barrx_Disposable_Base__C=wrapper.Barrx_Disposable_Base;
    a.Beacon_Base__C=wrapper.Beacon_Base;
    a.PillCam_Disposable_Base__C=wrapper.PillCam_Disposable_Base;
    a.Reflux_Disposable_Base__c=wrapper.Reflux_Disposable_Base;
    a.SmartPill_Disposable_Base__c=wrapper.SmartPill_Disposable_Base;
    a.PillCam_SB__c=wrapper.PillCam_SB;
    a.SmartPill_Capsules__c=wrapper.SmartPill_Capsules;
    a.RFA_Catheters__c=wrapper.RFA_Catheters;
    a.Bravo_Capsules__c=wrapper.Bravo_Capsules;
    update a;

    
  }
    
  global void finish(Database.BatchableContext BC) {}
    
}