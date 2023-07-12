import { LightningElement,wire,api } from 'lwc';

// messageChannels
import {subscribe,unsubscribe,MessageContext} from "lightning/messageService";
import FILTER_CHANNEL from "@salesforce/messageChannel/productFilterChannel__c";
import getProducts from "@salesforce/apex/getProductsInAddProducts.getProducts";
import getProductCount from "@salesforce/apex/getProductsInAddProducts.getCountOfRecords";
import updateSalesOrder from '@salesforce/apex/getProductsInAddProducts.updateSalesOrder';
//import getGST from "@salesforce/apex/DynamicDiscount.getGST";
import getGST from "@salesforce/apex/DiscountCalculation.getGST";

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getProductDetails from "@salesforce/apex/getProductsInAddProducts.getProductDetails";
import getProductMrp from "@salesforce/apex/getProductsInAddProducts.getProductMrp";
import { refreshApex } from '@salesforce/apex';
import {getRecordNotifyChange} from 'lightning/uiRecordApi';
import getOppLineItems from '@salesforce/apex/getProductsInAddProducts.getOppLineItems';
//import saveEditedLineItems from '@salesforce/apex/DynamicDiscount.saveEditedLineItems';
import saveEditedLineItems from '@salesforce/apex/DiscountCalculation.saveEditedLineItems';
import getGstWrapper from '@salesforce/apex/DynamicDiscount.getGSTWrapper';
import calculateDynamicDiscount from '@salesforce/apex/DynamicDiscount.calculateDynamicDiscount';
import getPriceMaster from '@salesforce/apex/DynamicDiscount.getPriceMaster';



const COLS=[
    {label:'Product Image',fieldName:'Product_Image_Link__c', type:'image', 'wrapText':true,cellAttributes: { alignment: 'center' }},
    {label:'Brand',fieldName:'Brand__c', type:'text', 'wrapText':true,cellAttributes: { alignment: 'center' }},    
    {label:'Collection',fieldName:'Collection__c', type:'text','wrapText':true,cellAttributes: { alignment: 'center' }}, 
    //{label:'Design No.',fieldName:'Design_Num__c', type:'text','wrapText':true,cellAttributes: { alignment: 'center' }},
    {label:'Product Name',fieldName:'Name', type:'picklist','wrapText':true,cellAttributes: { alignment: 'center' }}, 
    {label:'Size',fieldName:'Size__c', type:'picklist','wrapText':true,cellAttributes: { alignment: 'center' }},
    {label:'MOP',fieldName:'MOP__c', type:'text','wrapText':true,cellAttributes: { alignment: 'center' }},
    {label:'Rate',fieldName:'Kurl_On_to_Retailer_Price__c', type:'text', sortable: true,'wrapText':true,cellAttributes: { alignment: 'center' }},
    //{label:'Color',fieldName:'Color__c', type:'picklist','initialWidth': 100},
    //{label:'Design Type',fieldName:'Design_Type__c', type:'picklist','initialWidth': 120},
    //{label:'Customer Basic Price',fieldName:'Additional_Discount__c', type:'double'},    



    {
    label: 'Kurl On Rate',
    fieldName: 'Kurl_On_to_Retailer_Price_1__c',
    type: 'text',
    sortable: true,
    'wrapText': true,
    typeAttributes: {
        step: '0.01',
        minimumFractionDigits: '2',
        maximumFractionDigits: '2'
    },
    cellAttributes: {
        alignment: 'center'
    }
    },
    {
    label: 'Indocount Rate',
    fieldName: 'Kurl_On_to_Retailer_Price__c',
    type: 'text',
    sortable: true,
    'wrapText': true,
    typeAttributes: {
        step: '0.01',
        minimumFractionDigits: '2',
        maximumFractionDigits: '2'
    },
    cellAttributes: {
        alignment: 'center'
    }
    },
    {label:'Availability',fieldName:'Availability__c', type:'text','wrapText':true,cellAttributes: { alignment: 'center' }},
    {label:'Quantity',fieldName:'Quantity', type:'integer',editable:'true',typeAttributes: { required: true ,autocomplete:'off'},'wrapText':true,cellAttributes: { alignment: 'center' }},
    {label:'Basic Order Value',fieldName:'Final_Price__c', type:'number','wrapText':true,typeAttributes:{
        step: '0.01', minimumFractionDigits: '2', maximumFractionDigits: '2'
    },cellAttributes: { alignment: 'center' }},
    {
        type: 'button-icon',
        typeAttributes:
        {
            iconName: 'utility:delete',
            name: 'delete',
            iconClass: 'slds-icon-text-error'
        },
        initialWidth:5
    }
    ]; 

export default class ProdEditAPClone extends NavigationMixin(LightningElement) {
    @api recordId;   
    itemProdMap = new Map();
    spinner = false;
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
    oppLineItemsArr = new Array(); 
    gstMap = new Map();
    quantityMap = new Map();
    basicValueMap = new Map();
    totalMap = new Map();
    selectedRowsMap = new Map();
    bovMap = new Map();
    oppLineItemId = new Map();
    sessionMap = new Map();
    currentTotalMap = new Map();
    wiredList=[];
    draftValues = [];
    sortedBy;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    deleteItemArr = [];
    deletedRows = [];
    deleteMap = new Map();
    idsToDelete = [];
    resultArr = [];
    resultMap = new Map();
    brandCheck;
    page = 1; 
    items = []; 
    data = []; 
    columns; 
    startingRecord = 1;
    endingRecord = 0; 
    pageSize = 20; 
    totalRecountCount = 0;
    totalPage = 1;
    productName = [];
    isWholeNumber = true;
    additionalDiscount = 0.00;
    additionalDiscountMap = new Map();
    noProducts = false;
    rowOffset = 0;
    offSet = 0;
    productsArray = [];
    loadProdArray = [];
    recCount = 0;

	filtersData = {
		minPrice: 0,
		maxPrice: 10000,
	};


