FROM debian:stable
COPY qemu-arm-static /usr/bin

RUN apt-get update -qq && apt-get install puppet-master r10k -qq
COPY Puppetfile /etc/puppet/
COPY environment.conf /etc/puppet/code
COPY r10k.yaml /etc/
WORKDIR "/etc/puppet/"
RUN r10k deploy environment -p
RUN r10k deploy display --detail
EXPOSE 8140
