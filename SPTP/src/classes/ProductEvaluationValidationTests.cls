@isTest
public class ProductEvaluationValidationTests {

    static testmethod void ProductEvaluationValidationTest(){
    Account a = new Account(Name = 'TestProdEval');
    insert a;
    
    Id contactRecordId = [Select Id from RecordType Where sObjectType = 'Contact' and Name = 'Practicing Physician' limit 1].Id;
    Contact c1 = new Contact (accountid = a.Id, firstName='firstname1', lastname='lastname1');
    c1.recordtypeID =contactRecordId;    
    insert c1;
    Contact c2 = new Contact (accountid = a.Id, firstName='firstname2', lastname='lastname2');
    c2.recordtypeID =contactRecordId;    
    insert c2;
    Contact c3 = new Contact (accountid = a.Id, firstName='firstname3', lastname='lastname3');
    c3.recordtypeID =contactRecordId;    
    insert c3;
    Product_Evaluation__c pe1 = new Product_Evaluation__c(account__c=a.id, Procedure_date__c = system.today(), Physician__c = c1.id);
    insert pe1;    
    Product_Evaluation__c pe2 = new Product_Evaluation__c(account__c=a.id, Procedure_date__c = system.today(), Physician__c = c2.id);
    insert pe2;    
    Product_Evaluation__c pe3 = new Product_Evaluation__c(account__c=a.id, Procedure_date__c = system.today(), Physician__c = c3.id);
    insert pe3;            
 //  Product_Evaluation__c pe4 = new Product_Evaluation__c(account__c=a.id, Procedure_date__c = system.today(), Physician__c = c1.id);    
 //   insert pe4;
    List <Product_evaluation__c> PEresult1= [select id, Account__c, Physician__c from Product_Evaluation__c where Account__c =: a.id and Physician__c =: c1.id];
    List <Product_evaluation__c> PEresult2= [select id, Account__c, Physician__c from Product_Evaluation__c where Account__c =: a.id];    
    System.assertequals(PEresult1.size(),1);  
    System.assertequals(PEresult2.size(),3);     
    }
    
}