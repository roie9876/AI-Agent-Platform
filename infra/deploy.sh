#!/bin/bash
# AI Agent Platform Labs - One-Click Azure Deployment
# Deploys all resources needed for Labs 01-07

set -e

# Configuration
RESOURCE_GROUP="${RESOURCE_GROUP:-rg-agent-platform-labs}"
LOCATION="${LOCATION:-swedencentral}"
BASE_NAME="${BASE_NAME:-agentlabs}"

echo "🚀 AI Agent Platform Labs - Azure Deployment"
echo "=============================================="
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo ""

# Check if logged in
echo "📋 Checking Azure CLI login..."
if ! az account show &> /dev/null; then
    echo "❌ Not logged in. Running 'az login'..."
    az login
fi

# Show current subscription
SUBSCRIPTION=$(az account show --query name -o tsv)
echo "✅ Using subscription: $SUBSCRIPTION"
echo ""

# Create resource group
echo "📦 Creating resource group..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none
echo "✅ Resource group created"

# Deploy Bicep template
echo ""
echo "🔧 Deploying Azure resources..."
echo "   This will deploy:"
echo "   • Azure OpenAI (GPT-4.1, GPT-4o-mini, text-embedding-3-large)"
echo "   • Azure AI Search (for RAG lab)"
echo "   • Azure Cosmos DB Serverless (for memory/state lab)"
echo "   • Azure AI Content Safety (for guardrails lab)"
echo "   • Storage Account (for documents)"
echo ""
echo "   ⏱️  This may take 5-10 minutes..."

DEPLOYMENT_OUTPUT=$(az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file main.bicep \
    --parameters baseName="$BASE_NAME" location="$LOCATION" \
    --query properties.outputs \
    --output json)

echo "✅ Deployment complete!"
echo ""

# Generate .env file
echo "📝 Generating .env file..."

ENV_FILE="../labs/.env"

cat > "$ENV_FILE" << EOF
# ===========================================
# AI Agent Platform Labs - Environment Config
# Generated: $(date)
# Region: $LOCATION
# ===========================================
# ⚠️  This file contains secrets. Never commit it to Git!

# Azure Subscription & Resource Group
AZURE_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
AZURE_RESOURCE_GROUP=$RESOURCE_GROUP
AZURE_LOCATION=$LOCATION

# ── Azure OpenAI ──────────────────────────────────────
AZURE_OPENAI_ENDPOINT=$(echo $DEPLOYMENT_OUTPUT | jq -r '.aiServicesEndpoint.value')
AZURE_OPENAI_API_KEY=$(echo $DEPLOYMENT_OUTPUT | jq -r '.aiServicesKey.value')
AZURE_OPENAI_API_VERSION=2024-12-01-preview

# Model deployments
AZURE_OPENAI_DEPLOYMENT_GPT41=gpt-41
AZURE_OPENAI_DEPLOYMENT_GPT4O_MINI=gpt-4o-mini
AZURE_OPENAI_DEPLOYMENT_EMBEDDING=text-embedding-3-large

# ── Azure AI Foundry (Agents, Evaluations, Tracing) ──
AZURE_AI_FOUNDRY_PROJECT=$(echo $DEPLOYMENT_OUTPUT | jq -r '.foundryProjectName.value')
AZURE_AI_FOUNDRY_RESOURCE=$(echo $DEPLOYMENT_OUTPUT | jq -r '.aiServicesName.value')

# ── Azure AI Search (Lab 03 - RAG) ───────────────────
AZURE_SEARCH_ENDPOINT=$(echo $DEPLOYMENT_OUTPUT | jq -r '.searchServiceEndpoint.value')
AZURE_SEARCH_API_KEY=$(echo $DEPLOYMENT_OUTPUT | jq -r '.searchServiceAdminKey.value')
AZURE_SEARCH_INDEX_NAME=agent-labs-index

# ── Azure Cosmos DB (Lab 03 - Memory & State) ────────
AZURE_COSMOS_ENDPOINT=$(echo $DEPLOYMENT_OUTPUT | jq -r '.cosmosEndpoint.value')
AZURE_COSMOS_KEY=$(echo $DEPLOYMENT_OUTPUT | jq -r '.cosmosKey.value')
AZURE_COSMOS_DATABASE=$(echo $DEPLOYMENT_OUTPUT | jq -r '.cosmosDatabaseName.value')

# ── Azure AI Content Safety (Lab 05 - Guardrails) ────
AZURE_CONTENT_SAFETY_ENDPOINT=$(echo $DEPLOYMENT_OUTPUT | jq -r '.contentSafetyEndpoint.value')
AZURE_CONTENT_SAFETY_KEY=$(echo $DEPLOYMENT_OUTPUT | jq -r '.contentSafetyKey.value')

# ── Azure Storage (Lab 03 - Documents) ───────────────
AZURE_STORAGE_CONNECTION_STRING=$(echo $DEPLOYMENT_OUTPUT | jq -r '.storageConnectionString.value')
AZURE_STORAGE_CONTAINER_DOCUMENTS=documents
EOF

echo "✅ .env file generated at $ENV_FILE"
echo ""
echo "════════════════════════════════════════════════════"
echo "🎉 Setup complete! Next steps:"
echo ""
echo "   1. cd ../labs"
echo "   2. Open lab-00-setup/health-check.ipynb"
echo "   3. Run all cells to validate your setup"
echo "   4. Start with lab-01-react-agent!"
echo ""
echo "💰 Estimated cost: ~\$5-10/day while resources are running"
echo "   Run cleanup.sh when you're done to avoid charges."
echo "════════════════════════════════════════════════════"
