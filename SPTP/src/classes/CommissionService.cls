/**
 * Custom business logic that backs commission calculations and related processes.
 * Updated May 2016 for FY17 calculation - Adrian Bunea 
 *
 */
public class CommissionService {
  public String recalculateCommissions(String fiscalYear, Date startDate, Date endDate, Boolean recreate){
    Date fyEndDate;
    if (fiscalYear =='') { //called from scheduled job
      for (FiscalYearSettings fy : [SELECT Id,Name,EndDate,StartDate 
                                       FROM FiscalYearSettings 
                                      WHERE StartDate <= :endDate and
                                            EndDate >= :endDate]){
        startDate = fy.StartDate;
        fiscalYear = fy.Name;
        fyEndDate = fy.EndDate;
      }
    } else  { // called from comm admin page
      for (FiscalYearSettings fys : [SELECT Id,EndDate,StartDate FROM FiscalYearSettings WHERE Name = :fiscalYear]){
        startDate = fys.StartDate;
        endDate = system.today() <= fys.EndDate ? system.today() : fys.EndDate;
        fyEndDate = fys.EndDate;
      }
    }
    try {
      //get exsiting commissions for selected fiscal year
      Commission__c [] currCommLst = new List<Commission__c>();
      Set<String> commKeys = new Set<String>();
      currCommLst = [SELECT Id, Key__c,CommissionedSales__c, PillCam_Capital_Sales__c, PillCam_Disposables_Sales__c,
                            SmartPill_Capital_Sales__c,SmartPill_Disposables_Sales__c,Reflux_Capital_Sales__c,
                            Reflux_Disposables_Sales__c,Barrx_Disposables_Sales__c,Beacon_Disposables_Sales__c,
                            Manometry_Capital_Sales__c,Manometry_Disposables_Sales__c,Barrx_Capital_Sales__c,
                     		Reflux_Capital_Sales_RM__c, Manometry_Capital_sales_RM__c, Manometry_Disposables_Sales_RM__c, RFA_Capital_Sales_RM__c
                       FROM Commission__c 
                      WHERE Period__c >= :startDate and Period__c <= :fyEndDate];
      for(Commission__c c : currCommLst){commKeys.add(c.Key__c);}
      if (recreate) {
        delete currCommLst;
        commKeys.clear();
      } else {
        //zero out
        for(Commission__c c : currCommLst){
          c.CommissionedSales__c=0;
          c.PillCam_Capital_Sales__c=0;
          c.PillCam_Disposables_Sales__c=0;
          c.SmartPill_Capital_Sales__c=0;
          c.SmartPill_Disposables_Sales__c=0;
          c.Reflux_Capital_Sales__c=0;
          c.Reflux_Disposables_Sales__c=0;
          c.Barrx_Disposables_Sales__c=0;
          c.Beacon_Disposables_Sales__c=0;
          c.Manometry_Capital_Sales__c=0;
          c.Manometry_Disposables_Sales__c=0;
          c.Barrx_Capital_Sales__c=0;
          c.Reflux_Capital_Sales_RM__c=0;
          c.Manometry_Capital_sales_RM__c=0;
          c.Manometry_Disposables_Sales_RM__c=0;
          c.RFA_Capital_Sales_RM__c=0;
          c.Beacon_Disposables_Area_Sales__c=0;
        }
        update currCommLst;
      }
      //update/create new commission records for selected fiscal year
      CommissionService cs = new CommissionService();
      cs.createCommissionRecords(startDate, endDate,commKeys);
      //recalculate commissions on all invoices for selected fiscal year
      Integer fyInt = integer.valueOf(fiscalYear);
      batchRecalcCommission brc = new batchRecalcCommission('SELECT Id FROM Invoice2__c WHERE FY__c = ' + fyInt); 
      database.executebatch(brc,1);
    } catch (Exception e) {
      return e.getMessage();
    }
    return 'ok';
  }
  public void createCommissionRecords(Date startDate, Date endDate,Set<String> commKeys){
    system.debug('### start date is ' + startDate + ' and end date is ' + endDate);
    List<Commission__c>  commissions = new List<Commission__c>();
    Map<String, Id> key2QuotaMap = new Map<String, Id>();
    Map<String, Id> key2RepMap = new Map<String, Id>();
    Map<String, String> key2TerrName = new Map<String,String>();
    List<MonthlyQuota__c> missingQuotas = new List<MonthlyQuota__c>();
    Map<String, Date> key2PeriodDate = new Map<String, Date>();
    //Select Capital, Diagnostic, Interventional, KAM and Inside Sales W territories 
    UserTerritory2Association [] ut2aLst = [SELECT Territory2Id, Territory2.Name, Territory2.Territory2Type.DeveloperName, UserId
                                            FROM UserTerritory2Association 
                                            WHERE ((Territory2.Territory2Type.DeveloperName in ('Interventional','Diagnostic','Capital') and 
                                                  isactive=true and RoleInTerritory2 ='Rep') 
                                            	  or (Territory2.Territory2Type.DeveloperName in ('Key_Account_Manager') and 
                                                  isactive=true and RoleInTerritory2 ='Key Account Manager')
                                            	  or (Territory2.Territory2Type.DeveloperName in('Inside_Sales') and 
                                                  isactive=true and RoleInTerritory2 ='Inside Sales Rep')) ];

    //loop through each period(month) of the current FY and create commission records for each territory if none exist
    for (Period p : [SELECT Number, EndDate, FiscalYearSettings.Name 
                       FROM Period
                      WHERE StartDate >= :startDate and 
                            StartDate <= :endDate and
                            Type='Month'
                   ORDER BY Number]){
      for (UserTerritory2Association usrTerr : ut2aLst){
        String cKey = usrTerr.Territory2Id + '_' + p.Number + '_' + p.FiscalYearSettings.Name;
        if(!commKeys.contains(cKey)){
          Commission__c c = new Commission__c();
          c.Key__c = cKey;
          c.Period__c = p.EndDate;
          c.OwnerId = usrTerr.UserId;
          c.SalesRep__c = usrTerr.UserId;
          c.Territory2__c = usrTerr.Territory2.Name;
         
            
          commissions.add(c);
          key2QuotaMap.put(cKey,null);
          key2RepMap.put(cKey,usrTerr.UserId);
          key2TerrName.put(cKey,usrTerr.Territory2.Name);
          key2PeriodDate.put(cKey,p.EndDate);
        }
      }
    }
    if(!commissions.isEmpty()) {
      //get existing quotas
      for (MonthlyQuota__c mq : [SELECT Id, Key__c FROM MonthlyQuota__c WHERE Key__c in  :key2QuotaMap.keyset()]) {
        key2QuotaMap.put(mq.Key__c,mq.Id);
      }
      //create missing quotas
      for (String s : key2QuotaMap.keyset()){
        if (key2QuotaMap.get(s)==null){
          Id repId = key2RepMap.get(s);
          date pDate = key2PeriodDate.get(s);
          MonthlyQuota__c quota = new MonthlyQuota__c();
          quota.Key__c=s;
          quota.SalesRep__c=repId;
          quota.OwnerId=repId;
          quota.Territory2__c=key2TerrName.get(s);
          quota.PeriodEndDate__c = pDate;
          List<String> keyParts = s.Split('_',2);
          quota.Period_Key__c = keyParts[1];
          missingQuotas.add(quota);
        }
      }
      if(!missingQuotas.isEmpty()) {
        insert missingQuotas;
        for(MonthlyQuota__c m : missingQuotas) {key2QuotaMap.put(m.Key__c, m.Id);}
      }
      //add quotas to commissions
      for (Commission__c c : commissions) {c.Quota__c = key2QuotaMap.get(c.Key__c);}
      insert commissions;
    }
  }
}







