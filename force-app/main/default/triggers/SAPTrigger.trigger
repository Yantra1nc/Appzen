trigger SAPTrigger on Opportunity (after insert,after update) {
    
    
    For(Opportunity a : Trigger.New){
        
   if( !SAPUtility.avoidRecurssion &&
   !System.isFuture() && !System.isBatch()){
     // a.Netsuite_Id__c !=NULL){  =
      //  if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){ !NSSyncCommanUtility.avoidRecurssion &&
            SAPUtility.newSyncDataWithNetSuite(trigger.new, 'Opportunity');
        } 
   
  
}

}