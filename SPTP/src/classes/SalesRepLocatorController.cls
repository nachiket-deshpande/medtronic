public /*with sharing*/ class SalesRepLocatorController {
	public String baseLocation {get; set;}
	public String leadName {get; set;}
	public ResultRow resultRow {get; private set;}
	public Lead lead {get; set;}
	public Boolean searched {get; private set;}
	public Boolean empty { get{return (resultRow == null);} }
	public Boolean isInputStep { get; private set; }
	
	public SalesRepLocatorController() {
		searched = false;
		isInputStep = true;
		lead = new Lead();
	}
	
	public void onSubmit() {
		Integer index = leadName.indexOf(' ');
		if( index != -1) {
			lead.FirstName = leadName.substring(0, index);
			lead.LastName = leadName.substring(index+1, leadName.length() - 1);
		} else {
			lead.LastName = leadName;
		}
		
		Zipcode_Seller_Lookup__c seller = [SELECT Id, Seller__c, Seller__r.Picture__c,  
			Seller__r.Name, Seller_Phone__c, Email_Address__c, Name,
			Sales_Manager__c, Sales_Manager_Phone__c, Sales_Manager_Email__c, Sales_Manager_Title__c 
			from Zipcode_Seller_Lookup__c where Name = :lead.PostalCode LIMIT 1];
		
		lead.OwnerId = seller.Seller__c;		
		insert lead;
		
		notifyRep(lead, seller);
		
		doSearch();
	}
	
	private void notifyRep(Lead lead, Zipcode_Seller_Lookup__c seller) {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		
		mail.setToAddresses( new String[] { seller.Email_Address__c } );
       	mail.setReplyTo('donotreply@salesforce.com');    
        mail.setSenderDisplayName('Salesforce notification');     
       	mail.setSubject('New lead assigned');
       	
       	String body = 'You have a new lead assigned to you - https://na2.salesforce.com' + lead.Id;
       	
       	mail.setHtmlBody(body);          
        mail.setPlainTextBody(body);
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        mails.add(mail);
        
        Messaging.sendEmail(mails, false);
	}
	
	public void doSearch() {
		if (StringUtils.isBlank(lead.PostalCode)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must enter base zip code'));
			return;
		}
		
		try {
			Zipcode_Seller_Lookup__c seller = [SELECT Id, Seller__c, Seller__r.Picture__c,  
				Seller__r.Name, Seller_Phone__c, Email_Address__c, Name,
				Sales_Manager__c, Sales_Manager_Phone__c, Sales_Manager_Email__c, Sales_Manager_Title__c 
				from Zipcode_Seller_Lookup__c where Name = :lead.PostalCode LIMIT 1];
			resultRow = new ResultRow(seller);
		} catch (Exception e) {
			if( e.getMessage().contains('List has no rows for assignment to SObject') ) {
				ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'No sales rep could be located for the specified zip code') );			
				return;
			}
			ApexPages.addMessages(e);
			return;
		}
		isInputStep = false;
		searched = true;
		return;
	}
	
	public class ResultRow {
		public SObject record {get; private set;}
		public Zipcode_Seller_Lookup__c seller {get{return (Zipcode_Seller_Lookup__c)record;}}
		
		public ResultRow(SObject record) {
			this.record = record;
		}
	}
}