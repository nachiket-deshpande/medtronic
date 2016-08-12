public class BatchUtil {
   
   //Method called from the Batch class
   public wrapperObject CalculateData(Id id, String dateLiteral, Date invDate){
      
      wrapperObject temp = new wrapperObject();
      temp.Barrx_Disposable_Base = 0;
      temp.Beacon_Base = 0;
      temp.PillCam_Disposable_Base = 0;
      temp.Reflux_Disposable_Base = 0;
      temp.SmartPill_Disposable_Base = 0;
      temp.PillCam_SB = 0;
      temp.SmartPill_Capsules = 0;
      temp.RFA_Catheters = 0;
      temp.Bravo_Capsules = 0;
      String queryString = '';
      if(invDate != null){
          Date priorYearEndDate = invDate;
          Date priorYearStartDate = invDate.addYears(-1);
          queryString = 'SELECT Product__r.Product_Group__c,ExtendedPrice__c,Product__r.Product_Category__c FROM InvoiceLine__c WHERE Invoice__r.InvoiceDate__c >= :priorYearStartDate and '+
                                    ' Invoice__r.InvoiceDate__c <= :prioyYearEndDate ' + ' And Invoice__r.SAPSoldTo__c = \''+ id + '\'';
      }else{
          queryString = 'SELECT Product__r.Product_Group__c,ExtendedPrice__c,Product__r.Product_Category__c FROM InvoiceLine__c WHERE Invoice__r.InvoiceDate__c = ' + dateLiteral + ' And Invoice__r.SAPSoldTo__c = \''+ id + '\'';
      }
      System.debug('Query = '+queryString );
      for (InvoiceLine__c il : Database.query(queryString)){
      if(il.Product__r.Product_Group__c=='PillCam Disposables') {temp.PillCam_Disposable_Base+=il.ExtendedPrice__c;}
      else if(il.Product__r.Product_Group__c=='SmartPill Disposables') {temp.SmartPill_Disposable_Base+=il.ExtendedPrice__c;}
      else if(il.Product__r.Product_Group__c=='Barrx Disposables') {temp.Barrx_Disposable_Base+=il.ExtendedPrice__c;}
      else if(il.Product__r.Product_Group__c=='Reflux Disposables') {temp.Reflux_Disposable_Base+=il.ExtendedPrice__c;}
      else if(il.Product__r.Product_Group__c=='Beacon Disposables') {temp.Beacon_Base+=il.ExtendedPrice__c;}

      if(il.Product__r.Product_Category__c=='PillCam_SB Capsules'){temp.PillCam_SB++;}
      else if(il.Product__r.Product_Category__c=='PillCam_Patency Capsules'){temp.PillCam_SB++;}
      else if(il.Product__r.Product_Category__c=='SmartPill_Capsules'){temp.SmartPill_Capsules++;}
      else if(il.Product__r.Product_Category__c=='Reflux_Bravo Capsules '){temp.Bravo_Capsules++;}
      else if(il.Product__r.Product_Group__c=='Ablation Balloon'){temp.RFA_Catheters++;}
      else if(il.Product__r.Product_Group__c=='Barrx Focal'){temp.RFA_Catheters++;}
      else if(il.Product__r.Product_Group__c=='Barrx_Channel'){temp.RFA_Catheters++;}
      
    }
      return temp;
   }
   
   //Method to calculate number of working days between 2 given dates.
   public Integer calculateWorkingDaysBetweenTwoDates(Date date1,Date date2){

      List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];

      Integer allDaysBetween = date1.daysBetween(date2);
      Integer allWorkingDays=0;
      for(Integer k=0;k<allDaysBetween ;k++ ){
         if(checkifItisWorkingDay(date1.addDays(k),holidays)){
            allWorkingDays++;
         } 
      }
      
      system.debug('Number of working days -- '+allWorkingDays);
      return allWorkingDays;

   }

   public boolean checkifItisWorkingDay(Date currentDate,List<Holiday> holidays){
      Date weekStart  = currentDate.toStartofWeek();
      for(Holiday hDay:holidays){
         if(currentDate.daysBetween(hDay.ActivityDate) == 0){
            return false;
         }
      }
      if(weekStart.daysBetween(currentDate) ==0 || weekStart.daysBetween(currentDate) == 6){
         return false;
      } else 
          return true;
    }
}