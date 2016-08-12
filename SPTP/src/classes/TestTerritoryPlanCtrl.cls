@isTest(seeAlldata=true)
private class TestTerritoryPlanCtrl  {
  static testMethod void testunit() {
      territoryPlanCtrl obj = new territoryPlanCtrl();
      SelectOption s = obj.territoryptions[0];
      obj.selectedTerri  = s.getvalue();
      obj.onSelectTerritory();
      obj.selectedAcc = 'ALL';
      obj.onSelectAccount();
      SelectOption ss = obj.repOptions[0];
      obj.onSelectRep();
      SelectOption ss1 = obj.phyOptions[0];
      obj.onSelectPhysician();
      obj.accountOptions();
      obj.accountOptionsOnRepSelect();
      obj.repOptionsOnAccSelect();
      obj.phyOptionsOnAccSelect();
      obj.applySortingOnPO();
      obj.applySortingOnOPP();
      obj.filterIntervByRep();
      obj.filterIntervByTerritory();
      obj.filterDiagByTerritory();
      obj.filterDiagByRep();
  }
  
  
    
    static testMethod void testdoSortByValue() {
        Selectoption[] opts = new Selectoption[] {
        new Selectoption('v1', 'l1'),
        new Selectoption('v5', 'l1')
        };
        SelectOptionSorter.doSort(opts, FieldToSort.Value);
    }
    
    static testMethod void testdoSortByLabel() {
        Selectoption[] opts = new Selectoption[] {
        new Selectoption('v1', 'l1'),
        new Selectoption('v5', 'l5')
        };
        SelectOptionSorter.doSort(opts, FieldToSort.Label);
   }
   
   static testMethod void testPhysicianValidation() {
       Account acc = new Account(Name = 'Test');
       insert acc;
       Id entRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ENT').getRecordTypeId();
       Contact con = new Contact(LastName = 'Test', AccountId = acc.Id, RecordTypeId = entRecordTypeId);
       insert con;
       Sales_Plan__c sp = new Sales_Plan__c(Account__c = acc.id);
       insert sp;
       Physician_Sales_Goal__c psg = new Physician_Sales_Goal__c(Business_Plan__c = sp.id, Physician__c = con.id);
       insert psg;
       
   }
}