/*
Created: 7 Nov 2014
Author:  Appirio - Ben Lorenz
Purpose: Utility methods to be used in apex unit tests.

*/

public class TestUtils {
  public TestUtils() {
    //can only be used in test context otherwise we throw an exception
    if(!Test.isRunningTest())
      throw new TestUtilsClassUsedInNonTestContextException ('This class cannot be instantiated or used from a non-Test context!'); 
  }

  //custom exceptoin class for the constructor
  class TestUtilsClassUsedInNonTestContextException extends Exception {}

  //This method returns an invoice with the required fields
  public Invoice2__c createInvoice(String invName, String invKey) {
    return new Invoice2__c(Name = invName, key__c = invKey);
  }

  //This method returns a Zip/Seller Lookup record with the required fields
  public Zipcode_Seller_Lookup__c createZipSellerLookup(String zip) {
    return new Zipcode_Seller_Lookup__c(Name=zip,ZipExternalID__c=zip);
  }

  //This method retursn an account with the required fields
  public Account createAccount(String name) {
    return new Account(Name=name);
  }

  //This method returns an Invoice Line with the required fields
  public InvoiceLine__c createInvoiceLine(Id invID, String itemNum, String itemType, String key) {
    return new InvoiceLine__c(Invoice__c = invID, ItemNumber__c = itemNum, Line_Type__c = itemType, Key__c = key);
  }

  //This method returns a Product with required fields
  public Product2 createProduct(String pg, String sh, String n, String pc){
    Product2 p = new Product2();
    p.Commissionable__c = true;
    p.Product_Group__c = pg;
    p.Sales_Hierarchy__c = sh;
    p.Name = n;
    p.ProductCode = pc;
    return p;
  }

  //This method returns a Commission with required fields
  public Commission__c createCommission(String key, Date period, Id rep) {
    return new Commission__c(Period__c=period,SalesRep__c=rep,OwnerId=rep,Key__c=key);
  }
}