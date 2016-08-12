trigger UserRecordTrigger on User (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
UserUtilities useru = new Userutilities(trigger.new, trigger.old, trigger.newMap, trigger.oldMap);
                                                           
  if (Trigger.isBefore){
    if (Trigger.isInsert) {  //BEFORE INSERT
    } else if (Trigger.isUpdate) {  //BEFORE UPDATE
        useru.postBirthdayMessage();
        useru.TransferRecords();
    } else if (Trigger.isDelete) {  // BEFORE DELETE
    }
  } else {
    if (Trigger.isInsert) {  // AFTER INSERT
    } else if (Trigger.isUpdate) { // AFTER UPDATE
//useru.postBirthdayMessage();
        
    } else if (Trigger.isDelete) {  // AFTER DELETE
    } else if (Trigger.isUndelete) {  // AFTER UNDELETE
    }
  }
}