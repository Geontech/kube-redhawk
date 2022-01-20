#==================================================================================================
#! @file      Dockerfile
#! @author    Geon Technologies (geon.tech)
#! @copyright 2022 Geon Technologies, LLC. All rights reserved.
#! @license   GPLv3
#! @brief     A Docker image that adds an OpenSSH Server to the redhawk-development image
#==================================================================================================

# Start with base image
FROM geontech/redhawk-development:2.2.5

# Install Prerequisites
RUN yum -y install supervisor openssh-server openssh-clients xauth vim-common

# Setup Xserver
RUN ssh-keygen -A && \
    echo "root:redhawk" | chpasswd && \
    echo "X11UseLocalhost no" >> /etc/ssh/sshd_config && \
    touch /root/.Xauthority && \
    xauth add ${HOST}:0 . $(xxd -l 16 -p /dev/urandom) && \
    mkdir -p /data; mkdir -p /data/db

# Copy files
COPY sshd.ini /etc/supervisord.d/
COPY startup.sh /tmp/startup.sh

# Start supervisord (for ssh server) and wait
CMD ["/bin/bash", "-l", "-c", "/tmp/startup.sh"]
