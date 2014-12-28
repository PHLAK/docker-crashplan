FROM ubuntu:14.04
MAINTAINER Chris Kankiewicz <Chris@ChrisKankiewicz.com>

## CrashPlan version
ENV VERSION 3.6.4

## Perform apt update / upgrade
RUN apt-get update && apt-get -y upgrade

## Install CrashPlan dependencies
RUN apt-get -y install expect openjdk-7-jre-headless wget

## Increase max file watches
ADD /files/60-max-user-watches.conf /etc/sysctl.d/60-max-user-watches.conf

## Create tmp folder
RUN mkdir /tmp/crashplan

## Download and extract CrashPlan archive
RUN wget -O- http://download.code42.com/installs/linux/install/CrashPlan/CrashPlan_${VERSION}_Linux.tgz \
    | tar -xz --strip-components=1 -C /tmp/crashplan

## Install expect script
ADD /files/crashplan.exp /tmp/crashplan/crashplan.exp
RUN chmod +x /tmp/crashplan/crashplan.exp

## Install CrashPlan
RUN cd /tmp/crashplan && ./crashplan.exp && cd /

## Enable service port forwarding
RUN /usr/local/crashplan/bin/CrashPlanEngine start; sleep 2

## Add run file
ADD /files/run.sh /run.sh
RUN chmod +x /run.sh

## Perform apt cleanup
RUN apt-get -y autoremove && apt-get -y clean && apt-get -y autoclean

## Define volumes
VOLUME /usr/local/var/crashplan

## Expose ports
EXPOSE 4242 4243

## Default command
CMD ["/run.sh"]
