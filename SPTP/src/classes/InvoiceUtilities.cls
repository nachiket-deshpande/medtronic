/*
Created: 25 Jan 2013
Author:  Max Rudman
Purpose: 

Modified: 5 Nov 2014
Author: Appirio - Ben Lorenz
Purpose: refactored to accomodate single event handler trigger pattern,
refactored method setInvoiceFiscalDate to accomodate new pattern,
added new method for rep lookup by zip
*/

public class InvoiceUtilities {
    
    public Invoice2__c[] invoices_new = new Invoice2__c[]{};
        public Invoice2__c[] invoices_old = new Invoice2__c[]{};
            public Map <ID, Invoice2__c> newMap = new Map<ID, Invoice2__c>{};
                public Map <ID, Invoice2__c> oldMap = new Map<ID, Invoice2__c>{};
                    
                    public InvoiceUtilities(Invoice2__c[] triggered, Invoice2__c[] triggeredFrom,
                                            Map<ID,Invoice2__c> triggerNewMap, Map<ID,Invoice2__c> triggerOldMap){
                                                invoices_new = triggered;
                                                invoices_old = triggeredFrom;
                                                newMap = triggerNewMap;
                                                oldMap = triggerOldMap;
                                            }
    
    
    
    
    public void sendChatterNotificationforInvoice() {
        List<Invoice2__c> invoiceIds = new List <Invoice2__c>();
      //to restrict to Heartland region: 
        List<Invoice2__c> trigInvoices = [select name, id, BillTo__c, BillTo__r.Account_Region__c from Invoice2__c where id in: invoices_new];
        Set <id> heartlandInvIDs = new Set<Id>();
        for (Invoice2__c i: trigInvoices){
            if (i.billto__r.account_region__c=='Heartland'){
                heartlandInvIds.add(i.id);
            }
        }
        
        for (Invoice2__c invoice: invoices_new) {
            if ((invoice.LineTotal__c >= 5000) && (invoice.Send_Notification__c ==True) && (oldmap.get(invoice.id).Send_Notification__c == False) && (invoice.InvoiceDate__c.daysbetween(system.today()) <=4) && heartlandInvIds.contains(invoice.id)) {
                invoiceIds.add(invoice);
                system.debug('Region: '+invoice.billto__r.Account_Region__c);
            }
        } 
        if( invoiceIds.size() == 0 ) {
            return;
        }  
        List<InvoiceLine__c> invlines = [select name, id, invoice__c, SalesRep__c, SalesRep__r.UserRole.Name, invoice__r.LineTotal__c, quantity__c, ItemDescription1__c, ExtendedPrice__c, 
                                         SalesRep__r.Name, SalesRep__r.managerid, SalesRep__r.manager.managerid from InvoiceLine__c where invoice__c in: invoiceIDs and SalesRep__c != null];
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();  
        for( Invoice2__c invoice : invoiceIds ) {
            Set <id> atmentionReps = new Set <ID>(); 
            Set <id> atmentionManagers = new Set <ID>(); 
            for (InvoiceLine__c il :invlines){
                if (il.invoice__c == invoice.id){
                    atmentionReps.add(il.SalesRep__c);
                    atmentionManagers.add(il.SalesRep__r.managerid);
                    if (il.invoice__r.LineTotal__c >=20000){
                        atmentionManagers.add(il.SalesRep__r.manager.managerid);
                    }
                }
            }
            ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
            input.subjectId = invoice.id;
            ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
            body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = 'Congratulations ';
            body.messageSegments.add(textSegment);

            ConnectApi.TextSegmentInput textSegmentSpace = new ConnectApi.TextSegmentInput();
            textSegmentSpace.text = ' ';  
            for(ID userId : atmentionReps){  
                ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();  
                mentionSegment.id = userId;  
                body.messageSegments.add(mentionSegment);  
                body.messageSegments.add(textSegmentSpace);    
              }  
            ConnectApi.TextSegmentInput textSegment2 = new ConnectApi.TextSegmentInput();
            textSegment2.text = '! \nInvoice ' + Invoice.name + ', worth $'+ invoice.LineTotal__c + ' for '+ invoice.SoldToName__c +' was just received. \n\n ';
            body.messageSegments.add(textSegment2);

            for(ID userId2 : atmentionManagers){  
                ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();  
                mentionSegment.id = userId2;  
                body.messageSegments.add(mentionSegment);  
                body.messageSegments.add(textSegmentSpace);    
            }    
            input.body = body;
            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
            batchInputs.add(batchInput);
        }
        ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
    }
    
    
    
    
    
    
    
    
    
    
    public static void setAccountHaloFlex(List<Id> invoiceIds) {
        if( invoiceIds.size() == 0 ) {
            return;
        }  
        List<Invoice2__c> invoices = [SELECT BillTo__c from Invoice2__c where Id IN :invoiceIds AND BillTo__c != null];
        List<Account> accounts = new List<Account>();
        for( Invoice2__c invoice : invoices ) {
            Account account = new Account(Id = invoice.BillTo__c, HALOFlex_Account__c = true);
            accounts.add(account);
        }
        update accounts;
    }
    public static void setAccountDateGeneratorActivated(List<Id> invoiceIds) {
        if( invoiceIds.size() == 0 ) {
            return;
        }  
        List<Invoice2__c> invoices = [SELECT BillTo__c, InvoiceDate__c from Invoice2__c where Id IN :invoiceIds AND BillTo__c != null];
        List<Account> accounts = new List<Account>();
        for( Invoice2__c invoice : invoices ) {
            Account account = new Account(Id = invoice.BillTo__c, Date_Activated__c = invoice.InvoiceDate__c);
            accounts.add(account);
        }
        update accounts;
    }
    
    
    public static void setAccountSB3Purchased(List<Id> invoiceIds) {
        if( invoiceIds.size() == 0 ) {
            return;
        }  
        List<Invoice2__c> invoices = [SELECT BillTo__c, BillTo__r.Full_Conversion__c, BillTo__r.SB3_Purchased__c,BillTo__r.DR3_Conversion__c ,
                                      BillTo__r.Rapid_SW_Purchased__c from Invoice2__c where Id IN :invoiceIds AND BillTo__c != null];
        Set<Account> accounts = new Set<Account>();
        for( Invoice2__c invoice : invoices ) {
            Account account = new Account(Id = invoice.BillTo__c, SB3_Purchased__c = True);
            if (invoice.BillTo__r.DR3_Conversion__c && invoice.BillTo__r.Rapid_SW_Purchased__c)  {
                account.Full_Conversion__c = True;   }
            accounts.add(account);
        }
        List <Account> accountsList = new List <Account>(accounts);   
        update accountsList;
    }    
    
