@isTest
private class SpeakerBureauUtilitiesTest {

    static testmethod void UpdateSpeakerPictureTest(){
    Account a = new Account(Name = 'test123');
    insert a;
    
    Id contactRecordId = [Select Id from RecordType Where sObjectType = 'Contact' and Name = 'Practicing Physician' limit 1].Id;
    Contact c = new Contact (accountid = a.Id, firstName='firstname', lastname='lastname', Picture__c='TestPictureText');
    c.recordtypeID =contactRecordId;    
    insert c;
    test.startTest();
    Speaker__c s = new Speaker__c(speaker__c = c.id, start_date__c = system.today(), end_date__c = system.today());
    insert s;
	test.stoptest();
    //System.assertEquals(1,Limits.getFutureCalls());    // can't test if value was updated in @future method... 
       
    }
}