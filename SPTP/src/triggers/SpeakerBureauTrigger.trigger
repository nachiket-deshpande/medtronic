trigger SpeakerBureauTrigger on Speaker__c (after insert, after update) {
    
            if(system.isFuture() == FALSE){
            Set <id> sids = new Set<Id>();
                for (Speaker__c s : trigger.new ){
                    sids.add(s.id);
                }    
          SpeakerBureauUtilities.updatePicture(sids);
    }
}