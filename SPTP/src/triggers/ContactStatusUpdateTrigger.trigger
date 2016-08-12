trigger ContactStatusUpdateTrigger on Contact ( before update) {
 id InactiveAccRep = id.valueof('0014000000oznGLAAY');
 id RetiredAccRep = id.valueof('0014000000sgxYwAAI');
 id DuplicateAccRep = id.valueof('0014000001dUx44AAC');
 id DeceasedAccRep = id.valueof('0014000000sgxV9AAI');   
    
    for (Contact c: trigger.new)  {

        if(c.Contact_Status__c != Trigger.oldMap.get(c.id).Contact_Status__c) {
            if (c.Contact_Status__c == 'Inactive') {
                 c.AccountId = InactiveAccRep;
                 c.Hospital__c = null;
                 c.Hospital_2__c = null;
                 c.Hospital_3__c = null; 
                 c.ASC__c = null; 
                 c.Physician_Locator__c= False;
            }     
            else if (c.Contact_Status__c == 'Retired') {
                 c.AccountId = RetiredAccRep;
                 c.Hospital__c = null;
                 c.Hospital_2__c = null;
                 c.Hospital_3__c = null; 
                 c.ASC__c = null; 
                 c.Physician_Locator__c= False;
            }     
            else if (c.Contact_Status__c == 'Duplicate') {
                // c.AccountId = id.valueof('0011900000CDTWdAAP');
                 c.AccountId = DuplicateAccRep; 
                 c.Hospital__c = null;
                 c.Hospital_2__c = null;
                 c.Hospital_3__c = null; 
                 c.ASC__c = null; 
                 c.Physician_Locator__c= False;
            }     
            else if (c.Contact_Status__c == 'Deceased') {
                 c.AccountId = DeceasedAccRep;
                 c.Hospital__c = null;
                 c.Hospital_2__c = null;
                 c.Hospital_3__c = null; 
                 c.ASC__c = null; 
                 c.Physician_Locator__c= False;
            }     
            else if (c.Contact_Status__c == 'Active') {
                 c.Status_Change_Description__c = '';
            }                 
        }
       
        if ((c.AccountId != Trigger.oldMap.get(c.id).AccountId) && ((Trigger.oldMap.get(c.id).AccountId == InactiveAccRep) ||
           (Trigger.oldMap.get(c.id).AccountId == RetiredAccRep) || (Trigger.oldMap.get(c.id).AccountId == DuplicateAccRep) ||
           (Trigger.oldMap.get(c.id).AccountId == DeceasedAccRep)) && (c.AccountId !=InactiveAccRep) &&
            (c.AccountId !=RetiredAccRep) && (c.AccountId !=DuplicateAccRep) && (c.AccountId !=DeceasedAccRep))          {
            c.Contact_Status__c = 'Active';
            c.Status_Change_Description__c='';
        }
        
   }
}