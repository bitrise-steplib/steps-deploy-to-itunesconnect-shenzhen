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

  write_section_to_formatted_output "**If this is the very first build**
of the app you try to deploy to iTunes Connect then you might want to upload the first
build manually to make sure it fulfills the initial iTunes Connect submission
verification process."
}

function CLEANUP_ON_ERROR_FN {
  local err_msg="$1"
  finalcleanup "${err_msg}"
}
set_error_cleanup_function CLEANUP_ON_ERROR_FN


# ---------------------
# --- Required Inputs

if [ -z "${ipa_path}" ] ; then
	finalcleanup "Input: \`ipa_path\` not provided!"
	exit 1
fi

if [ -z "${password}" ] ; then
	finalcleanup "Input: \`password\` not provided!"
	exit 1
fi

if [ -z "${itunescon_user}" ] ; then
	finalcleanup "Input: \`itunescon_user\` not provided!"
	exit 1
fi

if [ -z "${app_id}" ] ; then
	finalcleanup "Input: \`app_id\` not provided!"
	exit 1
fi


# ---------------------
# --- Main

write_section_to_formatted_output "# Setup"
bash "${THIS_SCRIPT_DIR}/_setup.sh"
fail_if_cmd_error "Failed to setup the required tools!"

write_section_to_formatted_output "# Deploy"

write_section_to_formatted_output "**Note:** if your password
contains special characters
and you experience problems, please
consider changing your password
to something with only
alphanumeric characters."

write_section_to_formatted_output "**Be advised** that this
step uses a well maintained, open source tool which
uses *undocumented and unsupported APIs* (because the current
iTunes Connect platform does not have a documented and supported API)
to perform the deployment.
This means that when the API changes
**this step might fail until the tool is updated**."

ipa distribute:itunesconnect -f "${ipa_path}" -a "${itunescon_user}" -p "${password}" -i "${app_id}" --upload --verbose
fail_if_cmd_error "Deploy failed!"

write_section_to_formatted_output "# Success"
echo_string_to_formatted_output "* The app (.ipa) was successfully uploaded to [iTunes Connect](https://itunesconnect.apple.com), you should see it in the *Prerelease* section on the app's iTunes Connect page!"
echo_string_to_formatted_output "* **Don't forget to enable** the **TestFlight Beta Testing** switch on iTunes Connect (on the *Prerelease* tab of the app) if this is a new version of the app!"

exit 0
