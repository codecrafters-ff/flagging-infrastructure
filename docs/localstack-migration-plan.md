# LocalStack Migration and Adaptation Plan

This document reviews the current Terraform AWS infrastructure and proposes a practical, beginner-friendly migration path for adding a LocalStack deployment mode while keeping the real AWS path intact.

## 1. Repository Analysis Report

### Current repository structure

```text
.
├── .github/workflows/
│   ├── terraform-deploy.yml
│   └── terraform-validate.yml
├── bootstrap/
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   └── variables.tf
├── environments/development/
│   ├── backend/
│   │   ├── backend.hcl
│   │   ├── compute.tf
│   │   ├── main.tf
│   │   ├── network.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   ├── secrets.tf
│   │   └── variables.tf
│   └── frontend/
│       ├── backend.hcl
│       ├── compute.tf
│       ├── main.tf
│       ├── network.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── secrets.tf
│       └── variables.tf
├── modules/
│   ├── compute-ec2/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── user-data.sh
│   │   └── variables.tf
│   ├── network/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── secrets/
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── ssh/ff-dev-admin.pub
└── README.md
```

### Terraform roots, modules, variables, outputs, backends, providers, scripts, CI/CD, and docs

| Area | Files | Notes |
| --- | --- | --- |
| Remote-state bootstrap root | `bootstrap/*.tf` | Creates the real AWS S3 state bucket and DynamoDB lock table. |
| Development backend root | `environments/development/backend/*.tf`, `backend.hcl` | Deploys backend network, EC2, EIP, S3 test bucket, and SSM parameters. |
| Development frontend root | `environments/development/frontend/*.tf`, `backend.hcl` | Deploys frontend network, EC2, EIP, S3 test bucket, and GHCR SSM parameter. |
| Network module | `modules/network/*.tf` | Creates VPC, public subnets, internet gateway, route table, route associations, and security group. |
| Compute module | `modules/compute-ec2/*.tf`, `user-data.sh` | Looks up Amazon Linux 2023 AMI, creates IAM role/policy attachment/instance profile, EC2 instance, optional key pair, and host bootstrap script. |
| Secrets module | `modules/secrets/*.tf` | Creates optional SSM SecureString parameters for app/runtime secrets. |
| Static SSH public key | `ssh/ff-dev-admin.pub` | Used when `create_key_pair = true`. |
| CI/CD workflows | `.github/workflows/terraform-deploy.yml`, `.github/workflows/terraform-validate.yml` | Validation, linting, PR planning, and branch-based deployment. |
| Documentation | `README.md` | High-level architecture and AWS workflow. Some folders documented there, such as staging/production/scripts/templates, are not currently present. |

### AWS services and Terraform resources currently used

