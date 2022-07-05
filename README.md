# PKCE Proof of Concept

## Instructions for Setup
1. Deploy the source files in this repo to your org.
2. For the custom setting, CS AzurePKCE, set up your hierarchical custom settings with the authority url and client id from the Azure app.
- The authority URL should be "https://login.microsoftonline.com/{tenant-id}". The tenant id can be found on the Azure app's overview page.
- The client id should be the application (client) id from the Azure app's overview page.
3. Set up the visualforce page as an allowed redirect URI in the Azure app. Go to "Authentication", then "Single-page Application" and add a URI. The URI should be "https://{sf-domain}.visualforce.com/apex/POCPKCE". You can also get this full domain from the URL in salesforce by previewing the visualforce page in setup. Be aware that sandboxes have a format of "visual.force.com", not "visualforce.com".
4. Place the lwc on any UI where the user needs to go through a PKCE auth flow. This flow will automatically be initiated if there is no auth token previously stored in session storage.
5. Provide access (permission set or profiel) to the visualforce page and apex class for any user that needs it.

## How it works
When a user loads the lwc component (pocPKCE) on a page, the component checks to see if the Azure access token has already been retrieved and is stored in sessionStorage. If there is already a token in session storage, then nothing else happens and the user can work with the existing token. 

If there is no token, however, then the lwc will render the visualforce page (POCPKCE) in an iframe on the lwc and the page will automatically load the MSAL auth script from static resources. The lwc then calls the visualforce page to instruct it to begin the auth process. The visualforce page uses the msal library to create a popup and the user walks through the auth process to authenticate themselves to the Azure app. If successful, the Azure app will return an auth response with an access token.

The script on the visualforce page can then do whatever it needs to do with the response. The "setResponseJS" method in the visualforce script provides a way to send the response information the apex controller (POC_PKCE). The visualforce script can also post a message with the response information to the parent lwc. In this example we are posting the access token to the parent lwc.

After the visualforce page posts the message with the access token to the lwc, the lwc handles the access token and stores it in sessionStorage. The lwc also parses the token to extract the device id, and makes a callout to the Azure app to retrieve the workstation id. When the workstation id is retrieved, it is also stored in sessionStorage.

The user will now be fully authenticated, have both the access token and workstation id to use with Salesforce.

