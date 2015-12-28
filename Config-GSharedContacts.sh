#!/bin/bash
# This shell script provied as is, and I cannot provide any warranty or liability if it was used in the wrong way.
# I will try to keep a steady improvements on this script, and everyone is welcome to take it and change it the way they see more useful to them.
# This started as a very basic script to add shared contacts for Google apps, but it will get more features added by time, as I work on them slowly due to my real life obligations.
# -------------------------------------------------------------
echo -e "\n---------------------------------------------------------------------------------------------------------"
echo -e "-----------------   Config-GSharedContacts (Version 0.0.3-alpha) - saleh@is-linux.com   ------------------"
echo -e "---------------------------------------------------------------------------------------------------------\n"
echo -e "Preparing the required variables..."
echo -e "We will collect the following information:"
echo -e "    1. Client ID from the developer console, which you created earlier (if you read the README file)."
echo -e "    2. Client Secret from the developer console, which you created earlier (if you read the README file)."
echo -e "    3. Full path to the CSV file that contains the contacts you want to add to Google apps."
echo -e "=========================================================================================================\n"
echo -e "Checking the supplied arguments..."
if [ $# -eq 0 ]; then
    #here we have no arguments at all
    echo ""
    echo "ERROR: No parameters were supplied, cannot continue!"
    echo "Usage instructions:"
    echo "Config-GSharedContacts [METHOD:new,edit,delete] [FULL_PATH_TO_CLIENT_SECRETS.JSON] [FULL_PATH_TO_CONTACTS_CSV_FILE] [DOMAIN_NAME]"
    exit 1
fi
if [ $# -gt 4 ]; then
    #here we have more arguments than we need
    echo ""
    echo "ERROR: Too many parameters were supplied, cannot continue!"
    echo "Usage instructions:"
    echo "Config-GSharedContacts [METHOD:new,edit,delete] [FULL_PATH_TO_CLIENT_SECRETS.JSON] [FULL_PATH_TO_CONTACTS_CSV_FILE] [DOMAIN_NAME]"
    exit 1
fi
if [ $# -lt 4 ]; then
    #here we have less arguments than we need
    echo ""
    echo "ERROR: Missing parameters"
    echo "Usage instructions:"
    echo "Config-GSharedContacts [METHOD:new,edit,delete] [FULL_PATH_TO_CLIENT_SECRETS.JSON] [FULL_PATH_TO_CONTACTS_CSV_FILE] [DOMAIN_NAME]"
    exit 1
fi
#
# Checking the supplied method (currently, only NEW is supported
case $1 in
    #method "new"
    "new") echo "OK - Method (new) selected."
        method=1
	;;
    "update") echo "OK (not functioning yet) - Method (update) selected."
	method=2
	;;
    "delete") echo "OK - Method (delete) selected."
	method=3
	;;
    *) echo "ERROR: Could not determine the selected method, please check the supplied parameters."
       exit 1
       ;;
esac
#
# checking now for the JSON file if it is existing or not
jsonFile=$2
if [ ! -f $jsonFile ]; then
    # The JSON file is not available or wrong parameter was supplied
    echo "ERROR: Either JSON file not exists or wrong parameter supplied."
    exit 1
