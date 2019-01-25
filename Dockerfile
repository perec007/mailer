From ubuntu:trusty
MAINTAINER oleg@casp.ru

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get -y install supervisor postfix sasl2-bin opendkim opendkim-tools

#ADD assets/install.sh /opt/install.sh
# POSTFIX CONFIG
RUN postconf -e smtpd_sasl_auth_enable=yes ; \
    postconf -e broken_sasl_auth_clients=yes ; \
    postconf -e smtpd_recipient_restrictions=permit_sasl_authenticated,reject_unauth_destination; \
    postconf -e milter_protocol=2; \
    postconf -e milter_default_action=accept; \
    postconf -e smtpd_milters=inet:localhost:12301; \
    postconf -e non_smtpd_milters=inet:localhost:12301; \
    postconf -F '*/*/chroot = n'


ADD cfg/smtpd.conf /etc/postfix/sasl/smtpd.conf 
ADD cfg/opendkim.conf /etc/opendkim.conf
ADD cfg/opendkim_default /etc/default/opendkim
ADD cfg/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY postfix.sh /
ADD start.sh /


CMD /start.sh
