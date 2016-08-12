@isTest
private class UserTerrAssocEventHandler_Test {
  
  static testMethod void test1() {
  	//create account
  	User me = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
  	System.runAs (me) {
      Id currUsrId = userInfo.getUserId();
  	  TestUtils testUtils = new TestUtils();
  	  UserTerritory2Association t = [SELECT Territory2.Name, UserId, Territory2Id
  	                                   FROM UserTerritory2Association 
  	                                  WHERE isActive=true and 
                                            UserId != :currUsrId and
                                            RoleInTerritory2 ='Rep' limit 1];
    	Account a = testUtils.createAccount('abc123test');
    	a.Capital_Territory__c = t.Territory2.Name;
  	  insert a;
    	Id firstCapRepID = a.Capital_Rep__c;
      //create quota
      MonthlyQuota__c mq = new MonthlyQuota__c();
      mq.Key__c= t.Territory2Id + '_1_2015';
      mq.SalesRep__c=t.UserId;
      mq.OwnerId=t.UserId;
      insert mq;
      //create commission
      Commission__c comm = testUtils.createCommission(t.Territory2Id + '_1_2015', system.today(), t.UserId);
      comm.Quota__c=mq.Id;
      insert comm;
  	  //insert a new user for the terr
    	test.startTest();     
    	UserTerritory2Association newTerrAssoc = new UserTerritory2Association();
  	  newTerrAssoc.UserId = currUsrId;
    	newTerrAssoc.Territory2Id = t.Territory2Id;
     	insert newTerrAssoc;
   	  newTerrAssoc.RoleInTerritory2 = 'Rep';
  	  update newTerrAssoc;
  	  test.stopTest();
      //validate new user assigned back to the account
    	Account updatedA = [SELECT Id, Capital_Territory__c, Capital_Rep__c FROM Account WHERE Id = :a.Id];
    	system.assert(firstCapRepID != updatedA.Capital_Rep__c);
  	  system.assert(currUsrId == updatedA.Capital_Rep__c);
      //validate new user assigned back to comm
      Commission__c newC = [SELECT ID, SalesRep__c, OwnerId FROM Commission__c WHERE Id = :comm.Id];
      system.assertEquals(currUsrId,newC.SalesRep__c);
      system.assertEquals(currUsrId,newC.OwnerId);
      //validate new user assigned back to quota
      MonthlyQuota__c newMQ = [SELECT ID, SalesRep__c,OwnerId FROM MonthlyQuota__c WHERE Id = :mq.Id];
      system.assertEquals(currUsrId,newMQ.SalesRep__c);
      system.assertEquals(currUsrId,newMQ.OwnerId);
    }
	}
}