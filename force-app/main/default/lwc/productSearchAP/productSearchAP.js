import { LightningElement, wire,api } from "lwc";

// messageChannels
import {subscribe,unsubscribe,MessageContext} from "lightning/messageService";
import FILTER_CHANNEL from "@salesforce/messageChannel/productFilterChannel__c";
import getProducts from "@salesforce/apex/getProductsInAddProducts.getProducts";
import saveLineItems from "@salesforce/apex/DiscountCalculation.saveLineItems";
import getGST from "@salesforce/apex/DiscountCalculation.getGST";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getProductDetails from "@salesforce/apex/getProductsInAddProducts.getProductDetails";
import getProductMrp from "@salesforce/apex/getProductsInAddProducts.getProductMrp";
import { refreshApex } from '@salesforce/apex';
import getOppLineItems from "@salesforce/apex/getProductsInAddProducts.getOppLineItems";


const COLS=[
    {label:'Product Image',fieldName:'Product_Image_Link__c', type:'image', 'initialWidth': 140},
    {label:'Brand',fieldName:'Brand__c', type:'text', 'initialWidth': 80,'wrapText':true},    
    {label:'Collection',fieldName:'Collection__c', type:'text','initialWidth': 90,'wrapText':true}, 
    {label:'Design No.',fieldName:'Design_No__c', type:'text','initialWidth': 110,'wrapText':true},
    {label:'Product Name',fieldName:'Name', type:'picklist','initialWidth': 125,'wrapText':true}, 
    {label:'Size',fieldName:'Size__c', type:'picklist','initialWidth': 80},
    {label:'MOP',fieldName:'MOP__c', type:'text','initialWidth': 90},
    {label:'Rate',fieldName:'Kurl_On_to_Retailer_Price__c', type:'text','initialWidth': 80, sortable: true},
    //{label:'Color',fieldName:'Color__c', type:'picklist','initialWidth': 100},
    //{label:'Design Type',fieldName:'Design_Type__c', type:'picklist','initialWidth': 120},
    //{label:'Customer Basic Price',fieldName:'Additional_Discount__c', type:'double'},    
    {label:'Availability',fieldName:'Availability__c', type:'text','initialWidth': 90},
    {label:'Quantity',fieldName:'Quantity', type:'integer',editable:'true','initialWidth': 90,typeAttributes: {required: true ,autocomplete:'off'}},
    {label:'Basic Order Value',fieldName:'Final_Price__c', type:'double','initialWidth': 135}
    ]; 

export default class ProductSearchAP extends NavigationMixin(LightningElement) {

    @api recordId;
    cols=COLS; 
    searchKey = "";
	subscription = null;
    MRP_Rollup;
    oppLineItemRec = [];
    error ;
    arrayQuantity = [];
    quantity;
    quant;
    productId=[];
    totalordervalue;
    gst;
    gstPriceTotal; 
    gstWrapper;   
    products = [];
    preSelectedRows = [];
    discount = [];
    summaryMrp;
    summaryQuantity;
    total;
    saveOppLineItems = [];
	gstSave;
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
    totalGst;
    oppLineIds = [];
    draftValues = [];
    sortedBy;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    brandBoutique;
    brandLayer;
    brandCheck;
    isWholeNumber = true;
    page = 1; 
    items = []; 
    data = []; 
    columns; 
    startingRecord = 1;
    endingRecord = 0; 
    pageSize = 5; 
    totalRecountCount = 0;
    totalPage = 0;
    enableRowNumber;
    

	filtersData = {
		minPrice: 0,
		maxPrice: 10000,
	};

    
      

