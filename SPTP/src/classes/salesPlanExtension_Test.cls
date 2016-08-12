@isTest
private class salesPlanExtension_Test {
  static testmethod void test1() {
    //create account
    Account a = new Account(Name='test29may2016',SAP_Account_Name__c='test29may2016');
    insert a;
    //create opp
    Opportunity o = new Opportunity(AccountID=A.Id,CloseDate=date.newInstance(2016,02,27),name='test',stagename='teststage');
    insert o;
    //create activity
    Id eID = [SELECT Id FROM RecordType WHERE sObjectType = 'Event' and DeveloperName = 'Account_Development'].Id;
    system.debug('--'+eId);
    Event e = new Event(WhatID=a.Id,RecordTypeId=eID,StartDateTime=dateTime.newInstance(2016, 2, 27, 12, 30, 0),DurationInMinutes=60);
    insert e;
    //create sales plan
    Sales_Plan__c sp = new Sales_Plan__c(Name='test29may2016SP',Account__c=a.id,FQ_Start_Date__c=date.newInstance(2016,03,31),FQ_End_Date__c=date.newInstance(2016,01,01));
    insert sp;
    //create physician objectives
    Physician_Sales_Goal__c [] psgLst = new List<Physician_Sales_Goal__c>();
    Physician_Sales_Goal__c pcPSG = new Physician_Sales_Goal__c(Business_Plan__c=sp.Id,Objective_Type__c='PillCam Unit Growth');
    psgLst.add(pcPSG);
    Physician_Sales_Goal__c spPSG = new Physician_Sales_Goal__c(Business_Plan__c=sp.Id,Objective_Type__c='SmartPill');
    psgLst.add(spPSG);
    Physician_Sales_Goal__c rfPSG = new Physician_Sales_Goal__c(Business_Plan__c=sp.Id,Objective_Type__c='RFA Unit Growth');
    psgLst.add(rfPSG);
    Physician_Sales_Goal__c rxPSG = new Physician_Sales_Goal__c(Business_Plan__c=sp.Id,Objective_Type__c='Reflux Unit Growth');
    psgLst.add(rxPSG);
    Physician_Sales_Goal__c bePSG = new Physician_Sales_Goal__c(Business_Plan__c=sp.Id,Objective_Type__c='Beacon');
    psgLst.add(bePSG);
    insert psgLst;
   ApexPages.currentPage().getParameters().put('id',sp.id);
    ApexPages.StandardController stdSP = new ApexPages.StandardController(sp);
    salesPlanExtension spe = new salesPlanExtension(stdSP);
    spe.addObjective();
    spe.addEvent();
    spe.addContact();
    spe.addOpportunity();
  }
}