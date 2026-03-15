# 🛡️ פרק 9: Policy & Governance Engine

## תוכן עניינים
- [מה זה Policy Engine?](#מה-זה-policy-engine)
- [למה צריך Governance?](#למה-צריך-governance)
- [סוגי Policies](#סוגי-policies)
- [Policy Enforcement Points](#policy-enforcement-points)
- [Guardrails](#guardrails)
- [Content Safety](#content-safety)
- [Data Loss Prevention (DLP)](#data-loss-prevention-dlp)
- [Audit & Compliance](#audit--compliance)
- [יתרונות וחסרונות](#יתרונות-וחסרונות)
- [סיכום ושאלות](#סיכום-ושאלות)

---

## מה זה Policy Engine?

**Policy Engine** = מערכת כללים שמגדירה **מה מותר ומה אסור** ל-Agents לעשות.

```mermaid
graph LR
    Agent["🤖 Agent רוצה לעשות X"] --> Policy["🛡️ Policy Engine"]
    Policy -->|"✅ מותר"| Execute["▶️ Execute"]
    Policy -->|"❌ אסור"| Block["⛔ Block"]
    Policy -->|"⚠️ בתנאי"| Modify["🔄 Modify & Execute"]
```

### אנלוגיה:

```mermaid
graph TB
    subgraph "חברה אמיתית"
        Employee["👨‍💼 עובד"] --> Manager["👔 מנהל מאשר"]
        Manager --> Legal["⚖️ משפטי בודק"]
        Legal --> Compliance["📋 Compliance מוודא"]
    end
    
    subgraph "AI Agent Platform"
        Agent["🤖 Agent"] --> PolicyEng["🛡️ Policy Engine"]
        PolicyEng --> Rules["📜 Rules"]
        PolicyEng --> Guardrails["🚧 Guardrails"]
    end
```

---

## למה צריך Governance?

### בלי Governance:

```mermaid
graph TB
    Agent["🤖 Agent"] --> Bad1["📧 שלח מייל לכל החברה"]
    Agent --> Bad2["🗑️ מחק טבלה ב-DB"]
    Agent --> Bad3["💳 חשף מספרי כרטיסי אשראי"]
    Agent --> Bad4["🤬 כתב תוכן פוגעני"]
    Agent --> Bad5["💸 צרך $10,000 ב-tokens"]
    
    style Bad1 fill:#ff6b6b
    style Bad2 fill:#ff6b6b
    style Bad3 fill:#ff6b6b
    style Bad4 fill:#ff6b6b
    style Bad5 fill:#ff6b6b
```

### עם Governance:

```mermaid
graph TB
    Agent["🤖 Agent"] --> PolicEng["🛡️ Policy Engine"]
    
    PolicEng --> Check1["📧 מייל: רק לנמענים מורשים ✅"]
    PolicEng --> Check2["🗄️ DB: read-only ✅"]
    PolicEng --> Check3["🔒 PII: masked ✅"]
    PolicEng --> Check4["📝 Content: safe ✅"]
    PolicEng --> Check5["💰 Budget: within limit ✅"]
```

---

## סוגי Policies

### 1. Access Policies (מי מורשה)

```mermaid
graph TB
    subgraph "Access Policies"
        AP1["🔐 Authentication<br/>מי אתה?"]
        AP2["🔑 Authorization<br/>מה מותר לך?"]
        AP3["🔧 Tool Permissions<br/>אילו כלים?"]
        AP4["🧠 Model Access<br/>אילו מודלים?"]
    end
```

| Policy | דוגמה |
|--------|-------|
| Agent Access | "רק צוות Analytics יכול ליצור Data Agents" |
| Tool Access | "Agent הזה מורשה להשתמש רק ב-search ו-sql_read" |
| Model Access | "רק Agents מאושרים יכולים להשתמש ב-GPT-4o" |
| Data Access | "Agent רואה רק נתונים של ה-tenant שלו" |

### 2. Usage Policies (כמה מותר)

```mermaid
graph TB
    subgraph "Usage Policies"
        UP1["⏱️ Rate Limiting<br/>בקשות/דקה"]
        UP2["💰 Budget Limits<br/>תקציב/agent"]
        UP3["🔢 Token Limits<br/>tokens/בקשה"]
        UP4["⏰ Timeout<br/>זמן מקסימלי"]
        UP5["🔄 Max Steps<br/>מקסימום צעדים"]
    end
```

| Policy | דוגמה |
|--------|-------|
| Rate Limit | "מקסימום 100 בקשות/דקה per agent" |
| Budget | "מקסימום $50/יום per tenant" |
| Token Limit | "מקסימום 50K tokens per request" |
| Timeout | "Agent חייב לסיים תוך 120 שניות" |
| Max Steps | "מקסימום 10 tool calls per request" |

### 3. Content Policies (מה מותר לומר)

```mermaid
graph TB
    subgraph "Content Policies"
        CP1["🚫 Toxicity Filter<br/>תוכן פוגעני"]
        CP2["🔒 PII Detection<br/>מידע אישי"]
        CP3["📋 Topic Guard<br/>נושאים אסורים"]
        CP4["📝 Output Format<br/>פורמט נדרש"]
    end
```

### 4. Operational Policies (איך לפעול)

| Policy | דוגמה |
|--------|-------|
| Logging | "כל tool call חייב להתועד" |
| Approval | "שליחת מייל דורשת אישור אנושי" |
| Fallback | "אם Agent נכשל 3 פעמים, העבר לנציג" |
| SLA | "זמן תגובה מקסימלי: 5 שניות" |

---

## Policy Enforcement Points

### איפה אוכפים Policies?

```mermaid
graph TB
    User["👤 User"] --> GW["🚪 API Gateway<br/>⏱️ Rate Limiting<br/>🔐 Authentication"]
    
    GW --> PreExec["🛡️ Pre-Execution<br/>🔑 Authorization<br/>💰 Budget Check<br/>📋 Config Validation"]
    
    PreExec --> Runtime["⚙️ Runtime<br/>🔧 Tool Permissions<br/>🔢 Token Counting<br/>⏰ Timeout"]
    
    Runtime --> PostExec["🛡️ Post-Execution<br/>🔒 PII Scanning<br/>📝 Content Safety<br/>📊 Cost Logging"]
    
    PostExec --> Response["📤 Response"]
```

### Pre-Execution Policies (לפני הרצה):

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

### Runtime Policies (במהלך הרצה):

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

### Post-Execution Policies (אחרי הרצה):

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

### מה זה Guardrails?
**Guardrails** = מנגנוני הגנה שמוודאים שה-Agent נשאר "במסלול" ולא עושה דברים לא רצויים.

```mermaid
graph TB
    subgraph "🚧 Guardrails"
        Input_Guard["📥 Input Guardrails<br/>(על הקלט)"]
        Output_Guard["📤 Output Guardrails<br/>(על הפלט)"]
        Execution_Guard["⚙️ Execution Guardrails<br/>(על ההרצה)"]
    end
    
    User["👤 User Input"] --> Input_Guard
    Input_Guard --> Agent["🤖 Agent"]
    Agent --> Execution_Guard
    Execution_Guard --> Output_Guard
    Output_Guard --> Response["📤 Response"]
```

### Input Guardrails:

| Guardrail | מה בודק | דוגמה |
|-----------|---------|-------|
| **Prompt Injection Detection** | ניסיון לרמות את ה-Agent | "Ignore all previous instructions..." |
| **Topic Boundary** | שאלה מחוץ לתחום | Agent פיננסי שנשאל רפואי |
| **Language Detection** | שפה לא נתמכת | בקשה בשפה לא נתמכת |
| **Input Length** | קלט ארוך מדי | הגבלת אורך prompt |

### Output Guardrails:

| Guardrail | מה בודק | דוגמה |
|-----------|---------|-------|
| **PII Detection** | מידע אישי בפלט | מספרי ת"ז, כרטיסי אשראי |
| **Toxicity Filter** | תוכן פוגעני | גזענות, אלימות |
| **Hallucination Check** | עובדות שגויות | הצלבה עם מקורות |
| **Format Validation** | פלט בפורמט שגוי | JSON לא תקין |

### Execution Guardrails:

| Guardrail | מה בודק |
|-----------|---------|
| **Max Iterations** | Agent לא נתקע בלולאה |
| **Allowed Tools** | Agent משתמש רק בכלים מורשים |
| **Network Access** | Agent לא ניגש לכתובות אסורות |
| **Resource Limits** | CPU, Memory, Disk לא חורגים |

---

## Content Safety

### מה זה?
מנגנון שמוודא שהתוכן שה-Agent מייצר הוא **בטוח, מכבד, ולא מזיק**.

```mermaid
graph TB
    Content["📝 Agent Output"] --> CS["🛡️ Content Safety"]
    
    CS --> Cat1["🚫 Violence<br/>אלימות"]
    CS --> Cat2["🚫 Hate<br/>שנאה/גזענות"]
    CS --> Cat3["🚫 Sexual<br/>תוכן מיני"]
    CS --> Cat4["🚫 Self-harm<br/>פגיעה עצמית"]
    CS --> Cat5["🚫 Misinformation<br/>מידע שגוי"]
    
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

### מה זה?
**DLP** = מניעת דליפת מידע רגיש. לוודא שה-Agent לא מגלה:
- מספרי כרטיסי אשראי
- מספרי ת"ז / SSN
- סיסמאות
- מידע רפואי
- מידע עסקי סודי

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

| אסטרטגיה | הסבר | מתי |
|-----------|-------|-----|
| **Block** | חסום את התשובה לחלוטין | PII חמור (SSN, credit card) |
| **Mask** | מסך את המידע הרגיש | שמות, כתובות |
| **Tokenize** | החלף בטוקן מוצפן | מזהים פנימיים |
| **Log & Alert** | תעד ושלח התראה | לא חוסם, אבל מתריע |

---

## Audit & Compliance

### מה זה Audit Trail?
תיעוד של **כל פעולה** שכל Agent ביצע - מי, מה, מתי, ולמה.

```mermaid
graph TB
    subgraph "📋 Audit Log"
        E1["2026-02-21 10:00:01<br/>Agent: data-analyst<br/>Action: sql_query<br/>User: roi<br/>Result: success"]
        E2["2026-02-21 10:00:05<br/>Agent: data-analyst<br/>Action: llm_call<br/>Model: gpt-4o<br/>Tokens: 1,523"]
        E3["2026-02-21 10:00:07<br/>Agent: data-analyst<br/>Action: send_email<br/>Status: BLOCKED by policy<br/>Reason: missing approval"]
    end
```

### Compliance Requirements:

| תקן | הסבר | דרישות עיקריות |
|------|-------|---------------|
| **GDPR** | הגנת מידע אירופי | Right to be forgotten, consent |
| **SOC 2** | אבטחת מידע | Logging, access control |
| **HIPAA** | מידע רפואי | Encryption, audit trail |
| **PCI-DSS** | כרטיסי אשראי | PII masking, encryption |

### Policy as Code

כמו Infrastructure as Code, גם Policies צריכים להיות **מוגדרים כקוד**:

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

## יתרונות וחסרונות

| ✅ יתרון | ❌ חיסרון |
|----------|----------|
| מניעת שימוש לא מורשה | Latency נוסף (policy checking) |
| שליטה בעלויות | מורכבות בניהול rules |
| Compliance אוטומטי | False positives (חוסם דברים לגיטימיים) |
| Audit trail מלא | צריך עדכון שוטף |
| הגנה מפני PII leaks | User experience - Agent מוגבל |
| Consistent enforcement | Policy conflicts |

---

## סיכום

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

| מה למדנו | נקודה מרכזית |
|-----------|-------------|
| **Policy Engine** | מערכת כללים שקובעת מה מותר ומה אסור |
| **Guardrails** | Input, Output, Execution - שלוש שכבות הגנה |
| **Content Safety** | סינון תוכן פוגעני |
| **DLP** | מניעת דליפת מידע רגיש (PII) |
| **Audit Trail** | תיעוד של כל פעולה לצרכי Compliance |
| **Policy as Code** | Policies מוגדרים כקוד, לא ידנית |

---

## ❓ שאלות לבדיקה עצמית

1. מהם 4 הסוגים של Policies?
2. מה ההבדל בין Pre-Execution ל-Post-Execution policy?
3. מה זה Guardrails ואילו 3 סוגים יש?
4. מה זה Prompt Injection ואיך מתגוננים?
5. מה זה DLP ואילו אסטרטגיות טיפול יש (Block, Mask, etc.)?
6. למה Audit Trail חשוב?
7. מה זה Policy as Code ולמה זה עדיף על הגדרה ידנית?

---

### 📝 תשובות

<details>
<summary>1. מהם 4 הסוגים של Policies?</summary>

1. **Safety Policies** - מניעות תוכן מזיק/אלים/מסוכן.
2. **Compliance Policies** - עמידה ברגולציה (GDPR, HIPAA).
3. **Business Policies** - כללי עסקיים (תקציב, עלות מקס).
4. **Operational Policies** - rate limiting, ניטור משאבים.
</details>

<details>
<summary>2. מה ההבדל בין Pre-Execution ל-Post-Execution policy?</summary>

**Pre-Execution** = נבדק **לפני** שהבקשה מגיעה ל-LLM. למשל: סינון prompt injection, בדיקת PII בקלט. אם נכשל → הבקשה נחסמת. **Post-Execution** = נבדק **אחרי** שה-LLM מחזיר תשובה. למשל: בדיקת PII בתשובה, content safety, groundedness check.
</details>

<details>
<summary>3. מה זה Guardrails ואילו 3 סוגים יש?</summary>

**Guardrails** = "גדרות בטיחות" שמונעות מה-Agent לסטות מהמסלול. 3 סוגים: (1) **Input Guardrails** - סינון ווידוא של הקלט, (2) **Output Guardrails** - סינון תשובת ה-LLM, (3) **Topical Guardrails** - מניעות מה-Agent לצאת מהתחום ("אל תענה על פוליטיקה").
</details>

<details>
<summary>4. מה זה Prompt Injection ואיך מתגוננים?</summary>

**Prompt Injection** = תוקף מזריק הוראות בקלט שמתחזות להיות system prompt ("ignore all previous instructions"). הגנה: (1) **Input Validation** - זיהוי דפוסים, (2) **Prompt Sandboxing** - הפרדה בין system ל-user, (3) **Classifier Models** - מודל נפרד שמזהה injection.
</details>

<details>
<summary>5. מה זה DLP ואילו אסטרטגיות טיפול יש?</summary>

**DLP (Data Loss Prevention)** = מניעת דליפת מידע רגיש (PII, סודות, כרטיסי אשראי). אסטרטגיות: (1) **Block** - חוסם לגמרי אם יש PII, (2) **Mask** - מחליף בכוכביות ("***-**-1234"), (3) **Tokenize** - מחליף ב-token ומחזיר אחרי עיבוד, (4) **Log & Alert** - מרשה אבל מתיבות.
</details>

<details>
<summary>6. למה Audit Trail חשוב?</summary>

**Audit Trail** = תיעוד מלא של כל פעולה שה-Agent עשה (מי, מה, מתי, תוצאה). חשוב ל: (1) **רגולציה** - GDPR/HIPAA דורשים תיעוד, (2) **Debug** - להבין איפה Agent הגיע להחלטה, (3) **אחריות** - לדעת מי עשה מה, (4) **שיפור** - זיהוי שימוש לרעה.
</details>

<details>
<summary>7. מה זה Policy as Code ולמה זה עדיף על הגדרה ידנית?</summary>

**Policy as Code** = הגדרת policies בקוד (YAML/JSON/Rego) במקום UI ידני. עדיף כי: (1) **Version Control** - נשמר ב-Git, יש היסטוריה ו-rollback, (2) **CI/CD** - נבדק אוטומטית ב-pipeline, (3) **Reproducibility** - אותו policy בכל הסביבות, (4) **Automation** - אין טעויות אנוש.
</details>

---

**[⬅️ חזרה לפרק 8: Tools](08-tools-marketplace.md)** | **[➡️ המשך לפרק 10: Evaluation Engine →](10-evaluation-engine.md)**
