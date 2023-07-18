trigger NetsuiteContactTrigger on Contact (after insert, after update) {
      
    For(Contact c : Trigger.New){
      
      if(!NSSyncCommanUtility.avoidRecurssion &&
         !System.isFuture() && !System.isBatch()){
     
        if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
            NSSyncCommanUtility.newSyncDataWithNetSuite(trigger.new, 'Contact');
            System.debug('===Contact Updated===');
            // NSSIntegratorBatch nss = New NSSIntegratorBatch( Trigger.new,'Contact');
             //Database.ExecuteBatch(nss,1);
        } 
      }
   } 
}