#!/bin/bash
curl -k https://vault.stn.corrarello.net/v1/pki/crl/pem > /etc/puppet/ssl/crl.pem
puppet master --no-daemonize --verbose
