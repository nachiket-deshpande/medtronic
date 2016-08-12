/**
  Component controller for both Contact's Account and Opp role component. The class is shared
  because of slight difference between the controller requirements for each of the two components.
  @author Antenna
*/
public with sharing class OppAccountRolesCompController {
  
  // Contact ID from component attribute 
  public Id contactId {get;set;}
    
  public OppAccountRolesCompController() {}
  
  /**
    Returns all AccountContactRoles for the attribute contactId. 
  */
  public AccountContactRole[] getAccountRoles() {
    return [Select Role, IsPrimary, ContactId, Account.Name, AccountId, Account.RecordType.Name From AccountContactRole Where ContactId = :contactId];
  } 

  /**
    Returns all OpportunityContactRoles for the attribute contactId. 
  */
  public OpportunityContactRole[] getOpportunityRoles() {
    return [Select Role, IsPrimary, ContactId, Opportunity.Name, OpportunityId, Opportunity.RecordType.Name  From OpportunityContactRole Where ContactId = :contactId];
  } 
}