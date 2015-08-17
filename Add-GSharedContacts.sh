#!/bin/bash
# This shell script provied as is, and I cannot provide any warranty or liability if it was used in the wrong way.
# I will try to keep a steady improvements on this script, and everyone is welcome to take it and change it the way they see more useful to them.
# This started as a very basic script to add shared contacts for Google apps, but it will get more features added by time, as I work on them slowly due to my real life obligations.
# -------------------------------------------------------------
echo -e "Add-GSharedContacts (Version 0.0.1alpha) - saleh@is-linux.com\n"
echo -e "Preparing the required variables..."
echo -e "========================================================================================================="
echo -e "We will collect the following information:"
echo -e "    1. Client ID from the developer console, which you created earlier (if you read the README file)."
echo -e "    2. Client Secret from the developer console, which you created earlier (if you read the README file)."
echo -e "    3. Full path to the CSV file that contains the contacts you want to add to Google apps."
echo -e "=========================================================================================================\n"
echo -e "Checking the supplied arguments..."
if [ $# -eq 0 ]; then
    echo ""
    echo "ERROR: No parameters were supplied, cannot continue!"
    echo "Usage instructions:"
    echo "Add-GSharedContacts [METHOD:new,edit,delete] [FULL_PATH_TO_CLIENT_SECRETS.JSON] [FULL_PATH_TO_CONTACTS_CSV_FILE] [DOMAIN_NAME]"
    exit 1
fi
if [ $# -gt 4 ]; then
    echo ""
    echo "ERROR: Too many parameters were supplied, cannot continue!"
    echo "Usage instructions:"
    echo "Add-GSharedContacts [METHOD:new,edit,delete] [FULL_PATH_TO_CLIENT_SECRETS.JSON] [FULL_PATH_TO_CONTACTS_CSV_FILE] [DOMAIN_NAME]"
    exit 1
fi
if [ $# -lt 4 ]; then
   echo ""
   echo "ERROR: Missing parameters"
   echo "Usage instructions:"
   echo "Add-GSharedContacts [METHOD:new,edit,delete] [FULL_PATH_TO_CLIENT_SECRETS.JSON] [FULL_PATH_TO_CONTACTS_CSV_FILE] [DOMAIN_NAME]"
   exit 1
fi
# Checking the supplied method (currently, only NEW is supported
case $1 in
    #method "new"
    "new") echo "OK - Method (new) selected."
	   method=1
	   ;;
    #method "update"
    "update") echo "OK (not functioning yet) - Method (update) selected."
	      method=2
	      ;;
    #method "delete"
    "delete") echo "OK (not functioning yet) - Method (delete) selected."
	      method=3
	      ;;
    #unable to determine method
    *) echo "ERROR: Could not determine the selected method, please check the supplied parameters."
       exit 1
       ;;
esac
# checking now for the JSON file if it is existing or not
jsonFile=$2
if [ ! -f $jsonFile ]; then
    # The JSON file is not available or wrong parameter was supplied
    echo "ERROR: Either JSON file not exists or wrong parameter supplied."
    exit 1
fi
#start working on the jSON file
echo "OK - Found JSON file, will start pulling data from it."
jsonData=`jq '.installed.client_id' $jsonFile`
clientID="${jsonData%\"}"
clientID="${clientID#\"}"
#client ID line
echo "     Retrieved client ID: $clientID"
jsonData=`jq '.installed.client_secret' $jsonFile`
clientSecret="${jsonData%\"}"
clientSecret="${clientSecret#\"}"
#client secret line
echo "     Retrieved client secret:" $clientSecret
#checking for the CSV file now
CSVFile=$3
if [ ! -f $CSVFile ]; then
    # The CSV file is either not existent or was supplied wrong.
    echo "ERROR: Either CSV file not exists or wrong parameter supplied."
    exit 1
fi
echo -e "OK - Found CSV file, but did not read its contents yet."
#checking domain name
domainName=$4
echo -e "OK - Domain name is: $domainName"
echo -e "=========================================================================================================\n"
echo -e "Creating the authorization URL"
authURI="https://accounts.google.com/o/oauth2/auth?client_id=$clientID&redirect_uri=urn:ietf:wg:oauth:2.0:oob&response_type=code&scope=https://www.google.com/m8/feeds/"
echo -e "Please open your web browser and follow these instructions to grant us the required permissions:"
echo -e "    1. Copy the below link and once the page opens, sign in with your super admin account and grant the required permissions."
echo -e "    2. You will get an authorization code back from the page, please paste it here and press Enter/Return.\n"
echo -e "Copy below link:"
echo -e $authURI "\n"
#need to get the authorization code from user now
read -p "Please enter/paste the autorization code you got from the previous link: " authCode
#sending authorization code back and getting our token
tokenRequest=`curl -s -i -X POST https://www.googleapis.com/oauth2/v3/token -H "Content-Type: application/x-www-form-urlencoded" --data "code=$authCode&client_id=$clientID&client_secret=$clientSecret&redirect_uri=urn:ietf:wg:oauth:2.0:oob&grant_type=authorization_code"`
#reading the reeived access token and putting everything in one file
cat << EOF > tempToken.json
$tokenRequest
EOF
#extracing the line with the access token and put it in a new file with proper JSON formatting
tokenData=`cat tempToken.json | grep -E "access_token"`
cat << EOF  > token.json
{"token":{$tokenData"end":"end"}}
EOF
#now extract the token data and start use it.
APIToken=`jq '.token.access_token' token.json`
accessToken="${APIToken%\"}"
accessToken="${accessToken#\"}"
#rm -f tempToken.json
echo -e ""
echo -e "Received access token: $accessToken"
echo -e "=========================================================================================================\n\n"
echo -e "Reading contents of CSV file and sending requests to Google API"
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
    echo "Adding new shared contact... $givenName,$familyName,$fullName,$notes,$eaddress,$displayName,$eaddress2,$phoneNumber,$phoneNumber2,$imaddress,$city,$street,$region,$postcode,$country,$formattedAddress."
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
   # status=$newContact | grep -E 'HTTP/1.1'
    cat <<EOF > newContact.temp
$newContact
EOF
cat <<EOF >> output.temp
$newContact
EOF
    status=`cat newContact.temp | grep -E 'HTTP/1.1 201 Created'`
    if [ ! -z "$status" -a "$status" != " " ]; then
        echo -e "[OK] - [$status]"
    else
        echo "================== ERROR adding contact! - [$status]"
        exit 1
    fi 
done < $CSVFile
echo -e "\n"
echo -e "\n"
echo -e "\n"
echo -e "========================"
echo -e "Finished adding contacts... cleaning up and ending"
rm -f tempToken.json
rm -f token.json
rm -f newContact.temp
