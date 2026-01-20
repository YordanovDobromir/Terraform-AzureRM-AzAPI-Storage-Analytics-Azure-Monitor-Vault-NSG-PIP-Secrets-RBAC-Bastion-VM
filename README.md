# Terraform Azure Infrastructure Showcase

This repository showcases using **Terraform** to deploy infrastructure on **Microsoft Azure**
using the **AzureRM** and **AzAPI** providers, based on the course by Mark Tinderholt.

## Project goals
Deploying and managing Azure resources using Infrastructure as Code (IaC),
with support for **Dev** and **Prod** environments.

## Resources deployed
- Azure Storage Account
- Log Analytics Workspace
- Azure Monitor
- Key Vault
- RBAC (Role Assignments)
- Virtual Network & Subnets
- Network Security Groups (NSG)
- Private & Public Keys
- Secrets
- Linux Virtual Machine (SSH access)
- Entra ID integration
- Azure Bastion

## Deployment
Infrastructure is deployed using the `.debug.sh` script, which:
- Initializes Terraform
- Configures the remote backend
- Sets the environment variables
- Applies the selected environment configuration

## Environments
- `dev`
- `prod`

Each environment is isolated and deployed independently.

## Prerequisites
- Terraform
- Azure CLI
- Azure subscription with sufficient permissions

## Disclaimer
This repository is for **learning and demonstration purposes**.
