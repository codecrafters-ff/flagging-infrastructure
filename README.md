# 🏗️ Feature Flags Infrastructure

This repository manages the **cloud infrastructure** for the **Feature Flags Platform**, which includes:

- The **backend API** (built with .NET)
- The **frontend dashboard** (built with Vue.js)
- Supporting services such as **Redis** and **SQL Server**

All infrastructure is defined using **Terraform (Infrastructure as Code)** and deployed to **AWS**.

---

## 📂 Repository Structure

feature-flags-infra/
├── .github/workflows/ → CI/CD automation for Terraform and deployments
├── bootstrap/ → One-time setup for remote Terraform state (S3 + DynamoDB)
├── environments/ → Per-environment Terraform configurations
│ ├── development/ → Dev environment (testing, internal usage)
│ ├── staging/ → Staging environment (QA, integration)
│ └── production/ → Production environment (live deployment)
├── modules/ → Reusable Terraform modules
│ ├── compose/ → Handles Docker Compose deployments on EC2
│ ├── compute-ec2/ → Provisions EC2 instances and security groups
│ ├── dns/ → Manages DNS records, SSL certs, and optional load balancer
│ └── network/ → Creates VPCs, subnets, and networking resources
├── scripts/ → Helper shell scripts for rendering, deployment, and SSM commands
└── templates/ → Template files (e.g., docker-compose.yaml) used for deployments

markdown
Copy code

---

## 🧩 Key Concepts

| **Component**      | **Description**                                                        |
|--------------------|------------------------------------------------------------------------|
| **Terraform**      | Used to define, provision, and manage AWS resources.                   |
| **AWS EC2**        | Hosts Docker Compose deployments for API + Frontend containers.        |
| **AWS SSM**        | Enables secure, keyless remote commands and configuration.             |
| **Docker Compose** | Orchestrates multi-container setup (API, Frontend, Redis, SQL Server). |
| **GitHub Actions** | Automates build, plan, and deploy workflows across environments.       |

---

## ⚙️ How It Works

1. **API & Frontend Repositories**
   - Build and push Docker images to **GitHub Container Registry (GHCR)**.
   - Trigger a `repository_dispatch` event to this infrastructure repository.

2. **Infrastructure Repository**
   - Terraform provisions AWS resources per environment (**Development**, **Staging**, **Production**).
   - AWS **SSM** executes deployment commands on EC2 instances such as:

     ```text
     docker compose pull && docker compose up -d
     ```

3. **Environment Isolation**
   - Each environment has its own **Terraform state**, **variables**, and **resource set**.
   - Promoting changes is done by merging `develop → staging → main`.

---

## 🚀 Environments

| **Environment**  | **Branch** | **Purpose**  | **Trigger**                            |
|------------------|------------|--------------|----------------------------------------|
| 🧪 Development   | `develop`  | Active feature testing | On merge to `develop`        |
| 🚀 Staging       | `staging`  | QA and pre-production testing | On merge to `staging` |
| 🏆 Production    | `main`     | Live production deployment | On merge to `main`       |

---

## Typical Workflow

### Bootstrap Terraform Remote State

Used to create the S3 bucket and DynamoDB table for Terraform state management.

```bash
cd bootstrap
terraform init
terraform apply -auto-approve

cd environments/development
terraform init -backend-config=backend.hcl
terraform apply -auto-approve
```

## Promote to Staging / Production

Merge develop → staging → main

GitHub Actions automatically runs terraform apply for each environment

## Notes for Contributors

Each environment is fully isolated and can be applied independently.

Never commit AWS credentials — use GitHub OIDC authentication for Terraform.

Keep module logic reusable; environment folders should only contain configuration.

Use tags (e.g., Project, Env) on all resources for cost tracking and organization.
