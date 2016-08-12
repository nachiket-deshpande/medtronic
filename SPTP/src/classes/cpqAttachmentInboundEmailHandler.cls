global class cpqAttachmentInboundEmailHandler implements Messaging.InboundEmailHandler {
  global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope env) {
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
    String quoteNum = 'Q-' + email.subject.substringBetween('[Q-',']');
    for (SBQQ__Quote__c q : [SELECT Id FROM SBQQ__Quote__c WHERE Name = :quoteNum]){
      if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
        Attachment [] attachLst2Insert = new List<Attachment>();
        for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) {
          Attachment a = new Attachment();
          a.ParentId = q.Id;
          a.Name = email.binaryAttachments[i].filename;
          a.Body = email.binaryAttachments[i].body;
          attachLst2Insert.add(a);
        }
        insert attachLst2Insert;
      }
      return result;    
    }
    result.success=false;
    result.message='Attachment could not be processed. Please make sure you specified the Quote # in the subject line in the following format [Q-xxxxx]';
    return result;
  }
}