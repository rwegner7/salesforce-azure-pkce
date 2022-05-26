global class PKCEAzure extends Auth.AuthProviderPluginClass {

    private String clientId;
    private String clientSecret;
    private String accessTokenUrl;
    private String authorizationUrl;
    private String scope;
    private String userInfoUrl;
    private String redirectUri;
    private final static String cachePartition = 'local.Bedrock'; //change this to your partition
    String codeVerifier = generateRandomString(34);
    Blob sha256 = Crypto.generateDigest('SHA-256', Blob.valueOf(codeVerifier));
    String codeChallenge = base64EncodeURL(sha256);

    // Return the custom metadata storing the api credentials and other details
    global String getCustomMetadataType() {
        return 'AuthProviderCredential__mdt';
    }

    // The code challenge must be base64Url-encoded
    private static String base64EncodeURL(Blob input){
        String output = EncodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while ( output.endsWith('=')){
            output = output.substring(0,output.length()-1);
        }
        return output;
    }

    // Generate a code verifier using a random string
    private static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }

    // Initiate the authorization code flow
    global PageReference initiate(Map<String, String> authProviderConfiguration, String stateToPropagate) {

        //cache the current user id and the code verifier, using the state as a hash key. these will be used for the second leg of the auth journey
        String hashKey = stateToPropagate.replaceAll('[^a-zA-Z0-9]', '').substring(0,49); //the hash key cannot be longer than 50 characters, and must be alphanumeric
        List<String> cachedValues = new List<String>{System.UserInfo.getUserId(),codeVerifier}; //the cached values are stored as a list of strings, user id is in index 0, code verifier is in index 1
        Cache.Org.getPartition(cachePartition).put(hashKey, cachedValues, 300); //store values in cache partition

        //build the url to get the auth code
        clientId = authProviderConfiguration.get('Client_Id__c');
        authorizationUrl = authProviderConfiguration.get('Authorization_URL__c');
        scope = authProviderConfiguration.get('Scope__c');
        redirectUri = authProviderConfiguration.get('Redirect_URI__c');
        String url = authorizationUrl+'?client_id='+clientId+'&response_type=code&scope='+scope+'&redirect_uri='+redirectUri
                +'&code_challenge_method=S256&code_challenge='+codeChallenge+'&state='+stateToPropagate;
        System.debug('auth url ::: ' + url);
        //authenticate the user, the auth code is returned in the callback method below
        return new PageReference(url);
    }

    //handle the callback from auth code flow
    global Auth.AuthProviderTokenResponse handleCallback(Map<String, String> authProviderConfiguration, Auth.AuthProviderCallbackState state) {

        clientId = authProviderConfiguration.get('Client_Id__c');
        clientSecret = authProviderConfiguration.get('Client_Secret__c');
        scope = authProviderConfiguration.get('Scope__c');
        redirectUri = authProviderConfiguration.get('Redirect_URI__c');
        accessTokenUrl = authProviderConfiguration.get('Access_Token_URL__c');

        //exchange the auth code for an access token, passing the code verfier
        Map<String,String> queryParams = state.queryParameters;
        String code = queryParams.get('code');
        String sfdcState = queryParams.get('state');
        String hashKey = sfdcState.replaceAll('[^a-zA-Z0-9]', '').substring(0,49); //get the state from the callback to determine the hash key
        String[] cachedValues = (List<String>)Cache.Org.getPartition(cachePartition).get(hashKey);
        String requestBody = 'grant_type=authorization_code&client_id='+clientId+'&client_secret='+clientSecret+'&code='+code
                +'&redirect_uri='+redirectUri+'&state='+sfdcState +'&code_verifier='+cachedValues[1];

        System.debug('request body ::: ' + requestBody);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(accessTokenURL);
        req.setHeader('Accept','application/json');
        req.setMethod('POST');
        req.setBody(requestBody);

        Http http = new Http();
        HttpResponse res = http.send(req);
        String responseBody = res.getBody();
        System.debug('response body ::: ' + responseBody);
        //parse the response from the auth code
        AzureResponse response = (AzureResponse) JSON.deserialize(responseBody, AzureResponse.class);

        //store the access token in the cache, using the user id and PKCEToken as the key
        hashKey = cachedValues[0] + 'PKCEToken';
        Cache.Org.getPartition(cachePartition).put(hashKey, response.access_token, 1800);

        return new Auth.AuthProviderTokenResponse('PKCEAzure', response.access_token, null, sfdcState);
    }

    // This method is responsible to get the user information used for authentication from the external api, generally not used for Azure
    global Auth.UserData getUserInfo(Map<String, String> authProviderConfiguration, Auth.AuthProviderTokenResponse response) {
        userInfoUrl = authProviderConfiguration.get('User_Info_URL__c');
        String token = response.oauthToken;
        String userId, fullName, firstName, lastName, locale, loginURL;

        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setEndpoint(userInfoUrl);
        req.setMethod('GET');
        req.setTimeout(10000);
        String responseBody;

        Http h = new Http();
        try {
            HttpResponse res = h.send(req);
            System.debug('status ' + res.getStatusCode());
            if(res.getStatusCode() == 200) {
                responseBody = res.getBody();
                AzureUserInfoResponse infoApiResponse = (AzureUserInfoResponse) JSON.deserialize(responseBody, AzureUserInfoResponse.class);

                String[] names = infoApiResponse.name.split(' ');
                userId = infoApiResponse.aio;
                fullName = infoApiResponse.name;
                if(names.size()>=2) {
                    firstName = names[0];
                    lastName = names[1];
                }
            }
        }
        catch(Exception ex) {
            System.debug(ex.getMessage());
        }

        locale = 'en-au';
        loginURL = authProviderConfiguration.get('Login_URL__c');

        return new Auth.UserData(
                userId,
                firstName,
                lastName,
                fullName,
                null,
                null,
                userId,
                locale,
                'Azure PKCE',
                loginURL,
                null
        );
    }

    // wrapper class to handle User Info API response
    public class AzureUserInfoResponse {
        public String upn;
        public String uti;
        public String aio;
        public String name;
        public String oid;
        public String unique_name;
    }

    // wrapper class to handle Access Token API response
    public class AzureResponse {
        public String access_token;
        public String id_token;
        public String token_type;
        public String scope;
        public String expires_in;
    }
}