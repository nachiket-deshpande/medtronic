/*
  General Purpose class to consolidate business logic for trigger events on Quote
  1 Aug 2015     Ben Lorenz          Created
*/

public class QuoteEventHandler {
  public SBQQ__Quote__c[] newLst = new SBQQ__Quote__c[]{};
  public SBQQ__Quote__c[] oldLst = new SBQQ__Quote__c[]{};
  public Map <ID, SBQQ__Quote__c> newMap = new Map<ID, SBQQ__Quote__c>{};
  public Map <ID, SBQQ__Quote__c> oldMap = new Map<ID, SBQQ__Quote__c>{};

  public QuoteEventHandler(SBQQ__Quote__c[] triggered, SBQQ__Quote__c[] triggeredFrom,
                             Map<ID,SBQQ__Quote__c> triggerNewMap,Map<ID,SBQQ__Quote__c> triggerOldMap){
    newLst = triggered;
    oldLst = triggeredFrom;
    newMap = triggerNewMap;
    oldMap = triggerOldMap;
  }

  public void updateEstimatedFreight() {
    Map<string,Estimated_Freight__c> freightCharges = Estimated_Freight__c.getAll();  
    for (SBQQ__Quote__c q : newLst){
      string weight = string.valueOf(q.Total_Weight__c.round().intValue());
      if(null!= Estimated_Freight__c.getInstance(weight)){
        q.Estimated_Freight__c=Estimated_Freight__c.getInstance(weight).Freight_Charge__c;
      } else {
        q.Estimated_Freight__c=Estimated_Freight__c.getInstance('MINIMUM').Freight_Charge__c;
      }
    }
  }
}