import { LightningElement,wire} from 'lwc';

// messageChannels
import {subscribe,unsubscribe,MessageContext} from "lightning/messageService";
import FILTER_CHANNEL from "@salesforce/messageChannel/productFilterChannel__c";
import getProducts from "@salesforce/apex/getProductsInAddProducts.getProducts";

export default class AddProducts extends LightningElement {
    columns = [
        { label: 'Product Image', fieldName: 'Product_Image_Link__c', type:'image'},
        { label: 'Brand', fieldName: 'Brand__c', editable: false },
        { label: 'Collection', fieldName: 'Collection__c', editable: false },
        { label: 'Design Number', fieldName: 'Design_No__c', editable: false },
        { label: 'Product', fieldName: 'Product__c', type: 'date', editable: false },
        { label: 'Size', fieldName: 'Size__c', editable: false },
        { label: 'MRP', fieldName: 'MRP__c', editable: false },
        { label: 'Availability', fieldName: 'Availability__c', editable: false }
    ];

    subscription = null;
	
	filtersData = {
		minPrice: 0,
		maxPrice: 10000,
	};
	
	@wire(getProducts, {filtersData: "$filtersData"})
	wiredProducts;

	@wire(MessageContext)
	messageContext;

	connectedCallback() {
		this.subscribeMC();        
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