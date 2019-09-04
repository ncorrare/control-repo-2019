#!/bin/bash
curl -k https://vault.stn.corrarello.net/v1/pki/crl/pem > /etc/puppet/ssl/crl.pem
exec puppet master --no-daemonize --verbose
