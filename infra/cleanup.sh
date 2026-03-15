#!/bin/bash
# AI Agent Platform Labs - Cleanup Script
# Removes ALL Azure resources to stop charges

set -e

RESOURCE_GROUP="${RESOURCE_GROUP:-rg-agent-platform-labs}"

echo "🗑️  AI Agent Platform Labs - Cleanup"
echo "======================================"
echo ""
echo "⚠️  This will DELETE the resource group: $RESOURCE_GROUP"
echo "    and ALL resources inside it!"
echo ""
read -p "Are you sure? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "❌ Cancelled."
    exit 0
fi

echo ""
echo "🗑️  Deleting resource group '$RESOURCE_GROUP'..."
az group delete --name "$RESOURCE_GROUP" --yes --no-wait

echo ""
echo "✅ Resource group deletion initiated (runs in background)."
echo "   It may take a few minutes to fully remove all resources."
echo ""
echo "💡 You can check status with:"
echo "   az group show --name $RESOURCE_GROUP --query provisioningState -o tsv"
