import {LightningElement} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getCachedToken from '@salesforce/apex/PKCEAzureService.getCachedToken';

export default class AzurePKCE extends NavigationMixin(LightningElement) {

    token; //access token returned from getCachedToken
    error; //any error that is encountered
    device;
    navigateTo = ''; //used for auth call to azure
    AUTH_URL = 'https://customer-velocity-3418.cs22.my.salesforce.com/services/auth/oauth/PKCEAzure2'; //TODO put your Auth Provider OAuth-Only Initialization URL here

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
        setTimeout(() => { //wait for auth to finish (usually 2-3 seconds)
            this.fetchCachedToken(); //get the cached token
        },3000);
    }

    fetchCachedToken(){
        getCachedToken() //call apex service to get the cached token
            .then(result => {
                this.token = result;
                this.error = '';
                const deviceId = JSON.parse(window.atob(result.split('.')[1])).deviceid;
                console.log('::: device id ::: ' + deviceId);
                this.device = deviceId;
            })
            .catch(error => {
                this.error = error;
                this.token = '';
            });
    }
}