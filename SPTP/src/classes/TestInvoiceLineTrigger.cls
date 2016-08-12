/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestInvoiceLineTrigger {

    static testMethod void testAccountHaloFlex() {
        Account account = new Account(Name = 'test24567', HALOFlex_Account__c = false);
        insert account;
        
        Invoice2__c invoice = new Invoice2__c(BillTo__c = account.Id, Key__c = 'ioodiidif');
        insert invoice;
        
        InvoiceLine__c invoiceLine = new InvoiceLine__c(Invoice__c = invoice.Id, ItemNumber__c = '1190A-230A', Line_Type__c = 'N', Key__c = 'ioodiidif');
        insert invoiceLine;
        
        account = [SELECT HALOFlex_Account__c from Account where Id = :account.Id];
        System.assertEquals(true, account.HALOFlex_Account__c);
    }
    
    static testMethod void testAccountNoHaloFlex() {

        Account account = new Account(Name = 'test902456', HALOFlex_Account__c = false);
        insert account;
        
        Invoice2__c invoice = new Invoice2__c(BillTo__c = account.Id, Key__c = 'adfdsaff');
        insert invoice;
        
        InvoiceLine__c invoiceLine = new InvoiceLine__c(Invoice__c = invoice.Id, ItemNumber__c = '1190A-230A', Line_Type__c = 'M', Key__c = 'adfdsaff');
        insert invoiceLine;
        
        account = [SELECT HALOFlex_Account__c from Account where Id = :account.Id];
        System.assertEquals(false, account.HALOFlex_Account__c);
    }
    
    Static testMethod void testsetAccountSB3Purchased(){
        Account account = new Account(Name = 'testSB3');
        insert account;
        Invoice2__c invoice = new Invoice2__c(BillTo__c = account.Id, Key__c = 'testSB3Inv');
        insert invoice;
        InvoiceLine__c invoiceLine = new InvoiceLine__c(Invoice__c = invoice.Id, ItemNumber__c = 'FGS-0500', Key__c = 'testSB3Inv_1');
        insert invoiceLine;
        account = [SELECT SB3_Purchased__c from Account where Id = :account.Id];
        System.assertEquals(account.SB3_Purchased__c, True);    
		}
	Static testMethod void testsetAccountDR3Conversion()  {
        Account account = new Account(Name = 'testDR3');
        insert account;
        Invoice2__c invoice = new Invoice2__c(BillTo__c = account.Id, Key__c = 'testDR3Inv');
        insert invoice;
        InvoiceLine__c invoiceLine = new InvoiceLine__c(Invoice__c = invoice.Id, ItemNumber__c = 'FGS-0347', Key__c = 'testDR3Inv_1');
        insert invoiceLine;
        account = [SELECT DR3_Conversion__c from Account where Id = :account.Id];
        System.assertEquals(account.DR3_Conversion__c, True);    
        } 

     Static testMethod void testsetAccountRapidSWPurchased(){
        Account account = new Account(Name = 'testRapid');
        insert account;
        Invoice2__c invoice = new Invoice2__c(BillTo__c = account.Id, Key__c = 'testRapidInv');
        insert invoice;
        InvoiceLine__c invoiceLine = new InvoiceLine__c(Invoice__c = invoice.Id, ItemNumber__c = '80138', Key__c = 'testRapidInv_1');
        insert invoiceLine;
        account = [SELECT Rapid_SW_Purchased__c from Account where Id = :account.Id];
        System.assertEquals(account.Rapid_SW_Purchased__c, True);    
        } 
     Static testMethod void testsetAccountPurchasedBravoRecorderSinceJuly2015(){
        Account account = new Account(Name = 'testBravo');
        insert account;
        Invoice2__c invoice = new Invoice2__c(BillTo__c = account.Id, InvoiceDate__c = date.parse('09/30/2015'), Key__c = 'testBravoInv');
        insert invoice;
        InvoiceLine__c invoiceLine = new InvoiceLine__c(Invoice__c = invoice.Id, ItemNumber__c = 'FGS-0450', Key__c = 'testBravoInv_1');
        insert invoiceLine;
        account = [SELECT Purchased_Bravo_Recorder_since_July2015__c from Account where Id = :account.Id];
        System.assertEquals(account.Purchased_Bravo_Recorder_since_July2015__c, True);    
        } 
    
    static testMethod void testAccountDateGeneratorActivated() {
        Account account = new Account(Name = 'test24564567');
        insert account;
        Invoice2__c invoice = new Invoice2__c(BillTo__c = account.Id, InvoiceDate__c = date.parse('09/01/2015'), Key__c = 'io32343idif');
        insert invoice;
        InvoiceLine__c invoiceLine = new InvoiceLine__c(Invoice__c = invoice.Id, ItemNumber__c = '1190A-115A', UnitPrice__c =75000, Quantity__c=1, Key__c = 'ioo544diidif');
        insert invoiceLine;
        account = [SELECT Date_Activated__c from Account where Id = :account.Id];
        System.assertEquals(date.parse('09/01/2015'), account.Date_Activated__c);
    }
       
    static testMethod void testAccountBeaconAccountAsOf() {
        Account account = new Account(Name = 'test67');
        insert account;
        Invoice2__c invoice = new Invoice2__c(BillTo__c = account.Id, InvoiceDate__c = date.parse('09/01/2015'), Key__c = 'io3232if');
        insert invoice;
        Product2 p = new Product2();
        p.name = 'testproduct';
	    p.Commissionable__c = true;
    	p.Product_Group__c = 'Beacon Disposables';
    	p.Sales_Hierarchy__c = 'Interventional';
    	p.ProductCode = 'test2';
        insert p;
        InvoiceLine__c invoiceLine = new InvoiceLine__c(Invoice__c = invoice.Id, Product__c= p.id, Key__c = 'ioo54idif');
        insert invoiceLine;
        
        account = [SELECT Beacon_Account_As_Of__c from Account where Id = :account.Id];
        System.assertEquals(date.parse('09/01/2015'), account.Beacon_Account_As_Of__c);
    }
    
}