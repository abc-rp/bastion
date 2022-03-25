FROM quay.io/centos/centos:stream8

ENV NAME=bastion VERSION=8
ENV VISUAL=nvim
LABEL name="$NAME" \
    version="$VERSION"

COPY README.adoc /

# install packages
COPY extra-packages /
RUN dnf config-manager --enable powertools \
    && dnf install --nogpgcheck https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm \
    && dnf -y install $(<extra-packages) \
    && dnf clean all \
    && rm /extra-packages

# ssh config
RUN sed -i 's/#Port.*$/Port 2022/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication.*$/PasswordAuthentication no/' /etc/ssh/sshd_config \
    && sed -i 's/#PermitRootLogin.*$/PermitRootLogin no/' /etc/ssh/sshd_config

# create user
RUN useradd -M -G wheel -s /bin/bash bastion

# allow user's group to run all commands with no password
RUN echo %abc ALL=NOPASSWD:ALL > /etc/sudoers.d/bastion \
    && chmod 0440 /etc/sudoers.d/bastion

EXPOSE 2022

CMD ["/usr/sbin/sshd", "-De"]