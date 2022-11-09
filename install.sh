#!/usr/bin/env bash

set -eu

install_dir="${1:-/opt/adm}"

if [[ -e "${install_dir}" ]]; then
	if [[ ! -d "${install_dir}" ]]; then
		echo "Destination already exists, but it's not a directory, aborting."
		exit 1
	elif [[ ! -x "${install_dir}/current/bin/adm" ]]; then
		echo "Destination already exists, but it doesn't appear to be a previous SiteAdmin installation, aborting."
		exit 1
	fi
fi

version="$( date '+%F-%H-%M-%S' )"
tmp="/tmp/adm-install-${version}"

if ! mkdir -m 0750 "${tmp}"; then
	echo "Cannot create temporary installation directory '${tmp}'"
	exit 1
fi

umask 027

cd "${tmp}"
wget -O adm.zip "http://github.com/jahudka/site-admin/archive/main.zip"
unzip -oq adm.zip

if [[ ! -e "${install_dir}" ]]; then
	mkdir -p "${install_dir}"
	site-admin-main/bin/adm scaffold "${install_dir}"

	site-admin-main/bin/adm install config.tpl.sh "${install_dir}/shared/config.env" \
		-v php="$( site-admin-main/bin/adm resolve /etc/php 2>/dev/null | sed -Ee 's/\..+$//' )" \
		-v node="$( site-admin-main/bin/adm resolve /opt/node 2>/dev/null | sed -Ee 's/^v|\..+$//g' )"
fi

mv site-admin-main "${install_dir}/releases/${version}"
ln -s "${install_dir}/shared/config.env" "${install_dir}/releases/${version}/config.env"
ln -s "${install_dir}/releases/${version}" "${install_dir}/current.new"
mv -f "${install_dir}/current.new" "${install_dir}/current"

find "${install_dir}/releases" -mindepth 1 -maxdepth 1 -type d -regex '.+/[0-9][^/]+' \
	| sort -n \
	| head -n -3 \
	| xargs -rd '\n' rm -rf
