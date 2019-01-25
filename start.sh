#!/bin/bash


postconf -e myhostname=$maildomain


echo $smtp_user | tr , \\n > /tmp/passwd
while IFS=':' read -r _user _pwd; do
  echo $_pwd | saslpasswd2 -p -c -u $maildomain $_user
done < /tmp/passwd
chown postfix.sasl /etc/sasldb2

############
# Enable TLS
############
if [[ -d /etc/postfix/certs ]]; then 
  if [[ -n "$(find /etc/postfix/certs -iname *.crt)" && -n "$(find /etc/postfix/certs -iname *.key)" ]]; then
    # /etc/postfix/main.cf
    postconf -e smtpd_tls_cert_file=$(find /etc/postfix/certs -iname *.crt)
    postconf -e smtpd_tls_key_file=$(find /etc/postfix/certs -iname *.key)
    chmod 400 /etc/postfix/certs/*.*
    # /etc/postfix/master.cf
    postconf -M submission/inet="submission   inet   n   -   n   -   -   smtpd"
    postconf -P "submission/inet/syslog_name=postfix/submission"
    postconf -P "submission/inet/smtpd_tls_security_level=encrypt"
    postconf -P "submission/inet/smtpd_sasl_auth_enable=yes"
    postconf -P "submission/inet/milter_macro_daemon_name=ORIGINATING"
    postconf -P "submission/inet/smtpd_recipient_restrictions=permit_sasl_authenticated,reject_unauth_destination"
  fi
fi



if [[ ! -f /etc/opendkim/TrustedHosts ]]; then
echo add exaple file TrustedHosts
cat > /etc/opendkim/TrustedHosts <<EOF
127.0.0.1
localhost
172.17.0.1/16
*.$maildomain
EOF
fi

if [[ ! -f /etc/opendkim/KeyTable ]]; then
echo add exaple file KeyTable
cat > /etc/opendkim/KeyTable <<EOF
mail._domainkey.$maildomain $maildomain:mail:$(find /etc/opendkim/domainkeys -iname *.private)
EOF
chown opendkim:opendkim $(find /etc/opendkim/domainkeys -iname *.private)
chmod 400 $(find /etc/opendkim/domainkeys -iname *.private)
EOF
fi

if [[ ! -f /etc/opendkim/SigningTable ]]; then
echo add exaple file SigningTable
cat > /etc/opendkim/SigningTable <<EOF
*@$maildomain mail._domainkey.$maildomain
EOF
fi


/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
