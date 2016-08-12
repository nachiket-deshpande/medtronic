public class SpeakerBureauUtilities {
@future
    public static void updatePicture (Set <Id> sids){
    List<Speaker__c> splist = [select id, name, Picture__c, speaker__c, speaker__r.Picture__c from Speaker__c where id in: sids];
    for (Speaker__c sp: splist)    {
        if (sp.Picture__c != sp.speaker__r.Picture__c) {
            sp.Picture__c = sp.speaker__r.Picture__c;
        }
    }
     update splist;   
    }    
}