trigger ValuePopulation on OpportunityLineItem (before insert, before update) {
    
    Decimal discount =0.0;  
    //   Decimal absolutediscterm = lst.Absolute_Disc_Term__c;
    for(OpportunityLineItem ol : Trigger.new){
        
        System.debug('Inside ValuePopulation Trigger');
        System.debug('ol.Product2Id '+ol.Product2Id);
        System.debug('ol.Account__c '+ol.Account__c);
        
        if(ol.Product2Id != null && ol.Account__c != null){            
            List<Price_Master__c> lsts1 = [Select Activated_End_Date__c,Activated_Start_Date__c,Active__c,Brand__c,Collection__c,Account__c,Customer_Code__c,Marking__c,MD_Disc_Term__c,MD_Distributor_Margin__c,MD_LFS_Margin__c,MD_Retailer_GST__c,MD_Retailer_Margin__c,MU_Discount_Term__c,MU_Distributor_Margin__c,MU_LFS_Margin__c,MU_Retailer_GST__c,MU_Retailer_Margin__c,Product__c,Product_Type__c
                                           from Price_Master__c where Product__c =:ol.Product2Id and Account__c =:ol.Account__c LIMIT 1];
            System.debug('lsts1 '+lsts1);
            for(Price_Master__c lst : lsts1) {
                
                if(lst != null){  
                    
                    ol.MD_Discount_Term__c = lst.MD_Disc_Term__c;
                    ol.MD_Distributor_Margin__c = lst.MD_Distributor_Margin__c;
                    ol.MD_LFS_Margin__c = lst.MD_LFS_Margin__c;
                    ol.MD_Retailer_GST__c = lst.MD_Retailer_GST__c;
                    ol.MD_Retailer_Margin__c = lst.MD_Retailer_Margin__c;
                    ol.MU_Discount_Term__c = lst.MU_Discount_Term__c;
                    ol.MU_Distributor_Margin__c = lst.MU_Discount_Term__c;
                    ol.MU_LFS_Margin__c = lst.MU_LFS_Margin__c;
                    ol.MU_Retailer_GST__c = lst.MU_Retailer_GST__c;
                    ol.MU_Retailer_Margin__c = lst.MU_Retailer_Margin__c;
                    
                    Decimal discount = (lst.MD_Disc_Term__c+lst.MD_Distributor_Margin__c+lst.MD_LFS_Margin__c+lst.MD_Retailer_GST__c+lst.MU_Discount_Term__c+lst.MU_Discount_Term__c+lst.MU_LFS_Margin__c+lst.MU_Retailer_GST__c+lst.MU_Retailer_Margin__c);
                    System.debug('Discount '+ discount);
                    ol.Discount = discount;
                    //     ol.TotalPrice = (((ol.GST__c * ol.TotalPrice )/100) + ol.TotalPrice );
                }
            }
        }
        if(ol.Product2Id != null && ol.Brand__c != null && ol.Account__c != null){
            System.debug('Inside Brand');
            List<Price_Master__c> lsts2 = [Select Activated_End_Date__c,Activated_Start_Date__c,Active__c,Brand__c,Collection__c,Account__c,Customer_Code__c,Marking__c,MD_Disc_Term__c,MD_Distributor_Margin__c,MD_LFS_Margin__c,MD_Retailer_GST__c,MD_Retailer_Margin__c,MU_Discount_Term__c,MU_Distributor_Margin__c,MU_LFS_Margin__c,MU_Retailer_GST__c,MU_Retailer_Margin__c,Product__c,Product_Type__c
                                           from Price_Master__c where Brand__c =:ol.Brand__c and Account__c =:ol.Account__c LIMIT 1];
            for(Price_Master__c lst : lsts2) {
                
                //   System.debug('Absolute_Disc_Term__c '+lst.Absolute_Disc_Term__c);
                //  System.debug('Retailer__c '+lst.Retailer__c);
                //  System.debug('RetailerLocGST_on_MRP__c '+lst.RetailerLocGST_on_MRP__c);
                // System.debug('LFS__c '+lst.LFS__c);
                
                if(lst != null){                
                    ol.MD_Discount_Term__c = lst.MD_Disc_Term__c;
                    ol.MD_Distributor_Margin__c = lst.MD_Distributor_Margin__c;
                    ol.MD_LFS_Margin__c = lst.MD_LFS_Margin__c;
                    ol.MD_Retailer_GST__c = lst.MD_Retailer_GST__c;
                    ol.MD_Retailer_Margin__c = lst.MD_Retailer_Margin__c;
                    ol.MU_Discount_Term__c = lst.MU_Discount_Term__c;
                    ol.MU_Distributor_Margin__c = lst.MU_Discount_Term__c;
                    ol.MU_LFS_Margin__c = lst.MU_LFS_Margin__c;
                    ol.MU_Retailer_GST__c = lst.MU_Retailer_GST__c;
                    ol.MU_Retailer_Margin__c = lst.MU_Retailer_Margin__c;
                    
                    Decimal discount = (lst.MD_Disc_Term__c+lst.MD_Distributor_Margin__c+lst.MD_LFS_Margin__c+lst.MD_Retailer_GST__c+lst.MU_Discount_Term__c+lst.MU_Discount_Term__c+lst.MU_LFS_Margin__c+lst.MU_Retailer_GST__c+lst.MU_Retailer_Margin__c);
                    System.debug('Discount '+ discount);
                    ol.Discount = discount;
                    //     ol.TotalPrice = (((ol.GST__c * ol.TotalPrice )/100) + ol.TotalPrice );
                }
            }
        } 
        if(ol.Product2Id != null && ol.Collection__c != null && ol.Account__c != null){
            System.debug('Inside Collection');
            List<Price_Master__c> lsts2 = [Select Activated_End_Date__c,Activated_Start_Date__c,Active__c,Brand__c,Collection__c,Account__c,Customer_Code__c,Marking__c,MD_Disc_Term__c,MD_Distributor_Margin__c,MD_LFS_Margin__c,MD_Retailer_GST__c,MD_Retailer_Margin__c,MU_Discount_Term__c,MU_Distributor_Margin__c,MU_LFS_Margin__c,MU_Retailer_GST__c,MU_Retailer_Margin__c,Product__c,Product_Type__c from Price_Master__c where Collection__c =:ol.Collection__c and Account__c =:ol.Account__c LIMIT 1];
            for(Price_Master__c lst : lsts2) {
                
                //    System.debug('Absolute_Disc_Term__c '+lst.Absolute_Disc_Term__c);
                //  System.debug('Retailer__c '+lst.Retailer__c);
                //System.debug('RetailerLocGST_on_MRP__c '+lst.RetailerLocGST_on_MRP__c);
                //System.debug('LFS__c '+lst.LFS__c);
                
                if(lst != null){                
                    ol.MD_Discount_Term__c = lst.MD_Disc_Term__c;
                    ol.MD_Distributor_Margin__c = lst.MD_Distributor_Margin__c;
                    ol.MD_LFS_Margin__c = lst.MD_LFS_Margin__c;
                    ol.MD_Retailer_GST__c = lst.MD_Retailer_GST__c;
                    ol.MD_Retailer_Margin__c = lst.MD_Retailer_Margin__c;
                    ol.MU_Discount_Term__c = lst.MU_Discount_Term__c;
                    ol.MU_Distributor_Margin__c = lst.MU_Discount_Term__c;
                    ol.MU_LFS_Margin__c = lst.MU_LFS_Margin__c;
                    ol.MU_Retailer_GST__c = lst.MU_Retailer_GST__c;
                    ol.MU_Retailer_Margin__c = lst.MU_Retailer_Margin__c;
                    
                    Decimal discount = (lst.MD_Disc_Term__c+lst.MD_Distributor_Margin__c+lst.MD_LFS_Margin__c+lst.MD_Retailer_GST__c+lst.MU_Discount_Term__c+lst.MU_Discount_Term__c+lst.MU_LFS_Margin__c+lst.MU_Retailer_GST__c+lst.MU_Retailer_Margin__c);
                    System.debug('Discount '+ discount);
                    ol.Discount = discount;
                    //     ol.TotalPrice = (((ol.GST__c * ol.TotalPrice )/100) + ol.TotalPrice );
                }
            }
        }
        if(ol.Product2Id != null && ol.Product_Type__c != null && ol.Account__c != null){
            System.debug('Inside Product Type');
            List<Price_Master__c> lsts3 = [Select Activated_End_Date__c,Activated_Start_Date__c,Active__c,Brand__c,Collection__c,Account__c,Customer_Code__c,Marking__c,MD_Disc_Term__c,MD_Distributor_Margin__c,MD_LFS_Margin__c,MD_Retailer_GST__c,MD_Retailer_Margin__c,MU_Discount_Term__c,MU_Distributor_Margin__c,MU_LFS_Margin__c,MU_Retailer_GST__c,MU_Retailer_Margin__c,Product__c,Product_Type__c from Price_Master__c where Product_Type__c =:ol.Product_Type__c and Account__c =:ol.Account__c LIMIT 1];
            for(Price_Master__c lst : lsts3) {
                System.debug('Product_Type__c : '+lst.Product_Type__c);
                
                
                if(lst != null){                
                    ol.MD_Discount_Term__c = lst.MD_Disc_Term__c;
                    ol.MD_Distributor_Margin__c = lst.MD_Distributor_Margin__c;
                    ol.MD_LFS_Margin__c = lst.MD_LFS_Margin__c;
                    ol.MD_Retailer_GST__c = lst.MD_Retailer_GST__c;
                    ol.MD_Retailer_Margin__c = lst.MD_Retailer_Margin__c;
                    ol.MU_Discount_Term__c = lst.MU_Discount_Term__c;
                    ol.MU_Distributor_Margin__c = lst.MU_Discount_Term__c;
                    ol.MU_LFS_Margin__c = lst.MU_LFS_Margin__c;
                    ol.MU_Retailer_GST__c = lst.MU_Retailer_GST__c;
                    ol.MU_Retailer_Margin__c = lst.MU_Retailer_Margin__c;
                    
                    Decimal discount = (lst.MD_Disc_Term__c+lst.MD_Distributor_Margin__c+lst.MD_LFS_Margin__c+lst.MD_Retailer_GST__c+lst.MU_Discount_Term__c+lst.MU_Discount_Term__c+lst.MU_LFS_Margin__c+lst.MU_Retailer_GST__c+lst.MU_Retailer_Margin__c);
                    System.debug('Discount '+ discount);
                    ol.Discount = discount;
                    //     ol.TotalPrice = (((ol.GST__c * ol.TotalPrice )/100) + ol.TotalPrice );
                }
            }
        }
    }
}