    public static void setAccountDR3Conversion(List<Id> invoiceIds) {
        if( invoiceIds.size() == 0 ) {
            return;
        }  
        List<Invoice2__c> invoices = [SELECT BillTo__c, BillTo__r.Full_Conversion__c, BillTo__r.SB3_Purchased__c,BillTo__r.DR3_Conversion__c ,
                                      BillTo__r.Rapid_SW_Purchased__c from Invoice2__c where Id IN :invoiceIds AND BillTo__c != null];
        Set<Account> accounts = new Set<Account>();
        for( Invoice2__c invoice : invoices ) {
            Account account = new Account(Id = invoice.BillTo__c , DR3_Conversion__c = True);
            if (invoice.BillTo__r.SB3_Purchased__c && invoice.BillTo__r.Rapid_SW_Purchased__c)  {
                account.Full_Conversion__c = True;   }
            accounts.add(account);
        }
        List <Account> accountsList = new List <Account>(accounts);   
        update accountsList;
    }    
    
    
    public static void setAccountRapidSWPurchased(List<Id> invoiceIds) {
        if( invoiceIds.size() == 0 ) {
            return;
        }  
        List<Invoice2__c> invoices = [SELECT BillTo__c, BillTo__r.Full_Conversion__c, BillTo__r.SB3_Purchased__c,BillTo__r.DR3_Conversion__c ,
                                      BillTo__r.Rapid_SW_Purchased__c from Invoice2__c where Id IN :invoiceIds AND BillTo__c != null];
        Set<Account> accounts = new Set<Account>();
        for( Invoice2__c invoice : invoices ) {
            Account account = new Account(Id = invoice.BillTo__c, Rapid_SW_Purchased__c = True);
            if (invoice.BillTo__r.SB3_Purchased__c && invoice.BillTo__r.DR3_Conversion__c)  {
                account.Full_Conversion__c = True;   }  
            accounts.add(account);
        }
        List <Account> accountsList = new List <Account>(accounts);   
        update accountsList;
    }        
    
    
    
