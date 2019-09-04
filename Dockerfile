FROM debian:stable
#COPY qemu-arm-static /usr/bin

RUN apt-get update -qq && apt-get install puppet-master r10k curl -qq
COPY Puppetfile /etc/puppet/
COPY environment.conf /etc/puppet/code
COPY r10k.yaml /etc/
WORKDIR "/etc/puppet/"
RUN r10k deploy environment -p
RUN r10k deploy display --detail
RUN mkdir "/etc/puppet/ssl"
RUN puppet config set hostcert --section master /etc/puppet/ssl/server-cert.pem
RUN puppet config set localcacert --section master /etc/puppet/ssl/ca.pem
RUN puppet config set hostprivkey --section master /etc/puppet/ssl/server-key.pem
RUN puppet config set hostcrl --section master /etc/puppet/ssl/crl.pem
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 8140
