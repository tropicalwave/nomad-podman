FROM quay.io/podman/stable:v3.2.2
ARG DRIVER_VERSION=0.3.0
ENV PODMAN_DRIVER nomad-driver-podman_${DRIVER_VERSION}_linux_amd64.zip
RUN dnf -y install dnf-plugins-core && \
    dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo && \
    dnf -y install \
        nomad \
	consul \
	hostname \
	less \
	podman \
	podman-docker \
	procps-ng \
	unzip && \
    dnf clean all && \
    systemctl enable podman.socket && \
    systemctl enable consul.service && \
    systemctl enable nomad.service && \
    mkdir -p /opt/nomad/data/plugins && \
    curl -o "/opt/nomad/data/plugins/$PODMAN_DRIVER" "https://releases.hashicorp.com/nomad-driver-podman/$DRIVER_VERSION/$PODMAN_DRIVER" && \
    unzip "/opt/nomad/data/plugins/$PODMAN_DRIVER" -d "/opt/nomad/data/plugins/" && \
    rm -f "/opt/nomad/data/plugins/$PODMAN_DRIVER" && \
    chown podman:podman /opt/nomad/data
COPY nomad/override.conf /etc/systemd/system/nomad.service.d/override.conf
COPY etc/systemd/system/* /etc/systemd/system/
COPY usr/local/bin/* /usr/local/bin/
RUN systemctl enable prepare-podman.service && \
    systemctl enable write-configs.service
COPY examples/* /examples/

CMD ["/sbin/init"]
