public class GetDependentFields {
    
    @AuraEnabled(cacheable=true)
	public static List<String> getDependentPicklistValues(Id oppId) {
        System.debug(oppId);
    List<String> lstCollections = new List<String>();
    Schema.sObjectField dependToken = Product2.Collection__c;  
        system.debug('dependToken '+ dependToken);
    Schema.DescribeFieldResult depend = dependToken.getDescribe();
        system.debug('depend '+ depend);
    Schema.sObjectField controlToken = depend.getController();
        system.debug('controlToken '+ controlToken);
        Opportunity opp = [Select Id,Brand__c from Opportunity where Id =:oppId];
    if (controlToken == null) {
        return new List<String>();
    }
 
    Schema.DescribeFieldResult control = controlToken.getDescribe();
    List<Schema.PicklistEntry> controlEntries;
    if(control.getType() != Schema.DisplayType.Boolean) {
        controlEntries = control.getPicklistValues();
    }
 
    String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
    for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
        if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
            List<String> base64chars =
                    String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
            for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                Object controlValue =
                        (controlEntries == null
                                ?   (Object) (index == 1)
                                :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                        );
                Integer bitIndex = index / 6;
                if (bitIndex > base64chars.size() - 1) {
                    break;
                }
                Integer bitShift = 5 - Math.mod(index, 6);
                if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                    continue;
                if (!dependentPicklistValues.containsKey((String) controlValue)) {
                    dependentPicklistValues.put((String) controlValue, new List<String>());
                }
                dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
            }
        }
    }
        System.debug(dependentPicklistValues);
        for(String str:dependentPicklistValues.get(opp.Brand__c)){
            lstCollections.add(str); 
        }
        System.debug(lstCollections);
    return lstCollections;
}
}