global class InvoiceIntegrationCheck implements Schedulable {
    
    
    global void execute(SchedulableContext sc)
    {
        sendmail();
    }
    public void sendmail()
    {
        Date invToday = system.today();
        List<Invoice2__c> todaysInvoices = [select id, name, LineTotal__c from Invoice2__c where InvoiceDate__c =: invToday];
        Decimal TotalRevenue=0;
        for (Invoice2__c inv: todaysInvoices){
            TotalRevenue +=inv.LineTotal__c; 
        }
        
        if (!([SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox) && TotalRevenue <100000){

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        string [] toaddress= New string[]{'adrian.bunea@covidien.com'};
        email.setSubject('Issues with Integration? Today\'s Invoice Total: $'+TotalRevenue);
        email.setPlainTextBody('Please verify if SAP to SFDC integration is working properly. \nSo far, only $'+TotalRevenue +'worth of invoices were integrated for today.');
        email.setToAddresses(toaddress);
        Messaging.sendEmail(New Messaging.SingleEmailMessage[]{email});
    }
    }
    
}