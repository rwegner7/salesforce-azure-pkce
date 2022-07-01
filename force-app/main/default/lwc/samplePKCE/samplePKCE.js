import {LightningElement} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class SamplePkce extends NavigationMixin(LightningElement) {
    navigateToPKCEPage() {
        // Navigate to a URL
        const params = {
            type: 'standard__webPage',
            attributes: {
                url: '/apex/SamplePKCE'
            }
        };
        this[NavigationMixin.Navigate](params);
    }
}