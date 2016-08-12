trigger ProductEvaluationValidation on Product_Evaluation__c (before insert, before update) {
Set <ID> accountIDs = new Set <ID>();
Set <id> contactIDs = new Set <id>();
     for (Product_Evaluation__c pe:trigger.new)   {
           accountIDs.add(pe.account__c);
           contactIDs.add(pe.physician__c);
        }
List <Product_Evaluation__c> ProdEval = [select id, Account__c, Physician__c from Product_Evaluation__c where Account__c in: accountIDs or Physician__c in:contactIDs];
for (integer i=0; i < trigger.new.size(); i++)  {    
 Integer aflag = 0;
 Integer cflag = 0;
    for (Product_Evaluation__c p:ProdEval){
        if (p.account__c == trigger.new[i].account__c) {aflag+=1;}
        if (p.physician__c == trigger.new[i].physician__c) {cflag+=1;}    
    }
    if ((aflag > 8)&& (Trigger.isInsert)) {
        trigger.new[i].Account__c.addError ('Sorry! There are already three ingestions recorded for this account.');
    }
    if ((cflag > 0) && (((Trigger.isUpdate) && (trigger.new[i].Physician__c != trigger.old[i].Physician__c)) || (Trigger.isInsert)))  {
        trigger.new[i].Physician__c.addError ('Sorry! There is already an ingestion recorded for this Physician.');
    }
}
}