/*
 * Old version - for FY16 
 *
  public void createCommissionRecords(Date startDate, Date endDate,Set<String> commKeys){
    system.debug('### start date is ' + startDate + ' and end date is ' + endDate);
    List<Commission__c>  commissions = new List<Commission__c>();
    Map<String, Id> key2QuotaMap = new Map<String, Id>();
    Map<String, Id> key2RepMap = new Map<String, Id>();
    Map<String, String> key2TerrName = new Map<String,String>();
    List<MonthlyQuota__c> missingQuotas = new List<MonthlyQuota__c>();
    Map<String, Date> key2PeriodDate = new Map<String, Date>();
    //all current territories and their reps + the 3 Region territories and the RMs where the Capital Rep covering part of the region reports into a different RM 
    UserTerritory2Association [] ut2aLst = [SELECT Territory2Id, Territory2.Name, Territory2.Territory2Type.DeveloperName, UserId
                                            FROM UserTerritory2Association 
                                            WHERE (Territory2.Territory2Type.DeveloperName in ('Interventional','Diagnostic','Capital') and 
                                                  isactive=true and RoleInTerritory2 ='Rep') 
                                                  or (Territory2.Name in ('Pacific','Capital','MidAtlantic') and 
                                                  isactive=true and  RoleInTerritory2 ='RM')];
  
    // Associate the 3 Region with the Capital Rep partially covering it but reporting into a different region - will use this value for the Sales Rep and Territory Name fields 
   UserTerritory2Association [] ut2aLst_exceptions = [SELECT Territory2Id, Territory2.Name, Territory2.Territory2Type.DeveloperName, UserId, Territory2.ParentTerritory2.Name
                                            FROM UserTerritory2Association 
                                            WHERE Territory2.Territory2Type.DeveloperName ='Capital' and 
                                                  isactive=true and RoleInTerritory2 ='Rep' and 
                                                  Territory2.Name in ('San Francisco (C)','Washington DC (C)','Pittsburgh (C)') ];
      
    //loop through each period(month) of the current FY and create commission records for each territory if none exist
    for (Period p : [SELECT Number, EndDate, FiscalYearSettings.Name 
                       FROM Period
                      WHERE StartDate >= :startDate and 
                            StartDate <= :endDate and
                            Type='Month'
                   ORDER BY Number]){
      for (UserTerritory2Association usrTerr : ut2aLst){
        String cKey = usrTerr.Territory2Id + '_' + p.Number + '_' + p.FiscalYearSettings.Name;
        if(!commKeys.contains(cKey)){
          Commission__c c = new Commission__c();
          c.Key__c = cKey;
          c.Period__c = p.EndDate;
          c.OwnerId = usrTerr.UserId;
          c.SalesRep__c = usrTerr.UserId;
          c.Territory2__c = usrTerr.Territory2.Name;
         
          //overwrite Sales rep and territory name with the Rep - instead of the RM and region name - for the 3 exceptions  
         
            if (usrTerr.Territory2.Name == 'Pacific'){ 
            for (UserTerritory2Association usrTerr_e : ut2aLst_exceptions)   {
               if (usrTerr_e.Territory2.Name=='San Francisco (C)'){
                    c.SalesRep__c = usrTerr_e.UserId;
          			c.Territory2__c = usrTerr_e.Territory2.Name;    
           		 }    
          		} 
            } else if (usrTerr.Territory2.Name == 'Capital'){ 
            for (UserTerritory2Association usrTerr_e : ut2aLst_exceptions)   {
               if (usrTerr_e.Territory2.Name=='Washington DC (C)'){
                    c.SalesRep__c = usrTerr_e.UserId;
          			c.Territory2__c = usrTerr_e.Territory2.Name;    
           		 }    
          		} 
            } else if (usrTerr.Territory2.Name == 'MidAtlantic'){ 
            for (UserTerritory2Association usrTerr_e : ut2aLst_exceptions)   {
               if (usrTerr_e.Territory2.Name=='Pittsburgh (C)'){
                    c.SalesRep__c = usrTerr_e.UserId;
          			c.Territory2__c = usrTerr_e.Territory2.Name;    
           		 }    
          		} 
            } 
            
            
          commissions.add(c);
          key2QuotaMap.put(cKey,null);
          key2RepMap.put(cKey,usrTerr.UserId);
          key2TerrName.put(cKey,usrTerr.Territory2.Name);
          key2PeriodDate.put(cKey,p.EndDate);
        }
      }
    }
    if(!commissions.isEmpty()) {
      //get existing quotas
      for (MonthlyQuota__c mq : [SELECT Id, Key__c FROM MonthlyQuota__c WHERE Key__c in  :key2QuotaMap.keyset()]) {
        key2QuotaMap.put(mq.Key__c,mq.Id);
      }
      //create missing quotas
      for (String s : key2QuotaMap.keyset()){
        if (key2QuotaMap.get(s)==null){
          Id repId = key2RepMap.get(s);
          date pDate = key2PeriodDate.get(s);
          MonthlyQuota__c quota = new MonthlyQuota__c();
          quota.Key__c=s;
          quota.SalesRep__c=repId;
          quota.OwnerId=repId;
          quota.Territory2__c=key2TerrName.get(s);
          quota.PeriodEndDate__c = pDate;
          List<String> keyParts = s.Split('_',2);
          quota.Period_Key__c = keyParts[1];
          missingQuotas.add(quota);
        }
      }
      if(!missingQuotas.isEmpty()) {
        insert missingQuotas;
        for(MonthlyQuota__c m : missingQuotas) {key2QuotaMap.put(m.Key__c, m.Id);}
      }
      //add quotas to commissions
      for (Commission__c c : commissions) {c.Quota__c = key2QuotaMap.get(c.Key__c);}
      insert commissions;
    }
  } 
 */