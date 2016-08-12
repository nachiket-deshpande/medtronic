public class AccountEventHandler {
  public Account[] newLst = new Account[]{};
  public Account[] oldLst = new Account[]{};
  public Map <ID, Account> newMap = new Map<ID, Account>{};
  public Map <ID, Account> oldMap = new Map<ID, Account>{};
   
  public AccountEventHandler(Account[] triggered, Account[] triggeredFrom,
                             Map<ID,Account> triggerNewMap, Map<ID,Account> triggerOldMap){
    newLst = triggered;
    oldLst = triggeredFrom;
    newMap = triggerNewMap;
    oldMap = triggerOldMap;
  }

  public void actionPlanBatchDelete() {
    set<ID>             aIds    = new set<ID>();
    List<String>        apIds   = new List<String>();
    List<ActionPlan__c> deletePermantently_apIds= new List<ActionPlan__c>();
    //Delete related action plans
    for( Account a : oldLst ){aIds.add( a.Id );}
    /* GET Action Plans to delete from recycle bin */
    deletePermantently_apIds = [SELECT Id, Name , LastModifiedDate 
                                FROM ActionPlan__c 
                                WHERE Account__c in : aIds and isDeleted = true ALL ROWS ];
    if ( deletePermantently_apIds.size() >0 ){Database.emptyRecycleBin(deletePermantently_apIds);}
    //Get all action plans associated with Accounts
    for( Account a : [SELECT (SELECT Id , isDeleted FROM Action_Plans__r) FROM Account a WHERE Id in : aIds]){
      if (a.Action_Plans__r.size() >0 ){
        for(ActionPlan__c ap :a.Action_Plans__r ){                  
          apIds.add(ap.Id);
        }
      }
    }
    if ( apIds.size() >0 ){     
      ActionPlansBatchDelete aPBatch = new ActionPlansBatchDelete(apIds, Userinfo.getUserId());
      Database.ExecuteBatch( aPBatch );
    }
  }

  public void actionPlanUndelete(){
    set<ID>       aIds  = new set<ID>();
    //Undelete related action plans
    Database.UndeleteResult[] unDel_errors;
    for( Account a : newLst){aIds.add( a.Id );}
    list <ActionPlan__c> aPs = [SELECT Id, Name , LastModifiedDate 
                                FROM ActionPlan__c 
                                WHERE Account__c in : aIds and isDeleted = true ALL ROWS ];
    try{
      if(ActionPlanObjectTriggerTest.isTest){
        //throw dmlException
        insert new Contact();   
      }
      unDel_errors =Database.undelete( aPs,false);
    } catch ( Dmlexception e ){             
      for (Account a: newLst){
        a.addError('You can not undelete an action plan whose related object is deleted.');
      }
    }
  }

  public void changeTerritory(){
    Map<String,Id> territory2RepMap = new Map<String,Id>();
    for (UserTerritory2Association ut2a : [SELECT Territory2.Name, UserId FROM UserTerritory2Association WHERE isActive=true and (RoleInTerritory2 ='Rep' or RoleInTerritory2 ='Key Account Manager' 
     or RoleInTerritory2 ='Clinical Product Specialist' or RoleInTerritory2 ='Inside Sales Rep' or RoleInTerritory2 ='Inside Sales PC Rep')]) {
        territory2RepMap.put(ut2a.Territory2.Name,ut2a.UserId);
    }
    for( Account account : newLst ) {
      account.Diagnostic_Rep__c =  territory2RepMap.get(account.Diagnostic_Territory__c);
      account.Interventional_Rep__c =  territory2RepMap.get(account.Interventional_Territory__c);
      account.Capital_Rep__c = territory2RepMap.get(account.Capital_Territory__c);
      account.Diagnostic_Inside_Sales_Rep__c = territory2RepMap.get(account.Diagnostic_Inside_Sales_Territory__c);
      account.Inside_Sales_Rep__c = territory2RepMap.get(account.Inside_Sales_Territory__c);
      account.CPS_Rep__c = territory2RepMap.get(account.CEC_Territory__c);
      account.Key_Accounts_Rep__c = territory2RepMap.get(account.Key_Accounts_Territory__c);  

    }
  } 
}