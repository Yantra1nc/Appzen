trigger OpportunityTestTrigger on Opportunity (before insert,before update,after update,after insert) {
    /*if(trigger.isInsert && Trigger.isAfter){
        For(Opportunity oq:Trigger.New){
            system.debug('After Insert==>'+oq.Pricebook2);
        }
    }
    if(trigger.isUpdate && Trigger.isAfter){
        For(Opportunity oq:Trigger.New){
            system.debug('After Update==>'+oq.Pricebook2);
        }
    }
    if(trigger.isInsert && Trigger.isBefore){
        For(Opportunity oq:Trigger.New){
            system.debug('Before Insert==>'+oq.Pricebook2);
        }
    }
    if(trigger.isUpdate && Trigger.isBefore){
        For(Opportunity oq:Trigger.New){
            system.debug('Before Update==>'+oq.Pricebook2);
        }
    }*/
}