@isTest
private class InvoiceChatterNotificationBatch_test {

public static testMethod void testBatch() {
    
   		Account account = new Account(Name = 'test24567');
        insert account;
        
        Invoice2__c invoice = new Invoice2__c(Name = 'InvTestChatter1',BillTo__c = account.Id, Key__c = 'InvTestChatter1', InvoiceDate__c=system.today(), Send_notification__c = False);
        insert invoice;
        User salesRep = [select id, Name from User where isactive = True and profile.name = 'Sales' limit 1];
       
        InvoiceLine__c invoiceLine = new InvoiceLine__c(Invoice__c = invoice.Id, ItemNumber__c = '1190A-230A', Key__c = 'InvLineChatter1_1', quantity__c =1, UnitPrice__c = 85000, ItemDescription1__c = 'Test IL w Gen', SalesRep__c = salesrep.id  );
        insert invoiceLine;
   
   Test.StartTest();
    try {
  InvoiceChatterNotificationBatchSchedule SendNotificationFlag = new InvoiceChatterNotificationBatchSchedule(); 
  SendNotificationFlag.query = 'SELECT ID FROM Invoice2__c WHERE Send_Notification__c = False AND InvoiceDate__c>=: X4daysAgo';

   ID batchprocessid = Database.executeBatch(SendNotificationFlag);  
    } catch (exception e){    
		Boolean expectedExceptionThrown = e.getMessage().contains('already scheduled for execution'); 
	    System.AssertEquals(expectedExceptionThrown, true); 
    }
   Test.StopTest();

Invoice2__c inv = [select id, Send_notification__c from Invoice2__c where id =: invoice.id limit 1];
   System.AssertEquals(inv.Send_notification__c, True);  
   
   }

}