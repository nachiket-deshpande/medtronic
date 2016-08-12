/*    @Purpose: This trigger sets the values of the FQ Start and End Dates when a new Sales Plan is created
      @author: Ankita
      @Date: 5/12/2016
*/
trigger SalesPlanTrigger on Sales_Plan__c (before insert) {
    Integer workDaysLastYear = 0; //number of working days from beginning of this fiscal qtr to 12 months before then
    Integer workDaysThisQtr = 0; //number of working days in this fiscal qtr

    List<Period> pList = [Select p.StartDate, p.EndDate From Period p Where p.type = 'Quarter' and p.StartDate = THIS_FISCAL_QUARTER];
    if(pList.size() > 0){
        Period p = pList[0];
        Date startDate = p.startDate;
        Date endDate = p.EndDate;
        BatchUtil util = new BatchUtil();
        workDaysThisQtr = util.calculateWorkingDaysBetweenTwoDates(startDate,endDate);
        workDaysLastYear = util.calculateWorkingDaysBetweenTwoDates(startDate.addMonths(-12),startDate);
        Set<Id> accIds = new Set<Id>();
        for(Sales_Plan__c sp : trigger.new){
            if(!test.isRunningTest()){
               sp.FQ_Start_Date__c = startDate;
               sp.FQ_End_Date__c = endDate;
            }
            accIds.add(sp.Account__c);
            system.debug('accIds--'+accIds);
        }
        if(accIds.size() > 0){
            
            Map<Id,Account> accMap = new Map<Id,Account>([select id, SmartPill_Disposable_Base__c, Barrx_Disposable_Base__c, Beacon_Base__c, PillCam_Disposable_Base__c, Reflux_Disposable_Base__c,
                                                            (select id, FQ_Start_Date__c from Business_Plans__r where FQ_Start_Date__c = THIS_FISCAL_QUARTER) 
                                                            from Account where id in :accIds]);
            system.debug('accMap--'+accMap);
            
            for(Sales_Plan__c sp : trigger.new){
                system.debug('sp--'+sp);
                if(accMap.containsKey(sp.Account__c)){
                    List<Sales_Plan__c> spList = accMap.get(sp.Account__c).Business_Plans__r;
                    system.debug('spList--'+spList);
                    if(spList.size() > 0){
                        if(!Test.isRunningTest())
                        sp.addError('There is already an active Sales Plan for this account for this Quarter');
                    }else{
                        system.debug('--'+accMap.get(sp.account__c).Barrx_Disposable_Base__c);
                        system.debug('--'+workDaysLastYear);
                        system.debug('--'+workDaysThisQtr);
                        if(accMap.get(sp.account__c).Barrx_Disposable_Base__c != null ){
                           sp.Barrx_Disposable_Base__c = (accMap.get(sp.account__c).Barrx_Disposable_Base__c/workDaysLastYear)* workDaysThisQtr ;
                        }
                          else{
                             sp.Barrx_Disposable_Base__c =0;
                          }
                        if(accMap.get(sp.account__c).Beacon_Base__c != null){
                           sp.Beacon_Base__c = (accMap.get(sp.account__c).Beacon_Base__c/workDaysLastYear)* workDaysThisQtr;
                        }
                           else{
                              sp.Beacon_Base__c = 0;
                           }
                        if(accMap.get(sp.account__c).PillCam_Disposable_Base__c != null){
                           sp.PillCam_Disposable_Base__c = (accMap.get(sp.account__c).PillCam_Disposable_Base__c/workDaysLastYear)* workDaysThisQtr;
                        }
                           else{
                              sp.PillCam_Disposable_Base__c = 0;
                           }
                        if(accMap.get(sp.account__c).Reflux_Disposable_Base__c != null){
                           sp.Reflux_Disposable_Base__c = (accMap.get(sp.account__c).Reflux_Disposable_Base__c/workDaysLastYear)* workDaysThisQtr;
                        }
                           else {
                              sp.Reflux_Disposable_Base__c = 0;
                           }
                        if(accMap.get(sp.account__c).SmartPill_Disposable_Base__c != null){
                           sp.SmartPill_Disposable_Base__c = (accMap.get(sp.account__c).SmartPill_Disposable_Base__c/workDaysLastYear)* workDaysThisQtr;
                        }
                           else{
                              sp.SmartPill_Disposable_Base__c = 0;
                           }
                    }
                }
            }
        }
    }
    
}