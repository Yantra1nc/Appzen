trigger UGST on OpportunityLineItem (before insert,before update) {
    for(OpportunityLineItem opp : Trigger.New){ 
        if(opp.Union_Teritory__c == true){
            List<GST__c> gstList2 = [SELECT ID,IGST_less_than_1000__c,IGST_greater_than_1000__c,
                                 Within_State__c, HSN__c FROM GST__c 
                                 WHERE Within_State__c!=:opp.Union_Teritory__c 
                                 AND HSN__c =:opp.HSN_Code__c];
            for(GST__c gli2:gstList2){
                if(gli2!=null){
                if(opp.Indo_Count_Price_Less_Than_1000__c  == true){
                    opp.Kurl_On_UGST__c = gli2.IGST_less_than_1000__c;
                }
                else{
                    opp.Kurl_On_UGST__c = gli2.IGST_greater_than_1000__c;
                }
            }
        }
            for(GST__c gli3:gstList2){
                if(gli3!=null){
                if(opp.Less_than_1000__c  == true){
                    opp.Retailer_UGST__c = gli3.IGST_less_than_1000__c;
                }
                else{
                    opp.Retailer_UGST__c = gli3.IGST_greater_than_1000__c;
                }
            }
        }
    
    }

    }
}