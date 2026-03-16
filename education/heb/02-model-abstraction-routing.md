# 🧠 פרק 2: Model Abstraction & Multi-Model Routing

## תוכן עניינים
- [למה צריך שכבת הפשטה?](#למה-צריך-שכבת-הפשטה)
- [Model Abstraction Layer](#model-abstraction-layer)
- [Multi-Model Routing](#multi-model-routing)
- [אסטרטגיות Routing](#אסטרטגיות-routing)
- [Fallback & Retry](#fallback--retry)
- [Load Balancing בין מודלים](#load-balancing-בין-מודלים)
- [Caching של תשובות](#caching-של-תשובות)
- [השוואת מודלים](#השוואת-מודלים)
- [יתרונות וחסרונות](#יתרונות-וחסרונות)
- [סיכום ושאלות](#סיכום-ושאלות)

---

## למה צריך שכבת הפשטה?


### תרחיש מהעולם האמיתי: קריסה ב-Black Friday
דמיינו שאפליקציית האיקומרס שלכם מסתמכת באופן מוחלט על ה-API של OpenAI. מגיע יום שישי השחור (Black Friday), הטראפיק בשיאו, ולפתע השרתים של OpenAI קורסים במפתיע.
אם הקוד שלכם מכיל `import openai` שמפוזר ב-50 מיקרו-סרביסים שונים, הגירה למודל מחרה כמו Claude של Anthropic כדי להציל את המצב תיקח שבועות של עבודת פיתוח.
אבל, אם יש לכם **שכבת הפשטה (Abstraction Layer)**, לא תצטרכו לשנות שורת קוד אחת. פשוט תשנו הגדרה אחת ב-Control Plane: `DEFAULT_MODEL="claude-3-5-sonnet"`, והמערכת תחזור לאוויר תוך שניות. זה מה שמונע **נעילת ספק (Vendor Lock-in)**.

### הבעיה: כל ספק LLM שונה

כל ספק (OpenAI, Anthropic, Meta, Google) מציע API שונה:

```mermaid
graph TB
    subgraph "❌ בלי הפשטה"
        Agent1["Agent"] --> OpenAI["OpenAI API<br/>(format A)"]
        Agent2["Agent"] --> Anthropic["Anthropic API<br/>(format B)"]
        Agent3["Agent"] --> Google["Google API<br/>(format C)"]
        
        Note1["כל Agent צריך לדעת<br/>את כל הפורמטים 😩"]
    end
```

```mermaid
graph TB
    subgraph "✅ עם הפשטה"
        Agent4["Agent"] --> Abstract["🧠 Abstraction Layer<br/>(unified API)"]
        Abstract --> OpenAI2["OpenAI"]
        Abstract --> Anthropic2["Anthropic"]
        Abstract --> Google2["Google"]
        
        Note2["ה-Agent מדבר פורמט אחד ✅"]
    end
```

### דוגמה קונקרטית לבעיה:

| ספק | פורמט Request | Tool Calling | Streaming |
|-----|--------------|-------------|-----------|
| **OpenAI** | `messages: [{role, content}]` | `tools: [{function}]` | SSE events |
| **Anthropic** | `messages: [{role, content}]` | `tools: [{name, input_schema}]` | SSE (different format) |
| **Google** | `contents: [{parts}]` | `function_declarations` | Server-sent events |

ה-Agent לא צריך להכיר את כל ההבדלים האלה. שכבת ההפשטה מסתירה אותם.

---

## Model Abstraction Layer

### מה זה?
שכבה שמספקת **Interface אחיד** לכל ה-LLMs. לא משנה איזה מודל מאחורה, ה-Agent שולח בפורמט אחד.

```mermaid
graph TB
    subgraph "🧠 Model Abstraction Layer"
        Interface["Unified Interface"]
        Adapter1["OpenAI Adapter"]
        Adapter2["Anthropic Adapter"]
        Adapter3["Local Model Adapter"]
        Adapter4["Azure OpenAI Adapter"]
        
        Interface --> Adapter1
        Interface --> Adapter2
        Interface --> Adapter3
        Interface --> Adapter4
    end
    
    Adapter1 --> OpenAI["OpenAI API"]
    Adapter2 --> Anthropic["Anthropic API"]
    Adapter3 --> Local["Ollama / vLLM"]
    Adapter4 --> Azure["Azure OpenAI"]
```

### Adapter Pattern (דפוס עיצוב)

ה-Abstraction Layer משתמש בדפוס **Adapter**:

```mermaid
classDiagram
    class ModelInterface {
        <<interface>>
        +chat(messages, tools, config) Response
        +stream(messages, tools, config) Stream
        +embed(text) Vector
    }
    
    class OpenAIAdapter {
        +chat() Response
        +stream() Stream
        +embed() Vector
        -convertMessages()
        -convertTools()
    }
    
    class AnthropicAdapter {
        +chat() Response
        +stream() Stream
        +embed() Vector
        -convertMessages()
        -convertTools()
    }
    
    class LocalModelAdapter {
        +chat() Response
        +stream() Stream
        +embed() Vector
        -convertMessages()
    }
    
    ModelInterface <|.. OpenAIAdapter
    ModelInterface <|.. AnthropicAdapter
    ModelInterface <|.. LocalModelAdapter
```

### מה ה-Adapter עושה:
1. **Input Translation** - ממיר את הפורמט האחיד לפורמט של הספק
2. **Output Normalization** - ממיר את התשובה חזרה לפורמט אחיד
3. **Error Handling** - מטפל בשגיאות ספציפיות לספק
4. **Feature Detection** - יודע אילו יכולות המודל תומך (function calling, vision, etc.)

---

## Multi-Model Routing

### מה זה?
**Model Router** הוא הרכיב שמחליט **לאיזה מודל** לשלוח כל בקשה. לא כל משימה צריכה את המודל הכי חזק (ויקר).

```mermaid
graph TB
    Request["📨 בקשה"] --> Router["🔀 Model Router"]
    
    Router -->|"משימה פשוטה<br/>(סיכום, תרגום)"| Small["GPT-3.5 / Llama<br/>💰 #36;0.001"]
    Router -->|"משימה מורכבת<br/>(reasoning, קוד)"| Large["GPT-4o<br/>💰 #36;0.01"]
    Router -->|"משימת Vision<br/>(תמונות)"| Vision["GPT-4o Vision<br/>💰 #36;0.02"]
    Router -->|"Embedding<br/>(חיפוש סמנטי)"| Embed["Ada / text-embedding<br/>💰 #36;0.0001"]
```

### למה לא פשוט להשתמש תמיד במודל הכי טוב?

| מודל | איכות | מהירות | עלות ל-1M tokens |
|------|--------|--------|-----------------|
| **GPT-4o** | ⭐⭐⭐⭐⭐ | 🐌 | $5.00 |
| **GPT-4o-mini** | ⭐⭐⭐⭐ | ⚡ | $0.15 |
| **GPT-3.5** | ⭐⭐⭐ | ⚡⚡ | $0.50 |
| **Llama 3 (self-hosted)** | ⭐⭐⭐ | ⚡ | $0.00 (infra costs) |

> **מסקנה:** אם 80% מהבקשות הן פשוטות, אפשר לחסוך הרבה כסף על ידי ניתוב חכם!

---

## אסטרטגיות Routing

### 1. Content-Based Routing (לפי תוכן)

```mermaid
graph TD
    Request["📨 Request"] --> Classify["🏷️ Classify Task"]
    
    Classify -->|"Simple Q&A"| Small["GPT-3.5"]
    Classify -->|"Code Generation"| Code["GPT-4o"]
    Classify -->|"Math/Logic"| Math["GPT-4o"]
    Classify -->|"Summarization"| Med["GPT-4o-mini"]
    Classify -->|"Translation"| Small
```

**איך מסווגים?**
- Classifier קטן (LLM קטן או regex)
- לפי הכלים שה-Agent משתמש
- לפי keywords ב-prompt

| בעד | נגד |
|-----|-----|
| ✅ חיסכון משמעותי | ❌ הסיווג עצמו לוקח זמן |
| ✅ כל משימה מקבלת מודל מתאים | ❌ סיווג שגוי = תשובה גרועה |

### 2. Cost-Based Routing (לפי עלות)

```mermaid
graph TD
    Request["📨 Request"] --> Budget{"💰 Budget left?"}
    Budget -->|"Yes, >#36;1"| Best["GPT-4o"]
    Budget -->|"#36;0.10-#36;1"| Medium["GPT-4o-mini"]
    Budget -->|"<#36;0.10"| Cheap["GPT-3.5"]
    Budget -->|"#36;0"| Reject["❌ Budget exceeded"]
```

| בעד | נגד |
|-----|-----|
| ✅ שליטה מלאה בעלויות | ❌ איכות עלולה לרדת |
| ✅ אכיפת budget per-agent | ❌ לא תמיד הסכום מייצג את הצורך |

### 3. Latency-Based Routing (לפי מהירות)

```mermaid
graph TD
    Request["📨 Request"] --> Check{"⏱️ Latency requirement?"}
    Check -->|"<1 sec (real-time)"| Fast["GPT-3.5<br/>(fast)"]
    Check -->|"<5 sec (interactive)"| Medium["GPT-4o-mini"]
    Check -->|"<30 sec (batch)"| Slow["GPT-4o<br/>(thorough)"]
```

### 4. Capability-Based Routing (לפי יכולות)

```mermaid
graph TD
    Request["📨 Request"] --> Check{"🔍 What's needed?"}
    Check -->|"Text only"| Text["Any model"]
    Check -->|"Image analysis"| Vision["Vision-capable model"]
    Check -->|"Function Calling"| FC["FC-capable model"]
    Check -->|"JSON output"| JSON["JSON-mode model"]
    Check -->|"Very long context"| Long["128K+ context model"]
```

### 5. Hybrid Routing (שילוב)

בפרקטיקה, משלבים מספר אסטרטגיות:

```mermaid
graph TD
    Request["📨 Request"] --> Cap["1. יכולת נדרשת?"]
    Cap -->|"Vision needed"| V["Vision Model"]
    Cap -->|"Text"| Cost["2. בדיקת Budget"]
    Cost -->|"Budget OK"| Complex["3. מורכבות"]
    Complex -->|"Complex"| Big["GPT-4o"]
    Complex -->|"Simple"| Small["GPT-4o-mini"]
    Cost -->|"Low budget"| Cheap["GPT-3.5"]
```

---

## Fallback & Retry

### מה קורה כשמודל לא זמין?

```mermaid
sequenceDiagram
    participant Agent
    participant Router as 🔀 Router
    participant Primary as 🧠 GPT-4o (Primary)
    participant Fallback1 as 🧠 GPT-4o-mini (Fallback 1)
    participant Fallback2 as 🧠 Llama 3 (Fallback 2)
    
    Agent->>Router: Request
    Router->>Primary: Send
    Primary-->>Router: ❌ 429 Rate Limited
    
    Note over Router: Retry with backoff...
    Router->>Primary: Retry
    Primary-->>Router: ❌ 429 Still rate limited
    
    Note over Router: Switch to fallback
    Router->>Fallback1: Send
    Fallback1-->>Router: ✅ Response
    Router-->>Agent: Response (from fallback)
```

### Retry Strategies

```mermaid
graph LR
    subgraph "Exponential Backoff"
        R1["Attempt 1<br/>(wait 1s)"] --> R2["Attempt 2<br/>(wait 2s)"]
        R2 --> R3["Attempt 3<br/>(wait 4s)"]
        R3 --> R4["Attempt 4<br/>(wait 8s)"]
        R4 --> Fail["❌ Give up"]
    end
```

| אסטרטגיית Retry | הסבר | מתי להשתמש |
|-----------------|-------|-----------|
| **Fixed delay** | מחכה X שניות בין ניסיונות | שגיאות זמניות קצרות |
| **Exponential backoff** | מכפיל את זמן ההמתנה | Rate limiting (429) |
| **Jitter** | מוסיף אקראיות לזמן ההמתנה | כשהרבה clients עושים retry |
| **Circuit breaker** | מפסיק לנסות לגמרי | כשהשירות נפל לגמרי |

### Fallback Chain

```
Primary: GPT-4o (Azure East US)
    ↓ (if fails)
Fallback 1: GPT-4o (Azure West Europe)
    ↓ (if fails)
Fallback 2: GPT-4o-mini (Azure East US)
    ↓ (if fails)
Fallback 3: Local Llama 3
    ↓ (if fails)
Error: "Service temporarily unavailable"
```

---

## Load Balancing בין מודלים

כשיש הרבה deployments של אותו מודל, צריך **לפזר עומס**:

```mermaid
graph TB
    Router["🔀 Router"] --> LB["⚖️ Load Balancer"]
    
    LB -->|"33%"| D1["GPT-4o<br/>Deployment 1<br/>(East US)"]
    LB -->|"33%"| D2["GPT-4o<br/>Deployment 2<br/>(West EU)"]
    LB -->|"34%"| D3["GPT-4o<br/>Deployment 3<br/>(Japan)"]
```

### אלגוריתמי Load Balancing:

| אלגוריתם | הסבר | בעד | נגד |
|-----------|-------|-----|-----|
| **Round Robin** | מחלק לפי תור | פשוט | לא מתחשב בעומס |
| **Least Connections** | שולח לזה עם הכי פחות בקשות פתוחות | מתחשב בעומס | צריך tracking |
| **Weighted** | לפי משקלים (deployment חזק = יותר בקשות) | גמיש | צריך כיול |
| **Latency-based** | שולח לזה עם ה-latency הנמוך ביותר | מהירות | צריך monitoring |
| **Token-aware** | מתחשב ב-RPM/TPM limits של כל deployment | מנצל TPM limits טוב | מורכב |

---

## Caching של תשובות

### למה Caching?
אם אותה שאלה חוזרת, למה לשלם שוב על LLM call?

```mermaid
graph TD
    Request["📨 'מה שעות הפעילות?'"] --> Cache{"🔍 בCache?"}
    Cache -->|"Hit ✅"| Return["החזר תשובה שמורה<br/>⚡ 5ms | 💰 #36;0"]
    Cache -->|"Miss ❌"| LLM["קרא ל-LLM<br/>🐌 500ms | 💰 #36;0.01"]
    LLM --> Save["שמור ב-Cache"]
    Save --> Return2["החזר תשובה"]
```

### סוגי Cache:

| סוג | הסבר | Hit Rate | מורכבות |
|-----|-------|----------|---------|
| **Exact Match** | אותה שאלה בדיוק | נמוך | פשוט |
| **Semantic Cache** | שאלות דומות (embedding similarity) | גבוה | מורכב |
| **Prompt Cache** | Cache של system prompt (prefix) | גבוה | בינוני |

### Semantic Cache - דוגמה:

```
Query 1: "What are your business hours?"
Query 2: "When are you open?"
Query 3: "What time do you close?"

→ כולם דומים סמנטית → אותה תשובה מה-Cache!
```

### מתי **לא** לעשות Cache:
- ❌ שאלות שדורשות נתונים עדכניים ("מה מזג האוויר?")
- ❌ שאלות פרסונליות ("מה הקניות שלי?")
- ❌ Agent שחייב tool execution
- ❌ תשובות שתלויות ב-context רנדומלי

---

## השוואת מודלים

### ציר האיכות-עלות-מהירות:

```mermaid
quadrantChart
    title Model Comparison: Quality vs Cost
    x-axis Low Cost --> High Cost
    y-axis Low Quality --> High Quality
    quadrant-1 Best (but expensive)
    quadrant-2 Ideal
    quadrant-3 Budget
    quadrant-4 Avoid
    GPT-4o: [0.8, 0.9]
    GPT-4o-mini: [0.3, 0.75]
    GPT-3.5: [0.15, 0.5]
    Llama-3-70B: [0.4, 0.7]
    Llama-3-8B: [0.1, 0.4]
    Claude-Opus: [0.9, 0.95]
    Claude-Sonnet: [0.5, 0.85]
```

### טבלת השוואה מפורטת:

| קריטריון | כשלבחור מודל גדול | כשלבחור מודל קטן |
|-----------|-------------------|-------------------|
| **Complex reasoning** | ✅ | ❌ |
| **Simple Q&A** | Overkill | ✅ |
| **Code generation** | ✅ | ⚠️ |
| **Summarization** | Overkill | ✅ |
| **Translation** | Overkill | ✅ |
| **Math / Logic** | ✅ | ❌ |
| **High volume** | 💸 Expensive | ✅ |
| **Low latency** | 🐌 Slower | ✅ |

---


## נוף התעשייה: הפשטה וניתוב בייצור (Industry Tools)

כיום, אף חברה לא כותבת את שכבת ההפשטה מאפס. קיימים כלים מוכנים בשוק:

| כלי / ספרייה | הבעיה שהוא פותר | למה משתמשים בו בתעשייה |
|--------------|-----------------|-------------------------|
| **LiteLLM** | מתרגם מעל 100 APIs של ספקים שונים לפורמט סטנדרטי אחד (של OpenAI) | שומר על תאימות לאחור, קל להחלפת מודלים מיידית, מובנה בפייתון |
| **LangChain** | כולל שכבת `BaseChatModel` שמספקת עטיפה אחידה | מאפשר החלפה חלקה בין `ChatOpenAI` ל-`ChatAnthropic` |
| **Semantic Router** | כלי ניתוב מבוסס משמעות | מנתב בקשות עזר למודל קטן ובקשות תכנות למודל פיתוח |
| **Azure AI AI Foundry / Model Catalog** | שכבת הפשטה מנוהלת בענן | מספקת גישה אחידה למודלי OpenAI, Meta, Mistral תחת אותו API ברמת האנטרפרייז |

## יתרונות וחסרונות

### ✅ יתרונות של Model Abstraction + Routing

| יתרון | הסבר |
|-------|-------|
| **Vendor Independence** | לא נעולים בספק אחד |
| **Cost Optimization** | כל משימה מגיעה למודל המתאים (ולא ליקר ביותר) |
| **Resilience** | אם מודל אחד נפל, יש Fallback |
| **Flexibility** | קל להוסיף/להחליף מודלים |
| **A/B Testing** | קל לבדוק מודלים חדשים על production traffic |

### ❌ אתגרים

| אתגר | פתרון |
|-------|-------|
| Routing logic מורכב | התחל עם כללים פשוטים, הוסף מורכבות בהדרגה |
| Latency נוסף (classification) | Cache classification results |
| Inconsistency בין מודלים | Evaluation Engine (פרק 10) |
| Semantic Cache accuracy | טיונינג של similarity threshold |

---

## סיכום

```mermaid
mindmap
  root((Model Layer))
    Abstraction
      Unified Interface
      Adapter Pattern
      Provider Agnostic
    Routing
      Content-based
      Cost-based
      Latency-based
      Capability-based
      Hybrid
    Resilience
      Fallback Chains
      Retry + Backoff
      Circuit Breaker
    Optimization
      Load Balancing
      Caching
      Semantic Cache
```

| מה למדנו | נקודה מרכזית |
|-----------|-------------|
| **Abstraction Layer** | Interface אחיד לכל ה-LLMs - Adapter Pattern |
| **Model Router** | מחליט לאיזה מודל לשלוח כל בקשה |
| **Routing Strategies** | Content, Cost, Latency, Capability, Hybrid |
| **Fallback** | Chain של מודלים חלופיים במקרה של כשל |
| **Load Balancing** | פיזור עומס בין deployments (Round Robin, Least Connections) |
| **Caching** | Exact Match / Semantic Cache לחיסכון בעלויות |

---

## ❓ שאלות לבדיקה עצמית

1. למה צריך שכבת הפשטה מעל ה-LLMs?
2. מהו ה-Adapter Pattern ואיך הוא עוזר כאן?
3. תתאר 3 אסטרטגיות Routing שונות ואיך הן עובדות.
4. מה ההבדל בין Fallback ל-Retry?
5. מה זה Exponential Backoff עם Jitter ולמה זה חשוב?
6. מה ההבדל בין Exact Match Cache ל-Semantic Cache?
7. מתי **לא** כדאי לעשות Cache?
8. איזה מודל תבחר לכל משימה: סיכום דוח, פתרון בעיית קוד, תרגום, שיחת חולין?

---

### 📝 תשובות

<details>
<summary>1. למה צריך שכבת הפשטה מעל ה-LLMs?</summary>

בלי הפשטה, הקוד צמוד לספק אחד (OpenAI/Anthropic). שכבת הפשטה מאפשרת: (1) **החלפת ספק** בלי לשנות קוד, (2) **routing חכם** בין מודלים, (3) **fallback** אוטומטי אם ספק לא זמין, (4) **ממשק אחיד** לכל המודלים.
</details>

<details>
<summary>2. מהו ה-Adapter Pattern ואיך הוא עוזר כאן?</summary>

**Adapter Pattern** = Design Pattern שמתרגם ממשק אחד לאחר. כאן: כל LLM provider יש לו API שונה, אז יוצרים **Adapter** לכל ספק (OpenAIAdapter, AnthropicAdapter) שממיר את הבקשה לפורמט של אותו ספק. האפליקציה מדברת עם ממשק אחד אחיד → ה-Adapter מתרגם.
</details>

<details>
<summary>3. תתאר 3 אסטרטגיות Routing שונות.</summary>

1. **Content-Based** - לפי סוג המשימה: קוד → Claude, שיחה → GPT-4o-mini.
2. **Cost-Based** - מנסה קודם מודל זול, ואם לא מצליח → מודל יקר.
3. **Latency-Based** - בוחר את המודל עם זמן התגובה הנמוך ביותר כרגע.
</details>

<details>
<summary>4. מה ההבדל בין Fallback ל-Retry?</summary>

**Retry** = ניסיון חוזר **לאותו** ספק/מודל (אולי היתה בעיה זמנית). **Fallback** = מעבר ל**ספק/מודל אחר** (כי הספק הראשי לא זמין או נכשל ה-retry). Retry → אותו מודל שוב. Fallback → מודל אחר.
</details>

<details>
<summary>5. מה זה Exponential Backoff עם Jitter ולמה זה חשוב?</summary>

**Exponential Backoff** = ההמתנה בין retries גדלה: 1s → 2s → 4s → 8s. מונע הצפה של ספק שכבר עמוס. **Jitter** = הוספת רנדומיות קטנה לזמן ההמתנה. מונע מצב שהרבה clients עושים retry בדיוק באותו רגע ("thundering herd").
</details>

<details>
<summary>6. מה ההבדל בין Exact Match Cache ל-Semantic Cache?</summary>

**Exact Match** = Cache hit רק אם הפרומפט **זהה לחלוטין** (character by character). הרבה misses. **Semantic Cache** = Cache hit אם הפרומפט **דומה משמעותית** (embedding similarity > threshold). "What are Q3 sales?" ≈ "Q3 sales numbers?" → cache hit. יותר hits, אבל דורש חישוב embedding.
</details>

<details>
<summary>7. מתי לא כדאי לעשות Cache?</summary>

- כשהתשובה צריכה להיות **עדכנית** (real-time data).
- כש-**temperature > 0** ורוצים תשובות מגוונות.
- כשיש **PII** בתשובה (סיכון אבטחה).
- כשהקלט **ייחודי מאוד** (cache hit rate נמוך).
</details>

<details>
<summary>8. איזה מודל תבחר לכל משימה?</summary>

- **סיכום דוח** → GPT-4o-mini (פשוט, זול, מהיר).
- **פתרון בעיית קוד** → Claude 3.5 Sonnet / GPT-4o (דורש reasoning חזק).
- **תרגום** → GPT-4o-mini (משימה סטנדרטית, חסכוני).
- **שיחת חולין** → GPT-4o-mini (לא צריך מודל חזק, חשוב שיהיה מהיר וזול).
</details>

---

**[⬅️ חזרה לפרק 1: מושגי יסוד](01-fundamentals.md)** | **[➡️ המשך לפרק 3: Memory Management & RAG →](03-memory-management.md)**
