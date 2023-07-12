import { LightningElement,api} from 'lwc';

export default class ProductList extends LightningElement {
    @api products;
}