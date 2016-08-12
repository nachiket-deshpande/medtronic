@isTest
private class TestContactLeadController{
    static testmethod void unitTest(){
       
       Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
       
       User u = new User(Alias = 'testuser', Email= 'test1user1@testuser.com',
                         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',  
                         LocaleSidKey='en_US', ProfileId = p.Id,
                         TimeZoneSidKey='America/Los_Angeles', UserName='test1user1@testuser.com');
       //insert u;
       
       User u1 = new User(Alias = 'standt1', Email='standard1user1@testorg.com',
                         EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',  
                         LocaleSidKey='en_US', ProfileId = p.Id,
                         TimeZoneSidKey='America/Los_Angeles', UserName='standard1user1@testorg.com');
       //insert u1;
                         
       User u2 = new User(Alias = 'standt2', Email='standard2user2@testorg.com',
                         EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',  
                         LocaleSidKey='en_US', ProfileId = p.Id,
                         TimeZoneSidKey='America/Los_Angeles', UserName='standard2user2@testorg.com');
       //insert u2;
                         
       User u3 = new User(Alias = 'standt3', Email='standard3user3@testorg.com',
                         EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US',  
                         LocaleSidKey='en_US', ProfileId = p.Id,
                         TimeZoneSidKey='America/Los_Angeles', UserName='standard3user3@testorg.com');
       //insert u3;
       
       List<User> userList = new List<User>();
       userList.add(u);
       userList.add(u1);
       userList.add(u2);
       userList.add(u3);
       insert userList;
       
       Account acc = new Account(Name = 'Test Acc', Account_Number__c = 'asdf', Inside_Sales_Rep__c = u.Id);
       //insert acc;
       
       Account hospital = new Account(Name = 'Hospital', Account_Number__c = 'qwert', Inside_Sales_Rep__c = u1.Id);
       //insert hospital;
       
       Account hospital2 = new Account(Name = 'Hospital2', Account_Number__c = 'lmnop', Inside_Sales_Rep__c = u2.Id);
       //insert hospital2;
       
       Account hospital3 = new Account(Name = 'Hospital3', Account_Number__c = 'zxcv', Inside_Sales_Rep__c = u3.Id);
       //insert hospital3;
       
       List<Account> accList = new List<Account>();
       accList.add(acc);
       accList.add(hospital);
       accList.add(hospital2);
       accList.add(hospital3);
       insert accList;
       
       Id recTypeId = [ Select Id From RecordType Where SObjectType = 'Contact' And Name = 'Practicing Physician' Limit 1][0].Id;
       Contact con = new Contact( AccountId = acc.Id, Hospital__c = hospital.Id, Hospital_2__c = hospital2.Id, Hospital_3__c = hospital3.Id,
                                   firstname = 'Test', lastname = 'Contact', phone = '4556789045', email = 'contact@test.com', 
                                   mailingstreet = 'Street 1',mailingcity = 'San Francisco', mailingstate = 'California', 
                                   mailingCountry = 'USA', mailingpostalcode = '2345677', RecordTypeId = recTypeId);
       insert con;
       
       ApexPages.StandardController controller = new ApexPages.StandardController (con);
       ContactLeadController ctrl = new ContactLeadController(controller);
       ctrl.l.Existing_Account_Name__c = hospital.Id;
       ctrl.selectedSalesOpportunity = 'Reflux';
       ctrl.selectedProdPortfolio = 'Accessories';
       Boolean var = ctrl.isSF1;
       ctrl.onSave();
       ctrl.cancel();
       
    }
}