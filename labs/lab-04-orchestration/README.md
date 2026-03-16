# Lab 04 — Orchestration Patterns: Sequential, Parallel & Map-Reduce

## 🎯 Learning Objectives

By the end of this lab, you will:

1. **Understand why orchestration matters** — single agents can't handle complex multi-step tasks alone
2. **Build a sequential pipeline** — step-by-step workflow where each step depends on the previous one
3. **Build parallel execution** — run multiple tasks simultaneously and merge results
4. **Build a Map-Reduce workflow** — process many documents in parallel, then synthesize
5. **Build a supervisor multi-agent system** — a manager agent that delegates to specialist agents
6. **Measure the speedup** — see real timing comparisons between sequential and parallel

---

## 🎭 Part 1: Why Orchestration Matters

### The Problem

A single agent with a ReAct loop (Lab 01) works great for simple tasks. But what about:

- "Analyze our sales data, compare to competitors, and write a report"
- "Summarize these 10 documents into one executive brief"
- "Research a topic, analyze the findings, then produce a polished deliverable"

These require **coordination** — multiple steps, multiple agents, or both.

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│   SIMPLE TASK (Lab 01):                                         │
│   "What's the weather?" → One agent, one tool call, done.      │
│                                                                  │
│   COMPLEX TASK (Lab 04):                                        │
│   "Prepare a CEO brief on AI trends"                            │
│   → Research (gather data from multiple sources)                │
│   → Analyze (identify patterns and implications)                │
│   → Write (produce polished deliverable)                        │
│   → Review (quality check)                                      │
│                                                                  │
│   This needs ORCHESTRATION — who does what, in what order?      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### The Key Question

> **How should we coordinate multiple steps or agents to complete a complex task?**

The answer depends on the task. That's why there are multiple orchestration patterns.

---

## 🔀 Part 2: The Four Patterns

### Pattern 1: Sequential Pipeline

Steps run one after another. Each step uses the output of the previous step.

```
Research → Draft → Review → Final
   3s       2s      2s      = 7s total
```

**When to use:** Steps have dependencies (draft needs research, review needs draft).

### Pattern 2: Parallel Execution (Fan-Out / Fan-In)

Multiple independent tasks run simultaneously, then results are merged.

```
         ┌─ Source A (2s) ─┐
Query ───┤─ Source B (2s) ─├─ Merge → Answer
         └─ Source C (2s) ─┘
              = 2s total (not 6s!)
```

**When to use:** Tasks are independent (searching 3 sources, checking 3 systems).

### Pattern 3: Map-Reduce

Split a big task into N subtasks (Map), process in parallel, combine into one result (Reduce).

```
10 docs → [Map: summarize each] → 10 summaries → [Reduce: synthesize] → 1 executive summary
```

**When to use:** Bulk processing (summarize many docs, analyze many records).

### Pattern 4: Supervisor Multi-Agent

A manager agent delegates to specialist agents, coordinates the workflow, and combines results.

```
         ┌─ 🔍 Researcher ─┐
🎩 Manager ─┤─ 📊 Analyst ────├─ Final deliverable
         └─ ✍️ Writer ──────┘
```

**When to use:** Complex tasks requiring different expertise (research + analysis + writing).

---

## 🏗️ Part 3: What We'll Build in the Notebook

### Stage 1: Sequential Pipeline with LangGraph

Build a 3-step content pipeline using LangGraph's StateGraph:
- Research → Draft → Review
- Measure total wall-clock time
- See how each step depends on the previous one

### Stage 2: Parallel Execution

Search 3 sources for the same query:
- First: run sequentially (baseline timing)
- Then: run in parallel with ThreadPoolExecutor
- Compare: see the ~3x speedup

### Stage 3: Map-Reduce

Process the Acme Corp documents from Lab 03:
- Map: summarize each document in parallel
- Reduce: synthesize all summaries into one executive brief
- Compare: sequential vs parallel map timing

### Stage 4: Supervisor Multi-Agent

Build a manager agent that coordinates 3 specialists:
- 🔍 Researcher — gathers facts and data
- 📊 Analyst — analyzes findings, identifies patterns
- ✍️ Writer — produces polished deliverables
- The manager decides who to call and when

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│   STAGE 1          STAGE 2          STAGE 3        STAGE 4      │
│   Sequential       Parallel         Map-Reduce     Supervisor   │
│                                                                  │
│   A → B → C        ┌─A─┐           Map:  [A,B,C]  Manager      │
│   (each waits)     ├─B─├→ Merge    Reduce: → One  delegates    │
│                    └─C─┘           summary      to experts     │
│                                                                  │
│   "I understand"   "Wow, 3x       "Process      "A whole       │
│                     faster!"       any number     team of       │
│                                    of docs!"      agents!"      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## ☁️ Azure Resources Used

| Resource | What For | Deployed In |
|----------|---------|-------------|
| **Azure OpenAI** (GPT-4.1) | Agent reasoning, all LLM calls | Lab 00 |

This lab only needs Azure OpenAI — no additional services required!

---

## 📋 Concepts Covered

| Concept | Where | What You Learn |
|---------|-------|----------------|
| **Sequential pipeline** | Stage 1 | Building step-by-step workflows with LangGraph StateGraph |
| **State passing** | Stage 1 | How data flows between steps via shared state |
| **Parallel execution** | Stage 2 | Running independent tasks simultaneously |
| **ThreadPoolExecutor** | Stage 2 | Python's built-in mechanism for parallel execution |
| **Fan-Out / Fan-In** | Stage 2 | Splitting work out, merging results back |
| **Map-Reduce** | Stage 3 | Processing bulk data with parallel map + single reduce |
| **Speedup measurement** | Stage 2-3 | Timing sequential vs parallel to quantify improvement |
| **Supervisor pattern** | Stage 4 | Manager agent delegating to specialist sub-agents |
| **Multi-agent coordination** | Stage 4 | How agents work together on complex tasks |

---

## ⏱️ Estimated Time

| Section | Time |
|---------|------|
| Reading this README | 10 min |
| Stage 1 (Sequential pipeline) | 15 min |
| Stage 2 (Parallel execution) | 20 min |
| Stage 3 (Map-Reduce) | 20 min |
| Stage 4 (Supervisor multi-agent) | 25 min |
| **Total** | **~1.5 hours** |

---

## 📝 Key Takeaways (Read After the Lab)

After completing this lab, you should be able to answer:

1. **When to use sequential vs parallel?** — Sequential when steps depend on each other, parallel when they don't.
2. **What's the actual speedup from parallelism?** — Roughly N× for N independent tasks (limited by the slowest task).
3. **What is Map-Reduce?** — Split big work into small parallel pieces (Map), combine results (Reduce).
4. **When to use a supervisor?** — When the task requires multiple types of expertise and coordination.
5. **What are the trade-offs?** — Parallel is faster but more complex; supervisor is flexible but costs more LLM calls.

---

> **Ready to orchestrate?** Open **[lab.ipynb](lab.ipynb)** and let's coordinate some agents! 🎭
