#!/bin/bash
# this script will generate a sample CSV file filled with headers (headers should be removed when using the sample), you can use the generated template to fill the CSV contacts to upload them to Google apps
echo -e "Generating template file"
cat <<EOF > GSharedContactsTemplate.csv
givenName,familyName,fullName,notes,eaddress,displayName,eaddress2,phoneNumber,phoneNumber2,imaddress,city,street,region,postcode,country,formattedAddress
EOF
echo -e "Done, file generated (file name: GSharedContactsTemplate.csv)"
