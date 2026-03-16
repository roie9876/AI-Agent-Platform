# 📚 AI Agent Platform - Education Hub

> **[🇮🇱 גרסה בעברית](education/heb/README.md)**

## Purpose
This repository is a comprehensive educational resource designed to teach all the concepts, technologies, and architectures required to design and build an **AI Agent Platform as a Service (PaaS)**.

- **📖 Education chapters** (1-16) — deep concept explanations with diagrams
- **🧪 Hands-on labs** — build real agents with LangChain/LangGraph, step by step

Each chapter is self-contained, but together they form a complete picture of a Production-grade system.

---

## 🗂️ Recommended Learning Path

| # | Topic | File | What You'll Learn |
|---|-------|------|-------------------|
| 1 | **Fundamentals - What is an AI Agent?** | [01-fundamentals.md](education/en/01-fundamentals.md) | What is an LLM, what is an Agent, the difference between a Chatbot and an Agent, basic concepts |
| 2 | **Control Plane** | [02-control-plane.md](education/en/02-control-plane.md) | What is a Control Plane, why it's needed, key components |
| 3 | **Runtime (Data) Plane** | [03-runtime-plane.md](education/en/03-runtime-plane.md) | What is a Runtime Plane, how an Agent runs, request lifecycle |
| 4 | **Model Abstraction & Routing** | [04-model-abstraction-routing.md](education/en/04-model-abstraction-routing.md) | Abstraction layer for LLMs, smart routing between models, Routing strategies |
| 5 | **Memory Management & RAG** | [05-memory-management.md](education/en/05-memory-management.md) | Short-term and long-term memory, RAG, Vector Databases, Embeddings |
| 6 | **Thread & State Management** | [06-thread-state-management.md](education/en/06-thread-state-management.md) | Conversation management, State Machines, Checkpointing, Human-in-the-Loop |
| 7 | **Orchestration Patterns** | [07-orchestration.md](education/en/07-orchestration.md) | Sequential, Parallel, Autonomous, Sub-agents, DAG workflows |
| 8 | **Tools & Marketplace** | [08-tools-marketplace.md](education/en/08-tools-marketplace.md) | Function Calling, Tool Integration, Tool Registry, Marketplace |
| 9 | **Policy & Governance** | [09-policy-governance.md](education/en/09-policy-governance.md) | Content Safety, DLP, Rate Limiting, Guardrails |
| 10 | **Evaluation Engine** | [10-evaluation-engine.md](education/en/10-evaluation-engine.md) | Quality metrics, Groundedness, Relevance, automated testing |
| 11 | **Observability & Cost** | [11-observability-cost.md](education/en/11-observability-cost.md) | Metrics, Tracing, Token Tracking, Cost Dashboards |
| 12 | **Security & Isolation** | [12-security-isolation.md](education/en/12-security-isolation.md) | Sandboxing, Container Isolation, Zero Trust, Secrets Management |
| 13 | **Scalability Patterns** | [13-scalability.md](education/en/13-scalability.md) | Horizontal Scaling, Multi-tenancy, Partitioning, Edge Cases |
| 14 | **HLD - Full Architecture** | [14-hld-architecture.md](education/en/14-hld-architecture.md) | How everything connects - complete architecture diagram |
| 15 | **Microsoft Stack Mapping** | [15-microsoft-stack.md](education/en/15-microsoft-stack.md) | Mapping each component to specific Azure services |
| 16 | **Agent Development Frameworks & Ecosystem** | [16-agent-frameworks.md](education/en/16-agent-frameworks.md) | LangChain, LangGraph, Semantic Kernel, AutoGen, Microsoft Agent Framework, CrewAI, MCP, A2A protocols |
| 17 | **Azure AI Foundry** | [17-azure-ai-foundry.md](education/en/17-azure-ai-foundry.md) | Managed agent platform: Model Catalog, Agents Service, Evaluations, Tracing |

---

## 🎯 How to Use This Material

1. **Read in order** - chapters are structured from basics to advanced
2. **Study each diagram** - the Mermaid diagrams illustrate the flows and relationships between components
3. **Pay attention to pros/cons tables** - they will help you understand when each technology is appropriate
4. **At the end of each chapter** there is a summary and self-check questions

---

## 🧭 Platform Architecture — Bird's Eye View

```
┌──────────────────────────────────────────────────────────────────────────┐
│                         🎛️  CONTROL PLANE                              │
│                                                                          │
│   API Gateway ─── Identity & Access ─── Agent Registry                  │
│        │                                      │                          │
│   Policy Engine ─── Evaluation Engine ─── Tool Marketplace              │
│        │                  │                    │                          │
│        └──────────────────┼────────────────────┘                         │
│                           │                                              │
│                    Cost Dashboard                                        │
└──────────────────────────┬───────────────────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                         ⚙️  RUNTIME PLANE                               │
│                                                                          │
│                      ┌─────────────┐                                    │
│                      │ Orchestrator│                                    │
│                      └──────┬──────┘                                    │
│            ┌────────────┬───┴───┬────────────┐                          │
│            ▼            ▼       ▼            ▼                          │
│      Model Layer   Memory   Thread &    Tool Executor                   │
│      (Routing,     Manager  State       (Function Calling)              │
│       Fallback)             Manager          │                          │
│                                         Secure Sandbox                  │
└──────────────────────────────────────────────────────────────────────────┘
                           │
┌──────────────────────────┴───────────────────────────────────────────────┐
│                      📊  CROSS-CUTTING CONCERNS                         │
│                                                                          │
│          Observability  ───  Security & Isolation  ───  Scalability     │
│          (Ch 11)             (Ch 12)                    (Ch 13)          │
└──────────────────────────────────────────────────────────────────────────┘
```

Each box maps to an education chapter — read them in order to build the full picture.

---

## 🧪 Hands-On Labs

> **Learn by building.** Each lab teaches one core concept by writing real code with LangChain/LangGraph.

| Lab | What You Build | Time |
|-----|---------------|------|
| **[Lab 00](labs/lab-00-setup/README.md)** | Azure environment setup (one-click deploy) | ~20min |
| **[Lab 01](labs/lab-01-react-agent/README.md)** | Build a ReAct Agent from scratch, then with LangGraph | ~1.5h |
| **[Lab 02](labs/lab-02-model-routing/README.md)** | Smart model routing (cheap vs expensive) | ~1h |
| **[Lab 03](labs/lab-03-memory-rag/README.md)** | Memory & RAG integration | ~1.5h |
| **[Lab 04](labs/lab-04-orchestration/README.md)** | Orchestration patterns (sequential, parallel, map-reduce) | ~1.5h |
| **Lab 05** | Tool calling with safety guardrails | ~1h |
| **Lab 06** | Agent evaluation pipeline | ~1h |
| **Lab 07** | Framework deep dive (LangGraph vs Deep Agents) | ~1.5h |
| **Lab 08** | Observability & Monitoring (tracing, costs, dashboards) | ~1.5h |
| **Lab 09** | Azure AI Foundry (managed agents, evals, tracing) | ~2h |

**[→ Get started with the labs](labs/README.md)**

---

## 🌐 Available Languages

| Language | Path |
|----------|------|
| **English** | [education/en/](education/en/) |
| **Hebrew (עברית)** | [education/heb/](education/heb/) |

---

> **Note:** All Mermaid diagrams in these documents can be viewed directly on GitHub, in VS Code with the Mermaid extension, or on sites like [mermaid.live](https://mermaid.live).
