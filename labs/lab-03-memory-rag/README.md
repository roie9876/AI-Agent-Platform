# Lab 03 — Memory & RAG: Give Your Agent Knowledge and Memory

## 🎯 Learning Objectives

By the end of this lab, you will:

1. **Understand why agents need RAG** — see the LLM fail on YOUR data, then fix it
2. **Build a RAG pipeline** — embed documents, index in Azure AI Search, retrieve relevant chunks
3. **Create a RAG-powered agent** — a LangGraph agent that searches documents before answering
4. **Add persistent memory with Cosmos DB** — conversations survive restarts (not just RAM)
5. **Combine RAG + Memory** — an agent that knows your documents AND remembers previous conversations

---

## 🧠 Part 1: Why Agents Need External Knowledge

### The Problem

LLMs are trained on public internet data. They've never seen:
- Your company's internal policies
- Your product documentation
- Your customer data
- Anything that happened after their training date

When you ask about YOUR data, the LLM **guesses** — and often gets it wrong (hallucination).

```
┌─────────────────────────────────────────────────────────────────┐
│  YOU: "What is our refund policy for enterprise customers?"      │
│                                                                  │
│  ❌ WITHOUT RAG:                                                 │
│     "Typically, enterprise refunds are processed within 30       │
│      business days..." (GUESSING from general knowledge!)        │
│                                                                  │
│  ✅ WITH RAG:                                                    │
│     "According to the Enterprise Service Agreement (Section 7),  │
│      enterprise customers are eligible for a full refund within  │
│      14 days of purchase, prorated after 14 days."               │
│     (FROM YOUR ACTUAL DOCUMENTS!)                                │
└─────────────────────────────────────────────────────────────────┘
```

### The Solution: RAG (Retrieval-Augmented Generation)

Instead of hoping the LLM knows the answer:
1. **Store** your documents in a searchable database (Azure AI Search)
2. **Search** for relevant parts when the user asks a question
3. **Give** those parts to the LLM as context
4. The LLM **generates** an answer grounded in YOUR data

> 📚 **Want to go deep on RAG?** See the [RAG Workshop](https://github.com/roie9876/RAG-WorkShop) for
> detailed modules on document extraction, chunking strategies, and search optimization.
> This lab focuses on **how an agent uses RAG**, not on building the RAG pipeline from scratch.

---

## 💾 Part 2: Why Agents Need Persistent Memory

In Lab 01, we added memory with `MemorySaver()` — but that stores state **in RAM**.
If the Python process restarts, all conversations are lost.

For production agents, you need **durable storage**:

```
┌─────────────────────────────────────────────────────────────┐
│                                                              │
│   Lab 01: MemorySaver()           Lab 03: Cosmos DB          │
│   ━━━━━━━━━━━━━━━━━━━             ━━━━━━━━━━━━━━━━━          │
│   Stores in RAM                   Stores in database         │
│   Lost on restart                 Survives restarts          │
│   Single process only             Multi-server OK            │
│   Good for labs                   Good for production        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🏗️ Part 3: What We'll Build

### Stage 1: See the Agent Fail (No RAG)

Ask the agent about company documents → it hallucinates → motivation for RAG.

### Stage 2: Build a RAG Pipeline

Upload documents → chunk → embed → index in Azure AI Search.

### Stage 3: RAG Agent with LangGraph

Build an agent that has a `search_documents` tool — the agent DECIDES when to search.

### Stage 4: Persistent Memory with Cosmos DB

Replace `MemorySaver()` with a Cosmos DB-backed checkpointer.

### Stage 5: The Complete Agent

Combine RAG + Memory → agent that knows your docs AND remembers your conversations.

```
┌─────────────────────────────────────────────────────────────┐
│                                                              │
│   STAGE 1        STAGE 2       STAGE 3      STAGE 4+5       │
│   No RAG         Build RAG     RAG Agent    + Memory         │
│                                                              │
│   "I don't       Upload →      Agent uses   Agent knows     │
│    know your     Embed →       search_docs  your docs AND   │
│    data"         Index →       tool to      remembers you   │
│    (hallu-       Search        find answers                 │
│    cination)                   in YOUR data                 │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## ☁️ Azure Resources Used

| Resource | What For | Deployed In |
|----------|---------|-------------|
| **Azure OpenAI** (GPT-4.1) | Agent reasoning | Lab 00 |
| **Azure OpenAI** (text-embedding-3-large) | Convert text to vectors | Lab 00 |
| **Azure AI Search** | Store and search document vectors | Lab 00 |
| **Azure Cosmos DB** | Persistent conversation memory | Lab 00 |
| **Azure Storage** | Store sample documents | Lab 00 |

All resources were deployed in Lab 00 — no new setup needed!

---

## 📋 Concepts Covered

| Concept | Where | What You Learn |
|---------|-------|----------------|
| **Hallucination** | Stage 1 | Why LLMs make things up without your data |
| **Embeddings** | Stage 2 | Converting text to numbers for similarity search |
| **Chunking** | Stage 2 | Splitting documents into searchable pieces |
| **Vector search** | Stage 2 | Finding relevant content by meaning, not keywords |
| **Hybrid search** | Stage 2 | Combining vector + keyword search for better results |
| **RAG as a tool** | Stage 3 | Agent decides WHEN to search (not hardcoded) |
| **Grounding** | Stage 3 | Forcing the LLM to cite sources |
| **Cosmos DB checkpointer** | Stage 4 | Production-grade persistent memory |
| **Thread isolation** | Stage 4 | Multi-tenant conversations in one database |

---

## ⏱️ Estimated Time

| Section | Time |
|---------|------|
| Reading this README | 10 min |
| Stage 1 (See it fail) | 10 min |
| Stage 2 (Build RAG pipeline) | 25 min |
| Stage 3 (RAG agent) | 20 min |
| Stage 4 (Cosmos DB memory) | 20 min |
| Stage 5 (Combined agent) | 15 min |
| **Total** | **~1.5-2 hours** |

---

## 📝 Key Takeaways (Read After the Lab)

1. **RAG isn't magic** — it's just "search for relevant docs, add them to the prompt"
2. **The agent chooses when to search** — RAG is a tool, not a hardcoded step
3. **Chunk size matters** — too big = irrelevant noise, too small = missing context
4. **Hybrid search beats vector-only** — combine semantic and keyword matching
5. **MemorySaver is for labs, Cosmos DB is for production** — same API, different backend
6. **Thread ID = conversation isolation** — critical for multi-tenant production systems

---

> **Ready?** Open **[lab.ipynb](lab.ipynb)** and let's give your agent real knowledge! 🚀
