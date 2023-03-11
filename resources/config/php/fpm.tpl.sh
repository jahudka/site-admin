#!/usr/bin/env bash

set -eu

cat << EOT
;;;;;;;;;;;;;;;;;;;;;
; FPM Configuration ;
;;;;;;;;;;;;;;;;;;;;;

; All relative paths in this configuration file are relative
; to the application user's \$HOME (this is specified in the
; SystemD 'fpm.service' config file)

;;;;;;;;;;;;;;;;;;
; Global Options ;
;;;;;;;;;;;;;;;;;;

[global]
error_log = .log/php/fpm.log

;;;;;;;;;;;;;;;;;;;;
; Pool Definitions ;
;;;;;;;;;;;;;;;;;;;;

[app]
listen = /run/nginx/${name#www.}.sock

pm = dynamic
pm.max_children = 5
pm.start_servers = 1
pm.min_spare_servers = 1
pm.max_spare_servers = 3

env[PATH] = ${home_dir}/.bin:/opt/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

EOT
