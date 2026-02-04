# GHA runner + Nexus (Docker Compose)

Runs a self-hosted GitHub Actions runner (Linux ARM64, for Apple Silicon) and a Nexus repository manager.

## 1) Download GitHub Actions runner binaries (ARM64)

Put the extracted runner tarball contents into:

- `gha-nexus-env/runner/actions-runner/`

Example (pick the latest version from https://github.com/actions/runner/releases):

```bash
cd gha-nexus-env/runner/actions-runner
curl -L -o actions-runner-linux-arm64.tar.gz \
  https://github.com/actions/runner/releases/download/v2.322.0/actions-runner-linux-arm64-2.322.0.tar.gz

tar xzf actions-runner-linux-arm64.tar.gz
```

After extraction, this folder should contain `config.sh`, `run.sh`, `bin/`, etc.

## 2) Configure environment variables

Create `gha-nexus-env/.env` (not committed) based on `.env.example`.

You’ll need a runner registration token from your GitHub repo:

- Repo → Settings → Actions → Runners → New self-hosted runner

## 3) Start

```bash
cd gha-nexus-env
docker compose up -d --build
```

- Nexus UI: http://localhost:8081
- From the runner container, Nexus is reachable as: `http://nexus:8081`

## 4) Nexus: create a repository for uploads

Recommended simplest path:
- Create a **Raw (hosted)** repository named `petclinic-raw`

Then set GitHub repo secrets used by the workflow:
- `NEXUS_USERNAME`
- `NEXUS_PASSWORD`

## 5) Stop / restart (persistence)

```bash
docker compose down
docker compose up -d
```

- Nexus data persists via the `nexus-data` volume
- Runner config persists via the `runner-data` volume (so it won’t re-register each restart)
