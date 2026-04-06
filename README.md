## Azure VM Deployment using Bicep (Modular)

### Overview

This project demonstrates deploying Azure infrastructure using **Bicep (Infrastructure as Code)** with a modular design.

The solution provisions a Linux Virtual Machine along with required networking components, following best practices for reusability, security, and structure.

### Architecture

The deployment includes:

* Virtual Network (VNet)
* Subnet
* Network Security Group (NSG) with SSH access
* Public IP (Standard, Static)
* Network Interface (NIC)
* Linux Virtual Machine (Ubuntu)

### Project Structure

```
.
├── main.bicep
├── modules/
│   ├── network.bicep
│   └── vm.bicep
├── parameters/
│   └── dev.bicepparam
└── README.md
```

### Features

* Modular Bicep design (network and compute separated)
* Parameterized deployments for multiple environments (dev/test/prod)
* SSH-based authentication (no passwords)
* Reusable infrastructure components

### Deployment

#### 1. Create Resource Group

```bash
az group create --name <resource-group> --location centralindia
```

#### 2. Deploy Bicep Template

```bash
az deployment group create \
  --resource-group <resource-group> \
  --template-file main.bicep \
  --parameters parameters/dev.bicepparam
```

### SSH Access

After deployment, connect using:

```bash
ssh <adminUserName>@<public-ip>
```

### Cleanup

```bash
az group delete --name <resource-group> --yes
```

### Key Learnings

* Infrastructure as Code using Bicep
* Modular architecture for scalability and reuse
* Azure networking fundamentals
* Secure VM provisioning using SSH
* Automation of deployment lifecycle

### Technologies Used

* Azure Bicep
* Azure Virtual Machines
* Azure Networking (VNet, NSG, NIC)
* Azure CLI

### Notes

* SSH public key is required during deployment
* No secrets are stored in this repository
* Designed for learning and demonstration purposes

### Future Improvements

* Add Azure Bastion (remove public IP exposure)
* Integrate Azure Key Vault for secrets
* Convert modules into reusable library
* Add CI/CD pipeline (Azure DevOps)