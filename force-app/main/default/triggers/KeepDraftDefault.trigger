trigger KeepDraftDefault on Opportunity (before insert) {
    
    for(Opportunity opp: Trigger.New){
        opp.StageName = 'Draft';
           
    }

}