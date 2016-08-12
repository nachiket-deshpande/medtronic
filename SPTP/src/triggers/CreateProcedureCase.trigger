trigger CreateProcedureCase on Event (after insert, after update) {
	List<ProcedureCase__c> procedureCases = new List<ProcedureCase__c>();

	//Look at each new event which has a record type Procedure Support
	for( Event event : Trigger.new ) {
		if (!event.Event_Status__c || (event.RecordTypeId != '012400000009gfK')) { 
			//If this event is not completed or wrong RT, ignore it
			continue;
  		} else if (Trigger.isUpdate) {
  			//If this event is being updated and the completed value was already true, ignore it
  			//Get the old event object so that we can compare values
  			Event oldEvent = Trigger.oldMap.get(event.Id);
  			if (oldEvent.Event_Status__c) {
  				continue;
  			}
		} 
  		
  		//If the WhatId is null or not an Account Id, add an error to the event object and skip the procedure case creation
  		String whatId = event.WhatId;
  		if(whatId == null || !whatId.startsWith('001')) {
  			event.addError('The Related To of Procedure Case event must reference a hospital Account.');
  			continue;
  		}
  		
  		//Save the event if it is completed
  		ProcedureCase__c procedureCase = new ProcedureCase__c();
  		procedureCase.CaseDate__c = event.ActivityDate;
  		procedureCase.Physician__c = event.WhoId;
  		procedureCase.Hospital__c = event.WhatId;
  		procedureCase.Barrett_s_Grade__c = event.Barrett_s_Grade__c;
  		procedureCase.ProcedureType__c = event.Procedure_Type__c;
  		procedureCase.Reminder__c = event.Reminder__c;
  		procedureCase.Reminder_Days__c = event.Reminder_Days__c;
  		procedureCase.Scheduler_Notes__c = event.Scheduler_Notes__c;
  		procedureCase.Source_Event_Id__c = event.Id;
  		procedureCase.Size__c = event.Size__c;
  		procedureCases.add(procedureCase);
	}
	
	//Insert the new procedure case records
	insert procedureCases;
}