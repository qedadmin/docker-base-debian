#!/usr/bin/with-contenv bash

unset LANG
cd /etc/postfix

MAILNAME=${MAILNAME:=""}
MYDESTINATION=${MYDESTINATION:=""}
MYNETWORKS=${MYNETWORKS:="127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128"}
SIZELIMIT=${SIZELIMIT:="0"}
RELAYHOST=${RELAYHOST:=}
USE_TLS=${USE_TLS:="yes"}
TLS_SECURITY_LEVEL=${TLS_SECURITY_LEVEL:="may"}
TLS_KEY=${TLS_KEY:="/etc/ssl/private/ssl-cert-snakeoil.key"}
TLS_CRT=${TLS_CRT:="/etc/ssl/certs/ssl-cert-snakeoil.pem"}
TLS_CA=${TLS_CA:=}

if [ ! -z "$MAILNAME" ] && [ ! -z "$RELAYHOST" ] && [ ! -z "$MYDESTINATION" ]; then
    echo "Setting up Postfix"
    postfix set-permissions

    echo "smtpd_use_tls: '${USE_TLS}'"
    postconf -e smtpd_use_tls="${USE_TLS}"

    if [ "${USE_TLS}" == "yes" ]; then
        echo "smtpd_tls_key_file: '${TLS_KEY}'"
        if [ "${TLS_KEY}" == "/etc/ssl/private/ssl-cert-snakeoil.key" ]; then
            dpkg-reconfigure -f noninteractive ssl-cert
        fi
        postconf -e smtp_tls_security_level="${TLS_SECURITY_LEVEL}"
        postconf -e smtp_tls_CApath="/etc/ssl/certs"
        postconf -e smtp_tls_loglevel="1"
        postconf -e smtpd_tls_key_file="${TLS_KEY}"
        postconf -e smtpd_tls_cert_file="${TLS_CRT}"
        postconf -e smtpd_tls_CAfile="${TLS_CA}"
    fi

    echo "myorigin: '${MAILNAME}'"
    postconf -e myorigin="${MAILNAME}"

    echo "myhostname: '${MAILNAME}'"
    postconf -e myhostname="${MAILNAME}"

    echo "relayhost: '${RELAYHOST}'"
    postconf -e relayhost="${RELAYHOST}"

    echo "mydestination: '${MYDESTINATION}'"
    postconf -e mydestination="${MYDESTINATION}"

    echo "mynetworks: '${MYNETWORKS}'"
    postconf -e mynetworks="${MYNETWORKS}"

    postconf -e message_size_limit="${SIZELIMIT}"
    postconf -e inet_interfaces="all"
    postconf -e recipient_delimiter="+"

    mkdir -p /etc/services.d/postfix/
    cat <<EOT > /etc/services.d/postfix/run
#!/usr/bin/env bash
/usr/sbin/service postfix start
sleep 10
MASTER_PID="\$(cat /var/spool/postfix/pid/master.pid)"
while kill -0 "\${MASTER_PID}" 2>/dev/null; do
  sleep 1
done
EOT
    chmod +x /etc/services.d/postfix/run
else
    echo "'MAILNAME', 'RELAYHOST' & 'MYDESTINATION' are undefined. Skipped Postfix configuration."
fi
