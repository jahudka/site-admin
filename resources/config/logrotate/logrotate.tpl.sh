#!/usr/bin/env bash

set -eu

cat << EOT
${home_dir}/.log/*.log ${home_dir}/.log/*/*.log {
	rotate 5
	size 100k
	notifempty
	missingok
}

include ${home_dir}/.config/logrotate.d

EOT
