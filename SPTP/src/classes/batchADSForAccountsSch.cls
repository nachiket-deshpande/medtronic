global class batchADSForAccountsSch implements Schedulable{ 
  /*
   *  execute the Schedule batch 
   */
  global void execute(SchedulableContext sc) {
     batchCalculateADSForAccounts tb = new batchCalculateADSForAccounts() ;
     Database.executeBatch(tb);
  }
}