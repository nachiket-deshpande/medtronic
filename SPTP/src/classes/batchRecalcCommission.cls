global class batchRecalcCommission implements Database.Batchable<sobject> {
  global final String query;
  global batchRecalcCommission(String q) {query=q;}
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }
  global void execute(Database.BatchableContext BC, List<Invoice2__c> scope) {
    Set<Id> invoiceIDs = new Set<Id>();
    for (Invoice2__c i : scope) {invoiceIDs.add(i.Id);}
    InvoiceLine__c [] invLineLst = [SELECT Id, SalesRep__c, ExtendedPrice__c,isCommissionable__c
                                      FROM InvoiceLine__c
                                     WHERE Invoice__c in :invoiceIDs];
    InvoiceLineEventHandler ileh = new InvoiceLineEventHandler(invLineLst, null, null, null);
    ileh.calculateCommission();
  }
  global void finish(Database.BatchableContext BC) {}
}