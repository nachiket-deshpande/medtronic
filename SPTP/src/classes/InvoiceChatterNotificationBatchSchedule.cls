global class InvoiceChatterNotificationBatchSchedule implements Database.Batchable<sObject>{
// Call from Execute Anonymous: 
// InvoiceChatterNotificationBatchSchedule SendNotificationFlag = new InvoiceChatterNotificationBatchSchedule(); 
// ID batchprocessid = Database.executeBatch(SendNotificationFlag); 
     
    //String query;    
    Date invToday = system.today();
	DateTime timeNow = System.now(); // Get the time now
	DateTime X5MinutesAgo = timeNow.addMinutes(-5); // Subtract 5 minutes from it
	Date X4daysAgo = invToday.adddays(-4); //only selecting invoices with invoice date up to 4 days behind
    Global String query = 'SELECT ID FROM Invoice2__c WHERE createdDate <:X5MinutesAgo AND Send_Notification__c = False AND InvoiceDate__c>=: X4daysAgo';
    //selecting all invoices created in the last 4 days, up to 5 minutes ago, where a chatter notification was not sent 
    //not selecting invoices created within last 5 minutes to allow for invoice line integration; next batch run should capture these invoices

    global InvoiceChatterNotificationBatchSchedule(){}
   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }
    global void execute(Database.BatchableContext BC, List<sObject> scope)  {
       Set<Id> invoiceIDs = new Set<Id>();
    for (sObject s : scope) {
        Invoice2__c i=(Invoice2__c)s;
        invoiceIDs.add(i.Id);
    }
	List <Invoice2__c> invoices = [select id, Send_Notification__c from Invoice2__c where id in: invoiceIDs and Send_notification__c = False];
        for (Invoice2__c i: invoices)    {
            i.Send_notification__c = True;
        }
     update invoices;  
   }
   global void finish(Database.BatchableContext BC){
       if (!Test.isRunningTest()){ 
       System.scheduleBatch(new InvoiceChatterNotificationBatchSchedule(), 'Invoice - Send Chatter Notification Batch Job', 5);   //here 5 is the time interval before next batch run
       }
   }
}