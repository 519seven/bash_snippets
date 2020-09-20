#!/bin/bash

# PERC H330 controller on Dell R730
# Added to crontab to run every 30 minutes
# If FAIL_FILE exists, an email will not be sent out
# If there are no failed drives, if FAIL_FILE exists it
# will be removed and error condition cleared email sent out

PERC=/opt/MegaRAID/perccli/perccli64
FAIL_FILE=/.drive_failed_placeholder
EMAIL_ADDY=519seven@fixinit.com
HOSTNAME=$(cat /proc/sys/kernel/hostname)

drive_info=$($PERC /c0 show all | grep DRIVE)
# Examine word after "DRIVE" and ignore hot spare(s)
failed_drives=$(echo "$drive_info" | awk '{for (I=1;I<=NF;I++) if ($I == "DRIVE" && ($(I+1) != "Onln" && $(I+1) != "DHS")) {print $(I-2)};}')
if [ -z "${failed_drives}" ]; then
  if [ -f ${FAIL_FILE} ]; then
    rm ${FAIL_FILE}
    echo "Failed drive placeholder file removed (failure no longer exists) on ${HOSTNAME}" | mail -s "Failure cleared" ${EMAIL_ADDY};
  fi
else
  if [ ! -f ${FAIL_FILE} ]; then
    echo "Failed drive(s) on ${HOSTNAME}: ${failed_drives}" | mail -s "Failed drive on ${HOSTNAME}" ${EMAIL_ADDY};
    touch ${FAIL_FILE}
  fi
fi

