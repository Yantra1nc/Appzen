import { LightningElement, wire } from "lwc";

// messageChannels
import {subscribe,unsubscribe,MessageContext} from "lightning/messageService";
import FILTER_CHANNEL from "@salesforce/messageChannel/productFilterChannel__c";
import getProducts from "@salesforce/apex/ProductService.getProducts";

export default class ProductSearch extends LightningElement {
    searchKey = "";
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