fi
#
#start working on the jSON file
echo "OK - Found JSON file, will start pulling data from it."
jsonData=`jq '.installed.client_id' $jsonFile`
clientID="${jsonData%\"}"
clientID="${clientID#\"}"
#client ID line
echo "     Retrieved client ID: $clientID"
#
jsonData=`jq '.installed.client_secret' $jsonFile`
clientSecret="${jsonData%\"}"
clientSecret="${clientSecret#\"}"
#client secret line
echo "     Retrieved client secret:" $clientSecret
#
#
#
#checking domain name
domainName=$4
echo -e "OK - Domain name is: $domainName"
#
#Working on the authorizatio URL
echo -e "=========================================================================================================\n"
echo -e "Creating the authorization URL"
authURI="https://accounts.google.com/o/oauth2/auth?client_id=$clientID&redirect_uri=urn:ietf:wg:oauth:2.0:oob&response_type=code&scope=https://www.google.com/m8/feeds/"
echo -e "Please open your web browser and follow these instructions to grant us the required permissions:"
echo -e "    1. Copy the below link and once the page opens, sign in with your super admin account and grant the required permissions."
echo -e "    2. You will get an authorization code back from the page, please paste it here and press Enter/Return.\n"
echo -e "Copy below link:"
echo -e $authURI "\n"
#
#
#need to get the authorization code from user now
read -p "Please enter/paste the autorization code you got from the previous link: " authCode
#
#sending authorization code back and getting our token
tokenRequest=`curl -s -i -X POST https://www.googleapis.com/oauth2/v3/token -H "Content-Type: application/x-www-form-urlencoded" --data "code=$authCode&client_id=$clientID&client_secret=$clientSecret&redirect_uri=urn:ietf:wg:oauth:2.0:oob&grant_type=authorization_code"`
#
#reading the reeived access token and putting everything in one file
cat << EOF > tempToken.json
$tokenRequest
EOF
#
#extracing the line with the access token and put it in a new file with proper JSON formatting
tokenData=`cat tempToken.json | grep -E "access_token"`
cat << EOF  > token.json
{"token":{$tokenData"end":"end"}}
EOF
#
#now extract the token data and start use it.
APIToken=`jq '.token.access_token' token.json`
accessToken="${APIToken%\"}"
accessToken="${accessToken#\"}"
#
#Retrieved the token data
echo -e ""
echo -e "Received access token: $accessToken"
echo -e "=========================================================================================================\n\n"
#
#
#checking for the method we received from the user
case $method in
    1) # here is the function for method new
        #
        #checking for the CSV file now
        CSVFile=$3
        if [ ! -f $CSVFile ]; then
            # The CSV file is either not existent or was supplied wrong.
            echo "ERROR: Either CSV file not exists or wrong parameter supplied."
            exit 1
        fi
        echo -e "OK - Found CSV file, but did not read its contents yet."
        echo -e "Reading contents of CSV file and sending requests to Google API"
        counter=1
        while IFS=, read givenName familyName fullName notes eaddress displayName eaddress2 phoneNumber phoneNumber2 imaddress city street region postcode country formattedAddress
        do
            #checking for empty fields
            if [ ! "$givenName" ]; then
                echo -e "ERROR - Value 'givenName' cannot be null, please put a value in that field then run the script again"
                exit 1
            fi
            if [ ! "$familyName" ]; then
                echo -e "ERROR - Value 'familyName' cannot be null, please put a value in that field then run the script again"
                exit 1
            fi
            if [ ! "$fullName" ]; then
                echo -e "ERROR - Value 'fullName' cannot be null, please put a value in that field then run the script again"
                exit 1
            fi
            if [ ! "$eaddress" ]; then
                echo -e "ERROR - Value 'eaddress' cannot be null, please put a value in that field then run the script again"
                exit 1
            fi
            if [ ! "$phoneNumber" ]; then
                echo -e "ERROR - Value 'phoneNumber' cannot be null, please put a value in that field then run the script again"
                exit 1
            fi
            if [ ! "$phoneNumber2" ]; then
                echo -e "ERROR - Value 'phoneNumber2' cannot be null, please put a value in that field then run the script again"
                exit 1
            fi
            if [ ! "$city" ]; then
                echo -e "ERROR - Value 'city' cannot be null, please put a value in that field then run the script again"
                exit 1
            fi
            if [ ! "$street" ]; then
                echo -e "ERROR - Value 'street' cannot be null, please put a value in that field then run the script again"
                exit 1
            fi
            if [ ! "$region" ]; then
                echo -e "ERROR - Value 'region' cannot be null, please put a value in that field then run the script again"
                exit 1
            fi
            if [ ! "$postcode" ]; then
                echo -e "ERROR - Value 'postcode' cannot be null, please put a value in that field then run the script again"
                exit 1
            fi
            currentContact="Adding new shared contact [$counter]... $fullName,$eaddress,$eaddress2."
            echo -ne $currentContact
            newContact=`curl -s -i -X POST https://www.google.com/m8/feeds/contacts/$domainName/full -H "Gdata-version: 3.0" -H "Content-Type: application/atom+xml" -H "Authorization: Bearer $accessToken" --data "<atom:entry xmlns:atom='http://www.w3.org/2005/Atom'
        xmlns:gd='http://schemas.google.com/g/2005'>
    <atom:category scheme='http://schemas.google.com/g/2005#kind'
        term='http://schemas.google.com/contact/2008#contact' />
    <gd:name>
        <gd:givenName>$givenName</gd:givenName>
        <gd:familyName>$familyName</gd:familyName>
        <gd:fullName>$fullName</gd:fullName>
    </gd:name>
    <atom:content type='text'>$notes</atom:content>
    <gd:email rel='http://schemas.google.com/g/2005#work'
        primary='true'
        address='$eaddress' displayName='$displayName' />
    <gd:email rel='http://schemas.google.com/g/2005#home'
        address='$eaddress2' />
    <gd:phoneNumber rel='http://schemas.google.com/g/2005#work'
        primary='true'>
        $phoneNumber
    </gd:phoneNumber>
    <gd:phoneNumber rel='http://schemas.google.com/g/2005#home'>
        $phoneNumber2
    </gd:phoneNumber>
    <gd:im address='$imaddress'
        protocol='http://schemas.google.com/g/2005#GOOGLE_TALK'
        primary='true'
        rel='http://schemas.google.com/g/2005#home' />
    <gd:structuredPostalAddress
        rel='http://schemas.google.com/g/2005#work'
        primary='true'>
        <gd:city>$city</gd:city>
        <gd:street>$street</gd:street>
        <gd:region>$region</gd:region>
        <gd:postcode>$postcode</gd:postcode>
        <gd:country>$country</gd:country>
        <gd:formattedAddress>
        $formattedAddress
        </gd:formattedAddress>
    </gd:structuredPostalAddress>
    </atom:entry>"`
            #
            #now getting the status of the latest request to display it
            cat <<EOF > newContact.temp
