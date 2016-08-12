@isTest (seeAllData=true)
public class Gizmo_InboundEmailHandler_Test {
	
    static testMethod void testC2EmailService() {
		// Create a new email, envelope object and Attachment
       	Messaging.InboundEmail email = new Messaging.InboundEmail();
       	Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.fromAddress = 'c2testfrom@covidien.com';
        email.toAddresses = new List<String>{'c2testto@covidien.com'};
        email.ccAddresses = new List<String>{'c2testcc@covidien.com','c2testcc@covidien.com<cttest@covidien.com>'};
        env.fromAddress = 'c2testfrom@covidien.com';
   
        // call the class and test it with the data in the testMethod
        Gizmo_InboundEmailHandler emailServiceObj = new Gizmo_InboundEmailHandler();
        emailServiceObj.handleInboundEmail(email, env ); 
        
        Profile profile1 = [Select Id from Profile where name = 'System Administrator' limit 1];
        User seller = new User(
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'test2@test.com',
            Country='US',
            Alias = 'abune',
            Email='c2testfrom@covidien.com',
            EmailEncodingKey='UTF-8',
            Firstname='C2',
            Lastname='Test',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago');
        emailServiceObj.handleInboundEmail(email, env ); 
		insert seller;
        emailServiceObj.handleInboundEmail(email, env ); 
                
        email.subject = 'test';
        email.plainTextBody = 'test';
        Account a = new Account(Name='Test Account');
        insert a;
        Id contactRecordId = [Select Id from RecordType Where sObjectType = 'Contact' and Name = 'Practicing Physician' limit 1].Id;
        Contact con = new Contact(Lastname='test', FirstName='TEST', AccountId=a.Id, Email='c2testto@covidien.com');
        con.recordtypeID =contactRecordId;
        insert con;
        emailServiceObj.handleInboundEmail(email, env ); 
        
        Contact concc = new Contact(Lastname='test', FirstName='TEST', AccountId=a.Id, Email='c2testcc@covidien.com');
        concc.recordtypeID =contactRecordId;
        insert concc;
        emailServiceObj.handleInboundEmail(email, env ); 
    }   
}