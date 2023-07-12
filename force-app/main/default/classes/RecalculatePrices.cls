public class RecalculatePrices {
    @AuraEnabled
    public static void FlowMethod(String opportunityId){
                system.debug('Iside flowmethod '+opportunityId);

        system.debug('In the Apex '+opportunityId);
        List<OpportunityLineItem> lstToUpdate = new List<OpportunityLineItem>();
        
        for (OpportunityLineItem oli:[select Id,Indo_Count_Addtional_Discount_Price__c,Additional_Discount__c,Kul_On_Addtional_Discounted_Price__c,
                                      Indo_Count_Additional_Discount__c,
                                      opportunity.Within_Maharashtra__c,Product2Id,product2.HSN_Code__c,
                                      OpportunityId,UnitPrice,Quantity,Final_Price__c,CGST_on_Exmill__c,IGST_on_Exmill__c,
                                      SGST_on_Exmill__c from OpportunityLineItem where OpportunityId =:opportunityId])
        {
            Decimal discountedPrice = 0;
            //opp.GST_New__c = obj.gst;                   
            if(oli.opportunity.Within_Maharashtra__c == true){
                List<GST__c> gstList = [SELECT ID,CGST_less_than_1000__c,CGST_greater_than_1000__c,SGST_less_than_1000__c,
                                        SGST_greater_than_1000__c,Within_State__c, HSN__c FROM GST__c 
                                        WHERE Within_State__c=:oli.opportunity.Within_Maharashtra__c 
                                        AND HSN__c =:oli.Product2.HSN_Code__c];
                
                for(GST__c gli:gstList) {
                    if(gli!=null){
                        if(oli.Additional_Discount__c != null && oli.Additional_Discount__c != 0){
                            //discountedPrice = oli.UnitPrice - ((oli.Additional_Discount__c/100) * oli.UnitPrice);
                            //oli.UnitPrice = discountedPrice;
                            if(oli.Additional_Discount_Price__c < 1000){
                                oli.CGST__c = gli.CGST_less_than_1000__c;
                                oli.SGST__c = gli.SGST_less_than_1000__c;
                                oli.IGST__c = 0.0;
                                oli.CGST_on_Exmill__c = gli.CGST_less_than_1000__c;
                                oli.SGST_on_Exmill__c = gli.SGST_less_than_1000__c;
                                oli.IGST_on_Exmill__c = 0.0;
                            }
                            else{
                                oli.CGST__c = gli.CGST_greater_than_1000__c;
                                oli.SGST__c = gli.SGST_greater_than_1000__c;
                                oli.IGST__c = 0.0;
                                oli.CGST_on_Exmill__c = gli.CGST_greater_than_1000__c;
                                oli.SGST_on_Exmill__c = gli.SGST_greater_than_1000__c;
                                oli.IGST_on_Exmill__c = 0.0;
                            }
                            oli.GST_in_1__c = gli.IGST_less_than_1000__c;
                        }
                        if(oli.Indo_Count_Additional_Discount__c != null && oli.Indo_Count_Additional_Discount__c != 0){
                            discountedPrice = oli.Kul_On_Addtional_Discounted_Price__c - ((oli.Indo_Count_Additional_Discount__c/100) * oli.Kul_On_Addtional_Discounted_Price__c);
                            oli.Kul_On_Addtional_Discounted_Price__c = discountedPrice;
                            if(discountedPrice < 1000){
                                oli.Indo_Count_IGST__c = gli.CGST_less_than_1000__c;
                                oli.Indo_Count_CGST__c = 0.0;
                                oli.Indo_Count_SGST__c = 0.0;
                            }
                            else{
                                oli.Indo_Count_IGST__c = gli.CGST_greater_than_1000__c;
                                oli.Indo_Count_CGST__c = 0.0;
                                oli.Indo_Count_SGST__c = 0.0;
                            }
                            oli.GST_in_1__c = gli.IGST_less_than_1000__c;
                        }
                    }
                }
            }
            else{
                List<GST__c> gstList2 = [SELECT ID,CGST_less_than_1000__c,IGST_less_than_1000__c,IGST_greater_than_1000__c,
                                         Within_State__c, HSN__c FROM GST__c 
                                         WHERE Within_State__c=:oli.Opportunity.Within_Maharashtra__c AND HSN__c =:oli.Product2.HSN_Code__c];
                for(GST__c gli2:gstList2){
                    if(gli2!=null){
                        if(oli.Additional_Discount__c != null && oli.Additional_Discount__c != 0){
                            
                            //discountedPrice = oli.Additional_Discount_Price__c - ((oli.Additional_Discount__c/100) * oli.UnitPrice);
                            // oli.UnitPrice = discountedPrice;
                            
                            if(oli.Additional_Discount_Price__c < 1000){
                                oli.IGST__c = gli2.IGST_less_than_1000__c; 
                                oli.SGST__c = 0.0;
                                oli.CGST__c = 0.0;
                                oli.IGST_on_Exmill__c = gli2.IGST_less_than_1000__c;
                                oli.CGST_on_Exmill__c = 0.0;
                                oli.SGST_on_Exmill__c = 0.0;
                            } 
                            else{
                                oli.IGST__c = gli2.IGST_greater_than_1000__c; 
                                oli.SGST__c = 0.0;
                                oli.CGST__c = 0.0;
                                oli.IGST_on_Exmill__c = gli2.IGST_greater_than_1000__c;
                                oli.CGST_on_Exmill__c = 0.0;
                                oli.SGST_on_Exmill__c = 0.0;
                            }           
                            oli.GST_in_1__c = gli2.IGST_less_than_1000__c;
                        }     
                        if(oli.Indo_Count_Additional_Discount__c != null && oli.Indo_Count_Additional_Discount__c != 0){
                            System.debug('***else gli2 '+gli2);
                            discountedPrice = oli.Indo_Count_Addtional_Discount_Price__c - ((oli.Indo_Count_Additional_Discount__c/100) * oli.Indo_Count_Addtional_Discount_Price__c);
                            oli.Kul_On_Addtional_Discounted_Price__c = discountedPrice;
                            
                            if(discountedPrice < 1000){
                                oli.Indo_Count_IGST__c = gli2.CGST_less_than_1000__c;
                                oli.Indo_Count_CGST__c = 0.0;
                                oli.Indo_Count_SGST__c = 0.0;
                            }
                            else{
                                oli.Indo_Count_IGST__c = gli2.CGST_greater_than_1000__c;
                                oli.Indo_Count_CGST__c = 0.0;
                                oli.Indo_Count_SGST__c = 0.0;
                            }     
                            oli.GST_in_1__c = gli2.IGST_less_than_1000__c;
                        }     
                    }
                }                            
            }
            System.debug('******* discountedPrice '+discountedPrice);
            if(discountedPrice != 0){
                oli.PriceAfterGST__c = discountedPrice + (discountedPrice * (oli.GST_in_1__c/100));
            }
            System.debug('*** oli '+oli);
            lstToUpdate.add(oli);                   
            
        }
        if(!lstToUpdate.isEmpty()){
            update lstToUpdate;
            System.debug('Updated lstToUpdate '+lstToUpdate);
        }
    }
}