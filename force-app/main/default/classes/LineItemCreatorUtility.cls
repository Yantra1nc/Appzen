public class LineItemCreatorUtility {
    @future
    public static void createFile(String JSONStr){
        Opportunity oppRecord;
        OpportunityLineItem oli = new OpportunityLineItem();
        Integer qty = 0;
        Integer count = 0;
        Integer lstOlisize = 0;
        String zrlgPercentage = '';
        
        if(String.isNotBlank(JSONStr)){
            Map<String,Object>dataMap = (Map<String,Object>) JSON.deserializeUntyped(JSONStr);
            if(dataMap != null){
                System.debug('Data found '+dataMap);
                if(dataMap.containsKey('oppRecord')){
                    sObject opprec = (Opportunity) JSON.deserialize(JSON.serialize(dataMap.get('oppRecord')), Opportunity.Class);
                    oppRecord = (Opportunity) opprec;
                }
                if(dataMap.containsKey('OliRecord')){
                    sObject opprec = (OpportunityLineItem) JSON.deserialize(JSON.serialize(dataMap.get('OliRecord')), OpportunityLineItem.Class);
                    oli = (OpportunityLineItem) opprec;
                }   
                if(dataMap.containsKey('qty')){
                    qty = (Integer) dataMap.get('qty');
                }   
                if(dataMap.containsKey('count')){
                    count = (Integer) dataMap.get('count');
                }   
                if(dataMap.containsKey('lstOlisize')){
                    lstOlisize = (Integer) dataMap.get('lstOlisize');
                }    
                if(dataMap.containsKey('zrlgPercentage')){
                    zrlgPercentage = (String) dataMap.get('zrlgPercentage');
                }   
            }
            
            
            System.debug('**** oppRecord '+oppRecord);
            System.debug('**** OliRecord '+oli);
            System.debug('**** qty '+qty);
            System.debug('**** count '+count);
            System.debug('**** lstOliSize '+lstOliSize);
            String body = '';
            
            if(oppRecord != null){
                Attachment attachFile = new Attachment();
                attachFile.ParentId = oppRecord.Id;
                attachFile.Name = qty+ + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt';
                List<String>bodyList = new List<String>();
                for(Integer i = 1;i<=qty;i++){
                    String strBody = '';
                    if(lstOlisize == 1){
                        if(qty == 1){
                            SalesOrderWrapper.SaleOrderItems line = new SalesOrderWrapper.SaleOrderItems();
                            line.itemSku = oli.Product2.Material_Number__c;
                            line.shippingMethodCode = 'STD';
                            line.code = oli.Product2.Material_Number__c+'-'+i;//+generateRandomString(3);
                            line.packetNumber = '1';
                            line.totalPrice = String.valueOf(oli.Final_Order_Value_after_GST__c);
                            line.sellingPrice = String.valueOf(oli.Final_Order_Value_after_GST__c);
                            line.prepaidAmount = '0';
                            line.discount = '0';
                            line.shippingCharges = '0';
                            
                            List<SalesOrderWrapper.CustomFieldValues>fields = new List<SalesOrderWrapper.CustomFieldValues>();
                            
                            SalesOrderWrapper.CustomFieldValues field1 = new SalesOrderWrapper.CustomFieldValues();
                            field1.name = 'ITEMSTATUS';
                            field1.value = oli.Item_Status__c;
                            //fields.add(field1);
                            
                            SalesOrderWrapper.CustomFieldValues field2 = new SalesOrderWrapper.CustomFieldValues();
                            field2.name = 'ZADCADDITIONALDISCOUNT';
                            field2.value = String.valueOf(oli.Additional_Discount__c);
                            fields.add(field2);
                            
                            SalesOrderWrapper.CustomFieldValues field3 = new SalesOrderWrapper.CustomFieldValues();
                            field3.name = 'ZDC2DISCOUNT';
                            if(oli.MD_Discount_Term__c != null || oli.MD_Discount_Term__c != 0){
                                field3.value = String.valueOf(oli.MD_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                            }else{
                                field3.value = String.valueOf(oli.MU_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                            }
                            fields.add(field3);
                            
                            SalesOrderWrapper.CustomFieldValues field4 = new SalesOrderWrapper.CustomFieldValues();
                            field4.name = 'ZDMIDISTRIBUTORMARGIN';
                            if(oli.MD_Distributor_Margin__c != null && oli.MD_Distributor_Margin__c != 0){
                                field4.value = String.valueOf(oli.MD_Distributor_Margin__c); //MD Distributor Margin %  MU Distributor Margin % 
                            }else{
                                field4.value = String.valueOf(oli.MU_Distributor_Margin__c);  
                            }
                            
                            fields.add(field4);
                            
                            SalesOrderWrapper.CustomFieldValues field5 = new SalesOrderWrapper.CustomFieldValues();
                            field5.name = 'ZMRPMRP';
                            field5.value = String.valueOf(oli.UnitPrice); ///Retailer Price
                            fields.add(field5);
                            
                            SalesOrderWrapper.CustomFieldValues field6 = new SalesOrderWrapper.CustomFieldValues();
                            field6.name = 'ZRLGRETAILERGST';
                            field6.value = String.valueOf(zrlgPercentage);
                            fields.add(field6);
                            
                            SalesOrderWrapper.CustomFieldValues field7 = new SalesOrderWrapper.CustomFieldValues();
                            field7.name = 'ZRMDRETAILERMARGIN';
                            field7.value = String.valueOf(oli.MD_Retailer_Margin__c);
                            fields.add(field7);
                            if(fields != null && !fields.isEmpty()){
                                line.customFieldValues = fields;
                            }
                            
                            //field4.value = String.valueOf(zrlgPercentage);
                            
                            
                            strBody += JSON.serialize(line);
                            
                        }
                        else if(qty > 1 && qty != i){
                            SalesOrderWrapper.SaleOrderItems line = new SalesOrderWrapper.SaleOrderItems();
                            line.itemSku = oli.Product2.Material_Number__c;
                            line.shippingMethodCode = 'STD';
                            line.code = oli.Product2.Material_Number__c+'-'+i;//''+generateRandomString(3);
                            line.packetNumber = '1';
                            line.totalPrice = oli.Final_Order_Value_after_GST__c != null ? String.valueOf(oli.Final_Order_Value_after_GST__c / qty) : '0';
                            line.sellingPrice = oli.Final_Order_Value_after_GST__c != null ? String.valueOf(oli.Final_Order_Value_after_GST__c / qty) : '0';
                            line.prepaidAmount = '0';
                            line.discount = '0';
                            line.shippingCharges = '0';
                            
                            List<SalesOrderWrapper.CustomFieldValues>fields = new List<SalesOrderWrapper.CustomFieldValues>();
                            
                            SalesOrderWrapper.CustomFieldValues field1 = new SalesOrderWrapper.CustomFieldValues();
                            field1.name = 'ITEMSTATUS';
                            field1.value = oli.Item_Status__c;
                            //fields.add(field1);
                            
                            SalesOrderWrapper.CustomFieldValues field2 = new SalesOrderWrapper.CustomFieldValues();
                            field2.name = 'ZADCADDITIONALDISCOUNT';
                            field2.value = String.valueOf(oli.Additional_Discount__c);
                            fields.add(field2);
                            
                            SalesOrderWrapper.CustomFieldValues field3 = new SalesOrderWrapper.CustomFieldValues();
                            field3.name = 'ZDC2DISCOUNT';
                            if(oli.MD_Discount_Term__c != null || oli.MD_Discount_Term__c != 0){
                                field3.value = String.valueOf(oli.MD_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                            }else{
                                field3.value = String.valueOf(oli.MU_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                            }
                            fields.add(field3);
                            
                            SalesOrderWrapper.CustomFieldValues field4 = new SalesOrderWrapper.CustomFieldValues();
                            field4.name = 'ZDMIDISTRIBUTORMARGIN';
                            if(oli.MD_Distributor_Margin__c != null && oli.MD_Distributor_Margin__c != 0){
                                field4.value = String.valueOf(oli.MD_Distributor_Margin__c); //MD Distributor Margin %  MU Distributor Margin % 
                            }else{
                                field4.value = String.valueOf(oli.MU_Distributor_Margin__c);  
                            }
                            //field4.value = String.valueOf(zrlgPercentage);
                            fields.add(field4);
                            
                            SalesOrderWrapper.CustomFieldValues field5 = new SalesOrderWrapper.CustomFieldValues();
                            field5.name = 'ZMRPMRP';
                            field5.value = String.valueOf(oli.UnitPrice); ///Retailer Price
                            fields.add(field5);
                            
                            SalesOrderWrapper.CustomFieldValues field6 = new SalesOrderWrapper.CustomFieldValues();
                            field6.name = 'ZRLGRETAILERGST';
                            field6.value = String.valueOf(zrlgPercentage);
                            if(oli.MD_Retailer_GST__c != null){
                                fields.add(field6);
                            }
                            SalesOrderWrapper.CustomFieldValues field7 = new SalesOrderWrapper.CustomFieldValues();
                            field7.name = 'ZRMDRETAILERMARGIN';
                            field7.value = String.valueOf(oli.MD_Retailer_Margin__c);
                            if(oli.MD_Retailer_Margin__c != null){
                                fields.add(field7);
                            }
                            if(fields != null && !fields.isEmpty()){
                                line.customFieldValues = fields;
                            }
                            strBody += JSON.serialize(line);
                            
                            
                        } 
                        else if(qty == i){
                            SalesOrderWrapper.SaleOrderItems line = new SalesOrderWrapper.SaleOrderItems();
                            line.itemSku = oli.Product2.Material_Number__c;
                            line.shippingMethodCode = 'STD';
                            line.code = oli.Product2.Material_Number__c+'-'+i;//''+generateRandomString(3);
                            line.packetNumber = '1';
                            line.totalPrice = oli.Final_Order_Value_after_GST__c  != null ? String.valueOf(oli.Final_Order_Value_after_GST__c / qty) : '0';
                            line.sellingPrice = oli.Final_Order_Value_after_GST__c != null ? String.valueOf(oli.Final_Order_Value_after_GST__c / qty) : '0';
                            line.prepaidAmount = '0';
                            line.discount = '0';
                            line.shippingCharges = '0';
                            
                            List<SalesOrderWrapper.CustomFieldValues>fields = new List<SalesOrderWrapper.CustomFieldValues>();
                            
                            SalesOrderWrapper.CustomFieldValues field1 = new SalesOrderWrapper.CustomFieldValues();
                            field1.name = 'ITEMSTATUS';
                            field1.value = oli.Item_Status__c;
                            //fields.add(field1);
                            
                            SalesOrderWrapper.CustomFieldValues field2 = new SalesOrderWrapper.CustomFieldValues();
                            field2.name = 'ZADCADDITIONALDISCOUNT';
                            field2.value = String.valueOf(oli.Additional_Discount__c);
                            fields.add(field2);
                            
                            SalesOrderWrapper.CustomFieldValues field3 = new SalesOrderWrapper.CustomFieldValues();
                            field3.name = 'ZDC2DISCOUNT';
                            if(oli.MD_Discount_Term__c != null || oli.MD_Discount_Term__c != 0){
                                field3.value = String.valueOf(oli.MD_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                            }else{
                                field3.value = String.valueOf(oli.MU_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                            }
                            fields.add(field3);
                            
                            SalesOrderWrapper.CustomFieldValues field4 = new SalesOrderWrapper.CustomFieldValues();
                            field4.name = 'ZDMIDISTRIBUTORMARGIN';
                            if(oli.MD_Distributor_Margin__c != null && oli.MD_Distributor_Margin__c != 0){
                                field4.value = String.valueOf(oli.MD_Distributor_Margin__c); //MD Distributor Margin %  MU Distributor Margin % 
                            }else{
                                field4.value = String.valueOf(oli.MU_Distributor_Margin__c);  
                            }
                            //field4.value = String.valueOf(zrlgPercentage);
                            fields.add(field4);
                            
                            SalesOrderWrapper.CustomFieldValues field5 = new SalesOrderWrapper.CustomFieldValues();
                            field5.name = 'ZMRPMRP';
                            field5.value = String.valueOf(oli.UnitPrice); ///Retailer Price
                            fields.add(field5);
                            
                            SalesOrderWrapper.CustomFieldValues field6 = new SalesOrderWrapper.CustomFieldValues();
                            field6.name = 'ZRLGRETAILERGST';
                            field6.value = String.valueOf(zrlgPercentage);
                            if(oli.MD_Retailer_GST__c != null){
                                fields.add(field6);
                            }
                            SalesOrderWrapper.CustomFieldValues field7 = new SalesOrderWrapper.CustomFieldValues();
                            field7.name = 'ZRMDRETAILERMARGIN';
                            field7.value = String.valueOf(oli.MD_Retailer_Margin__c);
                            if(oli.MD_Retailer_Margin__c != null){
                                fields.add(field7);
                            }
                            if(fields != null && !fields.isEmpty()){
                                line.customFieldValues = fields;
                            }
                            strBody += JSON.serialize(line);
                            
                        }                    
                    }
                    else if(lstOlisize > 1){
                        if(qty == 1){
                            SalesOrderWrapper.SaleOrderItems line = new SalesOrderWrapper.SaleOrderItems();
                            line.itemSku = oli.Product2.Material_Number__c;
                            line.shippingMethodCode = 'STD';
                            line.code = oli.Product2.Material_Number__c+'-'+i;//''+generateRandomString(3);
                            line.packetNumber = '1';
                            line.totalPrice = String.valueOf(oli.Final_Order_Value_after_GST__c);
                            line.sellingPrice = String.valueOf(oli.Final_Order_Value_after_GST__c);
                            line.prepaidAmount = '0';
                            line.discount = '0';
                            line.shippingCharges = '0';
                            
                            List<SalesOrderWrapper.CustomFieldValues>fields = new List<SalesOrderWrapper.CustomFieldValues>();
                            
                            SalesOrderWrapper.CustomFieldValues field1 = new SalesOrderWrapper.CustomFieldValues();
                            field1.name = 'ITEMSTATUS';
                            field1.value = oli.Item_Status__c;
                            //fields.add(field1);
                            
                            SalesOrderWrapper.CustomFieldValues field2 = new SalesOrderWrapper.CustomFieldValues();
                            field2.name = 'ZADCADDITIONALDISCOUNT';
                            field2.value = String.valueOf(oli.Additional_Discount__c);
                            fields.add(field2);
                            
                            SalesOrderWrapper.CustomFieldValues field3 = new SalesOrderWrapper.CustomFieldValues();
                            field3.name = 'ZDC2DISCOUNT';
                            if(oli.MD_Discount_Term__c != null || oli.MD_Discount_Term__c != 0){
                                field3.value = String.valueOf(oli.MD_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                            }else{
                                field3.value = String.valueOf(oli.MU_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                            }
                            fields.add(field3);
                            
                            SalesOrderWrapper.CustomFieldValues field4 = new SalesOrderWrapper.CustomFieldValues();
                            field4.name = 'ZDMIDISTRIBUTORMARGIN';
                            if(oli.MD_Distributor_Margin__c != null && oli.MD_Distributor_Margin__c != 0){
                                field4.value = String.valueOf(oli.MD_Distributor_Margin__c); //MD Distributor Margin %  MU Distributor Margin % 
                            }else{
                                field4.value = String.valueOf(oli.MU_Distributor_Margin__c);  
                            } 
                            //field4.value = String.valueOf(zrlgPercentage);
                            fields.add(field4);
                            
                            SalesOrderWrapper.CustomFieldValues field5 = new SalesOrderWrapper.CustomFieldValues();
                            field5.name = 'ZMRPMRP';
                            field5.value = String.valueOf(oli.UnitPrice); ///Retailer Price
                            fields.add(field5);
                            
                            SalesOrderWrapper.CustomFieldValues field6 = new SalesOrderWrapper.CustomFieldValues();
                            field6.name = 'ZRLGRETAILERGST';
                            field6.value = String.valueOf(zrlgPercentage);
                            if(oli.MD_Retailer_GST__c != null){
                                fields.add(field6);
                            }
                            SalesOrderWrapper.CustomFieldValues field7 = new SalesOrderWrapper.CustomFieldValues();
                            field7.name = 'ZRMDRETAILERMARGIN';
                            field7.value = String.valueOf(oli.MD_Retailer_Margin__c);
                            if(oli.MD_Retailer_Margin__c != null){
                                fields.add(field7);
                            }
                            if(fields != null && !fields.isEmpty()){
                                line.customFieldValues = fields;
                            }
                            strBody += JSON.serialize(line);
                        }
                        else if(qty > 1 && qty != i){
                            SalesOrderWrapper.SaleOrderItems line = new SalesOrderWrapper.SaleOrderItems();
                            line.itemSku = oli.Product2.Material_Number__c;
                            line.shippingMethodCode = 'STD';
                            line.code = oli.Product2.Material_Number__c+'-'+i;//''+generateRandomString(3);
                            line.packetNumber = '1';
                            line.totalPrice = String.valueOf(oli.Final_Order_Value_after_GST__c / qty);
                            line.sellingPrice = String.valueOf(oli.Final_Order_Value_after_GST__c / qty);
                            line.prepaidAmount = '0';
                            line.discount = '0';
                            line.shippingCharges = '0';
                            
                            List<SalesOrderWrapper.CustomFieldValues>fields = new List<SalesOrderWrapper.CustomFieldValues>();
                            
                            SalesOrderWrapper.CustomFieldValues field1 = new SalesOrderWrapper.CustomFieldValues();
                            field1.name = 'ITEMSTATUS';
                            field1.value = oli.Item_Status__c;
                            //fields.add(field1);
                            
                            SalesOrderWrapper.CustomFieldValues field2 = new SalesOrderWrapper.CustomFieldValues();
                            field2.name = 'ZADCADDITIONALDISCOUNT';
                            field2.value = String.valueOf(oli.Additional_Discount__c);
                            fields.add(field2);
                            
                            SalesOrderWrapper.CustomFieldValues field3 = new SalesOrderWrapper.CustomFieldValues();
                            field3.name = 'ZDC2DISCOUNT';
                            if(oli.MD_Discount_Term__c != null || oli.MD_Discount_Term__c != 0){
                                field3.value = String.valueOf(oli.MD_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                            }else{
                                field3.value = String.valueOf(oli.MU_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                            }
                            fields.add(field3);
                            
                            SalesOrderWrapper.CustomFieldValues field4 = new SalesOrderWrapper.CustomFieldValues();
                            field4.name = 'ZDMIDISTRIBUTORMARGIN';
                            if(oli.MD_Distributor_Margin__c != null && oli.MD_Distributor_Margin__c != 0){
                                field4.value = String.valueOf(oli.MD_Distributor_Margin__c); //MD Distributor Margin %  MU Distributor Margin % 
                            }else{
                                field4.value = String.valueOf(oli.MU_Distributor_Margin__c);  
                            }
                            // field4.value = String.valueOf(zrlgPercentage);
                            fields.add(field4);
                            
                            SalesOrderWrapper.CustomFieldValues field5 = new SalesOrderWrapper.CustomFieldValues();
                            field5.name = 'ZMRPMRP';
                            field5.value = String.valueOf(oli.UnitPrice); ///Retailer Price
                            fields.add(field5);
                            
                            SalesOrderWrapper.CustomFieldValues field6 = new SalesOrderWrapper.CustomFieldValues();
                            field6.name = 'ZRLGRETAILERGST';
                            field6.value = String.valueOf(zrlgPercentage);
                            if(oli.MD_Retailer_GST__c != null){
                                fields.add(field6);
                            }
                            SalesOrderWrapper.CustomFieldValues field7 = new SalesOrderWrapper.CustomFieldValues();
                            field7.name = 'ZRMDRETAILERMARGIN';
                            field7.value = String.valueOf(oli.MD_Retailer_Margin__c);
                            if(oli.MD_Retailer_Margin__c != null){
                                fields.add(field7);
                            }
                            if(fields != null && !fields.isEmpty()){
                                line.customFieldValues = fields;
                            }   
                            strBody += JSON.serialize(line);
                        }
                        else if(qty == i && count < lstOlisize){
                            
                            SalesOrderWrapper.SaleOrderItems line = new SalesOrderWrapper.SaleOrderItems();
                            line.itemSku = oli.Product2.Material_Number__c;
                            line.shippingMethodCode = 'STD';
                            line.code = oli.Product2.Material_Number__c+'-'+i;//''+generateRandomString(3);
                            line.packetNumber = '1';
                            line.totalPrice = String.valueOf(oli.Final_Order_Value_after_GST__c / qty);
                            line.sellingPrice = String.valueOf(oli.Final_Order_Value_after_GST__c / qty);
                            line.prepaidAmount = '0';
                            line.discount = '0';
                            line.shippingCharges = '0';
                            
                            List<SalesOrderWrapper.CustomFieldValues>fields = new List<SalesOrderWrapper.CustomFieldValues>();
                            
                            SalesOrderWrapper.CustomFieldValues field1 = new SalesOrderWrapper.CustomFieldValues();
                            field1.name = 'ITEMSTATUS';
                            field1.value = oli.Item_Status__c;
                            //fields.add(field1);
                            
                            SalesOrderWrapper.CustomFieldValues field2 = new SalesOrderWrapper.CustomFieldValues();
                            field2.name = 'ZADCADDITIONALDISCOUNT';
                            field2.value = String.valueOf(oli.Additional_Discount__c);
                            fields.add(field2);
                            
                            SalesOrderWrapper.CustomFieldValues field3 = new SalesOrderWrapper.CustomFieldValues();
                            field3.name = 'ZDC2DISCOUNT';
                            if(oli.MD_Discount_Term__c != null || oli.MD_Discount_Term__c != 0){
                                field3.value = String.valueOf(oli.MD_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                            }else{
                                field3.value = String.valueOf(oli.MU_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                            }
                            fields.add(field3);
                            
                            SalesOrderWrapper.CustomFieldValues field4 = new SalesOrderWrapper.CustomFieldValues();
                            field4.name = 'ZDMIDISTRIBUTORMARGIN';
                            if(oli.MD_Distributor_Margin__c != null && oli.MD_Distributor_Margin__c != 0){
                                field4.value = String.valueOf(oli.MD_Distributor_Margin__c); //MD Distributor Margin %  MU Distributor Margin % 
                            }else{
                                field4.value = String.valueOf(oli.MU_Distributor_Margin__c);  
                            }
                            //field4.value = String.valueOf(zrlgPercentage);
                            fields.add(field4);
                            
                            SalesOrderWrapper.CustomFieldValues field5 = new SalesOrderWrapper.CustomFieldValues();
                            field5.name = 'ZMRPMRP';
                            field5.value = String.valueOf(oli.UnitPrice); ///Retailer Price
                            fields.add(field5);
                            
                            SalesOrderWrapper.CustomFieldValues field6 = new SalesOrderWrapper.CustomFieldValues();
                            field6.name = 'ZRLGRETAILERGST';
                            field6.value = String.valueOf(zrlgPercentage);
                            if(oli.MD_Retailer_GST__c != null){
                                fields.add(field6);
                            }
                            SalesOrderWrapper.CustomFieldValues field7 = new SalesOrderWrapper.CustomFieldValues();
                            field7.name = 'ZRMDRETAILERMARGIN';
                            field7.value = String.valueOf(oli.MD_Retailer_Margin__c);
                            if(oli.MD_Retailer_Margin__c != null){
                                fields.add(field7);
                            }
                            if(fields != null && !fields.isEmpty()){
                                line.customFieldValues = fields;
                            }      
                            strBody += JSON.serialize(line);
                            
                        } 
                        else if(qty == i && count == lstOlisize){
                            
                            
                            SalesOrderWrapper.SaleOrderItems line = new SalesOrderWrapper.SaleOrderItems();
                            line.itemSku = oli.Product2.Material_Number__c;
                            line.shippingMethodCode = 'STD';
                            line.code = oli.Product2.Material_Number__c+'-'+i;//''+generateRandomString(3);
                            line.packetNumber = '1';
                            line.totalPrice = String.valueOf(oli.Final_Order_Value_after_GST__c / qty);
                            line.sellingPrice = String.valueOf(oli.Final_Order_Value_after_GST__c / qty);
                            line.prepaidAmount = '0';
                            line.discount = '0';
                            line.shippingCharges = '0';
                            
                            List<SalesOrderWrapper.CustomFieldValues>fields = new List<SalesOrderWrapper.CustomFieldValues>();
                            
                            SalesOrderWrapper.CustomFieldValues field1 = new SalesOrderWrapper.CustomFieldValues();
                            field1.name = 'ITEMSTATUS';
                            field1.value = oli.Item_Status__c;
                            //fields.add(field1);
                            
                            SalesOrderWrapper.CustomFieldValues field2 = new SalesOrderWrapper.CustomFieldValues();
                            field2.name = 'ZADCADDITIONALDISCOUNT';
                            field2.value = String.valueOf(oli.Additional_Discount__c);
                            fields.add(field2);
                            
                            SalesOrderWrapper.CustomFieldValues field3 = new SalesOrderWrapper.CustomFieldValues();
                            field3.name = 'ZDC2DISCOUNT';
                            if(oli.MD_Discount_Term__c != null || oli.MD_Discount_Term__c != 0){
                                field3.value = String.valueOf(oli.MD_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                            }else{
                                field3.value = String.valueOf(oli.MU_Discount_Term__c); // Map MD Discount Term %   OR MU Discount Term %   
                            }
                            fields.add(field3);
                            
                            SalesOrderWrapper.CustomFieldValues field4 = new SalesOrderWrapper.CustomFieldValues();
                            field4.name = 'ZDMIDISTRIBUTORMARGIN';
                            if(oli.MD_Distributor_Margin__c != null && oli.MD_Distributor_Margin__c != 0){
                                field4.value = String.valueOf(oli.MD_Distributor_Margin__c); //MD Distributor Margin %  MU Distributor Margin % 
                            }else{
                                field4.value = String.valueOf(oli.MU_Distributor_Margin__c);  
                            }
                            //field4.value = String.valueOf(zrlgPercentage);
                            fields.add(field4);
                            
                            SalesOrderWrapper.CustomFieldValues field5 = new SalesOrderWrapper.CustomFieldValues();
                            field5.name = 'ZMRPMRP';
                            field5.value = String.valueOf(oli.UnitPrice); ///Retailer Price
                            fields.add(field5);
                            
                            SalesOrderWrapper.CustomFieldValues field6 = new SalesOrderWrapper.CustomFieldValues();
                            field6.name = 'ZRLGRETAILERGST';
                            field6.value = String.valueOf(oli.MD_Retailer_GST__c);
                            if(oli.MD_Retailer_GST__c != null){
                                fields.add(field6);
                            }
                            SalesOrderWrapper.CustomFieldValues field7 = new SalesOrderWrapper.CustomFieldValues();
                            field7.name = 'ZRMDRETAILERMARGIN';
                            field7.value = String.valueOf(oli.MD_Retailer_Margin__c);
                            if(oli.MD_Retailer_Margin__c != null){
                                fields.add(field7);
                            }
                            if(fields != null && !fields.isEmpty()){
                                line.customFieldValues = fields;
                            }
                            strBody += JSON.serialize(line);
                        } 
                    }
                    if(String.isNotBlank(strBody)){
                        bodyList.add(strBody);
                    }
                }
                System.debug('bodyList '+bodyList);
                attachFile.Body = Blob.valueOf(String.join(bodyList, ','));
             //   insert attachFile;
             body =json.serialize(bodyList); //String.join(bodyList, ',');
            }
        }
    }
    
    @future(callout = true)
    public static void sendSalesOrderToUniware(String JSONStr){
        if(String.isNotBlank(JSONStr)){
            Opportunity obj;
            
            Map<String,Object>dataMap = (Map<String,Object>) JSON.deserializeUntyped(JSONStr);
            if(dataMap != null){
                String oppId = '';
                if(dataMap.containsKey('oppRecord')){
                    sObject opprec = (Opportunity) JSON.deserialize(JSON.serialize(dataMap.get('oppRecord')), Opportunity.Class);
                    obj = (Opportunity) opprec;
                    
                    Map<Id,OpportunityLineItem> mapLineItems = new Map<Id,OpportunityLineItem>([select Id,MU_Distributor_Margin__c,MD_Discount_Term__c,MD_Distributor_Margin__c,Item_Status__c,Indo_Count_to_Kurl_On_Price__c,MD_Retailer_GST__c,MD_Retailer_Margin__c,ZDC2__c,Additional_Discount__c,OpportunityId,Final_Order_Value_after_GST__c,Total_Final_Order_Value_with_GST__c,Final_Order_Value_Ex_GST__c,Name,Quantity,Product2.Material_Number__c,UnitPrice from OpportunityLineItem where OpportunityId =:obj.Id]);
                    
                    List<Attachment>jsonAttach = new List<Attachment>();
                    for(Attachment attach : [Select id,name,Body from Attachment where parentId =:obj.Id]){
                        jsonAttach.add(attach);
                    }
                    
                    Integer attachListSize = jsonAttach.size();
                    
                    
                    
                    /**********
* SALES ORDER POST HERE
* ***********/
                    Set<ID>productIds = new Set<ID>();
                    
                    for(OpportunityLineItem oli:mapLineItems.values()){
                        if(obj.Id == oli.OpportunityId){
                            productIds.add(oli.Product2Id);
                            System.debug('Oli '+oli);
                        } 
                    } 
                    
                    Map<Id,Product2>productMap = new Map<Id,Product2>();
                    
                    for(Product2 p : [Select Id,Brand__c,Collection__c,Product__c,HSN_Code__c,(SELECT Id, UnitPrice FROM PricebookEntries WHERE IsActive = True ORDER BY UseStandardPrice DESC, Id DESC Limit 1) from Product2 where Id IN:productIds and IsActive = True AND Name != null]){
                        productMap.put(p.Id,p);
                    }
                    
                    List<SalesOrderWrapper.SaleOrderItems> saleOrderItems;// = constructRequestBodyforOli(lstOli,productMap,oppMap);
                    System.debug('->>>>> '+saleOrderItems);                
                    Account acc = [Select Id,Name,Customer_Type__c,Distrbution_Channel__c,Phone,Service_Tax_Number__c,Customer_Code_SOP__c,CST_Number__c,BillingAddress,ShippingAddress,Customer_Code__c from Account where Id=:obj.AccountId];
                    Address addr = acc.BillingAddress;
                    System.debug('Address obj '+addr);
                    String acctStreet = addr.Street != null ? addr.Street : '';
                    acctStreet.replaceAll('\n',' ');
                    String acctCity = addr.City != null ? addr.City : '';
                    String acctState = addr.State != null ? addr.State : '';
                    String acctCountry = addr.Country != null ? addr.Country : '';
                    String acctZip = addr.PostalCode != null ? addr.PostalCode : ''; 
                    
                    Address shippingAddress = acc.ShippingAddress;
                    String shStreet = shippingAddress.Street;
                    shStreet.replaceAll('\n',' ');
                    String shCity = shippingAddress.City != null ? shippingAddress.City : '';
                    String shState = shippingAddress.State != null ? shippingAddress.State : '';
                    String shCountry = shippingAddress.Country != null ? shippingAddress.Country : '';
                    String shZip = shippingAddress.PostalCode != null ? shippingAddress.PostalCode : ''; 
                    String SHRef = acc.Service_Tax_Number__c != null ? acc.Service_Tax_Number__c : '60002';
                    String SOPref = acc.Customer_Code_SOP__c != null ? acc.Customer_Code_SOP__c : '60003';
                    
                    SalesOrderWrapper reqObject = new SalesOrderWrapper();
                    
                    SalesOrderWrapper.SaleOrder sOrder = new SalesOrderWrapper.SaleOrder();
                    //create order here
                    //sOrder.thirdPartyShipping = false;
                    
                    if(acc.Customer_Type__c != null){
                        sOrder.channel = acc.Customer_Type__c+'_'+acc.Distrbution_Channel__c;
                    }else{
                        sOrder.channel = 'CUSTOM';
                    }
                    
                    sOrder.cashOnDelivery = false;
                    sOrder.customerName = acc.Customer_Code_SOP__c+'_'+acc.Name;
                    sOrder.customerCode = acc.Customer_Code__c;
                    reqObject.saleOrder = sOrder;
                    if(saleOrderItems != null && !saleOrderItems.isEMpty()){
                        sOrder.saleOrderItems = saleOrderItems;
                    }
                    List<SalesOrderWrapper.Addresses>addressList = new List<SalesOrderWrapper.Addresses>();               
                    //billing address
                    SalesOrderWrapper.Addresses billingAddrObj = new SalesOrderWrapper.Addresses();
                    billingAddrObj.id = SOPref;//'60002';
                    billingAddrObj.name = acc.Name;
                    if(String.isNotBlank(shStreet)){
                        billingAddrObj.addressLine1 = shStreet;
                    }
                    if(String.isNotBlank(shCity)){
                        billingAddrObj.city = shCity;
                    }
                    if(String.isNotBlank(shState)){
                        billingAddrObj.state = shState;
                    }
                    if(String.isNotBlank(shCountry)){
                        billingAddrObj.country = shCountry;
                    }
                    if(shZip != null && String.isNotBlank(shZip)){
                        billingAddrObj.pincode = shZip;
                    }
                    if(acc.Phone != null && String.isNotBlank(acc.Phone)){
                        billingAddrObj.phone = acc.Phone;
                    }
                    addressList.add(billingAddrObj);
                    
                    //shipping address
                    SalesOrderWrapper.Addresses shippingAddrObj = new SalesOrderWrapper.Addresses();
                    shippingAddrObj.id = SHref;//'60002';
                    shippingAddrObj.name = acc.Name;
                    if(String.isNotBlank(acctStreet)){
                        shippingAddrObj.addressLine1 = acctStreet;
                    }
                    if(String.isNotBlank(acctCity)){
                        shippingAddrObj.city = acctCity;
                    }
                    if(String.isNotBlank(acctState)){
                        shippingAddrObj.state = acctState;
                    }
                    if(String.isNotBlank(acctCountry)){
                        shippingAddrObj.country = acctCountry;
                    }
                    if(acctZip != null && String.isNotBlank(acctZip)){
                        shippingAddrObj.pincode = acctZip;
                    }
                    if(acc.Phone != null && String.isNotBlank(acc.Phone)){
                        shippingAddrObj.phone = acc.Phone;
                    }
                    addressList.add(shippingAddrObj);
                    
                    sOrder.addresses = addressList;
                    
                    //set address reference here
                    SalesOrderWrapper.BillingAddress billingAddr = new SalesOrderWrapper.BillingAddress();
                    billingAddr.referenceId = SOPref;//'60002';
                    sOrder.billingAddress = billingAddr;
                    SalesOrderWrapper.BillingAddress shippingAddr = new SalesOrderWrapper.BillingAddress();
                    shippingAddr.referenceId = SHref;//'60002';
                    sOrder.shippingAddress = shippingAddr;
                    
                    List<SalesOrderWrapper.CustomFieldValues>customFldValues = new List<SalesOrderWrapper.CustomFieldValues>();
                    SalesOrderWrapper.CustomFieldValues field1 = new SalesOrderWrapper.CustomFieldValues();
                    field1.name ='SHIPTOPARTY';
                    field1.value = SHref;
                    customFldValues.add(field1);
                    
                    SalesOrderWrapper.CustomFieldValues field2 = new SalesOrderWrapper.CustomFieldValues();
                    field2.name ='SOLDTOPARTY';
                    field2.value = SOPref;
                    customFldValues.add(field2);
                    
                    SalesOrderWrapper.CustomFieldValues field4 = new SalesOrderWrapper.CustomFieldValues();
                    field4.name ='ORDERTYPE';
                    field4.value = obj.Order_Type__c;
                    if(obj.Order_Type__c != null){
                        customFldValues.add(field4);
                    }
                    
                    SalesOrderWrapper.CustomFieldValues field5 = new SalesOrderWrapper.CustomFieldValues();
                    field5.name ='SFORDERSTATUS';
                    field5.value = obj.StageName;
                    customFldValues.add(field5);
                    
                    if(obj.Uniware_Internal_SO_No__c == null){
                        System.debug('uid null');
                        sOrder.code = obj.Sales_Order_No__c;
                        sOrder.displayOrderCode = obj.Sales_Order_No__c;
                        SalesOrderWrapper.CustomFieldValues field3 = new SalesOrderWrapper.CustomFieldValues();
                        field3.name ='HEADERSTATUS';
                        field3.value = obj.Header_Status__c;
                        if(obj.Header_Status__c != null){
                            customFldValues.add(field3);
                        }
                        
                    }
                    else if(!obj.Uniware_Internal_SO_No__c.containsAny('_') && obj.Uniware_Internal_SO_No__c != null){
                        System.debug('uid not null and not contains _');
                        String uniwareCodeToUpdate = obj.Sales_Order_No__c;
                        uniwareCodeToUpdate = uniwareCodeToUpdate+'_1'; 
                        
                        sOrder.code = uniwareCodeToUpdate;
                        sOrder.displayOrderCode = uniwareCodeToUpdate;
                        
                    }
                    else{
                        System.debug('else ');
                        String uniwareCodeToUpdate = obj.Uniware_Internal_SO_No__c;
                        System.debug(uniwareCodeToUpdate);
                        Integer version = Integer.valueOf(uniwareCodeToUpdate.substringAfterLast('_'));
                        System.debug(version);
                        String beforeCode = uniwareCodeToUpdate.substringBeforeLast('_');
                        System.debug(beforeCode);
                        version = version+1;
                        uniwareCodeToUpdate = beforeCode+'_'+version;                   
                        
                        sOrder.code = uniwareCodeToUpdate;
                        sOrder.displayOrderCode = uniwareCodeToUpdate;
                        
                    }   
                    
                    sOrder.customFieldValues = customFldValues;
                    
                }
            }
        }
        
    }
}