    connectedCallback() {
        this.spinner = true;
		this.subscribeMC();  
        console.log(this.recordId);
        let brand;
        getOppLineItems({oppId:this.recordId}).then((result) => {
            if (result.length > 0) {
                console.log('Have items');
            }
            result.forEach(element => {
                this.productName = [...this.productName,element.Product2.Name];
                console.log(this.productName.length);
                brand = element.Product2.Brand__c;
                console.log('---Brand'+element.Product2.Brand__c);
            });
            this.brandCheck = brand;
        }).catch((err) => {
            console.log(JSON.stringify(err));
        });
        this.brand = brand;        
        return refreshApex(this.wiredList);        
              
	}

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
    //Function when component is rendered to DOM
	renderedCallback(){       
        this.updateValues();       
    }  
    
    
	@wire(getProducts, {filtersData: "$filtersData",recordId: '$recordId',offSet:0})
	wiredProducts(result){ 
               
        this.rowOffset = 0;
        this.wiredList = result.data;                      
        var arr1 = [];
        var arr2 = [];
        this.page = 1;
        this.additionalDiscount = 0.00;
        this.offSet = 0;
        this.noProducts = false;
        if(result.data){ 
            console.log('Length'+result.data.length);
            console.log(result.data[1]);            
            this.spinner = false;                        
            if (result.data.length == 0) {
                this.noProducts = true;
            }
            this.MRP_Rollup = 0;
            this.gstPriceTotal = 0;
            let gstPrice = 0;
            let quantity = 0;
            this.products = result.data; 
            this.items = result.data;           
            let flag = false;
            

            getProductCount({filtersData:this.filtersData,recordId:this.recordId})
            .then((result) => {
                console.log('ProductCount'+result);
                this.recCount = result;
                this.totalPage = Math.ceil(result/this.pageSize);
                console.log(this.totalPage);
                
            }).catch((err) => {
                console.log(err.body.message);
            });
           
            getProductDetails({oppId:this.recordId}).then((result) => {
                console.log('Inside getProductDetails apex'+result.Add_Discount__c);
                this.orderNo = result.Sales_Order_No__c;               
                this.orderDate = result.Order_Date__c;               
                this.expiryDate = result.CloseDate;                
                if (result.Add_Discount__c == null || result.Add_Discount__c == undefined) {
                    this.additionalDiscount = 0.0;                   
                }else{
                    this.additionalDiscount = result.Add_Discount__c;                   
                }
                
            }).catch((err) => {
                console.log(err.message);
            });
           if (this.bovMap.size > 0) {
            console.log('Bov Map contains products' + this.bovMap.size); 
            this.page  = 1;                  
            this.items = result.data;
            this.totalRecountCount = result.data.length;
           
            //this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
            this.endingRecord = this.pageSize; 
            this.updateValues();
            
            if(this.filtersData.collection.length == 0 && this.filtersData.designType.length == 0 && this.filtersData.brand.length == 0 && this.filtersData.size.length == 0 && this.filtersData.color.length == 0 && this.filtersData.minPrice == 0 && this.filtersData.maxPrice == 10000){
                for(let [key,value] of this.bovMap){
                    this.productsArray.push({
                        Id:value.Id,
                        Product_Image_Link__c:value.Product_Image_Link__c,
                        Brand__c:value.Brand__c,
                        Collection__c:value.Collection__c,
                        Name:value.Name,
                        Size__c:value.Size__c,
                        Design_Num__c:value.Design_Num__c,
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
                    arr1 = [...arr1, {
                        Id:value.Id,
                        Product_Image_Link__c:value.Product_Image_Link__c,
                        Brand__c:value.Brand__c,
                        Collection__c:value.Collection__c,
                        Name:value.Name,
                        Size__c:value.Size__c,
                        Design_Num__c:value.Design_Num__c,
                        Kurl_On_to_Retailer_Price__c:value.Kurl_On_to_Retailer_Price__c,
                        Color__c:value.Color__c,                    
                        Quantity: value.Quantity,
                        MOP__c:value.MOP__c,                   
                        Availability__c:value.Availability__c,
                        Final_Price__c:value.Final_Price__c
                    }];               
                } 
                console.log('Arr1'+arr1);
                arr2 = this.items.filter( function( item ){
                    return arr1.find( function( item2 ){
                      return item.Id == item2.Id;
                    }) == undefined;
                  });             
                this.resultArr = [...new Set(arr1.concat(arr2))];
                console.log('Result array'+this.resultArr);
                this.resultArr = this.resultArr.map(obj => this.productsArray.find(o=>o.Id === obj.Id) || obj);
                this.data = this.resultArr.slice(0,this.pageSize);
                this.selectedRows = [...this.selectedRows];
                this.products =  this.data; 
            }else{
                console.log('Loadmore..');
                this.loadData();
            }        
                              
               
                      
           }else{ 
            console.log('BovMap is null');        
            this.page  = 1;                  
            this.items = result.data;
            this.totalRecountCount = result.data.length;
          
            //this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
            this.endingRecord = this.pageSize;                    
            getOppLineItems({oppId:this.recordId}).then((result) => {
                if (result.length > 0) {
                    result.forEach(element => {                        
                        console.log('Inside opplineitems loop');                        
                        if (element.Additional_Discount__c === undefined) {
                            element.Additional_Discount__c = 0;
                        }
                        let gst = 0;
                        let gstFinal = 0;
                        let gstPriceSum = 0;                       
                        this.oppLineItemId.set(element.Product2Id,element.Id);
                        this.selectedRows = [...this.selectedRows,element.Product2Id];
                        this.selectedRowsMap.set(element.Product2Id,element.Product2Id);  
                        console.log('Selected  rowss..'+this.selectedRows);                  
                        quantity = quantity + element.Quantity;
                        this.quantityEnd = quantity;
                        if(element.Product2.Kurl_On_to_Retailer_Price__c < 1000){
                            flag = true;
                        }else{
                            flag = false;
                        }
                        gstPrice = element.Quantity*element.Product2.Kurl_On_to_Retailer_Price__c*(element.GST__c/100);
                        
                        gstPriceSum = gstPriceSum+gstPrice;
                        this.gstMap.set(element.Product2Id,gstPrice * (1 - (Math.abs(element.Additional_Discount__c)/100)));
                        let sumGst = 0;
                            for (let [key, value] of this.gstMap) {  
                                             
                                sumGst = sumGst+value;
                            }
                        this.gstPriceTotal = sumGst;
                        
                        
                        this.quantityMap.set(element.Product2Id,element.Quantity);
                        
                        let quantTotal = 0;
                        for (let [key, value] of this.quantityMap) {               
                            quantTotal = quantTotal+Number(value);
                        }
                        this.quantityEnd = quantTotal;
                       
                        let priceAfterDisc = (Number(element.Product2.Kurl_On_to_Retailer_Price__c) * Number(element.Quantity));
                        this.basicValueMap.set(element.Product2Id,priceAfterDisc * (1 - (element.Additional_Discount__c/100)));
                       
                        let mrpTotal = 0;
                        for (let [key, value] of this.basicValueMap) {               
                            mrpTotal = mrpTotal+Number(value);
                        }
                        this.MRP_Rollup = mrpTotal;
                        
            
                        this.totalMap.set(element.Product2Id,this.MRP_Rollup + this.gstPriceTotal);
                       
                        let sumTotal = 0;
                        for (let [key, value] of this.totalMap) {               
                            sumTotal = sumTotal+value;
                        }
                        this.total = Array.from(this.totalMap.values()).pop();                        
                        
                        //this.MRP_Rollup = this.MRP_Rollup + (Number(element.Additional_Discount_Price__c) * Number(element.Quantity));
                        //this.total = this.MRP_Rollup + this.gstPriceTotal ; 
                        let finalPrice = (Number(element.Quantity) * Number(element.Product2.Kurl_On_to_Retailer_Price__c)) +gstFinal;
                       
                        arr1 = [...arr1, {
                            Id:element.Product2Id,
                            Product_Image_Link__c:element.Product2.Product_Image_Link__c,
                            Brand__c:element.Product2.Brand__c,
                            Collection__c:element.Product2.Collection__c,
                            Name:element.Product2.Name,
                            Size__c:element.Product2.Size__c,
                            Design_Num__c:element.Product2.Design_Num__c,
                            Kurl_On_to_Retailer_Price__c:element.Product2.Kurl_On_to_Retailer_Price__c,
                            Color__c:element.Product2.Color__c,                            
                            Quantity: element.Quantity,
                            MOP__c:element.Product2.MOP__c,                            
                            Availability__c:element.Product2.Availability__c,
                            Final_Price__c:finalPrice 
                        }];
                       
                        for (let index = 0; index < this.products.length; index++) {
                            const ele = this.products[index];                          
                            
                                arr2 = [...arr2,ele];
                                arr2 = [...new Set(arr2)];
                           
                        }
                        console.log('Line 433'+this.oppLineItemRec.length);
                        this.bovMap.set(element.Product2Id,
                            {
                                Id:element.Product2Id,
                                OppLiId:element.Id,
                                Product_Image_Link__c:element.Product2.Product_Image_Link__c,
                                Brand__c:element.Product2.Brand__c,
                                Collection__c:element.Product2.Collection__c,
                                Name:element.Product2.Name,
                                Size__c:element.Product2.Size__c,
                                Design_Num__c:element.Product2.Design_Num__c,
                                Kurl_On_to_Retailer_Price__c:element.Product2.Kurl_On_to_Retailer_Price__c,
                                Color__c:element.Product2.Color__c,                        
                                Quantity: element.Quantity,
                                MOP__c:element.Product2.MOP__c,                        
                                Availability__c:element.Product2.Availability__c,
                                Final_Price__c:finalPrice 
                            });   
                    });  
                    console.log('Arr1'+JSON.stringify(arr1));
                    console.log('Arr2'+JSON.stringify(arr2));              
                   console.log('Outside opplineitemloop');
                          
                    for(let [key,value] of this.bovMap){
                        this.oppLineItemRec.push({
                            Id:value.Id,
                            Product_Image_Link__c:value.Product_Image_Link__c,
                            Brand__c:value.Brand__c,
                            Collection__c:value.Collection__c,
                            Name:value.Name,
                            Size__c:value.Size__c,
                            Design_Num__c:value.Design_Num__c,
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
                    console.log('Items 464...'+JSON.stringify(this.oppLineItemRec));
                    arr2 = this.items.filter( function( item ){
                        return arr1.find( function( item2 ){
                          return item.Id == item2.Id;
                        }) == undefined;
                      });  
                    this.resultArr = [...new Set(arr1.concat(arr2))];             
                    console.log('Line 463'+this.resultArr.length); 
                    //this.products = this.resultArr;                  
                    this.data = this.resultArr.slice(0,this.pageSize);
                    this.products = this.data; 
                    this.products = this.products.map(obj => this.resultArr.find(o=>o.Id === obj.Id) || obj);
                    
                    console.log(this.products);                    
                }else{
                    console.log(this.wiredList.length);
                    this.page  = 1;                  
                    this.items = this.wiredList;
                    this.totalRecountCount = this.wiredList.length; 
                    //this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);            
                    this.endingRecord = this.pageSize;                   
                    //this.items = this.items.map(obj => this.oppLineItemRec.find(o=>o.Id === obj.Id) || obj);
                    this.data = this.items.slice(0,this.pageSize);        
                    this.products = this.products.map(obj => this.oppLineItemRec.find(o=>o.Id === obj.Id) || obj);                    
                    this.products =  this.data;
                }              
            }).catch((err) => {
                console.log(err);
            });
              
           } 

        }
    };
    
    // This method contains the logic for lazy loading of the products into the custom datatable
    loadData(){  
        if(this.offSet < 20 && (this.filtersData.collection.length == 0 && this.filtersData.designType.length == 0 && this.filtersData.brand.length == 0 && this.filtersData.size.length == 0 && this.filtersData.color.length == 0 && this.filtersData.minPrice == 0 && this.filtersData.maxPrice == 10000)){
            this.spinner = true;
            this.data = this.resultArr.slice(0,this.pageSize);
            console.log(this.data);
            this.products =  this.data; 
            this.spinner = false;
        }else{
            console.log('Load more...');
            this.spinner = true;
            console.log('Filters '+ JSON.stringify(this.filtersData));
            console.log('RecordId '+this.recordId);
            console.log('Offset '+this.offSet);         
            console.log('RecLength '+ this.recCount);            
            getProducts({filtersData:this.filtersData,recordId:this.recordId,offSet:this.offSet}).then((result) => {
                console.log(result);
                console.log(this.filtersData);
                if(result){
                    
                    this.loadProdArray = [];
                    result.forEach(element => {
                        console.log(element.Collection__c);
                        this.loadProdArray.push({
                            Id:element.Id,
                            Product_Image_Link__c:element.Product_Image_Link__c,
                            Brand__c:element.Brand__c,
                            Collection__c:element.Collection__c,
                            Name:element.Name,  
                            Size__c:element.Size__c,
                            Design_Num__c:element.Design_Num__c,
                            Kurl_On_to_Retailer_Price__c:element.Kurl_On_to_Retailer_Price__c,
                            Color__c:element.Color__c,                   
                            Quantity: element.Quantity,
                            MOP__c:element.MOP__c,                   
                            Availability__c:element.Availability__c,
                            Final_Price__c:element.Final_Price__c
                        });
                    });                    
                    this.loadProdArray = this.loadProdArray.slice(0,this.pageSize);
                    for(let [key,value] of this.bovMap){
                        this.loadProdArray.forEach(item => {
                            if(item.Id == value.Id){
                              this.loadProdArray =  this.loadProdArray.filter(function(prod){
                                    return prod.Id != item.Id;
                               });  
                               console.log(this.loadProdArray);
                                this.loadProdArray.unshift({
                                    Id:value.Id,
                                    Product_Image_Link__c:value.Product_Image_Link__c,
                                    Brand__c:value.Brand__c,
                                    Collection__c:value.Collection__c,
                                    Name:value.Name,  
                                    Size__c:value.Size__c,
                                    Design_Num__c:value.Design_Num__c,
                                    Kurl_On_to_Retailer_Price__c:value.Kurl_On_to_Retailer_Price__c,
                                    Color__c:value.Color__c,                   
                                    Quantity: value.Quantity,
                                    MOP__c:value.MOP__c,                   
                                    Availability__c:value.Availability__c,
                                    Final_Price__c:value.Final_Price__c
                                });
                                
                            }
                        });
                    }
                    this.products = this.loadProdArray;                    
                    console.log(this.products); 
                    this.spinner = false; 
                }else{
                    this.noProducts = true;
                }
            }).catch((err) => {
                console.log(err);
            });
        }      
       
    }
   
	@wire(MessageContext)
	messageContext;     

    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.offSet = this.offSet-20;
            this.displayRecordPerPage(this.page);
            this.loadData();            
        }              
    }

    nextHandler() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.offSet = this.offSet+20;
            this.displayRecordPerPage(this.page);   
            this.loadData();         
        }             
    }

    displayRecordPerPage(page){
       
        this.startingRecord = ((page -1) * this.pageSize) ;        
        this.endingRecord = (this.pageSize * page);
        this.rowOffset = this.startingRecord;

        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 

        if (this.resultArr.length == 0) {
            this.data = this.wiredList.slice(this.startingRecord, this.endingRecord);
        }else{

            this.data = this.resultArr.slice(this.startingRecord, this.endingRecord);
        } 
        for(let [key,value] of this.bovMap){
            this.oppLineItemRec.push({
                Id:value.Id,
                Product_Image_Link__c:value.Product_Image_Link__c,
                Brand__c:value.Brand__c,
                Collection__c:value.Collection__c,
                Name:value.Name,
                Size__c:value.Size__c,
                Design_Num__c:value.Design_Num__c,
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
        this.products = this.data;
        this.products = this.products.map(obj => this.oppLineItemRec.find(o=>o.Id === obj.Id) || obj);
        this.selectedRows = [...this.selectedRows];
        this.startingRecord = this.startingRecord + 1;        
        
    }    
    
    
    getProductDetails(filtersData){
        getProducts({
            filtersData: filtersData
        }).then((result) => {
            this.products = result.data;
        }).catch((err) => {
            
        });
    }

    updateValues(){
        
        let sumGst = 0;
        for (let [key, value] of this.gstMap) {               
            sumGst = sumGst+value;
        }        
        this.gstPriceTotal = sumGst;      

        let quantTotal = 0;
        for (let [key, value] of this.quantityMap) {               
            quantTotal = quantTotal+Number(value);
        }
        this.quantityEnd = quantTotal;
        

        let mrpTotal = 0;
        for (let [key, value] of this.basicValueMap) {               
            mrpTotal = mrpTotal+Number(value);
        }
        this.MRP_Rollup = mrpTotal;
        
        
        this.total = this.MRP_Rollup + this.gstPriceTotal;
       
    }

    updateTotal(recId){
        
        let sumGst = 0;
        for (let [key, value] of this.gstMap) {               
            sumGst = sumGst+value;
        }        
        this.gstPriceTotal = sumGst; 

        let quantTotal = 0;
        for (let [key, value] of this.quantityMap) {               
            quantTotal = quantTotal+Number(value);
        }
        this.quantityEnd = quantTotal;
        

        let mrpTotal = 0;
        for (let [key, value] of this.basicValueMap) {               
            mrpTotal = mrpTotal+Number(value);
        }
        this.MRP_Rollup = mrpTotal; 

        let sumTotal = 0;
        sumTotal = this.totalMap.get(recId);
        this.total = sumTotal;
       

    }
    
    getSelectedName(event){
        this.oppLineItemRec = [];  
        this.saveOppLineItems = [];     
        this.MRP_Rollup = 0;
        let quantity = 0;
        this.gstPriceTotal = 0;
        let gstPrice = 0;       
        this.total = 0;
        let finalMrp = 0;
        this.selectedRows = [];
                

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
        console.log('OutsideDraft'+draftValues.length);
        
        let afterSelectedRows = this.template.querySelector('c-salesforce-codex-data-table').getSelectedRows();        
        let flag = false;

        
        
        let newSelectArr = draftValues.filter(obj => getSelectedRows.find(o=>o.Id === obj.Id));        
        this.quantityEnd = 0;        
        for(let i = 0; i < newSelectArr.length; i++){
            this.quantityEnd = this.quantityEnd + parseInt(newSelectArr[i].Quantity);
        }
        
        let idArr1 = [];
        for(let i = 0; i < newSelectArr.length; i++){
            idArr1[i] = newSelectArr[i].Id;
        }
        let idArr2 = [];
        for(let i = 0; i < draftValues.length; i++){
            idArr2[i] = draftValues[i].Id;
        }
        const unCommonArray = (first, second) => {
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
         };
        console.log(unCommonArray(idArr1, idArr2));
        let deSelectedRowsIds = []; 
        deSelectedRowsIds = unCommonArray(idArr1, idArr2);
        for(let k = 0; k < deSelectedRowsIds.length; k++ ){
        console.log("Deselected ids: "+deSelectedRowsIds[k]);
        //this.selectedRowsMap.delete(deSelectedRowsIds[k]);
        //this.gstMap.delete(deSelectedRowsIds[k]);
        //this.bovMap.delete(deSelectedRowsIds[k]);
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
                        Design_Num__c:this.products[j].Design_Num__c,
                        Kurl_On_to_Retailer_Price__c:this.products[j].Kurl_On_to_Retailer_Price__c,
                        Color__c:this.products[j].Color__c,
                        Design_Type__c:this.products[j].Design_Type__c,
                        Quantity:"",
                        MOP__c:this.products[j].MOP__c,
                        Availability__c:this.products[j].Availability__c,
                        Final_Price__c:""
                    });
                    console.log('Before delete'+this.bovMap.size);
                    this.bovMap.delete(this.products[j].Id);
                    console.log(this.selectedRowsMap.size);
                    
                    if(draftValues.length < 1 || draftValues.length == 1){
                        this.draftValues = [];
                    }else{
                        var index = draftValues.findIndex(p => p.Id == this.products[j].Id);                       
                        draftValues.splice(index,1); 
                        this.draftValues = draftValues;
                    }                    
                    this.selectedRowsMap.delete(this.products[j].Id);
                    
                    console.log(this.selectedRowsMap.size);
                    this.quantityMap.delete(this.products[j].Id);
                    this.gstMap.delete(this.products[j].Id);
                    this.basicValueMap.delete(this.products[j].Id);
                    this.totalMap.delete(this.products[j].Id);
                }
            }
        }
        //this.updateValues(); 
        console.log('After delete'+this.bovMap.size);
         
        for (let [key, value] of this.bovMap) {               
            console.log('ProdNameMap'+value.Final_Price__c);
            //this.selectedRows = [...this.selectedRows,value.Id];
            let gst = 0;
            let gstFinal = 0;
            let gstPriceSum = 0;
            this.gstPriceTotal = 0;
            let finalTotal = 0;
            this.total = 0;            
            
            let mrp =  value.Kurl_On_to_Retailer_Price__c;
            //let disMrp = Number(this.discount[j]);           
            //let discMrp = mrp-(Number(mrp)*(disMrp))/100; 
            
            quantity = quantity + Number(value.Quantity);
            this.quantityEnd = quantity;
            console.log('QuanityInside'+this.quantityEnd);
            this.currentQuantity = this.quantityEnd;
            if(mrp < 1000){
                flag = true;
            }
            getGST({ lstProdId: value.Id,oppId:this.recordId,flag:flag}).then((result) => {
               
                gst = result;  
                gstPrice = gstPrice + Number(value.Quantity)*mrp*(gst/100);
                console.log('GSTPrice'+gstPrice);
                gstFinal = gstPrice; 
                gstPriceSum = gstPriceSum+gstPrice; 
                console.log('Gst Sum'+gstPriceSum);                
                //console.log(gst);
                this.gstPriceTotal = gstPriceSum;
                this.currentGst = this.gstPriceTotal;               
                finalTotal = (mrp * Number(value.Quantity)) + gstPrice;                
                this.currentTotal = this.total;
                //this.total = this.total+finalTotal;
                //console.log('tp'+this.total);
                finalMrp = finalMrp + value.Final_Price__c;
                console.log('FinalMrp'+finalMrp);
                this.MRP_Rollup = finalMrp; 
                console.log('Total'+this.total);                 
                this.total = this.MRP_Rollup + this.gstPriceTotal;              
            }).catch((err) => {
                console.log(err);
            });                           
        } 
        for(let [key, value] of this.selectedRowsMap){
            this.selectedRows = [...this.selectedRows,value];
        }
        this.products = this.products.map(obj => this.oppLineItemRec.find(o=>o.Id === obj.Id) || obj);
        //this.updateValues();
        //this.template.querySelector("c-salesforce-codex-data-table").draftValues = [];
    }


