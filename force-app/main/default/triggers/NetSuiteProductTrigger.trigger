trigger NetSuiteProductTrigger on Product2 (after insert, after update,after delete) {
  
    if(!NSSyncCommanUtility.avoidRecurssion){
        if(!NewAvoidRecursion.skipTrigger){
            if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
                for(Product2 p : trigger.new){
                    NSSyncCommanUtility.newSyncDataWithNetSuite(trigger.new, 'Product');
                }
            } 
        }
    }
}