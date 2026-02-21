# ☁️ פרק 15: Microsoft / Azure Stack

## תוכן עניינים
- [מיפוי HLD ל-Azure](#מיפוי-hld-ל-azure)
- [Azure Full Architecture](#azure-full-architecture)
- [Azure OpenAI Service](#azure-openai-service)
- [Azure AI Search](#azure-ai-search)
- [Azure Cosmos DB](#azure-cosmos-db)
- [Azure Container Apps / AKS](#azure-container-apps--aks)
- [Azure API Management (APIM)](#azure-api-management-apim)
- [Microsoft Entra ID](#microsoft-entra-id)
- [Azure Key Vault](#azure-key-vault)
- [Azure Service Bus](#azure-service-bus)
- [Azure Monitor & App Insights](#azure-monitor--app-insights)
- [Azure Content Safety](#azure-content-safety)
- [Azure AI Foundry](#azure-ai-foundry)
- [Semantic Kernel](#semantic-kernel)
- [יתרונות וחסרונות של Azure Stack](#יתרונות-וחסרונות-של-azure-stack)
- [סיכום ושאלות](#סיכום-ושאלות)

---

## מיפוי HLD ל-Azure

### כל רכיב גנרי → מוצר Azure ספציפי:

| HLD Component (Generic) | Azure Product | למה? |
|-------------------------|---------------|-------|
| **API Gateway** | Azure API Management (APIM) | Rate limiting, Auth, Policies |
| **Identity Provider** | Microsoft Entra ID | SSO, RBAC, Managed Identity |
| **Container Runtime** | Azure Container Apps / AKS | Auto-scale, serverless containers |
| **LLM Provider** | Azure OpenAI Service | GPT-4o, embeddings, enterprise SLA |
| **Vector DB** | Azure AI Search | Vector search, hybrid search, semantic ranking |
| **State Store** | Azure Cosmos DB | Multi-model, global distribution, low latency |
| **Cache** | Azure Cache for Redis | In-memory caching |
| **Message Queue** | Azure Service Bus | Reliable messaging, priority queues |
| **Secret Vault** | Azure Key Vault | Secrets, keys, certificates |
| **Observability** | Azure Monitor + App Insights | Metrics, logs, traces, dashboards |
| **Content Safety** | Azure AI Content Safety | Toxicity, hate, violence detection |
| **Agent Framework** | Semantic Kernel / AutoGen | Agent orchestration SDK |
| **Blob Storage** | Azure Blob Storage | Documents, files |
| **WAF** | Azure Front Door + WAF | DDoS, edge security |
| **Network** | Azure VNet + Private Endpoints | Network isolation |

---

## Azure Full Architecture

```mermaid
graph TB
    User["👤 Users"] --> FD["🌐 Azure Front Door\n+ WAF"]
    Dev["👨‍💻 Developers"] --> Portal["🌐 Developer Portal"]
    
    FD --> APIM["🚪 Azure API Management\nAuth, Rate Limit, Policies"]
    
    subgraph "📋 Control Plane"
        Portal --> ACA_CP["☁️ Azure Container Apps\n(Control Plane Services)"]
        ACA_CP --> CosmosConfig["💾 Cosmos DB\n(Agent Registry, Configs)"]
    end
    
    subgraph "⚙️ Runtime Plane"
        APIM --> ACA_RT["☁️ Azure Container Apps\n(Runtime Services)\nAuto-scale 0-N"]
        ACA_RT --> AOAI["🧠 Azure OpenAI\nGPT-4o, Embeddings"]
        ACA_RT --> AIS["🔍 Azure AI Search\nVector + Hybrid Search"]
        ACA_RT --> Tools["🔧 Tool Execution\n(Sandboxed containers)"]
    end
    
    subgraph "💾 Data Layer"
        ACA_RT --> Cosmos["💾 Azure Cosmos DB\nState, Threads, Memory"]
        ACA_RT --> Redis["📦 Azure Cache for Redis"]
        ACA_RT --> Blob["📁 Azure Blob Storage\nDocuments"]
        ACA_RT --> SB["📫 Azure Service Bus\nAsync tasks"]
    end
    
    subgraph "🔐 Security"
        Entra["🔐 Microsoft Entra ID"]
        KV["🔑 Azure Key Vault"]
        CS["🛡️ Azure Content Safety"]
    end
    
    subgraph "📊 Observability"
        Monitor["📈 Azure Monitor"]
        AppIns["📊 Application Insights"]
        LA["📝 Log Analytics"]
    end
    
    APIM -.-> Entra
    ACA_RT -.-> KV
    ACA_RT -.-> CS
    ACA_RT -.-> AppIns
```

---

## Azure OpenAI Service

### מה זה?
**Azure OpenAI** = שירות של Azure שמספק גישה למודלי OpenAI (GPT-4o, GPT-4o-mini, Embeddings) עם enterprise-grade security.

```mermaid
graph LR
    App["🤖 Agent"] --> AOAI["☁️ Azure OpenAI"]
    
    AOAI --> GPT4o["🧠 GPT-4o\nPowerful, expensive"]
    AOAI --> GPT4oMini["🧠 GPT-4o-mini\nFast, cheap"]
    AOAI --> Embeddings["📐 text-embedding-3\nFor RAG"]
    AOAI --> DALLE["🎨 DALL-E 3\nImage generation"]
```

### למה Azure OpenAI ולא API ישיר של OpenAI?

| Azure OpenAI | OpenAI Direct |
|-------------|---------------|
| ✅ Data stays in your Azure region | ❌ Data goes to OpenAI servers |
| ✅ Enterprise SLA (99.9%) | ⚠️ Best-effort |
| ✅ VNet integration (private) | ❌ Public internet only |
| ✅ Managed Identity auth | 🔑 API key only |
| ✅ Content filtering built-in | ⚠️ Basic |
| ✅ Azure RBAC | ❌ Limited |
| ⚠️ Models available later | ✅ Latest models first |

### Deployment Concepts:

```mermaid
graph TD
    Account["☁️ Azure OpenAI Resource"]
    
    Account --> Deploy1["🧠 Deployment: gpt-4o-main\nModel: GPT-4o\nCapacity: 80K TPM"]
    Account --> Deploy2["🧠 Deployment: gpt-4o-mini-fast\nModel: GPT-4o-mini\nCapacity: 200K TPM"]
    Account --> Deploy3["📐 Deployment: embeddings\nModel: text-embedding-3-large\nCapacity: 350K TPM"]
```

| Term | הסבר |
|------|-------|
| **TPM** | Tokens Per Minute - כמה tokens אפשר לצרוך |
| **Deployment** | Instance של מודל עם capacity מוגדר |
| **Provisioned** | Reserved capacity (מהיר, יקר) |
| **Standard** | Shared capacity (flexible, pay-per-use) |

---

## Azure AI Search

### מה זה?
**Azure AI Search** = שירות חיפוש שתומך ב-**Vector Search**, **Full-Text Search**, ו-**Hybrid Search**.

```mermaid
graph TB
    subgraph "Azure AI Search"
        Index["📋 Search Index"]
        
        Index --> FT["📝 Full-Text Search\nKeyword matching\nBM25 ranking"]
        Index --> VS["📐 Vector Search\nSemantic similarity\nCosine distance"]
        Index --> HS["🔀 Hybrid Search\nFull-text + Vector\nReciprocal Rank Fusion"]
        Index --> SR["🧠 Semantic Ranking\nAI re-ranking\nBetter results"]
    end
```

### RAG with Azure AI Search:

```mermaid
sequenceDiagram
    participant App as 🤖 Agent
    participant AOAI as 🧠 Azure OpenAI
    participant AIS as 🔍 Azure AI Search
    
    App->>AOAI: Embed user query
    AOAI-->>App: Query vector [0.1, 0.3, ...]
    App->>AIS: Hybrid search (text + vector)
    AIS-->>App: Top 5 relevant chunks
    App->>AOAI: Generate answer with context
    AOAI-->>App: Grounded response
```

### Why Azure AI Search for RAG:

| Feature | Benefit |
|---------|---------|
| **Hybrid Search** | Best of keyword + semantic |
| **Semantic Ranking** | AI re-ranks results for quality |
| **Built-in Indexer** | Auto-index from Blob, Cosmos, SQL |
| **Integrated Vectorization** | Auto-embed using Azure OpenAI |
| **Security** | VNet, Managed Identity, RBAC |
| **Scale** | Handle millions of documents |

---

## Azure Cosmos DB

### מה זה?
**Azure Cosmos DB** = globally distributed NoSQL database עם low-latency guarantees.

```mermaid
graph LR
    subgraph "Cosmos DB APIs"
        NoSQL["📄 NoSQL API\n(recommended)"]
        Mongo["🍃 MongoDB API"]
        Postgres["🐘 PostgreSQL API"]
        Table["📊 Table API"]
        Gremlin["🔗 Gremlin (Graph)"]
    end
```

### למה Cosmos DB ל-Agent Platform?

| Use Case | Why Cosmos DB |
|----------|--------------|
| **Thread State** | Low latency reads/writes |
| **Chat History** | Document model fits naturally |
| **Agent Configs** | Schema flexibility |
| **Session Data** | TTL for auto-cleanup |
| **Multi-region** | Global distribution |
| **Multi-tenant** | Hierarchical partition keys |

### Partition Strategy:

```mermaid
graph TD
    Container["💾 Cosmos Container: threads"]
    
    Container --> HPK["Hierarchical Partition Key:\n/tenantId → /agentId → /threadId"]
    
    HPK --> Q1["Query: Get thread\n→ Point read (fastest)"]
    HPK --> Q2["Query: All threads for agent\n→ Within partition"]
    HPK --> Q3["Query: All agents for tenant\n→ Within partition"]
```

### Best Practices:

| Practice | הסבר |
|----------|-------|
| **Hierarchical Partition Keys** | tenantId/agentId/threadId |
| **Singleton CosmosClient** | Don't recreate per request |
| **Async SDK** | Use async APIs for throughput |
| **Retry-after on 429** | Handle rate limiting gracefully |
| **Right-size RUs** | Test and adjust Request Units |

---

## Azure Container Apps / AKS

### ACA vs AKS:

```mermaid
graph TB
    subgraph "☁️ Azure Container Apps (ACA)"
        ACA_F["✅ Serverless containers"]
        ACA_F2["✅ Auto-scale to 0"]
        ACA_F3["✅ Built-in Dapr, KEDA"]
        ACA_F4["✅ Less operational overhead"]
        ACA_F5["⚠️ Less control"]
    end
    
    subgraph "☸️ Azure Kubernetes Service (AKS)"
        AKS_F["✅ Full Kubernetes"]
        AKS_F2["✅ Maximum control"]
        AKS_F3["✅ Complex workloads"]
        AKS_F4["⚠️ Operational overhead"]
        AKS_F5["⚠️ Need K8s expertise"]
    end
```

| | ACA | AKS |
|---|---|---|
| **Complexity** | ✅ Simple | ❌ Complex |
| **Scale to zero** | ✅ Yes | ⚠️ With KEDA |
| **Cost (small)** | ✅ Pay per use | ❌ Always-on nodes |
| **Control** | ⚠️ Limited | ✅ Full |
| **GPU workloads** | ⚠️ Limited | ✅ Supported |
| **Service mesh** | ✅ Built-in Envoy | ⚠️ Manual (Istio) |
| **Best for** | Most agent workloads | Large, complex platforms |

### Recommendation:

```mermaid
graph TD
    Start["🤔 Which compute?"] --> Size{"Team size &\nK8s expertise?"}
    Size -->|"Small team, no K8s"| ACA["☁️ ACA\n(Recommended for POC)"]
    Size -->|"Large team, K8s experts"| Scale{"Scale?"}
    Scale -->|"< 1000 RPS"| ACA
    Scale -->|"> 1000 RPS"| GPU{"Need GPU?"}
    GPU -->|"No"| ACA
    GPU -->|"Yes"| AKS["☸️ AKS"]
```

---

## Azure API Management (APIM)

### מה זה?
**APIM** = API Gateway של Azure. מנהל את כל ה-API traffic.

```mermaid
graph LR
    Client["👤 Client"] --> APIM["🚪 Azure APIM"]
    
    APIM --> Feature1["🔐 Auth (OAuth, JWT)"]
    APIM --> Feature2["⏱️ Rate Limiting"]
    APIM --> Feature3["💰 Quota Management"]
    APIM --> Feature4["📊 Analytics"]
    APIM --> Feature5["🔄 Request Transform"]
    APIM --> Feature6["📋 API Versioning"]
    APIM --> Feature7["🔗 Backend Routing"]
    
    APIM -->|"Route"| Backend["⚙️ Backend Services"]
```

### APIM Policies for Agents:

```
<!-- Rate limiting per tenant -->
<rate-limit-by-key 
  calls="100" 
  renewal-period="60" 
  counter-key="@(context.Request.Headers['X-Tenant-Id'])" />

<!-- Token counting -->
<set-variable name="token-count" 
  value="@(context.Response.Headers['x-openai-usage'])" />

<!-- Route to Azure OpenAI with retry -->
<retry count="3" interval="1" delta="1" max-interval="10">
  <forward-request />
</retry>
```

---

## Microsoft Entra ID

### מה זה?
**Microsoft Entra ID** (formerly Azure AD) = Identity & Access Management.

```mermaid
graph TD
    User["👤 User"] --> Entra["🔐 Microsoft Entra ID"]
    App["🤖 Agent App"] --> Entra
    Service["⚙️ Service"] --> Entra
    
    Entra --> AuthN["✅ Authentication\nWho are you?"]
    Entra --> AuthZ["✅ Authorization\nWhat can you do?"]
    Entra --> MI["✅ Managed Identity\nPasswordless auth"]
    Entra --> SSO["✅ Single Sign-On"]
    Entra --> RBAC2["✅ Azure RBAC"]
```

### Managed Identity:

```mermaid
graph LR
    subgraph "❌ Without Managed Identity"
        App1["🤖 App"] -->|"API Key stored somewhere"| Service1["☁️ Azure Service"]
    end
    
    subgraph "✅ With Managed Identity"
        App2["🤖 App\n(has Managed Identity)"] -->|"Auto-auth, no secrets"| Service2["☁️ Azure Service"]
    end
```

| Feature | Benefit for Agents |
|---------|-------------------|
| **Managed Identity** | No API keys/passwords needed |
| **RBAC** | Fine-grained access per agent/tenant |
| **Conditional Access** | Block access from untrusted networks |
| **Audit Logs** | Who accessed what, when |

---

## Azure Key Vault

### Agent Platform Integration:

```mermaid
graph TD
    subgraph "🔑 Azure Key Vault"
        S1["🔐 OpenAI API Keys"]
        S2["🔐 DB Connection Strings"]
        S3["🔐 Tool API Keys"]
        S4["🔐 Certificates"]
    end
    
    ACA2["☁️ Container App\n(Managed Identity)"] -->|"No passwords needed"| S1 & S2 & S3 & S4
```

---

## Azure Service Bus

### Async Agent Execution:

```mermaid
graph LR
    API2["🚪 APIM"] -->|"Enqueue"| SB2["📫 Azure Service Bus"]
    
    SB2 --> Q1["🔴 High Priority Queue"]
    SB2 --> Q2["🟡 Standard Queue"]
    SB2 --> Q3["🟢 Batch Queue"]
    
    Q1 & Q2 & Q3 --> Workers2["⚙️ Agent Workers\n(Container Apps)"]
```

| Feature | Benefit |
|---------|---------|
| **Sessions** | Ordered processing per thread |
| **Dead-letter queue** | Failed messages preserved |
| **Scheduled delivery** | Delayed processing |
| **Duplicate detection** | Idempotency |
| **Priority** | Premium tier supports priorities |

---

## Azure Monitor & App Insights

### Full Observability Stack:

```mermaid
graph TB
    subgraph "📊 Azure Monitor"
        AppIns2["📈 Application Insights\nAPM, Traces, Metrics"]
        LA2["📝 Log Analytics\nKQL queries, Logs"]
        Alerts2["🚨 Alerts\nReal-time notifications"]
        Workbooks["📊 Workbooks\nCustom dashboards"]
        
        AppIns2 --> LA2
        LA2 --> Alerts2
        LA2 --> Workbooks
    end
```

### Agent-Specific Monitoring:

```
// KQL: Cost per tenant per day
customMetrics
| where name == "agent_llm_cost"
| summarize TotalCost = sum(value) by tenant = tostring(customDimensions.tenant_id), bin(timestamp, 1d)
| order by TotalCost desc

// KQL: Slow agent requests
requests
| where duration > 10000  // > 10 seconds
| project timestamp, name, duration, customDimensions.agent_id, customDimensions.steps
| order by duration desc
| take 20
```

---

## Azure Content Safety

### מה זה?
**Azure AI Content Safety** = שירות שמזהה תוכן מזיק (אלימות, שנאה, מיני, פגיעה עצמית).

```mermaid
graph LR
    AgentOutput["🤖 Agent Output"] --> ACS["🛡️ Azure Content Safety"]
    
    ACS --> V["Violence: 0/7 ✅"]
    ACS --> H["Hate: 0/7 ✅"]
    ACS --> S["Sexual: 1/7 ✅"]
    ACS --> SH["Self-Harm: 0/7 ✅"]
    
    ACS --> Decision{"All < threshold?"}
    Decision -->|"Yes"| Allow2["✅ Allow"]
    Decision -->|"No"| Block2["⛔ Block"]
```

---

## Azure AI Foundry

### מה זה?
**Azure AI Foundry** (formerly Azure AI Studio) = פלטפורמה מלאה לפיתוח AI Apps ו-Agents.

```mermaid
graph TB
    subgraph "🏭 Azure AI Foundry"
        F1["🧠 Model Catalog\nGPT, Llama, Mistral, Phi"]
        F2["🔗 Prompt Flow\nVisual orchestration"]
        F3["📊 Evaluation\nBuilt-in eval metrics"]
        F4["🤖 Agent Service\nManaged agent runtime"]
        F5["🔍 Tracing\nEnd-to-end observability"]
    end
```

### Agent Service:

```mermaid
graph LR
    Foundry["🏭 Azure AI Foundry"] --> AgentSvc["🤖 Agent Service"]
    
    AgentSvc --> Features["Features:\n- Managed runtime\n- Built-in tools\n- Code Interpreter\n- File Search\n- Function Calling\n- Thread management"]
```

---

## Semantic Kernel

### מה זה?
**Semantic Kernel** = SDK של Microsoft לבניית AI Agents. זה ה-"framework" לכתיבת ה-Agent logic.

```mermaid
graph TB
    subgraph "🧩 Semantic Kernel"
        Kernel["Core: Kernel"]
        
        Kernel --> Plugins["🔌 Plugins\n(Tools/Functions)"]
        Kernel --> Planner["📋 Planner\n(Orchestration)"]
        Kernel --> Memory2["🧠 Memory\n(RAG integration)"]
        Kernel --> Connectors["🔗 Connectors\n(Azure OpenAI, etc.)"]
        Kernel --> Process["🔄 Process Framework\n(Multi-step workflows)"]
        Kernel --> Agents2["🤖 Agent Framework\n(Multi-agent)"]
    end
```

### SK vs LangChain:

| | Semantic Kernel | LangChain |
|---|---|---|
| **Company** | Microsoft | LangChain Inc. |
| **Languages** | C#, Python, Java | Python, JS |
| **Azure integration** | ✅ Native | ⚠️ Good |
| **Enterprise** | ✅ Designed for | ⚠️ Growing |
| **Multi-agent** | ✅ Agent framework | ⚠️ Via LangGraph |
| **Ecosystem** | Growing | ✅ Large |
| **Learning curve** | Moderate | Moderate |

---

## Architecture Summary: End-to-End Azure

```mermaid
graph TB
    Users["👤 Users"] --> FD2["🌐 Azure Front Door + WAF"]
    FD2 --> APIM2["🚪 Azure APIM\n(Auth, Rate Limit)"]
    
    APIM2 --> ACA3["☁️ Azure Container Apps\n(Agent Runtime)"]
    
    ACA3 --> AOAI2["🧠 Azure OpenAI\n(GPT-4o, Embeddings)"]
    ACA3 --> AIS2["🔍 Azure AI Search\n(RAG)"]
    ACA3 --> Cosmos2["💾 Azure Cosmos DB\n(State, Threads)"]
    ACA3 --> Redis2["📦 Redis Cache"]
    ACA3 --> SB3["📫 Service Bus\n(Async)"]
    ACA3 --> Blob2["📁 Blob Storage\n(Docs)"]
    
    ACA3 -.-> Entra2["🔐 Entra ID"]
    ACA3 -.-> KV2["🔑 Key Vault"]
    ACA3 -.-> CS2["🛡️ Content Safety"]
    ACA3 -.-> AppIns3["📊 App Insights"]
```

---

## יתרונות וחסרונות של Azure Stack

| ✅ יתרון | ❌ חיסרון |
|----------|----------|
| All services in one cloud | Vendor lock-in |
| Native integration between services | שירותים מסוימים יקרים |
| Enterprise-grade SLA | Learning curve per service |
| Managed Identity (passwordless) | Updates/changes by Microsoft |
| Compliance (GDPR, SOC2, HIPAA) | Some services still in preview |
| Global regions | Complexity of configuration |

---

## סיכום

```mermaid
mindmap
  root((Microsoft Stack))
    Compute
      Azure Container Apps
      AKS
    AI/LLM
      Azure OpenAI
      AI Search
      Content Safety
      AI Foundry
    Data
      Cosmos DB
      Redis Cache
      Blob Storage
    Messaging
      Service Bus
    Security
      Entra ID
      Key Vault
      VNet
    Observability
      Azure Monitor
      App Insights
      Log Analytics
    Framework
      Semantic Kernel
```

| Component | Azure Service | Role |
|-----------|--------------|------|
| **Gateway** | APIM | API management |
| **Compute** | Container Apps | Agent runtime |
| **LLM** | Azure OpenAI | AI models |
| **Search** | AI Search | RAG vector search |
| **State** | Cosmos DB | Threads, state, memory |
| **Cache** | Redis | Performance |
| **Queue** | Service Bus | Async processing |
| **Identity** | Entra ID | Auth |
| **Secrets** | Key Vault | Secret management |
| **Safety** | Content Safety | Content moderation |
| **Monitoring** | App Insights | Observability |
| **Framework** | Semantic Kernel | Agent SDK |

---

## ❓ שאלות לבדיקה עצמית

1. מפה כל רכיב גנרי מה-HLD ל-Azure service ספציפי (15 רכיבים).
2. למה Azure OpenAI ולא OpenAI ישירות?
3. מה היתרון של Hybrid Search ב-Azure AI Search?
4. למה Cosmos DB מתאים ל-Agent Platform (4 סיבות)?
5. מה ההבדל בין ACA ל-AKS ומתי משתמשים בכל אחד?
6. מה זה Managed Identity ולמה זה עדיף על API keys?
7. מה Semantic Kernel ואיך הוא שונה מ-LangChain?
8. מה Azure AI Foundry Agent Service מספק?

---

**[⬅️ חזרה לפרק 14: HLD Architecture](14-hld-architecture.md)** | **[🏠 חזרה ל-README](README.md)**