| AWS service | Terraform resource/data source | Location | LocalStack suitability | Recommendation |
| --- | --- | --- | --- | --- |
| S3 | `aws_s3_bucket`, `aws_s3_bucket_versioning`, `aws_s3_bucket_lifecycle_configuration`, `aws_s3_bucket_server_side_encryption_configuration` | `bootstrap/main.tf`, development stack `main.tf` files | Suitable for API/Terraform behavior testing. Lifecycle/encryption semantics may be less meaningful than AWS. | Test S3 creation locally. Keep real backend bucket bootstrap AWS-only unless intentionally testing state bootstrap. |
| DynamoDB | `aws_dynamodb_table` | `bootstrap/main.tf` | Suitable for table creation and simple lock-table shape validation. | Test bootstrap shape locally if desired, but use local backend for the LocalStack app stacks by default. |
| VPC | `aws_vpc` | `modules/network/main.tf` | Partially suitable. Terraform can create/list it, but real packet routing is not equivalent to AWS. | Keep for Terraform graph validation; do not treat as network runtime proof. |
| Subnets | `aws_subnet` | `modules/network/main.tf` | Partially suitable. | Keep for dependency validation only. |
| Internet Gateway | `aws_internet_gateway` | `modules/network/main.tf` | Partially suitable/not runtime meaningful. | Keep only if LocalStack accepts it; otherwise conditionally disable in local mode. |
| Route tables/routes | `aws_route_table`, `aws_route_table_association` | `modules/network/main.tf` | Partially suitable/not runtime meaningful. | Keep for plan validation; do not use as proof of public routing. |
| Security Groups | `aws_security_group` | `modules/network/main.tf` | Partially suitable. Rule objects can be validated; packet filtering behavior is not AWS-equivalent. | Keep for Terraform validation; do not use as security runtime proof. |
| EC2 AMI lookup | `data.aws_ami` | `modules/compute-ec2/main.tf` | Weak for local use. LocalStack usually needs mocked image IDs or seeded data. | Replace with `ami_id` variable in local mode or skip EC2. |
| EC2 instances | `aws_instance` | `modules/compute-ec2/main.tf` | Partially suitable for API shape only. It will not launch a real Amazon Linux host running Docker/user_data like AWS. | Make EC2 optional locally. Use LocalStack for Terraform validation, not app runtime validation. |
| EIP | `aws_eip` | development stack `main.tf` files | Partially suitable/not meaningful. Public IP association does not prove internet reachability. | Disable by default in LocalStack or keep only for API-shape testing. |
| IAM role | `aws_iam_role` | `modules/compute-ec2/main.tf` | Suitable for CRUD/policy document validation. | Keep in LocalStack if EC2 module is enabled; useful to validate names and assume-role policy. |
| IAM managed policy attachment | `aws_iam_role_policy_attachment` | `modules/compute-ec2/main.tf` | Partially suitable. Attachment object can be created, but AWS managed policy behavior is not truly enforced. | Keep for shape validation. |
| IAM instance profile | `aws_iam_instance_profile` | `modules/compute-ec2/main.tf` | Suitable for CRUD validation. | Keep if EC2 module is enabled. |
| EC2 key pair | `aws_key_pair` | `modules/compute-ec2/main.tf` | Suitable for CRUD validation. | Keep only if EC2 local mode is enabled. |
| SSM Parameter Store | `aws_ssm_parameter` | `modules/secrets/main.tf` | Suitable for parameter creation/get/list testing. SecureString encryption is not equivalent to KMS-backed AWS security. | Good LocalStack candidate. Use mock secret values locally. |
| Random provider | `random_id` | development stack `main.tf` files | Fully local Terraform provider, not AWS. | Keep unchanged. |

### Resources mentioned in README but not implemented in this repository

The README mentions Redis, SQL Server, Docker Compose deployment, DNS, SSL certificates, optional load balancer, scripts, and templates. Those runtime/application pieces are not currently represented by Terraform files in this repository, except indirectly through the EC2 `user-data.sh` bootstrap script and SSM/GHCR-related variables.

## 2. Current Real AWS Architecture Summary

### Simple architecture explanation

The repository currently has a one-time bootstrap root and two active development Terraform roots: `backend` and `frontend`.

1. `bootstrap/` creates a real S3 bucket for Terraform state and a DynamoDB table for state locking.
2. Each development stack initializes against that S3 backend.
3. Each development stack creates its own public VPC-style network.
4. Each stack creates one EC2 host in the first public subnet.
5. The EC2 host receives an IAM instance profile with SSM permissions.
6. The EC2 host runs `user-data.sh` to install Docker, create Linux users, configure SSH, create `/app/flagging-api`, and optionally install Node.js for frontend hosts.
7. Each stack creates a test S3 bucket.
8. Each stack allocates and associates an Elastic IP.
9. The backend stack creates SSM SecureString parameters for SQL Server, Redis, admin key, and GHCR token. The frontend stack creates a GHCR token parameter.

### Dependency flow

```text
bootstrap S3/DynamoDB
  └── Terraform remote state for environment stacks

environment stack
  ├── random_id ───> S3 test bucket name
  ├── network module
  │   ├── VPC
  │   ├── internet gateway
  │   ├── public subnets
  │   ├── route table + associations
  │   └── security group
  ├── secrets module ───> SSM parameters
  └── compute module
      ├── AMI data lookup
      ├── IAM role
      ├── IAM policy attachment
      ├── IAM instance profile
      ├── optional EC2 key pair
      └── EC2 instance
           └── EIP association
```

### Core infrastructure vs app/runtime-specific resources

| Category | Resources |
| --- | --- |
| Core platform infrastructure | S3 backend bucket, DynamoDB lock table, VPC, subnets, internet gateway, route table, route table associations, security group, IAM role, IAM policy attachment, IAM instance profile. |
| App/runtime-specific infrastructure | EC2 instance, EIP, EC2 key pair, EC2 user data, SSM app parameters, GHCR token parameter, test S3 buckets. |
| App runtime not fully modeled in Terraform | Docker Compose services, .NET API containers, Vue frontend containers, Redis container, SQL Server container, deployment commands via SSM. |

