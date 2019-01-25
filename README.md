# postfix mailer
==============

run postfix with smtp authentication (sasldb) in a docker container.
TLS and OpenDKIM support are optional.


## Usage
Create postfix container with smtp authentication

```bash
$ sudo docker run -p 25:25 \
		-e maildomain=mail.example.com -e smtp_user=user:pwd \
		--name postfix -d casp/mailer
# Set multiple user credentials: -e smtp_user=user1:pwd1,user2:pwd2,...,userN:pwdN
```

## Enable OpenDKIM: 
### 1. Gen key	
```bash
cd /etc/opendkim/keys
opendkim-genkey  -d example.com -s example
modify files:
	- /etc/opendkim/KeyTable
	- /etc/opendkim/SigningTable
	- /etc/opendkim/TrustedHosts 
```

###2. Add DNS Record from  ```example.txt``` file  
	


```bash
$ sudo docker run -p 25:25 \
		-e maildomain=mail.example.com -e smtp_user=user:pwd \
		-v /path/to/domainkeys:/etc/opendkim/domainkeys \
		--name postfix -d casp/mailer
```

## Enable TLS
Enable TLS(587): save your SSL certificates ```.key``` and ```.crt``` to  ```/path/to/certs```

```bash
	$ sudo docker run -p 587:587 \
			-e maildomain=example.com -e smtp_user=user:pwd \
			-v /path/to/certs:/etc/postfix/certs \
			--name postfix -d casp/mailer
```


## Example docker-compose
```
mailer-example:
    image: casp/mailer
    restart: always
    hostname: mailer-example
    domainname: example.com
    container_name: mailer-example
    volumes:
      - /srv/docker/mailer-example/opendkim:/etc/opendkim/
      - /srv/docker/mailer-example/maildata:/var/mail
      - /srv/docker/mailer-example/mailstate:/var/mail-state
    environment:
      - maildomain=example.com
      - smtp_user=noreply:pwd
    ports:
      - "2525:25"
```

