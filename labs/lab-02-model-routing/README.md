# Lab 02 — Smart Model Routing: Cut Costs by 80%

## 🎯 Learning Objectives

By the end of this lab, you will:

1. **Understand the cost problem** — why sending every request to GPT-4.1 is wasteful
2. **Build a complexity classifier** — an LLM that decides if a task is simple or complex
3. **Route requests intelligently** — cheap model for simple tasks, expensive model for complex ones
4. **Measure the savings** — see the actual cost difference with real numbers
5. **Build a routing agent with LangGraph** — production-ready model routing

---

## 💰 Part 1: The Cost Problem

### The Brutal Math

Every LLM call costs money. But not all calls need the most expensive model:

```
┌─────────────────────────────────────────────────────────────────┐
│                    THE COST PROBLEM                              │
│                                                                  │
│   Your agent handles 10,000 requests/day.                       │
│                                                                  │
│   Option A: Send ALL to GPT-4.1                                 │
│     10,000 × ~$0.03 = $300/day = $9,000/month 😱                │
│                                                                  │
│   Option B: Route intelligently                                 │
│     7,000 simple → GPT-4o-mini × $0.002 = $14/day              │
│     3,000 complex → GPT-4.1    × $0.03  = $90/day              │
│     Total: $104/day = $3,120/month 🎉                           │
│                                                                  │
│   SAVINGS: ~65% ($5,880/month!)                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Which Tasks are "Simple" vs "Complex"?

| Simple (use cheap model) | Complex (use expensive model) |
|--------------------------|-------------------------------|
| "Summarize this email" | "Analyze these 3 reports and find contradictions" |
| "Translate to Spanish" | "Write a legal contract section" |
| "Extract the date from this text" | "Debug this code and explain the race condition" |
| "Format this as a table" | "Create a multi-step plan for product launch" |
| "What's the capital of France?" | "Compare these 5 investment options with risks" |
| "Classify this support ticket" | "Generate a detailed architecture proposal" |

The key insight: **~70% of real-world requests are simple.** If you route them to a model that costs 15x less, you save a fortune.

---

## 🔀 Part 2: How Model Routing Works

### The Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    MODEL ROUTER                                  │
│                                                                  │
│   📨 Request                                                    │
│      ↓                                                          │
│   🔍 Classifier (lightweight LLM call)                          │
│      "Is this simple or complex?"                               │
│      ↓                                                          │
│   ┌─────────────┐     ┌──────────────────┐                     │
│   │ SIMPLE       │     │ COMPLEX           │                    │
│   │ GPT-4o-mini  │     │ GPT-4.1           │                    │
│   │ ~$0.002/req  │     │ ~$0.03/req        │                    │
│   │ Fast (0.5s)  │     │ Slower (2s)       │                    │
│   │ Good enough! │     │ Best quality      │                    │
│   └─────────────┘     └──────────────────┘                     │
│      ↓                       ↓                                  │
│   💬 Response            💬 Response                            │
└─────────────────────────────────────────────────────────────────┘
```

### Three Routing Strategies

| Strategy | How It Works | Pros | Cons |
|----------|-------------|------|------|
| **LLM-based classifier** | Ask a cheap LLM to rate complexity | Flexible, handles nuance | Extra LLM call cost |
| **Keyword/rule-based** | Match patterns like "analyze", "compare" | Zero cost, fast | Brittle, misses nuance |
| **Embedding similarity** | Compare to known simple/complex examples | Good accuracy | Requires training data |

In this lab, we'll build **Strategy 1** (LLM-based) because it's the most flexible and educational. The classifier call itself uses the cheap model, so it adds ~$0.0005 per request — negligible.

---

## 🧪 Part 3: What We'll Build in the Notebook

### Stage 1: Naive Approach (Everything to GPT-4.1)

Send all requests to the expensive model. Measure the quality and cost.

### Stage 2: Build a Complexity Classifier

Create a prompt that classifies requests as `simple` or `complex`. Test it on various inputs.

### Stage 3: Build a Smart Router

Route `simple` → GPT-4o-mini, `complex` → GPT-4.1. Compare quality and cost to Stage 1.

### Stage 4: Build it with LangGraph

Create a proper routing graph with conditional edges.

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│   STAGE 1          STAGE 2            STAGE 3         STAGE 4   │
│   Baseline         Classifier         Router          LangGraph │
│                                                                  │
│   Send ALL         Classify           Route to        Build as  │
│   to GPT-4.1       requests           right model     a graph   │
│   (expensive)      by complexity      (save $$$)      (prod)    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 What You'll See

By the end, you'll have a side-by-side comparison:

```
┌──────────────────────────────────────────────────────────┐
│                   RESULTS                                 │
│                                                           │
│   Request: "Translate 'hello' to French"                 │
│   ├── GPT-4.1:    "Bonjour" ✅  Cost: $0.03   Time: 1.8s│
│   └── GPT-4o-mini: "Bonjour" ✅  Cost: $0.002  Time: 0.4s│
│   → Same quality, 15x cheaper, 4x faster!               │
│                                                           │
│   Request: "Analyze these financial reports..."          │
│   ├── GPT-4.1:    [detailed analysis] ✅  $0.05          │
│   └── GPT-4o-mini: [shallow analysis] ⚠️  $0.003        │
│   → Quality matters here, use the big model!             │
└──────────────────────────────────────────────────────────┘
```

---

## 📋 Concepts Covered

| Concept | Where | What You Learn |
|---------|-------|----------------|
| **Cost per token** | Stage 1 | How LLM pricing works (input tokens vs output tokens) |
| **Model comparison** | Stage 1 | When cheap models match expensive ones |
| **Complexity classification** | Stage 2 | Using an LLM to classify tasks |
| **Prompt engineering** | Stage 2 | Writing a classification prompt |
| **Conditional routing** | Stage 3 | Sending requests to different models |
| **Cost tracking** | Stage 3 | Measuring actual savings |
| **LangGraph conditional edges** | Stage 4 | Building routing logic as a graph |

---

## ⏱️ Estimated Time

| Section | Time |
|---------|------|
| Reading this README | 10 min |
| Stage 1 (Baseline) | 15 min |
| Stage 2 (Classifier) | 20 min |
| Stage 3 (Router) | 20 min |
| Stage 4 (LangGraph) | 15 min |
| **Total** | **~1.5 hours** |

---

## 📝 Key Takeaways (Read After the Lab)

After completing this lab, you should be able to answer:

1. **Why not always use the best model?** — Cost. 70% of requests don't need it.
2. **How does a complexity classifier work?** — A cheap LLM call that outputs "simple" or "complex"
3. **What's the actual cost savings?** — Typically 50-80% depending on your traffic mix
4. **When does routing fail?** — When the classifier makes mistakes (routes complex to cheap model)
5. **How to handle classifier errors?** — Add a fallback: if cheap model's confidence is low, escalate to expensive

---

> **Ready to save money?** Open **[lab.ipynb](lab.ipynb)** and let's build a smart router! 🚀