## 3. LocalStack Feasibility Analysis

### What LocalStack can realistically emulate here

LocalStack can be very useful for validating that Terraform can create AWS-shaped resources and that basic AWS APIs are called correctly. For this repository, the strongest LocalStack candidates are:

- S3 bucket creation and bucket metadata checks.
- DynamoDB table creation for the bootstrap lock-table shape.
- SSM Parameter Store CRUD with mock secrets.
- IAM role, instance profile, and key pair object creation.
- VPC/subnet/security group/route-table object creation, as Terraform dependency validation.

### What LocalStack cannot fully emulate here

LocalStack should not be treated as a real EC2/public-networking test bed for this repository. In particular:

- `aws_instance` does not prove that an Amazon Linux VM actually booted.
- `user_data.sh` is not meaningfully validated by creating an EC2 resource in LocalStack.
- `aws_eip` does not prove public internet reachability.
- security groups do not prove real packet filtering.
- subnets, route tables, and internet gateways do not prove AWS-style routing behavior.
- the SSM agent running on EC2 and remote command workflows are not validated unless separately mocked or tested elsewhere.

### Terraform validation vs runtime validation

| Validation type | LocalStack value | What it proves | What it does not prove |
| --- | --- | --- | --- |
| Terraform syntax validation | High | Files parse and modules load. | Provider calls and AWS semantics. |
| Terraform plan against LocalStack | High | Provider config, graph, variables, and many AWS API calls work without real AWS. | Real AWS quotas, IAM enforcement, EC2 boot behavior, public networking. |
| Terraform apply against LocalStack | Medium/high for S3/SSM/IAM; low/medium for EC2/VPC | Resources can be created in the emulator. | Real cloud behavior. |
| App runtime validation | Low | Very little unless a separate Docker Compose app test is added. | Real EC2, SSM, Docker install, DNS, public ingress. |

### Resources to skip, mock, replace, or conditionally disable locally

| Resource | LocalStack mode recommendation |
| --- | --- |
| `data.aws_ami.al2023` | Replace with an explicit `ami_id` variable in LocalStack mode or skip EC2. |
| `aws_instance.app_server` | Disable by default locally with `enable_ec2 = false`; allow opt-in API-shape testing. |
| `aws_eip.dev_app` | Disable by default locally with `enable_eip = false` or make it depend on `enable_ec2`. |
| `user_data.sh` | Do not rely on LocalStack EC2. Validate with `shellcheck` and/or separate container-based tests. |
| S3 backend | Use local Terraform state for LocalStack app stacks. Do not point local tests at real S3 backend. |
| SSM SecureString values | Use mock values only. Never use production/dev real secrets locally. |

## 4. Recommended Dual-Mode Architecture

### Recommended repository layout

The cleanest long-term layout is to separate deployment roots from reusable modules and put AWS and LocalStack roots side by side:

```text
.
├── envs/
│   ├── aws/
│   │   ├── development/
│   │   │   ├── backend/
│   │   │   └── frontend/
│   │   ├── staging/
│   │   │   ├── backend/
│   │   │   └── frontend/
│   │   └── production/
│   │       ├── backend/
│   │       └── frontend/
│   └── localstack/
│       ├── backend/
│       └── frontend/
├── modules/
│   ├── compute-ec2/
│   ├── network/
│   └── secrets/
├── bootstrap/
├── scripts/
├── docs/
├── docker-compose.localstack.yml
└── Makefile
```

To minimize churn, this can be phased in:

1. Keep `environments/development/{backend,frontend}` as the current AWS roots.
2. Add `environments/localstack/{backend,frontend}` as new local roots that reuse the same modules.
3. Later, optionally rename `environments` to `envs/aws` after CI paths and docs are stable.

### Mode 1: Real AWS

- Provider: normal `hashicorp/aws` provider.
- Credentials: real AWS credentials, preferably GitHub OIDC in CI and a named AWS profile locally.
- State: S3 backend with DynamoDB locking.
- Resources: full cloud infrastructure, including EC2 and EIP.

### Mode 2: LocalStack

- Provider: `hashicorp/aws` pointed at `http://localhost:4566`, or `tflocal` wrapper.
- Credentials: mock credentials such as `AWS_ACCESS_KEY_ID=test` and `AWS_SECRET_ACCESS_KEY=test`.
- State: local Terraform state under the LocalStack environment directory.
- Resources: S3/SSM/IAM/network resources by default; EC2/EIP disabled by default unless explicitly testing API shape.

