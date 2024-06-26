#checkov:skip=CKV_DOCKER_3:runs unprivileged anyway (intended for test purposes)
#checkov:skip=CKV_DOCKER_2:no useful health check for servers and clients
FROM quay.io/podman/stable:v4.9.4
ARG DRIVER_VERSION=0.5.2
ENV PODMAN_DRIVER nomad-driver-podman_${DRIVER_VERSION}_linux_amd64.zip
RUN dnf -y install dnf-plugins-core && \
    dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo && \
    dnf -y install \
        jq \
        nomad \
        consul \
        haproxy \
        hostname \
        iproute \
        less \
        podman \
        podman-docker \
        procps-ng \
        unzip \
        util-linux && \
    dnf clean all && \
    systemctl enable podman.socket && \
    systemctl enable consul.service && \
    systemctl enable haproxy.service && \
    systemctl enable nomad.service && \
    mkdir -p /opt/nomad/data/plugins && \
    curl -o "/opt/nomad/data/plugins/$PODMAN_DRIVER" "https://releases.hashicorp.com/nomad-driver-podman/$DRIVER_VERSION/$PODMAN_DRIVER" && \
    unzip "/opt/nomad/data/plugins/$PODMAN_DRIVER" -d "/opt/nomad/data/plugins/" && \
    rm -f "/opt/nomad/data/plugins/$PODMAN_DRIVER" && \
    chown podman:podman /opt/nomad/data
COPY nomad/override.conf /etc/systemd/system/nomad.service.d/override.conf
COPY acls/ /etc/initial-acls/
COPY examples/ /examples/
COPY etc/systemd/system/* /etc/systemd/system/
RUN systemctl enable prepare-podman.service && \
    systemctl enable consul-acls.service && \
    systemctl enable nomad-acls.service && \
    systemctl enable write-configs.service
COPY usr/local/bin/* /usr/local/bin/

CMD ["/sbin/init"]
