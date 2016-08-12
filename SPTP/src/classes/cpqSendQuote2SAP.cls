global class cpqSendQuote2SAP {
  webservice static String SAPCallout(Id quoteId){

    String endpoint = 'http://en.wikipedia.org/w/api.php';  //@TODO GET FROM CUSTOM SETTTING
    try {
      SBQQ__Quote__c q = [SELECT Id, Name,(SELECT Id, Name FROM SBQQ__LineItems__r) 
                          FROM SBQQ__Quote__c
                         WHERE Id =:quoteId];
      String xmlString = '';
      xmlString += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:quote="">';
      xmlString += '<soapenv:Header><wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">';
      xmlString += '<wsse:UsernameToken><wsse:Username>' + '' + '</wsse:Username>';
      xmlString += '<wsse:Password>' + '' + '</wsse:Password></wsse:UsernameToken>';
      //@TODO LOOP THROUGH QUOTE AND LINE ITEMS AND BUILD CALLOUT BODY
      xmlString += '</wsse:Security></soapenv:Header><soapenv:Body>';
      xmlString += '</soapenv:Body></soapenv:Envelope>';
      Http h = new Http();
      HttpRequest req = new HttpRequest();
      req.setEndpoint(endpoint);
      req.setMethod('POST');
      req.setHeader('Content-Type', 'text/xml'); 
      req.setbody(xmlString);
      HttpResponse res;
      if(Test.isRunningTest()){
        HttpResponse dummyRes  = new HttpResponse();
        dummyRes.setStatusCode(200);
        dummyRes.setStatus('OK');
        res = dummyRes;
      } else {
        res = h.send(req);
        //@TODO parse response and ???
      }
    } catch(Exception ex) {
      return ex.getMessage() + ex.getStackTraceString();
    }
    return 'Success!';
  }
}