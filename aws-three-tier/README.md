# AWS 3-Tier Architecture with ECS Fargate & Terraform

This project provisions a modern, scalable 3-tier cloud infrastructure on AWS using Terraform as Infrastructure as Code (IaC). It features a completely serverless backend (Fargate), a secure static frontend (S3 + CloudFront), and a fully automated CI/CD pipeline.

## 🏗 Architecture Overview

| Tier         |    Technology   | Description |
|--------------|-----------------|-------------|
| **Frontend** | S3 + CloudFront | Static assets served via global CDN. Direct S3 access is blocked via Origin Access Control (OAC). |

| **Backend**  |  ECS Fargate    | PHP Application running in Docker containers. No EC2 management required. |

| **Database** | RDS MySQL       | Private relational database. |

| **CI/CD**    | CodePipeline    | Automates build and deploy from GitHub to ECS. |


### Key Features
* **Modular Terraform:** 
Separate modules for Networking, Database, Backend, Frontend, and CI/CD.

* **Multi-Environment Support:** 
    * `Dev`: Cost-optimized (Free tier eligible resources where possible, Single-AZ).
    * `Prod`: Performance-optimized (Multi-AZ, High Availability).

* **Security:** 
    * VPC with Public/Private subnets.
    * Database and ECS tasks isolated in Private subnets.
    * Least Privilege IAM roles.

## 🚀 Deployment Guide

### Prerequisites
* Terraform installed (`v1.0+`)
* AWS CLI configured
* A GitHub repository containing your PHP application code and a `buildspec.yml`.

### Step 1: Initialize Terraform
Navigate to the desired environment folder (e.g., `dev`):

```bash
cd environments/dev
terraform init