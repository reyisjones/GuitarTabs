# Azure Deployment Script
# This script deploys the Guitar Tabs application to Azure
# Make sure you have Azure CLI installed and are logged in

# Parameters
RESOURCE_GROUP="GuitarTabsRG"
LOCATION="eastus"
ACR_NAME="guitarTabsRegistry"
BACKEND_APP_NAME="guitarTabsBackend"
FRONTEND_APP_NAME="guitarTabsFrontend"
KEY_VAULT_NAME="guitarTabsKV"
CUSTOM_DOMAIN="guitartabs.example.com"  # Replace with your actual domain

# Create Resource Group
echo "Creating Resource Group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Container Registry
echo "Creating Azure Container Registry..."
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic --admin-enabled true

# Get ACR credentials
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query passwords[0].value -o tsv)

# Create Key Vault
echo "Creating Key Vault..."
az keyvault create --name $KEY_VAULT_NAME --resource-group $RESOURCE_GROUP --location $LOCATION

# Store ACR credentials in Key Vault
echo "Storing ACR credentials in Key Vault..."
az keyvault secret set --vault-name $KEY_VAULT_NAME --name "ACR-Username" --value $ACR_USERNAME
az keyvault secret set --vault-name $KEY_VAULT_NAME --name "ACR-Password" --value $ACR_PASSWORD

# Deploy infrastructure using Bicep
echo "Deploying infrastructure with Bicep..."
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file ./infrastructure/main.bicep \
  --parameters \
      baseName=guitarTabs \
      location=$LOCATION \
      containerRegistryUsername=$ACR_USERNAME \
      containerRegistryPassword=$ACR_PASSWORD \
      customDomainName=$CUSTOM_DOMAIN

echo "Deployment completed successfully!"
echo "Next steps:"
echo "1. Configure your domain DNS to point to the Azure Front Door endpoint"
echo "2. Set up SSL certificate for your custom domain"
echo "3. Configure CI/CD pipeline with GitHub Actions using the provided workflow file"