    public static void setAccountPurchasedBravoRecorderSinceJuly2015(List<Id> invoiceIds) {
        if( invoiceIds.size() == 0 ) {
            return;
        }  
        List<Invoice2__c> invoices = [SELECT BillTo__c, BillTo__r.Purchased_Bravo_Recorder_since_July2015__c from Invoice2__c where Id IN :invoiceIds AND BillTo__c != null];
        Set<Account> accounts = new Set<Account>();
        for( Invoice2__c invoice : invoices ) {
            Account account = new Account(Id = invoice.BillTo__c, Purchased_Bravo_Recorder_since_July2015__c = True);
            accounts.add(account);
        }
        List <Account> accountsList = new List <Account>(accounts);   
        update accountsList;
    }        
    
    
    
    public static void setAccountBeaconAccountAsOf(List<Id> invoiceIds) {
        if( invoiceIds.size() == 0 ) {
            return;
        }  
        List<Invoice2__c> invoices = [SELECT BillTo__c, InvoiceDate__c from Invoice2__c where Id IN :invoiceIds AND BillTo__c != null];
        Set<Account> accounts = new Set<Account>();
        for( Invoice2__c invoice : invoices ) {
            Account account = new Account(Id = invoice.BillTo__c, Beacon_Account_As_Of__c = invoice.InvoiceDate__c);
            accounts.add(account);
        }
        List <Account> accountsList = new List <Account>(accounts);   
        update accountsList;
    }
    
    
    public void setInvoiceFiscalDate() {
        List<Invoice2__c> invoices = new List<Invoice2__c>();
        for( Invoice2__c invoice : invoices_new ) {
            if( invoice.Temp_Trigger__c || newMap == null || ( invoice.InvoiceDate__c != oldMap.get(invoice.Id).InvoiceDate__c )) {
                invoices.add(invoice);
            }
        }
        if( invoices.size() == 0 ) {
            return;
        }
        
        List<Period> periods = [SELECT StartDate, EndDate, Number, FiscalYearSettings.Name FROM Period WHERE Type = 'Month'];
        List<Period> quarterPeriods = [SELECT StartDate, EndDate, Number FROM Period WHERE Type = 'Quarter'];
        for( Invoice2__c invoice : invoices) {
            if( invoice.InvoiceDate__c == null ) {
                invoice.FP__c = 0;
                invoice.FY__c = 0;
                invoice.FQ__c = 0;
                continue;
            }
            Period period;
            for( Period curPeriod : periods ) {
                if( invoice.InvoiceDate__c >= curPeriod.StartDate && invoice.InvoiceDate__c <= curPeriod.EndDate  ) {
                    period = curPeriod;
                    break;
                }
            }
            if( period != null ) {
                invoice.FP__c = period.Number;
                try {
                    invoice.FY__c = Integer.valueOf(period.FiscalYearSettings.Name);
                } catch(Exception e) {
                    invoice.FY__c = 0;
                }
            }
            Period quarterPeriod;
            for( Period curQuarterPeriod : quarterPeriods ) {
                if( invoice.InvoiceDate__c >= curQuarterPeriod.StartDate && invoice.InvoiceDate__c <= curQuarterPeriod.EndDate  ) {
                    quarterPeriod = curQuarterPeriod;
                    break;
                }
            }
            if( quarterPeriod != null ) {
                invoice.FQ__c = quarterPeriod.Number;
            }
        }
    }
}