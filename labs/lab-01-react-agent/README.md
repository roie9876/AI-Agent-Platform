# Lab 01 — Building a ReAct Agent from Scratch

## 🎯 Learning Objectives

By the end of this lab, you will:

1. **Understand what an AI Agent actually IS** — not the marketing version, the engineering version
2. **Build a working agent with raw Python** — no framework, just you and the OpenAI API
3. **See the ReAct loop in action** — Think → Act → Observe, step by step
4. **Understand WHY frameworks exist** — by feeling the pain of doing it without one
5. **Rebuild the same agent with LangGraph** — and appreciate what the framework gives you

---

## 🧠 Part 1: What is an Agent, Really?

### The One-Sentence Answer

> **An Agent is an LLM that can use tools in a loop until it has enough information to answer.**

That's it. Everything else is details.

### Let's Break It Down

An AI Agent has exactly **three components**:

```
┌─────────────────────────────────────────────────────────────────┐
│                        AI AGENT                                  │
│                                                                  │
│   ┌──────────┐     ┌──────────┐     ┌──────────┐               │
│   │  🧠 LLM  │     │ 🔧 Tools │     │ 🔄 Loop  │               │
│   │          │     │          │     │          │               │
│   │ Thinks & │     │ Actions  │     │ Keeps    │               │
│   │ decides  │     │ it can   │     │ going    │               │
│   │ what to  │     │ take in  │     │ until    │               │
│   │ do next  │     │ the real │     │ done     │               │
│   │          │     │ world    │     │          │               │
│   └──────────┘     └──────────┘     └──────────┘               │
│                                                                  │
│   "I need sales data"  → SQL query  → "Got it, now I'll        │
│                          → results     analyze..."              │
└─────────────────────────────────────────────────────────────────┘
```

### What is NOT an Agent?

This is important. Many things are called "agents" but aren't:

| What it is | Why it's NOT an agent | What's missing |
|------------|----------------------|----------------|
| ChatGPT answering a question | It responds once, no tools | 🔧 Tools, 🔄 Loop |
| A script that calls an API | No decision-making | 🧠 LLM reasoning |
| A chatbot with a knowledge base | Retrieves but doesn't act | 🔄 Loop, multi-step |
| A cron job that runs daily | No reasoning, fixed logic | 🧠 LLM |

**An agent MUST have all three: reasoning (LLM) + action (tools) + iteration (loop).**

---

## 🔄 Part 2: The ReAct Pattern

### What is ReAct?

**ReAct** stands for **Reasoning + Acting**. It's the most common pattern for building agents. The idea was published in a [2022 research paper](https://arxiv.org/abs/2210.03629) and it's surprisingly simple:

```
┌─────────────────────────────────────────────────────────────────┐
│                   THE ReAct LOOP                                 │
│                                                                  │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐                 │
│   │ 🤔 THINK │───▶│ 🔧 ACT   │───▶│ 👀 OBSERVE│                │
│   │          │    │          │    │          │                 │
│   │ "What do │    │ Execute  │    │ "What    │                 │
│   │  I need  │    │ a tool   │    │  did I   │                 │
│   │  to do?" │    │          │    │  get?"   │                 │
│   └──────────┘    └──────────┘    └──────────┘                 │
│        ▲                               │                        │
│        │                               │                        │
│        └───────────────────────────────┘                        │
│              Repeat until done                                  │
│                                                                  │
│   When the agent decides it has enough info:                    │
│        ┌──────────┐                                             │
│        │ 📤 ANSWER│  → Return final response to user            │
│        └──────────┘                                             │
└─────────────────────────────────────────────────────────────────┘
```

### A Concrete Example

Let's trace through a real request: **"What were the top 3 products by revenue last quarter?"**

