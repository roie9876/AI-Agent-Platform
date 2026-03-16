# 🔧 Chapter 6: Tools & Marketplace

## Table of Contents
- [What Are Tools?](#what-are-tools)
- [Function Calling](#function-calling)
- [Types of Tools](#types-of-tools)
- [Tool Registry](#tool-registry)
- [Tool Execution Pipeline](#tool-execution-pipeline)
- [Tool Marketplace](#tool-marketplace)
- [Tool Security](#tool-security)
- [Pros and Cons](#pros-and-cons)
- [Summary and Questions](#summary-and-questions)

---

## What Are Tools?

**Tool** = A function/API that the Agent can invoke to **act in the real world**.

The LLM knows how to generate text. Tools give it **hands**:

```mermaid
graph TB
    LLM["🧠 LLM Only"] --> Text["📝 Can only write text"]
    
    AgentTools["🧠 LLM + 🔧 Tools"] --> Actions
    
    subgraph Actions["Actions in the World"]
        Search["🔍 Search"]
        Code["🐍 Run Code"]
        DB["🗄️ DB Query"]
        Email["📧 Send Email"]
        API["🌐 API Call"]
        File["📁 Read/Write Files"]
    end
```

---

## Function Calling

### What Is It?
**Function Calling** is the mechanism by which the LLM "requests" to invoke a tool. The LLM doesn't run the tool itself - it **returns an instruction** that the system executes.

### The Flow:

```mermaid
sequenceDiagram
    participant App as 🖥️ Application
    participant LLM as 🧠 LLM
    participant Tool as 🔧 Tool
    
    App->>LLM: "What's the weather in Tel Aviv?"<br/>+ Tool definitions
    
    Note over LLM: LLM decides to use a tool
    LLM-->>App: {tool_call: "get_weather", args: {city: "Tel Aviv"}}
    
    Note over App: App executes the tool
    App->>Tool: get_weather("Tel Aviv")
    Tool-->>App: {temp: 25, condition: "sunny"}
    
    App->>LLM: Tool result: {temp: 25, condition: "sunny"}
    LLM-->>App: "Weather in Tel Aviv: 25°C, sunny ☀️"
```

### How Does the LLM "Know" About the Tools?

We send **tool definitions** as part of the prompt:

```
Tool Definition:
├── name: "get_weather"
├── description: "Get current weather for a city"
└── parameters:
    ├── city (string, required): "The city name"
    └── unit (string, optional): "celsius or fahrenheit"
```

The LLM sees the definition and **decides** if and when to use a tool.

### Important Point: The LLM Doesn't Execute Anything!

```mermaid
graph LR
    LLM["🧠 LLM"] -->|"Returns JSON:<br/>{tool: 'search', args: {...}}"| App["🖥️ Application"]
    App -->|"Executes"| Tool["🔧 Tool"]
    Tool -->|"Result"| App
    App -->|"Returns result"| LLM
    
    style LLM fill:#a8d5e2
    style App fill:#f7dc6f
    style Tool fill:#82e0aa
```

---

## Types of Tools

### 1. Data Retrieval Tools

```mermaid
graph LR
    Agent["🤖"] --> SQL["🗄️ SQL Query"]
    Agent --> Search["🔍 Web Search"]
    Agent --> FileRead["📂 File Reader"]
    Agent --> APIGet["🌐 API GET"]
```

| Tool | What It Does | Example |
|------|-------------|---------|
| SQL Query | Query a database | `SELECT * FROM sales WHERE...` |
| Web Search | Search the internet | Bing/Google search |
| File Reader | Read a file | Read CSV, PDF, Excel |
| API Call | Call an external API | GET /api/customers |

### 2. Action Tools

```mermaid
graph LR
    Agent["🤖"] --> Email["📧 Send Email"]
    Agent --> Create["📝 Create Document"]
    Agent --> Update["✏️ Update Record"]
    Agent --> Deploy["🚀 Deploy"]
```

### 3. Computation Tools

```mermaid
graph LR
    Agent["🤖"] --> Python["🐍 Python Executor"]
    Agent --> Calc["🔢 Calculator"]
    Agent --> Chart["📊 Chart Generator"]
    Agent --> ML["🤖 ML Model"]
```

### 4. Communication Tools

```mermaid
graph LR
    Agent["🤖"] --> Slack["💬 Slack Message"]
    Agent --> Teams["📱 Teams Message"]
    Agent --> Ticket["🎫 Create Ticket"]
```

### Classification by Risk Level:

```mermaid
graph TB
    subgraph "🟢 Low Risk (Read-only)"
        R1["Search"]
        R2["Read file"]
        R3["API GET"]
    end
    
    subgraph "🟡 Medium Risk (Reversible writes)"
        R4["Create draft"]
        R5["Update record"]
        R6["Create ticket"]
    end
    
    subgraph "🔴 High Risk (Irreversible)"
        R7["Send email"]
        R8["Delete data"]
        R9["Deploy to production"]
        R10["Transfer money"]
    end
```

---

## Tool Registry

### What Is It?
**Tool Registry** = A central repository of all available tools in the platform.

```mermaid
graph TB
    subgraph Registry["📋 Tool Registry"]
        T1["🔍 web_search<br/>v2.1 | search | low-risk"]
        T2["🗄️ sql_query<br/>v1.5 | data | medium-risk"]
        T3["🐍 python_exec<br/>v3.0 | compute | high-risk"]
        T4["📧 send_email<br/>v1.0 | comm | high-risk"]
    end
    
    Agent1["🤖 Agent A"] -->|"has access to"| T1
    Agent1 -->|"has access to"| T2
    
    Agent2["🤖 Agent B"] -->|"has access to"| T1
    Agent2 -->|"has access to"| T3
```

### Tool Definition Schema:

```
Tool:
├── id: "tool-sql-query"
├── name: "sql_query"
├── version: "1.5"
├── description: "Execute read-only SQL queries"
├── category: "data-retrieval"
├── risk_level: "medium"
├── parameters:
│   ├── query (string, required): "SQL query to execute"
│   └── database (string, required): "Target database name"
├── returns:
│   └── results (array): "Query results"
├── auth:
│   └── requires: ["db-read-access"]
├── limits:
│   ├── max_rows: 1000
│   ├── timeout: 30s
│   └── rate_limit: "10/minute"
├── sandbox:
│   └── required: true
└── owner: "team-data-platform"
```

---

## Tool Execution Pipeline

The flow from the moment the LLM requests a tool until the result comes back:

```mermaid
sequenceDiagram
    participant LLM as 🧠 LLM
    participant Orch as 🎭 Orchestrator
    participant Policy as 🛡️ Policy Engine
    participant Registry as 📋 Registry
    participant Sandbox as 🔒 Sandbox
    participant Tool as 🔧 Tool
    
    LLM-->>Orch: {tool_call: "sql_query", args: {...}}
    
    Note over Orch: Step 1: Validate
    Orch->>Registry: Is tool registered & active?
    Registry-->>Orch: ✅ Yes
    
    Note over Orch: Step 2: Authorization
    Orch->>Policy: Can this agent use this tool?
    Policy-->>Orch: ✅ Allowed
    
    Note over Orch: Step 3: Input Validation
    Orch->>Orch: Validate parameters schema
    
    Note over Orch: Step 4: Execute in Sandbox
    Orch->>Sandbox: Create isolated environment
    Sandbox->>Tool: Execute(args)
    Tool-->>Sandbox: Result
    Sandbox-->>Orch: Result (sanitized)
    
    Note over Orch: Step 5: Output Validation
    Orch->>Policy: Check output (PII? sensitive data?)
    Policy-->>Orch: ✅ Clean
    
    Orch-->>LLM: Tool result
```

### Pipeline Steps:

| Step | What Happens | Why It's Important |
|------|-------------|-------------------|
| **1. Validate** | Check that the tool exists | Prevent errors |
| **2. Authorize** | Check permissions | Security |
| **3. Input Validate** | Check that parameters are valid | Prevent injection |
| **4. Execute** | Run in an isolated environment | Security + isolation |
| **5. Output Validate** | Check that the result doesn't contain PII | Compliance |

### Implementation Example

```python
from typing import Any
from pydantic import ValidationError

async def execute_tool_pipeline(
    tool_call: ToolCall,
    agent_context: AgentContext
) -> ToolResult:
    """The 5-step tool execution pipeline."""
    
    # Step 1: Validate - Does the tool exist?
    tool = tool_registry.get(tool_call.name)
    if not tool:
        raise ToolNotFoundError(f"Tool '{tool_call.name}' not registered")
    if not tool.is_active:
        raise ToolDisabledError(f"Tool '{tool_call.name}' is disabled")
    
    # Step 2: Authorize - Can this agent use this tool?
    if not policy_engine.check_tool_permission(
        agent_id=agent_context.agent_id,
        tool_name=tool_call.name,
        user_role=agent_context.user_role
    ):
        raise ToolUnauthorizedError(
            f"Agent '{agent_context.agent_id}' cannot use '{tool_call.name}'"
        )
    
    # Step 3: Input Validation - Are parameters valid and safe?
    try:
        validated_params = tool.input_schema.validate(tool_call.arguments)
    except ValidationError as e:
        raise InvalidToolInputError(f"Invalid parameters: {e}")
    
    # Sanitize inputs (prevent SQL injection, command injection, etc.)
    sanitized_params = input_sanitizer.sanitize(validated_params, tool.input_schema)
    
    # Step 4: Execute in Sandbox
    result = await sandbox.execute(
        tool=tool,
        params=sanitized_params,
        timeout=tool.limits.timeout,
        resource_limits=tool.limits.resources
    )
    
    # Step 5: Output Validation - Check for PII, sensitive data
    scan_result = dlp_scanner.scan(result.data)
    if scan_result.has_violations:
        result.data = dlp_scanner.mask(result.data, scan_result.violations)
    
    # Log the execution
    audit_logger.log_tool_execution(
        tool=tool_call.name,
        agent=agent_context.agent_id,
        user=agent_context.user_id,
        duration=result.duration,
        status="success"
    )
    
    return result
```

### Tool Definition Example

```json
{
  "name": "sql_query",
  "version": "1.5",
  "description": "Execute read-only SQL queries on authorized databases",
  "parameters": {
    "type": "object",
    "properties": {
      "query": {
        "type": "string",
        "description": "SQL SELECT query to execute"
      },
      "database": {
        "type": "string",
        "enum": ["sales_db", "analytics_db"],
        "description": "Target database"
      }
    },
    "required": ["query", "database"]
  },
  "security": {
    "requires_permissions": ["db-read-access"],
    "allowed_operations": ["SELECT"],
    "blocked_keywords": ["DROP", "DELETE", "UPDATE", "INSERT", "ALTER"]
  },
  "limits": {
    "max_rows": 1000,
    "timeout": "30s",
    "rate_limit": "10/minute"
  }
}
```

---

## Tool Marketplace

### What Is It?
**Marketplace** = A store/catalog where teams can **publish**, **discover**, and **use** tools that others have built.

```mermaid
graph TB
    subgraph "🏪 Tool Marketplace"
        direction TB
        Cat1["📂 Data & Analytics"]
        Cat2["📂 Communication"]
        Cat3["📂 DevOps"]
        Cat4["📂 Finance"]
        
        Cat1 --> T1["sql_query ⭐4.5"]
        Cat1 --> T2["csv_analyzer ⭐4.2"]
        Cat2 --> T3["send_email ⭐4.8"]
        Cat2 --> T4["slack_msg ⭐4.0"]
        Cat3 --> T5["deploy_app ⭐3.9"]
        Cat4 --> T6["invoice_gen ⭐4.3"]
    end
    
    TeamA["👨‍💻 Team A<br/>(publishes)"] -->|"📤"| Cat1
    TeamB["👩‍💻 Team B<br/>(uses)"] -->|"📥"| Cat2
```

### Marketplace Features:

| Feature | Explanation |
|---------|------------|
| **Discovery** | Search for tools by category, name, description |
| **Versioning** | Each tool with versions (v1.0, v1.1, v2.0) |
| **Documentation** | Documentation, usage examples, API reference |
| **Ratings & Reviews** | Ratings and feedback from users |
| **Usage Analytics** | How many times the tool was used, success rate |
| **Access Control** | Who can use it - public/private/team-only |
| **Certification** | Tools that passed security and quality checks |

### Publishing Flow:

```mermaid
sequenceDiagram
    actor Dev as 👨‍💻 Developer
    participant MKT as 🏪 Marketplace
    participant Test as 🧪 Testing
    participant Review as 👁️ Security Review
    participant Pub as 📢 Published
    
    Dev->>MKT: Submit tool
    MKT->>Test: Automated tests
    Test-->>MKT: ✅ Tests pass
    MKT->>Review: Security scan
    Review-->>MKT: ✅ No vulnerabilities
    MKT->>Pub: Publish to marketplace
    Note over Pub: Available for all teams
```

---

## Tool Security

### Input Sanitization

```mermaid
graph TD
    Input["Input from LLM:<br/>sql_query('DROP TABLE users')"] --> Sanitize["🛡️ Sanitizer"]
    Sanitize -->|"❌ Blocked"| Reject["SQL Injection detected!"]
    
    Input2["Input from LLM:<br/>sql_query('SELECT * FROM sales')"] --> Sanitize2["🛡️ Sanitizer"]
    Sanitize2 -->|"✅ Allowed"| Execute["Execute query"]
```

### Security Risks in Tools:

| Risk | Explanation | Protection |
|------|------------|------------|
| **Prompt Injection** | LLM tricked into calling an unauthorized tool | Policy Engine, allowlist |
| **SQL Injection** | LLM generates malicious SQL | Parameterized queries, read-only |
| **Code Injection** | Agent generates dangerous code | Sandbox, restricted permissions |
| **Data Exfiltration** | Tool sends sensitive data out | Network isolation, output scanning |
| **Excessive Permissions** | Tool with overly broad permissions | Least Privilege, scoped access |

### Principle of Least Privilege:

```mermaid
graph TB
    subgraph "❌ Over-privileged"
        T1["SQL Tool"] --> Full["Full DB access<br/>READ + WRITE + DELETE + ADMIN"]
    end
    
    subgraph "✅ Least Privilege"
        T2["SQL Tool"] --> Limited["Read-only<br/>Specific tables only<br/>Max 1000 rows"]
    end
```

---

## Pros and Cons

### Tools

| ✅ Advantage | ❌ Disadvantage |
|-------------|----------------|
| Agent can act in the world | Security risks |
| Extends LLM capabilities | Each tool call adds latency |
| Modular - easy to add tools | LLM may call the wrong tool |
| Reusable across Agents | Tool definitions consume tokens |

### Marketplace

| ✅ Advantage | ❌ Disadvantage |
|-------------|----------------|
| Sharing across teams | Version management |
| Easy discovery | Quality control |
| Standardization | Security review overhead |
| Development speed | Dependency management |

---

## Summary

```mermaid
mindmap
  root((Tools))
    Function Calling
      Tool Definitions
      LLM decides
      App executes
    Types
      Data Retrieval
      Actions
      Computation
      Communication
    Registry
      Schema
      Versioning
      Access Control
    Execution Pipeline
      Validate
      Authorize
      Execute in Sandbox
      Output Check
    Marketplace
      Discovery
      Publishing
      Ratings
      Certification
    Security
      Input Sanitization
      Least Privilege
      Sandbox Execution
```

| What We Learned | Key Point |
|----------------|-----------|
| **Tools** | Functions that give the Agent the ability to act in the world |
| **Function Calling** | LLM returns an instruction (JSON), the system executes |
| **Tool Registry** | Central repository of all available tools |
| **Execution Pipeline** | Validate → Auth → Execute → Output Check |
| **Marketplace** | Tool store with discovery, versioning, reviews |
| **Security** | Input sanitization, Least Privilege, Sandbox |

---

## ❓ Self-Assessment Questions

1. What is the difference between a Tool and Function Calling?
2. Why doesn't the LLM execute the tool itself?
3. What are the four types of tools? Give an example for each.
4. What are the 5 steps in the Tool Execution Pipeline?
5. What is a Tool Marketplace and why is it important?
6. What is the Principle of Least Privilege in the context of Tools?
7. What are 3 security risks in using tools and how do you defend against them?

---

### 📝 Answers

<details>
<summary>1. What is the difference between a Tool and Function Calling?</summary>

**Tool** = An external capability that the Agent can invoke (API, DB query, calculator). **Function Calling** = The technical mechanism through which the LLM **requests** tool invocation - it returns JSON with the function name and parameters. Tool = what, Function Calling = how the LLM requests it.
</details>

<details>
<summary>2. Why doesn't the LLM execute the tool itself?</summary>

An LLM is a **language model** - it generates text, it doesn't run code. It is **not connected to the internet/DB/APIs**. Therefore the LLM only **decides** which tool to invoke, and the **Platform** (Runtime) actually executes it - separation of responsibility for security.
</details>

<details>
<summary>3. What are the four types of tools? Give an example for each.</summary>

1. **API Tools** - Calling external services (weather, scheduling a meeting).
2. **Data Tools** - Database access (SQL query, vector search).
3. **Compute Tools** - Computational code (Python sandbox, calculator).
4. **System Tools** - System operations (sending email, file system).
</details>

<details>
<summary>4. What are the 5 steps in the Tool Execution Pipeline?</summary>

1. **Selection** - The LLM chooses which tool to invoke.
2. **Validation** - Checking parameters, permissions, schema.
3. **Execution** - Running the tool (in a sandbox).
4. **Result Processing** - Processing the result (filtering, truncating).
5. **Return** - Returning the result to the LLM for the Observe step in the ReAct loop.
</details>

<details>
<summary>5. What is a Tool Marketplace and why is it important?</summary>

**Tool Marketplace** = A central catalog of ready-to-use tools, like an App Store for tools. Important because: (1) **Reuse** - don't reinvent the wheel, (2) **Compliance** - tools are tested for security and quality, (3) **Documentation** - uniform schema that the LLM understands, (4) **Discovery** - version discovery.
</details>

<details>
<summary>6. What is the Principle of Least Privilege in the context of Tools?</summary>

Give a tool only the **minimum** permissions it needs. For example: a tool that reads from a DB gets only read access, not write/delete. A tool that sends email can only send, not read the entire inbox. Reduces the "blast radius" if something goes wrong.
</details>

<details>
<summary>7. What are 3 security risks in using tools and how do you defend against them?</summary>

1. **Injection** - An attacker injects malicious input into a tool (SQL injection through the agent). Defense: input validation, parameterized queries.
2. **Data Exfiltration** - The Agent sends sensitive data through a tool. Defense: output filtering, DLP.
3. **Excessive Permissions** - A tool with overly broad permissions causes damage. Defense: Least Privilege, regular permission audits.
</details>

---

**[⬅️ Back to Chapter 5: Orchestration](05-orchestration.md)** | **[➡️ Continue to Chapter 7: Policy & Governance →](07-policy-governance.md)**
