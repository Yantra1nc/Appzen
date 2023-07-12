public class KurlOnOpportunityLineItemClass {
    
    public void IndocountGST(List<OpportunityLineItem> OppLineList){
        
        System.debug('Inside IndoCountGST');
        set<Id> lstId = new set<Id>();
        RecordType kurlOnRT = [select id,name,developerName from RecordType where developername ='KurlON_Sales_Order' and Sobjecttype = 'Opportunity'];
        for(OpportunityLineItem opp : OppLineList){
            if(opp.Within_Maharashtra__c == true){
                system.debug('opp.HSN_Code__c'+opp.HSN_Code__c);
                system.debug('opp.Within_Maharashtra__c'+opp.Within_Maharashtra__c);
                
                List<GST__c> gstList = [SELECT ID,GST_Value__c,IGST_greater_than_1000__c,CGST_less_than_1000__c,CGST_greater_than_1000__c,SGST_less_than_1000__c,SGST_greater_than_1000__c,Within_State__c, HSN__c FROM GST__c WHERE Within_State__c=:opp.Within_Maharashtra__c AND HSN__c =:opp.HSN_Code__c];
                system.debug('gstList'+gstList);
                for(GST__c gli:gstList){
                    if(gli!=null){
                        if(opp.Indo_Count_Price_Less_Than_1000__c == true){
                            opp.Indo_Count_CGST__c = gli.CGST_less_than_1000__c;
                            opp.Indo_Count_SGST__c = gli.SGST_less_than_1000__c;
                            opp.Indo_Count_IGST__c = 0.0;
                            opp.Line_Level_Discount_Applied__c = true;
                        }
                        else{ 
                            opp.Indo_Count_CGST__c = gli.CGST_greater_than_1000__c;
                            opp.Indo_Count_SGST__c = gli.SGST_greater_than_1000__c;
                            opp.Indo_Count_IGST__c = 0.0;
                            opp.Line_Level_Discount_Applied__c = true;
                            
                        }
                        //in maharashtra
                        System.debug('opp.Additional_Discount__c  '+opp.Dynamic_Additional_Discount__c );
                        System.debug('opp.Dynamic_Discounted_Price__c '+opp.Dynamic_Discounted_Price__c);
                        System.debug('gli2.GST_Value__c '+gli);
                        
                        //Dynamic Disc
                        if(opp.Dynamic_Additional_Discount__c != null && opp.Dynamic_Additional_Discount__c != 0){
                            if(opp.Dynamic_Discounted_Price__c < gli.GST_Value__c){
                                opp.GST_in_1__c = gli.IGST_less_than_1000__c;
                                
                                opp.CGST__c = gli.CGST_less_than_1000__c;
                                opp.SGST__c = gli.SGST_less_than_1000__c;
                                opp.IGST__c = gli.IGST_less_than_1000__c;
                                opp.CGST_on_Exmill__c = gli.CGST_less_than_1000__c;
                                opp.SGST_on_Exmill__c = gli.SGST_less_than_1000__c;
                                opp.IGST_on_Exmill__c = 0.0;
                                opp.Line_Level_Discount_Applied__c = true;
                            }
                            else{
                                opp.GST_in_1__c = gli.IGST_greater_than_1000__c;
                                
                                opp.CGST__c = gli.CGST_greater_than_1000__c;
                                opp.SGST__c = gli.SGST_greater_than_1000__c;
                                opp.IGST__c = gli.IGST_greater_than_1000__c;
                                opp.CGST_on_Exmill__c = gli.CGST_greater_than_1000__c;
                                opp.SGST_on_Exmill__c = gli.SGST_greater_than_1000__c;
                                opp.IGST_on_Exmill__c = 0.0;
                                opp.Line_Level_Discount_Applied__c = true;
                            }
                            if(opp.GST_in_1__c != null && opp.GST_in_1__c != 0 && opp.Dynamic_Discounted_Price__c != 0 && opp.Dynamic_Discounted_Price__c != null){
                                opp.PriceAfterGST__c = opp.Dynamic_Discounted_Price__c + (opp.Dynamic_Discounted_Price__c * (opp.GST_in_1__c/100));
                            }
                        }
                        
                        //retailer Disc
                        if(opp.Additional_Discount__c != null && opp.Additional_Discount__c != 0){
                            if(opp.Additional_Discount_Price__c < gli.GST_Value__c){
                                opp.CGST__c = 0;
                                opp.SGST__c = 0;
                                opp.IGST__c = gli.IGST_less_than_1000__c;
                                opp.CGST_on_Exmill__c = gli.CGST_less_than_1000__c;
                                opp.SGST_on_Exmill__c = gli.SGST_less_than_1000__c;
                                opp.IGST_on_Exmill__c = 0.0;
                            }
                            else{
                                opp.CGST__c = 0;
                                opp.SGST__c = 0;
                                opp.IGST__c = gli.IGST_greater_than_1000__c;
                                opp.CGST_on_Exmill__c = gli.CGST_greater_than_1000__c;
                                opp.SGST_on_Exmill__c = gli.SGST_greater_than_1000__c;
                                opp.IGST_on_Exmill__c = 0.0;
                            }
                        }
                        
                        
                        //kurl on disc
                        if(opp.Opportunity.recordtypeId == kurlOnRT.Id){
                            //change added on Aug-10-022
                            if(opp.Additional_Discount_Price__c < gli.GST_Value__c){
                                opp.CGST__c = gli.CGST_less_than_1000__c;
                                opp.SGST__c = gli.SGST_less_than_1000__c;
                                opp.IGST__c = gli.IGST_less_than_1000__c;
                                opp.CGST_on_Exmill__c = gli.CGST_less_than_1000__c;
                                opp.SGST_on_Exmill__c = gli.SGST_less_than_1000__c;
                                opp.IGST_on_Exmill__c = 0.0;
                                opp.Line_Level_Discount_Applied__c = true;
                                
                            }
                            else{
                                opp.CGST__c = gli.CGST_greater_than_1000__c;
                                opp.SGST__c = gli.SGST_greater_than_1000__c;
                                opp.IGST__c = gli.IGST_greater_than_1000__c;
                                opp.CGST_on_Exmill__c = gli.CGST_greater_than_1000__c;
                                opp.SGST_on_Exmill__c = gli.SGST_greater_than_1000__c;
                                opp.IGST_on_Exmill__c = 0.0;
                                opp.Line_Level_Discount_Applied__c = true;
                                
                            }
                            
                            //change added on Aug-11-022
                            Decimal calculatedDiscountPrice =DynamicDiscount.calculateDynamicDiscount(opp.Product2Id,opp.OpportunityId);    
                            System.debug('Discount is '+opp.Dynamic_Additional_Discount__c);
                            System.debug('Discounted calculation '+calculatedDiscountPrice);
                            
                            if(calculatedDiscountPrice != null || calculatedDiscountPrice != 0){
                                calculatedDiscountPrice = opp.Indo_Count_to_Kurl_On_Price__c;
                            }
                            
                            if(opp.Dynamic_Additional_Discount__c != null && opp.Dynamic_Additional_Discount__c != 0){
                                calculatedDiscountPrice = calculatedDiscountPrice - (calculatedDiscountPrice * (opp.Dynamic_Additional_Discount__c/100));
                            }
                            
                            System.debug('After applying addditional  '+calculatedDiscountPrice);
                            opp.Dynamic_Discount__c = calculatedDiscountPrice;
                            
                            if(calculatedDiscountPrice < gli.GST_Value__c){
                                opp.GST_in_1__c = gli.IGST_less_than_1000__c;
                                opp.Line_Level_Discount_Applied__c = true;
                            }
                            else{
                                opp.GST_in_1__c = gli.IGST_greater_than_1000__c;
                                opp.Line_Level_Discount_Applied__c = true;
                            }
                            if(opp.GST_in_1__c != null && opp.GST_in_1__c != 0){
                                opp.PriceAfterGST__c = calculatedDiscountPrice + (calculatedDiscountPrice * (opp.GST_in_1__c/100));
                            }
                        }
                    }
                }
            }
            else{
                system.debug('opp.Within_Maharashtra__c'+opp.Within_Maharashtra__c);
                List<GST__c> gstList2 = [SELECT ID,GST_Value__c,IGST_less_than_1000__c,CGST_less_than_1000__c ,SGST_less_than_1000__c,IGST_greater_than_1000__c,
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
                            opp.Line_Level_Discount_Applied__c = true;
                        }
                        else{
                            opp.Indo_Count_IGST__c = gli2.IGST_greater_than_1000__c;
                            opp.Indo_Count_SGST__c = 0.0;
                            opp.Indo_Count_CGST__c = 0.0;
                            opp.Line_Level_Discount_Applied__c = true;
                        }
                        System.debug('opp.Dynamic_Additional_Discount__c  '+opp.Dynamic_Additional_Discount__c );
                        System.debug('opp.Dynamic_Discounted_Price__c '+opp.Dynamic_Discounted_Price__c);
                        System.debug('gli2.GST_Value__c '+gli2);
                       
                        //Dynamic Disc
                        if(opp.Dynamic_Additional_Discount__c != null && opp.Dynamic_Additional_Discount__c != 0){
                            //change added on Aug-10-022
                            if(opp.Dynamic_Discounted_Price__c < gli2.GST_Value__c){
                                opp.GST_in_1__c = gli2.IGST_less_than_1000__c;
                                
                                opp.CGST__c = 0;
                                opp.SGST__c = 0;
                                opp.IGST__c = gli2.IGST_less_than_1000__c;
                                opp.CGST_on_Exmill__c = 0;
                                opp.SGST_on_Exmill__c = 0;
                                opp.IGST_on_Exmill__c = gli2.IGST_less_than_1000__c;
                                opp.Line_Level_Discount_Applied__c = true;
                            }
                            else{
                                opp.GST_in_1__c = gli2.IGST_greater_than_1000__c;
                                
                                opp.CGST__c = 0;
                                opp.SGST__c = 0;
                                opp.IGST__c = gli2.IGST_greater_than_1000__c;
                                opp.CGST_on_Exmill__c = 0;
                                opp.SGST_on_Exmill__c = 0;
                                opp.IGST_on_Exmill__c = gli2.IGST_greater_than_1000__c;
                                opp.Line_Level_Discount_Applied__c = true;
                            }
                            
                            if(opp.GST_in_1__c != null && opp.GST_in_1__c != 0 && opp.Dynamic_Discounted_Price__c != 0 && opp.Dynamic_Discounted_Price__c != null){
                                opp.PriceAfterGST__c = opp.Dynamic_Discounted_Price__c + (opp.Dynamic_Discounted_Price__c * (opp.GST_in_1__c/100));
                            }
                            System.debug('opp.GST_in_1__c '+opp.GST_in_1__c);
                        }
                        
                        //retailer disc
                        if(opp.Additional_Discount__c != null && opp.Additional_Discount__c != 0){
                            if(opp.Additional_Discount_Price__c < gli2.GST_Value__c){
                                opp.CGST__c = 0;
                                opp.SGST__c = 0;
                                opp.IGST__c = gli2.IGST_less_than_1000__c;
                                opp.CGST_on_Exmill__c = 0;
                                opp.SGST_on_Exmill__c = 0;
                                opp.IGST_on_Exmill__c = gli2.IGST_less_than_1000__c;
                            }
                            else{
                                opp.CGST__c = 0;
                                opp.SGST__c = 0;
                                opp.IGST__c = gli2.IGST_greater_than_1000__c;
                                opp.CGST_on_Exmill__c = 0;
                                opp.SGST_on_Exmill__c = 0;
                                opp.IGST_on_Exmill__c = gli2.IGST_greater_than_1000__c;
                            }
                        }
                        
                        //kurl on disc
                        if(opp.Opportunity.recordtypeId == kurlOnRT.Id){
                            
                            //change added on Aug-10-022
                            if(opp.Additional_Discount_Price__c < gli2.GST_Value__c){
                                opp.CGST__c = 0;
                                opp.SGST__c = 0;
                                opp.IGST__c = gli2.IGST_less_than_1000__c;
                                opp.CGST_on_Exmill__c = 0;
                                opp.SGST_on_Exmill__c = 0;
                                opp.IGST_on_Exmill__c = gli2.IGST_less_than_1000__c;
                                opp.Line_Level_Discount_Applied__c = true;
                            }
                            else{
                                opp.CGST__c = 0;
                                opp.SGST__c = 0;
                                opp.IGST__c = gli2.IGST_greater_than_1000__c;
                                opp.CGST_on_Exmill__c = 0;
                                opp.SGST_on_Exmill__c = 0;
                                opp.IGST_on_Exmill__c = gli2.IGST_greater_than_1000__c;
                                opp.Line_Level_Discount_Applied__c = true;
                            }
                            
                            //change added on Aug-11-022
                            Decimal calculatedDiscountPrice =DynamicDiscount.calculateDynamicDiscount(opp.Product2Id,opp.OpportunityId);    
                            System.debug('Discount is '+opp.Dynamic_Additional_Discount__c);
                            System.debug('Discounted calculation '+calculatedDiscountPrice);
                            
                            if(calculatedDiscountPrice != null || calculatedDiscountPrice != 0){
                                calculatedDiscountPrice = opp.Indo_Count_to_Kurl_On_Price__c;
                            }
                            
                            if(opp.Dynamic_Additional_Discount__c != null && opp.Dynamic_Additional_Discount__c != 0){
                                calculatedDiscountPrice = calculatedDiscountPrice - (calculatedDiscountPrice * (opp.Dynamic_Additional_Discount__c/100));
                            }
                            
                            System.debug('After applying addditional  '+calculatedDiscountPrice);
                            opp.Dynamic_Discount__c = calculatedDiscountPrice;
                            
                            if(calculatedDiscountPrice < gli2.GST_Value__c){
                                opp.GST_in_1__c = gli2.IGST_less_than_1000__c;
                                opp.Line_Level_Discount_Applied__c = true;
                            }
                            else{
                                opp.GST_in_1__c = gli2.IGST_greater_than_1000__c;
                                opp.Line_Level_Discount_Applied__c = true;
                            }
                            if(opp.GST_in_1__c != null && opp.GST_in_1__c != 0){
                                opp.PriceAfterGST__c = calculatedDiscountPrice + (calculatedDiscountPrice * (opp.GST_in_1__c/100));
                            }
                        }
                    }
                    
                }
                
            }
            
        }
    }
    
    public void KurlOnOpportunityLineItemUploadforSO(List<OpportunityLineItem> OppLineList){
        system.debug('this is in the code' +OppLineList);
        Id kurlOnId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('KurlON Sales Order').getRecordTypeId();
        
        set<string> OppNameSOSet =new set<string>();
        set<string> ProductNameSet =new set<string>();
        set<string> PricebookEntrySet =new set<string>();
        for(OpportunityLineItem oli1:OppLineList){
            OppNameSOSet.add(oli1.Sales_Order_Name__c);
            ProductNameSet.add(oli1.Product_Name_for_Insert__c);
            PricebookEntrySet.add(oli1.PricebookEntry_for_Insert__c);
        }
        
        List<Opportunity> OppfetchRecLst=[Select Id,Name,RecordTypeId from Opportunity where Name =: OppNameSOSet AND RecordTypeId=:kurlOnId];
        List <Product2> productFetch=[SELECT Id,Name,Standard_Price__c FROM Product2 where Name =:ProductNameSet];
        List <PricebookEntry> priceBookFetch=[SELECT Id,Name,Pricebook2.Name FROM PricebookEntry where Name=:PricebookEntrySet
                                              AND Pricebook2.Name=:'KurlON to Retailer Price'];
        system.debug('OppfetchRecLst---->'+OppfetchRecLst);
        system.debug('productFetch---->'+productFetch);
        system.debug('priceBookFetch---->'+priceBookFetch);
        //ean on product & so number
        
        for(OpportunityLineItem oli2:OppLineList){
            for(Opportunity o:OppfetchRecLst){if(oli2.Sales_Order_Name__c==o.Name){oli2.OpportunityId=o.Id;
                                                                                   system.debug('oli2 for Sales Order--->'+oli2);
                                                                                  }
                                             }
        }
        
        //Product
        for(OpportunityLineItem oli3:OppLineList){
            for(Product2 p:productFetch){
                if(oli3.Product_Name_for_Insert__c==p.Name){
                    system.debug(oli3.Product_Name_for_Insert__c);
                    system.debug(p.Name);
                    oli3.Product2Id=p.Id;
                    oli3.UnitPrice=p.Standard_Price__c;
                    system.debug('oli3 for Product2--->'+oli3);
                }
            }
        }   
        //PricebookEntry
        for(OpportunityLineItem oli4:OppLineList){
            for(PricebookEntry pe:priceBookFetch){
                if(oli4.PricebookEntry_for_Insert__c==pe.Name){
                    oli4.PricebookEntryId=pe.Id;
                }
            }
        }
    }    
    
    public void PageLoadTrgHandler(List <OpportunityLineItem> oldOppLineItemLst){
        System.debug('Inside PageLoad Class Handler');
        set<Id> lstId = new set<Id>();
        
        for(OpportunityLineItem opp :oldOppLineItemLst){
            System.debug('Inside Delete');
            lstId.add(opp.OpportunityId);
            list<Opportunity> lstOpp = [select id,PageLoad__c From Opportunity Where Id IN :lstId];
            for(Opportunity opt :lstOpp){
                opt.PageLoad__c = TRUE;
                System.debug('This Page load is now true');
                opt.PageLoad__c = FALSE;
                
            }
            update lstOpp;
            System.debug('This is updated');
            
        }
    }
    
    
}