trigger UserTerritoryAssociationEvents on UserTerritory2Association (before insert, before update, before delete, 
	                                                                 after insert, after update, after delete, after undelete) {
  UserTerrAssocEventHandler utaeh = new UserTerrAssocEventHandler(trigger.new, trigger.old, trigger.newMap, trigger.oldMap);
                                                                     
  if (Trigger.isBefore){
    if (Trigger.isInsert) {  //BEFORE INSERT
    } else if (Trigger.isUpdate) {  //BEFORE UPDATE
    } else if (Trigger.isDelete) {  // BEFORE DELETE
    }
  } else {
    if (Trigger.isInsert) {  // AFTER INSERT
    } else if (Trigger.isUpdate) { // AFTER UPDATE
      utaeh.updateAccountReps();
      AssetUtilities.UpdateRepOnGeneratorAssets(); 
    } else if (Trigger.isDelete) {  // AFTER DELETE
    } else if (Trigger.isUndelete) {  // AFTER UNDELETE
    }
  }
}