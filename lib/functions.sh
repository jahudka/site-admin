# intentionally no shebang - intended to be sourced


function mkdirp () {
	if [[ "$#" != "3" ]]; then
		echo "Usage: mkdirp <path> <user> <perms>"
		exit 1
	fi

	local -r path="${1}"
	local -r user="${2}"
	local -r perms="${3}"

  if [[ -e "${path}" ]]; then
    return 0
  fi

  mkdirp "$( dirname "${path}" )"
  mkdir -m "${perms}" "${path}"
  chown "${user}:${user}" "${path}"
}
