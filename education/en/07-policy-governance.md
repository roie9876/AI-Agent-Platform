# 🛡️ Chapter 7: Policy & Governance Engine

> 🔗 **See it in production:** [Policy Engine & Governance (AI-Platform-System)](https://github.com/roie9876/AI-Platform-System#25-policy-engine--governance)

## Table of Contents
- [What is a Policy Engine?](#what-is-a-policy-engine)
- [Why Do We Need Governance?](#why-do-we-need-governance)
- [Types of Policies](#types-of-policies)
- [Policy Enforcement Points](#policy-enforcement-points)
- [Guardrails](#guardrails)
- [Content Safety](#content-safety)
- [Data Loss Prevention (DLP)](#data-loss-prevention-dlp)
- [Audit & Compliance](#audit--compliance)
- [Industry Tools & Frameworks](#industry-tools--frameworks)
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

Think of the Policy Engine as the rules and regulations that every employee in a company must follow. Just as an employee's actions go through management, legal, and compliance review, every agent action passes through the Policy Engine before it's allowed to execute.

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
    Agent --> Bad5["💸 Consumed #36;10,000 in tokens"]
    
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
        AP1["🔐 Authentication<br/>Who are you?"]
        AP2["🔑 Authorization<br/>What are you allowed to do?"]
        AP3["🔧 Tool Permissions<br/>Which tools?"]
        AP4["🧠 Model Access<br/>Which models?"]
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
        UP1["⏱️ Rate Limiting<br/>Requests/minute"]
        UP2["💰 Budget Limits<br/>Budget/agent"]
        UP3["🔢 Token Limits<br/>Tokens/request"]
        UP4["⏰ Timeout<br/>Maximum time"]
        UP5["🔄 Max Steps<br/>Maximum steps"]
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
        CP1["🚫 Toxicity Filter<br/>Offensive content"]
        CP2["🔒 PII Detection<br/>Personal information"]
        CP3["📋 Topic Guard<br/>Forbidden topics"]
        CP4["📝 Output Format<br/>Required format"]
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

Policies aren't checked in just one place — they're enforced at **multiple points** throughout the request lifecycle. This is defense-in-depth: if one check fails to catch something, the next one might. No single enforcement point catches everything.

```mermaid
graph TB
    User["👤 User"] --> GW["🚪 API Gateway<br/>⏱️ Rate Limiting<br/>🔐 Authentication"]
    
    GW --> PreExec["🛡️ Pre-Execution<br/>🔑 Authorization<br/>💰 Budget Check<br/>📋 Config Validation"]
    
    PreExec --> Runtime["⚙️ Runtime<br/>🔧 Tool Permissions<br/>🔢 Token Counting<br/>⏰ Timeout"]
    
    Runtime --> PostExec["🛡️ Post-Execution<br/>🔒 PII Scanning<br/>📝 Content Safety<br/>📊 Cost Logging"]
    
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
        Input_Guard["📥 Input Guardrails<br/>(on the input)"]
        Output_Guard["📤 Output Guardrails<br/>(on the output)"]
        Execution_Guard["⚙️ Execution Guardrails<br/>(on the execution)"]
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
    
    CS --> Cat1["🚫 Violence<br/>Violence"]
    CS --> Cat2["🚫 Hate<br/>Hate/Racism"]
    CS --> Cat3["🚫 Sexual<br/>Sexual content"]
    CS --> Cat4["🚫 Self-harm<br/>Self-harm"]
    CS --> Cat5["🚫 Misinformation<br/>False information"]
    
    Cat1 --> Score["Score: severity 0-7"]
    Score -->|"> threshold"| Block["⛔ Block"]
    Score -->|"< threshold"| Allow["✅ Allow"]
```

### Multi-Layer Content Safety:

```mermaid
graph LR
    Layer1["Layer 1:<br/>System Prompt<br/>'Never generate harmful content'"]
    Layer1 --> Layer2["Layer 2:<br/>Guardrail Model<br/>(lightweight classifier)"]
    Layer2 --> Layer3["Layer 3:<br/>Post-processing<br/>(regex, keyword filter)"]
    Layer3 --> Layer4["Layer 4:<br/>Content Safety API<br/>(Azure Content Safety)"]
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
    Output["Agent Output:<br/>'The customer John Smith,<br/>SSN: 123-45-6789,<br/>lives at...'"]
    
    Output --> DLP["🔍 DLP Scanner"]
    
    DLP --> Detect["Detected:<br/>- Name (PII)<br/>- SSN (PII)<br/>- Address (PII)"]
    
    Detect --> Action{"Action?"}
    Action -->|"Mask"| Masked["'The customer J*** S****,<br/>SSN: XXX-XX-6789,<br/>lives at [REDACTED]'"]
    Action -->|"Block"| Blocked["⛔ Response blocked:<br/>Contains PII"]
    Action -->|"Log & Alert"| Alert["📢 Alert sent to admin"]
```

### DLP Strategies:

| Strategy | Explanation | When |
|----------|------------|------|
| **Block** | Block the response entirely | Severe PII (SSN, credit card) |
| **Mask** | Mask the sensitive information | Names, addresses |
| **Tokenize** | Replace with an encrypted token | Internal identifiers |
| **Log & Alert** | Log and send an alert | Doesn't block, but alerts |

### DLP Implementation Example

```python
import re
from dataclasses import dataclass

@dataclass
class DLPRule:
    name: str
    pattern: str   # regex pattern
    action: str    # "mask", "block", "log"
    mask_format: str = None

# Define PII detection rules
DLP_RULES = [
    DLPRule(
        name="ssn",
        pattern=r'\b\d{3}-\d{2}-\d{4}\b',
        action="mask",
        mask_format="XXX-XX-****"   # Keep last 4 digits
    ),
    DLPRule(
        name="credit_card",
        pattern=r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b',
        action="block"              # Never allow credit cards through
    ),
    DLPRule(
        name="email",
        pattern=r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
        action="mask",
        mask_format="[EMAIL_REDACTED]"
    ),
    DLPRule(
        name="phone",
        pattern=r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b',
        action="mask",
        mask_format="[PHONE_REDACTED]"
    ),
]

def scan_and_protect(text: str, rules: list[DLPRule]) -> dict:
    """Scan text for PII and apply protection actions."""
    violations = []
    protected_text = text
    
    for rule in rules:
        matches = re.findall(rule.pattern, protected_text)
        if matches:
            if rule.action == "block":
                raise DLPBlockedException(
                    f"Output blocked: contains {rule.name} "
                    f"({len(matches)} occurrences)"
                )
            elif rule.action == "mask":
                protected_text = re.sub(
                    rule.pattern, rule.mask_format, protected_text
                )
            violations.append({
                "rule": rule.name,
                "count": len(matches),
                "action": rule.action
            })
    
    return {"text": protected_text, "violations": violations}

# Example usage:
# Input:  "Customer John, SSN: 123-45-6789, email: john@acme.com"
# Output: "Customer John, SSN: XXX-XX-****,  email: [EMAIL_REDACTED]"
```

---

## Audit & Compliance

### What is an Audit Trail?
Documentation of **every action** that every Agent performed - who, what, when, and why.

```mermaid
graph TB
    subgraph "📋 Audit Log"
        E1["2026-02-21 10:00:01<br/>Agent: data-analyst<br/>Action: sql_query<br/>User: roi<br/>Result: success"]
        E2["2026-02-21 10:00:05<br/>Agent: data-analyst<br/>Action: llm_call<br/>Model: gpt-4o<br/>Tokens: 1,523"]
        E3["2026-02-21 10:00:07<br/>Agent: data-analyst<br/>Action: send_email<br/>Status: BLOCKED by policy<br/>Reason: missing approval"]
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

## Industry Tools & Frameworks

### Why Governance Matters — Real-World Failures

Without governance, agents can cause real damage:

- **Samsung (2023):** Engineers pasted proprietary source code into ChatGPT for debugging. The code became part of the training data. Samsung banned AI tools company-wide.
- **Air Canada (2024):** A customer support chatbot made up a refund policy that didn't exist. Air Canada was legally obligated to honor it.
- **Healthcare chatbots:** Multiple cases of medical chatbots giving dangerous advice when jailbroken with simple prompts.

These incidents show why governance isn't bureaucratic overhead — it's **risk management** for AI systems.

### Governance & Safety Platforms

| Tool | Creator | What It Does | Best For |
|------|---------|-------------|----------|
| **Azure AI Content Safety** | Microsoft | Real-time content classification (hate, violence, sexual, self-harm, jailbreak) | Azure-native, production safety |
| **Guardrails AI** | Open-source | Input/output validation framework with 50+ pre-built validators | Custom safety rules, any LLM |
| **NeMo Guardrails** | NVIDIA | Programmable conversation guardrails with Colang language | Complex safety flows |
| **LlamaGuard** | Meta | Open-source safety classifier fine-tuned on safety categories | Self-hosted safety classification |
| **Presidio** | Microsoft | PII detection and anonymization (emails, credit cards, SSNs, etc.) | DLP, GDPR compliance |

### Policy Engines & Rate Limiting

| Tool | What It Does | Best For |
|------|-------------|----------|
| **Azure API Management** | Rate limiting, quotas, policies for API traffic | Enterprise API governance |
| **OPA (Open Policy Agent)** | General-purpose policy engine (used by K8s, Envoy) | Fine-grained access control |
| **Kong Gateway** | API gateway with rate limiting and authentication plugins | Multi-cloud API management |
| **Portkey AI Gateway** | LLM-specific gateway with budget controls, fallbacks, caching | LLM cost management |

### Compliance Frameworks

| Framework | What It Covers | Who Needs It |
|-----------|---------------|-------------|
| **EU AI Act** | Risk classification, transparency requirements for AI systems | Any company serving EU users |
| **SOC 2 Type II** | Security controls audit (access, encryption, monitoring) | Enterprise B2B SaaS |
| **GDPR** | Personal data protection, right to deletion | Any company handling EU personal data |
| **HIPAA** | Healthcare data protection | Healthcare AI applications |

> 💡 **Key insight:** Governance is not one tool — it's a **stack** of policies, tools, and processes. You need content safety + DLP + rate limiting + audit logging + compliance, all working together.

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

> 🔗 **See it in production:** [Policy Engine & Governance (AI-Platform-System)](https://github.com/roie9876/AI-Platform-System#25-policy-engine--governance)

**[⬅️ Back to Chapter 6: Tools](06-tools-marketplace.md)** | **[➡️ Continue to Chapter 8: Control Plane →](08-control-plane.md)**
