# Lab 07 — Agent Framework Deep Dive

## 🎯 Learning Objectives

By the end of this lab, you will:

1. **Build the same agent in three different frameworks** — and understand the trade-offs
2. **Use LangGraph** — the most popular graph-based agent runtime
3. **Use Microsoft Agent Framework** — Microsoft's unified enterprise-grade SDK
4. **Use Deep Agents** — LangChain's autonomous agent harness with planning and context management
5. **Connect a tool via MCP** — the universal tool standard that works across frameworks
6. **Compare all three** — DX, token efficiency, strengths, and when to choose each

---

## 🧠 Part 1: Why Multiple Frameworks?

You built a raw agent in Lab 01 with just the OpenAI SDK. It worked! So why do frameworks exist?

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│   RAW OPENAI SDK (Lab 01):                                      │
│   ✅ Full control                                                │
│   ❌ You build EVERYTHING: tool loop, memory, state, retries    │
│   ❌ 80+ lines for a simple agent                               │
│   ❌ No checkpointing, no persistence, no streaming             │
│                                                                  │
│   FRAMEWORKS (This Lab):                                        │
│   ✅ ReAct loop is built-in                                     │
│   ✅ Memory, state, checkpointing — ready to use               │
│   ✅ 10-15 lines for the same agent                             │
│   ✅ Production features: streaming, HITL, observability        │
│                                                                  │
│   The question isn't IF you use a framework.                    │
│   The question is WHICH ONE.                                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🧩 Part 2: The Three Frameworks

| Framework | Creator | Core Idea | Best For |
|-----------|---------|-----------|----------|
| **LangGraph** | LangChain | Agents as state graphs (nodes + edges) | Complex multi-step workflows with checkpointing |
| **Microsoft Agent Framework** | Microsoft | Unified agent SDK (C# + Python) | Enterprise, Azure-native, multi-agent orchestration |
| **Deep Agents** | LangChain | Agent harness with built-in planning + filesystem | Autonomous agents handling large context and files |

### How They Relate

```
                    ┌──────────────────────┐
                    │    LLM Providers     │
                    │  (Azure OpenAI, etc) │
                    └──────────┬───────────┘
                               │
           ┌───────────────────┼───────────────────┐
           │                   │                   │
    ┌──────┴──────┐    ┌──────┴──────┐    ┌──────┴──────┐
    │  LangGraph  │    │  Microsoft  │    │    Deep     │
    │  (Runtime)  │    │   Agent FW  │    │   Agents    │
    │             │    │  (Unified)  │    │  (Harness)  │
    │ Nodes+Edges │    │  SK+AutoGen │    │ Built on LG │
    │ State Graph │    │   Plugins   │    │ Planning    │
    │ Checkpoint  │    │ Multi-Agent │    │ Filesystem  │
    └─────────────┘    └─────────────┘    └─────────────┘
```

---

## 🔌 Part 3: MCP — The Universal Tool Standard

**MCP (Model Context Protocol)** is an open standard that lets you build a tool **once** and connect it to **any** framework or model. Think of it like USB for AI tools.

| Without MCP | With MCP |
|-------------|----------|
| Build a Slack tool for LangGraph | Build a Slack MCP server **once** |
| Rebuild it for Semantic Kernel | Connect it to LangGraph, SK, MAF, Claude |
| Rebuild it again for Claude | One tool → all frameworks |

---

## 📋 Lab Structure

| Stage | Framework | What You Build | Lines of Code |
|-------|-----------|----------------|---------------|
| **Stage 1** | LangGraph | ReAct agent with tools + checkpointing | ~20 lines |
| **Stage 2** | Microsoft Agent Framework | Same agent with plugins + multi-agent | ~25 lines |
| **Stage 3** | Deep Agents | Same agent with planning + filesystem | ~15 lines |
| **Stage 4** | MCP | Connect a tool server to any framework | ~30 lines |
| **Stage 5** | All three | Side-by-side comparison | Analysis |

---

## ⚙️ Prerequisites

- **Completed Lab 01** (understand ReAct pattern)
- **Azure OpenAI** deployed (GPT-4.1)
- **Read** [Chapter 16: Agent Frameworks](../../education/en/16-agent-frameworks.md)

---

> **[← Back to Lab 06](../lab-06-evaluation/README.md)** | **[→ Lab 08: Observability](../lab-08-observability/README.md)**
