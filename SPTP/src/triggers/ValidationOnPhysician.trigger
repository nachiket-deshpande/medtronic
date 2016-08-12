trigger ValidationOnPhysician on Physician_Sales_Goal__c (before insert) {
    
    Set<Id> sPlanIds = new Set<Id>();
    Set<Id> phyIds = new Set<Id>();
    
    for(Physician_Sales_Goal__c phyGoal :trigger.new) {
        sPlanIds.add(phyGoal.Business_Plan__c);
        phyIds.add(phyGoal.Physician__c);
    }
    
    List<Contact> conList = [select AccountId, Hospital__c, Hospital_2__c, Hospital_3__c from Contact where Id in :phyIds];
    
    Map<Id, Set<Id>> conAccMap = new Map<Id, Set<Id>>();
    
    for(Contact con :conList) {
        Set<Id> accIds = new Set<Id>();
        accIds.add(con.AccountId);
        accIds.add(con.Hospital__c);
        accIds.add(con.Hospital_2__c);
        accIds.add(con.Hospital_3__c);
        conAccMap.put(con.Id, accIds);
    }
    
    Map<Id, Sales_Plan__c> salesPlanMap = new Map<Id, Sales_Plan__c>([select Account__c from Sales_Plan__c where id in :sPlanIds]);
    
    for(Physician_Sales_Goal__c phyGoal :trigger.new) {
        if(salesPlanMap != null && salesPlanMap.containsKey(phyGoal.Business_Plan__c)) {
            Id accId = salesPlanMap.get(phyGoal.Business_Plan__c).Account__c;
            if(conAccMap != null && conAccMap.containsKey(phyGoal.Physician__c)) {
                if(!conAccMap.get(phyGoal.Physician__c).contains(accId)) {
                    phyGoal.addError('Selected Physician is not associated with the Sales Plan Account. Please select Physician related to Sales Plan Account.');
                }
            }
        }
    }
}