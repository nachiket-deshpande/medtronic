@IsTest(SeeAllData=true)
private class UserUtilities_Tests {
  /* 
    static testMethod void testpostBirthdayMessage() {
        chatterutilities cu = new chatterutilities();
        User u = [select Id,Send_Birthday_Reminder__c,birthday__c from User where (isactive=true and Userrole.name !='VP of US Sales') limit 1 ];
        u.Send_Birthday_Reminder__c = True;
        u.birthday__c =system.today();
        update u;
        ID vpID = [select Id from User where (isactive=true and Userrole.name ='VP of US Sales') limit 1 ].id;               
        FeedItem f = [select InsertedById from FeedItem where parentid =:u.id];
        User u2 = [select Id,Send_Birthday_Reminder__c,birthday__c from User where id =: u.id]; 
        System.assertEquals (u.Send_Birthday_Reminder__c, False);
        
        //System.assertNotEquals(null, invoice.Fiscal_Period__c);
      
    } */ 
    static testMethod void testTransferRecords() {
        List <User> userids = [select Id from User where isactive=True limit 2];
        account a = new account (name = 'test account 1');    
        a.ownerid= userids[0].id;
        insert a;   
        RecordType rt = [SELECT id,Name FROM RecordType WHERE SobjectType='Contact'and Name='Practicing Physician'];
       
        Contact c = new Contact(firstname ='first', lastname = 'last', accountid = a.id, recordTypeId=rt.id);
        c.ownerid = userids[0].id;
        insert c;
        Opportunity o = new Opportunity(name ='opptest', accountid = a.id, stagename='Presenting', closedate = system.today());
        o.ownerid = userids[0].id;
        insert o;        
        userids[1].Transfer_Ownership_from_This_User_ID__c = userids[0].id;
        update userids;
        Contact c2 = [select Id,ownerid from Contact where id =: c.id];
        Opportunity o2= [select id, ownerid from Opportunity where id =: o.id];
        System.assertEquals (c2.ownerid, userids[1].id);
        System.assertEquals (o2.ownerid, userids[1].id);
        //System.assertNotEquals(null, invoice.Fiscal_Period__c);
    }      
}