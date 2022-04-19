# salesforce-azure-pkce
PKCE OIDC Auth Flow from Salesforce

**Instructions for Setup**

1. Set up PKCE in Azure App.
	1. Go to your application in Azure that you want to authenticate against. Go to the section in the app called 'Certificates & Secrets' (left panel), then go to Client secrets and click the button 'New client secret'.
	2. Enter a description, and set the expiration date to your desired value.
	3. Azure will give you the client id and client secret. Copy and store this information as it won't be available again.
2. Get the Directory Id in Azure App.
	1. Go to your application in Azure that you want to authenticate against. Go to the section in the app called 'Overview' (left panel).
	2. Copy the value for Directory (tenant) ID.
3. Create Custom Metadata Type with Azure values.
	1. Clone this git repo to your desktop. Go to force-app package in your local repo, and go to the subfolder for customMetadata.
	2. Open the customMetadata record called 'AuthProviderCredential.PKCEAzure.md-meta' in a text editor.
	3. Everywhere you see '<Directory ID>', replace it with the directory id in step 2.
	4. Replace '<client id>' with the client id from step 1.
	5. Replace '<client secret>' with the client secret from step 1.
	6. Replace '<domain>' with the domain of your salesforce org (e.g. 'my-awesome-org').
	7. Replace '<name of your auth provider>' with whatever name you want to give your auth provider. I used 'PKCEAzure'.
4. Deploy base metadata in Salesforce.
	1. Deploy the force-app folders for objects, customMetadata, and remoteSiteSettings to your Salesforce org.
5. Update Apex Class records for org cache.
	1. Go to force-app package in your local repo, and go to the subfolder for classes.
	2. Open the file 'PKCEAzure'. On line 10, change the cache partition to one that matches your org. More information on Platform Cache can be found here: https://trailhead.salesforce.com/content/learn/modules/platform_cache/platform_cache_get_started
	3. Open the file 'PKCEAzureService'. On line 6, change the cache partition to one that matches your org. 
	4. Deploy the classes folder to your Salesforce org.
6. Configure Auth Provider (NOTE: This step can be skipped if you prefer to do this manually, see this link: 'https://help.salesforce.com/s/articleView?id=sf.sso_provider_plugin_custom.htm&type=5');
	1. Open the authProvider record called 'PKCEAzure.authprovider-meta'.
	2. Where it says 'TODO update this with your user name', add the user name of someone in the org that has full admin rights.
	3. Deploy the authProvider folder to your org.
	4. After the authProvider is deployed, go to the record in Salesforce (Setup > Auth. Providers > PKCEAzure)
	5. Make sure the authProvider matches the custom metadata records. Update the fields for Access Token URL, Authorization URL, Client Id, Client Secret, Redirect URI, Scope, and User Info URL. These values can all be copied from the custom metadata record.
	6. When you save the record, Salesforce will present you with Auth URLs in the section 'Salesforce Configuration' at the bottom of the page. Copy the values for Callback URL and OAuth-Only Initialization URL.
7. Set up Callback in Azure.
	1. Go to your application in Azure that you want to authenticate against. Go to the section in the app called 'Authentication' (left panel).
	2. Under the section 'Web', click 'Add URI'. Paste the value for Callback URL from step 6 and save.
8. Configure LWC in Salesforce (this component will initialize the auth from the UI).
	1. Go to force-app package in your local repo, and go to the subfolder for lwc.
	2. Open the file 'azurePKCE.js'. On line 9, update the AUTH_URL to match the OAuth-Only Initialization URL from step 6. Save.
	3. Deploy the lwc folder to your org.
	4. In Salesforce, go to any flexipage that you want to add the lwc component to (Click the gear icon > Edit Page). Drag the lwc component Azure PKCE onto the page. Save and exit.
	5. Refresh the browser page, you should see an access token returned in the component that you added on the page.