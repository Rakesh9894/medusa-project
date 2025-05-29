# README.md

## Medusa Backend Deployment on AWS ECS Fargate with Terraform & GitHub Actions

This project demonstrates Infrastructure as Code (IaC) using **Terraform** to deploy the **Medusa headless commerce backend** on **AWS ECS with Fargate**, along with a **GitHub Actions** CI/CD pipeline.

---

## Architecture

- **Terraform** provisions:
  - VPC, public subnets, internet gateway
  - Security group for ECS and RDS
  - RDS PostgreSQL database
  - ECS Cluster, Task Definition, and Fargate Service
- **Medusa Backend**:
  - Dockerized and deployed to ECS
  - Uses environment variables like `DATABASE_URL` and `JWT_SECRET`
- **GitHub Actions**:
  - On push to `main`, deploys infrastructure via Terraform

---

## How to Use

### 1. Clone the Repository

```bash
git clone https://github.com/talibkhan786/medusa-ecs-fargate.git
cd medusa-ecs-fargate
```

### 2. Set Up Environment Variables

Create a `terraform.tfvars` file or pass variables via CLI:

```hcl
jwt_secret    = "your_jwt_secret"
db_password   = "your_db_password"
```

### 3. Set Up AWS Credentials in GitHub

Go to `Settings > Secrets and variables > Actions` and add:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### 4. Deploy

Push your changes to `main` branch. GitHub Actions will:

- Initialize Terraform
- Plan and apply your infrastructure
- Deploy Medusa backend on ECS

---

## Demo Video

[![Watch the video](https://img.youtube.com/vi/_2-yMCen4F8/0.jpg)](https://www.youtube.com/watch?v=_2-yMCen4F8)

---

## File Structure

```
.
├── Dockerfile                     # Medusa backend container
├── terraform/
│   ├── main.tf                    # ECS, VPC, DB, etc.
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf
├── .github/
│   └── workflows/
│       └── deploy.yml             # GitHub Actions workflow
├── .env.example                   # Example env vars
└── README.md
```

---

## Notes

- Make sure your AWS account has proper permissions for ECS, RDS, and VPC.
- Add a domain + load balancer if you want HTTPS.
- Adjust the Medusa Docker command if you’re using plugins or custom services.

---

## Author

– [@Talib Khan](https://github.com/talibkhan786)
