/*
Created: 21 June 2013
Author:  Max Rudman
Purpose: 

Modified: 5 Nov 2014
Author: Appirio - Ben Lorenz
Purpose: added new test for zip lookup method, uncommented existing asserts
*/

@isTest(SeeAllData=true)
private class InvoiceUtilitiesTests {


  static testMethod void testSetInvoiceFiscalDate() {
   	Invoice2__c invoice = new Invoice2__c(Name = '1234', Key__c = 'abcd', InvoiceDate__c = Date.today());
   	insert invoice;
    	
    	/*invoice = [SELECT Fiscal_Period__c, Fiscal_Year__c from Invoice2__c where Id = :invoice.Id];
    	
    	System.assertNotEquals(null, invoice.Fiscal_Period__c);
    	System.assertNotEquals(null, invoice.Fiscal_Year__c);*/
  }
    
  static testMethod void testSetInvoiceFiscalDateNull() {
  	Invoice2__c invoice = new Invoice2__c(Name = '1234', Key__c = 'abcd');
   	insert invoice;
    	
    	/*invoice = [SELECT Fiscal_Period__c, Fiscal_Year__c from Invoice2__c where Id = :invoice.Id];
    	
    	System.assertEquals(null, invoice.Fiscal_Period__c);
    	System.assertEquals(null, invoice.Fiscal_Year__c);*/
  }
    
   static testMethod void testsendChatterNotificationforInvoice() {
       
       Account account = new Account(Name = 'test24567');
        insert account;
        
        Invoice2__c invoice = new Invoice2__c(Name = 'InvTestChatter',BillTo__c = account.Id, Key__c = 'InvTestChatter', InvoiceDate__c=system.today(), Send_notification__c = False);
        insert invoice;
        User salesRep = [select id, Name from User where isactive = True and profile.name = 'Sales' limit 1];
       
        InvoiceLine__c invoiceLine = new InvoiceLine__c(Invoice__c = invoice.Id, ItemNumber__c = '1190A-230A', Key__c = 'InvLineChatter_1', quantity__c =1, UnitPrice__c = 85000, ItemDescription1__c = 'Test IL w Gen', SalesRep__c = salesrep.id  );
        insert invoiceLine;

		invoice.Send_Notification__c = True;
		update invoice;

        ConnectApi.FeedElementPage testPage = new ConnectApi.FeedElementPage();
        List<ConnectApi.FeedItem> testItemList = new List<ConnectApi.FeedItem>();
        testItemList.add(new ConnectApi.FeedItem());
        testItemList.add(new ConnectApi.FeedItem());
        testPage.elements = testItemList;
        
        // Set the test data
        ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(null, ConnectApi.FeedType.News, invoice.id, testPage);

        ConnectApi.FeedElementPage e = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(null, ConnectApi.FeedType.News, invoice.id);
 
        System.assertEquals(2, e.elements.size()); 
       

     // system.assertNotEquals(0, 1);
  }  

}