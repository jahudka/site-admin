# Site Admin

This tool provides a set of Bash scripts to simplify the creation and management of
self-hosted websites. It supports Nginx, PHP-FPM and NodeJS, as well as Let's Encrypt.

## Requirements

 - Nginx
 - PHP from [deb.sury.org](https://deb.sury.org)
 - Node from official binaries installed in `/opt/node/<version>`
 - Certbot with a DNS authenticator plugin

## Installation

```shell
curl -sSfL https://github.com/jahudka/site-admin/raw/main/install.sh | bash -s <install dir>
```

Default installation directory is `/opt/adm`.

## Commands

### `adm create [options] <name> [aliases]`

**Note:** this doc is outdated, will be fixed soon, run `adm create` for built-in help for now.

This command will create a new site. Available options are:
 - `-p[v]` / `--php[=v]`: enable PHP at the specified version (8.1 by default).
 - `-n[v]` / `--node[=v]`: enable NodeJS at the specified version (18 by default).
 - `-s` / `--ssl`: enable SSL and obtain certificates via Certbot.

This will:
 - Create a system user and matching group:
   - The user and group name will be the prefix `cst-` followed by the `<name>`
     translated such that leading `^www\.` and trailing `\.[^.]+$` are removed
     and the remaining names are reversed in order and separated by a dash instead
     of a dot, e.g. `www.example.com` becomes `cst-example` and `foo.bar.baz.com`
     becomes `cst-baz-bar-foo`.
   - The UID and GID will be in the range 801-899.
   - The user will additionally be added to the `www-data` group so that it can
     create application sockets in `/run/nginx`.
   - The `www-data` user will be added to the user's group so that it can access
     application sockets in `/run/nginx` as well as any files in document root.
   - The home directory will be `/srv/http/<name>`.
   - The UMASK will be 027.
   - The home directory will be seeded from `resources/skel`; this provides some
     useful things:
     - `.config/environment.d/*.conf` - any environment variables defined in these
       files will be available both to any user sessions and any user-defined Systemd
       services
     - `.bin` - will be added to `$PATH`
     - `.log` - common location for all logs related to the site; has `setgid` set,
       so that Nginx logs are owned by the user's primary group, giving the user
       (but not other members of `www-data`) read access.
   - _Lingering_ will be enabled for the user (meaning systemd user services will
     run at boot and persist after logout).
   - If `SSH_IMPORT` is set in `config.env`, SSH keys are imported for the app user.
 - If PHP is enabled:
   - Binaries for the selected version are symlinked to `~/.bin`.
   - Log directory `~/.log/php` is created.
   - A Systemd user service for PHP-FPM is created and enabled; the FPM pool config
     is stored in `~/.config/php/fpm.conf`.
 - If Node is enabled:
   - Binaries for the selected version are symlinked to `~/.bin`.
 - Finally, a Nginx virtual host config is generated at `/etc/nginx/sites-available/<name>.conf`
   and symlinked to `/etc/nginx/sites-enabled/<name>`. It contains a single canonical
   virtual host for `http${ssl:+s}://${name}` with appropriate `location` blocks forwarding
   requests which do not match an existing file to either PHP via `fastcgi_pass` or Node
   via `proxy_pass`. Additionally, it contains virtual hosts for any configured aliases
   and non-SSL versions if SSL is enabled; these all redirect to the canonical host.
