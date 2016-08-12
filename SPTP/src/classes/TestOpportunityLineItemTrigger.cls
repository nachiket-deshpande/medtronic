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
private class TestOpportunityLineItemTrigger {

    static testMethod void testInsert() {
        Product2 product = new Product2(Name = 'test', Description = 'test description');
		insert product;
		
		Pricebook2 standardPb = [SELECT Id from Pricebook2 where isStandard = true];
		
		PricebookEntry entry = new PricebookEntry(Product2Id = product.Id, UnitPrice = 12.5, Pricebook2Id = standardPb.Id, IsActive = true);
		insert entry;
		
		Opportunity opp = new Opportunity(Name = 'test', CloseDate = Date.today(), StageName = 'Open');
		insert opp;
		
		OpportunityLineItem lineItem = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = entry.Id, Quantity = 1, TotalPrice = 22.00);
		insert lineItem;
		
		lineItem = [SELECT Description from OpportunityLineItem where Id = :lineItem.Id];
		System.assertEquals( product.Description, lineItem.Description);
    }
}