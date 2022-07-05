import {LightningElement,wire} from 'lwc';
import getVFOrigin from '@salesforce/apex/POC_PKCE.getVFOrigin';

export default class PocPkce extends LightningElement {
    accessToken;
    workstationId;
    loadFrame;
    TOKEN = 'sfad_token';
    WORKSTATION = 'sfad_workstation';
    COM = '.com';

    // get vf origin
    @wire(getVFOrigin)
    vfOrigin;

    connectedCallback() {
        //bind event listener for data received from visualforce auth call
        window.addEventListener("message", this.handleAuthResponse.bind(this));
    }

    renderedCallback() {
        const isAuthenticated = sessionStorage.getItem(this.TOKEN);
        if(isAuthenticated){ //check session storage for existing token or workstation id.
            console.log('>>> Session Stored Token: ' + isAuthenticated);
            //this.workstationId = sessionStorage.getItem(this.WORKSTATION);
        }else{ //if there is no token or id, then call initiate VF Auth call
            console.log('>>> No token stored. Removed timeout.');
            this.loadFrame = true; //render the iframe
        }
    }

    handleAuthResponse(message) {
        if (message.data && (message.origin === this.vfOrigin.data + this.COM)) {
            const resp = message.data;
            if(resp.startsWith('vf-ready')){ //when the vf page is ready, start the auth call
                console.log('>>> Loaded.');
                this.initiateVFAuthCall();
            }else{ //we assume any other message would be the access token
                this.accessToken = resp;
                console.log('>>> Token: ' + this.accessToken);
                sessionStorage.setItem(this.TOKEN, this.accessToken);
                this.getWorkstationId(this.accessToken).catch();
            }
        }
    }

    async getWorkstationId(token){
        //const deviceId = JSON.parse(window.atob(token.split('.')[1])).deviceid;
        //console.log('>>> deviceId: ' + deviceId);
        //const endpoint = `https://graph.microsoft.com/v1.0/devices?$filter=deviceId+eq+'${deviceId}'&$select=displayName`;
        //const respJson = await this.callMSGraph(endpoint, token);
        //this.workstationId = respJson.value[0].displayName;
        //sessionStorage.setItem(this.WORKSTATION, this.workstationId);
        const storedToken = sessionStorage.getItem(this.TOKEN);
        console.log('>>> Session Storage Token: ' + storedToken);
        //TODO custom event or LMS to inform other components
    }

    initiateVFAuthCall() {
        console.log('>>> Initiating call to VF auth.');
        let message = 'pkce_login';
        //call vf to initiate auth flow
        this.template.querySelector("iframe").contentWindow.postMessage(message, this.vfOrigin.data + this.COM);
    }
}