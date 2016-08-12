public with sharing class UserUtilities {


  public User[] users_new = new User[]{};
  public User[] users_old = new User[]{};
  public Map <ID, User> newMap = new Map<ID, User>{};
  public Map <ID, User> oldMap = new Map<ID, User>{};
 
  public UserUtilities(User[] triggered, User[] triggeredFrom, Map<ID,User> triggerNewMap, Map<ID,User> triggerOldMap){
    users_new = triggered;
    users_old = triggeredFrom;
    newMap = triggerNewMap;
    oldMap = triggerOldMap;
  }    
 public void postBirthdayMessage()
    { 
     chatterutilities cu = new chatterutilities();
     ID vpID = [select Id from User where (isactive=true and Userrole.name ='VP of US Sales') limit 1 ].id;
     ID currentuserId = UserInfo.getUserId();   
     for (User u: users_new)    
     {
         if (u.send_birthday_reminder__c == True && u.birthday__c == Date.today() && u.isactive == true)
         {
             if (vpID !=null && vpID !=currentuserId && vpID!=u.id) {
             cu.SendMessageAs('Happy Birthday, '+ u.FirstName +'!',u.id+'', vpID);
             cu.sendprivatemessage('Hello, today is '+ u.FirstName + ' '+u.LastName+'\' birthday. A Chatter post was already created on your behalf. Here\'s a link to the user profile: https://na2.salesforce.com/'+u.id , vpID);    
             }
             if (u.managerid != null && u.managerid!=currentuserId && u.managerid!=vpID) {
             cu.sendprivatemessage('Hello, today is '+ u.FirstName + ' '+u.LastName+'\' birthday. Here\'s a link to the user profile: https://na2.salesforce.com/'+u.id , u.managerid);
             }
             if (vpID !=currentuserId && vpID==u.id) {
             cu.SendMessageAs('Happy Birthday, '+ u.FirstName +'!',u.id+'',null);
             }
             u.Send_Birthday_Reminder__c =False;

         }
     }
    } 
  public void TransferRecords()
    { 
    Set <String> olduserIds = new Set <String>(); 
	Map<String,User> UserMap = new Map<String,User>(); 
        
     for (User u: users_new)    
     {
         if (u.transfer_ownership_from_this_user_id__c!='' && u.isactive == true)
         {
          
          olduserIds.add(u.transfer_ownership_from_this_user_id__c);  
          UserMap.put(u.transfer_ownership_from_this_user_id__c,u);  
          u.transfer_ownership_from_this_user_id__c='';
         }
     }
     if( olduserIds.size() == 0 ) {
      return;
     }     
    List <Opportunity> OppstoUpdate = [select id, ownerid, name from Opportunity where ownerid in: olduserIds ];
    List <Contact> contactstoUpdate = [select id, ownerid, name from Contact where ownerid in: olduserIds];
    for (Opportunity o: OppstoUpdate)   
    {
        o.ownerid = usermap.get(o.ownerid).id;
    }
    update OppstoUpdate;    
       
    
   for (Contact  c: ContactstoUpdate)   
    {
        c.ownerid = usermap.get(c.ownerid).id;
    }
    update ContactstoUpdate;    
    }    
    
}