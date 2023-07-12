import { LightningElement, wire,api,track } from "lwc";

// messageChannels
import {subscribe,unsubscribe,MessageContext} from "lightning/messageService";
import FILTER_CHANNEL from "@salesforce/messageChannel/productFilterChannel__c";
import getProducts from "@salesforce/apex/getProductsInAddProducts.getProducts";
import saveLineItems from "@salesforce/apex/DiscountCalculation.saveLineItems";
//import basicOrderValue from "@salesforce/apex/DiscountCalculation.getBasicOrderValue";
//import getDiscount from "@salesforce/apex/DiscountCalculation.getDiscount";
import getGST from "@salesforce/apex/DiscountCalculation.getGST";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getProductDetails from "@salesforce/apex/getProductsInAddProducts.getProductDetails";
import getProductMrp from "@salesforce/apex/getProductsInAddProducts.getProductMrp";
import { refreshApex } from '@salesforce/apex';
import StartDate from "@salesforce/schema/Contract.StartDate";

const COLS=[
    {label:'Product Image',fieldName:'Product_Image_Link__c', type:'image', 'initialWidth': 150},
    {label:'Brand',fieldName:'Brand__c', type:'text', 'initialWidth': 100},    
    {label:'Collection',fieldName:'Collection__c', type:'text','initialWidth': 120}, 
    {label:'Design No.',fieldName:'Design_No__c', type:'text','initialWidth': 120},
    {label:'Product Name',fieldName:'Name', type:'picklist','initialWidth': 140}, 
    {label:'Size',fieldName:'Size__c', type:'picklist','initialWidth': 100},
    {label:'MOP',fieldName:'MOP__c', type:'text','initialWidth': 100},
    {label:'Retailer Price',fieldName:'Kurl_On_to_Retailer_Price__c', type:'text','initialWidth': 150},
    //{label:'Color',fieldName:'Color__c', type:'picklist','initialWidth': 100},
    //{label:'Design Type',fieldName:'Design_Type__c', type:'picklist','initialWidth': 120},
    //{label:'Customer Basic Price',fieldName:'Additional_Discount__c', type:'double'},    
    {label:'Availability',fieldName:'Availability__c', type:'text','initialWidth': 110},
    {label:'Quantity',fieldName:'Quantity', type:'integer',editable:'true','initialWidth': 100,typeAttributes: { required: true ,autocomplete:'off'}},
    {label:'Basic Order Value',fieldName:'Final_Price__c', type:'double','initialWidth': 150}
    ]; 

export default class ProductSearchAP extends NavigationMixin(LightningElement) {

   // @api recordId;
    cols=COLS; 
    searchKey = "";
	subscription = null;
    MRP_Rollup = 0;
    oppLineItemRec = [];
    error ;
    arrayQuantity = [];
    quantity = 0;
    quant = 0;
    productId=[];
    totalordervalue = 0;
    gst = 0;
    gstPriceTotal = 0; 
    gstWrapper = 0;   
    products = [];
    preSelectedRows = [];
    discount = [];
    summaryMrp = 0;
    summaryQuantity = 0;
    total = 0;
    saveOppLineItems = [];
	gstSave = 0;
    bool= false;
    selectedRows = [];
    currentSelectedRows= [];
    orderDate;
    orderNo;
    expiryDate;
    currentMrp;
    currentQuantity;
    currentTotal;
    currentGst;
    currentExpiryDate;
    currentOrderDate;
    currentOrderNo;
    length=0;
    mrp;
    productImage;
    brand;
    collection;
    designNo;
    size;
    prodName;
    availability;
    mop;
    quantityEnd;
    finalPrice;  
    gstMap = new Map();
    selectedRowsMap = new Map();
    bovMap = new Map();
    recordId = "006O000000G2nCqIAJ";
    filtersData = {
		minPrice: 0,
		maxPrice: 10000,
	};
    draftValues = [];

    @track page = 1; 
    @track items = []; 
    @track data = []; 
    @track columns; 
    @track startingRecord = 1;
    @track endingRecord = 0; 
    @track pageSize = 5; 
    @track totalRecordCount = 0;
    @track totalPage = 0;

