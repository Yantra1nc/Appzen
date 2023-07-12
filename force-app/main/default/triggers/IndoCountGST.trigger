trigger IndoCountGST on OpportunityLineItem (before insert, before update) {
    System.debug('Inside IndoCountGST');
    set<Id> lstId = new set<Id>();
    
    for(OpportunityLineItem opp : Trigger.New){
        if(opp.Within_Maharashtra__c == true){
            List<GST__c> gstList = [SELECT ID,CGST_less_than_1000__c,CGST_greater_than_1000__c,SGST_less_than_1000__c,
                                    SGST_greater_than_1000__c,Within_State__c, HSN__c FROM GST__c 
                                    WHERE Within_State__c=:opp.Within_Maharashtra__c 
                                    AND HSN__c =:opp.HSN_Code__c];
            
            for(GST__c gli:gstList)
            {
                if(gli!=null){
                    if(opp.Indo_Count_Price_Less_Than_1000__c == true){
                        opp.Indo_Count_CGST__c = gli.CGST_less_than_1000__c;
                        opp.Indo_Count_SGST__c = gli.SGST_less_than_1000__c;
                        opp.Indo_Count_IGST__c = 0.0;
                    }
                    else{
                        opp.Indo_Count_CGST__c = gli.CGST_greater_than_1000__c;
                        opp.Indo_Count_SGST__c = gli.SGST_greater_than_1000__c;
                        opp.Indo_Count_IGST__c = 0.0;
                    }
                    
                    
                }
                
                
            }
        }
        else{
            
            List<GST__c> gstList2 = [SELECT ID,IGST_less_than_1000__c,IGST_greater_than_1000__c,
                                     Within_State__c, HSN__c FROM GST__c 
                                     WHERE Within_State__c=:opp.Within_Maharashtra__c 
                                     AND HSN__c =:opp.HSN_Code__c];
            
            
            for(GST__c gli2:gstList2)
            {
                if(gli2!=null){
                    if(opp.Indo_Count_Price_Less_Than_1000__c  == true){
                        opp.Indo_Count_IGST__c = gli2.IGST_less_than_1000__c;
                        opp.Indo_Count_SGST__c = 0.0;
                        opp.Indo_Count_CGST__c = 0.0;
                    }
                    else{
                        opp.Indo_Count_IGST__c = gli2.IGST_greater_than_1000__c;
                        opp.Indo_Count_SGST__c = 0.0;
                        opp.Indo_Count_CGST__c = 0.0;
                    }
                    
                    
                }
                
                
            }
            
            
        }
        
    }
}