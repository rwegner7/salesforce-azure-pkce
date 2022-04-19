import {LightningElement} from 'lwc';
import getCachedToken from '@salesforce/apex/PKCEAzureService.getCachedToken';

export default class AzurePKCE extends LightningElement {

    token; //access token returned from getCachedToken
    error; //any error that is encountered
    navigateTo = ''; //used for auth call to azure
    AUTH_URL = ''; //TODO put your Auth Provider OAuth-Only Initialization URL here


    /*--------- LIFECYCLE EVENTS ----------------------------------------------------------*/
    connectedCallback() {
        this.initiateAuth();
    }

    /*--------- PROPERTIES ----------------------------------------------------------*/
    get hasToken(){
        return this.token && this.token !== '';
    }

    get hasError(){
        return this.error && this.token !== '';
    }

    /*--------- AUTH CALL ----------------------------------------------------------*/
    initiateAuth(){
        this.navigateTo = this.AUTH_URL; //load the auth url in the iframe
        setTimeout(() => { //wait for auth to finish (usually 1-2 seconds)
            this.fetchCachedToken(); //get the cached token
        },3000);
    }

    /*--------- FETCH TOKEN ----------------------------------------------------------*/
    fetchCachedToken(){
        getCachedToken() //call apex service to get the cached token
        .then(result => {
            this.token = result;
            this.error = '';
        })
        .catch(error => {
            this.error = error;
            this.token = '';
        });
    }
}