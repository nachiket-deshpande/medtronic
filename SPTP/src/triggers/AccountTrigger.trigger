/* 
  (c) 2015 Appirio, Inc.
  Universal Trigger Handler for sObject InvoiceLine__c
  11 May 2012     Rajin Shah          Created
  29 Jun 2015     Ben Lorenz          refactored to handle all trigger events
                                      consolidated all existing triggers to this main handler
                                      added new functionality to set Rep Lookups on Territory Change
*/

trigger AccountTrigger on Account (before insert, before update, before delete, 
                                          after insert, after update, after delete, after undelete) {
  AccountEventHandler aeh = new AccountEventHandler(trigger.new, trigger.old, trigger.newMap, trigger.oldMap);
  if (Trigger.isBefore){
    if (Trigger.isInsert) {  //BEFORE INSERT
      aeh.changeTerritory();
    } else if (Trigger.isUpdate) {  //BEFORE UPDATE
      aeh.changeTerritory();
    } else if (Trigger.isDelete) {  // BEFORE DELETE
      aeh.actionPlanBatchDelete();
    }
  } else {
    if (Trigger.isInsert) {  // AFTER INSERT
    } else if (Trigger.isUpdate) { // AFTER UPDATE
    } else if (Trigger.isDelete) {  // AFTER DELETE
    } else if (Trigger.isUndelete) {  // AFTER UNDELETE
      aeh.actionPlanUndelete();
    }
  }
}