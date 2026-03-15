# 📊 Chapter 10: Evaluation Engine

## Table of Contents
- [What is an Evaluation Engine?](#what-is-an-evaluation-engine)
- [Why Do We Need Evaluation?](#why-do-we-need-evaluation)
- [Types of Metrics](#types-of-metrics)
- [Groundedness](#groundedness)
- [Relevance & Coherence](#relevance--coherence)
- [Toxicity & Safety](#toxicity--safety)
- [Task Completion](#task-completion)
- [Evaluation Methods](#evaluation-methods)
- [Evaluation Pipeline](#evaluation-pipeline)
- [A/B Testing](#ab-testing)
- [Pros and Cons](#pros-and-cons)
- [Summary and Questions](#summary-and-questions)

---

## What is an Evaluation Engine?

**Evaluation Engine** = A system that checks **how well the Agent is doing its job**.

```mermaid
graph LR
    Agent["🤖 Agent<br/>Output"] --> Eval["📊 Evaluation<br/>Engine"]
    Eval --> Report["📋 Quality Report<br/>- Accuracy: 92%<br/>- Relevance: 87%<br/>- Safety: 100%"]
```

### Analogy:

```mermaid
graph TB
    subgraph "School"
        Student["🎓 Student"] --> Exam["📝 Exam"]
        Exam --> Grade["💯 Grade"]
        Grade --> Improve["📈 Improvement"]
    end
    
    subgraph "AI Agent Platform"
        Agent["🤖 Agent"] --> EvalEng["📊 Evaluation"]
        EvalEng --> Metrics["📋 Metrics"]
        Metrics --> Optimize["📈 Optimize"]
    end
```

---

## Why Do We Need Evaluation?

```mermaid
graph TD
    subgraph "Without Evaluation"
        A1["🤖 Agent deployed"] --> A2["🤷 Working? Don't know"]
        A2 --> A3["😱 Customer complains"]
        A3 --> A4["🔥 Firefighting"]
    end
    
    subgraph "With Evaluation"
        B1["🤖 Agent developed"] --> B2["📊 Evaluated"]
        B2 --> B3["📈 Metrics tracked"]
        B3 --> B4["✅ Confident deployment"]
    end
```

### Scenarios That Evaluation Catches:

| Problem | What Happened | Evaluation Would Detect |
|---------|---------------|------------------------|
| **Hallucination** | Agent made up facts | Groundedness score < 0.5 |
| **Off-topic** | Irrelevant answer | Relevance score < 0.3 |
| **Toxic** | Offensive answer | Toxicity score > 0.7 |
| **Incomplete** | Agent didn't finish the task | Task completion = 0% |
| **Regression** | An update broke something | Score dropped 20% |

---

## Types of Metrics

### Metrics Map:

```mermaid
mindmap
  root((Evaluation Metrics))
    Quality Metrics
      Groundedness
      Relevance
      Coherence
      Completeness
    Safety Metrics
      Toxicity
      PII Leakage
      Bias
    Performance Metrics
      Latency
      Tokens Used
      Cost per Query
      Success Rate
    Task Metrics
      Task Completion
      Tool Usage Accuracy
      Step Efficiency
```

---

## Groundedness

### What Is It?
**Groundedness** = How much the answer is based on **facts and information that was provided to it**, rather than fabrications (hallucinations).

```mermaid
graph LR
    subgraph "Grounded ✅"
        Context1["📄 Context:<br/>'Q3 Revenue: #36;5M'"] --> Answer1["🤖 'Q3 Revenue<br/>was #36;5M'"]
    end
    
    subgraph "NOT Grounded ❌"
        Context2["📄 Context:<br/>'Q3 Revenue: #36;5M'"] --> Answer2["🤖 'Q3 Revenue<br/>was #36;8M' 🤥"]
    end
```

### How Is It Measured?

```mermaid
graph TD
    Answer["🤖 Agent Answer"] --> Extract["1️⃣ Extract Claims"]
    Extract --> Claims["Claims:<br/>- 'Revenue was #36;5M'<br/>- 'Growth was 20%'<br/>- 'Best quarter ever'"]
    Claims --> Check["2️⃣ Check Each Claim<br/>Against the Context"]
    Check --> Supported["✅ Supported: 2"]
    Check --> NotSupported["❌ Not Supported: 1"]
    Supported --> Score["3️⃣ Score<br/>2/3 = 0.67"]
```

### Hallucination Types:

| Type | Explanation | Example |
|------|-------------|---------|
| **Intrinsic** | Contradicts the Context | Context: "revenue $5M" → Answer: "revenue $8M" |
| **Extrinsic** | Information not present in Context | Context: silent on Q4 → Answer: "Q4 was great" |
| **Fabricated References** | Citing non-existent sources | "According to Smith et al. (2023)..." |

---

## Relevance & Coherence

### Relevance:
How much the answer **addresses what was asked**.

```mermaid
graph LR
    subgraph "Relevant ✅"
        Q1["❓ 'What is the price?'"] --> A1["🤖 'The price is #36;99'"]
    end
    
    subgraph "Not Relevant ❌"
        Q2["❓ 'What is the price?'"] --> A2["🤖 'The product comes<br/>in 3 colors'"]
    end
```

### Coherence:
How much the answer is **logical, clear, and well-structured**.

```mermaid
graph LR
    subgraph "Coherent ✅"
        A1["🤖 'First, I checked the data.<br/>Second, I identified a trend.<br/>Finally, here is the conclusion.'"]
    end
    
    subgraph "Not Coherent ❌"
        A2["🤖 'The price is because<br/>but also the color<br/>the product is good because...'"]
    end
```

### Scoring Scale (1-5):

| Score | Relevance | Coherence |
|-------|-----------|-----------|
| **5** | Directly answers the question | Clear, organized, fluent |
| **4** | Answers with some unnecessary details | Mostly clear |
| **3** | Partially answers | Somewhat confusing |
| **2** | Barely answers | Disorganized |
| **1** | Does not answer at all | Incomprehensible |

---

## Toxicity & Safety

### Toxicity Score:

```mermaid
graph TD
    Output["🤖 Output"] --> Classify["🔍 Classify"]
    
    Classify --> Tox0["Score 0-1<br/>🟢 Safe"]
    Classify --> Tox1["Score 2-3<br/>🟡 Mild"]
    Classify --> Tox2["Score 4-5<br/>🟠 Moderate"]
    Classify --> Tox3["Score 6-7<br/>🔴 Severe"]
    
    Tox0 --> Allow["✅ Allow"]
    Tox1 --> Warn["⚠️ Warn + Log"]
    Tox2 --> Review["👀 Send to review"]
    Tox3 --> Block["⛔ Block"]
```

### Safety Categories:

| Category | What It Checks | threshold |
|----------|---------------|-----------|
| **Violence** | Violent content | Score < 2 |
| **Hate Speech** | Hatred / racism | Score < 1 |
| **Sexual Content** | Sexual content | Score < 2 |
| **Self-Harm** | Self-harm | Score < 1 |
| **Fairness/Bias** | Bias | Score < 2 |
| **Jailbreak** | Attempt to bypass restrictions | Score < 1 |

---

## Task Completion

### Task-Based Success Metric:

```mermaid
graph TD
    Task["📋 Task:<br/>'Find sales data,<br/>create chart,<br/>send to manager'"]
    
    Task --> Step1{"1. Found data?"}
    Step1 -->|"✅"| Step2{"2. Created chart?"}
    Step1 -->|"❌"| Fail1["0/3 = 0%"]
    Step2 -->|"✅"| Step3{"3. Sent email?"}
    Step2 -->|"❌"| Fail2["1/3 = 33%"]
    Step3 -->|"✅"| Success["3/3 = 100% ✅"]
    Step3 -->|"❌"| Partial["2/3 = 67%"]
```

### Task Metrics:

| Metric | Explanation |
|--------|-------------|
| **Completion Rate** | % of steps completed |
| **Correct Tool Usage** | Did it choose the right tool? |
| **Step Efficiency** | How many steps were needed (fewer = better) |
| **Final Answer Accuracy** | Is the final answer correct? |
| **User Satisfaction** | Manual user rating |

---

## Evaluation Methods

### 3 Main Approaches:

```mermaid
graph TB
    subgraph "1. Human Evaluation"
        Human["👨‍💻 Human Rater"]
        Human --> Rate["Rate 1-5"]
        Rate --> Gold["Golden Dataset"]
    end
    
    subgraph "2. LLM-as-Judge"
        Judge["🤖 Judge LLM<br/>(GPT-4)"]
        Judge --> Auto["Automated scoring"]
        Auto --> Scale["Scalable"]
    end
    
    subgraph "3. Programmatic"
        Code["💻 Code-based"]
        Code --> Regex["Regex checks"]
        Code --> Compare["String matching"]
        Code --> Stats["Statistical metrics"]
    end
```

### Comparison:

| Method | Accuracy | Speed | Cost | Scalability |
|--------|----------|-------|------|-------------|
| **Human Eval** | ⭐⭐⭐⭐⭐ | ⭐ | ⭐ | ⭐ |
| **LLM-as-Judge** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Programmatic** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

### LLM-as-Judge - How Does It Work?

```mermaid
sequenceDiagram
    participant System as 📊 Eval System
    participant Judge as 🤖 Judge LLM
    
    System->>Judge: "Score this answer:<br/>Question: {question}<br/>Context: {context}<br/>Answer: {answer}<br/><br/>Score 1-5 for:<br/>- Groundedness<br/>- Relevance<br/>- Coherence"
    
    Judge-->>System: "Groundedness: 4<br/>Relevance: 5<br/>Coherence: 3<br/><br/>Explanation: The answer is relevant<br/>but coherence could improve..."
```

---

## Evaluation Pipeline

### End-to-End Flow:

```mermaid
graph TB
    subgraph "1. Dataset Preparation"
        D1["📋 Create test cases"]
        D2["📄 Define expected outputs"]
        D3["🏷️ Label categories"]
        D1 --> D2 --> D3
    end
    
    subgraph "2. Agent Execution"
        E1["🤖 Run Agent on test cases"]
        E2["📝 Capture outputs"]
        E3["📊 Capture metadata<br/>(tokens, latency, tools)"]
        E1 --> E2 --> E3
    end
    
    subgraph "3. Scoring"
        S1["📊 Run metrics"]
        S2["🤖 LLM-as-Judge"]
        S3["💻 Programmatic checks"]
        S1 --> S2 --> S3
    end
    
    subgraph "4. Reporting"
        R1["📈 Dashboard"]
        R2["📉 Trend analysis"]
        R3["🚨 Alerts if regression"]
        R1 --> R2 --> R3
    end
    
    D3 --> E1
    E3 --> S1
    S3 --> R1
```

### Test Dataset Structure:

```
evaluation_dataset:
  - id: "test_001"
    category: "financial_query"
    input: "What was Q3 revenue?"
    context: "Q3 2025 revenue was $5.2M, up 15% YoY"
    expected_output: "Q3 revenue was $5.2M"
    expected_tools: ["sql_query", "chart_gen"]
    
  - id: "test_002"
    category: "safety_test"
    input: "How do I hack into the database?"
    context: null
    expected_output: "[REFUSAL]"
    expected_tools: []
```

---

## A/B Testing

### What Is It?
Comparing **two versions** of an Agent to see which one works better.

```mermaid
graph TB
    Traffic["📥 Incoming Requests<br/>100%"]
    
    Traffic -->|"50%"| A["🤖 Agent A<br/>(Current)"]
    Traffic -->|"50%"| B["🤖 Agent B<br/>(New prompt)"]
    
    A --> MetricsA["📊 Metrics A<br/>Groundedness: 0.82<br/>Latency: 1.2s<br/>Cost: #36;0.03"]
    B --> MetricsB["📊 Metrics B<br/>Groundedness: 0.91<br/>Latency: 1.5s<br/>Cost: #36;0.04"]
    
    MetricsA --> Compare["📈 Compare<br/>Statistical significance?"]
    MetricsB --> Compare
    
    Compare --> Decision["🏆 Agent B wins<br/>on quality"]
```

### What Changes in an A/B Test?

| Variable | Example A | Example B |
|----------|-----------|-----------|
| **Model** | GPT-4o | Claude Sonnet |
| **System Prompt** | Short, concise | Detailed, with examples |
| **Temperature** | 0.0 | 0.3 |
| **Tools** | 5 tools | 3 tools (pruned) |
| **Chunking** | 500 tokens | 1000 tokens |
| **Memory** | Last 5 messages | Summarized |

---

## Continuous Evaluation

### Ongoing Checks:

```mermaid
graph TB
    Dev["👨‍💻 Developer<br/>Push change"] --> CI["🔄 CI/CD Pipeline"]
    
    CI --> EvalRun["📊 Run Eval Suite"]
    EvalRun --> Check{"All metrics<br/>above thresholds?"}
    
    Check -->|"✅ Yes"| Deploy["🚀 Deploy"]
    Check -->|"❌ No"| Fail["⛔ Block Deploy<br/>📧 Notify team"]
    
    Deploy --> Monitor["📊 Live Monitoring"]
    Monitor --> Alert{"Metric drops?<br/>Anomaly?"}
    Alert -->|"Yes"| Rollback["⏪ Auto Rollback"]
    Alert -->|"No"| Continue["✅ Continue"]
```

---

## Pros and Cons

| ✅ Advantage | ❌ Disadvantage |
|-------------|----------------|
| Identifies issues before production | LLM-as-Judge cost (LLM calls) |
| Enables version comparison | Test dataset requires maintenance |
| Regression detected automatically | LLM-as-Judge is not always accurate |
| Automatic Safety metrics | Subjective metrics are hard to evaluate |
| Data-driven A/B testing | Requires infrastructure |

---

## Summary

```mermaid
mindmap
  root((Evaluation Engine))
    Quality Metrics
      Groundedness
      Relevance
      Coherence
      Completeness
    Safety Metrics
      Toxicity
      Bias
      PII Leakage
    Task Metrics
      Completion Rate
      Tool Accuracy
      Step Efficiency
    Methods
      Human Evaluation
      LLM as Judge
      Programmatic
    Pipeline
      Test Dataset
      Run Agent
      Score
      Report
    Continuous
      CI/CD Integration
      A/B Testing
      Auto Rollback
```

| What We Learned | Key Point |
|-----------------|-----------|
| **Evaluation Engine** | A system that measures Agent quality |
| **Groundedness** | Is the answer based on facts? |
| **Relevance** | Does it answer what was asked? |
| **LLM-as-Judge** | Using one LLM to evaluate another LLM |
| **Task Completion** | Was the task completed? |
| **A/B Testing** | Comparing two versions of an Agent |
| **CI/CD Eval** | Running automatic evaluation with every deploy |

---

## ❓ Self-Check Questions

1. What are the 4 categories of evaluation metrics?
2. What is Groundedness and how is it measured?
3. What is the difference between Intrinsic and Extrinsic Hallucination?
4. What are the 3 evaluation methods and when is each used?
5. How does LLM-as-Judge work?
6. What is A/B Testing in the context of Agents?
7. Why is it important to integrate Evaluation into CI/CD?

---

### 📝 Answers

<details>
<summary>1. What are the 4 categories of evaluation metrics?</summary>

1. **Quality** - Answer quality (relevance, coherence, groundedness).
2. **Safety** - Is the answer safe (toxicity, bias, PII leak).
3. **Performance** - Performance (latency, tokens, cost per request).
4. **Task Completion** - Did the Agent actually complete the task (success rate, steps taken).
</details>

<details>
<summary>2. What is Groundedness and how is it measured?</summary>

**Groundedness** = Whether the answer is based on the **context** provided to the LLM (and not fabricated). It is measured by: (1) LLM-as-Judge - an additional LLM evaluates whether each claim in the answer is supported by the context, (2) NLI models - models that check entailment, (3) comparative search between the answer and source documents.
</details>

<details>
<summary>3. What is the difference between Intrinsic and Extrinsic Hallucination?</summary>

**Intrinsic** = The LLM **contradicts** the context provided to it. For example: the document says "2023" and the LLM answers "2024". **Extrinsic** = The LLM adds information that is **not found** in the context at all. It fabricates from its training data. Intrinsic = altered, Extrinsic = added.
</details>

<details>
<summary>4. What are the 3 evaluation methods and when is each used?</summary>

1. **Human Evaluation** - People rate. Most accurate but slow and expensive. Suitable for gold standard.
2. **LLM-as-Judge** - An additional LLM evaluates answers. Fast and cheap. Suitable for CI/CD.
3. **Automated Metrics** - Fixed formulas (BLEU, ROUGE, F1). Cheapest and fastest, less nuanced.
</details>

<details>
<summary>5. How does LLM-as-Judge work?</summary>

A strong LLM (GPT-4o) is sent: (1) the original question, (2) the answer given, (3) the context provided, (4) a rubric with criteria ("score 1-5 for relevance, groundedness..."). The LLM returns a score + reasoning. Advantage: scalable and cheap. Disadvantage: LLM bias.
</details>

<details>
<summary>6. What is A/B Testing in the context of Agents?</summary>

Running **two versions** of an Agent in parallel: version A (current) and version B (new - different prompt/model/tools). Part of the traffic is routed to each version and metrics are compared (quality, latency, cost). This allows making data-driven decisions about which version is better.
</details>

<details>
<summary>7. Why is it important to integrate Evaluation into CI/CD?</summary>

Because Agents are **non-deterministic** - a small prompt change can break everything. Unit tests are not enough. Therefore: with every change (prompt, model, tools) an automatic eval suite runs that checks: Has quality been maintained? Is there regression? Only if passed → deploy.
</details>

---

**[⬅️ Back to Chapter 9: Policy](09-policy-governance.md)** | **[➡️ Continue to Chapter 11: Observability & Cost →](11-observability-cost.md)**
