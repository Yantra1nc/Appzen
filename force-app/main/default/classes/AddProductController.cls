public class AddProductController {
    
   // public List<wrapProduct> wrapProductList {get; set;}
    public List<Product2> selectedProducts{get;set;}
    //   public Integer ProductSelectedCount {get; set;}
    public string productname{get; set;}
    public string brand{get; set;}
    public string collection{get; set;}
 //   public string design{get; set;}
    public string size{get; set;}
    public string finalSearchValue1{get; set;}
    public string finalSearchValue2{get; set;}
    public string finalSearchValue3{get; set;}
    public string finalSearchValue4{get; set;}
    public string finalSearchValue5{get; set;}
    Public string salesOrderId {get; set;}
    public List<SelectOption> Option{get;set;}
    
 /*  public List<OpportunityLineItem> olList=new List<OpportunityLineItem>();
    
    public AddProductController(){
        salesOrderId = ApexPages.currentPage().getParameters().get('Id');
        if(wrapProductList == null) {
            wrapProductList = new List<wrapProduct>();
            for(Product2 p: [select Id, Name, Description, Brand__c, Collection__c, Design_No__c, Size__c, HSN__c from Product2]) {
                wrapProductList.add(new wrapProduct(p));
            }
        }
    }
    
    public void search(){
        finalSearchValue1 = '%' + productname + '%';
        finalSearchValue2 = '%' + brand + '%';
        finalSearchValue3 = '%' + collection + '%';
        finalSearchValue4 = '%' + design + '%';
        finalSearchValue5 = '%' + size + '%';
        wrapProductList = new List<wrapProduct>();
        for(Product2 prods :[select id, Name,Description, Brand__c, Collection__c, Design_No__c,Size__c, HSN__c from Product2 where Name 
                             like:finalSearchValue1 and Brand__c like:finalSearchValue2 and Collection__c like:finalSearchValue3
                             and Design_No__c like:finalSearchValue4 and Size__c like:finalSearchValue5 LIMIT 20]){
                                 wrapProductList.add(new wrapProduct(prods));                     
                             }
    }
    
    public PageReference cancel(){
        PageReference c=new PageReference('/'+salesOrderId);
        return c; 
        
    }
    
    
    
   public List<SelectOption> getOptions()
{
List<SelectOption> Option = new List<SelectOption>();
Option.add(new selectOption('none','None'));
Option.add(new selectOption('b','Brand'));
Option.add(new selectOption('c','Collection'));
Option.add(new selectOption('p','Product Name')); 
Option.add(new selectOption('s','Size')); 
Option.add(new selectOption('d','Design Number')); 
return Option;
}  
    
    
    
    public PageReference processSelected() {
        selectedProducts = new List<Product2>();
        
        for(wrapProduct wrapProductObj : wrapProductList) {
            if(wrapProductObj.selected == true) {
                selectedProducts.add(wrapProductObj.prod);
            }
        }
        PageReference s = Page.SelectedProductsPage;
        s.setRedirect(false);
        return s;
        
    }
    
    public PageReference insertproduct(){
        for(Product2 pr : selectedProducts){
         OpportunityLineItem prd = new OpportunityLineItem();
            prd.OpportunityId = ApexPages.currentPage().getParameters().get('Id');
            prd.Product2Id = pr.Id;
            prd.Description = pr.Description;
            prd.Quantity = 10;
            prd.TotalPrice = 100;
            olList.add(prd);
        }
        if(olList.size() > 0){
            insert olList;
        }
         pageReference pg = new pageReference('/'+salesOrderId);
        return pg;
    }
    
    public Pagereference clear(){
        
        PageReference newpage = new PageReference(System.currentPageReference().getURL());
        newpage.setRedirect(true);
        return newpage;
    }
    
    public class wrapProduct {
        public Product2 prod {get; set;}
        public Boolean selected {get; set;}
        
        public wrapProduct(Product2 p) {
            prod = p;
            selected = false;
        }
    }*/
}