## 5. Terraform Provider and Backend Changes

### Recommended approach: both, with `tflocal` as the beginner default

| Option | Pros | Cons | Recommendation |
| --- | --- | --- | --- |
| `tflocal` wrapper | Simple; automatically injects LocalStack endpoints; beginner-friendly. | Extra tool dependency; endpoint behavior may be less explicit in code. | Use as default local workflow. |
| Manual provider endpoints | Explicit, reviewable, CI-friendly, no magic. | Verbose; easy to miss a service endpoint or safety flag. | Keep a checked-in `provider.localstack.tf` in local roots. |
| Both | Easy local UX plus explicit code documentation. | Slightly more docs to maintain. | Best fit for this repo. |

### Example `provider.localstack.tf`

Use this in `environments/localstack/backend/provider.localstack.tf` and `environments/localstack/frontend/provider.localstack.tf`:

```hcl
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  backend "local" {
    path = "terraform.localstack.tfstate"
  }
}

provider "aws" {
  region                      = var.aws_region
  access_key                  = "test"
  secret_key                  = "test"
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway     = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    ec2            = "http://localhost:4566"
    iam            = "http://localhost:4566"
    s3             = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
    ssm            = "http://localhost:4566"
    sts            = "http://localhost:4566"
  }

  default_tags {
    tags = {
      Project        = "flagging-infra"
      ManagedBy      = "Terraform"
      DeploymentMode = "localstack"
    }
  }
}
```

### How to avoid mixing real AWS and LocalStack

- Put LocalStack roots in a separate directory from AWS roots.
- Use a local backend for LocalStack; never reuse `backend.hcl`.
- Export mock credentials in the LocalStack workflow.
- Add `DeploymentMode = "localstack"` tags in the LocalStack provider.
- Use `AWS_ENDPOINT_URL=http://localhost:4566` for CLI verification.
- Add CI checks that fail if LocalStack jobs use real AWS credential configuration actions.
- Use naming prefixes such as `ff-local-backend` and `ff-local-frontend` for local stacks.

### Backend separation

Real AWS backend example:

```bash
terraform -chdir=environments/development/backend init -reconfigure \
  -backend-config=backend.hcl
```

LocalStack backend example:

```bash
terraform -chdir=environments/localstack/backend init -reconfigure
```

### Safe commands: real AWS

```bash
export AWS_PROFILE=your-real-aws-profile
terraform -chdir=bootstrap init
terraform -chdir=bootstrap plan
terraform -chdir=bootstrap apply

terraform -chdir=environments/development/backend init -reconfigure -backend-config=backend.hcl
terraform -chdir=environments/development/backend plan
terraform -chdir=environments/development/backend apply
terraform -chdir=environments/development/backend destroy
```

### Safe commands: LocalStack

```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=af-south-1
export AWS_ENDPOINT_URL=http://localhost:4566

terraform -chdir=environments/localstack/backend init -reconfigure
terraform -chdir=environments/localstack/backend plan -var-file=localstack.tfvars
terraform -chdir=environments/localstack/backend apply -var-file=localstack.tfvars
terraform -chdir=environments/localstack/backend destroy -var-file=localstack.tfvars
```

With `tflocal`:

```bash
tflocal -chdir=environments/localstack/backend init -reconfigure
tflocal -chdir=environments/localstack/backend plan -var-file=localstack.tfvars
tflocal -chdir=environments/localstack/backend apply -var-file=localstack.tfvars
tflocal -chdir=environments/localstack/backend destroy -var-file=localstack.tfvars
```

## 6. Variables and Conditional Logic

### Existing root variables

| Variable | Current use |
| --- | --- |
| `aws_region` | Provider region; defaults to `af-south-1`. |
| `sa_password` | Backend SSM parameter. |
| `redis_password` | Backend SSM parameter. |
| `admin_key` | Backend SSM parameter. |
| `ghcr_token` | Backend/frontend SSM parameter. |
| `allowed_ssh_cidrs` | Security group SSH ingress. |
| `allowed_api_cidrs` | Security group API ingress. |
| `allowed_cms_cidrs` | Backend security group CMS ingress. |

### Recommended new variables

