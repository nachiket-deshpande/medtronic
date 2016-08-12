/**
  Test case for the component controller
  @author Antenna
  This test case is on v24 of API, so no dependency on org data.
*/
@isTest
private class OppAccountRolesCompTest {
  
  /**
    As functionality is trivial we are testing it all(positive+negative) in single test case 
  */
    static testMethod void testItAll() {
      //
      // Create SEED data
      //
      Account acc1 = new Account(Name ='Acc1');
      Account acc2 = new Account(Name ='Acc2');
    insert new Account[] {acc1, acc2};
    
      Opportunity opp1 = new Opportunity(Name ='Opp1', CloseDate = System.today().addDays(10), StageName ='Needs Analysis');
      Opportunity opp2 = new Opportunity(Name ='Opp2', CloseDate = System.today().addDays(20), StageName = 'Qualification');
      insert new Opportunity[] {opp1, opp2};
      
      //Contact anjan = new Contact(FirstName = 'Anjan', LastName = 'J');
      //insert anjan;
      
      //
      // Negative Test : No contact roles in place either for Account or Opp, the code shouldn't crash
      //
      OppAccountRolesCompController cont = new OppAccountRolesCompController();
      //cont.contactId = anjan.id;
      
      AccountContactRole[] accRoles = cont.getAccountRoles();
      // Nothing should come back
      System.assert(accRoles == null || accRoles.isEmpty());
      
      OpportunityContactRole[] oppRoles = cont.getOpportunityRoles();
      // Nothing should come back
      System.assert(oppRoles == null || oppRoles.isEmpty());
      
      //
      // Positive Tests : Lets create some roles for both Account and Opp, and then assert
      //
      /*AccountContactRole anjanAcc1Role = new AccountContactRole(AccountId = acc1.Id, ContactId = anjan.Id, 
                                    Role = 'Executive Sponsor', IsPrimary = true );
      AccountContactRole anjanAcc2Role = new AccountContactRole(AccountId = acc2.Id, ContactId = anjan.Id, 
                                    Role = 'Decision Maker', IsPrimary = false );
      insert new AccountContactRole [] {anjanAcc1Role, anjanAcc2Role};
      
      OpportunityContactRole anjanOpp1Role = new OpportunityContactRole(OpportunityId = opp1.Id, ContactId = anjan.Id, 
                                    Role = 'Executive Sponsor', IsPrimary = true );
      OpportunityContactRole anjanOpp2Role = new OpportunityContactRole(OpportunityId = opp2.Id, ContactId = anjan.Id, 
                                    Role = 'Decision Maker', IsPrimary = false );
      insert new OpportunityContactRole [] {anjanOpp1Role, anjanOpp2Role};
      
      // Create new instance of controller and test it all again
      cont = new OppAccountRolesCompController();
      cont.contactId = anjan.id;
      
      accRoles = cont.getAccountRoles();
      // 2 account roles should comeback 
      System.assertEquals(2, accRoles.size());
      
      oppRoles = cont.getOpportunityRoles();
      // 2 opp roles should comeback
      System.assertEquals(2, oppRoles.size());*/
      
    }
}