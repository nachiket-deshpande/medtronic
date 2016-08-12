global class batchADSForAccountsQTDSch implements Schedulable{ 
  /*
   *  execute the Schedule batch 
   */
  global void execute(SchedulableContext sc) {
     batchCalculateADSForAccountsQTD tb = new batchCalculateADSForAccountsQTD() ;
     if(!Test.isRunningTest())
     Database.executeBatch(tb,1);
  }
}