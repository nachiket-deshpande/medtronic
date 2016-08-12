public class InvoiceLineEventHandler {
  public InvoiceLine__c[] newLst = new InvoiceLine__c[]{};
  public InvoiceLine__c[] oldLst = new InvoiceLine__c[]{};
  public Map <ID, InvoiceLine__c> newMap = new Map<ID, InvoiceLine__c>{};
  public Map <ID, InvoiceLine__c> oldMap = new Map<ID, InvoiceLine__c>{};
   
  public InvoiceLineEventHandler(InvoiceLine__c[] triggered, InvoiceLine__c[] triggeredFrom,
                                 Map<ID,InvoiceLine__c> triggerNewMap, Map<ID,InvoiceLine__c> triggerOldMap){
    newLst = triggered;
    oldLst = triggeredFrom;
    newMap = triggerNewMap;
    oldMap = triggerOldMap;
  }

  public void setAccountHALOFlex(){
    List<Id> invoiceIds = new List<Id>();
    for( InvoiceLine__c invoiceLine : newLst) {
      if((invoiceLine.ItemNumber__c == '1190A-230A' || invoiceLine.ItemNumber__c == '1190A-115A' ) &&
        invoiceLine.Line_Type__c != 'M') {
        invoiceIds.add( invoiceLine.Invoice__c );
      }
    }
    if(invoiceIds.size() > 0)
    InvoiceUtilities.setAccountHaloFlex(invoiceIds);
  }
    
  public void setAccountDateGeneratorActivated(){
    List<Id> invoiceIds = new List<Id>();
      for( InvoiceLine__c invoiceLine : [SELECT id, ItemNumber__c,Item__c, ExtendedPrice__c, Invoice__r.BillTo__r.Date_Activated__c from InvoiceLine__c where id in: newLst]) {
      if((invoiceLine.ItemNumber__c == '1190A-115A' || invoiceLine.ItemNumber__c == '1190A-115A-R' || invoiceLine.ItemNumber__c == '1190A-115A-01' ) &&
         invoiceLine.ExtendedPrice__c > 70000 && invoiceLine.Invoice__r.BillTo__r.Date_Activated__c ==null ) {
        invoiceIds.add( invoiceLine.Invoice__c );
      }
    }
    if(invoiceIds.size() > 0)
    InvoiceUtilities.setAccountDateGeneratorActivated(invoiceIds);
  }  
    
  public void setAccountConversion(){
    List<Id> invoiceIds_SB3 = new List<Id>();
    List<Id> invoiceIds_Rapid = new List<Id>();
    List<Id> invoiceIds_DR3 = new List<Id>();  
      for( InvoiceLine__c invoiceLine : [SELECT id, ItemNumber__c, Quantity__c, Invoice__r.BillTo__r.SB3_Purchased__c, Invoice__r.BillTo__r.Rapid_SW_Purchased__c,
                                         Invoice__r.BillTo__r.DR3_Conversion__c, Invoice__r.BillTo__r.Full_Conversion__c from InvoiceLine__c where id in: newLst]) {
                                             
      if( !invoiceLine.Invoice__r.BillTo__r.SB3_Purchased__c && (invoiceLine.ItemNumber__c == 'FGS-0498' || invoiceLine.ItemNumber__c == 'FGS-0499' ||
                                                                 invoiceLine.ItemNumber__c == 'FGS-0500' || invoiceLine.ItemNumber__c == 'FGS-0501' ||
                                                                 invoiceLine.ItemNumber__c == 'FGS-0502')) {
        invoiceIds_SB3.add( invoiceLine.Invoice__c );
      }
	 if( !invoiceLine.Invoice__r.BillTo__r.DR3_Conversion__c && (invoiceLine.ItemNumber__c == 'RFB-0347' || invoiceLine.ItemNumber__c == 'FGS-0347' )) {
        invoiceIds_DR3.add( invoiceLine.Invoice__c );
      }  
     if( !invoiceLine.Invoice__r.BillTo__r.Rapid_SW_Purchased__c && (invoiceLine.ItemNumber__c == '80138' || invoiceLine.ItemNumber__c == '80200' )) {
        invoiceIds_Rapid.add( invoiceLine.Invoice__c );
      }    
    }
    if(invoiceIds_SB3.size() > 0)
    InvoiceUtilities.setAccountSB3Purchased(invoiceIds_SB3);
    if(invoiceIds_DR3.size() > 0)
    InvoiceUtilities.setAccountDR3Conversion(invoiceIds_DR3);  
    if(invoiceIds_Rapid.size() > 0)
    InvoiceUtilities.setAccountRapidSWPurchased(invoiceIds_Rapid);  
  }  
    
    
  public void setAccountBeaconAccountAsOf(){
    List<Id> invoiceIds = new List<Id>();
      for( InvoiceLine__c invoiceLine : [SELECT id, Product_Group__c, Invoice__r.BillTo__r.Beacon_Account_As_Of__c from InvoiceLine__c where id in: newLst]) {
      if(invoiceLine.Product_Group__c == 'Beacon Disposables'  && invoiceLine.Invoice__r.BillTo__r.Beacon_Account_As_Of__c ==null ) {
        invoiceIds.add( invoiceLine.Invoice__c );
      }
    }
    if(invoiceIds.size() > 0)
    InvoiceUtilities.setAccountBeaconAccountAsOf(invoiceIds);
  }      

    public void setAccountPurchasedBravoRecorderSinceJuly2015(){
    List<Id> invoiceIds = new List<Id>();
        
      for( InvoiceLine__c invoiceLine : [SELECT id, ItemNumber__c, Invoice__r.BillTo__r.Purchased_Bravo_Recorder_since_July2015__c, Invoice__r.InvoiceDate__c from InvoiceLine__c where id in: newLst]) {
      if( !invoiceLine.Invoice__r.BillTo__r.Purchased_Bravo_Recorder_since_July2015__c && (invoiceLine.ItemNumber__c == 'RFB-0450' || invoiceLine.ItemNumber__c == 'FGS-0450' ) && 
        (invoiceLine.Invoice__r.InvoiceDate__c > date.parse('07/01/2015'))) {
        invoiceIds.add( invoiceLine.Invoice__c );
      }
    }        
   if(invoiceIds.size() > 0)
    InvoiceUtilities.setAccountPurchasedBravoRecorderSinceJuly2015(invoiceIds);
  }     
    
  public void calculateCommission(){
    Map<Id, String> invoiceLine2CommKeyMap = new Map<Id, String>();
    Map<Id, String> dualCommKeyMap = new Map<Id,String>();
    Map<Id, String> areaBeaconCommKeyMap = new Map<Id,String>();
    Map<String, Id> terrMap = new Map<String, Id>();
    List<Period> periods = [SELECT StartDate, EndDate, Number, FiscalYearSettings.Name FROM Period WHERE Type = 'Month'];
    Map<String, Commission__c> commMap = new Map<String, Commission__c>();

    for(InvoiceLine__c line : newLst){
      if(line.ExtendedPrice__c != 0 && line.ExtendedPrice__c != null && line.isCommissionable__c) {
        if(oldMap == null || line.ExtendedPrice__c != oldMap.get(line.Id).ExtendedPrice__c) {
          invoiceLine2CommKeyMap.put(line.Id,null);
        }
      }
    }

    for(Territory2 t : [SELECT Id,Name FROM Territory2]){terrMap.put(t.Name,t.Id);}

    InvoiceLine__c [] lineLst = [SELECT SalesRep__c,ExtendedPrice__c, Invoice__r.InvoiceDate__c, 
                                               Invoice__r.BillTo__r.Capital_Territory__c,
                                               Invoice__r.BillTo__r.Diagnostic_Territory__c,
                                               Invoice__r.BillTo__r.Interventional_Territory__c,
                                 			   Invoice__r.BillTo__r.Diagnostic_Inside_Sales_Territory__c,
                                 			   Invoice__r.BillTo__r.Inside_Sales_Territory__c,
                                 			   Invoice__r.BillTo__r.Key_Accounts_Territory__c,
                                               Product__r.Commissionable__c, Product__r.Sales_Hierarchy__c, 
                                               Product__r.Product_Group__c, Product__r.Product_Category__c, Product__r.Product_Line__c, 
                                 			   Invoice__r.Fiscal_Year__c, Invoice__r.Fiscal_Quarter__c,
                                 			   Invoice__r.BillTo__r.Account_Region__c,
                                 			   Invoice__r.BillTo__r.Date_Activated__c 
                                        FROM InvoiceLine__c 
                                        WHERE ID IN : invoiceLine2CommKeyMap.keyset()];
    for (InvoiceLine__c il : lineLst) {
      Id terrID;

        if((il.Product__r.Product_Category__c =='Barrx_Service Plan')
           || (il.Product__r.Product_Category__c =='PillCam Service Plan'))
            terrID = terrMap.get(il.Invoice__r.BillTo__r.Inside_Sales_Territory__c);
        else if(il.Product__r.Product_Category__c =='Manometry_Multi Use Catheter')
            terrID = terrMap.get(il.Invoice__r.BillTo__r.Inside_Sales_Territory__c);
        else if(il.Product__r.Sales_Hierarchy__c=='Capital') 
            terrID = terrMap.get(il.Invoice__r.BillTo__r.Capital_Territory__c);
        else if ((il.Product__r.Sales_Hierarchy__c=='Diagnostic') &&
                 !(il.Invoice__r.BillTo__r.Diagnostic_Inside_Sales_Territory__c == null))
            terrID = terrMap.get(il.Invoice__r.BillTo__r.Inside_Sales_Territory__c);
        else if ((il.Product__r.Sales_Hierarchy__c=='Diagnostic') &&
                 (il.Invoice__r.BillTo__r.Diagnostic_Inside_Sales_Territory__c == null))
            terrID = terrMap.get(il.Invoice__r.BillTo__r.Diagnostic_Territory__c);
         else if (il.Product__r.Sales_Hierarchy__c=='Interventional') 
            terrID = terrMap.get(il.Invoice__r.BillTo__r.Interventional_Territory__c);
        if (terrID != null) {
        for( Period curPeriod : periods ) {
          string periodKey = '_' + curPeriod.Number + '_' + curPeriod.FiscalYearSettings.Name;
          if(il.Invoice__r.InvoiceDate__c >= curPeriod.StartDate && il.Invoice__r.InvoiceDate__c <= curPeriod.EndDate) {
            invoiceLine2CommKeyMap.put(il.Id, terrID + periodKey);
            /*
              Beacon products are dual credit products (Interventional and KAMs)
            */
            if (il.Product__r.Product_Group__c == 'Beacon Disposables') {
              dualCommKeyMap.put(il.Id,terrMap.get(il.Invoice__r.BillTo__r.Key_Accounts_Territory__c) + periodKey);
              if (il.Invoice__r.BillTo__r.Key_Accounts_Territory__c == 'Central (K)') {
              areaBeaconCommKeyMap.put(il.Id,terrMap.get('Western (K)') + periodKey); }
              if (il.Invoice__r.BillTo__r.Key_Accounts_Territory__c == 'Northeast (K)') {
              areaBeaconCommKeyMap.put(il.Id,terrMap.get('Ohio Valley (K)') + periodKey); }
              if (il.Invoice__r.BillTo__r.Key_Accounts_Territory__c == 'Ohio Valley (K)') {
              areaBeaconCommKeyMap.put(il.Id,terrMap.get('Northeast (K)') + periodKey); }
              if (il.Invoice__r.BillTo__r.Key_Accounts_Territory__c == 'South (K)') {
              areaBeaconCommKeyMap.put(il.Id,terrMap.get('Southeast (K)') + periodKey); }
              if (il.Invoice__r.BillTo__r.Key_Accounts_Territory__c == 'Southeast (K)') {
              areaBeaconCommKeyMap.put(il.Id,terrMap.get('South (K)') + periodKey); }
              if (il.Invoice__r.BillTo__r.Key_Accounts_Territory__c == 'Western (K)') {
              areaBeaconCommKeyMap.put(il.Id,terrMap.get('Central (K)') + periodKey); }                
            }
            break;
          }
        }
      }
    }

    for ( Commission__c c : [SELECT Id,Key__c, CommissionedSales__c, Period__c,PillCam_Capital_Sales__c, PillCam_Disposables_Sales__c, 
                                    SmartPill_Capital_Sales__c,SmartPill_Disposables_Sales__c,Reflux_Capital_Sales__c,
                                    Reflux_Disposables_Sales__c,Barrx_Disposables_Sales__c,Beacon_Disposables_Sales__c, Beacon_Disposables_Area_Sales__c, 
                                    Manometry_Capital_Sales__c,Manometry_Disposables_Sales__c,Barrx_Capital_Sales__c,Reflux_Capital_Sales_RM__c,Manometry_Capital_Sales_RM__c,Manometry_Disposables_Sales_RM__c,RFA_Capital_Sales_RM__c
                             FROM Commission__c  
                             WHERE key__c in :invoiceLine2CommKeyMap.Values() or key__c in :dualCommKeyMap.Values() or key__c in :areaBeaconCommKeyMap.Values() ]) {
      commMap.put(c.Key__c, c);
    }
    
    if (!lineLst.isEmpty()) {
      for(InvoiceLine__c line : lineLst){
        Commission__c comm = commMap.get(invoiceLine2CommKeyMap.get(line.Id));
        Commission__c comm2 = commMap.get(dualCommKeyMap.get(line.Id));
        Commission__c comm3 = commMap.get(areaBeaconCommKeyMap.get(line.Id));  
  //      line.Primary_Commission_Record__c = comm.id;  
        if (comm !=  null) {
          if (line.Product__r.Product_Group__c == 'PillCam Capital') {
            comm.PillCam_Capital_Sales__c += line.ExtendedPrice__c;
            comm.CommissionedSales__c += line.ExtendedPrice__c;
          } else if(line.Product__r.Product_Group__c == 'PillCam Disposables') {
            comm.PillCam_Disposables_Sales__c += line.ExtendedPrice__c;
            comm.CommissionedSales__c += line.ExtendedPrice__c;
          } else if (line.Product__r.Product_Group__c == 'SmartPill Capital') {
            comm.SmartPill_Capital_Sales__c += line.ExtendedPrice__c;
            comm.CommissionedSales__c += line.ExtendedPrice__c;
          } else if (line.Product__r.Product_Group__c == 'SmartPill Disposables') {
            comm.SmartPill_Disposables_Sales__c += line.ExtendedPrice__c;
            comm.CommissionedSales__c += line.ExtendedPrice__c;
          } else if (line.Product__r.Product_Group__c == 'Reflux Disposables'){
            comm.Reflux_Disposables_Sales__c += line.ExtendedPrice__c;
            comm.CommissionedSales__c += line.ExtendedPrice__c;
          } else if (line.Product__r.Product_Group__c == 'Barrx Disposables'){
            comm.Barrx_Disposables_Sales__c += line.ExtendedPrice__c;
            comm.CommissionedSales__c += line.ExtendedPrice__c;
          } else if (line.Product__r.Product_Group__c == 'Beacon Disposables'){
            comm.Beacon_Disposables_Sales__c += line.ExtendedPrice__c;
            comm.CommissionedSales__c += line.ExtendedPrice__c;
            if (comm2 !=  null) {
			comm2.Beacon_Disposables_Sales__c += line.ExtendedPrice__c;
            comm2.CommissionedSales__c += line.ExtendedPrice__c;
            comm2.Beacon_Disposables_Area_Sales__c+=line.ExtendedPrice__c;    
            commMap.put(dualCommKeyMap.get(line.Id),comm2);}
            if (comm3 !=  null) {
			comm3.Beacon_Disposables_Area_Sales__c+=line.ExtendedPrice__c;    
            commMap.put(areaBeaconCommKeyMap.get(line.Id),comm3);}  
          } else if (line.Product__r.Product_Group__c == 'Reflux Capital'){
            comm.Reflux_Capital_Sales__c += line.ExtendedPrice__c;
            comm.CommissionedSales__c += line.ExtendedPrice__c;
          } else if (line.Product__r.Product_Group__c == 'Manometry Capital') {
            comm.Manometry_Capital_Sales__c += line.ExtendedPrice__c;
            comm.CommissionedSales__c += line.ExtendedPrice__c;
            comm.Manometry_Capital_Sales_RM__c += line.ExtendedPrice__c;  
          } else if (line.Product__r.Product_Group__c == 'Manometry Disposables') {
            comm.Manometry_Disposables_Sales__c += line.ExtendedPrice__c;
            comm.CommissionedSales__c += line.ExtendedPrice__c;
            comm.Manometry_Disposables_Sales_RM__c += line.ExtendedPrice__c;  

          } else if (line.Product__r.Product_Group__c == 'Barrx Capital') { 
           if ((line.Product__r.Product_Category__c =='Barrx_Service Plan'))
           {
           comm.Barrx_Disposables_Sales__c += line.ExtendedPrice__c;
           comm.CommissionedSales__c += line.ExtendedPrice__c;    
           } 
           else  
           {
            comm.Barrx_Capital_Sales__c += line.ExtendedPrice__c;
            comm.CommissionedSales__c += line.ExtendedPrice__c;
            comm.RFA_Capital_Sales_RM__c += line.ExtendedPrice__c;  
           }
          }
              else {
            system.debug('### product group on invoice line does not match');
          }
          commMap.put(invoiceLine2CommKeyMap.get(line.Id),comm);
        } else {
          system.debug('### no comm record');
        }
      }
      update commMap.values();

 //     update linelst; 
    } else {
      system.debug('### no eligible invoice lines');
    }
  }

    
  public void assignProducts() {
    Set<String> itemNos = new Set<String>();
    Map<String,Id> productsByCode = new Map<String,Id>();
    for (InvoiceLine__c il : newLst) {
      itemNos.add(il.ItemNumber__c);
    }
    for (Product2 product : [SELECT Id, ProductCode, AGU_Classification__c FROM Product2 WHERE ProductCode IN :itemNos]) {
      productsByCode.put(product.ProductCode, product.Id);
    }
    for (InvoiceLine__c line : newLst) {
      if (line.Product__c == null){
        line.Product__c = productsByCode.get(line.ItemNumber__c);
      }
    }
  }
}


