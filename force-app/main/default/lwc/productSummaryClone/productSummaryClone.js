import { LightningElement,api } from 'lwc';

export default class ProductSummaryClone extends LightningElement {
    @api mrp_rollup;
    @api quantity;
    @api total;
    @api gst;
    @api final;
    @api orderno;
    @api orderdate;
    @api expirydate;
    @api discount;
}