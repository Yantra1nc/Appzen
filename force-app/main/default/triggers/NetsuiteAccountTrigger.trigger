trigger NetsuiteAccountTrigger on Account (after insert, after update) {
    
    For(Account a : Trigger.New){
        
        if(!NSSyncCommanUtility.avoidRecurssion && !System.isFuture() && !System.isBatch()){
            NSSyncCommanUtility.newSyncDataWithNetSuite(trigger.new, 'Account');
        } 
    }
    
}