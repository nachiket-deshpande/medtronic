@isTest
private class commissionAdminControllerTest {
  static testmethod void test1() {
  	PageReference p = Page.CommissionAdmin;
  	CommissionAdminController cat = new commissionAdminController();
  	cat.getFiscalYears();
  	cat.recalcComm();
  	cat.fy = '2015';
  	cat.recalcComm();
  }
}