# 🏗️ פרק 14: HLD Architecture - Vendor Agnostic

## תוכן עניינים
- [מה זה HLD?](#מה-זה-hld)
- [System Context](#system-context)
- [ארכיטקטורה מלאה](#ארכיטקטורה-מלאה)
- [Control Plane Architecture](#control-plane-architecture)
- [Runtime Plane Architecture](#runtime-plane-architecture)
- [Data Flow](#data-flow)
- [Component Breakdown](#component-breakdown)
- [Cross-Cutting Concerns](#cross-cutting-concerns)
- [Deployment Architecture](#deployment-architecture)
- [Technology Decisions](#technology-decisions)
- [סיכום ושאלות](#סיכום-ושאלות)

---

## מה זה HLD?

**HLD (High-Level Design)** = תיאור ארכיטקטוני **ברמה גבוהה** של המערכת - מה הרכיבים, איך הם מתקשרים, מה האחריות של כל אחד.

```mermaid
graph LR
    HLD["🏗️ HLD\nHigh-Level Design"]
    HLD --> What["מה הרכיבים?"]
    HLD --> How["איך הם מתקשרים?"]
    HLD --> Why["למה בחרנו ככה?"]
    HLD --> NotHow["❌ לא: קוד, configs, implementation details"]
```

### Vendor Agnostic = לא תלוי בספק:

| Vendor Agnostic | Vendor Specific |
|-----------------|-----------------|
| "Message Queue" | "Azure Service Bus" |
| "LLM Provider" | "Azure OpenAI" |
| "Vector Database" | "Azure AI Search" |
| "Container Orchestration" | "AKS" |
| "Identity Provider" | "Microsoft Entra ID" |

---

## System Context

### מי משתמש במערכת?

```mermaid
graph TB
    Dev["👨‍💻 Developer\nבונה ומגדיר Agents"]
    User["👤 End User\nמשתמש ב-Agents"]
    Admin["👑 Admin\nמנהל את הפלטפורמה"]
    
    Dev --> Platform["🏗️ AI Agent\nPlatform"]
    User --> Platform
    Admin --> Platform
    
    Platform --> LLM["🧠 LLM Providers\nOpenAI, Anthropic, etc."]
    Platform --> ExtTools["🔧 External Tools\nAPIs, DBs, etc."]
    Platform --> IdP["🔐 Identity Provider"]
```

---

## ארכיטקטורה מלאה

### Full HLD Diagram:

```mermaid
graph TB
    %% External Actors
    User["👤 User"] --> GW["🚪 API Gateway"]
    Dev["👨‍💻 Developer"] --> Portal["🌐 Developer Portal"]
    
    %% API Gateway Layer
    GW --> Auth["🔐 AuthN/AuthZ"]
    GW --> RateLimit["⏱️ Rate Limiter"]
    
    subgraph "📋 Control Plane"
        Portal --> AgentReg["📦 Agent Registry"]
        Portal --> ConfigMgr["⚙️ Config Manager"]
        Portal --> PolicyEng["🛡️ Policy Engine"]
        Portal --> ModelReg["🧠 Model Registry"]
        Portal --> ToolReg["🔧 Tool Registry"]
        Portal --> Eval["📊 Evaluation Engine"]
    end
    
    subgraph "⚙️ Runtime Plane"
        Auth --> Router["🔀 Request Router"]
        Router --> Orchestrator["🎭 Orchestrator"]
        
        Orchestrator --> ModelGW["🧠 Model Gateway"]
        Orchestrator --> ToolExec["🔧 Tool Executor"]
        Orchestrator --> MemMgr["💾 Memory Manager"]
        Orchestrator --> ThreadMgr["📋 Thread Manager"]
        
        ModelGW --> LLM1["☁️ LLM Provider 1"]
        ModelGW --> LLM2["☁️ LLM Provider 2"]
        
        ToolExec --> Sandbox["🐳 Sandbox"]
    end
    
    subgraph "💾 Data Layer"
        MemMgr --> VectorDB["📐 Vector DB"]
        ThreadMgr --> StateDB["💾 State Store"]
        StateDB --> Cache["📦 Cache"]
    end
    
    subgraph "📊 Cross-Cutting"
        Obs["📈 Observability"]
        CostDash["💰 Cost Dashboard"]
        AuditLog["📋 Audit Log"]
    end
```

---

## Control Plane Architecture

### רכיבי ה-Control Plane:

```mermaid
graph TB
    subgraph "📋 Control Plane"
        subgraph "Registry Services"
            AR["📦 Agent Registry\n- Agent definitions\n- Versions\n- Metadata"]
            MR["🧠 Model Registry\n- Available models\n- Routing rules\n- Rate limits"]
            TR["🔧 Tool Registry\n- Tool catalog\n- Permissions\n- Schemas"]
        end
        
        subgraph "Management Services"
            CM["⚙️ Config Manager\n- Agent configs\n- Environment vars\n- Feature flags"]
            PE["🛡️ Policy Engine\n- Access rules\n- Usage limits\n- Content safety"]
            TM["👥 Tenant Manager\n- Tenant onboarding\n- Quotas\n- Billing"]
        end
        
        subgraph "Quality Services"
            EE["📊 Evaluation Engine\n- Quality metrics\n- A/B testing\n- Regression detection"]
        end
    end
```

### Control Plane APIs:

| API | Method | Path | Description |
|-----|--------|------|-------------|
| Create Agent | POST | /agents | הגדרת Agent חדש |
| List Agents | GET | /agents | רשימת כל ה-Agents |
| Get Agent | GET | /agents/{id} | פרטי Agent |
| Update Config | PUT | /agents/{id}/config | עדכון הגדרות |
| Register Tool | POST | /tools | רישום כלי חדש |
| Set Policy | POST | /policies | הגדרת policy |
| Run Evaluation | POST | /evaluations | הרצת הערכה |

---

## Runtime Plane Architecture

### Request Processing Flow:

```mermaid
sequenceDiagram
    participant User as 👤 User
    participant GW as 🚪 Gateway
    participant Router as 🔀 Router
    participant Orch as 🎭 Orchestrator
    participant Policy as 🛡️ Policy
    participant Model as 🧠 Model GW
    participant Tool as 🔧 Tool Exec
    participant Mem as 💾 Memory
    participant Thread as 📋 Thread
    
    User->>GW: POST /run {agent, prompt}
    GW->>GW: Auth + Rate Limit
    GW->>Router: Route to agent
    Router->>Thread: Load/Create thread
    Thread-->>Router: Thread context
    Router->>Orch: Start orchestration
    
    loop ReAct Loop
        Orch->>Policy: Pre-check
        Policy-->>Orch: ✅ Allowed
        Orch->>Mem: Get relevant memory
        Mem-->>Orch: Context + RAG results
        Orch->>Model: LLM Call (prompt + context)
        Model-->>Orch: Response (text or tool_call)
        
        alt Tool Call
            Orch->>Policy: Check tool permission
            Orch->>Tool: Execute in sandbox
            Tool-->>Orch: Result
        end
    end
    
    Orch->>Policy: Post-check (PII, safety)
    Orch->>Thread: Save state
    Orch->>Mem: Update memory
    Orch-->>User: Final response
```

### Orchestrator State Machine:

```mermaid
stateDiagram-v2
    [*] --> Initializing
    Initializing --> LoadingContext: Load thread + memory
    LoadingContext --> Thinking: Send to LLM
    Thinking --> Acting: LLM returns tool_call
    Thinking --> Responding: LLM returns text
    Acting --> Observing: Tool executed
    Observing --> Thinking: Feed result to LLM
    Responding --> Saving: Save state + memory
    Saving --> [*]
    
    Thinking --> Error: LLM error
    Acting --> Error: Tool error
    Error --> Thinking: Retry
    Error --> [*]: Max retries exceeded
```

---

## Data Flow

### Data Flow Diagram:

```mermaid
graph LR
    subgraph "Ingest"
        Docs["📄 Documents"] --> Chunker["✂️ Chunker"]
        Chunker --> Embedder["📐 Embedder"]
        Embedder --> VDB["💾 Vector DB"]
    end
    
    subgraph "Query"
        Query["❓ User Query"] --> QEmbed["📐 Embed Query"]
        QEmbed --> Search["🔍 Vector Search"]
        VDB --> Search
        Search --> Context["📋 Top K Results"]
        Context --> LLM["🧠 LLM"]
        LLM --> Response["📤 Response"]
    end
    
    subgraph "State"
        Response --> Thread["📋 Thread Store"]
        Response --> History["📜 Chat History"]
        Response --> Audit["📋 Audit Log"]
    end
```

### Data Stores:

| Store | Type | What it stores | E.g. |
|-------|------|---------------|------|
| **State Store** | Key-Value / Document | Thread state, agent state | Redis, Cosmos DB |
| **Vector DB** | Vector | Document embeddings for RAG | Qdrant, Pinecone |
| **Chat History** | Document | Conversation messages | MongoDB, Cosmos DB |
| **Audit Log** | Append-only | All actions | Kafka → Storage |
| **Config Store** | Key-Value | Agent configs, policies | etcd, Consul |
| **Cache** | In-memory | LLM responses, tool results | Redis |
| **Blob Storage** | Object | Files, documents | S3, Blob |

---

## Component Breakdown

### כל רכיב, תפקידו, ו-inputs/outputs:

```mermaid
graph TB
    subgraph "🚪 API Gateway"
        GW_IN["IN: HTTP requests"]
        GW_DO["DO: Auth, rate limit, route"]
        GW_OUT["OUT: Routed request"]
    end
    
    subgraph "🔀 Request Router"
        RR_IN["IN: Authenticated request"]
        RR_DO["DO: Find agent, load config"]
        RR_OUT["OUT: Agent context"]
    end
    
    subgraph "🎭 Orchestrator"
        O_IN["IN: Agent context + prompt"]
        O_DO["DO: ReAct loop, manage steps"]
        O_OUT["OUT: Final response"]
    end
    
    subgraph "🧠 Model Gateway"
        MG_IN["IN: Prompt + model config"]
        MG_DO["DO: Route, retry, cache"]
        MG_OUT["OUT: LLM response"]
    end
    
    subgraph "🔧 Tool Executor"
        TE_IN["IN: Tool call + params"]
        TE_DO["DO: Validate, sandbox, execute"]
        TE_OUT["OUT: Tool result"]
    end
    
    subgraph "💾 Memory Manager"
        MM_IN["IN: Query / new memory"]
        MM_DO["DO: RAG search, store memory"]
        MM_OUT["OUT: Relevant context"]
    end
```

---

## Cross-Cutting Concerns

### רכיבים שעוברים את כל השכבות:

```mermaid
graph TB
    subgraph "Cross-Cutting Concerns"
        OBS["📈 Observability\nMetrics, Logs, Traces"]
        SEC["🔐 Security\nAuthN, AuthZ, Encryption"]
        POLICY["🛡️ Policy\nGuardrails, DLP, Content Safety"]
        COST["💰 Cost Tracking\nToken counting, Budget"]
        AUDIT["📋 Audit\nWho did what when"]
    end
    
    GW2["🚪 Gateway"] -.-> OBS & SEC & POLICY & COST & AUDIT
    RT2["⚙️ Runtime"] -.-> OBS & SEC & POLICY & COST & AUDIT
    DATA2["💾 Data"] -.-> OBS & SEC & POLICY & COST & AUDIT
```

---

## Deployment Architecture

### Kubernetes-Based Deployment:

```mermaid
graph TB
    subgraph "🌐 Edge"
        LB["⚖️ Load Balancer"]
        WAF2["🛡️ WAF"]
    end
    
    subgraph "☸️ Kubernetes Cluster"
        subgraph "Namespace: control-plane"
            CP1["📦 Agent Registry\n(2 replicas)"]
            CP2["⚙️ Config Manager\n(2 replicas)"]
            CP3["🛡️ Policy Engine\n(3 replicas)"]
        end
        
        subgraph "Namespace: runtime"
            RT1["🎭 Orchestrator\n(auto-scale 2-20)"]
            RT2["🔧 Tool Workers\n(auto-scale 1-10)"]
        end
        
        subgraph "Namespace: data"
            DB1["💾 State Store"]
            DB2["📐 Vector DB"]
            DB3["📦 Cache"]
        end
        
        subgraph "Namespace: observability"
            OBS2["📊 Metrics"]
            LOG["📝 Logs"]
            TRACE["🔗 Traces"]
        end
    end
    
    LB --> WAF2 --> CP1 & RT1
```

### Deployment Configurations:

| Environment | Config |
|------------|--------|
| **Dev** | 1 node, minimal replicas, mock LLM |
| **Staging** | 3 nodes, real LLM, synthetic data |
| **Production** | 5+ nodes, auto-scale, multi-region, real data |

---

## Technology Decisions

### כל רכיב ואופציות טכנולוגיות (Vendor Agnostic):

| Component | Option A | Option B | Option C |
|-----------|----------|----------|----------|
| **API Gateway** | Kong | Envoy | NGINX |
| **Container Runtime** | Kubernetes | Docker Swarm | Nomad |
| **State Store** | Redis | PostgreSQL | MongoDB |
| **Vector DB** | Qdrant | Pinecone | Weaviate |
| **Message Queue** | RabbitMQ | Kafka | NATS |
| **Cache** | Redis | Memcached | Hazelcast |
| **Observability** | OTel + Grafana | Datadog | Elastic Stack |
| **Secret Vault** | HashiCorp Vault | CyberArk | SOPS |
| **Identity** | Keycloak | Auth0 | Okta |
| **LLM Framework** | LangChain | Semantic Kernel | LlamaIndex |
| **Blob Storage** | MinIO | Ceph | NAS |

### Decision Framework:

```mermaid
graph TD
    Decision["🤔 Technology Decision"]
    Decision --> Req["📋 Requirements"]
    
    Req --> Perf["⚡ Performance needs"]
    Req --> Scale["📈 Scale requirements"]
    Req --> Cost["💰 Budget"]
    Req --> Team["👥 Team expertise"]
    Req --> Eco["🔗 Ecosystem fit"]
    Req --> Vendor["🏢 Vendor lock-in risk"]
```

---

## Architecture Qualities

### Non-Functional Requirements:

| Quality | Target | How |
|---------|--------|-----|
| **Latency** | P99 < 5s for simple queries | Caching, streaming |
| **Throughput** | 1000 RPS | Horizontal scaling |
| **Availability** | 99.9% (8.7 hours/year downtime) | Multi-AZ, redundancy |
| **Durability** | No data loss | Replication, backups |
| **Security** | SOC 2 compliant | Zero Trust, encryption |
| **Scalability** | 10x without redesign | Stateless, auto-scale |
| **Extensibility** | Add tools/models easily | Registry pattern, plugins |
| **Operability** | Quick debugging | Observability, tracing |

---

## סיכום

```mermaid
mindmap
  root((HLD Architecture))
    Control Plane
      Agent Registry
      Config Manager
      Policy Engine
      Model Registry
      Tool Registry
      Evaluation Engine
    Runtime Plane
      API Gateway
      Request Router
      Orchestrator
      Model Gateway
      Tool Executor
      Memory Manager
      Thread Manager
    Data Layer
      State Store
      Vector DB
      Cache
      Blob Storage
      Audit Log
    Cross-Cutting
      Observability
      Security
      Policy
      Cost Tracking
    Deployment
      Kubernetes
      Auto-scaling
      Multi-region
```

| מה למדנו | נקודה מרכזית |
|-----------|-------------|
| **HLD** | תיאור ארכיטקטוני ברמה גבוהה, ללא implementation |
| **Control Plane** | ניהול, הגדרות, Registry-ים |
| **Runtime Plane** | הרצה, Orchestrator, Model/Tool Gateway |
| **Data Layer** | State, Vectors, Cache, Audit |
| **Cross-Cutting** | Observability, Security, Cost - בכל השכבות |
| **Vendor Agnostic** | לא תלוי בספק מסוים |
| **Architecture Qualities** | Latency, Throughput, Availability, Security |

---

## ❓ שאלות לבדיקה עצמית

1. מה ההבדל בין Control Plane ל-Runtime Plane?
2. מהם 7 הרכיבים של ה-Control Plane?
3. מה עושה ה-Orchestrator ומה ה-state machine שלו?
4. מהם 7 סוגי ה-Data Stores ומה כל אחד שומר?
5. מה זה Cross-Cutting Concerns ותן 5 דוגמאות?
6. מה ההבדל בין Vendor Agnostic ל-Vendor Specific?
7. מהם ה-Non-Functional Requirements העיקריים?

---

**[⬅️ חזרה לפרק 13: Scalability](13-scalability.md)** | **[➡️ המשך לפרק 15: Microsoft Stack →](15-microsoft-stack.md)**
