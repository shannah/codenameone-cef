#!/bin/bash
# A script to check the notarization status of a mac notarization request.
# In the output of the build-mac.sh script, you should see a log entry like:
# RequestUUID = e36d7f1a-379d-4332-ac5b-6db286b449a0
# Use that RequestUUID as a parameter in this script to check on the notarization
# status.
#  E.g. bash notarize-check.sh e36d7f1a-379d-4332-ac5b-6db286b449a0
#
if [ -f codesign-settings.sh ]; then
  source codesign-settings.sh
fi
xcrun altool --notarization-info "$1" -u "$APPLE_USER" --password  "$APPLE_PASSWORD"
