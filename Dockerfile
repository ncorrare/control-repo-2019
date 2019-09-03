FROM debian:stable

RUN apt-get update -qq && apt-get install puppet-master r10k -qq
COPY Puppetfile /etc/puppet/
COPY environment.conf /etc/puppet/code
COPY r10k.yaml /etc/
WORKDIR "/etc/puppet/"
RUN r10k deploy environment -p
RUN 
EXPOSE 8140
