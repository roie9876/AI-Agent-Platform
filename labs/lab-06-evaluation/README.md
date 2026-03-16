# Lab 06 — Agent Evaluation: Score Your Agent's Quality

## 🎯 Learning Objectives

By the end of this lab, you will:

1. **Understand why evaluation matters** — agents that "feel" good can still hallucinate, miss the point, or leak data
2. **Build an evaluation dataset** — structured test cases with questions, context, and expected answers
3. **Implement LLM-as-Judge scoring** — use GPT-4.1 to score groundedness, relevance, and coherence
4. **Add programmatic checks** — regex-based safety checks (toxicity, PII leaks) that don't need an LLM
5. **Build a full eval pipeline** — run all test cases, score them, and produce a report

---

## 📊 Part 1: Why Evaluate?

You built an agent in Labs 01-05. It answers questions, uses tools, has guardrails. **But how good is it?**

Without evaluation, you're guessing:
- "It seems to work" → but does it hallucinate on edge cases?
- "The answers look right" → but are they grounded in the actual documents?
- "It handles jailbreaks" → but what about subtle prompt injections?

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│   WITHOUT EVAL:                                                 │
│   "I tested 3 questions and they looked fine" 🤷                │
│                                                                  │
│   WITH EVAL:                                                    │
│   "I ran 50 test cases:                                         │
│    Groundedness: 4.2/5.0                                        │
│    Relevance:    4.5/5.0                                        │
│    Safety:       100% pass (0 toxicity, 0 PII leaks)           │
│    Latency:      avg 1.8s, p95 3.2s                            │
│    3 failures — all on financial questions (need better RAG)"  │
│                                                                  │
│   Now you KNOW what to fix. That's the difference.             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🧪 Part 2: The Three Evaluation Methods

| Method | How It Works | Speed | Cost | Accuracy |
|--------|-------------|-------|------|----------|
| **Human Evaluation** | People rate answers 1-5 | Slow | Expensive | Best |
| **LLM-as-Judge** | GPT-4.1 scores the answer | Fast | Medium | Very good |
| **Programmatic** | Regex, string matching, rules | Instant | Free | Good for safety |

We'll use **LLM-as-Judge** (scalable, good accuracy) + **Programmatic** (free, instant safety checks).

---

## 🏗️ Part 3: What We'll Build in the Notebook

### Stage 1: Build an Evaluation Dataset

Create structured test cases:
- Question + Context + Expected answer
- Categories: factual, policy, safety, edge cases
- Gold answers for comparison

### Stage 2: Run the Agent on All Test Cases

Execute the agent on every test case and capture:
- The agent's response
- Which tools it used
- Latency per call

### Stage 3: LLM-as-Judge Scoring

Use GPT-4.1 as a judge to score each response on:
- **Groundedness** (1-5): Is the answer based on the provided context?
- **Relevance** (1-5): Does the answer address the question?
- **Coherence** (1-5): Is the answer clear and well-structured?

### Stage 4: Programmatic Safety Checks

Automated checks that don't need an LLM:
- **Toxicity keywords**: scan for harmful language
- **PII leaks**: detect credit cards, SSNs, emails in responses
- **Refusal detection**: verify the agent refuses unsafe requests

### Stage 5: Evaluation Report

Aggregate all scores into a final report:
- Per-category scores (factual, safety, policy)
- Pass/fail summary
- Failures to investigate

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│   STAGE 1       STAGE 2       STAGE 3      STAGE 4    STAGE 5   │
│   Dataset       Run Agent     LLM Judge    Safety     Report    │
│                                                                  │
│   50 test       Capture       Score 1-5    Regex      Aggregate  │
│   cases with    answers +     groundedness checks     scores,    │
│   expected      latency +     relevance    for PII,   find       │
│   outputs       tools used    coherence    toxicity   failures   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## ☁️ Azure Resources Used

| Resource | What For | Deployed In |
|----------|---------|-------------|
| **Azure OpenAI** (GPT-4.1) | Agent reasoning + LLM-as-Judge scoring | Lab 00 |

This lab only needs Azure OpenAI — no additional services required!

---

## 📋 Concepts Covered

| Concept | Where | What You Learn |
|---------|-------|----------------|
| **Evaluation dataset** | Stage 1 | Structured test cases with expected outputs |
| **Gold answers** | Stage 1 | Reference answers for comparison |
| **Agent execution pipeline** | Stage 2 | Running agents on test cases, capturing metadata |
| **LLM-as-Judge** | Stage 3 | Using an LLM to score another LLM's output |
| **Groundedness** | Stage 3 | Is the answer based on provided facts? |
| **Relevance** | Stage 3 | Does the answer address the question? |
| **Coherence** | Stage 3 | Is the answer clear and well-structured? |
| **Programmatic checks** | Stage 4 | Regex-based safety validation |
| **Eval report** | Stage 5 | Aggregating scores, identifying failures |

---

## ⏱️ Estimated Time

| Section | Time |
|---------|------|
| Reading this README | 10 min |
| Stage 1 (Evaluation dataset) | 10 min |
| Stage 2 (Run agent) | 15 min |
| Stage 3 (LLM-as-Judge) | 20 min |
| Stage 4 (Safety checks) | 15 min |
| Stage 5 (Report) | 10 min |
| **Total** | **~1.5 hours** |

---

## 📝 Key Takeaways (Read After the Lab)

After completing this lab, you should be able to answer:

1. **Why not just test manually?** — Manual testing doesn't scale and misses edge cases.
2. **What is LLM-as-Judge?** — Using a strong LLM to score another LLM's output on a 1-5 scale.
3. **What is groundedness?** — Whether the answer is based on the provided context (not hallucinated).
4. **Why programmatic checks too?** — They're free, instant, and catch things LLMs miss (PII patterns, exact keyword matches).
5. **What makes a good eval dataset?** — Diverse categories, clear expected answers, edge cases, and adversarial examples.

---

> **Ready to evaluate?** Open **[lab.ipynb](lab.ipynb)** and let's score your agent! 📊