	@wire(getProducts, {filtersData: "$filtersData",recordId: '$recordId'})
	wiredProducts({error,data}){
        if(data){
            //this.products = data;            
            this.page  = 1;                  
            this.items = data;
            this.totalRecountCount = data.length; 
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);            
            this.endingRecord = this.pageSize;
            
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

    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    nextHandler() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }             
    }

    displayRecordPerPage(page){

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
    
    updateValues(){
        
        let sumGst = 0;
        for (let [key, value] of this.gstMap) {               
            sumGst = sumGst+value;
        }        
        this.gstPriceTotal = sumGst;  

        console.log('Inside Wire Filter'+this.gstPriceTotal);

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
        for (let [key, value] of this.totalMap) {               
            sumTotal = sumTotal+value;
        }
        this.total = Array.from(this.totalMap.values()).pop();
    }

    getProductDetails(filtersData){
        getProducts({
            filtersData: filtersData
        }).then((result) => {
            this.products = result.data;
        }).catch((err) => {
            
        });
    }

    
    getSelectedName(event){
      
        //console.log('Current'+this.currentSelectedRows);
        //console.log(this.selectedRows); 
        console.log('EventTarget'+event.currentTarget);       
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
                        Design_No__c:this.products[j].Design_No__c,
                        Kurl_On_to_Retailer_Price__c:this.products[j].Kurl_On_to_Retailer_Price__c,
                        Color__c:this.products[j].Color__c,
                        Design_Type__c:this.products[j].Design_Type__c,
                        Quantity:'',
                        MOP__c:this.products[j].MOP__c,
                        Availability__c:this.products[j].Availability__c,
                        Final_Price__c:""
                    });
                    console.log('Before delete'+this.bovMap.size);
                   
                    this.bovMap.delete(this.products[j].Id);

                   
                    if(draftValues.length < 1 || draftValues.length == 1){
                        this.draftValues = [];
                    }else{
                        var index = draftValues.findIndex(p => p.Id == this.products[j].Id);                       
                        draftValues.splice(index,1); 
                        this.draftValues = draftValues;    
                    }                    
                   
                    //this.products = this.products.map(obj => this.oppLineItemRec.find(o=>o.Id === obj.Id) || obj);
                    
                    this.selectedRowsMap.delete(this.products[j].Id);
                    for (let [key, value] of this.selectedRowsMap) {               
                        this.selectedRows = [...this.selectedRows,value];
                        console.log(value);                
                    }
                    this.quantityMap.delete(this.products[j].Id);
                    this.gstMap.delete(this.products[j].Id);
                    this.basicValueMap.delete(this.products[j].Id);
                    this.totalMap.delete(this.products[j].Id);
                    //this.template.querySelector('c-salesforce-codex-data-table').draftValues[this.products[j].Id] = [];
                    console.log('Deselected Draft'+draftValues[0].Id);
                }
            }
        }
        this.updateValues(); 
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
        for(let [key,value] of this.selectedRowsMap){
            this.selectedRows = [...this.selectedRows,value];
            console.log('Selected Ids'+value);
         }       
        this.products = this.products.map(obj => this.oppLineItemRec.find(o=>o.Id === obj.Id) || obj);
        //this.template.querySelector('c-salesforce-codex-data-table').draftValues = [];
    }


    handleChange(event){ 
      
        let isValidQuantity = this.isAlphaNumeric(event.detail.draftValues[0].Quantity);
        if(event.detail.draftValues[0].Quantity >= 10000){
            const evt = new ShowToastEvent({
                message: 'The Quantity should be less than 10000',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            return;
        }
        if (isValidQuantity === false) {
            const evt = new ShowToastEvent({
                message: 'Quantity cannot be Negative / Decimal / Alphabet / Alpha-numeric',
                variant: 'error',            
            });
            this.dispatchEvent( evt );
            return;
        }
        console.log('Draft'+event.detail.draftValues[0].Quantity); 
        console.log(typeof(event.detail.draftValues[0].Quantity));      
        //this.selectedRows = [...this.selectedRows,event.detail.draftValues[0].Id];
        this.selectedRowsMap.set(event.detail.draftValues[0].Id,event.detail.draftValues[0].Id);
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
             message: 'Quantity cannot be Negative / Decimal / Alphabet / Alpha-numeric',
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
        this.brandBoutique = result.Boutique_Living_Count__c;
        this.brandLayer = result.Layers_Count__c;
        
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
            this.designNo = result.Design_No__c;
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
    }else{
        flag = false;
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
        this.gstPriceTotal = sumGst;
        
        this.quantityMap.set(event.detail.draftValues[0].Id,event.detail.draftValues[0].Quantity);
        console.log(this.quantityMap);
        let quantTotal = 0;
        for (let [key, value] of this.quantityMap) {               
            quantTotal = quantTotal+Number(value);
        }
        this.quantityEnd = quantTotal;
        //this.total = this.MRP_Rollup + this.gstPriceTotal;
        this.basicValueMap.set(event.detail.draftValues[0].Id,this.mrp * Number(event.detail.draftValues[0].Quantity));
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
        this.total = Array.from(this.totalMap.values()).pop();
        //this.total = sumTotal;
        this.currentTotal = this.total;
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
   let finalPrice = (Number(event.detail.draftValues[0].Quantity) * Number(this.mrp)) +gstFinal;
  
   // this.MRP_Rollup = this.MRP_Rollup + finalPrice; 
    

    console.log('Final'+finalPrice);              
    this.oppLineItemRec.push({
        Id:event.detail.draftValues[0].Id,
        Product_Image_Link__c:this.productImage,
        Brand__c:this.brand,
        Collection__c:this.collection,
        Name:this.prodName,
        Size__c:this.size,
        Design_No__c:this.designNo,
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
    console.log('Oppline'+this.oppLineItemRec.length); 
    //this.oppLineItemsArr = this.oppLineItemRec;
    //localStorage.setItem('localOpp',JSON.stringify(this.oppLineItemRec));
    this.bovMap.set(event.detail.draftValues[0].Id,
        {
            Id:event.detail.draftValues[0].Id,
            Product_Image_Link__c:this.productImage,
            Brand__c:this.brand,
            Collection__c:this.collection,
            Name:this.prodName,
            Size__c:this.size,
            Design_No__c:this.designNo,
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
    this.updateValues();    

    }).catch((err) => {
        console.log(err);
    });
    
             
        
    }

    isAlphaNumeric(quantity) {
        var code, i, len;
      
        for (i = 0, len = quantity.length; i < len; i++) {
          code = quantity.charCodeAt(i);
          if (!(code > 47 && code < 58) && // numeric (0-9)
              !(code > 64 && code < 91) && // upper alpha (A-Z)
              !(code > 96 && code < 123)) { // lower alpha (a-z)
            return false;
          }
        }
        return true;
    }
    
    handleClick(event){
        console.log('InsideSave'+this.bovMap.size);
        console.log('Brandd'+this.brand);
        let brandArr = [];
        let errorBrand;
        let errorName;
        for(let [key,value] of this.bovMap){
            brandArr = [...brandArr,{
                name:value.Name,
                brand:value.Brand__c,
                quant:value.Quantity                
            }];
            console.log('BrndArray'+JSON.stringify(brandArr));
        }
        for(let i=0;i<brandArr.length;i++){
            if (brandArr[i].brand != this.brandCheck) {
                errorBrand = brandArr[i].brand;
                errorName = brandArr[i].name;
            }
            if((brandArr[i].quant % 1 != 0) || (brandArr[i].quant.slice(0,1) == "-") || (brandArr[i].quant.slice(-1) == ".")){
                this.isWholeNumber = false;      
            }
        }
        if (this.isWholeNumber == false) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Quantity cannot be Negative / Decimal / Alphabet / Alpha-numeric',
                    variant: 'error'
                })
            );
            this.isWholeNumber = true;
            return;
        }
        let sameElements = brandArr.every((val,i,arr)=> val === arr[0]);
        let flag = 0;
        if (this.brandBoutique > 0) {
            flag = 1;
        }else if(this.brandLayer > 0){
            flag = 2;
        }else if((this.brandBoutique == null || this.brandLayer == null) && sameElements == true){            
            flag = 0;
        }
        else if((this.brandBoutique == null || this.brandLayer == null) && sameElements == false){
            flag = 3;            
        }
        for (let [key, value] of this.bovMap) {               
           console.log('Inside Save'+value.Id); 
           console.log('KurlPrice'+value.Kurl_On_to_Retailer_Price__c);
           console.log(this.oppLineIds.includes(value.Id));
           
           if (this.oppLineIds.includes(value.Id)) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Duplicate products found, please use the Edit Product Button',
                    variant: 'error'
                })
            );
            return;
           }else{
              if((value.Brand__c == 'Layers' && flag == 2) ||(value.Brand__c == 'Boutique Living' && flag == 1) || flag == 0){
                this.saveOppLineItems.push({
                    productId:value.Id,
                    opportunityId:this.recordId,                
                    kurlonretailprice:value.Kurl_On_to_Retailer_Price__c,
                    Quantity:value.Quantity,
                    addDisc:0,
                    Additional_Discount_Price__c:value.Kurl_On_to_Retailer_Price__c,
                    //GST__c:this.gstWrapper,
                    finalPrice:value.Final_Price__c 
                });
                console.log('Save'+JSON.stringify(this.saveOppLineItems));
              }else{                                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'The Sales Order have the Products for Brand" '+this.brandCheck+' "You cannot add product" '+errorName+' " of brand " '+errorBrand+' "',
                        variant: 'error'
                    })
                );
                return;
              }            
            console.log(this.saveOppLineItems); 
            console.log('Flag'+flag);
           }                   
        }
        
        if (this.saveOppLineItems.length > 0) {
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
                window.location.reload();
            }).catch((err) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: JSON.stringify(err.body.message),
                        variant: 'error'
                    })
                );
            });
    
        }else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select products',
                    variant: 'error'
                })
            );
        }
        
        //this.template.querySelector("c-salesforce-codex-data-table").draftValues = [];
       
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

	connectedCallback() {
		this.subscribeMC();  
        //console.og('Db result:', this.wiredProducts);
        console.log(this.recordId);
        let brand;
        getOppLineItems({oppId:this.recordId}).then((result) => {
            
            result.forEach(element => {
                this.oppLineIds = [...this.oppLineIds,element.Product2Id];
                console.log(this.oppLineIds.length);
                brand = element.Product2.Brand__c;
                console.log('---Brand'+element.Product2.Brand__c);
            });
            this.brandCheck = brand;
        }).catch((err) => {
            console.log(err.message);
        });
        this.brand = brand;
	}

    renderedCallback(){
        this.updateValues();
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
}