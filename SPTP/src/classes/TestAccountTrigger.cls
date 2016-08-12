/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestAccountTrigger {
  static testMethod void testAccountTerritoryChange() {
    //create account
    TestUtils testUtils = new TestUtils();
    Account a = testUtils.createAccount('8675309test');
    insert a;
    system.assert(a.Capital_Rep__c == null);

    //update territory on account
    UserTerritory2Association t = [SELECT Territory2.Name, UserId, Territory2Id
                                     FROM UserTerritory2Association 
                                    WHERE isActive=true and RoleInTerritory2 ='Rep' limit 1];
    a.Capital_Territory__c = t.Territory2.Name;
    update a;

    //validate rep from terr assigned to account
    Account updatedA = [SELECT Id, Capital_Territory__c, Capital_Rep__c FROM Account WHERE Id = :a.Id];
    system.assert(t.UserId == updatedA.Capital_Rep__c);
  }
}