    handleChange(event){
         
        console.log('Draft'+event.detail.draftValues[0].Quantity); 
        console.log(typeof(parseInt(event.detail.draftValues[0].Quantity)));
        var regex = /[ `a-zA-Z!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?~]/;
        var matched = regex.test(event.detail.draftValues[0].Quantity); 
        console.log(matched); 
      
        if (matched) {
            const evt = new ShowToastEvent({
                message: 'The Quantity should be Greater than 0 and not alpha-numeric',
                variant: 'error',            
            });
            this.dispatchEvent( evt );            
            return;
        }else{
              //this.selectedRows = [...this.selectedRows,event.detail.draftValues[0].Id];
        this.selectedRowsMap.set(event.detail.draftValues[0].Id,event.detail.draftValues[0].Id);
        if (this.deleteMap.has(event.detail.draftValues[0].Id)) {
            this.deleteMap.delete(event.detail.draftValues[0].Id);
        }
        console.log('Rows Map'+this.selectedRowsMap);
        for (let [key, value] of this.selectedRowsMap) {               
            this.selectedRows = [...this.selectedRows,value];
            console.log('SelectedRowsFilter'+this.selectedRows);
        }
        //console.log('SelectedRowsDraft'+this.selectedRows);
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
             message: 'The Quantity should be Greater than 0 and not alpha-numeric',
             variant: 'error',            
         });
         this.dispatchEvent( evt );
        
       }       
        getProductDetails({oppId:this.recordId}).then((result) => {
        console.log(result.Sales_Order_No__c);
        this.orderNo = result.Sales_Order_No__c;
        this.currentOrderNo = this.orderNo;
        this.orderDate = result.Order_Date__c;
        this.currentOrderDate = this.orderDate;
        this.expiryDate = result.CloseDate;
        this.currentExpiryDate = this.expiryDate;
        if (result.Add_Discount__c == null || result.Add_Discount__c == undefined) {
            this.additionalDiscount = 0.0;
        }else{
            this.additionalDiscount = result.Add_Discount__c;
        }
        
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
            this.designNo = result.Design_Num__c;
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
        
        this.gstMap.set(event.detail.draftValues[0].Id,gstPrice * (1 - (this.additionalDiscount/100)));
        console.log(this.gstMap);
        let sumGst = 0;
        for (let [key, value] of this.gstMap) {               
            sumGst = sumGst+value;
        }
        this.gstPriceTotal = sumGst;
        
        this.quantityMap.set(event.detail.draftValues[0].Id,event.detail.draftValues[0].Quantity);
        console.log(this.quantityMap);
        let quantTotal = 0;
        for (let [key, value] of this.quantityMap) {               
            quantTotal = quantTotal+Number(value);
        }
        this.quantityEnd = quantTotal;
        //this.total = this.MRP_Rollup + this.gstPriceTotal;
        let priceDisc = this.mrp * Number(event.detail.draftValues[0].Quantity);
        this.basicValueMap.set(event.detail.draftValues[0].Id,priceDisc * (1 - (this.additionalDiscount/100)));
        console.log(this.basicValueMap);
        let mrpTotal = 0;
        for (let [key, value] of this.basicValueMap) {               
            mrpTotal = mrpTotal+Number(value);
        }
        this.MRP_Rollup = mrpTotal; 

        this.totalMap.set(event.detail.draftValues[0].Id,this.MRP_Rollup + this.gstPriceTotal);
        console.log(this.totalMap);
        let sumTotal = 0;
        for (let [key, value] of this.totalMap) {               
            sumTotal = sumTotal+value;
        }
        
        //this.total = Array.from(this.totalMap.values()).pop();
        this.total = this.totalMap.get(event.detail.draftValues[0].Id);
        console.log('Sumtotal'+this.total);
        //this.total = sumTotal;
        this.currentTotal = this.total;
        this.updateTotal(event.detail.draftValues[0].Id);
        //this.total = this.total+finalTotal;
        //console.log('tp'+this.total);                
    }).catch((err) => {
        console.log(err);
    });
   

    /*console.log('Draftvalues end: '+ JSON.stringify(draftValues));
    this.quantityEnd = 0;
    let price = 0;
    for(let i = 0; i < draftValues.length; i++){
    this.quantityEnd = this.quantityEnd + parseInt(draftValues[i].Quantity);
    }  
    console.log(this.quantityEnd);*/
   let finalPrice = parseFloat((Number(event.detail.draftValues[0].Quantity) * Number(this.mrp))).toFixed(3);
   finalPrice = Math.round((Number(finalPrice) + Number.EPSILON) * 100) / 100;
   // this.MRP_Rollup = this.MRP_Rollup + finalPrice; 
    

    console.log('Final'+finalPrice);              
    this.oppLineItemRec.push({
        Id:event.detail.draftValues[0].Id,
        Product_Image_Link__c:this.productImage,
        Brand__c:this.brand,
        Collection__c:this.collection,
        Name:this.prodName,
        Size__c:this.size,
        Design_Num__c:this.designNo,
        Kurl_On_to_Retailer_Price__c:this.mrp,
        Color__c:this.color,
        //Design_Type__c:this.design,
        Quantity: event.detail.draftValues[0].Quantity,
        MOP__c:this.mop,
        //Discount:this.discount[j]+'%',            
        //DiscMRP:discMrp,
        //Additional_Discount__c:draftValues[j].Additional_Discount__c,
        Availability__c:this.availability,
        Final_Price__c:finalPrice 
    });
    this.products = this.products.map(obj => this.oppLineItemRec.find(o=>o.Id === obj.Id) || obj);
    //console.log('Oppline'+this.oppLineItemRec[0].Design_No__c + ' finalPrice'+finalPrice); 
    //this.oppLineItemsArr = this.oppLineItemRec;
    //localStorage.setItem('localOpp',JSON.stringify(this.oppLineItemRec));
    let oppLineId = this.oppLineItemId.get(event.detail.draftValues[0].Id) == null ? null:this.oppLineItemId.get(event.detail.draftValues[0].Id)
    this.bovMap.set(event.detail.draftValues[0].Id,
        {
            Id:event.detail.draftValues[0].Id,
            OppLiId:oppLineId,
            Product_Image_Link__c:this.productImage,
            Brand__c:this.brand,
            Collection__c:this.collection,
            Name:this.prodName,
            Size__c:this.size,
            Design_Num__c:this.designNo,
            Kurl_On_to_Retailer_Price__c:this.mrp,
            Color__c:this.color,
            //Design_Type__c:this.design,
            Quantity: event.detail.draftValues[0].Quantity,
            MOP__c:this.mop,
            //Discount:this.discount[j]+'%',            
            //DiscMRP:discMrp,
            //Additional_Discount__c:draftValues[j].Additional_Discount__c,
            Availability__c:this.availability,
            Final_Price__c:finalPrice 
        }            
    ); 
  
    }).catch((err) => {
        console.log(err);
    }); 
        }   
      
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
        this.spinner = true;
        this.idsToDelete = [];
        let brandArr = [];
        let isWhole = true;
      
        for(let [key,value] of this.bovMap){
            brandArr = [...brandArr,{
                name:value.Name,
                brand:value.Brand__c,
                quant:String(value.Quantity)               
            }];
            console.log('BrndArray'+JSON.stringify(brandArr));
        }
        for(let i=0;i<brandArr.length;i++){
           console.log(brandArr[i]);
            if((brandArr[i].quant % 1 != 0) || (brandArr[i].quant.slice(0,1) == "-") || (brandArr[i].quant.slice(-1) == ".")){
                isWhole = false; 
                console.log(isWhole);                
            }
        }
        console.log(isWhole);
        if (isWhole == false) {
            console.log(isWhole);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Quantity cannot be Negative / Decimal / Alphabet / Alpha-numeric',
                    variant: 'error'
                })
            );
            //isWhole = true;
            console.log('IsWhole '+isWhole);
            this.spinner = false;
            return;
        }
        let count = 0;
        for (let [key, value] of this.bovMap) { 
            count++;       

            let draftValues = this.template.querySelector('c-salesforce-codex-data-table').draftValues; 
            console.log(draftValues);
            var regex = /[ `a-zA-Z!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?~]/;
            for(let i = 0;i<draftValues.length;i++){           
             var matched = regex.test(draftValues[i].Quantity); 
                 if(matched){
                     this.dispatchEvent(
                         new ShowToastEvent({
                             title: 'Error',
                             message: 'Error saving products..Please enter the correct quantity',
                             variant: 'error'
                         })
                     );
                     this.spinner = false;

                     return;
                 }
            }               
           console.log('Inside Save'+value.Id); 
           console.log('ID'+this.recordId);
           


        
           //get data here and update
             getPriceMaster({productId:value.Id,oppId:this.recordId})
               .then((pm) => {
                  this.spinner = true;

                   console.log('PM ',pm);
                   this.saveOppLineItems = [];
                   this.saveOppLineItems.push({
                       productId: value.Id,
                       oppLineItemId: value.OppLiId,
                       opportunityId: this.recordId,
                       kurlonretailprice: value.Kurl_On_to_Retailer_Price__c,
                       Quantity: value.Quantity,
                       addDisc: this.additionalDiscount,
                       Additional_Discount_Price__c: value.Kurl_On_to_Retailer_Price__c,
                       //GST__c:this.gstWrapper,
                       priceAfterGst:(Number(value.Final_Price__c)+Number(this.gstMap.get(value.Id)))/value.Quantity,
                     //  gstPrice:Number(getWrapRes.cgst)+Number(getWrapRes.sgst)+Number(getWrapRes.igst),
                       discountedPrice:value.Final_Price__c/value.Quantity,
                       finalPrice: value.Final_Price__c, 
                       mdDiscountTerm:pm.MD_Disc_Term__c,
                       mdDistributorMargin:pm.MD_Distributor_Margin__c,
                       mdLfsMargin:pm.MD_LFS_Margin__c,
                       mdRetailerGst:pm.MD_Retailer_GST__c,
                       mdRetailerMargin:pm.MD_Retailer_Margin__c,
                       muDiscountTerm:pm.MU_Discount_Term__c,
                       muDistributorMargin:pm.MU_Distributor_Margin__c,
                       muLfsMargin:pm.MU_LFS_Margin__c,
                       muRetailerGst:pm.MU_Retailer_GST__c,
                       muRetailerMargin:pm.MU_Retailer_Margin__c,
                       priceMasterId:pm.Id,
                       priceMasterName:pm.Price_Master_Name__c
                       
                   }); 
                   console.log(this.saveOppLineItems);
                   if (this.saveOppLineItems.length > 0 || this.idsToDelete.length > 0) {
                       console.log('Inside if' + this.idsToDelete.length); 
                                         
                       saveEditedLineItems({
                           oppWrapperList: this.saveOppLineItems,
                           lstToDelete: this.idsToDelete,
                           opId: this.recordId
                       }).then((result) => {  
                          this.spinner = true;
                          console.log('this.idstodelete '+ this.idsToDelete);                          
                           this.dispatchEvent(
                               new ShowToastEvent({
                                   title: 'Success',
                                   message: 'Products added successfully',
                                   variant: 'success'
                               })
                           );  

                           this.spinner = false;
                             
                       
                           //window.location.reload();                           
                           updateSalesOrder({oppId : this.recordId}).then(result =>{
                               console.log(JSON.stringify(result));
                               setTimeout(function() {
                                   location.reload();
                                   //history.go(0);
                               }, 4000);                    
                           }).catch(error =>{
                              console.log(error);   
                              this.spinner = false;
  
                           });       
                           console.log('Size bovmap '+this.bovMap.size);
                         /*  if (this.bovMap.size == count) {
                               console.log('Count '+count);
                               window.location.reload();
                               this[NavigationMixin.Navigate]({
                                   type: 'standard__recordPage',
                                   attributes: {
                                       recordId: this.recordId,
                                       objectApiName: 'Opportunity',
                                       actionName: 'view'
                                   }
                               });
                           }    */                          
                           console.log('Save '+this.saveOppLineItems);                                
                   }).catch((err) => {
                       console.log('Error Apex : ',JSON.stringify(err.body.message));
                       this.spinner = false;

                           var msg = JSON.stringify(err.body.message);
                           this.spinner = false;
                           if(msg.includes("ENTITY_IS_LOCKED")){
                            msg = 'You can not Update/Edit items. After record is submited for Approval';
                        }
                               this.dispatchEvent(
                                   new ShowToastEvent({
                                       title: 'Error',
                                       message: msg,
                                       variant: 'error'
                                   })
                               );
                       });    

                   } else {
                       this.spinner = false;
                       this.dispatchEvent(
                           new ShowToastEvent({
                               title: 'Error',
                               message: 'Please select products',
                               variant: 'error'
                           })
                       );
                   }  
                   if(count > 0){
                       this.idsToDelete = []; 
                   }                               
               }).catch((err) => {
                      this.spinner = false;

                       console.log(JSON.stringify(err.message));
                       var msg = JSON.stringify(err.body.message);
                       this.spinner = false;
                       if(msg.includes("ENTITY_IS_LOCKED")){
                       msg = 'You can not Update/Edit items.';
                       }
                           this.dispatchEvent(
                               new ShowToastEvent({
                                   title: 'Error',
                                   message: msg,
                                   variant: 'error'
                               })
                           );
               });
                       
               console.log('Item to save ',this.saveOppLineItems);                    
       
              

            /*  this.saveOppLineItems.push({
                productId:value.Id,
                oppLineItemId:value.OppLiId,
                opportunityId:this.recordId,                
                kurlonretailprice:value.Kurl_On_to_Retailer_Price__c,
                Quantity:value.Quantity,
                addDisc:this.additionalDiscount,
                Additional_Discount_Price__c:value.Kurl_On_to_Retailer_Price__c,
                //GST__c:this.gstWrapper,
                finalPrice:value.Final_Price__c 
            });     
            console.log(this.saveOppLineItems);  
            */        
        }
        
