/**
 * Test suite for commission calculations.
 * 
 * @author Max Rudman
 * @since 1/31/2009
 */
@isTest
private class CommissionCalculatorTests {
  static testMethod void testBatchRecalc() {
    TestUtils t = new TestUtils();
    //get fiscal period and dates for testing
    Period p = [SELECT Number,EndDate, FiscalYearSettings.Name FROM Period WHERE Type = 'Month' LIMIT 1];
    Date invDate = p.EndDate - 1;
    //get rep and territor
    UserTerritory2Association capTerr;
    UserTerritory2Association intTerr;
    UserTerritory2Association diagTerr;
    for (UserTerritory2Association ut : [SELECT Territory2Id,Territory2.Name,UserId,Territory2.Territory2Type.DeveloperName
                                           FROM UserTerritory2Association 
                                          WHERE Territory2.Territory2Type.DeveloperName in ('Interventional','Diagnostic','Capital')  and 
                                                isactive=true and 
                                                RoleInTerritory2 ='Rep']){
      if (capTerr != null && intTerr != null && diagTerr != null)
        break;
      if (ut.Territory2.Territory2Type.DeveloperName == 'Interventional')
        intTerr = ut;
      if (ut.Territory2.Territory2Type.DeveloperName == 'Capital')
        capTerr = ut;
      if (ut.Territory2.Territory2Type.DeveloperName == 'Diagnostic')
        diagTerr = ut;
    }
    //create commission records
    Commission__c [] commLst = new List<Commission__c>();
    Commission__c capc = t.createCommission(capTerr.Territory2Id + '_' + p.Number + '_' + p.FiscalYearSettings.Name, p.EndDate, capTerr.UserId);
    commLst.add(capc);
    Commission__c intc = t.createCommission(intTerr.Territory2Id + '_' + p.Number + '_' + p.FiscalYearSettings.Name, p.EndDate, intTerr.UserId);
    commLst.add(intc);
    Commission__c diagc = t.createCommission(diagTerr.Territory2Id + '_' + p.Number + '_' + p.FiscalYearSettings.Name, p.EndDate, diagTerr.UserId);
    commLst.add(diagc);
    insert commLst;
    //create account
    Account a = t.createAccount('test8675309');
    a.Capital_Territory__c = capTerr.Territory2.Name;
    a.Capital_Rep__c = capTerr.UserId;
    a.Interventional_Territory__c = intTerr.Territory2.Name;
    a.Interventional_Rep__c = intTerr.UserId;
    a.Diagnostic_Territory__c = diagTerr.Territory2.Name;
    a.Diagnostic_Rep__c = diagTerr.UserId;
    insert a;
    //create invoice
    Invoice2__c i = t.createInvoice('INV8675309','ioodiidif');
    i.billto__c = a.id;
    i.InvoiceDate__c = invDate;
    insert i;
    //create products
    Product2 [] p2Lst = new List<Product2>();
    Product2 p1 = t.createProduct('Barrx Capital','Capital','P1', 'P1');
    p2Lst.add(p1);
    Product2 p2 = t.createProduct('Manometry Capital','Capital','P2', 'P2');
    p2Lst.add(p2);
    Product2 p3 = t.createProduct('Manometry Disposables','Capital','P3', 'P3');
    p2Lst.add(p3);
    Product2 p4 = t.createProduct('Reflux Capital','Interventional','P4', 'P4');
    p2Lst.add(p4);
    Product2 p5 = t.createProduct('Reflux Disposables','Interventional','P5', 'P5');
    p2Lst.add(p5);
    Product2 p6 = t.createProduct('Barrx Disposables','Interventional','P6', 'P6');
    p2Lst.add(p6);
    Product2 p7 = t.createProduct('Beacon Disposables','Interventional','P7', 'P7');
    p2Lst.add(p7);
    Product2 p8 = t.createProduct('PillCam Capital','Diagnostic','P8', 'P8');
    p2Lst.add(p8);
    Product2 p9 = t.createProduct('PillCam Disposables','Diagnostic','P9', 'P9');
    p2Lst.add(p9);
    Product2 p10 = t.createProduct('SmartPill Disposables','Diagnostic','P10', 'P10');
    p2Lst.add(p10);
    Product2 p11 = t.createProduct('SmartPill Capital','Diagnostic','P11', 'P11');
    p2Lst.add(p11);
    insert p2Lst;
    //create invoice lines
    InvoiceLine__c [] invLst = new List<InvoiceLine__c>();
    integer pKey = 1;
    for (Product2 prod : p2Lst) {
      InvoiceLine__c il = t.createInvoiceLine(i.Id,prod.Name,prod.ProductCode, 'screenflu_' + string.ValueOf(pKey));
      il.Product__c = prod.Id;
      il.SalesRep__c = capTerr.UserId;
      il.UnitPrice__c = 1;
      il.Quantity__c = 1;
      invLst.add(il);
      pKey++;
    }
    insert invLst;
    /* tests! */
    Commission__c [] updatedCommLst = [SELECT TerritoryID__c,CommissionedSales__c, Seller_Type__c FROM Commission__c];
    //there should only be 3 comm records
    //system.assertEquals(3,updatedCommLst.size());
    //each rep should have 4
    for(Commission__c uc: updatedCommLst) {
        System.debug('>>>>>per: '+ p.number +'com:  '+uc);
        if (uc.Seller_Type__c=='Capital') 
        system.assertEquals(uc.CommissionedSales__c,3);
        else system.assertEquals(uc.CommissionedSales__c,4);
    }
        
    //call the batch class
    Test.startTest();
    Integer fyInt = integer.valueOf(p.FiscalYearSettings.Name);
    batchRecalcCommission brc = new batchRecalcCommission('SELECT Id FROM Invoice2__c WHERE FY__c = ' + fyInt); 
    database.executebatch(brc,1);
    Test.stopTest();
  }
}