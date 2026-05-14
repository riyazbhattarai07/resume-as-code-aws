# Resume-as-Code: AWS Serverless Infrastructure

> A personal project to host my resume/portfolio on a production-grade, fully automated AWS infrastructure — built to practice and demonstrate real-world cloud engineering skills including IaC, CDN configuration, and security best practices.

A fully automated, highly available, and secure static website hosting architecture built using AWS and Terraform. This project demonstrates AWS Well-Architected principles by deploying a "Resume-as-Code" solution with HTTPS enforcement and automated infrastructure provisioning.

---

## 🏗 Architecture Overview

The infrastructure is designed for high availability and security, ensuring that the source S3 bucket remains private while content is delivered globally via CloudFront.

```
Browser → Route 53 (DNS) + ACM (SSL) → CloudFront (CDN) → OAC → S3 (Private Bucket)
```

> 📌 **Architecture diagram:**

[![Architecture Diagram](https://img.shields.io/badge/Architecture-Interactive_Diagram-orange?style=for-the-badge&logo=amazonaws)](https://riyazbhattarai07.github.io/resume-as-code-aws/aws-resume-architecture.html)

![Architecture Screenshot](Screenshot%202026-05-14%20144943.png)

* **Storage:** AWS S3 (Static Website Hosting)
* **Content Delivery:** AWS CloudFront (CDN)
* **Security:** IAM Policies, CloudFront Origin Access Control (OAC), and AWS Certificate Manager (ACM)
* **DNS:** Route 53
* **IaC:** Terraform

---

## 🚀 Key Features

* **Infrastructure as Code (IaC):** 100% automated provisioning using **Terraform**, ensuring consistent and repeatable environments.
* **Security First:** Uses **Origin Access Control (OAC)** to restrict S3 bucket access solely to CloudFront, keeping the origin shielded from the public internet. This directly prevents the common "S3 bucket leak" vulnerability — no direct public access to the storage layer is ever possible.
* **Global Performance:** Leveraging **CloudFront** edge locations to reduce latency and provide fast content delivery worldwide.
* **HTTPS Enforcement:** Secure communication managed via **ACM** SSL/TLS certificates and **Route 53** DNS records.
* **Well-Architected:** Implements least-privilege **IAM** roles and modular Terraform configurations.

---

## 🛠 Tech Stack

| Component | Service |
| --- | --- |
| **Cloud Provider** | Amazon Web Services (AWS) |
| **Infrastructure** | Terraform |
| **DNS & Delivery** | Route 53, CloudFront |
| **Security** | IAM, ACM, Origin Access Control (OAC) |
| **Storage** | Amazon S3 |

---

## ✅ Prerequisites

Before deploying, make sure you have the following set up:

* **AWS CLI** installed and configured (`aws configure`) with appropriate IAM permissions
* **Terraform** (v1.0+) installed — [Download here](https://developer.hashicorp.com/terraform/downloads)
* **A registered domain** managed by Route 53 (or delegated to Route 53 nameservers)
* **An ACM SSL certificate** provisioned in the **`us-east-1`** region — this is a hard requirement for CloudFront

---

## 📂 Project Structure

```text
├── terraform/
│   ├── main.tf         # Main provider and resource definitions
│   ├── s3.tf           # S3 bucket and policy configurations
│   ├── cloudfront.tf   # CloudFront distribution and OAC
│   ├── dns.tf          # Route 53 and ACM validation
│   ├── variables.tf    # Input variables
│   └── outputs.tf      # Useful resource endpoints
└── website/
    └── index.html      # Your resume/portfolio source code
```

---

## ⚙️ Deployment

1. **Initialize Terraform:**
```bash
terraform init
```

2. **Plan Infrastructure:**
```bash
terraform plan
```

3. **Deploy to AWS:**
```bash
terraform apply
```

4. **Tear Down (when done):**
```bash
terraform destroy
```

> **Terraform State:** This project uses a local state file (`terraform.tfstate`) for simplicity. For team environments, this is easily migratable to a remote backend using an S3 bucket + DynamoDB table for state locking — just update the `backend` block in `main.tf`.

---

## 🔧 Customization

To deploy this for your own domain:

1. Open `terraform/terraform.tfvars`
2. Replace the `domain_name` variable with your own:
```hcl
domain_name = "yourname.com"
```
3. Ensure your domain is registered and managed in **Route 53**, then run `terraform apply`.

---

## 💰 Estimated Cost

This architecture is designed to run at minimal cost. Expected monthly spend for low-traffic personal use:

| Service | Estimated Cost |
| --- | --- |
| S3 (storage + requests) | ~$0.01–$0.05 |
| CloudFront (first 1TB free tier) | ~$0.00–$0.50 |
| Route 53 (hosted zone) | ~$0.50 |
| ACM Certificate | Free |
| **Total** | **~$0.50–$1.00/mo** |

> Always run `terraform destroy` when the infrastructure is no longer needed to avoid unnecessary charges.

---

## 📜 License

This project is licensed under the MIT License.
