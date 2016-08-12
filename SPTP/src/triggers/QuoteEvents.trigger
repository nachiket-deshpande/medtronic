trigger QuoteEvents on SBQQ__Quote__c (before insert, before update, before delete,after insert, after update, after delete, after undelete) {
  QuoteEventHandler qeh = new QuoteEventHandler(trigger.new, trigger.old, trigger.newMap, trigger.oldMap);
  if (Trigger.isBefore){
    if (Trigger.isInsert) {  //BEFORE INSERT
    } else if (Trigger.isUpdate) {  //BEFORE UPDATE
      qeh.updateEstimatedFreight();
    } else if (Trigger.isDelete) {  // BEFORE DELETE
    }
  } else {
    if (Trigger.isInsert) {  // AFTER INSERT
    } else if (Trigger.isUpdate) {  // AFTER UPDATE
    } else if (Trigger.isDelete) {  // AFTER DELETE
    } else if (Trigger.isUndelete) {  // AFTER UNDELETE
    }
  } 
}