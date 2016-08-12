/*    This class clones the active sales plans to keep as an archive and updates the following information on the current ones
        1. Update the FQ Start and FQ End dates
        2. Clear out the growth goal fields
      The archived plans will be created as inactive and have the entire header level information about the Base and Targets. No info about the physician objectives as they are not copied.   
        
*/
global class batchCreateSalesPlans implements Database.Batchable<sObject> {
  String querySalesPlan ;
  Date currFQStartDate;
  Date currFQEndDate;
  global batchCreateSalesPlans() {
      //query = 'Select Id FROM Account WHERE SAP_Account_Name__c != \'\' and SAP_Account_Name__c != null and Has_Active_Sales_Plan__c > 0';
      if(test.isrunningtest()){
         querySalesPlan = 'Select id , Account__c, Account_Name__c, ' 
                           + 'Beacon_CQ_Growth_Goal__c , PillCam_CQ_Growth_Goal__c, '
                           + 'Reflux_CQ_Growth_Goal__c, SmartPill_CQ_Growth_Goal__c , '
                           + 'Barrx_Disposable_Base__c, SmartPill_Disposable_Base__c, '
                           + ' Barrx_Total_CQ_Target__c, Beacon_Total_CQ_Target__c, PillCam_Total_CQ_Target__c, Reflux_Total_CQ_Target__c, SmartPill_Total_CQ_Target__c, '
                           + ' Reflux_Disposable_Base__c, PillCam_Disposable_Base__c, Beacon_Base__c, '
                           + ' Barrx_CQ_Growth_Goal__c,   Bravo_Capsules_QTD_Actual__c, Pillcam_Disposable_QTD_Actual__c, '
                           + ' PillCam_SB_QTD_Actual__c, Reflux_Disposable_QTD_Actual__c,RFA_Catheters_QTD_Actual__c, '
                           + ' SmartPill_Capsules_QTD_Actual__c, Smartpill_Disposable_QTD_Actual__c, '
                           + ' Barrx_Disposable_QTD_Actual__c, Beacon_Base_QTD_Actual__c '
                           + ' from Sales_Plan__c  Where Active__c = true Limit 10';
      }
         else{
            querySalesPlan = 'Select id , Account__c, Account_Name__c, ' 
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
         }
      //Date currentDate = System.Today().addDays(9);
      
      for (Period p : [SELECT EndDate,StartDate FROM Period WHERE Type='Quarter' and StartDate <= :system.today() and EndDate > :system.today()]){
          currFQStartDate = p.StartDate;
          currFQEndDate = p.EndDate;
      } 
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {return Database.getQueryLocator(querySalesPlan);}

  global void execute(Database.BatchableContext BC, List<sObject> scope) {
    List<Sales_Plan__c> spInsertList = new List<Sales_Plan__c>();
    List<Sales_Plan__c> spUpdateList = new List<Sales_Plan__c>();
    for(sObject s : scope){
    
    //create new sales plan records for the current quarter.
      Sales_Plan__c osp = (Sales_Plan__c) s;
      Sales_Plan__c sp = osp.clone(false,true);
      sp.Active__c = false;
      sp.Account__c = osp.Account__c;
      spInsertList.add(sp);
      //insert sp;
      osp.Beacon_CQ_Growth_Goal__c = 0;
      osp.PillCam_CQ_Growth_Goal__c = 0;
      osp.Reflux_CQ_Growth_Goal__c = 0;
      osp.SmartPill_CQ_Growth_Goal__c = 0;
      osp.Barrx_CQ_Growth_Goal__c = 0;
      osp.FQ_Start_Date__c = currFQStartDate ;
      osp.FQ_End_Date__c = currFQEndDate ;
      spUpdateList.add(osp);
    }
    if(spUpdateList.size() > 0){
        update spUpdateList ;
    }
    if(spInsertList.size() > 0){
        insert spInsertList ;
    }
    
  }
    
  global void finish(Database.BatchableContext BC) {
      Date currentDate = System.Today().addMonths(3);
      List<Period> p = [SELECT EndDate,StartDate FROM Period WHERE Type='Quarter' and StartDate <= :currentDate and EndDate > :currentDate];
      if(p != null && p.size() > 0) {
            Date nextSchDate = p[0].StartDate;
            String Csec,Cmin,Chr,Cday,Cmonth,CYear;
            Csec=String.valueof(0);
            Cmin=String.valueof(0);
            Chr=String.valueof(8);
            Cday=String.valueof(nextSchDate.day());
            Cmonth=String.valueof(nextSchDate.month());
            CYear=String.valueof(nextSchDate.Year());
            String SchTimer=Csec+' '+Cmin+' '+Chr+' '+Cday+' '+Cmonth+' ? '+CYear;
            System.debug(LoggingLevel.INFO, 'timer = '+schTimer);
            
            if(!Test.isRunningTest())
            system.schedule('Create Sales Plans'+SchTimer, SchTimer, new scheduleSalesPlanCreate());
      }

  }
    
}