# 🎭 Chapter 5: Orchestration Patterns

## Table of Contents
- [What is Orchestration?](#what-is-orchestration)
- [Sequential Execution](#sequential-execution)
- [Parallel Execution](#parallel-execution)
- [Autonomous Execution](#autonomous-execution)
- [Sub-Agent Orchestration](#sub-agent-orchestration)
- [DAG Workflows](#dag-workflows)
- [Advanced Patterns](#advanced-patterns)
- [Patterns Comparison](#patterns-comparison)
- [Choosing the Right Pattern](#choosing-the-right-pattern)
- [Summary and Questions](#summary-and-questions)

---

## What is Orchestration?

**Orchestration** = how the Agent (or multiple Agents) coordinate actions to complete a task.

```mermaid
graph TB
    subgraph "Analogy"
        Conductor["🎼 Orchestra Conductor = Orchestrator"]
        Violin["🎻 Violin = Agent 1"]
        Piano["🎹 Piano = Agent 2"]
        Drums["🥁 Drums = Agent 3"]
        
        Conductor --> Violin
        Conductor --> Piano
        Conductor --> Drums
        
        Note1["The conductor determines who plays, when, and in what order"]
    end
```

### Why do we need Orchestration?

Simple tasks = one Agent is enough. Complex tasks = require **coordination**:

| Task | One Agent? | Orchestration? |
|------|-----------|---------------|
| "What's the weather?" | ✅ | ❌ |
| "Summarize the email" | ✅ | ❌ |
| "Analyze sales, compare to competitors, and write a report" | ❌ | ✅ |
| "Plan a trip: flights + hotel + car rental" | ❌ | ✅ |

---

## Sequential Execution

### What is it?
Step after step - each step starts only after the previous one finishes.

```mermaid
graph LR
    S1["Step 1:<br/>Fetch data"] --> S2["Step 2:<br/>Analyze trends"]
    S2 --> S3["Step 3:<br/>Create graphs"]
    S3 --> S4["Step 4:<br/>Write report"]
    S4 --> Result["📄 Report ready"]
```

### Example: Document Processing Pipeline

```mermaid
graph LR
    Input["📄 PDF"] --> Extract["1. Extract text"]
    Extract --> Clean["2. Clean & process"]
    Clean --> Summarize["3. Summarize"]
    Summarize --> Translate["4. Translate"]
    Translate --> Output["📋 Result"]
```

### Pros and Cons

| ✅ Pros | ❌ Cons |
|---------|---------|
| Easy to understand | Slow - each step waits for the previous one |
| Easy to debug | Doesn't utilize parallelism |
| Deterministic - always the same order | If a step fails, everything stops |
| Easy to add Checkpoint | |

---

## Parallel Execution

### What is it?
Multiple actions run **in parallel** - not dependent on each other.

```mermaid
graph TB
    Start["📥 Task: 'Check 3 sources'"] --> Fork["🔀 Fork"]
    
    Fork --> A1["Agent 1:<br/>Search Wikipedia"]
    Fork --> A2["Agent 2:<br/>Search internal DB"]
    Fork --> A3["Agent 3:<br/>Search news"]
    
    A1 --> Join["🔄 Join / Merge"]
    A2 --> Join
    A3 --> Join
    
    Join --> Result["📋 Combined result"]
```

### Fan-Out / Fan-In Pattern

```mermaid
graph TB
    subgraph "Fan-Out (Scatter)"
        Task["Task"] --> T1["Task 1"]
        Task --> T2["Task 2"]
        Task --> T3["Task 3"]
    end
    
    subgraph "Fan-In (Gather)"
        T1 --> Merge["Merge Results"]
        T2 --> Merge
        T3 --> Merge
    end
    
    Merge --> Final["Final result"]
```

### Challenges in Parallel Execution:

```mermaid
graph TB
    Challenge["⚠️ Challenges"]
    
    Challenge --> C1["🕐 Timeout<br/>What if one doesn't finish?"]
    Challenge --> C2["❌ Partial Failure<br/>What if one fails?"]
    Challenge --> C3["🔄 Merge Logic<br/>How to combine results?"]
    Challenge --> C4["💰 Cost<br/>Multiple LLM calls = expensive"]
```

| Challenge | Solution |
|-----------|----------|
| **Timeout** | Set a deadline; if not finished, continue without it |
| **Partial Failure** | Decide: one failure = all fail? Or continue with what's available? |
| **Merge** | Aggregator Agent that combines results |
| **Cost** | Limit parallelism (max concurrent) |

### Pros and Cons

| ✅ Pros | ❌ Cons |
|---------|---------|
| Fast (N operations in the time of 1) | Complex |
| Good resource utilization | Merge logic is non-trivial |
| Suitable for multi-source search | Partial failure is hard to handle |

---

## Autonomous Execution

### What is it?
The Agent **decides on its own** what to do next. No predefined workflow - the Agent navigates as needed.

```mermaid
graph TD
    Start["📥 'Find why sales dropped'"]
    Start --> Think1["🤔 Think:<br/>'I need sales data'"]
    Think1 --> Act1["🔧 Act:<br/>SQL query - get sales data"]
    Act1 --> Observe1["👀 Observe:<br/>'Drop in Q3'"]
    Observe1 --> Think2["🤔 Think:<br/>'I'll check what happened in Q3'"]
    Think2 --> Act2["🔧 Act:<br/>Search news for Q3"]
    Act2 --> Observe2["👀 Observe:<br/>'New competitor entered the market'"]
    Observe2 --> Think3["🤔 Think:<br/>'That explains it. I have enough'"]
    Think3 --> Answer["📤 'Sales dropped due to a new competitor...'"]
```

### ReAct Pattern (Reason + Act)

```mermaid
graph TD
    Input["📥 Task"] --> Loop
    
    subgraph Loop["🔄 ReAct Loop"]
        Reason["🤔 Reason<br/>(LLM decides what to do)"]
        Act["🔧 Act<br/>(Execute tool/action)"]
        Observe["👀 Observe<br/>(Check result)"]
        
        Reason --> Act
        Act --> Observe
        Observe --> Reason
    end
    
    Loop -->|"Done"| Output["📤 Final Answer"]
```

### Plan-and-Execute Pattern

An improvement over ReAct: the Agent **plans ahead** and then **executes** the plan:

```mermaid
graph TD
    Task["📥 Task"] --> Planner["📋 Planner Agent"]
    
    Planner --> Plan["Plan:<br/>1. Get sales data<br/>2. Analyze trends<br/>3. Compare competitors<br/>4. Write report"]
    
    Plan --> E1["Execute Step 1"]
    E1 --> E2["Execute Step 2"]
    E2 --> Replan{"Need to replan?"}
    Replan -->|"Yes"| Planner
    Replan -->|"No"| E3["Execute Step 3"]
    E3 --> E4["Execute Step 4"]
    E4 --> Result["📤 Result"]
```

### Pros and Cons

| ✅ Pros | ❌ Cons |
|---------|---------|
| Very flexible | Unpredictable (non-deterministic) |
| Discovers things you didn't think of | Can get lost |
| Suitable for open-ended problems | High cost (many LLM calls) |
| | Hard to debug |
| | Requires strong guardrails |

---

## Sub-Agent Orchestration

### What is it?
A main Agent that delegates tasks to **specialist Agents**:

```mermaid
graph TB
    User["👤 User"] --> Manager["🎩 Manager Agent<br/>'Manager'"]
    
    Manager --> Researcher["🔍 Research Agent<br/>'Researcher'"]
    Manager --> Analyst["📊 Analyst Agent<br/>'Analyst'"]
    Manager --> Writer["✍️ Writer Agent<br/>'Writer'"]
    
    Researcher -->|"Findings"| Manager
    Analyst -->|"Analysis"| Manager
    Writer -->|"Report"| Manager
    
    Manager --> User
```

### Example: Writing an Article

```mermaid
sequenceDiagram
    actor User as 👤 User
    participant Mgr as 🎩 Manager
    participant Res as 🔍 Researcher
    participant Wrt as ✍️ Writer
    participant Rev as 🔎 Reviewer
    
    User->>Mgr: "Write an article about AI Agents"
    
    Mgr->>Res: "Research the topic"
    Res-->>Mgr: Research findings
    
    Mgr->>Wrt: "Write an article based on the findings"
    Wrt-->>Mgr: Draft article
    
    Mgr->>Rev: "Review the article"
    Rev-->>Mgr: Review + corrections
    
    Mgr->>Wrt: "Fix according to the comments"
    Wrt-->>Mgr: Final article
    
    Mgr-->>User: "Here's the final article"
```

### Sub-Agent Patterns:

```mermaid
graph TB
    subgraph "1. Delegation"
        M1["Manager"] -->|"task"| S1["Sub-Agent"]
        S1 -->|"result"| M1
    end
    
    subgraph "2. Discussion"
        A1["Agent A"] <-->|"back & forth"| A2["Agent B"]
    end
    
    subgraph "3. Voting"
        V1["Agent 1"] --> Vote["🗳️"]
        V2["Agent 2"] --> Vote
        V3["Agent 3"] --> Vote
        Vote --> Decision["Decision"]
    end
```

### Pros and Cons

| ✅ Pros | ❌ Cons |
|---------|---------|
| Each Agent specializes in its domain | Communication overhead |
| Scaling of experts | Multiple LLM calls = cost |
| Modularity - easy to replace an Agent | Complex management |
| Parallel execution possible | Debugging is hard |

---

## DAG Workflows

### What is a DAG?
**DAG = Directed Acyclic Graph** = a directed graph with no cycles.

Allows describing complex workflows with **dependencies** - "step X runs only after A and B finish":

```mermaid
graph TB
    A["📥 Get Data"] --> B["📊 Analyze Sales"]
    A --> C["📊 Analyze Costs"]
    B --> D["📋 Compare"]
    C --> D
    D --> E["✍️ Write Report"]
    A --> F["🔍 Market Research"]
    F --> E
    E --> G["📤 Send Report"]
```

### Why DAG and not a list?

```mermaid
graph LR
    subgraph "❌ Sequential (Linear)"
        L1["A"] --> L2["B"] --> L3["C"] --> L4["D"] --> L5["E"]
        Note1["Total time: 5 units"]
    end
```

```mermaid
graph TB
    subgraph "✅ DAG (Parallel where possible)"
        D1["A"] --> D2["B"]
        D1 --> D3["C"]
        D2 --> D4["D"]
        D3 --> D4
        D4 --> D5["E"]
        Note2["Total time: 3 units!"]
    end
```

### DAG vs Sequential:

| Sequential | DAG |
|-----------|-----|
| A→B→C→D→E = 5 steps | A→(B,C parallel)→D→E = 3 steps |
| Simple | Fast |
| Each step depends on the previous one | Independent steps run in parallel |

---

## Advanced Patterns

### 1. Map-Reduce Pattern

```mermaid
graph TB
    Input["📄 100 documents"] --> Map["🗺️ Map:<br/>Summarize each document separately"]
    
    Map --> S1["Summary 1"]
    Map --> S2["Summary 2"]
    Map --> S3["..."]
    Map --> SN["Summary 100"]
    
    S1 --> Reduce["📊 Reduce:<br/>Combine all summaries"]
    S2 --> Reduce
    S3 --> Reduce
    SN --> Reduce
    
    Reduce --> Final["📋 One comprehensive summary"]
```

**Suitable for:** Summarizing many documents, analyzing datasets, aggregation

#### Map-Reduce Implementation Example

```python
import asyncio

async def map_reduce_summarize(documents: list[str]) -> str:
    """Summarize 100 documents using Map-Reduce pattern."""
    
    # MAP PHASE: Process each document in parallel
    async def summarize_one(doc: str) -> str:
        """Summarize a single document (one LLM call)."""
        return await llm.call(
            f"Summarize this document in 2-3 sentences:\n\n{doc}"
        )
    
    # Run 10 concurrent workers (not 100 — respect rate limits!)
    semaphore = asyncio.Semaphore(10)
    
    async def limited_summarize(doc):
        async with semaphore:
            return await summarize_one(doc)
    
    summaries = await asyncio.gather(
        *[limited_summarize(doc) for doc in documents]
    )
    # Result: 100 individual summaries, ~10 seconds (parallel)
    
    # REDUCE PHASE: Combine all summaries into one
    combined = "\n".join(
        f"[Doc {i+1}]: {s}" for i, s in enumerate(summaries)
    )
    
    final_summary = await llm.call(
        f"Synthesize these {len(summaries)} document summaries "
        f"into one cohesive report:\n\n{combined}"
    )
    # Result: One comprehensive summary
    
    return final_summary

# Performance comparison:
# Sequential: 100 LLM calls × 3s = ~300 seconds
# Map-Reduce:  10 batches × 3s + 1 reduce = ~33 seconds (9x faster!)
```

### 2. Supervisor Pattern

```mermaid
graph TB
    Sup["👁️ Supervisor Agent"]
    
    Sup -->|"assign"| W1["Worker 1"]
    Sup -->|"assign"| W2["Worker 2"]
    Sup -->|"assign"| W3["Worker 3"]
    
    W1 -->|"status"| Sup
    W2 -->|"status"| Sup
    W3 -->|"status"| Sup
    
    Sup -->|"reassign if failed"| W4["Worker 4 (backup)"]
```

**Supervisor is responsible for:**
- Assigning tasks to Workers
- Tracking progress
- Handling failures (reassign)
- Deciding when everything is done

### 3. Critic Pattern

```mermaid
graph TD
    Task["📥 Task"] --> Generator["✍️ Generator Agent"]
    Generator --> Output["Draft output"]
    Output --> Critic["🔎 Critic Agent"]
    Critic -->|"❌ Not good enough"| Generator
    Critic -->|"✅ Good enough"| Final["📤 Final Output"]
```

**Suitable for:** Writing, code, answers that require high quality

---

## Patterns Comparison

```mermaid
quadrantChart
    title Orchestration Patterns: Complexity vs Flexibility
    x-axis Simple --> Complex
    y-axis Rigid --> Flexible
    quadrant-1 Powerful but Complex
    quadrant-2 Sweet Spot
    quadrant-3 Limited
    quadrant-4 Over-engineered
    Sequential: [0.15, 0.15]
    Parallel: [0.4, 0.3]
    DAG: [0.55, 0.5]
    ReAct: [0.35, 0.85]
    Plan-Execute: [0.55, 0.75]
    Sub-Agents: [0.7, 0.7]
    Map-Reduce: [0.45, 0.35]
    Supervisor: [0.8, 0.8]
```

| Pattern | Suitable for | Complexity | Cost |
|---------|-------------|------------|------|
| **Sequential** | Simple pipelines | ⭐ | 💰 |
| **Parallel** | Multi-source search | ⭐⭐ | 💰💰 |
| **ReAct** | Open-ended problems | ⭐⭐ | 💰💰💰 |
| **Plan-Execute** | Complex tasks | ⭐⭐⭐ | 💰💰💰 |
| **Sub-Agents** | Team of experts | ⭐⭐⭐ | 💰💰💰💰 |
| **DAG** | Workflows with dependencies | ⭐⭐⭐ | 💰💰 |
| **Map-Reduce** | Bulk processing | ⭐⭐ | 💰💰💰 |
| **Supervisor** | Distributed systems | ⭐⭐⭐⭐ | 💰💰💰💰 |

---

## Choosing the Right Pattern

With so many patterns, how do you decide which one to use? Start with these questions:

### Decision Tree

```
📥 You have a task. Ask yourself:
│
├─ Is it a single step?
│   └─ YES → No orchestration needed. Use a simple ReAct agent (Ch 1).
│
├─ Does it have multiple steps that DEPEND on each other?
│   └─ YES → Sequential Pipeline
│        Example: Research → Draft → Review → Publish
│
├─ Does it have multiple INDEPENDENT tasks?
│   ├─ Are they all the SAME operation on different data?
│   │   └─ YES → Map-Reduce
│   │        Example: Summarize 50 documents → merge into one report
│   └─ Are they DIFFERENT operations?
│       └─ YES → Parallel (Fan-Out / Fan-In)
│            Example: Search news + search DB + search docs → merge
│
├─ Does it have tasks with MIXED dependencies?
│   └─ YES → DAG Workflow
│        Example: A→(B,C parallel)→D→(E,F parallel)→G
│
├─ Does it need multiple types of EXPERTISE?
│   └─ YES → Supervisor / Sub-Agent
│        Example: Manager → Researcher, Analyst, Writer
│
├─ Is it OPEN-ENDED (you don't know the steps in advance)?
│   ├─ Simple exploration → ReAct (reason + act loop)
│   └─ Complex multi-step → Plan-and-Execute
│
└─ Does the output need to be HIGH QUALITY?
    └─ YES → Add a Critic pattern (generate → review → refine loop)
```

### Real-World Scenarios

| Scenario | Best Pattern | Why |
|----------|-------------|-----|
| "Summarize this email" | None (single LLM call) | Too simple for orchestration |
| "Translate this document to 5 languages" | **Map-Reduce** | Same operation (translate) on the same input, then combine |
| "Find the cheapest flight + hotel + car rental" | **Parallel** | 3 independent searches, then merge and compare |
| "Analyze Q3 sales, compare to competitors, write report" | **Sequential** | Each step depends on the previous |
| "Research AI trends, analyze implications, write CEO brief" | **Supervisor** | Needs different expertise per step |
| "Summarize 100 support tickets and find trends" | **Map-Reduce** | Summarize each (Map), find patterns (Reduce) |
| "Extract data → clean → validate → enrich → load" | **DAG** | Some steps can parallelize, others depend |
| "Debug why the app is crashing" | **ReAct** | Open-ended, agent discovers next step |
| "Plan a product launch (timeline, tasks, owners)" | **Plan-and-Execute** | Complex, needs upfront planning then execution |
| "Write a blog post with high quality" | **Critic** | Generate draft → review → improve → repeat |

### Common Mistakes

| Mistake | Why It's Wrong | Fix |
|---------|---------------|-----|
| Using Sequential when tasks are independent | Wastes time — 3 independent calls take 3x longer | Use Parallel |
| Using Parallel when tasks depend on each other | Results will be wrong — step 2 needs step 1's output | Use Sequential |
| Using Supervisor for a 2-step pipeline | Over-engineering — adds LLM calls for the manager | Use Sequential |
| Using Map-Reduce for 2 documents | Overhead isn't worth it for small N | Use Sequential |
| Using ReAct for a fixed workflow | Unpredictable — the agent might take wrong paths | Use Sequential or DAG |
| No rate-limit control in Parallel/Map-Reduce | Hits API rate limits with too many concurrent calls | Add a semaphore |

### Combining Patterns

In production, you often **combine** patterns:

```
┌─────────────────────────────────────────────────────────┐
│  Real-World Example: Monthly Analytics Report           │
│                                                         │
│  1. Parallel: Fetch data from 4 sources simultaneously  │
│         ↓                                               │
│  2. Map-Reduce: Summarize each dataset in parallel      │
│         ↓                                               │
│  3. Sequential: Analyze → Draft report → Review         │
│         ↓                                               │
│  4. Critic: Check quality, refine if needed             │
│                                                         │
│  Total: 4 patterns combined into one workflow           │
└─────────────────────────────────────────────────────────┘
```

---

## Summary

```mermaid
mindmap
  root((Orchestration))
    Sequential
      Pipeline
      Chain
    Parallel
      Fan-Out/Fan-In
      Map-Reduce
    Autonomous
      ReAct Loop
      Plan & Execute
    Multi-Agent
      Sub-Agent Delegation
      Discussion
      Voting
      Supervisor
    DAG Workflows
      Dependencies
      Critical Path
```

| What we learned | Key point |
|----------------|-----------|
| **Sequential** | Step after step - simple but slow |
| **Parallel** | Multiple operations in parallel - fast but complex |
| **Autonomous** | Agent decides on its own - flexible but unpredictable |
| **Sub-Agents** | Experts for each domain - modular but expensive |
| **DAG** | Dependency graph - balances between parallelism and order |
| **Map-Reduce** | Bulk data processing |
| **Supervisor** | Agent that manages workers |

---

## ❓ Self-Check Questions

1. What is the difference between Sequential and Parallel execution?
2. What is the ReAct Pattern? Describe the loop.
3. What is the advantage of Plan-and-Execute over ReAct?
4. When should you use Sub-Agents?
5. What is a DAG and why is it better than a list?
6. What is the Map-Reduce Pattern and when is it used?
7. What is the role of the Supervisor Agent?
8. Which Pattern is suitable for each situation: summarizing 100 documents? Searching 3 sources? Writing an article?

---

### 📝 Answers

<details>
<summary>1. What is the difference between Sequential and Parallel execution?</summary>

**Sequential** = steps run one after another. The output of step 1 feeds into step 2. Simple, but slow. **Parallel** = steps run simultaneously. Fast, but requires dependency management and fan-out/fan-in.
</details>

<details>
<summary>2. What is the ReAct Pattern? Describe the loop.</summary>

**ReAct (Reason + Act)** = a loop of: **Think** (the LLM analyzes what to do) → **Act** (invokes a tool / performs an action) → **Observe** (sees the result) → returns to Think until done. The Agent stops when it has no more actions to perform or reaches max steps.
</details>

<details>
<summary>3. What is the advantage of Plan-and-Execute over ReAct?</summary>

**ReAct** decides step by step - doesn't see the full picture. **Plan-and-Execute** first creates a **complete plan** and then executes step by step. Advantages: (1) higher efficiency, (2) fewer LLM calls (planning only once, each execution is separate), (3) each executor can be parallelized.
</details>

<details>
<summary>4. When should you use Sub-Agents?</summary>

When the task **consists of multiple different domains** (search + writing + analysis). Each sub-agent is an expert in one domain with a customized system prompt, tools, and model. A main Agent (Supervisor) routes to sub-agents and combines results.
</details>

<details>
<summary>5. What is a DAG and why is it better than a list?</summary>

**DAG (Directed Acyclic Graph)** = a directed graph with no cycles. Better than a list because: (1) enables **parallelism** - steps without dependencies run in parallel, (2) enables **complex dependencies** - A → B and also A → C in parallel, (3) ensures there are no **infinite loops**.
</details>

<details>
<summary>6. What is the Map-Reduce Pattern and when is it used?</summary>

**Map** = splitting a large task into many sub-tasks that run in parallel. **Reduce** = combining all results into one answer. Suitable for: summarizing 100 documents (Map: summarize each one | Reduce: combine into one summary), analysis of multiple tables.
</details>

<details>
<summary>7. What is the role of the Supervisor Agent?</summary>

**Supervisor Agent** = a main Agent that manages a team of Sub-Agents. It: (1) receives the task from the user, (2) decides which sub-agent to route to, (3) tracks results, (4) combines and returns a final answer. It is responsible for routing and quality.
</details>

<details>
<summary>8. Which Pattern is suitable for each situation?</summary>

- **Summarizing 100 documents** → **Map-Reduce**: Map summarizes each one, Reduce combines.
- **Searching 3 sources** → **Parallel + Fan-In**: 3 searches in parallel, combine results.
- **Writing an article** → **Plan-and-Execute**: first a plan (outline, research, draft, review) then sequential execution.
</details>

---

**[⬅️ Back to Chapter 4: Thread & State](04-thread-state-management.md)** | **[➡️ Continue to Chapter 6: Tools & Marketplace →](06-tools-marketplace.md)**