| Variable | Type | Default | Purpose |
| --- | --- | --- | --- |
| `deployment_mode` | `string` | `"aws"` in AWS roots, `"localstack"` in local roots | Hard safety label and naming/tagging input. |
| `environment` | `string` | `"development"` or `"local"` | Avoid hardcoding environment strings in multiple files. |
| `enable_ec2` | `bool` | `true` in AWS, `false` in LocalStack | Disable weak EC2 runtime testing locally. |
| `enable_eip` | `bool` | `true` in AWS, `false` in LocalStack | Disable public IP emulation locally by default. |
| `enable_key_pair` | `bool` | existing behavior | Make key-pair behavior explicit per root. |
| `ami_id` | `string` nullable | `null` | Allow fixed/mock AMI ID locally and avoid `data.aws_ami`. |
| `enable_remote_state` | `bool` | not used directly by Terraform backend | Document/scripting guard; Terraform backend cannot be dynamically conditional. |

### Example conditional patterns

Root-level module gating:

```hcl
module "compute" {
  count  = var.enable_ec2 ? 1 : 0
  source = "../../../modules/compute-ec2"

  name_prefix       = var.name_prefix
  environment       = var.environment
  environment_type  = var.environment_type
  subnet_ids        = module.network.public_subnet_ids
  security_group_id = module.network.host_sg_id
  key_name          = var.key_name
  create_key_pair   = var.enable_key_pair
  ami_id            = var.ami_id
}

resource "aws_eip" "dev_app" {
  count    = var.enable_ec2 && var.enable_eip ? 1 : 0
  instance = module.compute[0].instance_id
  domain   = "vpc"
  tags     = { Name = "${var.name_prefix}-eip" }
}

output "instance_public_ip" {
  value = var.enable_ec2 ? module.compute[0].instance_public_ip : null
}
```

AMI lookup gating inside `modules/compute-ec2`:

```hcl
variable "ami_id" {
  description = "Optional AMI ID override. Use a mock AMI ID for LocalStack."
  type        = string
  default     = null
}

data "aws_ami" "al2023" {
  count       = var.ami_id == null ? 1 : 0
  most_recent = true
  owners      = ["amazon"]
  # filters unchanged
}

locals {
  effective_ami_id = var.ami_id != null ? var.ami_id : data.aws_ami.al2023[0].id
}

resource "aws_instance" "app_server" {
  ami = local.effective_ami_id
  # remaining arguments unchanged
}
```

## 7. Docker Compose / LocalStack Setup

### Proposed `docker-compose.localstack.yml`

```yaml
services:
  localstack:
    image: localstack/localstack:latest
    container_name: flagging-infra-localstack
    ports:
      - "4566:4566"
      - "4510-4559:4510-4559"
    environment:
      SERVICES: s3,dynamodb,ec2,iam,ssm,sts,cloudwatch,secretsmanager
      AWS_DEFAULT_REGION: af-south-1
      DEBUG: "0"
      PERSISTENCE: "1"
      LS_LOG: warn
    volumes:
      - localstack-data:/var/lib/localstack
      - /var/run/docker.sock:/var/run/docker.sock

volumes:
  localstack-data:
```

### LocalStack commands

```bash
# Start
 docker compose -f docker-compose.localstack.yml up -d

# Check logs
 docker compose -f docker-compose.localstack.yml logs -f localstack

# Stop but keep persisted state
 docker compose -f docker-compose.localstack.yml down

# Reset LocalStack state
 docker compose -f docker-compose.localstack.yml down -v
```

### AWS CLI verification examples

```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=af-south-1
export AWS_ENDPOINT_URL=http://localhost:4566

aws --endpoint-url=http://localhost:4566 s3api list-buckets
aws --endpoint-url=http://localhost:4566 dynamodb list-tables
aws --endpoint-url=http://localhost:4566 ssm describe-parameters
aws --endpoint-url=http://localhost:4566 ec2 describe-vpcs
aws --endpoint-url=http://localhost:4566 ec2 describe-security-groups
aws --endpoint-url=http://localhost:4566 iam list-roles
```

## 8. Developer Workflow

### LocalStack workflow

1. Start LocalStack:

   ```bash
   docker compose -f docker-compose.localstack.yml up -d
   ```

2. Export mock AWS credentials:

   ```bash
   export AWS_ACCESS_KEY_ID=test
   export AWS_SECRET_ACCESS_KEY=test
   export AWS_DEFAULT_REGION=af-south-1
   export AWS_ENDPOINT_URL=http://localhost:4566
   ```

