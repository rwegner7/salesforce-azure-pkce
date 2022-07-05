public with sharing class POC_PKCE {

    public String origin {get{ return Url.getOrgDomainUrl().toExternalForm().split('.my.')[0].toLowerCase();} set;} // origin getter/ setter for vf page
    public String resp { get; set; } // response getter/ setter for vf page

    //if we need to store the response in cache we can use this method
    public void setResponse(){
        System.debug('>>> Response from Azure AD: ' + resp);
    }

    @AuraEnabled(Cacheable=true)
    public static String getVFOrigin() {
        Organization org = [SELECT InstanceName, IsSandbox, OrganizationType FROM Organization LIMIT 1];
        String baseURL = Url.getOrgDomainUrl().toExternalForm().split('.my.')[0].toLowerCase();
        String vfOrigin;
        if(org.IsSandbox){
            vfOrigin = baseURL + '--c.' + org.InstanceName.toLowerCase() + '.visual.force';
        }else{
            vfOrigin = baseURL + '--c.' + 'visualforce';
        }
        return vfOrigin;
    }
}