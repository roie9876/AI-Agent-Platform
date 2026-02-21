# ⚙️ פרק 3: Runtime (Data) Plane

## תוכן עניינים
- [מהו Runtime Plane?](#מהו-runtime-plane)
- [ההבדל בין Control ל-Runtime](#ההבדל-בין-control-ל-runtime)
- [מחזור חיים של בקשה](#מחזור-חיים-של-בקשה)
- [רכיבי ה-Runtime Plane](#רכיבי-ה-runtime-plane)
- [The Orchestrator](#the-orchestrator)
- [Execution Models](#execution-models)
- [הרצה בטוחה - Sandboxing](#הרצה-בטוחה---sandboxing)
- [יתרונות וחסרונות](#יתרונות-וחסרונות)
- [סיכום ושאלות](#סיכום-ושאלות)

---

## מהו Runtime Plane?

ה-**Runtime Plane** (נקרא גם Data Plane) הוא המקום שבו ה-Agent **באמת עובד**. כאן קורים כל הדברים "החיים": קריאות ל-LLM, הרצת כלים, ניהול זיכרון, ובניית תשובות.

```mermaid
graph TB
    subgraph "אנלוגיה: מסעדה"
        Menu["📋 תפריט + הזמנה = Control Plane"]
        Kitchen["👨‍🍳 מטבח = Runtime Plane"]
        
        Menu -->|"מה הלקוח רוצה"| Kitchen
        Kitchen -->|"הארוחה מוכנה"| Plate["🍽️ צלחת ללקוח"]
    end
```

### בקצרה:
- **Control Plane** = "מה לעשות?" (הגדרות, Policies, Registry)
- **Runtime Plane** = "עושה את זה!" (הרצה, LLM calls, כלים)

---

## ההבדל בין Control ל-Runtime

| תכונה | 🎛️ Control Plane | ⚙️ Runtime Plane |
|--------|-----------------|-----------------|
| **מטרה** | ניהול והגדרות | הרצה ועיבוד |
| **תעבורה** | נמוכה (קונפיגורציה) | גבוהה (בקשות משתמשים) |
| **Latency דרוש** | לא קריטי (שניות OK) | קריטי (מילישניות) |
| **Scaling** | מינימלי | אגרסיבי (אלפי בקשות/שנייה) |
| **Stateful/Stateless** | בעיקר Stateless | Stateful (Thread, Memory) |
| **כשל** | "אי אפשר לנהל" | "Agents לא עובדים" |
| **דוגמאות** | Registry, IAM, Policy | Orchestrator, LLM calls, Tools |

---

## מחזור חיים של בקשה (Request Lifecycle)

הנה מה שקורה מהרגע שמשתמש שולח בקשה לAgent ועד שמקבל תשובה:

```mermaid
sequenceDiagram
    actor User as 👤 User
    participant GW as 🚪 Gateway
    participant Orch as 🎭 Orchestrator
    participant Mem as 💾 Memory
    participant LLM as 🧠 LLM
    participant Tool as 🔧 Tool
    participant State as 📌 State
    
    User->>GW: "נתח לי את דוח המכירות"
    GW->>Orch: Forward request + agent config
    
    Note over Orch: שלב 1: טעינת הקשר
    Orch->>Mem: Retrieve conversation history
    Mem-->>Orch: [previous messages]
    Orch->>State: Load agent state
    State-->>Orch: {step: 0, status: idle}
    
    Note over Orch: שלב 2: קריאה ל-LLM
    Orch->>LLM: System Prompt + History + User Message
    LLM-->>Orch: "I need to use sql_query tool"
    
    Note over Orch: שלב 3: הרצת כלי
    Orch->>Tool: sql_query("SELECT * FROM sales...")
    Tool-->>Orch: {results: [...data...]}
    
    Note over Orch: שלב 4: קריאה נוספת ל-LLM
    Orch->>LLM: "Here are the results: {...}"
    LLM-->>Orch: "המכירות עלו ב-15%..."
    
    Note over Orch: שלב 5: שמירה וחזרה
    Orch->>Mem: Save to conversation history
    Orch->>State: Update state {step: 2, status: complete}
    Orch-->>GW: Response
    GW-->>User: "המכירות עלו ב-15%..."
```

### מבנה ה-Request בכל שלב:

```
Request Lifecycle:
│
├── 1. 📥 RECEIVE
│   ├── Parse user input
│   ├── Identify target agent
│   └── Load agent configuration from Registry
│
├── 2. 📚 CONTEXT BUILDING
│   ├── Load conversation history (Short-term Memory)
│   ├── Retrieve relevant docs (Long-term Memory / RAG)
│   ├── Load agent state
│   └── Build full prompt
│
├── 3. 🧠 LLM INFERENCE
│   ├── Send prompt to Model Router
│   ├── Model Router selects best model
│   └── Get LLM response
│
├── 4. 🔍 PARSE & DECIDE
│   ├── Is it a final answer? → Go to step 6
│   ├── Is it a tool call? → Go to step 5
│   └── Is it a sub-agent call? → Spawn sub-agent
│
├── 5. 🔧 TOOL EXECUTION
│   ├── Validate tool is allowed (Policy check)
│   ├── Execute in sandbox
│   ├── Capture result
│   └── Go back to step 3 (with tool result)
│
└── 6. 📤 RESPOND
    ├── Format response
    ├── Save to memory
    ├── Update state
    ├── Log metrics (tokens, latency, cost)
    └── Return to user
```

---

## רכיבי ה-Runtime Plane

```mermaid
graph TB
    subgraph RP["⚙️ Runtime Plane"]
        Orch["🎭 Orchestrator\n(מנצח התזמורת)"]
        
        Orch --> ModelRouter["🧠 Model Router"]
        Orch --> MemMgr["💾 Memory Manager"]
        Orch --> ThreadMgr["🧵 Thread Manager"]
        Orch --> StateMgr["📌 State Manager"]
        Orch --> ToolExec["🔧 Tool Executor"]
        
        ModelRouter --> LLMs["☁️ LLM Providers"]
        ToolExec --> Sandbox["🔒 Secure Sandbox"]
        MemMgr --> VectorDB["Vector DB"]
        MemMgr --> Cache["Cache"]
        StateMgr --> StateDB["State Store"]
    end
```

| רכיב | תפקיד | פרק מורחב |
|------|--------|-----------|
| **Orchestrator** | מנהל את זרימת ההרצה, מחליט מתי לקרוא ל-LLM ומתי לכלי | פרק 7 |
| **Model Router** | בוחר איזה LLM להשתמש לכל בקשה | פרק 4 |
| **Memory Manager** | מנהל זיכרון קצר/ארוך טווח | פרק 5 |
| **Thread Manager** | מנהל שיחות ו-context | פרק 6 |
| **State Manager** | שומר מצב של workflows ארוכים | פרק 6 |
| **Tool Executor** | מריץ כלים בסביבה מאובטחת | פרק 8 |

---

## The Orchestrator

ה-Orchestrator הוא **הלב** של ה-Runtime Plane. הוא ה"מנצח" שמתאם בין כל הרכיבים.

### תפקידים:

```mermaid
graph TB
    Orch["🎭 Orchestrator"]
    
    Orch --> T1["📋 Plan\nלפרק משימה לשלבים"]
    Orch --> T2["🔄 Loop\nלנהל את לולאת Think-Act-Observe"]
    Orch --> T3["🔀 Route\nלהפנות לכלי, LLM, או Sub-Agent"]
    Orch --> T4["⏱️ Timeout\nלוודא שלא נתקעים"]
    Orch --> T5["🛡️ Guard\nלבדוק Policies לפני כל פעולה"]
    Orch --> T6["📊 Track\nלתעד כל צעד (Tracing)"]
```

### הלולאה הפנימית של ה-Orchestrator:

```mermaid
stateDiagram-v2
    [*] --> ReceiveInput
    ReceiveInput --> BuildContext: Load memory & state
    BuildContext --> CallLLM: Send prompt
    CallLLM --> ParseResponse
    
    ParseResponse --> ToolCall: LLM wants to use a tool
    ParseResponse --> SubAgent: LLM wants to delegate
    ParseResponse --> FinalAnswer: LLM has the answer
    
    ToolCall --> PolicyCheck: Validate permission
    PolicyCheck --> ExecuteTool: ✅ Allowed
    PolicyCheck --> Error: ❌ Denied
    ExecuteTool --> CallLLM: Feed result back
    
    SubAgent --> SpawnChild: Create sub-orchestrator
    SpawnChild --> WaitForChild
    WaitForChild --> CallLLM: Feed result back
    
    FinalAnswer --> SaveState: Update memory & state
    SaveState --> Respond
    Respond --> [*]
    
    Error --> Respond
    
    note right of CallLLM: Max iterations check
```

### Max Steps / Circuit Breaker

בעיה: מה אם ה-Agent נכנס ללולאה אינסופית?

```mermaid
graph TD
    A["Start"] --> B["Step 1"]
    B --> C["Step 2"]
    C --> D["Step 3"]
    D --> E{"Step > Max?"}
    E -->|"No"| F["Step 4..."]
    F --> E
    E -->|"Yes ⛔"| G["STOP: Max steps reached"]
    
    style G fill:#ff6b6b
```

| מנגנון הגנה | הסבר |
|-------------|-------|
| **Max Steps** | מספר מקסימלי של iterations (למשל 10) |
| **Timeout** | זמן מקסימלי להרצה (למשל 120 שניות) |
| **Token Budget** | מספר מקסימלי של tokens (למשל 50,000) |
| **Cost Budget** | עלות מקסימלית (למשל $0.50) |
| **Circuit Breaker** | אם שירות חיצוני כושל 3 פעמים, תפסיק לנסות |

---

## Execution Models

יש כמה דרכים שונות להריץ Agent. כל אחת מתאימה למקרה שימוש אחר:

### 1. Synchronous (סינכרוני)

```mermaid
sequenceDiagram
    User->>Agent: Request
    Note over Agent: Processing...<br/>(user waits)
    Agent-->>User: Response
```

| בעד | נגד |
|-----|-----|
| פשוט ליישום | המשתמש מחכה |
| קל לדבג | לא מתאים למשימות ארוכות |
| תשובה מיידית | Timeout ב-HTTP (30-60 sec) |

**מתאים ל:** שאלות מהירות, chat-style

### 2. Asynchronous (אסינכרוני)

```mermaid
sequenceDiagram
    User->>Agent: Request
    Agent-->>User: ✅ "Accepted" (job_id: 123)
    Note over Agent: Processing in background...
    
    User->>Agent: GET /status/123
    Agent-->>User: "In progress... step 3/5"
    
    User->>Agent: GET /status/123
    Agent-->>User: "Done! Here's the result"
```

| בעד | נגד |
|-----|-----|
| המשתמש לא מחכה | מורכבות גבוהה יותר |
| מתאים למשימות ארוכות | צריך מנגנון Polling/Webhook |
| אפשר לבטל | ניהול State מורכב |

**מתאים ל:** משימות מורכבות, דוחות, אנליזות

### 3. Streaming

```mermaid
sequenceDiagram
    User->>Agent: Request
    Agent-->>User: Token 1: "ה"
    Agent-->>User: Token 2: "מכירות"
    Agent-->>User: Token 3: " עלו"
    Agent-->>User: Token 4: " ב-15%"
    Agent-->>User: [DONE]
```

| בעד | נגד |
|-----|-----|
| תחושת מהירות (UX טוב) | מורכבות בצד Client |
| המשתמש רואה תוצאות תוך כדי | קשה לעבד Tool Calls |
| נמוך Memory footprint | Retry Logic מורכב |

**מתאים ל:** Chat UI, תשובות טקסטואליות ארוכות

---

## הרצה בטוחה - Sandboxing

### למה צריך Sandbox?

Agent יכול לייצר ולהריץ קוד. זה **מסוכן**:

```mermaid
graph TB
    Agent["🤖 Agent"] -->|"generates"| Code["🐍 Python Code"]
    Code --> Risk1["⚠️ os.system('rm -rf /')"]
    Code --> Risk2["⚠️ requests.get('https://evil.com')"]
    Code --> Risk3["⚠️ open('/etc/passwd')"]
    
    style Risk1 fill:#ff6b6b
    style Risk2 fill:#ff6b6b
    style Risk3 fill:#ff6b6b
```

### פתרון: Secure Sandbox

```mermaid
graph TB
    Agent["🤖 Agent"] -->|"code"| Sandbox
    
    subgraph Sandbox["🔒 Secure Sandbox"]
        Container["📦 Ephemeral Container"]
        Container --> Allow["✅ Read data\n✅ Run Python\n✅ Generate charts"]
        Container --> Block["❌ No network access\n❌ No filesystem access\n❌ No system commands"]
    end
    
    Sandbox -->|"result only"| Agent
```

### רמות בידוד (Isolation Levels)

```mermaid
graph TB
    subgraph "🔓 רמה 1: Process Isolation"
        P1["Agent runs in separate process"]
        P1 --> L1["⚠️ Low isolation"]
    end
    
    subgraph "🔒 רמה 2: Container Isolation"
        P2["Agent runs in Docker container"]
        P2 --> L2["✅ Good isolation"]
    end
    
    subgraph "🔐 רמה 3: VM / microVM Isolation"
        P3["Agent runs in lightweight VM"]
        P3 --> L3["✅✅ Strong isolation"]
    end
```

| רמה | טכנולוגיה | אבטחה | ביצועים | עלות |
|-----|-----------|--------|---------|------|
| **Process** | subprocess, fork | ⚠️ נמוכה | ⚡ מהיר | 💰 זול |
| **Container** | Docker, containerd | ✅ טובה | ⚡ מהיר | 💰 בינוני |
| **microVM** | Firecracker, gVisor | ✅✅ גבוהה | 🐌 איטי | 💰💰 יקר |
| **Ephemeral Session** | Azure Dynamic Sessions | ✅✅ גבוהה | ⚡ מהיר | 💰💰 בינוני |

### תכונות של Sandbox טוב:

| תכונה | הסבר |
|--------|-------|
| **Ephemeral** | נוצר ונהרס לכל הרצה - אין שאריות |
| **Resource Limits** | CPU, Memory, Disk מוגבלים |
| **Network Isolation** | אין גישה לרשת (או גישה מוגבלת) |
| **Filesystem Isolation** | אין גישה ל-filesystem של המארח |
| **Time Limit** | ההרצה מוגבלת בזמן |
| **Read-only** | ה-Agent יכול לקרוא אבל לא לכתוב |

---

## Scaling ב-Runtime Plane

ה-Runtime Plane הוא זה שצריך את ה-Scaling הכי אגרסיבי:

```mermaid
graph TB
    LB["⚖️ Load Balancer"]
    
    LB --> I1["Instance 1"]
    LB --> I2["Instance 2"]
    LB --> I3["Instance 3"]
    LB --> I4["Instance ...N"]
    
    subgraph "Auto Scaling"
        direction LR
        Low["📉 עומס נמוך\n1-2 instances"] --> Med["📊 עומס בינוני\n5-10 instances"]
        Med --> High["📈 עומס גבוה\n50+ instances"]
    end
```

### Stateless vs Stateful Scaling

| סוגי רכיבים | Scaling | הסבר |
|-------------|---------|-------|
| **Stateless** (API, Router) | קל | פשוט מוסיפים instances |
| **Stateful** (Memory, State) | מורכב | צריך shared storage או sticky sessions |

```mermaid
graph TB
    subgraph "Stateless - קל"
        R1["Request"] --> Any["Any Instance"]
        Any --> DB["Shared DB"]
    end
    
    subgraph "Stateful - מורכב"
        R2["Request for Thread-123"] --> Specific["Must go to Instance 2\n(has the state)"]
    end
```

**הפתרון:** externalize state

כל ה-state נשמר **מחוץ** ל-instance (ב-Redis, DB, etc.), כך שכל instance יכול לטפל בכל בקשה.

---

## יתרונות וחסרונות

### ✅ יתרונות

| יתרון | הסבר |
|-------|-------|
| **Decoupled** | כל רכיב עצמאי - קל להחליף/לשדרג |
| **Scalable** | כל רכיב scales בנפרד |
| **Observable** | ניתן למדוד כל שלב בזרימה |
| **Secure** | Sandbox isolates untrusted code |

### ❌ אתגרים

| אתגר | הסבר | פתרון |
|-------|------|-------|
| **Latency** | הרבה hops = latency | Optimize critical path, caching |
| **Complexity** | הרבה רכיביות | Good observability, testing |
| **State management** | Hard to scale stateful components | Externalize state |
| **Cost** | LLM calls are expensive | Model routing, caching |

---

## סיכום

```mermaid
mindmap
  root((Runtime Plane))
    Orchestrator
      Request Lifecycle
      Loop Management
      Circuit Breakers
    Execution Models
      Synchronous
      Asynchronous
      Streaming
    Components
      Model Router
      Memory Manager
      Thread Manager
      State Manager
      Tool Executor
    Security
      Sandboxing
      Isolation Levels
      Ephemeral Containers
    Scaling
      Horizontal
      Stateless design
      Externalized state
```

| מה למדנו | נקודה מרכזית |
|-----------|-------------|
| **Runtime Plane** | כאן ה-Agent באמת עובד - LLM calls, כלים, זיכרון |
| **Request Lifecycle** | Receive → Context → LLM → Parse → Tool/Answer → Save |
| **Orchestrator** | ה"מנצח" - מתאם בין כל הרכיבים |
| **Execution Models** | Sync (מהיר), Async (ארוך), Streaming (UX טוב) |
| **Sandbox** | סביבה מבודדת להרצת קוד שה-Agent מייצר |
| **Scaling** | Stateless components scale בקלות, Stateful דורש externalized state |

---

## ❓ שאלות לבדיקה עצמית

1. מה ההבדל העיקרי בין Control Plane ל-Runtime Plane?
2. תתאר את 6 השלבים במחזור חיים של בקשה.
3. מה תפקיד ה-Orchestrator?
4. למה צריך Circuit Breaker ומה הוא עושה?
5. מה ההבדל בין Sync, Async, ו-Streaming execution?
6. למה Agent צריך Sandbox וכמה רמות בידוד יש?
7. מה הבעיה עם Stateful components ב-Scaling ומה הפתרון?

---

**[⬅️ חזרה לפרק 2: Control Plane](02-control-plane.md)** | **[➡️ המשך לפרק 4: Model Abstraction & Routing →](04-model-abstraction-routing.md)**
