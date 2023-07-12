import { LightningElement,api } from 'lwc';

export default class ProductTile extends LightningElement {
    @api product;
    _productPrice;
    _brand;
    _collection;
    _size;
    _color;
    _designType;
    
   connectedCallback(){
     this._productPrice = this.product.PricebookEntries[0].UnitPrice;
     this._brand = this.product.Brand__c;
     this._collection = this.product.Collection__c;
     this._size = this.product.Size__c;
     this._color = this.product.Color__c;
     this._designType = this.product.Design_Type__c;
   }
}