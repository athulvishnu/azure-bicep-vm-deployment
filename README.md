## Azure VM Deployment (Bicep)

### What this deploys
- Virtual Network
- Subnet
- Network Security Group (SSH enabled)
- Public IP (Static, Standard)
- Linux VM (Ubuntu 22.04)

### How to deploy
```bash
az deployment group create \
  --resource-group <rg-name> \
  --template-file main.bicep \
  --parameters dev.bicepparam
```