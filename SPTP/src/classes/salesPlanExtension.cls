public with sharing class salesPlanExtension { 
  public List<Physician_Sales_Goal__c> pillCamObjectives {get;set;}
  public List<Physician_Sales_Goal__c> smartPillObjectives {get;set;}
  public List<Physician_Sales_Goal__c> RFAObjectives {get;set;}
  public List<Physician_Sales_Goal__c> refluxObjectives {get;set;}
  public List<Physician_Sales_Goal__c> beaconObjectives {get;set;}
  public List<Opportunity> opps {get;set;}
  public List<Event> activities {get;set;}
  private String salesPlanID;
  private String salesPlanName;
  private String salesPlanAccountID;
  private Id eventAcctDevRTID;
  public String pageTitle {get;set;}
  public Map<String, List<Opportunity>> mapOwnerOpps {get;set;}
  Sales_Plan__c sp;
  
  public salesPlanExtension(ApexPages.StandardController controller) {
    pillCamObjectives = new List<Physician_Sales_Goal__c>();
    smartPillObjectives = new List<Physician_Sales_Goal__c>();
    RFAObjectives = new List<Physician_Sales_Goal__c>();
    refluxObjectives = new List<Physician_Sales_Goal__c>();
    beaconObjectives = new List<Physician_Sales_Goal__c>();
    sp = (Sales_Plan__c)controller.getRecord();
    salesPlanID = sp.Id;
    salesPlanName = sp.Name;
    salesPlanAccountID = sp.Account__c;
    Date CQStartDate = sp.FQ_Start_Date__c;
    Date CQEndDate = sp.FQ_End_Date__c;
    Date oppStartDate = system.today();
    Date oppEndDate = system.today().addMonths(6);
    eventAcctDevRTID = [SELECT Id FROM RecordType WHERE sObjectType = 'Event' and DeveloperName = 'Account_Development'].Id;
    pageTitle = sp.Account__r.Name + ' Sales Plan for ' + CQStartDate.format() + ' to ' + CQEndDate.format();
    String spSOQL = 'SELECT Id,Objective__c, Physician__c, Role__c,Objective_Type__c, Target_Type__c, Next_Steps__c, Stage__c ' +
                      'FROM Physician_Sales_Goal__c ' +
                     'WHERE Business_Plan__c = :salesPlanID and (NOT Target_Focus__c like \'Closed %\') ' +
                  'ORDER BY Physician__c';

    for (Physician_Sales_Goal__c po : database.query(spSOQL)){
      if(po.Objective_Type__c=='PillCam Unit Growth') {
        pillCamObjectives.add(po);
      } else if(po.Objective_Type__c=='SmartPill') {
        smartPillObjectives.add(po);
      } else if(po.Objective_Type__c=='Barrx Unit Growth') {
        RFAObjectives.add(po);
      } else if(po.Objective_Type__c=='Reflux Unit Growth') {
        refluxObjectives.add(po);
      } else if(po.Objective_Type__c=='Beacon') {
        beaconObjectives.add(po);
      }
    }    
    String oSOQL = 'SELECT Id,Type, Name, Amount, StageName, CloseDate, RecordType.Name, RecordTypeId, Owner.Name ' +
                     'FROM Opportunity ' +
                    'WHERE AccountId =:salesPlanAccountID and ' +
                          'CloseDate >= :oppStartDate and ' +
                          'CloseDate <= :oppEndDate' +
                          ' Order by CloseDate';
    opps = database.query(oSOQL);
    String aSOQL = 'SELECT Type,Next_Steps__c,Call_Objective__c,ActivityDate,subject,Id,OwnerId ' +
                     'FROM Event ' +
                    'WHERE WhatID = :salesPlanAccountID and ' +
                          'RecordTypeId = :eventAcctDevRTID and ' +
                          'StartDateTime >= :CQStartDate and ' +
                          'StartDateTime <= :CQEndDate';
    activities = database.query(aSOQL);
    summarizeOppByOwner();
  }
  
   public void summarizeOppByOwner() {
        mapOwnerOpps = new Map<String, List<Opportunity>>();
        for(Opportunity opp :opps) {
            List<Opportunity> oppList = new List<Opportunity>();
            if(mapOwnerOpps != null && mapOwnerOpps.containsKey(opp.Owner.Name)) {
                oppList.addAll(mapOwnerOpps.get(opp.Owner.Name));
            }
            oppList.add(opp);
            mapOwnerOpps.put(opp.Owner.Name, oppList);
        }
        
    }
    
    public static Boolean runningInASandbox() {
      return [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
  
  public PageReference addObjective(){
    Schema.DescribeSObjectResult dsr = Physician_Sales_Goal__c.SObjectType.getDescribe();
    String url = '';
    System.debug('Environment = '+runningInASandbox());
    If(!runningInASandbox()){
        url = '/' + dsr.getKeyPrefix() + '/e?retURL=/' + salesPlanID + '&CF00N400000038Oyu_lkid=' + salesPlanID + '&CF00N400000038Oyu=' + salesPlanName;
    }else{
        url = '/' + dsr.getKeyPrefix() + '/e?retURL=/' + salesPlanID + '&CF00N19000000iL6m_lkid=' + salesPlanID + '&CF00N19000000iL6m=' + salesPlanName;
    }
    return new PageReference(url);  
  }

  public PageReference addContact(){
    Schema.DescribeSObjectResult dsr = Contact.SObjectType.getDescribe();
    String url = '';
    String accountName = this.sp.Account__r.Name;
    //?CF00N40000001tsVe=Faxton+St+Lukes+Hospital+Champlin&CF00N40000001tsVe_lkid=0014000000f3plS&RecordType=012400000009ZZ7&ent=Contact
    url = '/' + dsr.getKeyPrefix() + '/e?retURL=/' + salesPlanID + '&RecordType=012400000009ZZ7&ent=Contact&CF00N40000001tsVe_lkid=' + salesPlanAccountID + '&CF00N40000001tsVe=' + accountName ;
    
    return new PageReference(url);  
  }
  
  public PageReference addOpportunity(){
    Schema.DescribeSObjectResult dsr = Opportunity.SObjectType.getDescribe();
    String url = '';
    String accountName = this.sp.Account__r.Name;
    ///setup/ui/recordtypeselect.jsp?ent=Opportunity
    url = '/' + dsr.getKeyPrefix() + '/e?retURL=/' + salesPlanID + '/setup/ui/recordtypeselect.jsp?ent=Opportunity&accid=' + salesPlanAccountID  ;
    
    return new PageReference(url);  
  }
  

  public PageReference addEvent(){
    Schema.DescribeSObjectResult dsr = Physician_Sales_Goal__c.SObjectType.getDescribe();
    String url = '/00U/e?what_id=' + salesPlanAccountID + '&retURL=/' + salesPlanID + '&RecordType=' + eventAcctDevRTID + '&ent=Event';
    return new PageReference(url);  
  }
}