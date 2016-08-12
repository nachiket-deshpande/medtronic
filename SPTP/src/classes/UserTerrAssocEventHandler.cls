public class UserTerrAssocEventHandler {
  public UserTerritory2Association[] newLst = new UserTerritory2Association[]{};
  public UserTerritory2Association[] oldLst = new UserTerritory2Association[]{};
  public Map <ID, UserTerritory2Association> newMap = new Map<ID, UserTerritory2Association>{};
  public Map <ID, UserTerritory2Association> oldMap = new Map<ID, UserTerritory2Association>{};
   
  public UserTerrAssocEventHandler(UserTerritory2Association[] triggered, UserTerritory2Association[] triggeredFrom,
                                   Map<ID,UserTerritory2Association> triggerNewMap, Map<ID,UserTerritory2Association> triggerOldMap){
    newLst = triggered;
    oldLst = triggeredFrom;
    newMap = triggerNewMap;
    oldMap = triggerOldMap;
  }

  public void updateAccountReps(){
    Set<Id> IdsForUpdate = new Set<Id>();
    for (UserTerritory2Association ut2a : newLst) {
      if (ut2a.isActive && (ut2a.RoleInTerritory2 =='Rep' || ut2a.RoleInTerritory2 =='Key Account Manager' || ut2a.RoleInTerritory2 =='Clinical Product Specialist' 
                            || ut2a.RoleInTerritory2 =='Inside Sales Rep' || ut2a.RoleInTerritory2 =='Inside Sales PC Rep' ))
        IdsForUpdate.add(ut2a.Id);
    }
    if (!IdsForUpdate.isEmpty())
        updateAccountReps_futurewrapper(IdsForUpdate);
      
  }

  @future
  public static void updateAccountReps_futurewrapper(Set<Id> usrTerr2AssocIDs){
    accountRepsUpdate(usrTerr2AssocIDs);
  }

  public static void accountRepsUpdate(Set<Id> usrTerr2AssocIDs) {
    
    Map<String,Id> territory2RepMap = new Map<String,Id>();
    Map<String, Id> terrID2RepIdMap = new Map<String,Id>();
    for (UserTerritory2Association ut2a : [SELECT Territory2.Name, Territory2Id,UserId 
                                             FROM UserTerritory2Association 
                                            WHERE Id in :usrTerr2AssocIDs]) {
      territory2RepMap.put(ut2a.Territory2.Name,ut2a.UserId);
      terrID2RepIdMap.put(ut2a.Territory2Id, ut2a.UserId);
    }
    Account [] acctLst = [SELECT Id, Capital_rep__c, Capital_Territory__c,Diagnostic_Rep__c,
                                 Diagnostic_Territory__c, Interventional_Rep__c,Interventional_Territory__c,
                          		Diagnostic_Inside_Sales_Territory__c, Diagnostic_Inside_Sales_Rep__c, Inside_Sales_Territory__c, Inside_Sales_Rep__c, 
							CEC_Territory__c, CPS_Rep__c, Key_Accounts_Territory__c, Key_Accounts_Rep__c
                          
                          FROM Account
                          WHERE Capital_Territory__c in :territory2RepMap.keyset() OR
                                Diagnostic_Territory__c in :territory2RepMap.keyset() OR
                                Interventional_Territory__c in :territory2RepMap.keyset() OR
                          		Diagnostic_Inside_Sales_Territory__c in :territory2RepMap.keyset() OR
                          		Inside_Sales_Territory__c in :territory2RepMap.keyset() OR
                          		CEC_Territory__c in :territory2RepMap.keyset() OR
                          		Key_Accounts_Territory__c in :territory2RepMap.keyset()];
    if (!acctLst.isEmpty()) {
      for (Account a : acctLst) {
        Id dRep = territory2RepMap.get(a.Diagnostic_Territory__c);
        Id cRep = territory2RepMap.get(a.Capital_Territory__c);
        Id iRep = territory2RepMap.get(a.Interventional_Territory__c);
        Id disRep = territory2RepMap.get(a.Diagnostic_Inside_Sales_Territory__c);
        Id isRep = territory2RepMap.get(a.Inside_Sales_Territory__c);
        Id cpsRep = territory2RepMap.get(a.CEC_Territory__c);
        Id kRep = territory2RepMap.get(a.Key_Accounts_Territory__c);
            
        if(dRep != null )
          a.Diagnostic_Rep__c =  dRep;
        if(cRep != null)
          a.Capital_Rep__c = cRep;
        if(iRep != null)
          a.Interventional_Rep__c = iRep;
        if(disRep != null)
          a.Diagnostic_Inside_Sales_Rep__c = disRep;
        if(isRep != null)
          a.Inside_Sales_Rep__c = isRep;
        if(cpsRep != null)
          a.CPS_Rep__c = cpsRep;
        if(kRep != null)
          a.Key_Accounts_Rep__c = kRep;
   
      }
      update acctLst;
    }
    //also update commission  and quota records
    Commission__c [] commLst = [SELECT ID,TerritoryID__c,SalesRep__c,OwnerId 
                                  FROM Commission__c 
                                 WHERE TerritoryID__c in :terrID2RepIdMap.keyset()];
    for(Commission__c c : commLst){
      Id repId = terrID2RepIdMap.get(c.TerritoryID__c);
      c.SalesRep__c = repId;
      c.OwnerId = repId;
    }
    update commLst;
    MonthlyQuota__c [] mqLst = [SELECT Id, SalesRep__c, OwnerId, TerritoryID__c
                                  FROM MonthlyQuota__c 
                                 WHERE TerritoryID__c in :terrID2RepIdMap.keyset()];
    for (MonthlyQuota__c mq : mqLst) {
      Id repId = terrID2RepIdMap.get(mq.TerritoryID__c);
      mq.SalesRep__c = repId;
      mq.OwnerId = repId;
    }
    update mqLst;
  } 
}