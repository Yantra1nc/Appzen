public class NewAvoidRecursion {
 public static boolean skipTrigger = false;
    public static void updateRecord(Product2 p){
        skipTrigger = true;
        p.From_NetSuite__c = false;
        update p;
            
        
    }
}