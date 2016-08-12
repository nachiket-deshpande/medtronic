public class InvoiceItemsEmailTemplateController {
  public Id invoiceId {get;set;}
  public List <InvoiceLine__c> getInvoiceLines() {
    InvoiceLine__c [] lst = new List<InvoiceLine__c>();
    lst = [SELECT Quantity__c, ItemDescription1__c, SalesRep__r.Name
             FROM InvoiceLine__c 
            WHERE ExtendedPrice__c > 0 and Invoice__c = :invoiceId];
    return lst;
  }   
}