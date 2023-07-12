trigger PageLOadCheck on OpportunityLineItem (after delete) {
    if(Trigger.isAfter && Trigger.isDelete){
        System.debug('Inside IndoCountGST');
        KurlOnOpportunityLineItemClass pageLoad=new KurlOnOpportunityLineItemClass();
        pageLoad.PageLoadTrgHandler(Trigger.old);
    }
    
}