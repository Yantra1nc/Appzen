trigger DeleteJsonLog on JSON_Log__c (before insert) {
List<JSON_Log__c>jloglist =[Select Id, Log_Age__c From JSON_Log__c
                           Where Log_Age__c > 35];
    For(JSON_Log__c jlog : Trigger.New){
        System.debug('Deleting log aging more than 35 days.');
        
    }
    delete jloglist;
}