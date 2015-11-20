# Add-GSharedContacts
Current version: 0.0.2alpha
This small shell script will allow the adding, editing and deleting of domain shared contacts on Google apps...

# Prerequisites
* Any Linux distribution
* cURL package (for sending GET, POST requests to Google servers)
* jq package (for working with JSON files)

# Documentation and support
[Please visit the wiki page](https://github.com/salehram/Add-GSharedContacts/wiki) for information on the prerequisites and CSV file formatting, and I am looking forward to read the feedback and address any issue in the operation of this little script

# Usage
**To add new contacts:**  
``Config-GSharedContacts.sh [METHOD:new,edit,delete] [FULL_PATH_TO_CLIENT_SECRETS.JSON] [FULL_PATH_TO_CONTACTS_CSV_FILE] [DOMAIN_NAME]``  

Where:
* [METHOD:new,edit,delete] is the action to be used, right now only new/delete are functional.
* [FULL_PATH_TO_CLIENT_SECRETS.JSON] is the full path to the client_secrets.json file, including the file name.
* [FULL_PATH_TO_CONTACTS_CSV_FILE] is the full file name and path for the CSV file that holds the contacts you want to add.
* [DOMAIN_NAME] is the domain name which we want to add the contacts on it  

Example:  
Config-GSharedContacts new ~/Downloads/client_secrets.json ~/Documents/contacts.csv example.com
