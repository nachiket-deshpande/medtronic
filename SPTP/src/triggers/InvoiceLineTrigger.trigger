/* 
  (c) 2015 Appirio, Inc.
  Universal Trigger Handler for sObject InvoiceLine__c
  25 Jan 2013     Max Rudman          Created
  15 Jan 2015     Ben Lorenz          refactored to handle all trigger events
                                                      consolidated all existing triggers to this main handler
                                                      added new functionality to normalize line item codes from QAD
*/

trigger InvoiceLineTrigger on InvoiceLine__c (before insert, before update, before delete, 
                                              after insert, after update, after delete, after undelete) {
  InvoiceLineEventHandler ILEH = new InvoiceLineEventHandler(trigger.new, trigger.old, trigger.newMap, trigger.oldMap);
  if (Trigger.isBefore){
    if (Trigger.isInsert) {  //BEFORE INSERT
      ILEH.assignProducts();
    } else if (Trigger.isUpdate) {  //BEFORE UPDATE
      ILEH.assignProducts();
    } else if (Trigger.isDelete) {  // BEFORE DELETE
    }
  } else {
    if (Trigger.isInsert) {  // AFTER INSERT
      ILEH.setAccountHALOFlex();
      ILEH.calculateCommission();
      ILEH.setAccountDateGeneratorActivated();  
      ILEH.setAccountBeaconAccountAsOf();  
      ILEH.setAccountConversion();
      ILEH.setAccountPurchasedBravoRecorderSinceJuly2015();  
    } else if (Trigger.isUpdate) { // AFTER UPDATE
      ILEH.calculateCommission();
      ILEH.setAccountDateGeneratorActivated();    
      ILEH.setAccountBeaconAccountAsOf();  
      ILEH.setAccountConversion(); 
      ILEH.setAccountPurchasedBravoRecorderSinceJuly2015();    
    } else if (Trigger.isDelete) {  // AFTER DELETE
    } else if (Trigger.isUndelete) {  // AFTER UNDELETE
    }
  }
}