/*
 * SF2-3113 - AT
 * JS to apply CSS as static resource for hiding the Change Owner Button
 * Also resposible for reloading the page to remove if the style was added  
 */

import { LightningElement, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import HideOwnerCSS from '@salesforce/resourceUrl/hideOwner';
import { CurrentPageReference } from 'lightning/navigation';
import OBJECT_NAMES from '@salesforce/label/c.Object_Names_to_hide_Change_Owner';

export default class HideOwner extends LightningElement {
    objNames = OBJECT_NAMES; //variable to hold the object names from custom labels
    pageOpened = false; //varibale to determine if the style of hiding was already loaded or not
    curURL = ''; // To hold the currentPage URL
    objNameSet = []; //set to hold the objectNames for which the style has to be applied
    @wire(CurrentPageReference)
    getpageRef(pageRef) {
        this.curURL = window.location; //Get the curent page URL
        if(pageRef){
            //Check the pageReference attributes 
            //If standard object page and current object is present in custom label
            //split the custom label by using comma and convert it to lower case to do an exact match
            //As JS is case-sensitive
            console.log(pageRef);
            let objPresent = this.objNames.toLowerCase() == 'all' || pageRef.attributes && pageRef.attributes.objectApiName && this.objNames.replace(/\s+/g, '').split(',').map((a) => { return a.toLowerCase() }).includes(pageRef.attributes.objectApiName.toLowerCase());
            if(pageRef.type == 'standard__objectPage' && objPresent){
                this.pageOpened = true; //Style is applied and so the variable will be holding true
                Promise.all([
                    loadStyle( this, HideOwnerCSS )
                    ]).then(() => {
                        console.log( 'Files loaded' );
                    })
                    .catch(error => {
                        console.log( error.body.message );
                });
            } else if(this.pageOpened){
                //Page reference will be changed but for the URL to change it'll take few seconds and so
                //making use of settimeout
                setTimeout(function() {
                    if(this.curURL != window.location){
                        this.pageOpened = false;
                        window.location.reload();
                    }
                }, 100);
            }
        }
    }
}