    isFirstPage = false;
    isLastPage = false;

    @track prods;
    @track prodLength= 0;
    @track recordsToDisplay = []; 
    @track rowNumberOffset; 


    connectedCallback() {
		this.subscribeMC();  
        //console.og('Db result:', this.wiredProducts);
        console.log(this.recordId); 
        console.log("Connected callback");
        console.log("Wired data:"+this.data);     
	}
   

	@wire(getProducts, {filtersData: "$filtersData",recordId: '$recordId'})
	wiredProducts({error,data}){
       /*  if(data){
            this.products = data;
            this.items = data;
            this.totalRecordCount = data.length; 
            this.totalPage = Math.ceil(this.totalRecordCount / this.pageSize); 
            this.data = this.items.slice(0,this.pageSize);
            this.endingRecord = this.pageSize;
            this.columns = columns;
            this.products = this.data;
        } */
        if(data){
            //this.products = data;            
            this.page  = 1;                  
            this.items = data;
            this.totalRecountCount = data.length; 
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);            
            this.endingRecord = this.pageSize;
            let recs = [];
            for(let i=0; i<data.length; i++){
                let prod = {};
                prod.rowNumber = ''+(i+1);
                prod.prodLink = '/'+data[i].Id;
                prod = Object.assign(prod, data[i]);
                recs.push(prod);
            }
            this.prods = recs;
            this.prodLength = this.prods.length;
            for (let [key, value] of this.bovMap) {               
                //this.oppLineItemsArr = [...this.oppLineItemsArr,value]; 
                //this.selectedRows = [...this.selectedRows,value.Id];
                this.oppLineItemRec.push({
                    Id:value.Id,
                    Product_Image_Link__c:value.Product_Image_Link__c,
                    Brand__c:value.Brand__c,
                    Collection__c:value.Collection__c,
                    Name:value.Name,
                    Size__c:value.Size__c,
                    Design_No__c:value.Design_No__c,
                    Kurl_On_to_Retailer_Price__c:value.Kurl_On_to_Retailer_Price__c,
                    Color__c:value.Color__c,
                    //Design_Type__c:this.design,
                    Quantity: value.Quantity,
                    MOP__c:value.MOP__c,
                    //Discount:this.discount[j]+'%',            
                    //DiscMRP:discMrp,
                    //Additional_Discount__c:draftValues[j].Additional_Discount__c,
                    Availability__c:value.Availability__c,
                    Final_Price__c:value.Final_Price__c 
                });
                this.selectedRowsMap.set(key,key);
                console.log('Length'+this.selectedRowsMap.size);
            } 
            //this.oppLineItemRec = [...this.oppLineItemRec,retrieveData];
            this.items = this.items.map(obj => this.oppLineItemRec.find(o=>o.Id === obj.Id) || obj);
            this.data = this.items.slice(0,this.pageSize);        
            this.products = this.products.map(obj => this.oppLineItemRec.find(o=>o.Id === obj.Id) || obj);
            
            this.products =  this.data;
            //this.updateValues(); 
             for(let [key,value] of this.selectedRowsMap){
                this.selectedRows = [...this.selectedRows,value];
                console.log('Selected Ids'+value);
             }  
                  
        }else{
            this.error = false;
        }
    };

   
	@wire(MessageContext)
	messageContext; 
    
    getProductDetails(filtersData){
        getProducts({
            filtersData: filtersData
        }).then((result) => {
            this.products = result.data;
        }).catch((err) => {
            
        });
    }

    handlePaginatorChange(event){
        this.recordsToDisplay = event.detail;
        this.rowNumberOffset = this.recordsToDisplay[0].rowNumber-1;
    }
    //clicking on previous button this method will be called
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    //clicking on next button this method will be called
    nextHandler() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }             
    }

     //this method displays records page by page
     displayRecordPerPage(page){

        /* this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecordCount) 
                            ? this.totalRecordCount : this.endingRecord; 

        this.products = this.items.slice(this.startingRecord, this.endingRecord);

        this.startingRecord = this.startingRecord + 1;
        this.upDatePageButtons(); */
        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);        
        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord;        
        
        for(let [key,value] of this.bovMap){
            this.oppLineItemRec.push({
                Id:value.Id,
                Product_Image_Link__c:value.Product_Image_Link__c,
                Brand__c:value.Brand__c,
                Collection__c:value.Collection__c,
                Name:value.Name,
                Size__c:value.Size__c,
                Design_No__c:value.Design_No__c,
                Kurl_On_to_Retailer_Price__c:value.Kurl_On_to_Retailer_Price__c,
                Color__c:value.Color__c,
                //Design_Type__c:this.design,
                Quantity: value.Quantity,
                MOP__c:value.MOP__c,
                //Discount:this.discount[j]+'%',            
                //DiscMRP:discMrp,
                //Additional_Discount__c:draftValues[j].Additional_Discount__c,
                Availability__c:value.Availability__c,
                Final_Price__c:value.Final_Price__c
            });
        } 
        this.items = this.items.map(obj => this.oppLineItemRec.find(o=>o.Id === obj.Id) || obj);                
        this.data = this.items.slice(this.startingRecord, this.endingRecord);
        this.products = this.data;
        this.selectedRows = [...this.selectedRows];
        this.startingRecord = this.startingRecord + 1;
    }    

    upDatePageButtons(){
        console.log("Page Number: "+ this.page+"Total page count: "+ this.totalPage);
        if(this.page===1){
            this.isFirstPage = true;
        }else{
            this.isFirstPage = false;
        }
        if(this.page >= this.totalPage){
            this.isLastPage = true;
        }else{
            this.isLastPage = false;
        }
    }
    
    getSelectedName(event){
      
        //console.log('Current'+this.currentSelectedRows);
        //console.log(this.selectedRows);        
        this.oppLineItemRec = [];  
        this.saveOppLineItems = [];     
        this.MRP_Rollup = 0;
        let quantity = 0;
        this.gstPriceTotal = 0;
        let gstPrice = 0;       
        this.total = 0;
        

        getProductDetails({oppId:this.recordId}).then((result) => {
            console.log(result.Sales_Order_No__c);
            this.orderNo = result.Sales_Order_No__c;
            this.currentOrderNo = this.orderNo;
            this.orderDate = result.Order_Date__c;
            this.currentOrderDate = this.orderDate;
            this.expiryDate = result.CloseDate;
            this.currentExpiryDate = this.expiryDate;
            
        }).catch((err) => {
            console.log(err);
        });

        let getSelectedRows = this.template.querySelector("c-salesforce-codex-data-table").getSelectedRows();       
        this.length  = getSelectedRows.length;
        console.log('Inside cell click'+getSelectedRows.length);
        let selectedRows = event.detail.selectedRows;
        console.log('SelectedRowsss'+selectedRows.length);
        console.log('Checked'+event.target);
        
        this.productId = []; 
        
        
        //await this.getDiscount(getSelectedRows);
        /*getSelectedRows.forEach(element => {                  
            
            getDiscount({ lstProdId: element.Id,oppId:this.recordId}).then((result) => {
                this.discount = [...this.discount,result]; 
                console.log('DiscountInside'+this.discount);                         
            }).catch((err) => {
                console.log(err);
            });
            console.log('DiscountOutside'+this.discount);
        });*/
        
        //Get GST         
        
        let draftValues = this.template.querySelector('c-salesforce-codex-data-table').draftValues;
        console.log("Draft values: " + JSON.stringify(draftValues));
        console.log('OutsideDraft'+draftValues.length);
        console.log("Selected rows: "+JSON.stringify(getSelectedRows));
        let newSelectArr = draftValues.filter(obj => getSelectedRows.find(o=>o.Id === obj.Id));
        console.log("Array after reselection: "+JSON.stringify(newSelectArr));
        this.quantityEnd = 0;
        console.log("Test");
        console.log("Quantity after deselection: " + newSelectArr[0].Quantity);
        for(let i = 0; i < newSelectArr.length; i++){
        this.quantityEnd = this.quantityEnd + parseInt(newSelectArr[i].Quantity);
        } 
        console.log("Test 1");

        let idArr1 = [];
        if(newSelectArr.length >0){
            console.log("Inside if");
        for(let i = 0; i < newSelectArr.length; i++){
            idArr1[i] = newSelectArr[i].Id;
        }}
        let idArr2 = [];
        for(let i = 0; i < draftValues.length; i++){
            idArr2[i] = draftValues[i].Id;
        }
        const unCommonArray = (first, second) => {
            if(first.length >0){
                console.log("Inside function call");
            const res = [];
            for(let i = 0; i < first.length; i++){
               if(second.indexOf(first[i]) === -1){
                  res.push(first[i]);
               }
            };
            for(let j = 0; j < second.length; j++){
               if(first.indexOf(second[j]) === -1){
                  res.push(second[j]);
               };
            };
            return res;
         } };
        console.log(unCommonArray(idArr1, idArr2));
        let deSelectedRowsIds = []; 
        deSelectedRowsIds = unCommonArray(idArr1, idArr2);
        if(deSelectedRowsIds.length>0){
        for(let k = 0; k < deSelectedRowsIds.length; k++ ){
        console.log("Deselected ids: "+deSelectedRowsIds[k]);
        }   
       
        console.log(this.products.length);
        for(let j = 0; j <this.products.length; j++ ){
            for(let k = 0; k < deSelectedRowsIds.length; k++ ){
                if(this.products[j].Id == deSelectedRowsIds[k]){
                    this.oppLineItemRec.push({
                        Id:this.products[j].Id,
                        Product_Image_Link__c:this.products[j].Product_Image_Link__c,
                        Brand__c:this.products[j].Brand__c,
                        Collection__c:this.products[j].Collection__c,
                        Name:this.products[j].Name,
                        Size__c:this.products[j].Size__c,
                        Design_Number__c:this.products[j].Design_Number__c,
                        Kurl_On_to_Retailer_Price__c:this.products[j].Kurl_On_to_Retailer_Price__c,
                        Color__c:this.products[j].Color__c,
                        Design_Type__c:this.products[j].Design_Type__c,
                        Quantity:"",
                        MOP__c:this.products[j].MOP__c,
                        Availability__c:this.products[j].Availability__c,
                        Final_Price__c:""
                    });
                    if(draftValues.length < 1 || draftValues.length == 1){
                        this.draftValues = [];
                    }else{
                        var index = draftValues.findIndex(p => p.Id == this.products[j].Id);                       
                        draftValues.splice(index,1); 
                        this.draftValues = draftValues;    
                    }
                }
            }
          
        } 
        this.products = this.products.map(obj => this.oppLineItemRec.find(o=>o.Id === obj.Id) || obj); 
    } 
    console.log("Draft values.." + JSON.stringify(draftValues));
    console.log("Deselected Ids.." + deSelectedRowsIds);
    /*  for(let i = 0; i < draftValues.length; i++){
        for(let j=0;j <deSelectedRowsIds.length; j++){
            if(draftValues[i].Id == deSelectedRowsIds[j]){
                console.log("Check deselection");
                draftValues.splice(draftValues.findIndex(v => v.Id === deSelectedRowsIds[j]), 1);
                draftValues.splice(i);
                console.log(draftValues[i]);
                break;
            }
        }
    }  */
   
       
                console.log("Check deselection");
                console.log(draftValues);
                
                
               /* console.log(draftValues.length);
               for(let i = 0; i< draftValues.length; i ++){
                   console.log(draftValues[i].Id);
                   for(let j=0;j <deSelectedRowsIds.length; j++){
               if(draftValues[i].Id === deSelectedRowsIds[j]){
                   console.log("__Draft"+JSON.stringify(draftValues));
                var index = draftValues.findIndex(p => p.Id == draftValues[i].Id);   
                //draftValues[i].Quantity = "";
                   //break;
               draftValues.splice(index, 1);
                console.log("__Draft after"+JSON.stringify(draftValues));
                this.draftValues = draftValues; 
               }
            }
        }
            */
     
        var index = draftValues.findIndex(function(o){
            return o.id === 'myid';
        })
        if (index !== -1) myArr.splice(index, 1);
        
        let afterSelectedRows = this.template.querySelector('c-salesforce-codex-data-table').getSelectedRows();        
        let flag = false;
        
        for (let j = 0; j < afterSelectedRows.length; j++) {                         
            let gst = 0;
            let gstFinal = 0;
            let gstPriceSum = 0;
            this.gstPriceTotal = 0;
            let finalTotal = 0;
            this.total = 0;
           
           
            let mrp =  afterSelectedRows[j].Kurl_On_to_Retailer_Price__c;
            //let disMrp = Number(this.discount[j]);           
            //let discMrp = mrp-(Number(mrp)*(disMrp))/100; 
            
            quantity = quantity + Number(draftValues[j].Quantity);
            this.quantity = quantity;
            this.currentQuantity = this.quantity;
            if(mrp < 1000){
                flag = true;
            }
            getGST({ lstProdId: afterSelectedRows[j].Id,oppId:this.recordId,flag:flag}).then((result) => {
                console.log('GST'+result);
                console.log('OppIds'+this.recordId);
                console.log('ProdIds'+afterSelectedRows[j].Id);
                gst = result;  
                gstPrice = gstPrice + Number(draftValues[j].Quantity)*mrp*(gst/100);
                console.log('GSTPrice'+gstPrice);
                gstFinal = gstPrice; 
                gstPriceSum = gstPriceSum+gstPrice; 
                console.log('Gst Sum'+gstPriceSum);                
                //console.log(gst);
                this.gstPriceTotal = gstPriceSum;
                this.currentGst = this.gstPriceTotal;               
                finalTotal = (mrp * Number(draftValues[j].Quantity)) + gstPrice;
                this.total = this.MRP_Rollup + this.gstPriceTotal; 
                this.currentTotal = this.total;
                //this.total = this.total+finalTotal;
                //console.log('tp'+this.total);                
            }).catch((err) => {
                console.log(err);
            });
            
            
            let finalPrice = (Number(draftValues[j].Quantity) * Number(afterSelectedRows[j].Kurl_On_to_Retailer_Price__c)) +gstFinal;  
            console.log('Final'+finalPrice);  
            console.log('Final after formatting: '+finalPrice.toFixed(2));            
            this.oppLineItemRec.push({
                Id:afterSelectedRows[j].Id,
                Product_Image_Link__c:afterSelectedRows[j].Product_Image_Link__c,
                Brand__c:afterSelectedRows[j].Brand__c,
                Collection__c:afterSelectedRows[j].Collection__c,
                Name:afterSelectedRows[j].Name,
                Size__c:afterSelectedRows[j].Size__c,
                Design_Number__c:afterSelectedRows[j].Design_Number__c,
                Kurl_On_to_Retailer_Price__c:afterSelectedRows[j].Kurl_On_to_Retailer_Price__c,
                Color__c:afterSelectedRows[j].Color__c,
                Design_Type__c:afterSelectedRows[j].Design_Type__c,
                Quantity:draftValues[j].Quantity,
                MOP__c:afterSelectedRows[j].MOP__c,
                //Discount:this.discount[j]+'%',            
                //DiscMRP:discMrp,
                //Additional_Discount__c:draftValues[j].Additional_Discount__c,
                Availability__c:afterSelectedRows[j].Availability__c,
                Final_Price__c:finalPrice 
            });
            this.products = this.products.map(obj => this.oppLineItemRec.find(o=>o.Id === obj.Id) || obj);
            this.saveOppLineItems.push({
                productId:afterSelectedRows[j].Id,
                oppId:this.recordId,                
                Kurl_On_to_Retailer_Price__c:afterSelectedRows[j].Kurl_On_to_Retailer_Price__c,
                Quantity:draftValues[j].Quantity,
                Additional_Discount__c:0,
                Additional_Discount_Price__c:afterSelectedRows[j].Kurl_On_to_Retailer_Price__c,
                GST__c:this.gstWrapper,
                Final_Price__c:finalPrice 
            });
            //console.log('FinalList'+this.saveOppLineItems[0].Quantity);            
            
            //this.summaryMrp = this.summaryMrp+(draftValues[j].Quantity * discMrp);
            //this.summaryQuantity = this.summaryQuantity + draftValues[j].Quantity;
            this.MRP_Rollup = this.MRP_Rollup + finalPrice;
            this.currentMrp = this.MRP_Rollup; 
            
            console.log('GSTPRICETOT'+this.gstPriceTotal);         
            //this.gstPriceTotal = 0; 
            
        }
        
        //this.Quantity = this.summaryQuantity;
        //this.productId = [];
        //this.discount = [];
        this.afterSelectedRows = [];
        
    }


    handleChange(event){  
      
        console.log('Draft'+event.detail.draftValues[0].Quantity); 
        console.log(typeof(event.detail.draftValues[0].Quantity));      
        this.selectedRows = [...this.selectedRows,event.detail.draftValues[0].Id];
        console.log('SelectedRowsDraft'+this.selectedRows);
        this.oppLineItemRec = [];  
        this.saveOppLineItems = [];
        let quantity = 0;
        let gstPrice = 0; 
        let qtyInt = 0;        
        qtyInt =  (event.detail.draftValues[0].Quantity) % 1;
        console.log((event.detail.draftValues[0].Quantity).slice(0,1));
        
       if((qtyInt != 0) || ((event.detail.draftValues[0].Quantity).slice(0,1) == "-") || ((event.detail.draftValues[0].Quantity).slice(-1) == ".")){
           console.log('Not an integer');
           const evt = new ShowToastEvent({
            message: 'The Quantity should always be a number',
            variant: 'error',            
        });
        this.dispatchEvent( evt );
        
       }else{

        getProductDetails({oppId:this.recordId}).then((result) => {
            console.log(result.Sales_Order_No__c);
            this.orderNo = result.Sales_Order_No__c;
            this.currentOrderNo = this.orderNo;
            this.orderDate = result.Order_Date__c;
            this.currentOrderDate = this.orderDate;
            this.expiryDate = result.CloseDate;
            this.currentExpiryDate = this.expiryDate;
            
        }).catch((err) => {
            console.log(err);
        });
        let dt = this.template.querySelector("c-salesforce-codex-data-table");
        dt.setAttribute("autocomplete","off");
        let getSelectedRows = this.template.querySelector("c-salesforce-codex-data-table").getSelectedRows();       
        this.productId = []; 
        let draftValues = this.template.querySelector('c-salesforce-codex-data-table').draftValues;
        console.log('OutsideDraft'+draftValues[0]);
        
        let afterSelectedRows = this.template.querySelector('c-salesforce-codex-data-table').getSelectedRows();
        console.log('AfterSelectedRow'+afterSelectedRows[0]); 
        getProductMrp({prodId:event.detail.draftValues[0].Id}).
            then((result) => {
                console.log(result);
                this.mrp = result.Kurl_On_to_Retailer_Price__c;
                console.log(this.mrp+'Rs');
                this.productImage = result.Product_Image_Link__c;
                this.brand = result.Brand__c;
                this.collection = result.Collection__c;
                this.prodName = result.Name;
                this.size = result.Size__c;
                this.designNo = result.Design_Number__c;
                this.color = result.Color__c;
                this.availability = result.Availability__c;
                this.mop = result.MOP__c;

        let flag = false;
        let gst = 0;
        let gstFinal = 0;
        let gstPriceSum = 0;
        let finalTotal = 0;
        
        
        console.log(this.mrp+'MRP');

        quantity = quantity + Number( event.detail.draftValues[0].Quantity);
        this.quantity = this.quantity+quantity;
        this.currentQuantity = this.quantity;
        if(this.mrp < 1000){
            flag = true;
        }
        
        let idArr = [];
        for(let i = 0; i < draftValues.length; i++){
        idArr[i] = draftValues[i].Id;
        }
        console.log("Array of ids: "+idArr);
       
       // getGST({ lstProdId: event.detail.draftValues[0].Id,oppId:this.recordId,flag:flag}).then((result) => {
        
        getGST({ lstProdId: event.detail.draftValues[0].Id,oppId:this.recordId,flag:flag}).then((result) => {
            console.log('GST'+result);
            console.log('OppIds'+this.recordId);
            console.log('ProdIds'+event.detail.draftValues[0].Id);
            console.log(this.products);
            gst = result;  
            gstPrice = Number(event.detail.draftValues[0].Quantity)*this.mrp*(gst/100);
            console.log('MRP within '+this.mrp + ' gstres'+result);
           // gstPrice = gstPrice + this.products[0].Quantity*this.mrp*(gst/100);
            console.log('GSTPrice'+gstPrice);
            gstFinal = gstPrice; 
            gstPriceSum = gstPrice; 
            console.log('Gst Sum'+gstPriceSum);                
            //console.log(gst);
            //this.gstPriceTotal = this.gstPriceTotal+gstPriceSum;
            //this.currentGst = this.gstPriceTotal;               
            finalTotal = (this.mrp * Number(event.detail.draftValues[0].Quantity)) + gstPrice;
            
            this.gstMap.set(event.detail.draftValues[0].Id,gstPrice);
            console.log(this.gstMap);
            let sumGst = 0;
            for (let [key, value] of this.gstMap) {               
                sumGst = sumGst+value;
            }
            this.gstPriceTotal = sumGst.toFixed(2);
            this.total = this.MRP_Rollup + this.gstPriceTotal; 
            this.currentTotal = this.total;
            //this.total = this.total+finalTotal;
            //console.log('tp'+this.total);                
        }).catch((err) => {
            console.log(err);
        });
       
        

        console.log('Draftvalues end: '+ JSON.stringify(draftValues));
        this.quantityEnd = 0;
        let price = 0;
        for(let i = 0; i < draftValues.length; i++){
        this.quantityEnd = this.quantityEnd + parseInt(draftValues[i].Quantity);
        }  
        console.log(this.quantityEnd);
        
       let finalPrice = (Number(event.detail.draftValues[0].Quantity) * Number(this.mrp)) +gstFinal;
       // this.MRP_Rollup = this.MRP_Rollup + finalPrice; 
        

        console.log('Final'+finalPrice);  
        console.log('Final after formatting: '+finalPrice.toFixed(2));               
        this.oppLineItemRec.push({
            Id:event.detail.draftValues[0].Id,
            Product_Image_Link__c:this.productImage,
            Brand__c:this.brand,
            Collection__c:this.collection,
            Name:this.prodName,
            Size__c:this.size,
            Design_Number__c:this.designNo,
            Kurl_On_to_Retailer_Price__c:this.mrp,
            Color__c:this.color,
            //Design_Type__c:this.desi,
            Quantity: event.detail.draftValues[0].Quantity,
            MOP__c:this.mop,
            //Discount:this.discount[j]+'%',            
            //DiscMRP:discMrp,
            //Additional_Discount__c:draftValues[j].Additional_Discount__c,
            Availability__c:this.availability,
            Final_Price__c:finalPrice.toFixed(2)
        });
        this.products = this.products.map(obj => this.oppLineItemRec.find(o=>o.Id === obj.Id) || obj);


        console.log(this.products);
        console.log(this.products.length);
        this.MRP_Rollup = 0;
        for(let i = 0; i < draftValues.length; i++){
        console.log("Each final price: "+ this.products[i].Final_Price__c);
        this.MRP_Rollup = this.MRP_Rollup + this.products[i].Final_Price__c;
        }
        console.log(this.MRP_Rollup);


        this.saveOppLineItems.push({
            productId:event.detail.draftValues[0].Id,
            oppId:this.recordId,                
            Kurl_On_to_Retailer_Price__c:this.mrp,
            Quantity:event.detail.draftValues[0].Quantity,
            Additional_Discount__c:0,
            Additional_Discount_Price__c:this.mrp,
            //GST__c:this.gstWrapper,
            Final_Price__c:finalPrice 
        });
        //console.log('FinalList'+this.saveOppLineItems[0].Quantity);            
        
        //this.summaryMrp = this.summaryMrp+(draftValues[j].Quantity * discMrp);
        //this.summaryQuantity = this.summaryQuantity + draftValues[j].Quantity;
        
        this.currentMrp = this.MRP_Rollup; 
        
        console.log('GSTPRICETOT'+this.gstPriceTotal);         
        //this.gstPriceTotal = 0;  
        
        

        }).catch((err) => {
            console.log(err);
        });
        //console.log('Checked'+event.target.checked);       
        
       };

       
       //this.template.querySelector("c-salesforce-codex-data-table").draftValues = [];  
        
    }

    
    
    handleClick(event){
        if(this.quantityEnd >= 10000){
            const evt = new ShowToastEvent({
                message: 'The Quantity should be less than 10000',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            return;
        }
        console.log('clicked');
        console.log('Inside Call'+this.saveOppLineItems[0].Quantity);
        this.saveOppLineItems = [];
        let draftValues = this.template.querySelector('c-salesforce-codex-data-table').draftValues;
        let afterSelectedRows = this.template.querySelector('c-salesforce-codex-data-table').getSelectedRows();
        let flag = false;
        
        for (let j = 0; j < afterSelectedRows.length; j++) { 
            console.log(afterSelectedRows[j]);                        
            let gst = 0;           
            let mrp =  afterSelectedRows[j].Kurl_On_to_Retailer_Price__c;
            if(mrp < 1000){
                flag = true;
            }
            getGST({ lstProdId: afterSelectedRows[j].Id,oppId:this.recordId,flag:flag}).then((result) => {
                console.log('GSTSave'+result);
                gst = result;
                this.gstSave = result;

            }).catch((err) => {
                console.log(err);
            }); 
            console.log('GSTSAVE'+this.gstSave); 
            let finalPrice = (Number(draftValues[j].Quantity) * Number(afterSelectedRows[j].Kurl_On_to_Retailer_Price__c)) + gst;           
            console.log('OppID'+this.recordId);
            this.saveOppLineItems.push({
                productId:afterSelectedRows[j].Id,
                opportunityId:this.recordId,
                kurlonretailprice:afterSelectedRows[j].Kurl_On_to_Retailer_Price__c,
                quantity:draftValues[j].Quantity,
                addDisc:0,
                additionalDiscountPrice:afterSelectedRows[j].Kurl_On_to_Retailer_Price__c,
                gst:this.gstSave,                
                finalPrice:finalPrice 
            });
        }
        console.log('OppLineItems'+this.saveOppLineItems[0]);
        saveLineItems({ oppWrapperList: this.saveOppLineItems}).then((result) => {
            console.log(result);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Products added successfully',
                    variant: 'success'
                })
            );
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'Opportunity',
                    actionName: 'view'
                }
            });
        }).catch((err) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: err.message,
                    message: err.message,
                    variant: 'error'
                })
            );
        });
        console.log('Save btn data: ', this.oppLineItemRec);

        this.template.querySelector("c-salesforce-codex-data-table").draftValues = [];
        
    }
    

	/* connectedCallback() {
		this.subscribeMC();  
        //console.og('Db result:', this.wiredProducts);
        console.log(this.recordId); 
        console.log("Connected callback");
        console.log("Wired data length:"+this.products);     
	} */

	disconnectedCallback() {
		this.unsubscribeMC();
	}	

	subscribeMC() {
		if (this.subscription) {
			return;
		}
		this.subscription = subscribe(
			this.messageContext,
			FILTER_CHANNEL,
			(message) => {
				console.log("message " + JSON.stringify(message));
				this.filtersData = message.filtersData;
			}
		);
	}

	unsubscribeMC() {
		unsubscribe(this.subscription);
		this.subscription = null;
	}
}