#!/bin/bash

set -ue

date
export USER_PASSWD_FILE=$1
export CONDA_PREFIX='/rsd/conda/workshop'
export PRIMARY_GROUP='workshop-rsd-users'
export CONDA_SETUP=/rsd/workshop_setup/conda_setup/Miniconda3-latest-Linux-x86_64.sh

users=()
existing_users=()
declare -A user_passwd
while IFS==$'\t' read -r -a line; do
    [[ "${line[0]}" =~ ^#.*$ ]] && continue
    user=${line[0]}

    if grep "^${user}:" /etc/passwd; then
        existing_users+=($user)
        continue 
    fi

    users+=($user)
    passwd=${line[1]}
    user_passwd[$user]=$passwd
done < "$USER_PASSWD_FILE"

if (( ${#existing_users[@]} )); then
    echo skipping existing users: ${existing_users[@]}
fi
echo adding ${#users[@]} users: ${users[@]}


added_users=()
for user in ${users[@]}; do
    echo ${user} : add user
    export user
    export pass=${user_passwd[$user]}
    export uhome=/home/${user}
    sudo useradd -s /bin/bash -m -p $(openssl passwd -1 $pass) -g $PRIMARY_GROUP $user
    sudo -H -u $user bash -c "bash /rsd/workshop_setup/scripts/user_setup.sh $CONDA_SETUP $CONDA_PREFIX"
    added_users+=($user)
done

echo added ${#added_users[@]} of ${#users[@]} users: ${added_users[@]}

if (( ${#existing_users[@]} )); then
    echo skipped existing users: ${existing_users[@]}
fi

date
echo done
