# Lab 08 — Observability & Cost Dashboard

## 🎯 What We're Building

You've built agents in Labs 01-07. They work. But in production, you need to answer:

- **What's happening right now?** — Is the agent running? How long does each step take?
- **Why is it slow?** — Was it the LLM call, the tool, or the RAG retrieval?
- **How much does it cost?** — How many tokens per request? Per tenant? Per model?
- **What went wrong?** — A user complaint — can you find the exact trace?

This lab teaches you to **instrument your agents with OpenTelemetry** and build a **cost tracking dashboard** — the same patterns used in production platforms.

```
┌──────────────────────────────────────────────────────┐
│               What You'll Build                       │
│                                                       │
│  Part 1: OpenTelemetry Tracing                        │
│  ├── Instrument a LangGraph agent                     │
│  ├── See spans for every LLM call, tool call          │
│  ├── Track parent→child relationships                 │
│  └── Visualize the full trace timeline                │
│                                                       │
│  Part 2: Token & Cost Tracking                        │
│  ├── Count tokens per request (input + output)        │
│  ├── Calculate cost per model, per agent              │
│  ├── Build a live cost dashboard                      │
│  └── Set budget alerts                                │
│                                                       │
│  Part 3: Custom Callbacks                             │
│  ├── Build a LangGraph callback handler               │
│  ├── Log every agent step with structured data         │
│  └── Track multi-turn conversation costs              │
│                                                       │
└──────────────────────────────────────────────────────┘
```

---

## 🏗️ The Three Pillars

| Pillar | What It Answers | Agent Example |
|--------|----------------|---------------|
| **Metrics** | "How much?" | Requests/sec, tokens/min, cost/hour |
| **Logs** | "What happened?" | Agent chose tool X, tool returned error |
| **Traces** | "Where in the flow?" | LLM call #2 took 3.5s (of 4.2s total) |

### Trace Anatomy for an Agent Request

```
Trace ID: abc-123                         Total: 4.2s
├── Agent Orchestrator                    ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  4.0s
│   ├── LLM Call 1 (think)               ▓▓▓░░░░░░░░░░░░░░░  1.2s
│   │   └── Tokens: 800 in + 400 out    Cost: $0.007
│   ├── Tool: get_weather                ░░░░▓░░░░░░░░░░░░░░  0.3s
│   ├── LLM Call 2 (observe + think)     ░░░░░▓▓░░░░░░░░░░░░  0.8s
│   │   └── Tokens: 1,500 in + 600 out  Cost: $0.010
│   ├── Tool: calculate                  ░░░░░░░░▓░░░░░░░░░░  0.1s
│   └── LLM Call 3 (final answer)        ░░░░░░░░░▓▓▓░░░░░░░  1.0s
│       └── Tokens: 700 in + 200 out     Cost: $0.004
└── Total: 3,000 in + 1,200 out tokens   Cost: $0.021
```

---

## 🛠️ Prerequisites

| Requirement | How to Check |
|------------|-------------|
| Lab 00 completed (Azure resources deployed) | `.env` file exists in `labs/` |
| Lab 01 completed (understand ReAct agents) | You built the raw agent |
| Python 3.11+ | `python --version` |

### Packages (installed in the notebook)

```bash
pip install opentelemetry-sdk opentelemetry-api
pip install opentelemetry-instrumentation-openai
pip install langgraph langchain-openai python-dotenv rich
```

---

## 📖 Related Education Chapter

- [Chapter 11: Observability & Cost Dashboard](../../education/en/11-observability-cost.md)

---

## 🗂️ Lab Files

```
lab-08-observability/
├── README.md       ← You are here
└── lab.ipynb       ← Main notebook (Parts 1-3)
```

---

**[← Back to Labs Overview](../README.md)**
