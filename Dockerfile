FROM alpine:3.14

ARG ARCH=arm64

RUN if ! echo "amd64 arm64" | grep -wq $ARCH; then \
        echo "Error: Invalid architecture: $ARCH"; \
        exit 1; \
    fi

# Install necessary dependencies
RUN apk add --no-cache curl python3 py3-pip bash jq shadow && \
    pip3 install --upgrade pip && \
    \
    # Fetch and install the latest version of AWS CLI
    LATEST_AWSCLI_VERSION=$(curl -s https://pypi.org/pypi/awscli/json | jq -r '.info.version') && \
    pip3 install awscli=="$LATEST_AWSCLI_VERSION" && \
    \
    # Fetch and install the latest version of kops
    LATEST_KOPS_VERSION=$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | jq -r '.tag_name' | sed 's/v//') && \
    curl -LO "https://github.com/kubernetes/kops/releases/download/v${LATEST_KOPS_VERSION}/kops-linux-$ARCH" && \
    chmod +x kops-linux-$ARCH && \
    mv kops-linux-$ARCH /usr/local/bin/kops && \
    \
    # Fetch and install the latest version of kubectl
    LATEST_KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt) && \
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/${LATEST_KUBECTL_VERSION}/bin/linux/$ARCH/kubectl" && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

RUN groupadd -g 1000 iguazio && \
    useradd -u 1000 -g iguazio iguazio && \
    echo 'iguazio ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    mkdir -p .aws

USER iguazio
WORKDIR /kops
# Entrypoint can be bash, so you have a shell when the container starts
ENTRYPOINT ["/bin/bash"]

