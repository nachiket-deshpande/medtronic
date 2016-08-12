/**
 * Unit tests for CreateProcedureCase trigger.
 */
@isTest
private class CreateProcedureCaseTriggerTests {

    static testMethod void testUpdateEvent() {
    	Account account = new Account(Name='Test',QAD_Customer_Number__c='123',RecordTypeId='012400000009ZZL');
    	insert account;
    	
    	/*Contact contact = new Contact(FirstName='John',LastName='Smith',Adoption_Status__c='Ablating');
    	insert contact;
    	
    	RecordType recordType = [select id from RecordType WHERE Name = 'Procedure Support' limit 1];
    	
        Event event = new Event(Event_Status__c=false,RecordTypeId=recordType.Id,DurationInMinutes=20,ActivityDateTime=DateTime.now(),ActivityDate=Date.today(),WhoId=contact.Id,WhatId=account.Id,Barrett_s_Grade__c='IM',Procedure_Type__c='Focal');
        insert event;
        
        event.Event_Status__c = true;
        update event;
        
        ProcedureCase__c procedureCase = [select CaseDate__c,Physician__c,Hospital__c,Barrett_s_Grade__c,ProcedureType__c from ProcedureCase__c where Physician__c = :event.WhoId limit 1];
		
		System.assertEquals(event.ActivityDate,procedureCase.CaseDate__c);
		System.assertEquals(event.WhoId,procedureCase.Physician__c);
		System.assertEquals(event.WhatId,procedureCase.Hospital__c);
		System.assertEquals(event.Barrett_s_Grade__c,procedureCase.Barrett_s_Grade__c);
		System.assertEquals(event.Procedure_Type__c,procedureCase.ProcedureType__c);*/
    }
    
    static testMethod void testCreateEvent() {
    	Account account = new Account(Name='Test',QAD_Customer_Number__c='123',RecordTypeId='012400000009ZZL');
    	insert account;
    	
    	/*Contact contact = new Contact(FirstName='John',LastName='Smith',Adoption_Status__c='Ablating');
    	insert contact;
    	
    	RecordType recordType = [select id from RecordType WHERE Name = 'Procedure Support' limit 1];
    	
        Event event = new Event(Event_Status__c=true,RecordTypeId=recordType.Id,DurationInMinutes=20,ActivityDateTime=DateTime.now(),ActivityDate=Date.today(),WhoId=contact.Id,WhatId=account.Id,Barrett_s_Grade__c='IM',Procedure_Type__c='Focal');
        insert event;
        
        ProcedureCase__c procedureCase = [select CaseDate__c,Physician__c,Hospital__c,Barrett_s_Grade__c,ProcedureType__c from ProcedureCase__c where Physician__c = :event.WhoId limit 1];
		
		System.assertEquals(event.ActivityDate,procedureCase.CaseDate__c);
		System.assertEquals(event.WhoId,procedureCase.Physician__c);
		System.assertEquals(event.WhatId,procedureCase.Hospital__c);
		System.assertEquals(event.Barrett_s_Grade__c,procedureCase.Barrett_s_Grade__c);
		System.assertEquals(event.Procedure_Type__c,procedureCase.ProcedureType__c);*/
    }
    
    static testMethod void testCreateEventNotCompleted() {
    	Account account = new Account(Name='Test',QAD_Customer_Number__c='123',RecordTypeId='012400000009ZZL');
    	insert account;
    	
    	/*Contact contact = new Contact(FirstName='John',LastName='Smith',Adoption_Status__c='Ablating');
    	insert contact;
    	
    	RecordType recordType = [select id from RecordType WHERE Name = 'Procedure Support' limit 1];
    	
        Event event = new Event(Event_Status__c=false,RecordTypeId=recordType.Id,DurationInMinutes=20,ActivityDateTime=DateTime.now(),ActivityDate=Date.today(),WhoId=contact.Id,WhatId=account.Id,Barrett_s_Grade__c='IM',Procedure_Type__c='Focal');
        insert event;
        
        List<ProcedureCase__c> procedureCases = [select Id from ProcedureCase__c where Physician__c = :event.WhoId];
		
		System.assertEquals(0,procedureCases.size());*/
    }
    
    static testMethod void testUpdateEventAlreadyCompleted() {
    	
    	Account account = new Account(Name='Test',QAD_Customer_Number__c='123',RecordTypeId='012400000009ZZL');
    	insert account;
    	
    	/*Contact contact = new Contact(FirstName='John',LastName='Smith',Adoption_Status__c='Ablating');
    	insert contact;
    	
    	RecordType recordType = [select id from RecordType WHERE Name = 'Procedure Support' limit 1];
    	
        Event event = new Event(Event_Status__c=true,RecordTypeId=recordType.Id,DurationInMinutes=20,ActivityDateTime=DateTime.now(),ActivityDate=Date.today(),WhoId=contact.Id,WhatId=account.Id,Barrett_s_Grade__c='IM',Procedure_Type__c='Focal');
        insert event;
        
        event.Event_Status__c = true;
        update event;
        
        List<ProcedureCase__c> procedureCases = [select CaseDate__c,Physician__c,Hospital__c,Barrett_s_Grade__c,ProcedureType__c from ProcedureCase__c where Physician__c = :event.WhoId];
		
		System.assertEquals(1,procedureCases.size());*/
    }
}