3. Initialize Terraform for local mode:

   ```bash
   tflocal -chdir=environments/localstack/backend init -reconfigure
   ```

4. Plan:

   ```bash
   tflocal -chdir=environments/localstack/backend plan -var-file=localstack.tfvars
   ```

5. Apply:

   ```bash
   tflocal -chdir=environments/localstack/backend apply -var-file=localstack.tfvars
   ```

6. Verify resources:

   ```bash
   aws --endpoint-url=http://localhost:4566 s3api list-buckets
   aws --endpoint-url=http://localhost:4566 ssm describe-parameters
   aws --endpoint-url=http://localhost:4566 ec2 describe-vpcs
   ```

7. Destroy:

   ```bash
   tflocal -chdir=environments/localstack/backend destroy -var-file=localstack.tfvars
   ```

### Real AWS workflow

1. Authenticate to real AWS using a profile or CI OIDC.
2. Bootstrap remote state only when needed:

   ```bash
   terraform -chdir=bootstrap init
   terraform -chdir=bootstrap apply
   ```

3. Initialize the target real stack with its S3 backend:

   ```bash
   terraform -chdir=environments/development/backend init -reconfigure -backend-config=backend.hcl
   ```

4. Plan and apply only after confirming credentials and account:

   ```bash
   aws sts get-caller-identity
   terraform -chdir=environments/development/backend plan
   terraform -chdir=environments/development/backend apply
   ```

## 9. CI/CD Considerations

### Current workflows

- `.github/workflows/terraform-validate.yml` runs `terraform fmt -check -recursive`, initializes backend/frontend development roots with `-backend=false`, validates, runs TFLint, and on PRs also runs real AWS-backed Terraform plans.
- `.github/workflows/terraform-deploy.yml` deploys development on `develop`, plans staging on `staging`, and plans production on `main`; it uses GitHub OIDC via `aws-actions/configure-aws-credentials`.

### Recommended LocalStack validation workflow

Add a separate workflow, for example `.github/workflows/localstack-validate.yml`, that does not configure real AWS credentials:

```yaml
name: LocalStack Terraform Validation

on:
  pull_request:
    branches: [main, staging, develop]
  workflow_dispatch: {}

permissions:
  contents: read

jobs:
  localstack-plan:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        stack: [backend, frontend]
    env:
      AWS_ACCESS_KEY_ID: test
      AWS_SECRET_ACCESS_KEY: test
      AWS_DEFAULT_REGION: af-south-1
      AWS_ENDPOINT_URL: http://localhost:4566
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - uses: actions/setup-python@v5
        with:
          python-version: "3.x"
      - run: pip install terraform-local
      - run: docker compose -f docker-compose.localstack.yml up -d
      - run: terraform fmt -check -recursive
      - run: tflocal -chdir=environments/localstack/${{ matrix.stack }} init -reconfigure
      - run: tflocal -chdir=environments/localstack/${{ matrix.stack }} validate
      - run: tflocal -chdir=environments/localstack/${{ matrix.stack }} plan -var-file=localstack.tfvars -no-color
```

### Should CI run LocalStack apply?

Prefer `plan` by default. `apply` can be useful for a nightly or manually triggered smoke test, but PR CI should stay fast, deterministic, and low-risk. If `apply` is added, it must use mock credentials only, run in isolated LocalStack state, and destroy afterwards.

## 10. Pros and Cons

### Pros

- Safer local Terraform experimentation without creating real AWS resources.
- No AWS costs for routine validation and learning.
- Faster onboarding for developers who do not have AWS account access yet.
- Good coverage for S3, DynamoDB, IAM object creation, SSM parameter patterns, and Terraform dependency graph validation.
- Clear separation between infrastructure code validation and real runtime/cloud validation.
- Reduced risk when refactoring modules because most provider calls can be tested locally first.

### Cons

- LocalStack is not a perfect AWS replacement.
- EC2 creation does not validate a real Amazon Linux boot.
- Public networking, security groups, route tables, internet gateways, and EIPs are not equivalent to AWS networking behavior.
- `user_data.sh` is not truly validated by LocalStack EC2.
- Service behavior and provider compatibility can differ from AWS.
- There is a false confidence risk if local `apply` is treated as production proof.
- Dual deployment paths introduce extra maintenance.
- CI can become more complex if real AWS and LocalStack paths are not clearly separated.

