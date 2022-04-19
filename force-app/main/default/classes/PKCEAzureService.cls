public with sharing class PKCEAzureService {

    @AuraEnabled
    public static String getCachedToken() {
        try{
            String cachePartition = 'local.Bedrock'; ////TODO change this to your partition
            String hashKey = System.UserInfo.getUserId() + 'PKCEToken'; //custom hash key of user id + PKCEToken, stored in cache by the auth provider
            return (String)Cache.Org.getPartition(cachePartition).get(hashKey); //return the token that was stored in the cache by the auth provider
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}