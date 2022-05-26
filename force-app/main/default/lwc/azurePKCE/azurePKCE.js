import {LightningElement} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import callAuthProvider from '@salesforce/apex/PKCEAzureService.callAuthProvider';

export default class AzurePKCE extends NavigationMixin(LightningElement) {

    token; //access token returned from getCachedToken
    error; //any error that is encountered

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
        callAuthProvider()
            .then((result) => {
                this.token = result;
                this.error = '';
                const deviceId = JSON.parse(window.atob(result.split('.')[1])).deviceid;
                console.log('::: device id ::: ' + deviceId);
            })
            .catch(error => {
                this.error = error;
                this.token = '';
            });
    }
}