/*
 * commission calculator for FY16:
 * 
 *   public void calculateCommission(){
    Map<Id, String> invoiceLine2CommKeyMap = new Map<Id, String>();
    Map<Id, String> dualCommKeyMap = new Map<Id,String>();
    Map<Id, String> dualRegionCommKeyMap = new Map<Id,String>();  
    Map<String, Id> terrMap = new Map<String, Id>();
    List<Period> periods = [SELECT StartDate, EndDate, Number, FiscalYearSettings.Name FROM Period WHERE Type = 'Month'];
    Map<String, Commission__c> commMap = new Map<String, Commission__c>();

    for(InvoiceLine__c line : newLst){
      if(line.ExtendedPrice__c != 0 && line.ExtendedPrice__c != null && line.isCommissionable__c) {
        if(oldMap == null || line.ExtendedPrice__c != oldMap.get(line.Id).ExtendedPrice__c) {
          invoiceLine2CommKeyMap.put(line.Id,null);
        }
      }
    }

    for(Territory2 t : [SELECT Id,Name FROM Territory2]){terrMap.put(t.Name,t.Id);}

    InvoiceLine__c [] lineLst = [SELECT SalesRep__c,ExtendedPrice__c, Invoice__r.InvoiceDate__c, 
                                               Invoice__r.BillTo__r.Capital_Territory__c,
                                               Invoice__r.BillTo__r.Diagnostic_Territory__c,
                                               Invoice__r.BillTo__r.Interventional_Territory__c,
                                               Product__r.Commissionable__c, Product__r.Sales_Hierarchy__c, 
                                               Product__r.Product_Group__c, Product__r.Product_Category__c, 
                                 			   Invoice__r.Fiscal_Year__c, Invoice__r.Fiscal_Quarter__c,
                                 			   Invoice__r.BillTo__r.Account_Region__c,
                                 			   Invoice__r.BillTo__r.Date_Activated__c
                                        FROM InvoiceLine__c 
                                        WHERE ID IN : invoiceLine2CommKeyMap.keyset()];
    for (InvoiceLine__c il : lineLst) {
      Id terrID;
      Id terrIDdualRegion; 
        
        if ((il.Invoice__r.BillTo__r.Capital_Territory__c=='San Francisco (C)')&& (il.Invoice__r.BillTo__r.Account_Region__c=='Pacific'))
            terrIDdualRegion=terrMap.get('Pacific'); 
        if ((il.Invoice__r.BillTo__r.Capital_Territory__c=='Pittsburgh (C)')&& (il.Invoice__r.BillTo__r.Account_Region__c=='MidAtlantic'))
            terrIDdualRegion=terrMap.get('MidAtlantic');   
        if ((il.Invoice__r.BillTo__r.Capital_Territory__c=='Washington DC (C)')&& (il.Invoice__r.BillTo__r.Account_Region__c=='Capital'))
            terrIDdualRegion=terrMap.get('Capital');
   // added service plan adjustment for the current fiscal year as follows: 
   // If the Product Category = Barrx_Service Plan and Account.Date Generator Activated < 04/29/2015
   // and the Invoice Date >= 09/01/2015 - !!!manual adjustments were done before this date 
   // Then the invoice Line Extended Price is added to the Interventional rep instead of the Capital one
   // under the RFA Disposable Sales field
        
   //   if(il.Product__r.Sales_Hierarchy__c=='Capital') 
        if((il.Product__r.Sales_Hierarchy__c=='Capital') 
           && !((il.Product__r.Product_Category__c =='Barrx_Service Plan') &&
         (il.invoice__r.InvoiceDate__c >= date.parse('09/01/2015') &&
         (il.invoice__r.BillTo__r.Date_Activated__c < date.parse('04/29/2015')))))
      terrID = terrMap.get(il.Invoice__r.BillTo__r.Capital_Territory__c);
      else if (il.Product__r.Sales_Hierarchy__c=='Diagnostic')
        terrID = terrMap.get(il.Invoice__r.BillTo__r.Diagnostic_Territory__c);
      else if ((il.Product__r.Sales_Hierarchy__c=='Interventional') 
          || ((il.Product__r.Product_Category__c =='Barrx_Service Plan') &&
         (il.invoice__r.InvoiceDate__c >= date.parse('09/01/2015') &&
         (il.invoice__r.BillTo__r.Date_Activated__c < date.parse('04/29/2015')))))
        terrID = terrMap.get(il.Invoice__r.BillTo__r.Interventional_Territory__c);
      if (terrID != null) {
        for( Period curPeriod : periods ) {
          string periodKey = '_' + curPeriod.Number + '_' + curPeriod.FiscalYearSettings.Name;
          if(il.Invoice__r.InvoiceDate__c >= curPeriod.StartDate && il.Invoice__r.InvoiceDate__c <= curPeriod.EndDate) {
            invoiceLine2CommKeyMap.put(il.Id, terrID + periodKey);
            //
            //  reflux capital products are dual comp'd to Capital and intervential territory
            //  sales hierarchy for capital reflux capital product is interventional so need 
            //  to add commission key for Capital territory to separate map so we do not overwrite 
             // the key for the interventional territory already in the map
            
            if (il.Product__r.Product_Group__c == 'Reflux Capital') {
              dualCommKeyMap.put(il.Id,terrMap.get(il.Invoice__r.BillTo__r.Capital_Territory__c) + periodKey);
            }
             //for Capital Territories in two regions, the rep commission is calculated as usual but the RM fields are updated based on account location in the region
             //mapping the invoice line to the secondary region (rep not reporting to this RM) to properly assing RM commission
            if (terrIDdualRegion !=null) {
                dualRegionCommKeyMap.put(il.Id,terrIDdualRegion + periodKey);
              }
            break;
          }
        }
      }
    }

    for ( Commission__c c : [SELECT Key__c, CommissionedSales__c, Period__c,PillCam_Capital_Sales__c, PillCam_Disposables_Sales__c, 
                                    SmartPill_Capital_Sales__c,SmartPill_Disposables_Sales__c,Reflux_Capital_Sales__c,
                                    Reflux_Disposables_Sales__c,Barrx_Disposables_Sales__c,Beacon_Disposables_Sales__c,
                                    Manometry_Capital_Sales__c,Manometry_Disposables_Sales__c,Barrx_Capital_Sales__c,Reflux_Capital_Sales_RM__c,Manometry_Capital_Sales_RM__c,Manometry_Disposables_Sales_RM__c,RFA_Capital_Sales_RM__c
                             FROM Commission__c  
                             WHERE key__c in :invoiceLine2CommKeyMap.Values() or key__c in :dualCommKeyMap.Values() or key__c in: dualRegionCommKeyMap.Values()]) {
      commMap.put(c.Key__c, c);
    }
    
    if (!lineLst.isEmpty()) {
      for(InvoiceLine__c line : lineLst){
        Commission__c comm = commMap.get(invoiceLine2CommKeyMap.get(line.Id));
        Commission__c comm2 = commMap.get(dualCommKeyMap.get(line.Id));
        Commission__c commTer = commMap.get(dualRegionCommKeyMap.get(line.Id));  
        if (comm !=  null) {
          if (line.Product__r.Product_Group__c == 'PillCam Capital') {
            comm.PillCam_Capital_Sales__c += line.ExtendedPrice__c;
            comm.CommissionedSales__c += line.ExtendedPrice__c;
          } else if(line.Product__r.Product_Group__c == 'PillCam Disposables') {
            comm.PillCam_Disposables_Sales__c += line.ExtendedPrice__c;
            comm.CommissionedSales__c += line.ExtendedPrice__c;
          } else if (line.Product__r.Product_Group__c == 'SmartPill Capital') {
            comm.SmartPill_Capital_Sales__c += line.ExtendedPrice__c;
            comm.CommissionedSales__c += line.ExtendedPrice__c;
          } else if (line.Product__r.Product_Group__c == 'SmartPill Disposables') {
            comm.SmartPill_Disposables_Sales__c += line.ExtendedPrice__c;
            comm.CommissionedSales__c += line.ExtendedPrice__c;
          } else if (line.Product__r.Product_Group__c == 'Reflux Disposables'){
            comm.Reflux_Disposables_Sales__c += line.ExtendedPrice__c;
            comm.CommissionedSales__c += line.ExtendedPrice__c;
          } else if (line.Product__r.Product_Group__c == 'Barrx Disposables'){
            comm.Barrx_Disposables_Sales__c += line.ExtendedPrice__c;
            comm.CommissionedSales__c += line.ExtendedPrice__c;
          } else if (line.Product__r.Product_Group__c == 'Beacon Disposables'){
            comm.Beacon_Disposables_Sales__c += line.ExtendedPrice__c;
            comm.CommissionedSales__c += line.ExtendedPrice__c;
              
          } else if (line.Product__r.Product_Group__c == 'Reflux Capital'){
            comm.Reflux_Capital_Sales__c += line.ExtendedPrice__c;
            comm.CommissionedSales__c += line.ExtendedPrice__c;
            //  dual comp to capital rep - is only applied during Q1 FY2016 
              
              if ((line.Invoice__r.Fiscal_Year__c == 'FY2016') && (line.Invoice__r.Fiscal_Quarter__c == 'FQ1'))   {
                  if (comm2 != null) {
              comm2.Reflux_Capital_Sales__c += line.ExtendedPrice__c;
              comm2.CommissionedSales__c += line.ExtendedPrice__c;
                if (commTer != null) { 
                    // the sale is from an account outside the regular reporting region - Ex: Pacific 
                    commTer.Reflux_Capital_Sales_RM__c += line.ExtendedPrice__c;
                    commMap.put(dualRegionCommKeyMap.get(line.Id),commTer);
                }  else { 
                comm2.Reflux_Capital_Sales_RM__c += line.ExtendedPrice__c;  
                 }
                  
              commMap.put(dualCommKeyMap.get(line.Id),comm2);  
                      }
              }

          } else if (line.Product__r.Product_Group__c == 'Manometry Capital') {
            comm.Manometry_Capital_Sales__c += line.ExtendedPrice__c;
            comm.CommissionedSales__c += line.ExtendedPrice__c;
                if (commTer!=null) { // the sale is from an account outside the regular reporting region - Ex: Pacific 
                    commTer.Manometry_Capital_Sales_RM__c += line.ExtendedPrice__c;
                    commMap.put(dualRegionCommKeyMap.get(line.Id),commTer);
                } else {
                 comm.Manometry_Capital_Sales_RM__c += line.ExtendedPrice__c;  
                 }
          } else if (line.Product__r.Product_Group__c == 'Manometry Disposables') {
            comm.Manometry_Disposables_Sales__c += line.ExtendedPrice__c;
            comm.CommissionedSales__c += line.ExtendedPrice__c;
              if (commTer!=null) {  //the sale is from an account outside the regular reporting region - Ex: Pacific 
                    commTer.Manometry_Disposables_Sales_RM__c  += line.ExtendedPrice__c;
                    commMap.put(dualRegionCommKeyMap.get(line.Id),commTer);
                } else {
                 comm.Manometry_Disposables_Sales_RM__c += line.ExtendedPrice__c;  
                 }
          } else if (line.Product__r.Product_Group__c == 'Barrx Capital') { 
           if ((line.Product__r.Product_Category__c =='Barrx_Service Plan') &&
         (line.invoice__r.InvoiceDate__c >= date.parse('09/01/2015') &&
         (line.invoice__r.BillTo__r.Date_Activated__c < date.parse('04/29/2015'))))
           {
           comm.Barrx_Disposables_Sales__c += line.ExtendedPrice__c;
           comm.CommissionedSales__c += line.ExtendedPrice__c;    
           } 
           else  
           {
              // 
            comm.Barrx_Capital_Sales__c += line.ExtendedPrice__c;
            comm.CommissionedSales__c += line.ExtendedPrice__c;
              if (commTer!=null) { // the sale is from an account outside the regular reporting region - Ex: Pacific 
                    commTer.RFA_Capital_Sales_RM__c  += line.ExtendedPrice__c;
                    commMap.put(dualRegionCommKeyMap.get(line.Id),commTer);
                } else {
                 comm.RFA_Capital_Sales_RM__c += line.ExtendedPrice__c;  
                 }
              //
           }
          }
              else {
            system.debug('### product group on invoice line doesn not match');
          }
          commMap.put(invoiceLine2CommKeyMap.get(line.Id),comm);
        } else {
          system.debug('### no comm record');
        }
      }
      update commMap.values();
    } else {
      system.debug('### no eligible invoice lines');
    }
  }
  
 */