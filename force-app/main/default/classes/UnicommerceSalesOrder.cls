/** 
  Class Name : UnicommerceSalesOrder 
  Description : Class which is responsible for processing of salesorder to and from unicommerce to Salesforce 
  Created Date : 27/10/2021
  Last Modified Date : 29/10/2021
  Author: Rajiv

**/

public with sharing class UnicommerceSalesOrder {
    public List<Opportunity> lstToUpdateUnicommerce;
    public static String token;
    
    public UnicommerceSalesOrder(List<Opportunity> lstToUpdateUnicommerce){
        this.lstToUpdateUnicommerce = lstToUpdateUnicommerce;
        token = UnicommerceAuthentication.getAuthenticationToken();
        processSalesOrder(token,lstToUpdateUnicommerce);
    }
    
    public static void processSalesOrder(String token,List<Opportunity> lstToUpdateUnicommerce){
        try{
            UnicommerceSalesOrderUtility.createSalesOrders(lstToUpdateUnicommerce,token);
        }catch(Exception ex){
            System.debug('Exception '+ex.getMessage());
        }
    }
}