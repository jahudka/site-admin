#!/usr/bin/env bash

cat << EOT
# This file will be sourced by all commands. You can set up some things here.

# Default PHP and Node versions.
# Used when PHP or Node is requested without specifying a version.
DEFAULT_PHP_VERSION=${php}
DEFAULT_NODE_VERSION=${node}

# Import SSH keys to application users. Uses 'ssh-import-keys'.
# Optional.
#SSH_IMPORT=gh:username

# The name of an installed and configured Certbot authenticator plugin.
# Note that only DNS plugins are supported - webroot authentication is not!
# Required when creating sites with SSL enabled.
#CERTBOT_AUTHENTICATOR=dns-active24
EOT
