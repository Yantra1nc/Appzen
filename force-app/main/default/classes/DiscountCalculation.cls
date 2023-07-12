public with sharing class DiscountCalculation {
    
    public static List<Decimal> lstGst = new List<Decimal>();
    public static Map<Id,Decimal> mapDiscount = new Map<Id,Decimal>();
    
    /*@AuraEnabled(cacheable=true)
public static Decimal getDiscount(List<Id> prodId,Id oppId){
System.debug(prodId);
System.debug(oppId);        
Decimal discount = 0.0;
List<Opportunity> opp = [Select AccountId From Opportunity where Id=:oppId limit 1];

for(Id prod:prodId){
List<Product2> p = [Select Brand__c,Collection__c,Product__c from Product2 where Id=:prod limit 1];
if(opp.size() > 0){
if(prod != null && opp[0].AccountId != null){
List<Price_Master__c> lsts1 = [Select Product__c, Account__c, Absolute_Disc_Term__c, Retailer__c, RetailerLocGST_on_MRP__c, LFS__c,
District__c from Price_Master__c where Product__c =:prod and Account__c =:opp[0].AccountId LIMIT 1];
for(Price_Master__c lst : lsts1) {

if(lst != null){                

discount = (lst.Absolute_Disc_Term__c+lst.Retailer__c+lst.RetailerLocGST_on_MRP__c+lst.LFS__c+lst.District__c);                      
mapDiscount.put(prod,discount);

}
}
}

if(prod != null && p[0].Brand__c != null && opp[0].AccountId != null){                
List<Price_Master__c> lsts2 = [Select Brand__c, Account__c, Absolute_Disc_Term__c, Retailer__c, RetailerLocGST_on_MRP__c, LFS__c,
District__c from Price_Master__c where Brand__c =:p[0].Brand__c and Account__c =:opp[0].AccountId LIMIT 1];
for(Price_Master__c lst : lsts2) {

if(lst != null){ 
discount = (lst.Absolute_Disc_Term__c+lst.Retailer__c+lst.RetailerLocGST_on_MRP__c+lst.LFS__c+lst.District__c);
mapDiscount.put(prod,discount);

}
}
} 

if(prod != null && p[0].Collection__c != null && opp[0].AccountId != null){

List<Price_Master__c> lsts2 = [Select Collection__c, Account__c, Absolute_Disc_Term__c, Retailer__c, RetailerLocGST_on_MRP__c, LFS__c,
District__c from Price_Master__c where Collection__c =:p[0].Collection__c and Account__c =:opp[0].AccountId LIMIT 1];
for(Price_Master__c lst : lsts2) {                  
if(lst != null){ 
discount = (lst.Absolute_Disc_Term__c+lst.Retailer__c+lst.RetailerLocGST_on_MRP__c+lst.LFS__c+lst.District__c);                      
mapDiscount.put(prod,discount);
}
}
}

if(prod != null && p[0].Product__c != null && opp[0].AccountId != null){

List<Price_Master__c> lsts3 = [Select Product_Type__c, Account__c, Absolute_Disc_Term__c, Retailer__c, RetailerLocGST_on_MRP__c, LFS__c,
District__c from Price_Master__c where Product_Type__c =:p[0].Product__c and Account__c =:opp[0].AccountId LIMIT 1];
for(Price_Master__c lst : lsts3) {
if(lst != null){
discount = (lst.Absolute_Disc_Term__c+lst.Retailer__c+lst.RetailerLocGST_on_MRP__c+lst.LFS__c+lst.District__c);                       
mapDiscount.put(prod,discount);
}
}
}
System.debug(discount);

}


}       
return discount;

}*/
    
    /*
@AuraEnabled(cacheable=true)
public static Decimal getBasicOrderValue(List<Id> lstProdId,Id oppId){

Decimal basicOrder = 0.0;   

for (Opportunity opp : [select Id,Within_Maharashtra__c,(select Id,Final_Price__c,Additional_Discount_Price__c from OpportunityLineItems) from Opportunity where Id =:oppId]) {
for(OpportunityLineItem oppItem:opp.OpportunityLineItems){
OpportunityWrapper wrapperObj = new OpportunityWrapper();
wrapperObj.finalPrice = oppItem.Final_Price__c;
wrapperObj.additionalDiscountPrice = oppItem.Final_Price__c;
wrapperObj.finalPrice = oppItem.Final_Price__c;
}
}
return basicOrder;
}*/
    
    @AuraEnabled(cacheable=true)
    public static Decimal getGST(List<Id> lstProdId,Id oppId,Boolean flag){
        System.debug(lstProdId);
        System.debug(oppId);
        Decimal gst = 0.0;
        try {
            
            List<Opportunity> opp = [Select AccountId,Within_Maharashtra__c From Opportunity where Id=:oppId limit 1];
            if (opp.size() > 0) {
                for(Id prod:lstProdId){
                    List<Product2> p = [Select HSN_Code__c from Product2 where Id=:prod limit 1];
                    if (opp[0].Within_Maharashtra__c == true) {
                        System.debug('Flag'+flag);
                        List<GST__c> gstList = [SELECT ID,GST_Value__c,CGST_less_than_1000__c,CGST_greater_than_1000__c,SGST_less_than_1000__c,
                                                SGST_greater_than_1000__c,Within_State__c, HSN__c FROM GST__c 
                                                WHERE Within_State__c=:opp[0].Within_Maharashtra__c 
                                                AND HSN__c =:p[0].HSN_Code__c];
                        for(GST__c gli:gstList)
                        {
                            if(gli!=null){
                                if(flag == true){                                   
                                    gst = gli.CGST_less_than_1000__c+ gli.SGST_less_than_1000__c+0.0;
                                    lstGst.add(gst);
                                }
                                else{                                    
                                    gst = gli.CGST_greater_than_1000__c + gli.SGST_greater_than_1000__c + 0.0;
                                    lstGst.add(gst);
                                }                                
                            }
                        }
                    }
                    else {
                        System.debug('Flag'+flag);
                        List<GST__c> gstList2 = [SELECT ID,GST_Value__c,IGST_less_than_1000__c,IGST_greater_than_1000__c,
                                                 Within_State__c, HSN__c FROM GST__c 
                                                 WHERE Within_State__c=:opp[0].Within_Maharashtra__c 
                                                 AND HSN__c =:p[0].HSN_Code__c];
                        
                        
                        for(GST__c gli2:gstList2)
                        {
                            if(gli2!=null){
                                if(flag == true){                       
                                    gst = gli2.IGST_less_than_1000__c + 0.0 + 0.0;
                                    lstGst.add(gst);
                                    System.debug(gst);
                                }
                                else{
                                    gst = gli2.IGST_greater_than_1000__c + 0.0 + 0.0;
                                    lstGst.add(gst);
                                    System.debug(gst);
                                }
                            }
                        }
                    }
                }
                System.debug(lstGst);
            }
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return gst;
    }
    
    @AuraEnabled
    public static void saveLineItems(List<OpportunityWrapper> oppWrapperList){
        try {            
            List<OpportunityLineItem> lstOpp = new List<OpportunityLineItem>();
            System.debug('****** oppWrapperList '+oppWrapperList);
            for (OpportunityWrapper obj : oppWrapperList) {               
                OpportunityLineItem opp = new OpportunityLineItem();
                Pricebook2 pb2 = [select Id,Name from Pricebook2 where Name ='KurlON to Retailer Price' limit 1];
                PricebookEntry pbEntry = [select Id from PricebookEntry where Product2Id =: obj.productId and Pricebook2Id =: pb2.Id limit 1];
                opp.PricebookEntryId = pbEntry.Id;
                opp.Product2Id = obj.productId;
                opp.OpportunityId = obj.opportunityId;
                opp.UnitPrice = obj.kurlonretailprice;
                opp.Quantity = obj.quantity;
                opp.Additional_Discount__c = obj.addDisc;                
                //opp.GST_New__c = obj.gst;
                Opportunity salesOrder = [SELECT Within_Maharashtra__c  FROM Opportunity where Id=:obj.opportunityId];
                System.debug(salesOrder);
                Product2 prod = [SELECT HSN_Code__c FROM Product2 where Id=:obj.productId];
                System.debug(prod);
                if(salesOrder.Within_Maharashtra__c == true){
                    List<GST__c> gstList = [SELECT ID,GST_Value__c,CGST_less_than_1000__c,CGST_greater_than_1000__c,SGST_less_than_1000__c,
                                            SGST_greater_than_1000__c,Within_State__c, HSN__c FROM GST__c 
                                            WHERE Within_State__c=:salesOrder.Within_Maharashtra__c 
                                            AND HSN__c =:prod.HSN_Code__c];
                    System.debug(gstList);
                    
                    for(GST__c gli:gstList)
                    {
                        if(gli!=null){
                            if(obj.kurlonretailprice < gli.GST_Value__c){
                                opp.CGST__c = gli.CGST_less_than_1000__c;
                                opp.SGST__c = gli.SGST_less_than_1000__c;
                                opp.IGST__c = 0.0;
                            }
                            else{
                                opp.CGST__c = gli.CGST_greater_than_1000__c;
                                opp.SGST__c = gli.SGST_greater_than_1000__c;
                                opp.IGST__c = 0.0;
                            }
                            if(obj.discountedAmount < gli.GST_Value__c){
                                opp.CGST__c = gli.CGST_less_than_1000__c;
                                opp.SGST__c = gli.SGST_less_than_1000__c;
                                opp.IGST__c = 0.0;
                            }
                            else{
                                opp.CGST__c = gli.CGST_greater_than_1000__c;
                                opp.SGST__c = gli.SGST_greater_than_1000__c;
                                opp.IGST__c = 0.0;
                                
                            }
                        }
                    }
                }
                else{
                    
                    List<GST__c> gstList2 = [SELECT ID,GST_Value__c,IGST_less_than_1000__c,IGST_greater_than_1000__c,
                                             Within_State__c, HSN__c FROM GST__c 
                                             WHERE Within_State__c=:salesOrder.Within_Maharashtra__c 
                                             AND HSN__c =:prod.HSN_Code__c];
                    
                    
                    for(GST__c gli2:gstList2)
                    {
                        if(gli2!=null){
                            if(obj.kurlonretailprice < gli2.GST_Value__c){
                                opp.IGST__c = gli2.IGST_less_than_1000__c;
                                opp.SGST__c = 0.0;
                                opp.CGST__c = 0.0;
                            }
                            else{
                                opp.IGST__c = gli2.IGST_greater_than_1000__c;
                                opp.SGST__c = 0.0;
                                opp.CGST__c = 0.0;
                            }
                            if(obj.discountedAmount  < gli2.GST_Value__c){
                                opp.GST_in_1__c = gli2.IGST_less_than_1000__c;
                                opp.SGST__c = 0.0;
                                opp.CGST__c = 0.0;
                            }
                            else{
                                opp.IGST__c = gli2.IGST_greater_than_1000__c;
                                opp.SGST__c = 0.0;
                                opp.CGST__c = 0.0;
                            }
                            
                        }
                        
                        
                    }
                    
                    
                }       
                
                opp.Final_Price__c = obj.finalPrice;
                //opp.GST_in_1__c = obj.gstPrice;
                //  opp.PriceAfterGST__c = obj.priceAfterGst;
                opp.Dynamic_Discount__c = obj.discountedAmount;           
                opp.Final_Price__c = obj.finalPrice;
                //opp.discountedAmount__c = obj.discountedAmount;
                //opp.GST_in_1__c = obj.gstPrice; 
                opp.PriceAfterGST__c = obj.discountedAmount + (obj.discountedAmount * (opp.GST_in_1__c/100));
                
                opp.MD_Discount_Term__c = obj.mdDiscountTerm;
                opp.MD_Distributor_Margin__c = obj.mdDistributorMargin;
                opp.MD_LFS_Margin__c = obj.mdLfsMargin;
                opp.MD_Retailer_Margin__c = obj.mdRetailerMargin;
                opp.MD_Retailer_GST__c = obj.mdRetailerGst;
                opp.MU_Discount_Term__c = obj.muDiscountTerm;
                opp.MU_Distributor_Margin__c = obj.muDistributorMargin;
                opp.MU_LFS_Margin__c = obj.muLfsMargin;
                opp.MU_Retailer_Margin__c = obj.muRetailerMargin;
                opp.MU_Retailer_GST__c = obj.muRetailerGst;
                opp.Price_Master_Name__c = obj.priceMasterName;
                opp.Price_Master_Number__c = obj.priceMasterId;
                lstOpp.add(opp);
            }
            System.debug(lstOpp.size());
            insert lstOpp;            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void saveEditedLineItems(List<OpportunityWrapper> oppWrapperList,List<Id> lstToDelete,Id opId){
        ID oppId;
        System.debug('*** lstToDelete '+lstToDelete);
        System.debug('*** oppWrapperList '+oppWrapperList);
        System.debug(' **** opId '+opId);
        try {
            List<OpportunityLineItem> lstToUpdate = new List<OpportunityLineItem>();
            List<OpportunityLineItem> lstToInsert = new List<OpportunityLineItem>();
            List<OpportunityLineItem> lstDelete = new List<OpportunityLineItem>();
            List<Opportunity> lstOpp = new List<Opportunity>();
            
            System.debug(oppWrapperList);
            if (oppWrapperList.size() > 0) {
                for (OpportunityWrapper obj : oppWrapperList) {
                    oppId = obj.opportunityId;
                    System.debug('Final'+obj.finalValue);
                    System.debug('***** Discounted Price '+obj.discountedAmount);
                    
                    Opportunity op = [SELECT Id,Distrbution_Channel__c,CheckUpdateSO__c,Retailer_Order_Value_Ex_GST_Num__c,Retailer_Final_Order_Value__c  FROM Opportunity where Id =:oppId];
                    op.Retailer_Order_Value_Ex_GST_Num__c = obj.basicValue;
                    op.Retailer_Final_Order_Value__c = obj.finalValue;
                    
                 
                    if (lstOpp.size() <= 0) {
                        lstOpp.add(op);                    
                    }
                    if (obj.oppLineItemId != null) {
                        OpportunityLineItem oli = [select Id,Product2Id,OpportunityId,UnitPrice,Quantity,Additional_Discount__c,Final_Price__c from OpportunityLineItem where OpportunityId =:obj.opportunityId and Id =:obj.oppLineItemId limit 1];
                        
                        //oli.Product2Id = obj.productId;
                        //oli.OpportunityId = obj.opportunityId;
                        //oli.UnitPrice = obj.kurlonretailprice;
                        oli.Quantity = obj.quantity;
                        oli.Additional_Discount__c = obj.addDisc;                                  
                        //opp.GST_New__c = obj.gst;                   
                        Opportunity salesOrder = [SELECT Within_Maharashtra__c  FROM Opportunity where Id=:obj.opportunityId];
                        Product2 prod = [SELECT Brand__c,Collection__c,Product__c,HSN_Code__c,(SELECT Id, UnitPrice FROM PricebookEntries WHERE IsActive = True ORDER BY UseStandardPrice DESC, Id DESC Limit 1) FROM Product2 where Id=:obj.productId];
                        //zrlg
                        Price_Master__c pm = DynamicDiscount.getPriceMaster(prod.Id,op.Id);
                        Double distChan = 0;
                        Decimal zrlg = 0;
                        if(op.Distrbution_Channel__c != null){
                           distChan = Double.valueOf(op.Distrbution_Channel__c);
                        }
                        zrlg = UnicommerceSalesOrderUtility.getZRLG(pm,prod,distChan);
                        oli.ZRLG__c = zrlg;
                        System.debug('********* zrlg '+zrlg);

                        if(salesOrder.Within_Maharashtra__c == true){
                            List<GST__c> gstList = [SELECT ID,GST_Value__c,CGST_less_than_1000__c,CGST_greater_than_1000__c,SGST_less_than_1000__c,
                                                    SGST_greater_than_1000__c,Within_State__c, HSN__c FROM GST__c 
                                                    WHERE Within_State__c=:salesOrder.Within_Maharashtra__c 
                                                    AND HSN__c =:prod.HSN_Code__c];
                            System.debug('*** MAH IF gstList '+gstList);
                            
                            System.debug('***MAH  IF obj.discountedAmount  '+obj.discountedAmount );
                            
                            for(GST__c gli:gstList)
                            {
                                System.debug('*** IF gli '+gli);
                                
                                if(gli!=null){
                                    if(obj.kurlonretailprice < gli.GST_Value__c){
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
                                    if(obj.discountedAmount  < gli.GST_Value__c){
                                        oli.GST_in_1__c = gli.IGST_less_than_1000__c;
                                    }else{
                                        oli.GST_in_1__c = gli.IGST_greater_than_1000__c;
                                     }
                                    
                                }
                                
                                
                            }
                        }
                        else{
                            
                            List<GST__c> gstList2 = [SELECT ID,GST_Value__c,IGST_less_than_1000__c,IGST_greater_than_1000__c,
                                                     Within_State__c, HSN__c FROM GST__c 
                                                     WHERE Within_State__c=:salesOrder.Within_Maharashtra__c 
                                                     AND HSN__c =:prod.HSN_Code__c];
                            
                            System.debug('***MAH Else gstList2 '+gstList2);
                            System.debug('***MAH Else obj.discountedAmount  '+obj.discountedAmount );
                            
                            for(GST__c gli2:gstList2)
                            {
                                System.debug('Mah Else GST OBJ '+gli2);
                                if(gli2!=null){
                                    if(obj.kurlonretailprice < gli2.GST_Value__c){
                                        oli.IGST__c = gli2.IGST_less_than_1000__c;
                                        oli.SGST__c = 0.0;
                                        oli.CGST__c = 0.0;
                                        oli.CGST_on_Exmill__c = 0;
                                        oli.SGST_on_Exmill__c = 0;
                                        oli.IGST_on_Exmill__c = gli2.IGST_less_than_1000__c;
                                    }
                                    else{
                                        oli.IGST__c = gli2.IGST_greater_than_1000__c;
                                        oli.SGST__c = 0.0;
                                        oli.CGST__c = 0.0;
                                        oli.CGST_on_Exmill__c = 0;
                                        oli.SGST_on_Exmill__c = 0;
                                        oli.IGST_on_Exmill__c = gli2.IGST_greater_than_1000__c;
                                    }
                                    if(obj.discountedAmount  < gli2.GST_Value__c){
                                        oli.GST_in_1__c = gli2.IGST_less_than_1000__c;
                                    }else{
                                        oli.GST_in_1__c = gli2.IGST_greater_than_1000__c;
                                    }
                                    
                                }
                                
                                
                            }
                            
                            
                        }           
                        oli.Final_Price__c = obj.finalPrice;
                        System.debug('*******IF obj.discountedAmount '+obj.discountedAmount);
                        System.debug('*******IF obj.discountedPrice '+obj.discountedPrice);
                        System.debug('*******IF obj.gstPrice '+obj.gstPrice);
                        System.debug('*******IF obj.priceAfterGst '+obj.priceAfterGst);
                        System.debug('*******IF obj.discountedAmount '+obj.discountedAmount);
                        System.debug('*******IF (obj.discountedAmount * obj.gstPrice) '+(obj.discountedAmount * obj.gstPrice));
                        
                        //oli.discountedAmount__c = obj.discountedAmount;
                        //oli.GST_in_1__c = obj.gstPrice; 
                        oli.PriceAfterGST__c = obj.discountedAmount + (obj.discountedAmount * (oli.GST_in_1__c/100));
                        oli.Dynamic_Discount__c = obj.discountedAmount;           
                        oli.Final_Price__c = obj.finalPrice;
                        oli.MD_Discount_Term__c = obj.mdDiscountTerm;
                        oli.MD_Distributor_Margin__c = obj.mdDistributorMargin;
                        oli.MD_LFS_Margin__c = obj.mdLfsMargin;
                        oli.MD_Retailer_Margin__c = obj.mdRetailerMargin;
                        oli.MD_Retailer_GST__c = obj.mdRetailerGst;
                        oli.MU_Discount_Term__c = obj.muDiscountTerm;
                        oli.MU_Distributor_Margin__c = obj.muDistributorMargin;
                        oli.MU_LFS_Margin__c = obj.muLfsMargin;
                        oli.MU_Retailer_Margin__c = obj.muRetailerMargin;
                        oli.MU_Retailer_GST__c = obj.muRetailerGst;
                        oli.Price_Master_Name__c = obj.priceMasterName;
                        oli.Price_Master_Number__c = obj.priceMasterId;
                        System.debug('if********** obj wrap : '+obj);
                        System.debug('if********** LINE : '+oli);
                        lstToUpdate.add(oli);                   
                    }else {
                        System.debug('OppNull');
                        OpportunityLineItem opp = new OpportunityLineItem();
                        Pricebook2 pb2 = [select Id,Name from Pricebook2 where Name ='KurlON to Retailer Price' limit 1];
                        PricebookEntry pbEntry = [select Id from PricebookEntry where Product2Id =: obj.productId and Pricebook2Id =: pb2.Id limit 1];
                        System.debug(pbEntry);
                        opp.PricebookEntryId = pbEntry.Id;
                        opp.Product2Id = obj.productId;
                        opp.OpportunityId = obj.opportunityId;
                        opp.UnitPrice = obj.kurlonretailprice;
                        opp.Quantity = obj.quantity;
                        opp.Additional_Discount__c = obj.addDisc;                                  
                        //opp.GST_New__c = obj.gst; 
                        Opportunity salesOrder = [SELECT Within_Maharashtra__c  FROM Opportunity where Id=:obj.opportunityId];
                        System.debug(salesOrder);
                        Product2 prod = [SELECT Brand__c,Collection__c,Product__c,HSN_Code__c,(SELECT Id, UnitPrice FROM PricebookEntries WHERE IsActive = True ORDER BY UseStandardPrice DESC, Id DESC Limit 1) FROM Product2 where Id=:obj.productId];
                        
                        //zrlg
                        Price_Master__c pm = DynamicDiscount.getPriceMaster(prod.Id,op.Id);
                        Double distChan = 0;
                        Decimal zrlg = 0;
                        if(op.Distrbution_Channel__c != null){
                            distChan = Double.valueOf(op.Distrbution_Channel__c);
                        }
                        zrlg = UnicommerceSalesOrderUtility.getZRLG(pm,prod,distChan);
                        opp.ZRLG__c = zrlg;
                        System.debug('**********zrlg '+zrlg);
                        if(salesOrder.Within_Maharashtra__c == true){
                            List<GST__c> gstList = [SELECT ID,GST_Value__c,CGST_less_than_1000__c,CGST_greater_than_1000__c,SGST_less_than_1000__c,
                                                    SGST_greater_than_1000__c,Within_State__c, HSN__c FROM GST__c 
                                                    WHERE Within_State__c=:salesOrder.Within_Maharashtra__c 
                                                    AND HSN__c =:prod.HSN_Code__c];
                            System.debug('****else lese gstList1 '+gstList);
                            System.debug('**** else lese obj.discountedPrice   '+obj.discountedPrice  );
                            
                            for(GST__c gli:gstList)
                            {
                                System.debug('***else lese GST OBJ '+gli);
                                if(gli!=null){
                                    if(obj.kurlonretailprice < gli.GST_Value__c){
                                        opp.CGST__c = gli.CGST_less_than_1000__c;
                                        opp.SGST__c = gli.SGST_less_than_1000__c;
                                        opp.IGST__c = 0.0;
                                        opp.CGST_on_Exmill__c = gli.CGST_less_than_1000__c;
                                        opp.SGST_on_Exmill__c = gli.SGST_less_than_1000__c;
                                        opp.IGST_on_Exmill__c = 0.0;
                                    }
                                    else{
                                        opp.CGST__c = gli.CGST_greater_than_1000__c;
                                        opp.SGST__c = gli.SGST_greater_than_1000__c;
                                        opp.IGST__c = 0.0;
                                        opp.CGST_on_Exmill__c = gli.CGST_greater_than_1000__c;
                                        opp.SGST_on_Exmill__c = gli.SGST_greater_than_1000__c;
                                        opp.IGST_on_Exmill__c = 0.0;
                                    }
                                    if(obj.discountedPrice  < gli.GST_Value__c){
                                        opp.GST_in_1__c = gli.IGST_less_than_1000__c;
                                    }else if(obj.discountedAmount < gli.GST_Value__c){
                                        opp.GST_in_1__c = gli.IGST_less_than_1000__c;
                                    }else{
                                        opp.GST_in_1__c = gli.IGST_greater_than_1000__c;
                                    }
                                    
                                    
                                }
                                
                                
                            }
                        }
                        else{
                            
                            List<GST__c> gstList2 = [SELECT ID,IGST_less_than_1000__c,GST_Value__c,IGST_greater_than_1000__c,
                                                     Within_State__c, HSN__c FROM GST__c 
                                                     WHERE Within_State__c=:salesOrder.Within_Maharashtra__c 
                                                     AND HSN__c =:prod.HSN_Code__c];
                            
                            System.debug('****else lese gstList2 '+gstList2);
                            for(GST__c gli2:gstList2)
                            {
                                System.debug('****elseGST OBJ  '+gli2);
                                
                                if(gli2!=null){
                                    System.debug('**** gli2.IGST_less_than_1000__c '+gli2.IGST_less_than_1000__c);
                                    if(obj.kurlonretailprice < gli2.GST_Value__c){
                                        opp.IGST__c = gli2.IGST_less_than_1000__c;
                                        opp.SGST__c = 0.0;
                                        opp.CGST__c = 0.0;
                                        opp.CGST_on_Exmill__c = 0;
                                        opp.SGST_on_Exmill__c = 0;
                                        opp.IGST_on_Exmill__c = gli2.IGST_less_than_1000__c;
                                    }
                                    else{
                                        opp.IGST__c = gli2.IGST_greater_than_1000__c;
                                        opp.SGST__c = 0.0;
                                        opp.CGST__c = 0.0;
                                        opp.CGST_on_Exmill__c = 0;
                                        opp.SGST_on_Exmill__c = 0;
                                        opp.IGST_on_Exmill__c = gli2.IGST_greater_than_1000__c;
                                    }
                                    System.debug('*** obj.discountedPrice '+obj.discountedPrice);
                                    if(obj.discountedPrice  < gli2.GST_Value__c){
                                        opp.GST_in_1__c = gli2.IGST_less_than_1000__c;
                                        System.debug('**** opp.GST_in_1__c '+opp.GST_in_1__c);
                                    }else if(obj.discountedAmount < gli2.GST_Value__c){
                                        opp.GST_in_1__c = gli2.IGST_less_than_1000__c;
                                    }else{
                                        opp.GST_in_1__c = gli2.IGST_greater_than_1000__c;
                                     }
                                }
                            }
                            
                            
                        }     
                        System.debug('******* obj.discountedAmount '+obj.discountedAmount);
                        //opp.discountedAmount__c = obj.discountedAmount;
                        opp.Final_Price__c = obj.finalPrice;
                        //opp.GST_in_1__c = obj.gstPrice; 
                        // opp.PriceAfterGST__c = obj.priceAfterGst;
                        opp.Dynamic_Discount__c = obj.discountedAmount;  
                        //opp.discountedAmount__c = obj.discountedAmount;
                        //  opp.GST_in_1__c = obj.gstPrice; 
                        if(opp.GST_in_1__c != null){     
                            opp.PriceAfterGST__c = obj.discountedAmount + (obj.discountedAmount * (opp.GST_in_1__c/100));
                        }
                        opp.Final_Price__c = obj.finalPrice;
                        opp.MD_Discount_Term__c = obj.mdDiscountTerm;
                        opp.MD_Distributor_Margin__c = obj.mdDistributorMargin;
                        opp.MD_LFS_Margin__c = obj.mdLfsMargin;
                        opp.MD_Retailer_Margin__c = obj.mdRetailerMargin;
                        opp.MD_Retailer_GST__c = obj.mdRetailerGst;
                        opp.MU_Discount_Term__c = obj.muDiscountTerm;
                        opp.MU_Distributor_Margin__c = obj.muDistributorMargin;
                        opp.MU_LFS_Margin__c = obj.muLfsMargin;
                        opp.MU_Retailer_Margin__c = obj.muRetailerMargin;
                        opp.MU_Retailer_GST__c = obj.muRetailerGst;
                        opp.Price_Master_Name__c = obj.priceMasterName;
                        opp.Price_Master_Number__c = obj.priceMasterId;
                        lstToInsert.add(opp);
                        
                        System.debug('esle********** obj wrap : '+obj);
                        System.debug('esle********** LINE : '+opp);
                        System.debug(lstToInsert);
                    }
                }  
            }
            
            for (OpportunityLineItem op : [select Id,Product2Id from OpportunityLineItem where OpportunityId =:opId]) {
                if (lstToDelete.contains(op.Product2Id)) {
                    lstDelete.add(op);
                }
            } 
            System.debug(lstDelete);          
            insert lstToInsert;
            update lstToUpdate;
            delete lstDelete;
            update lstOpp;
            
        } catch (Exception e) {
            System.debug(' ***  ERROR  '+e.getCause()+' '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage()+' '+e.getLineNumber());
        }
    }
    
    public class OpportunityWrapper{
        @AuraEnabled
        public Decimal finalPrice { get; set; }
        @AuraEnabled
        public Decimal discountedAmount { get; set; }
        
        @AuraEnabled
        public Id oppLineItemId { get; set; }
        
        @AuraEnabled
        public Id opportunityId { get; set; }
        
        @AuraEnabled
        public Decimal additionalDiscountPrice { get; set; }
        
        @AuraEnabled
        public String brand { get; set; }
        
        @AuraEnabled
        public String collection { get; set; }
        
        @AuraEnabled
        public String name { get; set; }
        
        @AuraEnabled
        public String size { get; set; }
        
        @AuraEnabled
        public Decimal quantity { get; set; }
        
        @AuraEnabled
        public String designNo { get; set; }
        
        @AuraEnabled
        public String designType { get; set; }
        
        @AuraEnabled
        public Decimal kurlonretailprice { get; set; }
        
        @AuraEnabled
        public String color { get; set; }
        
        @AuraEnabled
        public Decimal addDisc { get; set; }
        
        @AuraEnabled
        public Decimal gst { get; set; }
        
        @AuraEnabled
        public Id productId { get; set; }
        
        @AuraEnabled
        public Decimal igst { get; set; }
        
        @AuraEnabled
        public Decimal cgst { get; set; }
        
        @AuraEnabled
        public Decimal sgst { get; set; }
        
        @AuraEnabled
        public Decimal basicValue { get; set; }
        
        @AuraEnabled
        public Decimal finalValue { get; set; }
        
        @AuraEnabled
        public String priceMasterId { get; set; }
        
        @AuraEnabled
        public String priceMasterName { get; set; }
        
        @AuraEnabled
        public Decimal mdDiscountTerm { get; set; }
        
        @AuraEnabled
        public Decimal mdDistributorMargin { get; set; }
        
        @AuraEnabled
        public Decimal mdLfsMargin { get; set; }
        
        @AuraEnabled
        public Decimal mdRetailerGst { get; set; }
        
        @AuraEnabled
        public Decimal mdRetailerMargin { get; set; }
        
        @AuraEnabled
        public Decimal muDiscountTerm { get; set; }
        
        @AuraEnabled
        public Decimal muDistributorMargin { get; set; }
        
        @AuraEnabled
        public Decimal muLfsMargin { get; set; }
        
        @AuraEnabled
        public Decimal muRetailerGst { get; set; }
        
        @AuraEnabled
        public Decimal muRetailerMargin { get; set; }
        
        @AuraEnabled
        public Decimal priceAfterGst { get; set; }
        
        @AuraEnabled
        public Decimal gstPrice { get; set; }
        
        @AuraEnabled
        public Decimal discountedPrice { get; set; }
        
    }
}