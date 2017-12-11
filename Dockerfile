FROM alpine:3.6
MAINTAINER Chris Kankiewicz <Chris@ChrisKankiewicz.com>

# CrashPlan version
ARG CP_VERSION=4.8.2

# Set tarball file URL
ARG TARBALL_URL=http://download.code42.com/installs/linux/install/CrashPlan/CrashPlan_${CP_VERSION}_Linux.tgz

# Create non-root user
# RUN adduser -DHs /sbin/nologin crashplan

# Create CrashPlan directory
RUN mkdir -p /tmp/crashplan

# Install expect script
COPY /files/crashplan.exp /tmp/crashplan/crashplan.exp
RUN chmod +x /tmp/crashplan/crashplan.exp

# Install dependencies and fet CrashPlan tarball
RUN apk add --no-cache --update bash ca-certificates coreutils cpio expect tar tzdata wget \
    # && wget -qO- ${TARBALL_URL} | tar -xz --strip-components=1 -C /tmp/crashplan
    && wget -qO- ${TARBALL_URL} | tar -xzO --strip-components=1 crashplan-install/CrashPlan_${CP_VERSION}.cpi \
    | cpio --extract --no-preserve-owner --verbose \
    && rm /var/cache/apk/*

# RUN gunzip -c CrashPlan_4.8.2.cpi

# Install CrashPlan
RUN cd /tmp/crashplan && ./crashplan.exp && cd /

# Run CrashPlan once to generate files
# RUN /usr/local/crashplan/bin/CrashPlanEngine start && sleep 2 \
#     && /usr/local/crashplan/bin/CrashPlanEngine stop; sleep 2

# Add run file
# ADD /files/run.sh /run.sh
# RUN chmod +x /run.sh

# Define volumes
VOLUME /vol/crashplan

# Expose ports
EXPOSE 4242 4243

WORKDIR /opt/crashplan

# Default command
CMD ["/run.sh"]
