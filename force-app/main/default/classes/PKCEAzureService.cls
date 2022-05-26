public with sharing class PKCEAzureService {

    @AuraEnabled
    public static String callAuthProvider() {
        try{
            String token = Auth.AuthToken.getAccessToken('0SO170000004RC3', 'PKCEAzure2');
            System.debug('auth token ::: ' + token);
            return token;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getCachedToken() {
        try{
            String cachePartition = 'local.Bedrock'; //I used a local cache partition in this example, change this to the correct partition needed
            String hashKey = System.UserInfo.getUserId() + 'PKCEToken'; //custom hash key of user id + PKCEToken, stored in cache by the auth provider
            String token = (String)Cache.Org.getPartition(cachePartition).get(hashKey); //return the token that was stored in the cache by the auth provider
            System.debug('cached token ::: ' + token);
            return token;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}