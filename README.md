# 📚 AI Agent Platform - Education Hub

> **[🇮🇱 גרסה בעברית](education/heb/README.md)**

## Purpose
This repository is a comprehensive educational resource designed to teach all the concepts, technologies, and architectures required to design and build an **AI Agent Platform as a Service (PaaS)**.

- **📖 Education chapters** (1-17) — deep concept explanations with diagrams
- **🧪 Hands-on labs** (0-9) — build real agents with LangChain/LangGraph, step by step

Each chapter is self-contained, but together they form a complete picture of a Production-grade system.

---

## 🗺️ Complete Learning Path — Education + Labs

| # | Education Chapter | Hands-On Lab | What You'll Learn |
|---|-------------------|-------------|-------------------|
| 1 | [Fundamentals — What is an AI Agent?](education/en/01-fundamentals.md) | [Lab 00: Setup](labs/lab-00-setup/README.md) | LLMs, Agents, ReAct loop, Azure environment deploy |
| 2 | [Model Abstraction & Routing](education/en/02-model-abstraction-routing.md) | [Lab 01: ReAct Agent](labs/lab-01-react-agent/README.md) | Build an agent from scratch, then with LangGraph |
| 3 | [Memory Management & RAG](education/en/03-memory-management.md) | [Lab 02: Smart Model Routing](labs/lab-02-model-routing/README.md) | Route cheap vs expensive models, measure savings |
| 4 | [Thread & State Management](education/en/04-thread-state-management.md) | [Lab 03: Memory & RAG](labs/lab-03-memory-rag/README.md) | RAG pipeline, Cosmos DB memory, grounded answers |
| 5 | [Orchestration Patterns](education/en/05-orchestration.md) | [Lab 04: Orchestration](labs/lab-04-orchestration/README.md) | Sequential, parallel, map-reduce, supervisor agents |
| 6 | [Tools & Marketplace](education/en/06-tools-marketplace.md) | Lab 05: Tools & Safety | Custom tools, input validation, DLP, guardrails |
| 7 | [Policy & Governance](education/en/07-policy-governance.md) | Lab 06: Evaluation | Quality metrics, groundedness, relevance, toxicity |
| 8 | [Control Plane](education/en/08-control-plane.md) | Lab 07: Framework Deep Dive | LangGraph vs Deep Agents — compare approaches |
| 9 | [Runtime Plane](education/en/09-runtime-plane.md) | Lab 08: Observability | OpenTelemetry, cost tracking, dashboards |
| 10 | [Evaluation Engine](education/en/10-evaluation-engine.md) | Lab 09: Azure AI Foundry | Managed agents, built-in evals, tracing |
| 11 | [Observability & Cost](education/en/11-observability-cost.md) | | Metrics, tracing, token tracking, cost dashboards |
| 12 | [Security & Isolation](education/en/12-security-isolation.md) | | Sandboxing, zero trust, secrets management |
| 13 | [Scalability Patterns](education/en/13-scalability.md) | | Horizontal scaling, multi-tenancy, partitioning |
| 14 | [HLD — Full Architecture](education/en/14-hld-architecture.md) | | Complete architecture diagram |
| 15 | [Microsoft Stack Mapping](education/en/15-microsoft-stack.md) | | Map components to specific Azure services |
| 16 | [Agent Frameworks & Ecosystem](education/en/16-agent-frameworks.md) | | LangGraph, Semantic Kernel, AutoGen, CrewAI, MCP, A2A |
| 17 | [Azure AI Foundry](education/en/17-azure-ai-foundry.md) | | Managed agent platform: Model Catalog, Agents Service |

---

## 🎯 How to Use This Material

1. **Read in order** — chapters are structured from basics to advanced
2. **Do the labs** — theory + practice together is the fastest way to learn
3. **Study the diagrams** — they illustrate flows and relationships
4. **Check yourself** — every chapter ends with a summary and self-check questions

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

## 🌐 Available Languages

| Language | Path |
|----------|------|
| **English** | [education/en/](education/en/) |
| **Hebrew (עברית)** | [education/heb/](education/heb/) |

---

> **Note:** All Mermaid diagrams in these documents can be viewed directly on GitHub, in VS Code with the Mermaid extension, or on sites like [mermaid.live](https://mermaid.live).
