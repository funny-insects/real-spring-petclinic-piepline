FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    gosu \
    jq \
    maven \
    default-jdk \
    tar \
    gzip \
    unzip \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash GHA

# GitHub Actions runner distribution (Linux ARM64) must be provided in this folder.
COPY actions-runner/ /opt/actions-runner/

# Install runner OS dependencies (script is shipped in the runner tarball).
RUN if [ -f /opt/actions-runner/bin/installdependencies.sh ]; then \
      chmod +x /opt/actions-runner/bin/installdependencies.sh && /opt/actions-runner/bin/installdependencies.sh; \
    else \
      echo "ERROR: runner binaries missing. Put the extracted actions-runner tarball into runner/actions-runner/" >&2; \
      exit 1; \
    fi

COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

ENV RUNNER_HOME=/home/GHA/actions-runner
ENV RUNNER_SRC=/opt/actions-runner

WORKDIR /home/GHA
ENTRYPOINT ["/usr/local/bin/start.sh"]
