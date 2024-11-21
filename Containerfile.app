FROM registry.redhat.io/rhel9/rhel-bootc:latest

#add additional software. Below are some useful tools, but we don't technically need them for this example so let's skip them!
#RUN dnf install -y cockpit cockpit-podman cockpit-storaged cockpit-ws git lm_sensors sysstat tuned && dnf clean all

#enable desired units. Did you know podman can automatically update your containers?
RUN systemctl enable podman-auto-update.timer

#include configs and the quadlet files to run Caddy as a container
ADD etc etc
ADD www usr/www
ADD systemd/* /usr/share/containers/systemd/
