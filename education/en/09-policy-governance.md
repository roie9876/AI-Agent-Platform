# 🛡️ Chapter 9: Policy & Governance Engine

## Table of Contents
- [What is a Policy Engine?](#what-is-a-policy-engine)
- [Why Do We Need Governance?](#why-do-we-need-governance)
- [Types of Policies](#types-of-policies)
- [Policy Enforcement Points](#policy-enforcement-points)
- [Guardrails](#guardrails)
- [Content Safety](#content-safety)
- [Data Loss Prevention (DLP)](#data-loss-prevention-dlp)
- [Audit & Compliance](#audit--compliance)
- [Pros and Cons](#pros-and-cons)
- [Summary and Questions](#summary-and-questions)

---

## What is a Policy Engine?

**Policy Engine** = A rules system that defines **what is allowed and what is forbidden** for Agents to do.

```mermaid
graph LR
    Agent["🤖 Agent wants to do X"] --> Policy["🛡️ Policy Engine"]
    Policy -->|"✅ Allowed"| Execute["▶️ Execute"]
    Policy -->|"❌ Forbidden"| Block["⛔ Block"]
    Policy -->|"⚠️ Conditional"| Modify["🔄 Modify & Execute"]
```

### Analogy:

```mermaid
graph TB
    subgraph "Real Company"
        Employee["👨‍💼 Employee"] --> Manager["👔 Manager approves"]
        Manager --> Legal["⚖️ Legal reviews"]
        Legal --> Compliance["📋 Compliance verifies"]
    end
    
    subgraph "AI Agent Platform"
        Agent["🤖 Agent"] --> PolicyEng["🛡️ Policy Engine"]
        PolicyEng --> Rules["📜 Rules"]
        PolicyEng --> Guardrails["🚧 Guardrails"]
    end
```

---

## Why Do We Need Governance?

### Without Governance:

```mermaid
graph TB
    Agent["🤖 Agent"] --> Bad1["📧 Sent email to entire company"]
    Agent --> Bad2["🗑️ Deleted a DB table"]
    Agent --> Bad3["💳 Exposed credit card numbers"]
    Agent --> Bad4["🤬 Wrote offensive content"]
    Agent --> Bad5["💸 Consumed $10,000 in tokens"]
    
    style Bad1 fill:#ff6b6b
    style Bad2 fill:#ff6b6b
    style Bad3 fill:#ff6b6b
    style Bad4 fill:#ff6b6b
    style Bad5 fill:#ff6b6b
```

### With Governance:

```mermaid
graph TB
    Agent["🤖 Agent"] --> PolicEng["🛡️ Policy Engine"]
    
    PolicEng --> Check1["📧 Email: only to authorized recipients ✅"]
    PolicEng --> Check2["🗄️ DB: read-only ✅"]
    PolicEng --> Check3["🔒 PII: masked ✅"]
    PolicEng --> Check4["📝 Content: safe ✅"]
    PolicEng --> Check5["💰 Budget: within limit ✅"]
```

---

## Types of Policies

### 1. Access Policies (Who is authorized)

```mermaid
graph TB
    subgraph "Access Policies"
        AP1["🔐 Authentication\nWho are you?"]
        AP2["🔑 Authorization\nWhat are you allowed to do?"]
        AP3["🔧 Tool Permissions\nWhich tools?"]
        AP4["🧠 Model Access\nWhich models?"]
    end
```

| Policy | Example |
|--------|---------|
| Agent Access | "Only the Analytics team can create Data Agents" |
| Tool Access | "This Agent is only authorized to use search and sql_read" |
| Model Access | "Only approved Agents can use GPT-4o" |
| Data Access | "Agent sees only data from its own tenant" |

### 2. Usage Policies (How much is allowed)

```mermaid
graph TB
    subgraph "Usage Policies"
        UP1["⏱️ Rate Limiting\nRequests/minute"]
        UP2["💰 Budget Limits\nBudget/agent"]
        UP3["🔢 Token Limits\nTokens/request"]
        UP4["⏰ Timeout\nMaximum time"]
        UP5["🔄 Max Steps\nMaximum steps"]
    end
```

| Policy | Example |
|--------|---------|
| Rate Limit | "Maximum 100 requests/minute per agent" |
| Budget | "Maximum $50/day per tenant" |
| Token Limit | "Maximum 50K tokens per request" |
| Timeout | "Agent must finish within 120 seconds" |
| Max Steps | "Maximum 10 tool calls per request" |

### 3. Content Policies (What is allowed to say)

```mermaid
graph TB
    subgraph "Content Policies"
        CP1["🚫 Toxicity Filter\nOffensive content"]
        CP2["🔒 PII Detection\nPersonal information"]
        CP3["📋 Topic Guard\nForbidden topics"]
        CP4["📝 Output Format\nRequired format"]
    end
```

### 4. Operational Policies (How to operate)

| Policy | Example |
|--------|---------|
| Logging | "Every tool call must be documented" |
| Approval | "Sending email requires human approval" |
| Fallback | "If Agent fails 3 times, transfer to a human agent" |
| SLA | "Maximum response time: 5 seconds" |

---

## Policy Enforcement Points

### Where are Policies enforced?

```mermaid
graph TB
    User["👤 User"] --> GW["🚪 API Gateway\n⏱️ Rate Limiting\n🔐 Authentication"]
    
    GW --> PreExec["🛡️ Pre-Execution\n🔑 Authorization\n💰 Budget Check\n📋 Config Validation"]
    
    PreExec --> Runtime["⚙️ Runtime\n🔧 Tool Permissions\n🔢 Token Counting\n⏰ Timeout"]
    
    Runtime --> PostExec["🛡️ Post-Execution\n🔒 PII Scanning\n📝 Content Safety\n📊 Cost Logging"]
    
    PostExec --> Response["📤 Response"]
```

### Pre-Execution Policies (Before execution):

```mermaid
sequenceDiagram
    participant Agent
    participant Policy as 🛡️ Policy Engine
    
    Agent->>Policy: "Agent wants to use sql_query"
    
    Policy->>Policy: ✅ Agent authorized for this tool?
    Policy->>Policy: ✅ Budget remaining?
    Policy->>Policy: ✅ Rate limit OK?
    Policy->>Policy: ✅ Within working hours?
    
    Policy-->>Agent: ✅ Proceed / ❌ Denied
```

### Runtime Policies (During execution):

```mermaid
graph TD
    Running["🔄 Agent Running"]
    
    Running --> TokenCheck{"Tokens > limit?"}
    TokenCheck -->|"Yes"| Stop1["⛔ Stop: Token limit"]
    TokenCheck -->|"No"| TimeCheck{"Timeout?"}
    TimeCheck -->|"Yes"| Stop2["⛔ Stop: Timeout"]
    TimeCheck -->|"No"| StepCheck{"Steps > max?"}
    StepCheck -->|"Yes"| Stop3["⛔ Stop: Max steps"]
    StepCheck -->|"No"| Continue["✅ Continue"]
```

### Post-Execution Policies (After execution):

```mermaid
graph TD
    Output["📤 Agent Output"] --> PII["🔍 PII Scanner"]
    PII -->|"Found PII"| Mask["🔒 Mask: 'XXX-XX-1234'"]
    PII -->|"Clean"| Safety["🛡️ Content Safety"]
    Mask --> Safety
    Safety -->|"Toxic"| Block["⛔ Block response"]
    Safety -->|"Safe"| Log["📝 Log & Return"]
```

---

## Guardrails

### What are Guardrails?
**Guardrails** = Protection mechanisms that ensure the Agent stays "on track" and doesn't do unwanted things.

```mermaid
graph TB
    subgraph "🚧 Guardrails"
        Input_Guard["📥 Input Guardrails\n(on the input)"]
        Output_Guard["📤 Output Guardrails\n(on the output)"]
        Execution_Guard["⚙️ Execution Guardrails\n(on the execution)"]
    end
    
    User["👤 User Input"] --> Input_Guard
    Input_Guard --> Agent["🤖 Agent"]
    Agent --> Execution_Guard
    Execution_Guard --> Output_Guard
    Output_Guard --> Response["📤 Response"]
```

### Input Guardrails:

| Guardrail | What it checks | Example |
|-----------|---------------|---------|
| **Prompt Injection Detection** | Attempt to trick the Agent | "Ignore all previous instructions..." |
| **Topic Boundary** | Question outside the domain | Financial Agent asked a medical question |
| **Language Detection** | Unsupported language | Request in an unsupported language |
| **Input Length** | Input too long | Prompt length limitation |

### Output Guardrails:

| Guardrail | What it checks | Example |
|-----------|---------------|---------|
| **PII Detection** | Personal information in output | ID numbers, credit cards |
| **Toxicity Filter** | Offensive content | Racism, violence |
| **Hallucination Check** | Incorrect facts | Cross-referencing with sources |
| **Format Validation** | Output in wrong format | Invalid JSON |

### Execution Guardrails:

| Guardrail | What it checks |
|-----------|---------------|
| **Max Iterations** | Agent doesn't get stuck in a loop |
| **Allowed Tools** | Agent only uses authorized tools |
| **Network Access** | Agent doesn't access forbidden addresses |
| **Resource Limits** | CPU, Memory, Disk don't exceed limits |

---

## Content Safety

### What is it?
A mechanism that ensures the content the Agent generates is **safe, respectful, and not harmful**.

```mermaid
graph TB
    Content["📝 Agent Output"] --> CS["🛡️ Content Safety"]
    
    CS --> Cat1["🚫 Violence\nViolence"]
    CS --> Cat2["🚫 Hate\nHate/Racism"]
    CS --> Cat3["🚫 Sexual\nSexual content"]
    CS --> Cat4["🚫 Self-harm\nSelf-harm"]
    CS --> Cat5["🚫 Misinformation\nFalse information"]
    
    Cat1 --> Score["Score: severity 0-7"]
    Score -->|"> threshold"| Block["⛔ Block"]
    Score -->|"< threshold"| Allow["✅ Allow"]
```

### Multi-Layer Content Safety:

```mermaid
graph LR
    Layer1["Layer 1:\nSystem Prompt\n'Never generate harmful content'"]
    Layer1 --> Layer2["Layer 2:\nGuardrail Model\n(lightweight classifier)"]
    Layer2 --> Layer3["Layer 3:\nPost-processing\n(regex, keyword filter)"]
    Layer3 --> Layer4["Layer 4:\nContent Safety API\n(Azure Content Safety)"]
```

---

## Data Loss Prevention (DLP)

### What is it?
**DLP** = Prevention of sensitive information leakage. Ensuring the Agent doesn't reveal:
- Credit card numbers
- ID numbers / SSN
- Passwords
- Medical information
- Confidential business information

```mermaid
graph TD
    Output["Agent Output:\n'The customer John Smith,\nSSN: 123-45-6789,\nlives at...'"]
    
    Output --> DLP["🔍 DLP Scanner"]
    
    DLP --> Detect["Detected:\n- Name (PII)\n- SSN (PII)\n- Address (PII)"]
    
    Detect --> Action{"Action?"}
    Action -->|"Mask"| Masked["'The customer J*** S****,\nSSN: XXX-XX-6789,\nlives at [REDACTED]'"]
    Action -->|"Block"| Blocked["⛔ Response blocked:\nContains PII"]
    Action -->|"Log & Alert"| Alert["📢 Alert sent to admin"]
```

### DLP Strategies:

| Strategy | Explanation | When |
|----------|------------|------|
| **Block** | Block the response entirely | Severe PII (SSN, credit card) |
| **Mask** | Mask the sensitive information | Names, addresses |
| **Tokenize** | Replace with an encrypted token | Internal identifiers |
| **Log & Alert** | Log and send an alert | Doesn't block, but alerts |

---

## Audit & Compliance

### What is an Audit Trail?
Documentation of **every action** that every Agent performed - who, what, when, and why.

```mermaid
graph TB
    subgraph "📋 Audit Log"
        E1["2026-02-21 10:00:01\nAgent: data-analyst\nAction: sql_query\nUser: roi\nResult: success"]
        E2["2026-02-21 10:00:05\nAgent: data-analyst\nAction: llm_call\nModel: gpt-4o\nTokens: 1,523"]
        E3["2026-02-21 10:00:07\nAgent: data-analyst\nAction: send_email\nStatus: BLOCKED by policy\nReason: missing approval"]
    end
```

### Compliance Requirements:

| Standard | Explanation | Key Requirements |
|----------|------------|-----------------|
| **GDPR** | European data protection | Right to be forgotten, consent |
| **SOC 2** | Information security | Logging, access control |
| **HIPAA** | Medical information | Encryption, audit trail |
| **PCI-DSS** | Credit cards | PII masking, encryption |

### Policy as Code

Like Infrastructure as Code, Policies also need to be **defined as code**:

```
policy:
  name: "data-analyst-policy"
  version: "1.2"
  rules:
    - name: "read-only-db"
      description: "SQL queries must be read-only"
      target: tool.sql_query
      condition: "query NOT CONTAINS 'DELETE|DROP|UPDATE|INSERT'"
      action: BLOCK
      
    - name: "budget-limit"
      description: "Max $5 per day"
      target: agent.cost
      condition: "daily_cost > 5.00"
      action: BLOCK
      
    - name: "pii-masking"
      description: "Mask PII in output"
      target: agent.output
      condition: "contains_pii(output)"
      action: MASK
```

---

## Pros and Cons

| ✅ Advantage | ❌ Disadvantage |
|-------------|----------------|
| Prevention of unauthorized use | Additional latency (policy checking) |
| Cost control | Complexity in managing rules |
| Automatic Compliance | False positives (blocks legitimate things) |
| Full audit trail | Requires ongoing updates |
| Protection against PII leaks | User experience - Agent is limited |
| Consistent enforcement | Policy conflicts |

---

## Summary

```mermaid
mindmap
  root((Policy & Governance))
    Policy Types
      Access Policies
      Usage Policies
      Content Policies
      Operational Policies
    Enforcement Points
      Pre-Execution
      Runtime
      Post-Execution
    Guardrails
      Input Guards
      Output Guards
      Execution Guards
    Content Safety
      Toxicity
      Hate Speech
      Multi-layer
    DLP
      PII Detection
      Masking
      Blocking
    Compliance
      Audit Trail
      GDPR/SOC2
      Policy as Code
```

| What We Learned | Key Point |
|----------------|-----------|
| **Policy Engine** | A rules system that determines what is allowed and what is forbidden |
| **Guardrails** | Input, Output, Execution - three layers of protection |
| **Content Safety** | Filtering offensive content |
| **DLP** | Prevention of sensitive information leakage (PII) |
| **Audit Trail** | Documentation of every action for Compliance purposes |
| **Policy as Code** | Policies defined as code, not manually |

---

## ❓ Self-Assessment Questions

1. What are the 4 types of Policies?
2. What is the difference between Pre-Execution and Post-Execution policy?
3. What are Guardrails and what 3 types exist?
4. What is Prompt Injection and how do you defend against it?
5. What is DLP and what handling strategies exist (Block, Mask, etc.)?
6. Why is Audit Trail important?
7. What is Policy as Code and why is it better than manual configuration?

---

### 📝 Answers

<details>
<summary>1. What are the 4 types of Policies?</summary>

1. **Safety Policies** - Prevention of harmful/violent/dangerous content.
2. **Compliance Policies** - Meeting regulations (GDPR, HIPAA).
3. **Business Policies** - Business rules (budget, max cost).
4. **Operational Policies** - Rate limiting, resource monitoring.
</details>

<details>
<summary>2. What is the difference between Pre-Execution and Post-Execution policy?</summary>

**Pre-Execution** = Checked **before** the request reaches the LLM. For example: prompt injection filtering, PII checking in input. If it fails → the request is blocked. **Post-Execution** = Checked **after** the LLM returns a response. For example: PII checking in the response, content safety, groundedness check.
</details>

<details>
<summary>3. What are Guardrails and what 3 types exist?</summary>

**Guardrails** = "Safety fences" that prevent the Agent from deviating from the path. 3 types: (1) **Input Guardrails** - Filtering and validation of input, (2) **Output Guardrails** - Filtering the LLM's response, (3) **Topical Guardrails** - Preventing the Agent from going outside its domain ("don't answer about politics").
</details>

<details>
<summary>4. What is Prompt Injection and how do you defend against it?</summary>

**Prompt Injection** = An attacker injects instructions in input that impersonate a system prompt ("ignore all previous instructions"). Defense: (1) **Input Validation** - Pattern recognition, (2) **Prompt Sandboxing** - Separation between system and user, (3) **Classifier Models** - A separate model that detects injection.
</details>

<details>
<summary>5. What is DLP and what handling strategies exist?</summary>

**DLP (Data Loss Prevention)** = Prevention of sensitive information leakage (PII, secrets, credit cards). Strategies: (1) **Block** - Completely blocks if there's PII, (2) **Mask** - Replaces with asterisks ("***-**-1234"), (3) **Tokenize** - Replaces with a token and returns after processing, (4) **Log & Alert** - Allows but documents.
</details>

<details>
<summary>6. Why is Audit Trail important?</summary>

**Audit Trail** = Full documentation of every action the Agent performed (who, what, when, result). Important for: (1) **Regulation** - GDPR/HIPAA require documentation, (2) **Debug** - Understanding where the Agent reached a decision, (3) **Accountability** - Knowing who did what, (4) **Improvement** - Identifying misuse.
</details>

<details>
<summary>7. What is Policy as Code and why is it better than manual configuration?</summary>

**Policy as Code** = Defining policies in code (YAML/JSON/Rego) instead of manual UI. Better because: (1) **Version Control** - Saved in Git, has history and rollback, (2) **CI/CD** - Automatically tested in pipeline, (3) **Reproducibility** - Same policy in all environments, (4) **Automation** - No human errors.
</details>

---

**[⬅️ Back to Chapter 8: Tools](08-tools-marketplace.md)** | **[➡️ Continue to Chapter 10: Evaluation Engine →](10-evaluation-engine.md)**
