public with sharing class PKCEAzureService {

    @AuraEnabled
    public static String callAuthProvider() {
        try{
            String token = Auth.AuthToken.getAccessToken('0SO54000000CnoC', 'PKCEAzure2');
            System.debug('### token ### ' + token);
            return token;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}