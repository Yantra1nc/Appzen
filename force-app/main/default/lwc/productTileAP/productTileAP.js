import { LightningElement,api } from 'lwc';
const COLS=[  
    {label:'Product Picture',fieldName:'Product_Image_Link__c', type:'text area'},  
    {label:'Brand',fieldName:'Brand__c', type:'text'},  
    {label:'Collection',fieldName:'Collection_Name__c', type:'text'},  
    {label:'Design No.',fieldName:'Design_Number__c', type:'text'},
    {label:'Product',fieldName:'Product__c', type:'picklist'},
    {label:'Size',fieldName:'Size__c', type:'picklist'},
    {label:'MRP',fieldName:'MRP__c', type:'text'},
    {label:'Availability',fieldName:'Availability__c', type:'text'}
     ]; 
export default class ProductTileAP extends LightningElement {
    @api product;
    _productPrice;
    cols=COLS; 
   connectedCallback(){
     this._productPrice = this.product.PricebookEntries[0].UnitPrice;
     console.log(this._productPrice);
   }
}