```
ITERATION 1:
  🤔 THINK:  "I need to query the sales database for last quarter's data"
  🔧 ACT:    sql_query("SELECT product, SUM(revenue) as total 
                         FROM sales WHERE quarter='Q3-2025' 
                         GROUP BY product ORDER BY total DESC LIMIT 3")
  👀 OBSERVE: [
    {"product": "Widget Pro", "total": 2340000},
    {"product": "Gadget X",   "total": 1870000},
    {"product": "Tool Kit",   "total": 1520000}
  ]

ITERATION 2:
  🤔 THINK:  "I have the data. Let me format a clear answer."
  📤 ANSWER: "The top 3 products by revenue last quarter were:
              1. Widget Pro — $2.34M
              2. Gadget X  — $1.87M  
              3. Tool Kit  — $1.52M"
```

**Key insight:** The LLM decided what tool to use, what arguments to pass, and when it had enough information. Nobody programmed this specific flow — the LLM **reasoned** its way through.

### Why Not Just One LLM Call?

You might ask: "Why not just ask the LLM directly?"

Because **LLMs can't access your data**. They can only work with text in their prompt. The ReAct loop gives the LLM **superpowers** by letting it:

1. **Call tools** to get real data (databases, APIs, files)
2. **Make decisions** based on what it finds
3. **Iterate** if the first attempt wasn't enough
4. **Combine information** from multiple tool calls

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│   WITHOUT TOOLS:                                                │
│   User: "What were Q3 sales?"                                   │
│   LLM:  "I don't have access to your sales data." 😔            │
│                                                                  │
│   WITH TOOLS (ReAct):                                           │
│   User: "What were Q3 sales?"                                   │
│   LLM:  Think → "I'll query the database"                       │
│         Act   → sql_query(...)                                  │
│         Observe → [{Widget Pro: $2.34M}, ...]                   │
│         Think → "I have the data, let me answer"                │
│         Answer → "Top 3 products were Widget Pro ($2.34M)..."   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## ⚙️ Part 3: How Function Calling Works (The Mechanism)

### The Key Insight

The LLM **never actually executes** a tool. It only **asks** for a tool to be called. YOUR code does the actual execution.

This is the most misunderstood part of agents. Let's be very precise:

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│  YOUR CODE                    LLM (OpenAI)                      │
│  ──────────                   ────────────                      │
│                                                                  │
│  1. Send message    ─────▶   "Hmm, I need data..."             │
│     + tool definitions       "I'll use sql_query"               │
│                                                                  │
│  2. Receive back    ◀─────   { tool_call: "sql_query",          │
│     a tool_call request       arguments: {"sql": "SELECT..."} } │
│                                                                  │
│  3. YOU execute the   ┌──▶  Database                            │
│     tool yourself     └──   Results                             │
│                                                                  │
│  4. Send results    ─────▶   "Ah, I see the data..."            │
│     back to LLM                "Here's my answer: ..."          │
│                                                                  │
│  5. Receive final   ◀─────   "The top products were..."         │
│     answer                                                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**The LLM outputs JSON describing what tool to call. Your code calls the tool. You send the result back. The LLM continues.**

This is critical for security: the LLM never has direct access to your database, filesystem, or APIs. Your code is always in control.

### Tool Definitions

When you call the LLM, you tell it what tools are available by sending **tool definitions** — JSON schemas that describe each tool:

```json
{
  "type": "function",
  "function": {
    "name": "get_weather",
    "description": "Get the current weather for a given city",
    "parameters": {
      "type": "object",
      "properties": {
        "city": {
          "type": "string",
          "description": "The city name, e.g., 'Tel Aviv'"
        }
      },
      "required": ["city"]
    }
  }
}
```

The LLM reads these definitions and decides **when** and **how** to use each tool. The better your descriptions, the better the LLM will use the tools.

---

## 🏗️ Part 4: What We'll Build in the Notebook

In the hands-on notebook, you'll build agents in **three stages**:

### Stage 1: Raw Agent (No Framework)

You'll build a complete agent using only the OpenAI Python SDK. This means:
- Writing the ReAct loop yourself
- Managing the message history
- Parsing tool calls from the LLM response
- Executing tools and sending results back
- Deciding when to stop the loop

