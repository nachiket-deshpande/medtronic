global class BatchLatLongGenerator implements Database.Batchable<sObject>, Database.AllowsCallouts {
//Call:
//BatchLatLongGenerator bJob = new BatchLatLongGenerator('SELECT Id, BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet FROM Account WHERE GeoCoding_Call_Status__c = null and account_number__c <> null Limit 100' ); 
//database.executebatch(bJob,10);


  global final String query;
  global BatchLatLongGenerator(String q) {query=q;}
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }
  global void execute(Database.BatchableContext BC, List<Account> scope) {
    
      for (account a : scope) {

        // create an address string
        String address = '';
        if (a.BillingStreet != null)
            address += a.BillingStreet +', ';
        if (a.BillingCity != null)
            address += a.BillingCity +', ';
        if (a.BillingState != null)
            address += a.BillingState +' ';
        if (a.BillingPostalCode != null)
            address += a.BillingPostalCode +', ';
        if (a.BillingCountry != null)
            address += a.BillingCountry;

        address = EncodingUtil.urlEncode(address, 'UTF-8');

        // build callout
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address='+address+'&sensor=false&key=AIzaSyCSG2RcV9VHvOKQu5Bi4bPtmMrQi6bMX5U');
        req.setMethod('GET');
        req.setTimeout(60000);

        try{
            // callout
            HttpResponse res = h.send(req);

            // parse coordinates from response
            JSONParser parser = JSON.createParser(res.getBody());
            double lat = null;
            double lon = null;
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&(parser.getText() == 'location')){
                      parser.nextToken(); // object start
                       while (parser.nextToken() != JSONToken.END_OBJECT){
                           String txt = parser.getText();
                           parser.nextToken();
                           if (txt == 'lat')
                               lat = parser.getDoubleValue();
                           else if (txt == 'lng')
                               lon = parser.getDoubleValue();
                       }
                    }
             } 
            // update coordinates if we get back
            if (lat != null){
                a.BillingLatitude = lat;
                a.BillingLongitude = lon;
                a.GeoCoding_Call_Status__c = res.getStatus();
               // accountlist.add(a);
               update a; 
            }

        } catch (Exception e) {
        }
    }
        //update scope;
    }  
 
  global void finish(Database.BatchableContext BC) {
    //create a mail object to send a single email.
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    User u =[select email,name from user where id=: userinfo.getUserId() limit 1];
    //set the email properties
    mail.setToAddresses(new string[] {u.email});
    mail.setSubject('Case Latitude Longitude batch completed');
    String body='';
    body +='Hi '+u.name+',';
    body+='<br/><br/>Account Latitude Longitude Calulation Batch is complete';
    body+='<br/><br/>Thank,<br/>Admin';
    mail.setHtmlBody(body);
    mail.setPlainTextBody('Account Latitude Longitude Calculation Batch is complete');
    //send the email
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail } );
  }
 
}