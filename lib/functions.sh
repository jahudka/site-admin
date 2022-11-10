# intentionally no shebang - intended to be sourced


function mkdirp () {
	if [[ "$#" != "3" ]]; then
		echo "Usage: mkdirp <path> <user> <perms>"
		exit 1
	fi

	local -r path="${1}"
	local -r user="${2}"
	local -r perms="${3}"

  if [[ -d "${path}" ]]; then
    return 0
	elif [[ -e "${path}" ]]; then
		echo "Failed to create '${path}': file already exists and is not a directory"
		return 1
  fi

  mkdirp "$( dirname "${path}" )" "${user}" "${perms}"
  mkdir -m "${perms}" "${path}"
  chown "${user}:${user}" "${path}"
}
