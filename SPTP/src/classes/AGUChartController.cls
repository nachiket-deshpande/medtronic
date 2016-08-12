/**
 * Custom controller that generates "Rolling 90-day AGU" chart. Calculated numbers are fed into
 * Google Visualization project to genertaed Google chart.
 * 
 * @author Max Rudman
 * @since 5/28/2009
 */
public with sharing class AGUChartController {
    private Decimal totalAGU = 0;
    
    /**
     * Returns JSON-encoded string that contains chart data: HALO90 AGU and HALO360 AGU for the past 90
     * days. 
     */
    public String getAGU() {
        Map<Id,Decimal> agu90ByRep = new Map<Id,Decimal>();
        Map<Id,Decimal> agu360ByRep = new Map<Id,Decimal>();
        Decimal agu90 = 0;
        Decimal agu360 = 0;
        Set<Id> repIds = new Set<Id>();
        Date start = System.today().addDays(-90);
        /* for (Commission__c c : [SELECT AGU90__c, AGU360__c, SalesRep__c FROM Commission__c WHERE Period__c > :start]) {
            agu360ByRep.put(c.SalesRep__c, agu360);
            if (c.AGU360__c != null) {
                agu360 += c.AGU360__c;
            }
            if (c.AGU90__c != null) {
                agu90 += c.AGU90__c;
            }
            repIds.add(c.SalesRep__c);
        } */
        
        //for (Commission__c c : [SELECT SalesRep__c FROM Commission__c WHERE Period__c > :start AND SalesRep__r.UserRoleId NOT IN ('00E40000000sihC','00E40000000sih9')]) {
        for (Commission__c c : [SELECT SalesRep__c FROM Commission__c WHERE Period__c > :start AND SalesRep__r.UserRoleId NOT IN ('00E40000000sihC','00E40000000sih9')]) {
            // Build the list of rep IDs; it'd be better if invoices were owned by reps
            repIds.add(c.SalesRep__c);
        }
        
        Integer accounts90Base = [SELECT count() FROM Account WHERE Profile__c = true AND Profile_Date__c <= :start AND HALO_90_Purchase_Date__c < :start AND Focal_Catheter_User__c = true AND OwnerId IN :repIds];
        Integer accounts360Base = [SELECT count() FROM Account WHERE Profile__c = true AND Profile_Date__c <= :start AND HALO_360_Purchase_Date__c < :start AND Ablation_Balloon_User__c = true AND OwnerId IN :repIds];
        
        Set<Date> new90Dates = new Set<Date>();
        Set<Date> new360Dates = new Set<Date>();
        
        for (Account acct : [SELECT Profile_Date__c, Halo_90_Purchase_Date__c FROM Account WHERE Profile__c = true AND Profile_Date__c >= :start AND Focal_Catheter_User__c = true AND HALO_90_Purchase_Date__c >= :start AND OwnerId IN :repIds]) {
          if (acct.Profile_Date__c > acct.HALO_90_Purchase_Date__c) {
                new90Dates.add(acct.Profile_Date__c);
            } else {
                new90Dates.add(acct.HALO_90_Purchase_Date__c);
            }
        }
        
        for (Account acct : [SELECT Profile_Date__c, Halo_360_Purchase_Date__c FROM Account WHERE Profile__c = true AND Profile_Date__c >= :start AND Ablation_Balloon_User__c = true AND HALO_360_Purchase_Date__c >= :start AND OwnerId IN :repIds]) {
            if (acct.Profile_Date__c > acct.HALO_360_Purchase_Date__c) {
                new360Dates.add(acct.Profile_Date__c);
            } else {
                new360Dates.add(acct.HALO_360_Purchase_Date__c);
            }
        }
        
        Integer periodCount360 = 0;
        Integer periodCount90 = 0;
        for (InvoiceLine__c line : [SELECT Quantity__c, ExtendedPrice__c, Halo_360_Catheter__c, Halo_90_Catheter__c, Invoice__r.InvoiceDate__c, Invoice__r.Halo_90__c, Invoice__r.Halo_360__c, Invoice__r.ProfileAccount__c, Invoice__r.PrimarySalesRep__c FROM InvoiceLine__c WHERE Invoice__r.InvoiceDate__c > :start AND Invoice__r.ProfileAccount__c = true AND Invoice__r.PrimarySalesRep__c IN :repIds]) {
            
            Date invoiceDate = line.Invoice__r.InvoiceDate__c;
            if (line.Invoice__r.Halo_360__c && (line.Halo_360_Catheter__c == 'Yes') && (line.ExtendedPrice__c != 0)) {
                Decimal catheters360 = line.Quantity__c;
                Integer accounts360 = accounts360Base + countDatesBeforeOrOn(new360Dates,invoiceDate);
                if (accounts360 > 0) {
                    agu360 += (catheters360.divide(accounts360,6));
                }
                periodCount360++;
            }
            
            if (line.Invoice__r.Halo_90__c && (line.Halo_90_Catheter__c == 'Yes') && (line.ExtendedPrice__c != 0)) {
                Decimal catheters90 = line.Quantity__c;
                Integer accounts90 = accounts90Base + countDatesBeforeOrOn(new90Dates,invoiceDate);
                if (accounts90 > 0) {
                    agu90 += (catheters90.divide(accounts90,6));
                }
                periodCount90++;
            }
        }
        
        //System.assert(false, repIds + ' ' + catheters90 + '/' + accounts90 + '   ' + catheters360 + '/' + accounts360);
        
        totalAGU = agu360 + agu90;
        
        GoogleViz gv = new GoogleViz();
        gv.cols = new list<GoogleViz.col> { 
            new GoogleViz.Col('col1','Type','string'),
            new GoogleViz.Col('col2','AGU','number')
        };
        
        GoogleViz.row r = new GoogleViz.row();
        r.cells.add ( new GoogleViz.cell('HALO90') );
        r.cells.add ( new GoogleViz.cell(agu90) );
        gv.addRow( r );
        
        r = new GoogleViz.row();
        r.cells.add ( new GoogleViz.cell('HALO360') );
        r.cells.add ( new GoogleViz.cell(agu360) );
        gv.addRow( r );
        
        return gv.toJsonString();
    }
    
    private Integer countDatesBeforeOrOn(Set<Date> dates, Date before) {
        Integer result = 0;
        for (Date d : dates) {
            if (d <= before) {
                result++;
            }
        }
        return result;
    }
    
    public Decimal getTotalAGU() {
        return totalAGU / 2;
    }
}