        if(this.saveOppLineItems.length == 0 && this.idsToDelete.length < 0){
            this.spinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select products',
                    variant: 'error'
                })
            );
        }

        console.log('Length save ',this.saveOppLineItems.length);
        for(let [key,value] of this.deleteMap){
            this.idsToDelete = [...this.idsToDelete,value];
        }    
        console.log(' delete'+this.idsToDelete);

        if (this.idsToDelete.length > 0) {
            this.spinner = true;

            console.log('Inside if delete'+this.idsToDelete);
            saveEditedLineItems({ oppWrapperList: this.saveOppLineItems,lstToDelete:this.idsToDelete,opId:this.recordId}).then((result) => {
                console.log(result);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Products added successfully',
                        variant: 'success'
                    })
                ); 
                this.spinner = false;
                             
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.recordId,
                        objectApiName: 'Opportunity',
                        actionName: 'view'
                    }
                });   
                //window.location.reload();                           
                updateSalesOrder({oppId : this.recordId}).then(result =>{
                    console.log(JSON.stringify(result));
                    setTimeout(function() {
                        location.reload();
                        //history.go(0);
                    }, 4000);                    
                }).catch(error =>{
                   console.log(error);     
                });                 
            }).catch((err) => {
                this.spinner = false;

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message:  JSON.stringify(err.body.message),
                        variant: 'error'
                    })
                );
                console.log( JSON.stringify(err.body.message));
            });
            
        }
        this.saveOppLineItems = [];
        this.spinner = false;

        //this.template.querySelector("c-salesforce-codex-data-table").draftValues = [];        
        return refreshApex(this.wiredList);                    
    }

    onHandleSort( event ) {

        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.products];

        cloneData.sort( this.sortBy( sortedBy, sortDirection === 'asc' ? 1 : -1 ) );
        this.products = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;

    }

    sortBy( field, reverse, primer ) {

        const key = primer
            ? function( x ) {
                  return primer(x[field]);
              }
            : function( x ) {
                  return x[field];
              };

        return function( a, b ) {
            a = key(a);
            b = key(b);
            return reverse * ( ( a > b ) - ( b > a ) );
        };

    }

    handleRowAction(event){
        
        this.deletedRows = [];
        this.deleteItemArr = [];
        const action = event.detail.action;
        console.log(action.name);
        const row = event.detail.row;
        console.log(row.Id);
        this.deleteMap.set(row.Id,row.Id);
        let draftValues = this.template.querySelector('c-salesforce-codex-data-table').draftValues;
        console.log(draftValues);
        this.bovMap.delete(row.Id);
        this.selectedRowsMap.delete(row.Id);         
        if(this.draftValues.length < 1 || this.draftValues.length == 1){
            this.draftValues = [];
        }else{
            var index = this.draftValues.findIndex(p => p.Id == row.Id);                       
            this.draftValues.splice(index,1); 
            //this.draftValues = draftValues;
        } 
        this.deleteItemArr.push({
            Id:row.Id,
            Product_Image_Link__c:row.Product_Image_Link__c,
            Brand__c:row.Brand__c,
            Collection__c:row.Collection__c,
            Name:row.Name,
            Size__c:row.Size__c,
            Design_Num__c:row.Design_Num__c,
            Kurl_On_to_Retailer_Price__c:row.Kurl_On_to_Retailer_Price__c,
            Color__c:row.Color__c,
            //Design_Type__c:this.design,
            Quantity: '',
            MOP__c:row.MOP__c,
            //Discount:this.discount[j]+'%',            
            //DiscMRP:discMrp,
            //Additional_Discount__c:draftValues[j].Additional_Discount__c,
            Availability__c:row.Availability__c,
            Final_Price__c:''
        }); 
                              
       
        console.log('Array to delete '+JSON.stringify(this.deleteItemArr));  
        console.log(this.deleteMap);     
        this.quantityMap.delete(row.Id);
        this.gstMap.delete(row.Id);
        this.basicValueMap.delete(row.Id);
        this.totalMap.delete(row.Id);
        this.updateValues();
        this.products = this.products.map(obj => this.deleteItemArr.find(o=>o.Id === obj.Id) || obj);
        for(let [key, value] of this.selectedRowsMap){
            this.deletedRows = [...this.deletedRows,value];            
        }
        this.selectedRows = this.deletedRows;
        console.log(this.selectedRows);
    }
    
	
}