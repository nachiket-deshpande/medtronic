public class LeadOwnerUpdateController { 

    public Lead leadObject; 
    public LeadOwnerUpdateController(Apexpages.StandardController con) 
{ 
      this.leadObject = (Lead) con.getRecord(); 
  } 

public void UpdateLeadOwner() 
  { 
           Apexpages.Message msg = new Apexpages.Message(Apexpages.Severity.CONFIRM, 'Changes saved successfully!','');  
           Apexpages.Message error_msg = new Apexpages.Message(Apexpages.Severity.Error, 'An error occurred while saving changes !','');  
	try{  
      		update this.leadObject;  
            Apexpages.addMessage(msg);  
       } catch(Exception e){  
                Apexpages.addMessage(error_msg);  
                System.debug('@@@@ calling save on LeadOwnerUpdateController. Following error occured while saving changes: ' + e);  
           }  
  } 
}