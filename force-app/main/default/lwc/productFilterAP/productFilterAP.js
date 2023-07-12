import { LightningElement, wire,api } from "lwc";
import { getPicklistValues } from "lightning/uiObjectInfoApi";

// messageChannels
import { publish, MessageContext } from "lightning/messageService";
import FILTER_CHANNEL from "@salesforce/messageChannel/productFilterChannel__c";
//product fields
import collections_field from "@salesforce/schema/Product2.Collection__c";
import designType_field from "@salesforce/schema/Product2.Design_Type__c";
import brand_field from "@salesforce/schema/Product2.Brand__c";
import size_field from "@salesforce/schema/Product2.Size__c";
import color_field from "@salesforce/schema/Product2.Color__c";
import designNo_field from "@salesforce/schema/Product2.Design_No__c";
import prodType_field from "@salesforce/schema/Product2.Product__c"
import { getRecord } from 'lightning/uiRecordApi';
import getDependentPicklistValues from "@salesforce/apex/GetDependentFields.getDependentPicklistValues";


export default class ProductFilterAP extends LightningElement {
   
	collections = [];
    size = [];
	minPrice=0;
	maxPrice=10000;	
	brand = [];
	designType = [];
    prodMin;
    prodMax;
	color = [];
	designNo = [];
	prodType = [];
	checkBoxOptions = [];
	hideFilter = true;
	@api recid;
	hasRendered = true;
	pickListValues = [];

	renderedCallback(){
		console.log('ProductFilterAP'+this.recid);
		if(this.hasRendered){
			
			getDependentPicklistValues({oppId:this.recid})
			.then(res=>{
				console.log(res);
				this.pickListValues = res;
				console.log(this.collections);
				this.hasRendered = false;
			}).catch(err=>{
				console.log(JSON.stringify(err));
			});
		}
		console.log(this.collections);
		
	}
	
	get options(){
		this.checkBoxOptions = [];
		this.pickListValues.forEach(element => {
					console.log('element '+element);
					const obj = {label:element,value:element};
					this.checkBoxOptions.push(obj);
				});
		return this.checkBoxOptions;
	}

    @wire(getPicklistValues, {
		recordTypeId: "012000000000000AAA",
		fieldApiName: collections_field
	})
	collectionsPicklistValues;
	
	@wire(getPicklistValues, {
		recordTypeId: "012000000000000AAA",
		fieldApiName: designType_field
	})
	designTypePicklistValues;

    @wire(getPicklistValues, {
		recordTypeId: "012000000000000AAA",
		fieldApiName: brand_field
	})
	brandPicklistValues;

    @wire(getPicklistValues, {
		recordTypeId: "012000000000000AAA",
		fieldApiName: size_field
	})
	sizePicklistValues;
   
	@wire(getPicklistValues, {
		recordTypeId: "012000000000000AAA",
		fieldApiName: color_field
	})
	colorPicklistValues;

	/*@wire(getPicklistValues, {
		recordTypeId: "012000000000000AAA",
		fieldApiName: designNo_field
	})
	designNoPicklistValues;*/

	@wire(getPicklistValues, {
		recordTypeId: "012000000000000AAA",
		fieldApiName: prodType_field
	})
	prodTypePicklistValues;

    @wire(MessageContext)
	messageContext;
	

	handleChange(event) {		
		this[event.target.name] = event.detail.value;		
		this.publishChange();
	}

	hideFilterColumn(event){
		if (this.hideFilter == true) {
			this.hideFilter = false;
		}
		else{
			this.hideFilter = true;
		}
		
		console.log(this.hideFilter);
	}

	publishChange() {
		const message = {
			filtersData: {
				collection: this.collections,
				minPrice: this.minPrice,
				maxPrice: this.maxPrice,				
				designType: this.designType,				
				brand: this.brand,
                size:this.size,
				color:this.color,
				//designNo:this.designNo,
				productType:this.prodType
			}
		};
		publish(this.messageContext, FILTER_CHANNEL, message);
	}

}