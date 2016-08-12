public class TaskExtensionController {
	/* private Id taskId;
	
	public TaskExtensionController(ApexPages.StandardController standardController) {
		taskId = standardController.getId();
	}
	
	public PageReference onCloseAndNextAGU() {
		String returnUrl = ApexPages.currentPage().getParameters().get('retURL');
		if (returnUrl == null) {
			returnUrl = '/' + taskId;
		}
		Task task = [SELECT Id, MilestoneId__c, WhoId FROM Task WHERE Id = :taskId LIMIT 1];
		if ((task.MilestoneId__c != null) && (task.WhoId != null)) {
			// AGU Task, inject URL of the selector VF page as retURL param
			returnUrl = Page.SelectAGUTask.getUrl() + '?id=' + task.WhoId + '&retURL=' + EncodingUtil.urlEncode(returnUrl,'UTF-8'); 
		}
		return new PageReference('/' + taskId + '/e?nooverride=1&close=1&retURL=' + EncodingUtil.urlEncode(returnUrl,'UTF-8'));
	} */
}