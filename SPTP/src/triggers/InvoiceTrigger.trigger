/*
Created: 17 June 2013
Author:  Max Rudman
Purpose: 

Modified: 5 Nov 2014
Author: Appirio - Ben Lorenz
Purpose: refactored to single event handler pattern, added new method call before insert
*/
	
trigger InvoiceTrigger on Invoice2__c (after delete, after insert, after undelete, after update,
                                       before delete, before insert, before update) {

  InvoiceUtilities invUtilEventHandler = new InvoiceUtilities(Trigger.new,Trigger.old,trigger.newMap,trigger.oldMap);

  if (Trigger.isInsert){
    if (Trigger.isBefore) { //BEFORE INSERT
      invUtilEventHandler.setInvoiceFiscalDate();
    } else {  //AFTER INSERT
    }
  } else if (Trigger.isUpdate) {
    if (Trigger.isBefore) { //BEFORE UPDATE
      invUtilEventHandler.setInvoiceFiscalDate();
      invUtilEventHandler.sendChatterNotificationforInvoice();  
    } else { //AFTER UPDATE
    }
  } else if (Trigger.isDelete) {
    if (Trigger.isBefore) { //BEFORE DELETE
    } else { //AFTER DELETE
    }
  } else if (Trigger.isUndelete) { // UNDELETE
  }
}