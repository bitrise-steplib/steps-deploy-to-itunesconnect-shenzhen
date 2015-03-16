#!/bin/bash

THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# load bash utils
source "${THIS_SCRIPT_DIR}/bash_utils/utils.sh"
source "${THIS_SCRIPT_DIR}/bash_utils/formatted_output.sh"


# ------------------------------
# --- Error Cleanup

function finalcleanup {
  echo "-> finalcleanup"
  local fail_msg="$1"

  write_section_to_formatted_output "# Error"
  if [ ! -z "${fail_msg}" ] ; then
    write_section_to_formatted_output "**Error Description**:"
    write_section_to_formatted_output "${fail_msg}"
  fi
  write_section_to_formatted_output "*See the logs for more information*"
}

function CLEANUP_ON_ERROR_FN {
  local err_msg="$1"
  finalcleanup "${err_msg}"
}
set_error_cleanup_function CLEANUP_ON_ERROR_FN


# ---------------------
# --- Required Inputs

if [ -z "${STEP_SHENZHEN_DEPLOY_IPA_PATH}" ] ; then
	finalcleanup "Input: \`STEP_SHENZHEN_DEPLOY_IPA_PATH\` not provided!"
	exit 1
fi

if [ -z "${STEP_SHENZHEN_DEPLOY_ITUNESCON_PASSWORD}" ] ; then
	finalcleanup "Input: \`STEP_SHENZHEN_DEPLOY_ITUNESCON_PASSWORD\` not provided!"
	exit 1
fi

if [ -z "${STEP_SHENZHEN_DEPLOY_ITUNESCON_USER}" ] ; then
	finalcleanup "Input: \`STEP_SHENZHEN_DEPLOY_ITUNESCON_USER\` not provided!"
	exit 1
fi

if [ -z "${STEP_SHENZHEN_DEPLOY_ITUNESCON_APP_ID}" ] ; then
	finalcleanup "Input: \`STEP_SHENZHEN_DEPLOY_ITUNESCON_APP_ID\` not provided!"
	exit 1
fi


# ---------------------
# --- Main

set -e
set -v

write_section_to_formatted_output "# Setup"
set +e
bash "${THIS_SCRIPT_DIR}/_setup.sh"
fail_if_cmd_error "Failed to setup the required tools!"
set -e

write_section_to_formatted_output "# Deploy"
set +e
ipa distribute:itunesconnect -f "${STEP_SHENZHEN_DEPLOY_IPA_PATH}" -a "${STEP_SHENZHEN_DEPLOY_ITUNESCON_USER}" -p "${STEP_SHENZHEN_DEPLOY_ITUNESCON_PASSWORD}" -i "${STEP_SHENZHEN_DEPLOY_ITUNESCON_APP_ID}" --upload
fail_if_cmd_error "Deploy failed!"
set -e

write_section_to_formatted_output "# Success"
echo_string_to_formatted_output "The app (.ipa) was successfully uploaded to [iTunes Connect](https://itunesconnect.apple.com), you should see it in the *Prerelease* section on the app's iTunes Connect page!"

exit 0
