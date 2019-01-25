#!/bin/bash -ex
registry=casp/mailer
docker build -t $registry . && docker push $registry
#--squash 

