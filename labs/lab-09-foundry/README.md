# Lab 09 — Azure AI Foundry: Everything Out of the Box

## 🎯 The Big Idea

Remember all those things we built **by hand** in Labs 01–07?

| Lab | What We Built Manually | Lines of Code |
|-----|----------------------|---------------|
| Lab 01 | ReAct loop, tool calls, streaming | ~80 lines |
| Lab 02 | Model router with cost-based routing | ~60 lines |
| Lab 03 | Memory manager, RAG pipeline, vector store | ~120 lines |
| Lab 04 | Orchestration patterns (sequential, parallel, map-reduce) | ~100 lines |
| Lab 05 | Tool registry, DLP scanner, budget guardrails | ~90 lines |
| Lab 06 | Evaluation pipeline (groundedness, relevance, toxicity) | ~80 lines |
| Lab 07 | Framework comparison (LangGraph, SK, Deep Agents) | ~150 lines |

**Azure AI Foundry gives you ALL of that — out of the box.**

In this lab, you'll build the **same kind of agent** but this time using Azure AI Foundry's managed services. You'll see how it handles threads, tools, evaluations, and tracing **for you** — with a fraction of the code.

```
┌─────────────────────────────────────────────────────────────────────┐
│                     Azure AI Foundry                                │
│                                                                      │
│   ┌───────────────────────────────────────────────────────────┐     │
│   │  🤖 Agents Service                                        │     │
│   │   • Managed orchestration     (replaces Lab 01, 04)       │     │
│   │   • Built-in thread/state     (replaces Lab 03 state)     │     │
│   │   • File Search + Code Interp (replaces Lab 03 RAG, 05)   │     │
│   │   • Content Safety included   (replaces Lab 05 guardrails)│     │
│   └───────────────────────────────────────────────────────────┘     │
│                                                                      │
│   ┌───────────────────────────────────────────────────────────┐     │
│   │  📊 Evaluations                                           │     │
│   │   • Relevance, Coherence, Groundedness, Fluency           │     │
│   │   • Violence, Hate, Self-Harm, Sexual safety metrics      │     │
│   │   • Agent-specific: Intent Resolution, Tool Call Accuracy  │     │
│   │   • Portal visualization + SDK automation                  │     │
│   │   (replaces Lab 06)                                        │     │
│   └───────────────────────────────────────────────────────────┘     │
│                                                                      │
│   ┌───────────────────────────────────────────────────────────┐     │
│   │  🔍 Tracing & Observability                               │     │
│   │   • OpenTelemetry + GenAI semantic conventions             │     │
│   │   • Azure Monitor / Application Insights export            │     │
│   │   • Agent spans, tool spans, model spans — automatic       │     │
│   │   (replaces Lab 08 concepts)                               │     │
│   └───────────────────────────────────────────────────────────┘     │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🏗️ What You'll Build

In one notebook, three parts:

| Part | What | What It Replaces |
|------|------|-----------------|
| **Part 1** | Build a Foundry Agent with file search | Labs 01 + 03 (agent + RAG) |
| **Part 2** | Run built-in evaluations (quality + safety + agent) | Lab 06 (eval pipeline) |
| **Part 3** | Instrument with OpenTelemetry tracing | Lab 08 (observability) |

### Part 1: Build a Foundry Agent (~10 lines of code)

Compare this to Lab 01 where you built the ReAct loop by hand:

```python
# Lab 01: ~80 lines to build a ReAct agent
while True:
    response = client.chat.completions.create(...)
    if tool_calls: execute_tool(...)
    else: break

# Lab 09: ~10 lines with Foundry Agent Service
agent = project_client.agents.create_agent(model=..., instructions=..., tools=[...])
thread = project_client.agents.threads.create()
project_client.agents.messages.create(thread_id=thread.id, role="user", content="...")
run = project_client.agents.runs.create_and_process(thread_id=thread.id, agent_id=agent.id)
```

**Threads, state, tool orchestration, content safety — all managed for you.**

### Part 2: Built-in Evaluations (~5 lines per evaluator)

Compare this to Lab 06 where you built evaluation pipelines from scratch:

```python
# Lab 09: Built-in evaluators
from azure.ai.evaluation import RelevanceEvaluator, ViolenceEvaluator
relevance = RelevanceEvaluator(model_config)
result = relevance(query="...", response="...")  # Score 1-5, with reasoning!
```

### Part 3: Tracing (~3 lines to enable)

```python
# Lab 09: Automatic tracing with OpenTelemetry
OpenAIAgentsInstrumentor().instrument(tracer_provider=provider)
# That's it. All agent operations are now traced.
```

---

## 📚 Credits & Acknowledgments

> This lab is adapted from the excellent **[Microsoft Ignite 2025 — PREL13: Observe, Manage, and Scale Agentic AI Apps with Azure AI Foundry](https://github.com/microsoft/ignite25-PREL13-observe-manage-and-scale-agentic-ai-apps-with-microsoft-foundry)** workshop.
>
> Original authors: **Nitya Narasimhan** (@nitya), **Bethany Jepchumba** (@BethanyJep), and the Microsoft AI team.
>
> We adapted their labs to fit our course's environment (Lab 00 already deploys AI Foundry), added the "aha moment" narrative linking back to concepts from Labs 01–07, and restructured the content into a single focused notebook.
>
> **If you want to go deeper**, clone their full repo — it includes model customization, fine-tuning, deployment, and governance labs that go beyond what we cover here.

---

## 🛠️ Prerequisites

| Requirement | How to Check |
|------------|-------------|
| Lab 00 completed (Azure resources deployed) | `.env` file exists in `labs/` |
| Python 3.11+ | `python --version` |
| Azure CLI logged in | `az account show` |

### Additional Packages (installed in the notebook)

```bash
pip install azure-ai-projects azure-ai-evaluation azure-identity
pip install openai openai-agents opentelemetry-sdk
pip install opentelemetry-instrumentation-openai-agents-v2
pip install azure-monitor-opentelemetry-exporter
```

---

## 📖 Related Education Chapters

- [Chapter 17: Azure AI Foundry](../../education/en/17-azure-ai-foundry.md) — Full platform deep-dive
- [Chapter 15: Microsoft Stack Mapping](../../education/en/15-microsoft-stack.md) — How Azure services map to platform components

---

## 🗂️ Lab Files

```
lab-09-foundry/
├── README.md              ← You are here
├── lab.ipynb              ← Main notebook (Parts 1-3)
└── data/
    ├── evaluation-dataset.jsonl  ← Test data for Part 2
    └── products/                 ← Product catalog for Part 1
        ├── interior-eggshell-paint.md
        ├── zero-voc-interior-paint.md
        ├── exterior-acrylic-paint.md
        ├── cordless-drill-18v.md
        ├── finishing-hammer-13oz.md
        └── synthetic-brush-set.md
```

---

**[← Back to Labs Overview](../README.md)**