## 11. Risk and Gotcha Checklist

- [ ] Do not initialize LocalStack roots with real AWS `backend.hcl` files.
- [ ] Do not export real AWS credentials in LocalStack terminal sessions.
- [ ] Confirm `AWS_ENDPOINT_URL=http://localhost:4566` before CLI verification.
- [ ] Use `s3_use_path_style = true` for manual LocalStack provider configuration.
- [ ] Use local state files for LocalStack and S3 remote state for real AWS.
- [ ] Keep resource names distinct, for example `ff-local-*` vs `ff-dev-*`.
- [ ] Use mock secret values in `localstack.tfvars`.
- [ ] Do not assume LocalStack EC2 validates `user_data.sh`.
- [ ] Do not assume LocalStack networking validates AWS routing or ingress.
- [ ] Avoid CI jobs that both configure real AWS credentials and point Terraform at LocalStack.
- [ ] Make EC2 and EIP optional in local roots.
- [ ] Validate real AWS separately before production deployments.
- [ ] Watch for LocalStack service coverage/provider-version differences.

## 12. Documentation Draft: README LocalStack Deployment Section

```markdown
## LocalStack Deployment

This repository supports a planned LocalStack mode for local Terraform validation without creating real AWS resources.

### What LocalStack is for

LocalStack mode is intended to validate Terraform structure, provider calls, resource names, tags, variables, S3 buckets, SSM parameters, IAM objects, and network object creation. It is not a replacement for real AWS validation of EC2 boot, Elastic IP reachability, security group enforcement, public routing, or EC2 user data.

### Prerequisites

- Docker and Docker Compose
- Terraform >= 1.6
- AWS CLI
- Optional: `terraform-local` / `tflocal`

### Start LocalStack

```bash
docker compose -f docker-compose.localstack.yml up -d
```

### Use mock credentials

```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=af-south-1
export AWS_ENDPOINT_URL=http://localhost:4566
```

### Plan locally

```bash
tflocal -chdir=environments/localstack/backend init -reconfigure
tflocal -chdir=environments/localstack/backend plan -var-file=localstack.tfvars
```

### Apply and verify locally

```bash
tflocal -chdir=environments/localstack/backend apply -var-file=localstack.tfvars
aws --endpoint-url=http://localhost:4566 s3api list-buckets
aws --endpoint-url=http://localhost:4566 ssm describe-parameters
aws --endpoint-url=http://localhost:4566 ec2 describe-vpcs
```

### Clean up

```bash
tflocal -chdir=environments/localstack/backend destroy -var-file=localstack.tfvars
docker compose -f docker-compose.localstack.yml down -v
```

### Resource support matrix

| Resource family | LocalStack value |
| --- | --- |
| S3 | Good for bucket API testing. |
| DynamoDB | Good for table API testing. |
| SSM | Good for parameter CRUD using mock values. |
| IAM | Good for object creation; policy enforcement is limited. |
| VPC/subnets/routes/security groups | Useful for Terraform graph validation; not real packet networking. |
| EC2/EIP/user_data | Limited; disable by default locally unless testing provider API shape. |
```

## 13. Proposed File-by-File Change Plan

| File/path | Change |
| --- | --- |
| `docker-compose.localstack.yml` | Add LocalStack container with only required services: S3, DynamoDB, EC2, IAM, SSM, STS, CloudWatch, Secrets Manager. |
| `Makefile` | Add safe local commands: `localstack-up`, `localstack-down`, `localstack-reset`, `local-plan-backend`, `local-apply-backend`, `local-destroy-backend`, and AWS commands with explicit profile prompts. |
| `environments/localstack/backend/` | Add a new LocalStack backend stack root reusing `modules/network`, `modules/secrets`, and optionally `modules/compute-ec2`. Use local backend and `provider.localstack.tf`. |
| `environments/localstack/frontend/` | Add a new LocalStack frontend stack root with local backend and mock variables. |
| `environments/localstack/*/localstack.tfvars` | Add mock values and safe CIDRs. Do not include real secrets. |
| `modules/compute-ec2/variables.tf` | Add `ami_id` override and optionally `enable_user_data` if user-data behavior needs to be bypassed locally. |
| `modules/compute-ec2/main.tf` | Gate the AMI data source with `count`, use `local.effective_ami_id`, and keep existing AWS defaults unchanged. |
| `environments/development/*/variables.tf` | Optionally add `environment`, `deployment_mode`, `enable_ec2`, and `enable_eip` with AWS-safe defaults. |
| `environments/development/*/main.tf` | Optionally gate EIP using `enable_eip`; default remains `true`. |
| `.github/workflows/localstack-validate.yml` | Add PR workflow that starts LocalStack and runs `tflocal init/validate/plan` without real AWS credentials. |
| `README.md` | Add a concise LocalStack Deployment section that links to this detailed plan. |

