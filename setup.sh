#!/usr/bin/env bash
printf "%s\n" "!!        INSTALL PREREQUISITES      !!"
printf "%s\n" "#Install podman rootless"
printf "%s\n" "minikube config set rootless true"
printf "%s\n" "#Set SUB UID and GID"
printf "%s\n" "echo $(whoami):10000:65536 >> /etc/subuid"
printf "%s\n" "echo $(whoami):10000:65536 >> /etc/subgid"
printf "%s\n" "#Add $(whoami) to the sudoers"
printf "%s\n" "echo \"$(whoami) ALL=(ALL) NOPASSWD: /usr/bin/podman\" | sudo tee -a /etc/sudoers.d/10-installer"
printf "%s\n" "#enable rootless podman"
printf "%s\n" "systemctl --user enable podman"
printf "%s\n" "systemctl --user start podman"
printf "%s\n" "minikube start --driver=podman -c cri-o"
printf "%s\n" ""
sleep 2
helm repo add container-agent https://packagecloud.io/circleci/container-agent/helm
helm repo update
kubectl create namespace circleci
helm install eg oci://docker.io/envoyproxy/gateway-helm --version v1.2.1 -n envoy-gateway-system --create-namespace
kubectl wait --timeout=5m -n envoy-gateway-system deployment/envoy-gateway --for=condition=Available
helm install container-agent container-agent/container-agent -n circleci -f values.yaml
minikube dashboard &