**Why start here?** Because you need to understand what happens "under the hood" before using a framework. A framework is just automating what you'll build by hand first.

### Stage 2: LangGraph Agent

You'll rebuild the same agent using LangGraph. You'll see how the framework:
- Manages the state for you
- Handles the tool execution loop automatically
- Adds checkpointing (save/resume state)
- Provides a visual graph structure

### Stage 3: Adding Memory and Persistence

You'll add conversation memory so the agent remembers previous interactions, and persistence so it survives crashes.

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│   STAGE 1          STAGE 2            STAGE 3                   │
│   Raw Python       LangGraph          + Memory                  │
│                                                                  │
│   ┌──────┐         ┌──────┐          ┌──────┐                  │
│   │ You  │         │Frame-│          │Persis│                  │
│   │write │   ──▶   │work  │   ──▶    │tent  │                  │
│   │every-│         │does  │          │agent │                  │
│   │thing │         │it for│          │with  │                  │
│   │      │         │you   │          │memory│                  │
│   └──────┘         └──────┘          └──────┘                  │
│                                                                  │
│   ~80 lines         ~15 lines         ~25 lines                 │
│   of code           of code           of code                   │
│                                                                  │
│   "I understand"    "That's way       "Now it                   │
│                      easier!"          remembers!"              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔧 Tools We'll Give Our Agent

Our agent will have three simple tools:

| Tool | What It Does | Example |
|------|-------------|---------|
| `get_weather` | Returns weather for a city | `get_weather("Tel Aviv")` → "25°C, sunny" |
| `calculate` | Evaluates a math expression | `calculate("15 * 7 + 3")` → 108 |
| `search_knowledge` | Searches a small knowledge base | `search_knowledge("company policy")` → "..." |

We use simple tools on purpose — the goal is to learn the **agent pattern**, not to build complex integrations. Once you understand the pattern, you can swap these for any real tool.

---

## 📋 Concepts Covered

| Concept | Where | What You Learn |
|---------|-------|----------------|
| **LLM as Reasoner** | Stage 1 | The LLM decides what to do, not your code |
| **Tool Calling** | Stage 1 | How the LLM requests tool execution via JSON |
| **ReAct Loop** | Stage 1 | The Think → Act → Observe cycle |
| **Message History** | Stage 1 | How the LLM tracks context across iterations |
| **Max Iterations** | Stage 1 | Safety: preventing infinite loops |
| **StateGraph** | Stage 2 | How LangGraph models agents as graphs |
| **Nodes & Edges** | Stage 2 | Graph structure for agent flow |
| **Built-in Tool Node** | Stage 2 | LangGraph's automatic tool execution |
| **Checkpointing** | Stage 3 | Saving state for resume after crash |
| **Thread Memory** | Stage 3 | Remembering previous conversations |

---

## ⏱️ Estimated Time

| Section | Time |
|---------|------|
| Reading this README | 15 min |
| Stage 1 (Raw Agent) | 30 min |
| Stage 2 (LangGraph) | 20 min |
| Stage 3 (Memory) | 15 min |
| Experimenting | 15 min |
| **Total** | **~1.5 hours** |

---

## 📝 Key Takeaways (Read After the Lab)

After completing this lab, you should be able to answer:

1. **What are the 3 components of an agent?** — LLM (reasoning) + Tools (actions) + Loop (iteration)
2. **What does the LLM actually output during tool calling?** — JSON with tool name and arguments, NOT the tool result
3. **Who executes the tool?** — YOUR code, not the LLM
4. **What is the ReAct loop?** — Think → Act → Observe → repeat until done
5. **Why use a framework like LangGraph?** — It handles the loop, state, persistence, and error handling for you
6. **What is a StateGraph?** — A graph where nodes are functions and edges are transitions, with shared state flowing through

---

> **Ready to code?** Open **[lab.ipynb](lab.ipynb)** and let's build your first agent! 🚀