## 14. Terraform Code Snippets

### LocalStack variables example

```hcl
variable "deployment_mode" {
  description = "Deployment target: aws or localstack."
  type        = string
  default     = "localstack"

  validation {
    condition     = contains(["aws", "localstack"], var.deployment_mode)
    error_message = "deployment_mode must be aws or localstack."
  }
}

variable "enable_ec2" {
  description = "Whether to create EC2 resources. Disabled by default for LocalStack."
  type        = bool
  default     = false
}

variable "enable_eip" {
  description = "Whether to create and associate an EIP. Disabled by default for LocalStack."
  type        = bool
  default     = false
}
```

### Example `localstack.tfvars`

```hcl
aws_region         = "af-south-1"
deployment_mode    = "localstack"
environment        = "local"
enable_ec2         = false
enable_eip         = false
allowed_ssh_cidrs  = ["127.0.0.1/32"]
allowed_api_cidrs  = ["127.0.0.1/32"]
allowed_cms_cidrs  = ["127.0.0.1/32"]
admin_key          = "local-admin-key"
sa_password        = "LocalOnlyPassword123!"
redis_password     = "local-redis-password"
ghcr_token         = "local-ghcr-token"
```

## 15. Proposed Makefile

```makefile
LOCALSTACK_COMPOSE=docker-compose.localstack.yml
LOCALSTACK_BACKEND_DIR=environments/localstack/backend
LOCALSTACK_FRONTEND_DIR=environments/localstack/frontend

.PHONY: localstack-up localstack-down localstack-reset local-plan-backend local-apply-backend local-destroy-backend local-plan-frontend local-apply-frontend local-destroy-frontend

localstack-up:
	docker compose -f $(LOCALSTACK_COMPOSE) up -d

localstack-down:
	docker compose -f $(LOCALSTACK_COMPOSE) down

localstack-reset:
	docker compose -f $(LOCALSTACK_COMPOSE) down -v

local-plan-backend:
	AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=af-south-1 AWS_ENDPOINT_URL=http://localhost:4566 \
	tflocal -chdir=$(LOCALSTACK_BACKEND_DIR) init -reconfigure && \
	tflocal -chdir=$(LOCALSTACK_BACKEND_DIR) plan -var-file=localstack.tfvars

local-apply-backend:
	AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=af-south-1 AWS_ENDPOINT_URL=http://localhost:4566 \
	tflocal -chdir=$(LOCALSTACK_BACKEND_DIR) apply -var-file=localstack.tfvars

local-destroy-backend:
	AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=af-south-1 AWS_ENDPOINT_URL=http://localhost:4566 \
	tflocal -chdir=$(LOCALSTACK_BACKEND_DIR) destroy -var-file=localstack.tfvars
```

## 16. Step-by-Step Implementation Order

1. Add `docker-compose.localstack.yml` and verify LocalStack starts.
2. Add `environments/localstack/backend` with local backend, LocalStack provider, mock variables, and only S3/SSM/network initially.
3. Add `environments/localstack/frontend` with the same pattern.
4. Add `ami_id` override to `modules/compute-ec2` without changing AWS defaults.
5. Add `enable_ec2` and `enable_eip` to local roots, defaulting both to `false`.
6. Run `terraform fmt -recursive`.
7. Run `terraform validate` on existing AWS roots with `-backend=false` to confirm no regressions.
8. Start LocalStack and run `tflocal init/validate/plan` for local backend and frontend.
9. Optionally run a LocalStack `apply` smoke test locally and verify with AWS CLI endpoint commands.
10. Add the LocalStack validation workflow after local commands are stable.
11. Add README LocalStack section and troubleshooting notes.
12. Consider separately testing `user-data.sh` with `shellcheck` and/or a container-based Amazon Linux script test.
13. Only after local mode is stable, consider restructuring directories into `envs/aws` and `envs/localstack`; otherwise keep the additive `environments/localstack` layout.
