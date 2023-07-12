import { LightningElement, wire } from "lwc";
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

export default class ProductFilter extends LightningElement {
   
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
	hideFilter = true;
	
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
		fieldApiName: prodType_field
	})
	prodTypePicklistValues;

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

	@wire(getPicklistValues, {
		recordTypeId: "012000000000000AAA",
		fieldApiName: designNo_field
	})
	designNoPicklistValues;

    @wire(MessageContext)
	messageContext;

	handleChange(event) {		
		this[event.target.name] = event.detail.value;		
		this.publishChange();
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
				designNo:this.designNo,
				prodType:this.prodType
			}
		};
		publish(this.messageContext, FILTER_CHANNEL, message);
	}

}