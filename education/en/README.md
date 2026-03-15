# 📚 AI Agent Platform - Education Hub

## Purpose
This document is a comprehensive educational resource designed to teach all the concepts, technologies, and architectures required to design and build an **AI Agent Platform as a Service (PaaS)**.

Each chapter is self-contained, but together they form a complete picture of a Production-grade system.

---

## 🗂️ Recommended Learning Path

| # | Topic | File | What You'll Learn |
|---|-------|------|-------------------|
| 1 | **Fundamentals - What is an AI Agent?** | [01-fundamentals.md](01-fundamentals.md) | What is an LLM, what is an Agent, the difference between a Chatbot and an Agent, basic concepts |
| 2 | **Control Plane** | [02-control-plane.md](02-control-plane.md) | What is a Control Plane, why it's needed, key components |
| 3 | **Runtime (Data) Plane** | [03-runtime-plane.md](03-runtime-plane.md) | What is a Runtime Plane, how an Agent runs, request lifecycle |
| 4 | **Model Abstraction & Routing** | [04-model-abstraction-routing.md](04-model-abstraction-routing.md) | Abstraction layer for LLMs, smart routing between models, Routing strategies |
| 5 | **Memory Management & RAG** | [05-memory-management.md](05-memory-management.md) | Short-term and long-term memory, RAG, Vector Databases, Embeddings |
| 6 | **Thread & State Management** | [06-thread-state-management.md](06-thread-state-management.md) | Conversation management, State Machines, Checkpointing, Human-in-the-Loop |
| 7 | **Orchestration Patterns** | [07-orchestration.md](07-orchestration.md) | Sequential, Parallel, Autonomous, Sub-agents, DAG workflows |
| 8 | **Tools & Marketplace** | [08-tools-marketplace.md](08-tools-marketplace.md) | Function Calling, Tool Integration, Tool Registry, Marketplace |
| 9 | **Policy & Governance** | [09-policy-governance.md](09-policy-governance.md) | Content Safety, DLP, Rate Limiting, Guardrails |
| 10 | **Evaluation Engine** | [10-evaluation-engine.md](10-evaluation-engine.md) | Quality metrics, Groundedness, Relevance, automated testing |
| 11 | **Observability & Cost** | [11-observability-cost.md](11-observability-cost.md) | Metrics, Tracing, Token Tracking, Cost Dashboards |
| 12 | **Security & Isolation** | [12-security-isolation.md](12-security-isolation.md) | Sandboxing, Container Isolation, Zero Trust, Secrets Management |
| 13 | **Scalability Patterns** | [13-scalability.md](13-scalability.md) | Horizontal Scaling, Multi-tenancy, Partitioning, Edge Cases |
| 14 | **HLD - Full Architecture** | [14-hld-architecture.md](14-hld-architecture.md) | How everything connects - complete architecture diagram |
| 15 | **Microsoft Stack Mapping** | [15-microsoft-stack.md](15-microsoft-stack.md) | Mapping each component to specific Azure services |
| 16 | **Agent Development Frameworks & Ecosystem** | [16-agent-frameworks.md](16-agent-frameworks.md) | LangChain, LangGraph, Semantic Kernel, AutoGen, CrewAI, MCP, A2A protocols |\n| 17 | **Azure AI Foundry** | [17-azure-ai-foundry.md](17-azure-ai-foundry.md) | Managed agent platform: Model Catalog, Agents Service, Evaluations, Tracing, Content Safety |

---

## 🎯 How to Use This Material

1. **Read in order** - chapters are structured from basics to advanced
2. **Study each diagram** - the Mermaid diagrams illustrate the flows and relationships between components
3. **Pay attention to pros/cons tables** - they will help you understand when each technology is appropriate
4. **At the end of each chapter** there is a summary and self-check questions

---

## 🧭 Topic Map - Bird's Eye View

```mermaid
graph TB
    subgraph "🎛️ Control Plane"
        API[API Gateway]
        IAM[Identity & Access]
        Registry[Agent Registry]
        Policy[Policy Engine]
        Eval[Evaluation Engine]
        Cost[Cost Dashboard]
        Marketplace[Tool Marketplace]
    end

    subgraph "⚙️ Runtime Plane"
        Orch[Orchestrator]
        Model[Model Layer]
        Mem[Memory Manager]
        Thread[Thread Manager]
        State[State Manager]
        Sandbox[Secure Sandbox]
        Tools[Tool Executor]
    end

    subgraph "📊 Cross-Cutting"
        Obs[Observability]
        Sec[Security]
        Scale[Scalability]
    end

    API --> Orch
    IAM --> API
    Registry --> Orch
    Orch --> Model
    Orch --> Mem
    Orch --> Thread
    Orch --> State
    Orch --> Tools
    Tools --> Sandbox
    Policy --> Orch
    Eval --> Orch
    Cost --> Obs
    Obs --> Orch
    Sec --> Sandbox
    Scale --> Orch
```

---

> **Note:** All Mermaid diagrams in these documents can be viewed directly in VS Code with the Mermaid extension, or on sites like [mermaid.live](https://mermaid.live).
