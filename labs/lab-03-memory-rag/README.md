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

## � Part 3: Industry Landscape — What the Real World Uses

Before we build, let's understand what tools and platforms the industry uses for RAG and memory in production. This helps you see the big picture and make informed choices.

### RAG Solutions in Production

| Solution | Type | What It Does | Best For |
|----------|------|-------------|----------|
| **Azure AI Search** | Vector + Keyword DB | Hybrid search (vector + BM25 + semantic reranking) | Enterprise, Azure-native |
| **Pinecone** | Managed Vector DB | Serverless vector search, zero-ops | Startups, fast prototyping |
| **Qdrant** | Open-source Vector DB | Self-hosted, Rust-based, fast | Teams wanting full control |
| **Weaviate** | Open-source Vector DB | GraphQL API, hybrid search, multi-modal | Complex RAG pipelines |
| **ChromaDB** | Open-source Vector DB | Lightweight, Python-native, great for dev | Prototyping, small datasets |
| **Milvus** | Open-source Vector DB | Distributed, handles billions of vectors | Large-scale production |
| **LlamaIndex** | RAG Framework | Data connectors + indexing + query engines | RAG-heavy applications |
| **LangChain Retrievers** | RAG Framework | Pluggable retrievers for any vector DB | LangGraph-based agents |

### Memory Solutions in Production

| Solution | Type | How It Works | Best For |
|----------|------|-------------|----------|
| **LangGraph MemorySaver** | Framework built-in | Full state checkpoint in RAM | Development, prototyping |
| **LangGraph SqliteSaver** | Framework built-in | Checkpoint to SQLite file | Single-server production |
| **LangGraph PostgresSaver** | Framework built-in | Checkpoint to PostgreSQL | Multi-server production |
| **Azure Cosmos DB** | Cloud database | Serverless, global replication, partition by thread | Azure-native, enterprise |
| **Mem0** | Smart memory platform | Extracts facts from conversations, not raw messages | User-level memory across sessions |
| **Zep** | Memory platform | Conversation summarization + user facts + temporal awareness | Long-running agent sessions |
| **LangMem** | LangChain memory | Long-term memory with LangGraph Store API | LangGraph-native apps |
| **Redis** | In-memory cache | Fast read/write, TTL support | Recent context caching |
| **MongoDB** | Document database | Flexible schema, conversation storage | General-purpose persistence |

### The 4 Types of Agent Memory

The industry recognizes four distinct types of memory:

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│  1. CONVERSATION MEMORY (Short-term)                            │
│     What: Full message history of current conversation           │
│     Tools: LangGraph Checkpointer, Redis                        │
│     We build: MemorySaver (Lab 01) → Cosmos DB (this lab)       │
│                                                                  │
│  2. USER MEMORY (Long-term, per user)                           │
│     What: Facts about the user across ALL conversations          │
│     Tools: Mem0, Zep, LangMem                                   │
│     Example: "Roi prefers Hebrew", "works in analytics team"    │
│                                                                  │
│  3. SEMANTIC MEMORY (Knowledge)                                 │
│     What: Documents, knowledge base, organizational info         │
│     Tools: Azure AI Search, Pinecone, Qdrant, LlamaIndex        │
│     We build: RAG pipeline with Azure AI Search (this lab)       │
│                                                                  │
│  4. EPISODIC MEMORY (Past experiences)                          │
│     What: Summaries of previous tasks and outcomes               │
│     Tools: Zep, custom vector DB solutions                       │
│     Example: "Last time, user needed the enterprise policy"     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### What We Build in This Lab (Two Approaches)

In this lab, we show **two approaches side by side**:

| Aspect | Open Source (LangGraph) | Microsoft Azure |
|--------|----------------------|-----------------|
| **RAG search** | LangChain retriever with any vector DB | Azure AI Search (hybrid + semantic) |
| **Embeddings** | Any embedding model | Azure OpenAI text-embedding-3-large |
| **Conversation memory** | LangGraph `MemorySaver` / `SqliteSaver` | Azure Cosmos DB |
| **User memory** | Mem0 (optional) | Cosmos DB with custom schema |
| **Agent framework** | LangGraph `create_react_agent` | Azure AI Foundry Agents Service |

> 💡 **Key insight:** The concepts are the same — only the implementation differs.
> Understanding WHAT (RAG, memory types, chunking) matters more than WHERE (Azure vs self-hosted).

---

## 🏗️ Part 4: What We'll Build

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
