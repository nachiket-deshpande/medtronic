public with sharing class ContactLeadController{
    public Contact c;
    public Lead l {get;set;}
    public List<SelectOption> accOptions {get;set;}
    public List<SelectOption> prodPortfolioOptions {get;set;}
    public List<SelectOption> salesOpptyOptions {get;set;}
    Map<id,String> accMap = new Map<id,String>();
    Map<Id,Id> accISRMap = new Map<Id,Id>();
    public String selectedProdPortfolio {get;set;}
    public String selectedSalesOpportunity {get;set;}
    
    public ContactLeadController(ApexPages.StandardController stdController){
         this.c = (Contact)stdController.getRecord();
         c = [select id, AccountId, Account.Name, Hospital__c, Hospital_2__c, Hospital_3__c, Hospital__r.Name, Hospital_2__r.Name, 
             Hospital_3__r.Name, Account.Inside_Sales_Rep__c, Hospital__r.Inside_Sales_Rep__c, Hospital_2__r.Inside_Sales_Rep__c, Hospital_3__r.Inside_Sales_Rep__c,
             firstname, lastname, phone, email, mailingstreet,mailingcity, mailingstate, mailingCountry, mailingpostalcode,
             Account.Account_Number__c, Hospital__r.Account_Number__c, Hospital_2__r.Account_Number__c, Hospital_3__r.Account_Number__c
             from Contact where id = :c.Id];
         if(c.AccountId != null){
             accMap.put(c.AccountId,c.Account.Name);
             accISRMap.put(c.AccountId,c.Account.Inside_Sales_Rep__c);
         }
         if(c.Hospital__c != null){
             accMap.put(c.Hospital__c, c.Hospital__r.Name);
             accISRMap.put(c.Hospital__c,c.Hospital__r.Inside_Sales_Rep__c);
         }
         if(c.Hospital_2__c != null){
             accMap.put(c.Hospital_2__c, c.Hospital_2__r.Name);
             accISRMap.put(c.Hospital_2__c,c.Hospital_2__r.Inside_Sales_Rep__c);
         }
         if(c.Hospital_3__c != null){
             accMap.put(c.Hospital_3__c, c.Hospital_3__r.Name);
             accISRMap.put(c.Hospital_3__c,c.Hospital_3__r.Inside_Sales_Rep__c);
         }

         accOptions = new List<SelectOption>();
         for(Id i : accMap.keySet()){
             accOptions.add(new SelectOption(i,accMap.get(i)));
         }
         Id recTypeId = [select Id from RecordType where name = 'Sales Lead' and sobjecttype = 'Lead'].Id;
         l = new Lead(firstname = c.firstname, lastname = c.lastname, phone = c.phone, email = c.email, Street = c.mailingstreet, city = c.mailingcity,
                     state = c.mailingstate, country = c.mailingcountry, postalcode = c.mailingpostalcode, recordtypeid = recTypeId);
         if(accMap.size() == 1){
             for(Id i : accMap.keySet())
             l.Existing_Account_Name__c = i;
         }
         getProdPortfolioOptions();
         getSalesOpportunity();
    }
    
    public List<SelectOption> getProdPortfolioOptions(){
        prodPortfolioOptions = new List<SelectOption>();
        Schema.DescribeFieldResult dfr = Lead.Product_Portofolio__c.getDescribe();
        List<Schema.PicklistEntry> pickValList = dfr.getPicklistValues();
        for(Schema.PicklistEntry ple : pickValList){
            prodPortfolioOptions.add(new SelectOption(ple.label,ple.value));
        }

        return prodPortfolioOptions;
    }
    
    public List<SelectOption> getSalesOpportunity(){
        salesOpptyOptions = new List<SelectOption>();
        Schema.DescribeFieldResult dfr = Lead.Sales_Opportunity__c.getDescribe();
        List<Schema.PicklistEntry> pickValList = dfr.getPicklistValues();
        for(Schema.PicklistEntry ple : pickValList){
            salesOpptyOptions.add(new SelectOption(ple.label,ple.value));
        }
        return salesOpptyOptions;
    }
    
    public PageReference onSave(){
        List<Lead> existingLeads = [select id from Lead where Existing_Account_Name__c = :l.Existing_Account_Name__c and Product_Portofolio__c = :l.Product_Portofolio__c and Sales_Opportunity__c = :l.Sales_Opportunity__c and CreatedDate = THIS_QUARTER];
        if(existingLeads.size() > 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There is already a lead for this account for this Product Portofolio and Sales Opportunity combination.'));
            return null;
        }
        l.company = accMap.get(l.Existing_Account_Name__c);
        Id ISRQueueId = [select id from group where name = 'Inside Sales Leads'].id;
        Id ownerId = accISRMap.get(l.Existing_Account_Name__c) != null ? accISRMap.get(l.Existing_Account_Name__c) : ISRQueueId ;
        l.ownerId = ownerId ;
        //selectedSalesOpportunity = selectedSalesOpportunity.substring(1,selectedSalesOpportunity.indexOf(']'));
        if(selectedSalesOpportunity != null){
            selectedSalesOpportunity = selectedSalesOpportunity.replace('[','');
            selectedSalesOpportunity = selectedSalesOpportunity.replace(']','');
            selectedSalesOpportunity = selectedSalesOpportunity.replace(',',';'); 
            l.Sales_Opportunity__c = selectedSalesOpportunity ;
        }
        //selectedProdPortfolio = selectedProdPortfolio.substring(1,selectedSalesOpportunity.indexOf(']'));
        if(selectedProdPortfolio != null){
            selectedProdPortfolio = selectedProdPortfolio.replace('[','');
            selectedProdPortfolio = selectedProdPortfolio.replace(']','');
            selectedProdPortfolio = selectedProdPortfolio.replace(',',';'); 
            l.Product_Portofolio__c = selectedProdPortfolio ;
        }
        
        
        System.debug('Product Portfolio: '+l.Product_Portofolio__c);
        
        insert l;
        return (new PageReference('/'+l.Id));
    }
    public PageReference cancel(){
        return (new PageReference('/'+c.Id));

    }
    public Boolean isSF1 {
        get {                   
            if(String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) ||
                String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) ||
                ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
                (ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone') )
            ) {
                return true;
            }else{
                return false;
            }
        }
    }
}