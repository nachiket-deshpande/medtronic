@isTest
private class scheduleCommissionRecalculationTest {
  static testmethod void test1(){
  	String schedule='0 0 0 3 9 ? 2022';
  	Test.startTest();
  	String jobId = System.schedule('testRecalcComm',schedule, new scheduleCommissionRecalculation());
  	Test.stopTest();
  }
}