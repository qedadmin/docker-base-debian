#!/usr/bin/with-contenv bash

set -e

DEFAULTDOMAIN=${DEFAULTDOMAIN:=""}
NISSERVERS=${NISSERVERS:=""}

if [ ! -z "$DEFAULTDOMAIN" ] && [ ! -z "$NISSERVERS" ]; then
    echo "Setting up NIS/YP"
    echo "defaultdomain: '${DEFAULTDOMAIN}'"
    echo "NIS server: '${NISSERVERS}'"

    echo ${DEFAULTDOMAIN} > /etc/defaultdomain
    echo "domain ${DEFAULTDOMAIN} server ${NISSERVERS}" > /etc/yp.conf

    cat <<EOT > /etc/nsswitch.conf
    passwd:         files nis
    group:          files nis
    shadow:         files nis
    gshadow:        files

    hosts:          files dns
    networks:       files

    protocols:      db files
    services:       db files
    ethers:         db files
    rpc:            db files

    netgroup:       nis
EOT

    mkdir -p /etc/services.d/rpcbind/
    cat <<EOT > /etc/services.d/rpcbind/run
#!/usr/bin/execlineb -P

/sbin/rpcbind -f
EOT
    chmod +x /etc/services.d/rpcbind/run
    mkdir -p /etc/services.d/nis/
    cat <<EOT > /etc/services.d/nis/run
#!/usr/bin/env bash
exec /usr/sbin/ypbind -n
EOT
    chmod +x /etc/services.d/nis/run
else
    echo "'DEFAULTDOMAIN' & 'NISSERVERS' are undefined. Skipped NIS configuration."
fi
