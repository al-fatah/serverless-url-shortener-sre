# Serverless URL Shortener (SRE / Cloud-Native Project)

A production-style **serverless URL shortener** built on AWS, designed with **security, observability, reliability, and CI/CD best practices** in mind.

This project demonstrates how to design, deploy, and operate a real-world cloud service using **Infrastructure as Code**, **zero-trust security controls**, and **automated delivery pipelines**.

---

## ✨ Key Features

- **Serverless architecture** using API Gateway, AWS Lambda, and DynamoDB
- **Custom domain** with HTTPS (ACM + Route53)
- **WAFv2 IP allowlist** with default BLOCK and block-only logging
- **DynamoDB TTL** for automatic expiry of short links
- **X-Ray tracing** enabled for API Gateway and Lambda
- **CloudWatch alarms + SNS alerts** for errors and 5XXs
- **CI/CD with GitHub Actions** using OIDC (no long-lived AWS keys)
- **Terraform-first** design with modular, reusable code

---

## 🏗️ Architecture Overview

**Flow**
1. Client calls `POST /newurl`
2. API Gateway invokes Create Lambda
3. Lambda stores URL in DynamoDB with TTL
4. Client calls `GET /{shortid}`
5. API Gateway invokes Retrieve Lambda
6. Lambda redirects (302) to original URL

**Core AWS Services**
- Amazon API Gateway (REST, REGIONAL)
- AWS Lambda (Python 3.12)
- Amazon DynamoDB (On-Demand, TTL enabled)
- AWS WAFv2 (IP allowlist)
- AWS ACM + Route53 (custom domain)
- Amazon CloudWatch + SNS
- AWS X-Ray
- GitHub Actions (CI/CD)
- Terraform (IaC)

---

## 🔐 Security Design

- **WAF IP Allowlist**
  - Default action: **BLOCK**
  - Only approved IP CIDRs are allowed
- **WAF Logging**
  - Logs **only BLOCK actions**
  - Stored in CloudWatch Log Group:
    `aws-waf-logs-urlshortener-dev`
- **IAM**
  - Separate execution roles for each Lambda
  - Least-privilege access to DynamoDB, logs, and X-Ray
- **OIDC-based CI/CD**
  - GitHub Actions assumes AWS role
  - No static AWS credentials stored in GitHub

---

## 📡 API Endpoints

### Create Short URL
```
POST /newurl
```

**Example**
```bash
curl -X POST https://alfatah-urlshortener.sctp-sandbox.com/newurl   -H "Content-Type: application/json"   -d '{"long_url":"https://openai.com"}'
```

**Response**
```json
{
  "short_url": "https://alfatah-urlshortener.sctp-sandbox.com/AbC123..."
}
```

---

### Redirect to Original URL
```
GET /{shortid}
```

**Example**
```bash
curl -i https://alfatah-urlshortener.sctp-sandbox.com/AbC123
```

**Response**
```
HTTP/2 302
Location: https://openai.com
```

---

## 📊 Observability & Monitoring

- **X-Ray**
  - Enabled on API Gateway stage
  - Enabled on both Lambda functions
- **CloudWatch Alarms**
  - Create Lambda Errors ≥ 1
  - Retrieve Lambda Errors ≥ 1
  - API Gateway 5XX Errors ≥ 1
- **SNS Topic**
  - `urlshortener-dev-alerts`
  - Used as alarm action target

---

## 🚀 CI/CD Pipeline

### Continuous Integration (CI)
Triggered on pull requests:
- Terraform `fmt` & `validate`
- Python unit tests for both Lambdas
- No backend state required

### Continuous Deployment (CD)
Triggered manually or on merge:
- GitHub Actions packages Lambda ZIPs
- Uses **OIDC** to assume AWS role
- Runs `terraform plan` and `apply`
- Uses **remote Terraform state** (S3 + DynamoDB lock)

---

## 📁 Repository Structure

```
.
├── src/
│   ├── create-url-lambda/
│   └── retrieve-url-lambda/
├── terraform/
│   ├── modules/
│   │   ├── apigw/
│   │   ├── custom_domain/
│   │   ├── dynamodb/
│   │   ├── lambdas/
│   │   ├── observability/
│   │   └── waf/
│   └── env/dev/
├── scripts/
│   └── package_lambda.sh
└── .github/workflows/
    ├── ci.yml
    └── cd.yml
```

---

## 🧪 Local Development

### Package Lambdas
```bash
./scripts/package_lambda.sh create
./scripts/package_lambda.sh retrieve
```

### Terraform (local)
```bash
cd terraform/env/dev
terraform init
terraform plan
terraform apply
```

---

## 🛣️ Roadmap / Improvements

- Rate limiting per IP
- Custom short aliases
- Analytics dashboard (CloudWatch or QuickSight)
- Canary deployments for Lambda
- Multi-environment setup (dev / prod)
- OpenTelemetry export

---

## 🎯 Why This Project Matters

This project is intentionally built to reflect **real-world cloud engineering practices**, including:

- Secure-by-default architecture
- Operational visibility
- Infrastructure automation
- Safe deployment workflows
- Clear separation of concerns

It demonstrates not just *how to build*, but *how to operate* a cloud-native service.

---

## 👤 Author

Built by **Alfatah Jalalludin**  
Cloud / DevOps / SRE-focused engineer
