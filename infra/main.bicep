// AI Agent Platform Labs - Azure Infrastructure
// Deploy all required Azure resources with one command
//
// Resources deployed:
//   - Azure OpenAI (GPT-4o, GPT-4o-mini, text-embedding-3-large)
//   - Azure AI Foundry Project (Agents, Evaluations, Tracing)
//   - Azure AI Search (vector + semantic search for RAG labs)
//   - Azure Cosmos DB (thread/state storage for memory labs)
//   - Azure AI Content Safety (guardrails for tools & safety lab)
//   - Storage Account (document storage for RAG lab)

// ============================================================================
// PARAMETERS
// ============================================================================

@description('Base name for all resources')
param baseName string = 'agentlabs'

@description('Azure region for deployment')
@allowed([
  'swedencentral'
  'eastus2'
  'westus3'
])
param location string = 'swedencentral'

@description('Tags to apply to all resources')
param tags object = {
  project: 'AI-Agent-Platform-Labs'
  environment: 'development'
  SecurityControl: 'Ignore'
}

// ============================================================================
// VARIABLES
// ============================================================================

var uniqueSuffix = uniqueString(resourceGroup().id)
var storageAccountName = '${baseName}${uniqueSuffix}'
var searchServiceName = 'search-${baseName}-${uniqueSuffix}'
var aiServicesName = 'ai-${baseName}-${uniqueSuffix}'
var cosmosAccountName = 'cosmos-${baseName}-${uniqueSuffix}'
var contentSafetyName = 'safety-${baseName}-${uniqueSuffix}'

// ============================================================================
// AZURE OPENAI + AI SERVICES (Unified Resource)
// ============================================================================

resource aiServices 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' = {
  name: aiServicesName
  location: location
  tags: tags
  kind: 'AIServices'
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: aiServicesName
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    allowProjectManagement: true
  }
}

// GPT-4.1 deployment (primary model for labs)
resource gpt41Deployment 'Microsoft.CognitiveServices/accounts/deployments@2024-04-01-preview' = {
  parent: aiServices
  name: 'gpt-41'
  sku: {
    name: 'Standard'
    capacity: 30
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4.1'
      version: '2025-04-14'
    }
    raiPolicyName: 'Microsoft.DefaultV2'
  }
}

// GPT-4o-mini deployment (cheap model for routing lab)
resource gpt4oMiniDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-04-01-preview' = {
  parent: aiServices
  name: 'gpt-4o-mini'
  sku: {
    name: 'Standard'
    capacity: 60
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o-mini'
      version: '2024-07-18'
    }
    raiPolicyName: 'Microsoft.DefaultV2'
  }
  dependsOn: [gpt41Deployment]
}

// Embedding deployment (for RAG lab)
resource embeddingDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-04-01-preview' = {
  parent: aiServices
  name: 'text-embedding-3-large'
  sku: {
    name: 'Standard'
    capacity: 80
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'text-embedding-3-large'
      version: '1'
    }
    raiPolicyName: 'Microsoft.DefaultV2'
  }
  dependsOn: [gpt4oMiniDeployment]
}

// ============================================================================
// AZURE AI SEARCH (for RAG lab - Lab 03)
// ============================================================================

resource searchService 'Microsoft.Search/searchServices@2023-11-01' = {
  name: searchServiceName
  location: location
  tags: tags
  sku: {
    name: 'standard'  // Standard tier required for Agentic Retrieval + semantic search
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
    hostingMode: 'default'
    semanticSearch: 'standard'
  }
}

// ============================================================================
// AZURE COSMOS DB (for memory/state - Lab 03, relates to Ch 5-6)
// ============================================================================

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-11-15' = {
  name: cosmosAccountName
  location: location
  tags: tags
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    capabilities: [
      {
        name: 'EnableServerless'  // Serverless = pay per request, perfect for labs
      }
    ]
  }
}

// Cosmos DB database
resource cosmosDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-11-15' = {
  parent: cosmosAccount
  name: 'agent-platform'
  properties: {
    resource: {
      id: 'agent-platform'
    }
  }
}

// Container for chat threads/state
resource threadsContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-11-15' = {
  parent: cosmosDatabase
  name: 'threads'
  properties: {
    resource: {
      id: 'threads'
      partitionKey: {
        paths: ['/thread_id']
        kind: 'Hash'
      }
      defaultTtl: 604800  // 7 days TTL for lab data
    }
  }
}

// Container for agent memory
resource memoryContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-11-15' = {
  parent: cosmosDatabase
  name: 'memory'
  properties: {
    resource: {
      id: 'memory'
      partitionKey: {
        paths: ['/user_id']
        kind: 'Hash'
      }
      defaultTtl: 604800
    }
  }
}

// ============================================================================
// AZURE AI CONTENT SAFETY (for guardrails - Lab 05)
// ============================================================================

resource contentSafety 'Microsoft.CognitiveServices/accounts@2023-10-01-preview' = {
  name: contentSafetyName
  location: location
  tags: tags
  kind: 'ContentSafety'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: contentSafetyName
    publicNetworkAccess: 'Enabled'
  }
}

// ============================================================================
// STORAGE ACCOUNT (for documents - Lab 03 RAG)
// ============================================================================

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: take(storageAccountName, 24)
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}

resource documentsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storageAccount.name}/default/documents'
  properties: {
    publicAccess: 'None'
  }
}

// ============================================================================
// AZURE AI FOUNDRY PROJECT (New Foundry - not classic Hub)
// The AIServices resource above IS the Foundry resource.
// This creates a project under it for Agents, Evaluations, Tracing, etc.
// ============================================================================

resource foundryProject 'Microsoft.CognitiveServices/accounts/projects@2025-04-01-preview' = {
  parent: aiServices
  name: '${baseName}-project'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
  dependsOn: [embeddingDeployment]  // Wait for all model deployments to finish first
}

// ============================================================================
// OUTPUTS (used by deploy.sh to generate .env)
// ============================================================================

output aiServicesEndpoint string = aiServices.properties.endpoint
output aiServicesKey string = aiServices.listKeys().key1
output aiServicesName string = aiServices.name

output foundryProjectName string = foundryProject.name

output searchServiceEndpoint string = 'https://${searchService.name}.search.windows.net'
output searchServiceAdminKey string = searchService.listAdminKeys().primaryKey

output cosmosEndpoint string = cosmosAccount.properties.documentEndpoint
output cosmosKey string = cosmosAccount.listKeys().primaryMasterKey
output cosmosDatabaseName string = cosmosDatabase.name

output contentSafetyEndpoint string = contentSafety.properties.endpoint
output contentSafetyKey string = contentSafety.listKeys().key1

output storageAccountName string = storageAccount.name
output storageConnectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
