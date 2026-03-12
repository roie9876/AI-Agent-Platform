# 📈 Chapter 13: Scalability & High Availability

## Table of Contents
- [What is Scalability?](#what-is-scalability)
- [Horizontal vs Vertical Scaling](#horizontal-vs-vertical-scaling)
- [Stateless vs Stateful Scaling](#stateless-vs-stateful-scaling)
- [Agent Scaling Challenges](#agent-scaling-challenges)
- [Load Balancing](#load-balancing)
- [Queue-Based Architecture](#queue-based-architecture)
- [Auto-Scaling](#auto-scaling)
- [High Availability (HA)](#high-availability-ha)
- [Multi-Region](#multi-region)
- [Caching Strategies](#caching-strategies)
- [Partitioning & Sharding](#partitioning--sharding)
- [Pros and Cons](#pros-and-cons)
- [Summary and Questions](#summary-and-questions)

---

## What is Scalability?

**Scalability** = the ability of a system **to grow** to handle more load, without losing performance.

```mermaid
graph LR
    subgraph "Today"
        T1["👤 100 users\n⏱️ 2s latency"]
    end
    
    subgraph "Next Year"
        T2["👥 10,000 users\n⏱️ 2s latency ✅"]
    end
    
    subgraph "Bad Scaling"
        T3["👥 10,000 users\n⏱️ 30s latency ❌"]
    end
    
    T1 -->|"Good scaling"| T2
    T1 -->|"Bad scaling"| T3
```

---

## Horizontal vs Vertical Scaling

```mermaid
graph TB
    subgraph "⬆️ Vertical Scaling (Scale Up)"
        VSmall["🖥️ Small\n4 CPU, 8 GB"]
        VBig["🖥️🖥️ BIG\n64 CPU, 256 GB"]
        VSmall -->|"Upgrade"| VBig
    end
    
    subgraph "↔️ Horizontal Scaling (Scale Out)"
        H1["🖥️"]
        H2["🖥️"]
        H3["🖥️"]
        H4["🖥️"]
        H5["🖥️"]
    end
```

### Comparison:

| | Vertical (Scale Up) | Horizontal (Scale Out) |
|---|---|---|
| **What you do** | Scale up an existing server | Add more servers |
| **Limit** | There's a ceiling (max hardware) | No ceiling (almost) |
| **Cost** | Very expensive upfront | Cheap per unit |
| **Downtime** | Requires restart | Zero downtime |
| **Complexity** | Simple | Complex (state, sync) |
| **Agents** | ❌ Not recommended | ✅ Recommended |

---

## Stateless vs Stateful Scaling

### Why is this important for Agents?
Agents maintain **state** (conversation, memory, Thread). This makes scaling difficult.

```mermaid
graph TB
    subgraph "✅ Stateless Service"
        LB1["⚖️ LB"]
        S1["🖥️ Instance 1"]
        S2["🖥️ Instance 2"]
        S3["🖥️ Instance 3"]
        LB1 --> S1 & S2 & S3
        
        Note1["Every request can go\nto any instance.\nEasy to add instances."]
    end
    
    subgraph "⚠️ Stateful Service"
        LB2["⚖️ LB"]
        SF1["🖥️ Instance 1\n📋 Thread A, B"]
        SF2["🖥️ Instance 2\n📋 Thread C, D"]
        LB2 -->|"Thread A"| SF1
        LB2 -->|"Thread C"| SF2
        
        Note2["Request must reach\nthe correct instance. Complex."]
    end
```

### Solution: Externalize State

```mermaid
graph TB
    LB["⚖️ Load Balancer"]
    
    LB --> I1["🖥️ Instance 1\n(Stateless)"]
    LB --> I2["🖥️ Instance 2\n(Stateless)"]
    LB --> I3["🖥️ Instance 3\n(Stateless)"]
    
    I1 & I2 & I3 --> StateStore["💾 External State Store\n(Redis / Cosmos DB)\n📋 All threads & state"]
```

| Strategy | Explanation | Pros | Cons |
|----------|-------------|------|------|
| **Externalize State** | Store state in an external DB | Easy to scale | Latency to DB |
| **Sticky Sessions** | Route user to the same instance | State local | Instance failure = lost state |
| **Event Sourcing** | Store events, rebuild state | Reliable, audit | Complex |

---

## Agent Scaling Challenges

### Why are Agents hard to Scale?

```mermaid
graph TD
    C1["⏱️ Long-running\nAgent task = seconds-minutes\n(not milliseconds)"]
    C2["🧠 Memory intensive\nContext window = large"]
    C3["💰 Expensive\nEvery LLM call = money"]
    C4["🔄 Variable load\n1 request = 1-20 LLM calls"]
    C5["📋 Stateful\nThread, memory, history"]
    C6["⏳ External dependencies\nLLM provider rate limits"]
```

### Resource per Agent Request:

```mermaid
graph LR
    Simple["📨 Simple query\n1 LLM call\n~2s, $0.01"] 
    
    Complex["📨 Complex task\n10 LLM calls\n5 tool calls\n~30s, $0.50"]
    
    HeavyAgent["📨 Research task\n20 LLM calls\n15 tool calls\n~120s, $2.00"]
```

---

## Load Balancing

### Load Balancing Strategies:

```mermaid
graph TB
    subgraph "Algorithms"
        RR["🔄 Round Robin\nOne by one, in order"]
        WRR["⚖️ Weighted Round Robin\nMore to stronger instances"]
        LC["📊 Least Connections\nRoute to least busy"]
        RND["🎲 Random\nRandom pick"]
    end
```

### Agent-Aware Load Balancing:

```mermaid
graph TB
    Request["📨 Request\nAgent: data-analyst\nTenant: acme"]
    
    Request --> Router["⚖️ Smart Router"]
    
    Router --> Check1{"Current load\nper instance?"}
    Check1 --> Check2{"Token budget\nremaining?"}
    Check2 --> Check3{"Model provider\nrate limits?"}
    Check3 --> Best["Best instance"]
```

---

## Queue-Based Architecture

### Why Queues?
Agent requests are **long** and **heavy**. A Queue enables:
- **Decoupling** - separation between the sender and the processor
- **Smoothing** - smoothing out load spikes
- **Retry** - automatic retry
- **Priority** - handling by priority

```mermaid
graph LR
    Producers["📨 Incoming\nRequests"]
    
    Producers --> Queue["📫 Message Queue"]
    
    Queue --> W1["⚙️ Worker 1"]
    Queue --> W2["⚙️ Worker 2"]
    Queue --> W3["⚙️ Worker 3"]
    Queue --> W4["⚙️ Worker 4"]
    
    W1 & W2 & W3 & W4 --> Results["📤 Results"]
```

### Priority Queues:

```mermaid
graph LR
    subgraph "Priority Queues"
        HQ["🔴 High Priority\nSync, urgent"]
        MQ["🟡 Medium Priority\nNormal requests"]
        LQ["🟢 Low Priority\nBatch, background"]
    end
    
    HQ -->|"Process first"| Workers["⚙️ Workers"]
    MQ -->|"Process second"| Workers
    LQ -->|"Process last"| Workers
```

### Async Agent Execution:

```mermaid
sequenceDiagram
    participant User
    participant API as 🚪 API
    participant Queue as 📫 Queue
    participant Worker as ⚙️ Worker
    participant LLM as 🧠 LLM
    
    User->>API: POST /agent/run
    API->>Queue: Enqueue task
    API-->>User: 202 Accepted (task_id: abc123)
    
    User->>API: GET /tasks/abc123 (polling)
    API-->>User: Status: processing...
    
    Queue->>Worker: Dequeue task
    Worker->>LLM: Process (multiple calls)
    LLM-->>Worker: Results
    Worker->>Worker: Save result
    
    User->>API: GET /tasks/abc123
    API-->>User: Status: completed ✅ + result
```

---

## Auto-Scaling

### What is it?
**Auto-scaling** = the system **adds/removes** instances automatically according to the load.

```mermaid
graph TD
    Metrics["📊 Metrics"] --> Rules["📋 Scaling Rules"]
    
    Rules --> ScaleOut{"CPU > 70%?\nQueue > 100?\nLatency > 5s?"}
    
    ScaleOut -->|"Yes"| Add["➕ Add instances\n(Scale Out)"]
    ScaleOut -->|"No"| ScaleIn{"CPU < 20%?\nQueue = 0?\nInstances > min?"}
    
    ScaleIn -->|"Yes"| Remove["➖ Remove instances\n(Scale In)"]
    ScaleIn -->|"No"| Keep["= Keep current"]
```

### Scaling Metrics for Agents:

| Metric | Scale Out When | Scale In When |
|--------|---------------|---------------|
| **CPU** | > 70% for 5 min | < 20% for 10 min |
| **Queue Depth** | > 50 pending tasks | Queue = 0 for 10 min |
| **Active Agents** | > 80% capacity | < 20% capacity |
| **Latency P99** | > 10s | < 2s consistently |
| **Concurrent requests** | > threshold | < min threshold |

### KEDA (Kubernetes Event-Driven Autoscaler):

```mermaid
graph TD
    KEDA["📊 KEDA"] --> Monitor["Monitor:\n- Queue length\n- HTTP requests\n- Custom metrics"]
    Monitor --> Scale["Scale:\n- Pods 0 → N\n- Based on events\n- Scale to zero!"]
```

---

## High Availability (HA)

### What is it?
**HA** = the system **continues to work** even when parts of it go down.

```mermaid
graph TB
    subgraph "Without HA"
        Single["🖥️ Single Instance"]
        Single -->|"Dies"| Down["💀 SERVICE DOWN"]
    end
    
    subgraph "With HA"
        LB_HA["⚖️ Load Balancer"]
        HA1["🖥️ Instance 1 ✅"]
        HA2["🖥️ Instance 2 ✅"]
        HA3["🖥️ Instance 3 💀"]
        LB_HA --> HA1 & HA2
        LB_HA -.-x HA3
        Note_HA["Service still UP ✅"]
    end
```

### HA Patterns:

| Pattern | Explanation |
|---------|-------------|
| **Redundancy** | Multiple instances of everything |
| **Health Checks** | Automatic detection of failures |
| **Failover** | Automatic switch to backup |
| **Circuit Breaker** | Stop calling failed services |
| **Retry with Backoff** | Retry with increasing delays |
| **Graceful Degradation** | Reduce features rather than fail |

### Circuit Breaker:

```mermaid
stateDiagram-v2
    [*] --> Closed
    Closed --> Open: Failures > threshold
    Open --> HalfOpen: Timeout expires
    HalfOpen --> Closed: Success
    HalfOpen --> Open: Failure
    
    note right of Closed: Normal operation\nRequests pass through
    note right of Open: Stop all requests\nReturn error immediately
    note right of HalfOpen: Try one request\nIf OK → Close\nIf fail → Open
```

---

## Multi-Region

### Why Multi-Region?

```mermaid
graph TB
    subgraph "🌍 Multi-Region Benefits"
        B1["⚡ Low latency\nClose to users"]
        B2["🛡️ Disaster recovery\nRegion fails = another takes over"]
        B3["📋 Compliance\nData stays in region"]
    end
```

### Active-Active vs Active-Passive:

```mermaid
graph TB
    subgraph "Active-Active"
        AA_LB["🌐 Global LB"]
        AA_R1["🏢 Region 1\n(Active ✅)"]
        AA_R2["🏢 Region 2\n(Active ✅)"]
        AA_LB --> AA_R1 & AA_R2
        AA_R1 <-->|"Sync"| AA_R2
    end
    
    subgraph "Active-Passive"
        AP_LB["🌐 Global LB"]
        AP_R1["🏢 Region 1\n(Active ✅)"]
        AP_R2["🏢 Region 2\n(Standby ⏸️)"]
        AP_LB --> AP_R1
        AP_R1 -->|"Replicate"| AP_R2
        AP_LB -.->|"Failover"| AP_R2
    end
```

| | Active-Active | Active-Passive |
|---|---|---|
| **Latency** | ✅ Low (close to user) | ⚠️ One region only |
| **Capacity** | ✅ 2x capacity | ⚠️ Wasted standby |
| **Failover** | ✅ Instant | ⚠️ Minutes |
| **Complexity** | ❌ Data sync complex | ✅ Simpler |
| **Cost** | ❌ 2x cost | ✅ Lower |

---

## Caching Strategies

### What goes into the Cache in an Agent Platform?

```mermaid
graph TD
    subgraph "🗄️ Caching Layers"
        C1["🧠 LLM Response Cache\nExact same query → cached response"]
        C2["📄 RAG Cache\nDocument embeddings cached"]
        C3["🔧 Tool Result Cache\nSame SQL query → cached result"]
        C4["📋 Config Cache\nAgent configs cached"]
    end
```

### Semantic Cache:

```mermaid
graph LR
    Q1["❓ 'What are sales for Q3?'"] --> Cache["🗄️ Semantic Cache"]
    Cache --> Search["🔍 Similar query exists?\n'Q3 sales numbers?'\nSimilarity: 0.95"]
    Search -->|"> threshold"| Hit["✅ Cache Hit\nReturn cached response"]
    Search -->|"< threshold"| Miss["❌ Cache Miss\nCall LLM"]
```

| Cache Type | Hit Rate | Savings |
|------------|----------|---------|
| **Exact Match** | Low (5-10%) | Tokens + latency |
| **Semantic Cache** | Medium (20-40%) | Tokens + latency |
| **RAG Embedding Cache** | High (80%+) | Embedding compute |
| **Tool Result Cache** | Variable | Tool execution time |

---

## Partitioning & Sharding

### Tenant-Based Partitioning:

```mermaid
graph TB
    Router["🔀 Tenant Router"]
    
    Router -->|"Tenant A-F"| Shard1["💾 Shard 1"]
    Router -->|"Tenant G-M"| Shard2["💾 Shard 2"]
    Router -->|"Tenant N-T"| Shard3["💾 Shard 3"]
    Router -->|"Tenant U-Z"| Shard4["💾 Shard 4"]
```

### Partitioning Strategies:

| Strategy | Explanation | For Agents |
|----------|-------------|-----------|
| **By Tenant** | Each tenant in a different partition | ✅ Common, good isolation |
| **By Agent Type** | Each agent type in a different partition | ⚠️ Some types may be hot |
| **By Region** | By geographic region | ✅ Compliance + latency |
| **By Time** | By date (logs, history) | ✅ For time-series data |

---

## Pros and Cons

| ✅ Advantage | ❌ Disadvantage |
|----------|----------|
| Handle growing traffic | Added complexity |
| Cost efficiency (scale to zero) | State management challenges |
| High availability | Data consistency challenges |
| Low latency (multi-region) | Network costs |
| Fault tolerance | Debugging harder |

---

## Summary

```mermaid
mindmap
  root((Scalability & HA))
    Scaling Types
      Horizontal ✅
      Vertical ❌
    State Management
      Externalize state
      Stateless services
      Event sourcing
    Load Balancing
      Round Robin
      Least Connections
      Agent-aware
    Queues
      Async processing
      Priority queues
      Spike smoothing
    Auto-Scaling
      Metrics-based
      KEDA
      Scale to zero
    High Availability
      Redundancy
      Circuit Breaker
      Failover
    Multi-Region
      Active-Active
      Active-Passive
      Data sovereignty
    Caching
      LLM cache
      Semantic cache
      Tool cache
    Partitioning
      By Tenant
      By Region
      By Time
```

| What We Learned | Key Point |
|-----------------|-----------|
| **Horizontal Scaling** | Add more instances (not a more powerful server) |
| **Stateless** | Externalizing state enables easy scaling |
| **Queue-Based** | Queue separates sender from worker, enables async |
| **Auto-Scaling** | The system grows and shrinks automatically based on load |
| **HA** | Redundancy + failover = always-available service |
| **Multi-Region** | Low latency + DR + Compliance |
| **Caching** | Semantic Cache saves tokens and money |
| **Partitioning** | Partitioning per tenant for performance and isolation |

---

## ❓ Self-Check Questions

1. What is the difference between Horizontal and Vertical scaling?
2. Why are Agents hard to scale (5 reasons)?
3. What is Externalize State and why is it important?
4. What is the advantage of Queue-Based Architecture?
5. What is Auto-Scaling and which metrics are used?
6. What is the difference between Active-Active and Active-Passive?
7. What is Semantic Cache and how does it help?
8. What is the tradeoff of Circuit Breaker?

---

### 📝 Answers

<details>
<summary>1. What is the difference between Horizontal and Vertical scaling?</summary>

**Vertical (Scale Up)** = enlarging the existing machine (more CPU, RAM). Simple but has a ceiling. **Horizontal (Scale Out)** = adding more machines (more instances). No theoretical ceiling, but requires handling state and load balancing.
</details>

<details>
<summary>2. Why are Agents hard to scale (5 reasons)?</summary>

1. **Stateful** - each agent holds state (thread, memory).
2. **Long-Running** - requests last seconds (long loops).
3. **Unpredictable Cost** - each request consumes a different number of tokens.
4. **External Dependencies** - LLM APIs with rate limits and variable latency.
5. **Fan-Out** - a single agent can invoke multiple tools/sub-agents in parallel.
</details>

<details>
<summary>3. What is Externalize State and why is it important?</summary>

**Externalize State** = moving the state from the instance to an external DB (Redis, Cosmos DB). Important because: if the state is inside the instance, you can't scale out (a request must reach the same instance). With external state: every instance is stateless → any instance can handle any request.
</details>

<details>
<summary>4. What is the advantage of Queue-Based Architecture?</summary>

Instead of requests going directly to the Agent, they enter a **queue**. Advantages: (1) **Load smoothing** - a spike doesn't crash the system, (2) **Decoupling** - producer and consumer are independent, (3) **Retry** - a failed message goes back to the queue, (4) **Scale** - add consumers based on queue depth.
</details>

<details>
<summary>5. What is Auto-Scaling and which metrics are used?</summary>

**Auto-Scaling** = the system adds/removes instances automatically. Metrics: (1) **Queue depth** - how many messages are waiting in the queue, (2) **Active requests** - how many requests are being processed, (3) **CPU/Memory** - resource utilization, (4) **Latency** - response time. For Agents: queue depth is usually the best metric.
</details>

<details>
<summary>6. What is the difference between Active-Active and Active-Passive?</summary>

**Active-Active** = two regions active simultaneously, traffic is distributed. RTO ≈ 0, but requires complex data sync, more expensive. **Active-Passive** = one region active, the other on standby. When the first goes down → failover to the second. RTO > 0 (there is downtime), but cheaper.
</details>

<details>
<summary>7. What is Semantic Cache and how does it help?</summary>

**Semantic Cache** = saving LLM responses and returning them for **semantically similar** (not identical) questions. Helps with **scalability** by: (1) saving LLM calls → less load on APIs, (2) saving tokens → saving costs, (3) lower latency on cache hit (milliseconds instead of seconds).
</details>

<details>
<summary>8. What is the tradeoff of Circuit Breaker?</summary>

**Advantage**: protects against cascading failure - when a service is unavailable, it stops sending requests that will fail → saves resources. **Disadvantage**: legitimate requests are rejected while the CB is open - they can't be handled. You need to properly tune the thresholds and the timeout period.
</details>

---

**[⬅️ Back to Chapter 12: Security](12-security-isolation.md)** | **[➡️ Continue to Chapter 14: HLD Architecture →](14-hld-architecture.md)**
