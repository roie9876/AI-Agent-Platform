# 📚 AI Agent Platform - Education Hub

> **[🇮🇱 גרסה בעברית](education/heb/README.md)**

## Purpose
This repository is a comprehensive educational resource designed to teach all the concepts, technologies, and architectures required to design and build an **AI Agent Platform as a Service (PaaS)**.

- **📖 Education chapters** (1-17) — deep concept explanations with diagrams
- **🧪 Hands-on labs** (0-9) — build real agents with LangChain/LangGraph, step by step

Each chapter is self-contained, but together they form a complete picture of a Production-grade system.

---

## � Education Chapters

| # | Topic | Chapter |
|---|-------|---------|
| 1 | **Fundamentals — What is an AI Agent?** | [01-fundamentals.md](education/en/01-fundamentals.md) |
| 2 | **Model Abstraction & Routing** | [02-model-abstraction-routing.md](education/en/02-model-abstraction-routing.md) |
| 3 | **Memory Management & RAG** | [03-memory-management.md](education/en/03-memory-management.md) |
| 4 | **Thread & State Management** | [04-thread-state-management.md](education/en/04-thread-state-management.md) |
| 5 | **Orchestration Patterns** | [05-orchestration.md](education/en/05-orchestration.md) |
| 6 | **Tools & Marketplace** | [06-tools-marketplace.md](education/en/06-tools-marketplace.md) |
| 7 | **Policy & Governance** | [07-policy-governance.md](education/en/07-policy-governance.md) |
| 8 | **Control Plane** | [08-control-plane.md](education/en/08-control-plane.md) |
| 9 | **Runtime Plane** | [09-runtime-plane.md](education/en/09-runtime-plane.md) |
| 10 | **Evaluation Engine** | [10-evaluation-engine.md](education/en/10-evaluation-engine.md) |
| 11 | **Observability & Cost** | [11-observability-cost.md](education/en/11-observability-cost.md) |
| 12 | **Security & Isolation** | [12-security-isolation.md](education/en/12-security-isolation.md) |
| 13 | **Scalability Patterns** | [13-scalability.md](education/en/13-scalability.md) |
| 14 | **HLD — Full Architecture** | [14-hld-architecture.md](education/en/14-hld-architecture.md) |
| 15 | **Microsoft Stack Mapping** | [15-microsoft-stack.md](education/en/15-microsoft-stack.md) |
| 16 | **Agent Frameworks & Ecosystem** | [16-agent-frameworks.md](education/en/16-agent-frameworks.md) |
| 17 | **Azure AI Foundry** | [17-azure-ai-foundry.md](education/en/17-azure-ai-foundry.md) |

---

## 🧪 Hands-On Labs

> **Learn by building.** Each lab teaches one core concept by writing real code with LangChain/LangGraph.

| Lab | What You Build | Education Chapters |
|-----|---------------|--------------------|
| **[Lab 00](labs/lab-00-setup/README.md)** | Azure environment setup (one-click deploy) | — |
| **[Lab 01](labs/lab-01-react-agent/README.md)** | Build a ReAct Agent from scratch, then with LangGraph | Ch 1 |
| **[Lab 02](labs/lab-02-model-routing/README.md)** | Smart model routing (cheap vs expensive) | Ch 2 |
| **[Lab 03](labs/lab-03-memory-rag/README.md)** | Memory & RAG integration | Ch 3, 4 |
| **[Lab 04](labs/lab-04-orchestration/README.md)** | Orchestration patterns (sequential, parallel, map-reduce) | Ch 5 |
| Lab 05 | Tool calling with safety guardrails | Ch 6, 7 |
| Lab 06 | Agent evaluation pipeline | Ch 10 |
| Lab 07 | Framework deep dive (LangGraph vs Deep Agents) | Ch 16 |
| Lab 08 | Observability & Monitoring | Ch 11 |
| Lab 09 | Azure AI Foundry | Ch 17 |

**[→ Get started with the labs](labs/README.md)**

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