$newContact
EOF
            cat <<EOF >> output.temp
$newContact
EOF
            status=`cat newContact.temp | grep -E 'HTTP/1.1 201 Created'`
            if [ ! -z "$status" -a "$status" != " " ]; then
                echo -e " [OK] - [$status]"
            else
                echo -e " ================== ERROR adding contact! - [$status]"
                exit 1
            fi
            let counter=$counter+1
        done < $CSVFile
        echo -e "\n"
        echo -e "========================"
        echo -e "Finished adding contacts... cleaning up and ending"
        rm -f tempToken.json
        rm -f token.json
        rm -f newContact.temp
    ;; #end of new method
    #
    #
    #
    #
    2) #here is the update method
    ;; #end of update method
    #
    #
    #
    #
    3) #here is the delete method
        fileName=$3
        #checking the value of file name, we need to knwo if the suer suppolied an 'all' so it means he want to delete all contacts.
        #if he did not supply 'all', then we need to check if the file is existent and in correct format
        case $fileName in
            "all") #here the user supplied an 'all', it means we will delete all shared contacts
                echo -en "\nAn 'all' switch is detected in place of file name!\n"
                read -p "This will cause to delete ALL contacts. Do you want to proceed? (y/n): " answer
                case $answer in
                    "y") # we want to proceed deleting all contacts
                        # we will delete all contacts here
                        #
                        echo -en "\nProceeding to delete ALL shared contacts\n"
                        status=0
                        contactCounter=1
                        requestURL="https://www.google.com/m8/feeds/contacts/$domainName/full"
                        #
                        #
                        echo "Log for curl" > Config-GSharedContacts-Delete.log
                        while [ $status -ne 1 ]; do
                            echo `curl -i -s $requestURL -H "Authorization: Bearer $accessToken" > Config-GSharedContacts-Delete.output`
                            data=`cat Config-GSharedContacts-Delete.output`
                            cat <<EOF >> Config-GSharedContacts-Delete.log
$data
EOF
                            #
                            #read the output and extract the id value
                            readAtom () {
                                local IFS=\>
                                read -d \< ENTITY CONTENT
                            }
                            while readAtom; do
                                if [[ $ENTITY = "id" ]]; then
                                    ExtraURL="http://www.google.com/m8/feeds/contacts/$domainName/base/"
                                    IDContent=${CONTENT#$ExtraURL}
                                    noLine=0
                                    if [[ $IDContent == "$domainName" ]]; then
                                        noLine=1
                                    fi
                                    if [[ $noLine != 1 ]]; then
                                        echo -en "$IDContent\n"
                                    fi
                                fi
                            done < Config-GSharedContacts-Delete.output >> tempContactList.output
                            #
                            #checking to see if we have more pages in the returned result
                            nextPage=$(cat Config-GSharedContacts-Delete.output | grep -Po "<link rel='next' type='application\/atom\+xml' href(.*?)\/>")
                            if [[ ! "$nextPage" ]] ; then
                                #here we don't have a next page link anymore.
                                status=1
                            else
                                nextPageLink=$(echo -en $nextPage | grep -Po "https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#;?&=\/]*)(index)([-a-zA-Z0-9@:%_\+.~#;?&=\/]*)")
                                requestURL=$nextPageLink
                                status=0
                            fi
                        done
                        while IFS=, read id; do
                            curl -s --request DELETE "https://www.google.com/m8/feeds/contacts/$domainName/full/$id" -H "Authorization: Bearer $accessToken" -H "If-Match: *"
                            echo -en "Deleting contact [$contactCounter]...\n"
                            let contactCounter=$contactCounter+1
                        done < tempContactList.output
                        echo -e "\n"
                        echo -e "========================"
                        echo -e "Finished deleting contacts... cleaning up and ending"
                        rm -f tempToken.json
                        rm -f token.json
                        rm -f tempContactList.output
                        rm -f Config-GSharedContacts-Delete.output
                    ;;
                    #
                    #
                    "n") #we do not want to delete all contacts
                        echo -en "Operation to delete all contacts cancelled based on user input. Exiting.\n"
                        exit 1
                    ;;
                    #
                    #
                    *) #the user did not answer yes or no, so we will assume it as a no.
                        echo -en "User did not answer 'y' or 'n', so we will assume it as 'n'\n"
                        echo -en "Operation to delete all contacts cancelled based on user input. Exiting.\n"
                        exit 1
                    ;;
                    #
                    #
                esac
            ;;
            #
            #
            *) #here the user did not supply 'all', so we will check for the file he supplied now
            
            ;;
        esac
    ;; #end of delete method
esac
