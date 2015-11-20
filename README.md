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
##To add new contacts  
``Config-GSharedContacts.sh [METHOD:new] [FULL_PATH_TO_CLIENT_SECRETS.JSON] [FULL_PATH_TO_CONTACTS_CSV_FILE] [DOMAIN_NAME]``  

Where:
* [METHOD:new,edit,delete] is the action to be used, right now only new/delete are functional.
* [FULL_PATH_TO_CLIENT_SECRETS.JSON] is the full path to the client_secrets.json file, including the file name.
* [FULL_PATH_TO_CONTACTS_CSV_FILE] is the full file name and path for the CSV file that holds the contacts you want to add.
* [DOMAIN_NAME] is the domain name which we want to add the contacts on it  

Example:  
``Config-GSharedContacts new ~/Downloads/client_secrets.json ~/Documents/contacts.csv example.com``  

## To edit contacts  

## To delete contacts
**To delete ALL contacts:**  
``Config-GSharedContacts.sh [METHOD:delete] [FULL_PATH_TO_CLIENT_SECRETS.JSON] all [DOMAIN_NAME]``  

Where:
* [METHOD:delete] is the action to be used (delete), right now only new/delete are functional.
* [FULL_PATH_TO_CLIENT_SECRETS.JSON] is the full path to the client_secrets.json file, including the file name.
* [DOMAIN_NAME] is the domain name which we want to add the contacts on it  

Example:  
``Config-GSharedContacts delete ~/Downloads/client_secrets.json all example.com``  

**To delete a group of contacts:**  
``Config-GSharedContacts.sh [METHOD:delete] [FULL_PATH_TO_CLIENT_SECRETS.JSON] [FULL_PATH_TO_CONTACTS_CSV_FILE] [DOMAIN_NAME]``  

Where:
* [METHOD:delete] is the action to be used (delete), right now only new/delete are functional.
* [FULL_PATH_TO_CLIENT_SECRETS.JSON] is the full path to the client_secrets.json file, including the file name.
* [FULL_PATH_TO_CONTACTS_CSV_FILE] is the full file name and path for the CSV file that holds the contacts you want to delete.
* [DOMAIN_NAME] is the domain name which we want to add the contacts on it  

Example:  
``Config-GSharedContacts delete ~/Downloads/client_secrets.json ~/Documents/contacts.csv example.com``  

### Notes on the CSV file for deleting a group of contacts:  
It is enough to have one column in the CSV file for the delete operation, this column should be the value of the ID for each contact. This should retrieved using Get-GSharedContacts.sh script.
