#!/usr/bin/with-contenv bash

MASTER=$(find /etc/auto.master.d/ -maxdepth 1 -name "*.autofs" | wc -l)

if [ "${MASTER}" -gt 0 ]; then
    echo "Setting up AutoFs"
    echo "Found ${MASTER} master files"
    cat /etc/auto.master.d/*.autofs
    mkdir -p /etc/services.d/automount/
    cat <<EOT > /etc/services.d/automount/run
#!/usr/bin/env bash
exec /usr/sbin/automount -f
EOT
    chmod +x /etc/services.d/automount/run
else
    echo "No master files (/etc/auto.master.d/*.autofs) found. Skipped AutoFs configuration."
fi
