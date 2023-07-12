trigger KurlOnUploadOppLineItem on OpportunityLineItem (before insert,before update, after delete) {
    KurlOnOpportunityLineItemClass op1 = new KurlOnOpportunityLineItemClass() ;
    if(Trigger.isBefore && Trigger.isUpdate){
        op1.IndocountGST(Trigger.New);
    }   
    if(Trigger.isBefore && Trigger.isInsert){    
        op1.KurlOnOpportunityLineItemUploadforSO(Trigger.new);
        op1.IndocountGST(Trigger.New);
    }
    if(Trigger.isAfter && Trigger.isDelete){
        op1.PageLoadTrgHandler(Trigger.old);
    } 
}