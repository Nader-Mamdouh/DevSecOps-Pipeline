# DevSecOps Pipeline for Tic-Tac-Toe

A full DevSecOps project that combines:
- a React + TypeScript web application,
- containerized delivery with Docker,
- CI/CD and security checks via GitHub Actions,
- Kubernetes deployment manifests,
- AWS EKS infrastructure provisioning with Terraform.

This repository is designed to demonstrate an end-to-end workflow from local development to cloud deployment with integrated security controls.

## Architecture Overview

1. **Application**: Vite + React + TypeScript Tic-Tac-Toe game.
2. **CI pipeline**: Linting, testing, Docker image build.
3. **Security gate**: Trivy image scan blocks `HIGH`/`CRITICAL` vulnerabilities.
4. **Image publish**: Image is pushed to Docker Hub on `main` branch pushes.
5. **GitOps**: Argo CD watches this repository and syncs Kubernetes state automatically.
6. **Runtime**: Kubernetes manifests deploy the image to a cluster.
7. **Infrastructure**: Terraform provisions AWS networking and EKS resources.

## Key Features

- Interactive Tic-Tac-Toe gameplay with win/draw detection.
- Scoreboard tracking wins for `X`, `O`, and draws.
- Game history tracking with timestamps.
- Highlighted winning line for better game UX.
- Multi-stage Docker build for efficient production image.
- CI pipeline with automated linting, tests, and container vulnerability scanning.

## Tech Stack

### Application
- React 18
- TypeScript
- Vite
- Tailwind CSS
- Vitest

### DevSecOps and Infrastructure
- Docker (multi-stage build)
- GitHub Actions
- Trivy (container security scan)
- Kubernetes (Deployment, Service, Ingress)
- Argo CD (GitOps continuous delivery)
- Terraform (AWS VPC + EKS modules)

## Repository Structure

```text
.
├── .github/workflows/ci.yaml     # CI pipeline: lint, test, build, scan, push image
├── Dockerfile                    # Multi-stage Docker build (Node -> Nginx)
├── argocd/
│   └── application.yaml          # Argo CD app definition (GitOps sync)
├── Kubernetes/
│   ├── Deployment.yaml           # App deployment and probes
│   ├── Service.yaml              # ClusterIP service
│   └── Ingress.yaml              # Ingress routing
├── Terraform/
│   ├── backend.tf                # Remote state backend configuration
│   ├── vpc.tf                    # VPC and subnet provisioning
│   ├── eks.tf                    # EKS cluster and node groups
│   ├── sg.tf                     # Security group resources
│   ├── output.tf                 # Terraform outputs
│   ├── versions.tf               # Terraform and provider constraints
│   └── varibales.tf              # Input variables
└── src/
    ├── components/               # UI components
    ├── utils/gameLogic.ts        # Core game logic
    └── __tests__/                # Unit tests
```

## Local Development

### Prerequisites

- Node.js 22+ (matches CI and Docker build image)
- npm

### Run Locally

```bash
npm ci
npm run dev
```

### Useful Commands

```bash
npm run lint     # Static analysis
npm test         # Unit tests (Vitest)
npm run build    # Production build output in dist/
npm run preview  # Preview production build locally
```

## Docker

### Build Image

```bash
docker build -t tic-tac-toe:local .
```

### Run Container

```bash
docker run --rm -p 8080:80 tic-tac-toe:local
```

Then open `http://localhost:8080`.

## CI/CD and Security

The GitHub Actions workflow at `.github/workflows/ci.yaml` runs on pushes and pull requests targeting `main`.

Pipeline stages:
- **Static Code Analysis**: installs dependencies and runs ESLint.
- **Build and Test**: runs automated tests.
- **Build and Scan Docker Image**:
  - builds a Docker image tagged with commit SHA,
  - scans with Trivy,
  - fails the pipeline on `HIGH` or `CRITICAL` vulnerabilities,
  - pushes image to Docker Hub on push events.

### Required GitHub Secrets

- `DOCKER_USERNAME`
- `DOCKER_PASSWORD`

## Kubernetes Deployment

Kubernetes manifests are available under `Kubernetes/`.

Typical apply sequence:

```bash
kubectl apply -f Kubernetes/Deployment.yaml
kubectl apply -f Kubernetes/Service.yaml
kubectl apply -f Kubernetes/Ingress.yaml
```

Before applying:
- update the container image tag in `Kubernetes/Deployment.yaml`,
- verify service names and ingress host values match your environment.

## Argo CD GitOps (Auto-Sync from Git)

This repository now includes an Argo CD `Application` at `argocd/application.yaml`.

What it does:
- Watches the `main` branch of this Git repository.
- Tracks manifests in the `Kubernetes/` path.
- Automatically applies detected changes to the target cluster.
- Uses `prune` and `selfHeal` to keep cluster state aligned with Git.

### Install Argo CD (if not installed)

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Register This Application

```bash
kubectl apply -f argocd/application.yaml
```

### Verify Sync Status

```bash
kubectl get applications -n argocd
kubectl describe application tic-tac-toe -n argocd
```

### Important

- Update `spec.source.repoURL` in `argocd/application.yaml` if your repository URL differs.
- Ensure Argo CD has access to the repo (for private repos, configure repository credentials in Argo CD).

## Terraform Infrastructure (AWS EKS)

Terraform configuration under `Terraform/` provisions:
- VPC and subnets,
- EKS cluster,
- managed node group,
- supporting security groups and outputs.

Typical workflow:

```bash
cd Terraform
terraform init
terraform plan
terraform apply
```

### Notes

- The backend uses S3 remote state as configured in `Terraform/backend.tf`.
- Ensure your AWS credentials and permissions are configured before apply.

## Project Goal

This project serves as a practical DevSecOps reference implementation for:
- secure CI/CD design,
- containerized frontend delivery,
- Kubernetes deployment patterns,
- infrastructure-as-code provisioning with Terraform.
