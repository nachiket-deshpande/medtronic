/****************************************************************************************
 * Name    : Gizmo_InboundEmailHandler 
 * Author  : Adrian Bunea 
 * Date    : 02/23/2016 
 * Purpose : Handle the inbound emails from Gizmo 
 * Dependencies: 
 *
 * ========================
 * = MODIFICATION HISTORY =
 * ========================
 * DATE        AUTHOR               CHANGE
 *****************************************************************************************/

global class Gizmo_InboundEmailHandler implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        try{
            List<User> users = [select Id, Country from User where Email = :email.fromAddress and isActive=true limit 1];
            
            //This service only accept emails from a SFDC user
            User fromUser;
            if (users.size()>0) 
                fromUser = users[0];
            else
                fromUser = [select Id, Country from User where Id = :UserInfo.getUserId() limit 1];
                
            //Initial task
            Task contentSharing = new Task();
            contentSharing.OwnerId = fromUser.Id;
            contentSharing.Status = 'Completed';
            contentSharing.Priority = 'Low';
            contentSharing.IsReminderSet = false;
            contentSharing.ActivityDate = date.today();
            
            if(email.subject != null)
                contentSharing.subject = email.subject;
            else
                contentSharing.subject = 'Content Sharing';
            
            if(email.plainTextBody != null)
                contentSharing.Description = email.plainTextBody;
            else    
                contentSharing.Description = 'Content Sharing, no details from the email body';
            
            if(users.size()==0)
                contentSharing.Description = '\nFrom Email: ' + email.fromAddress + '\n###################################################\n' + contentSharing.Description;
                            
           // Id contentSharingRTId = [Select Id from RecordType Where sObjectType = 'Task' and DeveloperName = 'Content_Sharing' limit 1].Id;
           // contentSharing.RecordTypeId = contentSharingRTId; 
            contentSharing.Type = 'Content Sharing';
            
            //Matching Contacts with to and cc addresses
            List<String> toNccAddresses = new List<String>();
            if(email.toAddresses != null)
                toNccAddresses.addAll(email.toAddresses);
            if(email.ccAddresses != null)
                toNccAddresses.addAll(email.ccAddresses);
            
            boolean noContactMatched = true;
            if(toNccAddresses.size()>0)
            {
                List<String> relatedEmails = new List<String>();
                //extract the email address from "to" and "cc" addresses
                for (String address : toNccAddresses) {
                    Matcher matcher = Pattern.compile('<.+>').matcher(address);
                    
                    // Parse addresses to emails
                    if (matcher.find()) {
                        relatedEmails.add(matcher.group().replaceAll('[<>]', ''));
                    } 
                    else {
                        relatedEmails.add(address);
                    }
                }   
                //exclude master contacts
               //Id masterContactRTId = [Select Id from RecordType Where sObjectType = 'Contact' and DeveloperName = 'Master_Contact' limit 1].Id;
               // List<Contact> relatedContacts = [Select Id, AccountId from Contact Where (Email =:relatedEmails or Personal_Email__c = :relatedEmails) and RecordTypeId != :masterContactRTId];
               List<Contact> relatedContacts = [Select Id, AccountId from Contact Where Email =:relatedEmails];
                if(relatedContacts.size()>0){
                    noContactMatched = false;
                    contentSharing.WhoId = relatedContacts[0].Id;
                    contentSharing.WhatId = relatedContacts[0].AccountId;
                    insert contentSharing;
                    
                    //Link task to multiple contacts
                    if(relatedContacts.size()>1)
                    {
                        List<TaskRelation> taskRl = new List<TaskRelation>();
                        for(Integer i=1; i<relatedContacts.size(); i++)
                        {
                            taskRl.add(new TaskRelation(TaskId = contentSharing.Id, IsWhat = false, RelationId = relatedContacts[i].Id));
                        }
                        insert taskRl;
                    }

                }
            }
            
            //No Contact matched, link the task to the country account
            if(noContactMatched){
               // Id countryAccountRTId = [Select Id from RecordType Where sObjectType = 'Account' and DeveloperName = 'Country_Accounts' limit 1].Id;
               // String strCountryAccountName = fromUser.Country + '-Account';
               // Id countryAccountId = [Select Id from Account Where RecordTypeId=:countryAccountRTId and Name=:strCountryAccountName limit 1].Id;
                ID countryAccountId = [Select Id from Account where Name=:'Content Cloud Sharing Unmatched Email Repository' limit 1].id;

                contentSharing.WhatId=countryAccountId;
                contentSharing.Description = Label.Unmatched_Email_Address + '\n###################################################\n' + contentSharing.Description;
                contentSharing.Status = 'Not Started';
                contentSharing.IsReminderSet = true;
                contentSharing.ReminderDateTime = System.now();
                insert contentSharing;  
            }
            
        }
        catch(Exception e) {
            result.success = false;
            result.message = 'Oops, Gizmo_InboundEmailHandler failed.' + e.getStackTraceString();
        }
        
        return result; 
    }

}