public with sharing class TerritoryPlanCtrl {
    
    public List<Physician_Sales_Goal__c> pillCamObjectives {get;set;}
    public List<Physician_Sales_Goal__c> smartPillObjectives {get;set;}
    public List<Physician_Sales_Goal__c> RFAObjectives {get;set;}
    public List<Physician_Sales_Goal__c> refluxObjectives {get;set;}
    public List<Physician_Sales_Goal__c> beaconObjectives {get;set;}
    public transient List<Sales_Plan__c> pillCampsalesPlanList {get;set;}
    public transient List<Sales_Plan__c> smartsalesPlanList {get;set;}
    public transient List<Sales_Plan__c> rFAsalesPlanList {get;set;}
    public transient List<Sales_Plan__c> refluxsalesPlanList {get;set;}
    public transient List<Sales_Plan__c> beaconSales{get;set;}
    public transient List<Sales_Plan__c> barrxalesPlanList {get;set;}
    public List<Sales_Plan__c> salesPlanList {get;set;}
    
    
    public Map<String, List<Opportunity>> mapOwnerOpps {get;set;}
    public List<Event> activities {get;set;}
    public List<SelectOption> accOptions { get; set; }
    public List<SelectOption> repOptions { get; set; }
    public List<SelectOption> phyOptions { get; set; }
    public List<SelectOption> trgtOptions { get; set; }
    public List<SelectOption> evntOptions { get; set; }
    public List<SelectOption> territoryptions { get; set; }
    Map<String, List<Account>> territoryToAccountMap;
    
    public String selectedAcc { get; set; } 
    public String selectedTerri { get; set; }
    public String selectedTerriDiag { get; set; }
    public String selectedTerriInterv { get; set; }
    public String selectedrep { get; set; }
    public String selectedrepDiag { get; set; }
    public String selectedrepInterv { get; set; }
    public String selectedphy { get; set; }
    public String selectedTrgt { get; set; }
    public String selectedEvntFilter { get; set; }
    public String oppTitle { get; set; }
    public String sortFieldPO { get; set; }
    public String sortFieldOPP { get; set; }
    public String sortOrderPO { get; set; }
    public String sortOrderOPP { get; set; }
    
    public Decimal pillDispTotal { get; set; }
    public Decimal smartDispTotal { get; set; }
    public Decimal barrxDispTotal { get; set; }
    public Decimal refluxDispTotal { get; set; }
    public Decimal beaconDispTotal { get; set; }
    
    public Decimal barrxQTD{ get; set; }
    public Decimal beaconQTD{ get; set; }
    public Decimal bravoQTD{ get; set; }
    public Decimal pillDispQTD{ get; set; }
    public Decimal pillSBQTD{ get; set; }
    public Decimal refluxQTD{ get; set; }
    public Decimal rfaQTD{ get; set; }
    public Decimal smartPillQTD { get; set; }
    public Decimal smartDISCQTD { get; set; }
    
    public Decimal pillCamTotal { get; set; }
    public Decimal smartPillTotal { get; set; }
    public Decimal barrxTotal { get; set; }
    public Decimal refluxTotal { get; set; }
    public Decimal beaconTotal { get; set; }
    
    public Decimal pillCamGrandTotal { get; set; }
    public Decimal smartPillGrandTotal { get; set; }
    public Decimal barrxGrandTotal { get; set; }
    public Decimal refluxGrandTotal { get; set; }
    public Decimal beaconGrandTotal { get; set; }
    public List<Account> accountList = new List<Account>();
    
    Map<String, Map<Id, String>> mapAccRepName = new Map<String, Map<Id, String>>();
    String querySalesPlan;
    String queryWithFilters;
    String oppQueryWithFilters;
    List<Opportunity> opps;
    Set<Id> filteredAccIdSet;
    
    public territoryPlanCtrl() {
        onLoad();
        accountLIst.clear();
    }
    
    public void onLoad() {
        territoryptions  = new List<SelectOption>();
        accOptions = new List<SelectOption>();
        repOptions = new List<SelectOption>();
        phyOptions = new List<SelectOption>();
        trgtOptions = new List<SelectOption>();
        evntOptions = new List<SelectOption>();
        pillCampsalesPlanList  = new List<Sales_Plan__c> ();
        smartsalesPlanList  = new  List<Sales_Plan__c>();
        RFAsalesPlanList = new List<Sales_Plan__c> ();
        RefluxsalesPlanList = new List<Sales_Plan__c>();
        beaconSales = new  List<Sales_Plan__c> ();
        barrxalesPlanList  = new List<Sales_Plan__c> ();
    
        activities  = new List<Event>();
        pillCamObjectives = new List<Physician_Sales_Goal__c>();
        
        opps = new List<Opportunity>();
        territoryToAccountMap =  new Map<String, List<Account>>();
        
        oppTitle = 'Show 6 months';
        sortOrderPO = 'ASC';
        sortOrderOPP = 'ASC';
        sortFieldPO = 'Stage__c';
        sortFieldOPP = 'StageName';
        
        createSalesPlanQuery();
        resetSalesPlan();
        territoryOptions();
        repOptions();
        physicianOptions();
        targetOptions();
        eventFilterOptions();
        //applyOppFilter();
        //applyEventFilter();
        summarizeTargetGrowth();
        
        String spSOQL = 'SELECT Id,Objective__c, Business_Plan__c, Physician__c, Business_Plan__r.Account__c, Business_Plan__r.Account__r.Name, Role__c,Objective_Type__c, Target_Type__c, Next_Steps__c, Stage__c ' +
                     'FROM Physician_Sales_Goal__c where NOT (Target_Focus__c like \'Closed %\') ';
        //applyPOFilters(spSOQL);
        sortOrderPO();
        sortOrderOPP();
    }
    
    /***********************************************
           Picklist Options - START
    ************************************************/
    
    public void territoryOptions(){
        //showAllIntervention();
        if(!Test.isRunningTest()){
        accountList = [select Name, Capital_Rep__c, Territory__c ,Capital_Rep__r.Name, Diagnostic_Rep__c, Diagnostic_Rep__r.Name, 
                        Interventional_Rep__c, Interventional_Rep__r.Name, CPS_Rep__c, CPS_Rep__r.Name, Diagnostic_Inside_Sales_Rep__c,
                        Diagnostic_Inside_Sales_Rep__r.Name, Inside_Sales_Rep__c, Inside_Sales_Rep__r.Name, Key_Accounts_Rep__c, Key_Accounts_Rep__r.Name,
                        Capital_Territory__c, CEC_Territory__c,Diagnostic_Inside_Sales_Territory__c, Diagnostic_Territory__c, Inside_Sales_Territory__c,
                        Interventional_Territory__c, Key_Accounts_Territory__c   
                        from Account where SAP_Account_Name__c != null and SAP_Account_Name__c != ''  AND Has_Active_Sales_Plan__c > 0 order by Name];
        }else{
            accountList = [select Name, Capital_Rep__c, Territory__c ,Capital_Rep__r.Name, Diagnostic_Rep__c, Diagnostic_Rep__r.Name, 
                        Interventional_Rep__c, Interventional_Rep__r.Name, CPS_Rep__c, CPS_Rep__r.Name, Diagnostic_Inside_Sales_Rep__c,
                        Diagnostic_Inside_Sales_Rep__r.Name, Inside_Sales_Rep__c, Inside_Sales_Rep__r.Name, Key_Accounts_Rep__c, Key_Accounts_Rep__r.Name,
                        Capital_Territory__c, CEC_Territory__c,Diagnostic_Inside_Sales_Territory__c, Diagnostic_Territory__c, Inside_Sales_Territory__c,
                        Interventional_Territory__c, Key_Accounts_Territory__c   
                        from Account where SAP_Account_Name__c != null and SAP_Account_Name__c != ''  AND Has_Active_Sales_Plan__c > 0 order by Name limit 10];
        }
       system.debug('****accountList****'+accountList.size());
       Set<String> territorySet = new Set<String>();
       List<Account> tempList;
       territoryptions.add(new SelectOption('','-- All --')) ; 
       territoryToAccountMap.put('', accountList); 
       for(Account a : accountList){
           String key = '';
           if(a.Capital_Territory__c  != null)
               key+=   a.Capital_Territory__c ;
           if(a.CEC_Territory__c != null)
               key+=  '-' +  a.CEC_Territory__c ;
           if(a.Diagnostic_Inside_Sales_Territory__c != null)
               key+=  '-' + a.Diagnostic_Inside_Sales_Territory__c ;
           if(a.Diagnostic_Territory__c != null)
               key+=  '-' + a.Diagnostic_Territory__c;
           if(a.Inside_Sales_Territory__c    != null)
               key+= '-' + a.Inside_Sales_Territory__c ;     
           if(a.Interventional_Territory__c != null)
               key+= '-' + a.Interventional_Territory__c;
           if(a.Key_Accounts_Territory__c != null)
               key+= '-' + a.Key_Accounts_Territory__c ;
           if(a.Territory__c != null)
               key+=  '-' + a.Territory__c  ;
           
           if(!territorySet.contains(key)){          
               territorySet.add(key); 
               territoryptions.add(new SelectOption(key ,key)) ; 
               territoryToAccountMap.put(key, new List<Account>{a}); 
           }else{
               tempList = new List<Account>();
               if(territoryToAccountMap != null && territoryToAccountMap.containsKey(key)){
                   tempList  = territoryToAccountMap.get(key);
                   tempList.add(a);  
                   territoryToAccountMap.put(key, tempList); 
               }
           }
       } 
       SelectOptionSorter.doSort(territoryptions, FieldToSort.Label);                
    }
    
    
    public void accountOptions() {
        accOptions.add(new SelectOption('All', ' -- All -- '));
        for(Account acc :accountList ) {
            accOptions.add(new SelectOption(acc.id, acc.Name));
        }
        SelectOptionSorter.doSort(accOptions, FieldToSort.Label);
    }
    
    public void accountOptionsOnRepSelect() {
        filteredAccIdSet = new Set<Id>();
        accOptions = new List<SelectOption>();
        accOptions.add(new SelectOption('All', ' -- All -- '));
        if(!Test.isRunningTest()){
        for(Account acc :[select Name from Account where (Capital_Rep__c = :selectedRep or Diagnostic_Rep__c = :selectedRep or Interventional_Rep__c = :selectedRep) and SAP_Account_Name__c != null and SAP_Account_Name__c != '' AND Has_Active_Sales_Plan__c > 0] ) {
            accOptions.add(new SelectOption(acc.id, acc.Name));
            filteredAccIdSet.add(acc.id);
        }
        }else{
            for(Account acc :[select Name from Account where (Capital_Rep__c = :selectedRep or Diagnostic_Rep__c = :selectedRep or Interventional_Rep__c = :selectedRep) and SAP_Account_Name__c != null and SAP_Account_Name__c != '' AND Has_Active_Sales_Plan__c > 0 limit 10] ) {
                accOptions.add(new SelectOption(acc.id, acc.Name));
                filteredAccIdSet.add(acc.id);
            }
        }
        SelectOptionSorter.doSort(accOptions, FieldToSort.Label);
    }
    
    public void repOptions() {
        Map<Id, String> mapRepName = new Map<Id, String>();
        Map<Id, String> tempMapRepName = new Map<Id, String>();
        
        for(Account acc : accountList) {
            tempMapRepName = new Map<Id, String>();
            if(acc.Capital_Rep__c != null) {
                mapRepName.put(acc.Capital_Rep__c, acc.Capital_Rep__r.Name);
                tempMapRepName.put(acc.Capital_Rep__c, acc.Capital_Rep__r.Name);
            } 
            if(acc.Diagnostic_Rep__c != null) {
                mapRepName.put(acc.Diagnostic_Rep__c, acc.Diagnostic_Rep__r.Name);
                tempMapRepName.put(acc.Diagnostic_Rep__c, acc.Diagnostic_Rep__r.Name);
            }
            if(acc.Interventional_Rep__c != null) {
                mapRepName.put(acc.Interventional_Rep__c, acc.Interventional_Rep__r.Name);
                tempMapRepName.put(acc.Interventional_Rep__c, acc.Interventional_Rep__r.Name);
            }
            
            mapAccRepName.put(acc.id, tempMapRepName);
        }
        mapAccRepName.put('All', mapRepName);
        repOptions.add(new SelectOption('All', ' -- All -- '));
        
        
        for(String repid :mapRepName.keySet()) {
            repOptions.add(new SelectOption(repid, mapRepName.get(repid)));
        }
        SelectOptionSorter.doSort(repOptions, FieldToSort.Label);
    }
    
    public void repOptionsOnAccSelect() {
        repOptions = new List<SelectOption>();
        repOptions.add(new SelectOption('All', ' -- All -- '));
        Map<Id, String> tempMapRepName = new Map<Id, String>();
        
        if(mapAccRepName.containsKey(selectedAcc)) {
            tempMapRepName = mapAccRepName.get(selectedAcc);
            
            for(String repid : tempMapRepName.keySet()) {
                repOptions.add(new SelectOption(repid, tempMapRepName.get(repid)));
            }
        }
        SelectOptionSorter.doSort(repOptions, FieldToSort.Label);
    }
    
    public void physicianOptions() {
        phyOptions.add(new SelectOption('All', ' -- All -- '));
        List<Physician_Sales_Goal__c> cList = [select id, Physician__c, Physician__r.Name from Physician_Sales_Goal__c where NOT(Target_Focus__c like 'Closed %') order by Physician__r.Name LIMIT 1000];
        Set<Id> phyIds = new Set<Id>();
        for(Physician_Sales_Goal__c phy :cList) {
            if(phy.Physician__c != null && !phyIds.contains(phy.Physician__c)) {
                if(phy.Physician__r.Name != null){
                phyOptions.add(new SelectOption(phy.Physician__c, phy.Physician__r.Name));
                phyIds.add(phy.Physician__c);
                }
            }
        }
        
        SelectOptionSorter.doSort(phyOptions, FieldToSort.Label);
    }
    
    public void phyOptionsOnAccSelect() {
        phyOptions = new List<SelectOption>();
        phyOptions.add(new SelectOption('All', ' -- All -- '));
        Set<Id> phyIds = new Set<Id>();
        List<Physician_Sales_Goal__c> phyGoals = [select Physician__c, Physician__r.Name from Physician_Sales_Goal__c where Business_Plan__r.Account__c = :selectedAcc];
        for(Physician_Sales_Goal__c phy :phyGoals) {
            if(!phyIds.contains(phy.Physician__c)) {
                phyOptions.add(new SelectOption(phy.Physician__c, phy.Physician__r.Name));
                phyIds.add(phy.Physician__c);
            }
        }
        SelectOptionSorter.doSort(phyOptions, FieldToSort.Label);
    }
    
    public void targetOptions() {
        trgtOptions.add(new SelectOption('All', ' -- All -- '));
        trgtOptions.add(new SelectOption('Current Target', 'Current Target'));
        trgtOptions.add(new SelectOption('Prospect Target', 'Prospect Target'));
    }
    
    public void eventFilterOptions() {
        evntOptions.add(new SelectOption('All', ' -- All -- '));
        evntOptions.add(new SelectOption('Upcoming', 'Upcoming'));
        evntOptions.add(new SelectOption('In The Past', 'In The Past'));
    }
    
    /***********************************************
           Picklist Options - END
    ************************************************/
    
    /***********************************************
           Dynamic FIlters - START
    ************************************************/
    
    
    public PageReference onSelectTerritory(){
        System.debug('selectedTerri  ::::'+selectedTerri);
        filteredAccIdSet = new Set<Id>();
        accOptions = new List<SelectOption>();
        accOptions.add(new SelectOption('All', '-- All --')) ;    
        if(territoryToAccountMap != null && selectedTerri  != null && territoryToAccountMap.containsKey(selectedTerri)){
            List<Account> accList = territoryToAccountMap.get(selectedTerri);
            for(Account a : accList){
                accOptions.add(new SelectOption(a.id, a.Name)) ; 
                filteredAccIdSet.add(a.id);   
            }
        }
        SelectOptionSorter.doSort(accOptions, FieldToSort.Label);
        summarizeTargetGrowth();
        return null;    
    }
    
    public void onSelectAccount() {
        String spSOQL = 'SELECT Id,Objective__c, Business_Plan__c, Physician__c, Business_Plan__r.Account__c, Business_Plan__r.Account__r.Name, Role__c,Objective_Type__c, Target_Type__c, Next_Steps__c, Stage__c ' +
                      'FROM Physician_Sales_Goal__c ';
        if(selectedAcc != null && selectedAcc == 'All'){
            
            spSOQL += '  WHERE (Physician__r.AccountId in :filteredAccIdSet OR Physician__r.Hospital__c in :filteredAccIdSet OR Physician__r.Hospital_2__c in :filteredAccIdSet) and (NOT Target_Focus__c like \'Closed %\')  ';
    
        } else if(selectedAcc != null && selectedAcc != '' && selectedAcc != 'All'){
            spSOQL += '  WHERE (Physician__r.AccountId = :selectedAcc OR Physician__r.Hospital__c = :selectedAcc OR Physician__r.Hospital_2__c = :selectedAcc) and (NOT Target_Focus__c like \'Closed %\')  ';
            
            //repOptionsOnAccSelect();
            phyOptionsOnAccSelect();
           
        }  
        System.debug('spSOQL:::'+spSOQL); 
        
        
        applyPOFilters(spSOQL);
        filterOpp();
        applyEventFilter();
        summarizeTargetGrowth();
    }
    
    public void onSelectRep() {
        String spSOQL = 'SELECT Id,Objective__c, Business_Plan__c, Physician__c, Business_Plan__r.Account__c, Business_Plan__r.Account__r.Name, Role__c,Objective_Type__c, Target_Type__c, Next_Steps__c, Stage__c ' +
                      'FROM Physician_Sales_Goal__c ';
        if(selectedRep != null && selectedRep != 'All') {
            spSOQL += 'WHERE (Physician__r.Account.Capital_Rep__c = :selectedRep or Physician__r.Account.Diagnostic_Rep__c = :selectedRep or Physician__r.Account.Interventional_Rep__c = :selectedRep) and (NOT Target_Focus__c like \'Closed %\') ';
            
            applyPOFilters(spSOQL);
            accountOptionsOnRepSelect();
            filterOpp();
            applyEventFilter();
            summarizeTargetGrowth();
        } else {
            selectedAcc = 'All';
            filteredAccIdSet = new Set<Id>();
            onLoad();
        }
        
    }
    
    public void onSelectPhysician() {
        String spSOQL = 'SELECT Id,Objective__c, Business_Plan__c, Physician__c, Business_Plan__r.Account__c, Business_Plan__r.Account__r.Name, Role__c,Objective_Type__c, Target_Type__c, Next_Steps__c, Stage__c ' +
                      'FROM Physician_Sales_Goal__c ';
        if(selectedPhy != null && selectedPhy != '' && selectedPhy != 'All') {
            spSOQL += 'WHERE Physician__c = :selectedPhy';
                     
        }
        if(selectedAcc != null && selectedAcc != '' && selectedAcc != 'All'){
            if(spSOQL.contains('WHERE')){
                spSOQL += '  and Physician__r.AccountId = :selectedAcc ';
            }else{
                spSOQL += '  WHERE Physician__r.AccountId = :selectedAcc ';
            }
        }
        if(spSOQL.contains('WHERE')){
            spSOQL = spSOQL + ' and (NOT Target_Focus__c like \'Closed %\')';
        } else {
            spSOQL = spSOQL + ' where (NOT Target_Focus__c like \'Closed %\')';
        }
        applyPOFilters(spSOQL);
      
    }
    
    /***********************************************
           Dynamic FIlters - END
    ************************************************/
    
    /***********************************************
           Target Growth Summary - START
    ************************************************/
    
    public void initTargetGrowthVar() {
        pillDispTotal = 0;
        smartDispTotal = 0;
        barrxDispTotal = 0;
        refluxDispTotal = 0;
        beaconDispTotal = 0;
        
        pillCamTotal = 0;
        smartPillTotal = 0;
        barrxTotal = 0;
        refluxTotal = 0;
        beaconTotal = 0;
        
        pillCamGrandTotal = 0;
        smartPillGrandTotal = 0;
        barrxGrandTotal = 0;
        refluxGrandTotal = 0;
        beaconGrandTotal = 0;
        
        barrxQTD  = 0;
        beaconQTD = 0;
        bravoQTD = 0;
        pillDispQTD = 0;
        pillSBQTD = 0;
        refluxQTD = 0;
        rfaQTD = 0;
        smartPillQTD  = 0;
        smartDISCQTD  = 0;
    
    }
    
    public void summarizeTargetGrowth() {
        initTargetGrowthVar();
        
        String query = 'SELECT SUM(Barrx_Disposable_Base__c)bdisp, SUM(PillCam_Disposable_Base__c)pdisp, ' +
                        ' SUM(Reflux_Disposable_Base__c)rdisp, SUM(SmartPill_Disposable_Base__c)sdisp, ' +
                        ' SUM(PillCam_CQ_Growth_Goal__c)pgrwth, SUM(SmartPill_CQ_Growth_Goal__c)sgrwth, ' +
                        ' SUM(Reflux_CQ_Growth_Goal__c)rgrwth, SUM(Barrx_CQ_Growth_Goal__c)bgrwth, ' +
                        ' SUM(Barrx_Disposable_QTD_Actual__c)brQTD, SUM(Beacon_Base_QTD_Actual__c)bcQTD, ' +
                        ' SUM(Bravo_Capsules_QTD_Actual__c)brcQTD, SUM(Pillcam_Disposable_QTD_Actual__c)pdQTD, ' +
                        ' SUM(PillCam_SB_QTD_Actual__c) psQTD, SUM(Reflux_Disposable_QTD_Actual__c)rdQTD, ' +
                        ' SUM(RFA_Catheters_QTD_Actual__c)rfaQTD, ' +
                        ' SUM(SmartPill_Capsules_QTD_Actual__c) scQTD, SUM(Smartpill_Disposable_QTD_Actual__c)sdQTD, ' +
                        ' SUM(Beacon_CQ_Growth_Goal__c)bcngrwth, SUM(Beacon_Base__c) bcnBase FROM Sales_Plan__c ' + 
                        ' where Account__c != null AND Active__c = true';
        if(selectedAcc != null && selectedAcc != '' && selectedAcc != 'All') {
            query += ' and Account__c = :selectedAcc ';
        } else {
            
            if(filteredAccIdSet != null && !filteredAccIdSet.isEmpty()) {
                query += ' and Account__c in :filteredAccIdSet ';
            }
        }
        AggregateResult[] groupedResults = Database.query(query);
        System.debug('groupedResults1=== ' + groupedResults);
        //Object avgAmount = groupedResults[0].get('aver');
        if(groupedResults != null && groupedResults.size() > 0) {
            AggregateResult agr = groupedResults[0];
            if(agr.get('brQTD') != null)
                barrxQTD  = Decimal.valueOf(Double.valueOf(agr.get('brQTD'))).setScale(2);
            if(agr.get('bcQTD') != null)
                beaconQTD = Decimal.valueOf(Double.valueOf(agr.get('bcQTD'))).setScale(2);
            if(agr.get('brcQTD') != null)
                bravoQTD = Decimal.valueOf(Double.valueOf(agr.get('brcQTD'))).setScale(2);
            if(agr.get('pdQTD') != null)
                pillDispQTD = Decimal.valueOf(Double.valueOf(agr.get('pdQTD'))).setScale(2);
            if(agr.get('rdQTD') != null)
                refluxQTD = Decimal.valueOf(Double.valueOf(agr.get('rdQTD'))).setScale(2);
            if(agr.get('psQTD') != null)
                pillSBQTD = Decimal.valueOf(Double.valueOf(agr.get('psQTD'))).setScale(2);
            if(agr.get('rfaQTD') != null)
                rfaQTD  = Decimal.valueOf(Double.valueOf(agr.get('rfaQTD'))).setScale(2);
            if(agr.get('scQTD') != null)
                smartPillQTD  = Decimal.valueOf(Double.valueOf(agr.get('scQTD'))).setScale(2);
            if(agr.get('sdQTD') != null)
                smartDISCQTD  = Decimal.valueOf(Double.valueOf(agr.get('sdQTD'))).setScale(2);
             
            
            
            if(agr.get('pdisp') != null)
                pillDispTotal = Decimal.valueOf(Double.valueOf(agr.get('pdisp'))).setScale(2);
            if(agr.get('sdisp') != null)
                smartDispTotal = Decimal.valueOf(Double.valueOf(agr.get('sdisp'))).setScale(2);
            if(agr.get('bdisp') != null)
                barrxDispTotal = Decimal.valueOf(Double.valueOf(agr.get('bdisp'))).setScale(2);
            if(agr.get('rdisp') != null)
                refluxDispTotal = Decimal.valueOf(Double.valueOf(agr.get('rdisp'))).setScale(2);
            if(agr.get('bcnBase') != null)
                beaconDispTotal = Decimal.valueOf(Double.valueOf(agr.get('bcnBase'))).setScale(2);
            if(agr.get('pgrwth') != null)
                pillCamTotal = Decimal.valueOf(Double.valueOf(agr.get('pgrwth'))).setScale(2);
            if(agr.get('sgrwth') != null)
                smartPillTotal = Decimal.valueOf(Double.valueOf(agr.get('sgrwth'))).setScale(2);
            if(agr.get('rgrwth') != null)
                refluxTotal = Decimal.valueOf(Double.valueOf(agr.get('rgrwth'))).setScale(2);
            if(agr.get('bgrwth') != null)
                barrxTotal = Decimal.valueOf(Double.valueOf(agr.get('bgrwth'))).setScale(2);
            if(agr.get('bcngrwth') != null)
                beaconTotal = Decimal.valueOf(Double.valueOf(agr.get('bcngrwth'))).setScale(2);
        }
        
        pillCamGrandTotal = pillDispTotal + pillCamTotal;
        smartPillGrandTotal = smartDispTotal + smartPillTotal;
        barrxGrandTotal = barrxDispTotal + barrxTotal;
        refluxGrandTotal = refluxDispTotal + refluxTotal;
        beaconGrandTotal = beaconDispTotal + beaconTotal;
    }
    
    /***********************************************
           Target Growth Summary - END
    ************************************************/
    
    /***********************************************
     Physician Objective Sorting and FIlter - START
    ************************************************/
    
    public void applyPOFilters(String spSOQL) {
        queryWithFilters = spSOQL;
        spSOQL = applyOrderPO(spSOQL);
        
        pillCamObjectives = new List<Physician_Sales_Goal__c>();
        smartPillObjectives = new List<Physician_Sales_Goal__c>();
        RFAObjectives = new List<Physician_Sales_Goal__c>();
        refluxObjectives = new List<Physician_Sales_Goal__c>();
        beaconObjectives = new List<Physician_Sales_Goal__c>();
        System.debug('selectedAcc === ' + selectedAcc);
        System.debug('spSOQL=== ' + spSOQL);
        
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
        
    }
    
    public String applyOrderPO(String spSOQL) {
        String sortBy = ApexPages.currentPage().getParameters().get('sortby');
        
        if(sortFieldPO != sortBy) sortOrderPO = 'ASC';
        
        if(sortBy != null && sortBy != '') sortFieldPO = sortBy;
        
        spSOQL += ' Order By ' + sortFieldPO + ' ' + sortOrderPO;
        
        return spSOQL;
    }
    
    public void applySortingOnPO() {
        applyPOFilters(queryWithFilters);
        sortOrderPO();
    }
    
    public void sortOrderPO() {
        if(sortOrderPO == 'ASC') {
            sortOrderPO = 'DESC';
        } else {
            sortOrderPO = 'ASC';
        }
    }
    
    public void resetSalesPlan() {
        pillCamObjectives = new List<Physician_Sales_Goal__c>();
        smartPillObjectives = new List<Physician_Sales_Goal__c>();
        RFAObjectives = new List<Physician_Sales_Goal__c>();
        refluxObjectives = new List<Physician_Sales_Goal__c>();
        beaconObjectives = new List<Physician_Sales_Goal__c>();
        mapOwnerOpps = new Map<String, List<Opportunity>>();
        activities  = new List<Event>();
        
        selectedAcc = '';
        selectedTerri = 'All';
        selectedrep = '';
        selectedphy = '';
        initTargetGrowthVar();
    }
    
    /***********************************************
     Physician Objective Sorting and FIlter - END
    ************************************************/
    
    /***********************************************
         Opportunity Sorting and FIlter - START
    ************************************************/
    
    public void applyOppFilter() {
        filterOpp();
        if(oppTitle == 'Show 6 months') oppTitle = 'Show All';
        else if(oppTitle == 'Show All') oppTitle = 'Show 6 months';
        
    }
    
    public void filterOpp() {
        String oSOQL = 'SELECT Id,Type, Name, Amount, StageName, CloseDate, RecordType.Name, RecordTypeId, Owner.Name, AccountId ' +
                     'FROM Opportunity ';
        
        if(oppTitle == 'Show 6 months')
            oSOQL += ' WHERE (CloseDate = THIS_MONTH or CloseDate = NEXT_N_MONTHS:5) AND Account.SAP_Account_Name__c != null AND Account.Has_Active_Sales_Plan__c > 0 ';
        if(oppTitle == 'Show All')
            oSOQL += ' WHERE CloseDate != null AND Account.SAP_Account_Name__c != null AND Account.Has_Active_Sales_Plan__c > 0 ';
            
        if(selectedAcc != null && selectedAcc != 'All')
            oSOQL += ' and AccountId = :selectedAcc ';
        else if(filteredAccIdSet != null && !filteredAccIdSet.isEmpty())
            oSOQL += ' and AccountId in :filteredAccIdSet ';
        
        oSOQL += ' and isClosed = false';
        oppQueryWithFilters = oSOQL;
        oSOQL = applyOrderOPP(oSOQL);
        System.debug('oSOQL===' + oSOQL);                  
        
        opps = database.query(oSOQL);
        summarizeOppByOwner();
        opps.clear();
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
    
    public String applyOrderOPP(String spSOQL) {
        String sortBy = ApexPages.currentPage().getParameters().get('sortby');
        
        if(sortFieldOPP != sortBy) sortOrderOPP = 'ASC';
        
        if(sortBy != null && sortBy != '') sortFieldOPP = sortBy;
        
        spSOQL += ' Order By ' + sortFieldOPP + ' ' + sortOrderOPP;
        
        return spSOQL;
    }
    
    public void applySortingOnOPP() {
        String oSOQL = applyOrderOPP(oppQueryWithFilters);
        opps = database.query(oSOQL);
        summarizeOppByOwner();
        sortOrderOPP();
        opps.clear();
    }
    
    public void sortOrderOPP() {
        if(sortOrderOPP == 'ASC') {
            sortOrderOPP = 'DESC';
        } else {
            sortOrderOPP = 'ASC';
        }
    }
    
    /***********************************************
         Opportunity Sorting and FIlter - END
    ************************************************/
    
    /***********************************************
                Event Filter - START
    ************************************************/
    
    public void applyEventFilter() {
        
        Id eventAcctDevRTID = [SELECT Id FROM RecordType WHERE sObjectType = 'Event' and DeveloperName = 'Account_Development'].Id;
        String aSOQL = 'SELECT Type,Next_Steps__c,Call_Objective__c,ActivityDate,subject,Id,OwnerId ' +
                     'FROM Event ' +
                    'WHERE RecordTypeId = :eventAcctDevRTID ';
        
        if(selectedEvntFilter != null && selectedEvntFilter != '') {
            if(selectedEvntFilter.equals('Upcoming')) aSOQL += ' and (StartDateTime = NEXT_N_MONTHS:6 or (StartDateTime = THIS_MONTH and StartDateTime > TODAY)) ';
            if(selectedEvntFilter.equals('In The Past')) aSOQL += ' and StartDateTime = THIS_FISCAL_QUARTER and StartDateTime < TODAY ';
        
        } else {
            aSOQL += ' and StartDateTime = THIS_FISCAL_QUARTER';
        }
        
        if(selectedAcc != null && selectedAcc != 'All')
            aSOQL += ' and WhatId = : selectedAcc';
        else if(filteredAccIdSet != null && !filteredAccIdSet.isEmpty())
            aSOQL += ' and WhatId in :filteredAccIdSet ';
            
        aSOQL += '  order by StartDateTime ';
        
        activities = database.query(aSOQL);
    }
    
    /***********************************************
                Event Filter - END
    ************************************************/
    
    /***********************************************
     Interventional and Diagnostic Territory - START
    ************************************************/
    
    
    public void createSalesPlanQuery() {
        querySalesPlan = 'Select id , Account_Name__c, ' 
                           + 'Beacon_CQ_Growth_Goal__c , PillCam_CQ_Growth_Goal__c, '
                           + 'Reflux_CQ_Growth_Goal__c, SmartPill_CQ_Growth_Goal__c , '
                           + 'Barrx_Disposable_Base__c, SmartPill_Disposable_Base__c, '
                           + ' Barrx_Total_CQ_Target__c, Beacon_Total_CQ_Target__c, PillCam_Total_CQ_Target__c, Reflux_Total_CQ_Target__c, SmartPill_Total_CQ_Target__c, '
                           + ' Reflux_Disposable_Base__c, PillCam_Disposable_Base__c, Beacon_Base__c, '
                           + ' Barrx_CQ_Growth_Goal__c,   Bravo_Capsules_QTD_Actual__c, Pillcam_Disposable_QTD_Actual__c, '
                           + ' PillCam_SB_QTD_Actual__c, Reflux_Disposable_QTD_Actual__c,RFA_Catheters_QTD_Actual__c, '
                           + ' SmartPill_Capsules_QTD_Actual__c, Smartpill_Disposable_QTD_Actual__c, '
                           + ' Barrx_Disposable_QTD_Actual__c, Beacon_Base_QTD_Actual__c '
                           + ' from Sales_Plan__c  Where Active__c = true LIMIT 1000';
    }
    
    public void showAllIntervention(){
        resetInterventionList();
        
        for(Sales_Plan__c s : Database.query(querySalesPlan)){
                            
             if(s.Reflux_CQ_Growth_Goal__c != null && s.Reflux_CQ_Growth_Goal__c != 0)   
                RefluxsalesPlanList.add(s);
             if(s.Beacon_CQ_Growth_Goal__c != null && s.Beacon_CQ_Growth_Goal__c != 0)      
                 beaconSales.add(s);
             if(s.Barrx_CQ_Growth_Goal__c != null && s.Barrx_CQ_Growth_Goal__c != 0) 
                barrxalesPlanList.add(s);
       }
    }
    
    public void showAllDiagnostic(){
        resetDiagnosticList();
        
        for(Sales_Plan__c s : Database.query(querySalesPlan)){
                            
             if(s.PillCam_CQ_Growth_Goal__c != null && s.PillCam_CQ_Growth_Goal__c != 0)
                 pillCampsalesPlanList.add(s);
             if(s.SmartPill_CQ_Growth_Goal__c != null && s.SmartPill_CQ_Growth_Goal__c != 0)
                 smartsalesPlanList.add(s);
       }
    }
    
    public void resetInterventionList() {
        RefluxsalesPlanList = new List<Sales_Plan__c>();
        beaconSales = new  List<Sales_Plan__c> ();
        barrxalesPlanList  = new List<Sales_Plan__c> ();
        selectedTerriInterv = 'All';
        selectedrepInterv = '';
    }
    
    public void resetDiagnosticList() {
        pillCampsalesPlanList  = new List<Sales_Plan__c> ();
        smartsalesPlanList  = new  List<Sales_Plan__c>();
        selectedTerriDiag = 'All';
        selectedrepDiag = '';
    }
    
    /***********************************************
     Interventional and Diagnostic Territory - END
    ************************************************/
    
    /***********************************************
         Interventional Territory Filter - START
    ************************************************/
    
    public void filterIntervByRep() {
        String qry = querySalesPlan;
        
        if(selectedRepInterv != null && selectedRepInterv != '') {
            qry += ' AND (Account__r.Capital_Rep__c = :selectedRepInterv or Account__r.Diagnostic_Rep__c = :selectedRepInterv or Account__r.Interventional_Rep__c = :selectedRepInterv)  ';
                     
        }
        
        RefluxsalesPlanList = new List<Sales_Plan__c>();
        beaconSales = new  List<Sales_Plan__c> ();
        barrxalesPlanList  = new List<Sales_Plan__c> ();
        for(Sales_Plan__c s : Database.query(qry)){
                            
             if(s.Reflux_CQ_Growth_Goal__c != null && s.Reflux_CQ_Growth_Goal__c != 0)   
                RefluxsalesPlanList.add(s);
             if(s.Beacon_CQ_Growth_Goal__c != null && s.Beacon_CQ_Growth_Goal__c != 0)      
                 beaconSales.add(s);
             if(s.Barrx_CQ_Growth_Goal__c != null && s.Barrx_CQ_Growth_Goal__c != 0) 
                barrxalesPlanList.add(s);
             
         }
    }
    
    public void filterIntervByTerritory(){
        String qry = querySalesPlan;
        
        if(territoryToAccountMap != null && selectedTerriInterv  != null && territoryToAccountMap.containskey(selectedTerriInterv)){
            Set<String> accIds = new Set<String>();
            for (Account a : territoryToAccountMap.get(selectedTerriInterv)) {
                accIds.add(a.id);
            }
            
            qry += '  and Account__c in :accIds  ';

        }
        
        RefluxsalesPlanList = new List<Sales_Plan__c>();
        beaconSales = new  List<Sales_Plan__c> ();
        barrxalesPlanList  = new List<Sales_Plan__c> ();
        for(Sales_Plan__c s : Database.query(qry)){
                            
             if(s.Reflux_CQ_Growth_Goal__c != null && s.Reflux_CQ_Growth_Goal__c != 0)   
                RefluxsalesPlanList.add(s);
             if(s.Beacon_CQ_Growth_Goal__c != null && s.Beacon_CQ_Growth_Goal__c != 0)      
                 beaconSales.add(s);
             if(s.Barrx_CQ_Growth_Goal__c != null && s.Barrx_CQ_Growth_Goal__c != 0) 
                barrxalesPlanList.add(s);
             
         }
    }
    
    /***********************************************
         Interventional Territory Filter - END
    ************************************************/
    
    /***********************************************
         Diagnostic Territory Filter - START
    ************************************************/
    
    public void filterDiagByTerritory(){
        String qry = querySalesPlan;
        if(territoryToAccountMap != null && selectedTerriDiag  != null && territoryToAccountMap.containskey(selectedTerriDiag)){
            Set<String> accIds = new Set<String>();
            for (Account a : territoryToAccountMap.get(selectedTerriDiag)) {
                accIds.add(a.id);
            }
            
            qry += '  and Account__c in :accIds  ';

        }
        
        pillCampsalesPlanList = new List<Sales_Plan__c>();
        smartsalesPlanList = new List<Sales_Plan__c>();
        for(Sales_Plan__c s : Database.query(qry)){
                            
             if(s.PillCam_CQ_Growth_Goal__c != null && s.PillCam_CQ_Growth_Goal__c != 0)
                 pillCampsalesPlanList.add(s);
             if(s.SmartPill_CQ_Growth_Goal__c != null && s.SmartPill_CQ_Growth_Goal__c != 0)
                 smartsalesPlanList.add(s);
             
         }
    }
    
    public void filterDiagByRep() {
        String qry = querySalesPlan;
        
        if(selectedRepDiag != null && selectedRepDiag != '') {
            qry += ' AND (Account__r.Capital_Rep__c = :selectedRepDiag or Account__r.Diagnostic_Rep__c = :selectedRepDiag or Account__r.Interventional_Rep__c = :selectedRepDiag)  ';
                     
        }
        
        pillCampsalesPlanList = new List<Sales_Plan__c>();
        smartsalesPlanList = new List<Sales_Plan__c>();
        for(Sales_Plan__c s : Database.query(qry)){
                            
             if(s.PillCam_CQ_Growth_Goal__c != null && s.PillCam_CQ_Growth_Goal__c != 0)
                 pillCampsalesPlanList.add(s);
             if(s.SmartPill_CQ_Growth_Goal__c != null && s.SmartPill_CQ_Growth_Goal__c != 0)
                 smartsalesPlanList.add(s);
             
         }
    }
    /***********************************************
         Diagnostic Territory Filter - END
    ************************************************/
    
    
    /*public void applyTrgtFilter() {
        String spSOQL = 'SELECT Id, Target_Focus__c, Business_Plan__c, Objective__c, Physician__c, Business_Plan__r.Account__c, Business_Plan__r.Account__r.Name, Role__c, Objective_Type__c, Target_Type__c, Next_Steps__c, Stage__c ' +
                      'FROM Physician_Sales_Goal__c ';
        if(selectedTrgt != null && selectedTrgt != '') {
            if(selectedTrgt == 'Current Target')
                spSOQL += 'WHERE Target_Focus__c = \'Current Target\'';
            if(selectedTrgt == 'Prospect Target')
                spSOQL += 'WHERE Target_Focus__c = \'Prospect\'';         
        } else {
            spSOQL += 'WHERE (Target_Focus__c = \'Current Target\' or Target_Focus__c = \'Prospect\') ';
        }
        if(selectedAcc != null && selectedAcc != '')
            spSOQL += '  and Physician__r.AccountId = :selectedAcc ';
        if(selectedPhy != null && selectedPhy != '') 
            spSOQL += ' and Physician__c = :selectedPhy';
        spSOQL = spSOQL + ' and (NOT Target_Focus__c like \'Closed %\')';    
        applyPOFilters(spSOQL);
      
    }*/
    
}