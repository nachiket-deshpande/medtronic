@isTest
public class LeadOwnerupdateControllerTest {
    
private static testMethod void UpdateLeadOwner() {    
    
Lead leadtest = new Lead (Company ='Test Company', FirstName= 'Test', LastName = 'Lead Last Name' );
insert leadtest;  
   
test.startTest();
Apexpages.Message msg = new Apexpages.Message(Apexpages.Severity.CONFIRM, 'Changes saved successfully!','');  
           Apexpages.Message error_msg = new Apexpages.Message(Apexpages.Severity.Error, 'An error occurred while saving changes !','');      
User u1 = [SELECT Id, LastName, ProfileId from User WHERE IsActive=true LIMIT 1];    
leadtest.OwnerId = u1.Id;
update leadtest;
leadtest = [select id, OwnerId from Lead where id=:leadtest.id];    
    
system.assertEquals(leadtest.OwnerId, u1.id);
    
test.stopTest();
}
}