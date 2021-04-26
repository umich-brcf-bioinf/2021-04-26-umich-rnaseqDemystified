#!/bin/bash

set -ue

date
export USER_PASSWD_FILE=$1
export OUTPUT_DIR=$2
export SERVER=$3

users=()
missing_users=()
declare -A user_passwd
declare -A user_email
declare -A user_name
while IFS==$'\t' read -r -a line; do
    [[ "${line[0]}" =~ ^#.*$ ]] && continue
    user=${line[0]}

    if ! grep -q "^${user}:" /etc/passwd; then
        missing_users+=($user)
        continue 
    fi

    users+=($user)
    passwd=${line[1]}
    email=${line[2]}
    first_name=${line[3]}
    user_passwd[$user]=$passwd
    user_email[$user]=$email
    user_name[$user]=$first_name
done < "$USER_PASSWD_FILE"

if (( ${#missing_users[@]} )); then
    echo missing users: ${existing_users[@]}
fi
echo adding ${#users[@]} users: ${users[@]}


added_users=()
for user in ${users[@]}; do
    export passwd=${user_passwd[$user]}
cat << EOF > $OUTPUT_DIR/${user_email[$user]}
Hello ${user_name[$user]},

The following info will be used to connect to the shared server used in the upcoing workshop session:
login: $user
password:
$passwd

You can connect to the shared server with this command (use the password above when prompted):
ssh ${user}@${SERVER}

For more details on how to test these credentials, see:
https://umich-brcf-bioinf.github.io/2021-04-26-umich-rnaseqDemystified/connecting_to_linux

For other questions, please email us at:
bioinformatics-workshops@umich.edu

---
EOF
    added_users+=($user)
done

echo added ${#added_users[@]} of ${#users[@]} users: ${added_users[@]}

if (( ${#missing_users[@]} )); then
    echo skipped missing users: ${missing_users[@]}
fi

date
echo done
