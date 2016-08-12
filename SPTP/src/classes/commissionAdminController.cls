public with sharing class commissionAdminController {
  public Boolean inProcess {get;set;}
  public String fy {get;set;}
  public Boolean recreateCommRecords {get;set;}
  public List<selectOption> getFiscalYears() {
    List<selectOption> options = new List<selectOption>(); 
    options.add(new selectOption('', '- None -')); 
//    options.add(new selectOption('2016', '2016')); 
    options.add(new selectOption('2017', '2017')); 
    return options;
  }
  
  public commissionAdminController() {}

  public PageReference checkExisting() {
    inProcess = false;
    //if there is a batch already running show in progress
    for(AsyncApexJob a : [SELECT Id,Status,ApexClass.name, JobItemsProcessed, TotalJobItems
                            FROM AsyncApexJob
                           WHERE ApexClass.Name = 'batchRecalcCommission' AND   JobType='BatchApex' AND 
                                 (Status='Queued' or Status='Preparing' or Status='Processing')]) {
      String msg = 'Commission re-calculatin is in process. ' + a.JobItemsProcessed + 
                   ' out of ' + a.TotalJobItems + ' have been completed.  ' +
                   'Refresh the page to see updates or go to Setup==>Monitor==>Jobs==>Apex Jobs.';
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, msg));
      inProcess = true;
    }
    return null;
  }

  public PageReference recalcComm(){
    //make sure user selected a fiscal year
    if (fy == null || fy == '' ) {
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'You must select a Fiscal Year from the list.'));
      return null;    
    }
    CommissionService cs = new CommissionService();
    String resp = cs.recalculateCommissions(fy,null,null,recreateCommRecords);
    if (resp != 'ok') {
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, resp));
      return null;
    }
    return checkExisting();
  }
}