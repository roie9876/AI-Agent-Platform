# 📊 פרק 10: Evaluation Engine

## תוכן עניינים
- [מה זה Evaluation Engine?](#מה-זה-evaluation-engine)
- [למה צריך הערכה?](#למה-צריך-הערכה)
- [סוגי מדדים (Metrics)](#סוגי-מדדים)
- [Groundedness](#groundedness)
- [Relevance & Coherence](#relevance--coherence)
- [Toxicity & Safety](#toxicity--safety)
- [Task Completion](#task-completion)
- [שיטות הערכה](#שיטות-הערכה)
- [Evaluation Pipeline](#evaluation-pipeline)
- [A/B Testing](#ab-testing)
- [יתרונות וחסרונות](#יתרונות-וחסרונות)
- [סיכום ושאלות](#סיכום-ושאלות)

---

## מה זה Evaluation Engine?

**Evaluation Engine** = מערכת שבודקת **באיזו מידה ה-Agent עושה עבודה טובה**.

```mermaid
graph LR
    Agent["🤖 Agent<br/>Output"] --> Eval["📊 Evaluation<br/>Engine"]
    Eval --> Report["📋 Quality Report<br/>- Accuracy: 92%<br/>- Relevance: 87%<br/>- Safety: 100%"]
```

### אנלוגיה:

```mermaid
graph TB
    subgraph "בית ספר"
        Student["🎓 תלמיד"] --> Exam["📝 מבחן"]
        Exam --> Grade["💯 ציון"]
        Grade --> Improve["📈 שיפור"]
    end
    
    subgraph "AI Agent Platform"
        Agent["🤖 Agent"] --> EvalEng["📊 Evaluation"]
        EvalEng --> Metrics["📋 Metrics"]
        Metrics --> Optimize["📈 Optimize"]
    end
```

---

## למה צריך הערכה?

```mermaid
graph TD
    subgraph "בלי Evaluation"
        A1["🤖 Agent deployed"] --> A2["🤷 עובד? לא יודע"]
        A2 --> A3["😱 לקוח מתלונן"]
        A3 --> A4["🔥 כיבוי שריפות"]
    end
    
    subgraph "עם Evaluation"
        B1["🤖 Agent developed"] --> B2["📊 Evaluated"]
        B2 --> B3["📈 Metrics tracked"]
        B3 --> B4["✅ Confident deployment"]
    end
```

### תרחישים שהערכה תופסת:

| בעיה | מה קרה | הערכה היתה מזהה |
|------|---------|-----------------|
| **Hallucination** | Agent בדה עובדות | Groundedness score < 0.5 |
| **Off-topic** | תשובה לא רלוונטית | Relevance score < 0.3 |
| **Toxic** | תשובה פוגענית | Toxicity score > 0.7 |
| **Incomplete** | Agent לא סיים משימה | Task completion = 0% |
| **Regression** | עדכון שבר דבר | Score dropped 20% |

---

## סוגי מדדים (Metrics)

### מפת מדדים:

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

### מה זה?
**Groundedness** = עד כמה התשובה מבוססת על **עובדות ומידע שניתן לו**, ולא על המצאות (hallucinations).

```mermaid
graph LR
    subgraph "Grounded ✅"
        Context1["📄 Context:<br/>'הכנסות Q3: #36;5M'"] --> Answer1["🤖 'ההכנסות ב-Q3<br/>היו #36;5M'"]
    end
    
    subgraph "NOT Grounded ❌"
        Context2["📄 Context:<br/>'הכנסות Q3: #36;5M'"] --> Answer2["🤖 'ההכנסות ב-Q3<br/>היו #36;8M' 🤥"]
    end
```

### איך מודדים?

```mermaid
graph TD
    Answer["🤖 Agent Answer"] --> Extract["1️⃣ Extract Claims<br/>חלץ טענות"]
    Extract --> Claims["Claims:<br/>- 'Revenue was #36;5M'<br/>- 'Growth was 20%'<br/>- 'Best quarter ever'"]
    Claims --> Check["2️⃣ Check Each Claim<br/>נגד ה-Context"]
    Check --> Supported["✅ Supported: 2"]
    Check --> NotSupported["❌ Not Supported: 1"]
    Supported --> Score["3️⃣ Score<br/>2/3 = 0.67"]
```

### Hallucination Types:

| סוג | הסבר | דוגמה |
|-----|-------|-------|
| **Intrinsic** | סותר את ה-Context | Context: "revenue $5M" → Answer: "revenue $8M" |
| **Extrinsic** | מידע שלא קיים ב-Context | Context: silent on Q4 → Answer: "Q4 was great" |
| **Fabricated References** | ציטוט מקורות לא קיימים | "According to Smith et al. (2023)..." |

---

## Relevance & Coherence

### Relevance (רלוונטיות):
עד כמה התשובה **עונה על מה שנשאל**.

```mermaid
graph LR
    subgraph "Relevant ✅"
        Q1["❓ 'מה המחיר?'"] --> A1["🤖 'המחיר הוא #36;99'"]
    end
    
    subgraph "Not Relevant ❌"
        Q2["❓ 'מה המחיר?'"] --> A2["🤖 'המוצר מגיע<br/>ב-3 צבעים'"]
    end
```

### Coherence (קוהרנטיות):
עד כמה התשובה **הגיונית, ברורה, ומובנית**.

```mermaid
graph LR
    subgraph "Coherent ✅"
        A1["🤖 'ראשית, בדקתי את הנתונים.<br/>שנית, זיהיתי מגמה.<br/>לבסוף, הנה המסקנה.'"]
    end
    
    subgraph "Not Coherent ❌"
        A2["🤖 'המחיר הוא כי<br/>אבל גם הצבע<br/>המוצר טוב כי...'"]
    end
```

### Scoring Scale (1-5):

| ציון | Relevance | Coherence |
|------|-----------|-----------|
| **5** | עונה ממוקד על השאלה | ברור, מאורגן, שוטף |
| **4** | עונה עם קצת פרטים מיותרים | ברור ברובו |
| **3** | עונה חלקית | קצת מבלבל |
| **2** | בקושי עונה | לא מאורגן |
| **1** | לא עונה כלל | לא מובן |

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

| Category | מה בודק | threshold |
|----------|---------|-----------|
| **Violence** | תוכן אלים | Score < 2 |
| **Hate Speech** | שנאה / גזענות | Score < 1 |
| **Sexual Content** | תוכן מיני | Score < 2 |
| **Self-Harm** | פגיעה עצמית | Score < 1 |
| **Fairness/Bias** | הטיה | Score < 2 |
| **Jailbreak** | ניסיון לעקוף מגבלות | Score < 1 |

---

## Task Completion

### מדד הצלחה מבוסס משימה:

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

### מדדי Task:

| מדד | הסבר |
|-----|-------|
| **Completion Rate** | % צעדים שהושלמו |
| **Correct Tool Usage** | בחר בכלי הנכון? |
| **Step Efficiency** | כמה צעדים נדרשו (פחות = יותר טוב) |
| **Final Answer Accuracy** | האם התשובה הסופית נכונה? |
| **User Satisfaction** | דירוג ידני של המשתמש |

---

## שיטות הערכה

### 3 גישות עיקריות:

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

### השוואה:

| שיטה | דיוק | מהירות | עלות | Scalability |
|------|------|--------|------|-------------|
| **Human Eval** | ⭐⭐⭐⭐⭐ | ⭐ | ⭐ | ⭐ |
| **LLM-as-Judge** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Programmatic** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

### LLM-as-Judge - איך זה עובד?

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

### מה זה?
השוואה של **שתי גרסאות** של Agent כדי לראות מי עובד יותר טוב.

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

### מה משנים ב-A/B test?

| Variable | דוגמה A | דוגמה B |
|----------|---------|---------|
| **Model** | GPT-4o | Claude Sonnet |
| **System Prompt** | Short, concise | Detailed, with examples |
| **Temperature** | 0.0 | 0.3 |
| **Tools** | 5 tools | 3 tools (pruned) |
| **Chunking** | 500 tokens | 1000 tokens |
| **Memory** | Last 5 messages | Summarized |

---

## Continuous Evaluation

### בדיקות שוטפות:

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

## יתרונות וחסרונות

| ✅ יתרון | ❌ חיסרון |
|----------|----------|
| מזהה בעיות לפני production | עלות LLM-as-Judge (קריאות LLM) |
| מאפשר השוואת גרסאות | Test dataset דורש תחזוקה |
| רגרסיה מזוהה אוטומטית | LLM-as-Judge לא תמיד מדויק |
| מדדי Safety אוטומטיים | Subjective metrics קשים להערכה |
| A/B testing מבוסס נתונים | דורש infrastructure |

---

## סיכום

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

| מה למדנו | נקודה מרכזית |
|-----------|-------------|
| **Evaluation Engine** | מערכת שמודדת את איכות ה-Agent |
| **Groundedness** | האם התשובה מבוססת על עובדות? |
| **Relevance** | האם עונה על מה שנשאל? |
| **LLM-as-Judge** | שימוש ב-LLM אחד כדי להעריך LLM אחר |
| **Task Completion** | האם המשימה הושלמה? |
| **A/B Testing** | השוואת שתי גרסאות של Agent |
| **CI/CD Eval** | הרצת הערכה אוטומטית עם כל deploy |

---

## ❓ שאלות לבדיקה עצמית

1. מהם 4 הקטגוריות של מדדי הערכה?
2. מה זה Groundedness ואיך מודדים אותו?
3. מה ההבדל בין Intrinsic ל-Extrinsic Hallucination?
4. מהם 3 שיטות ההערכה ומתי משתמשים בכל אחת?
5. איך LLM-as-Judge עובד?
6. מה זה A/B Testing ב-context של Agents?
7. למה חשוב לשלב Evaluation ב-CI/CD?

---

### 📝 תשובות

<details>
<summary>1. מהם 4 הקטגוריות של מדדי הערכה?</summary>

1. **Quality** - איכות התשובה (relevance, coherence, groundedness).
2. **Safety** - האם התשובה בטוחה (toxicity, bias, PII leak).
3. **Performance** - ביצועים (latency, tokens, cost per request).
4. **Task Completion** - האם ה-Agent באמת השלים את המשימה (success rate, steps taken).
</details>

<details>
<summary>2. מה זה Groundedness ואיך מודדים אותו?</summary>

**Groundedness** = האם התשובה מבוססת על ה-**context** שניתן ל-LLM (ולא המציא). מודדים על ידי: (1) LLM-as-Judge - LLM נוסף מעריך אם כל claim בתשובה נתמך ב-context, (2) NLI models - מודלים שבודקים entailment, (3) חיפוש השוואתי בין תשובה ל-source documents.
</details>

<details>
<summary>3. מה ההבדל בין Intrinsic ל-Extrinsic Hallucination?</summary>

**Intrinsic** = ה-LLM **סותר** את ה-context שניתן לו. למשל: המסמך אומר "2023" וה-LLM עונה "2024". **Extrinsic** = ה-LLM מוסיף מידע ש**לא נמצא** ב-context כלל. ממציא מהאימון שלו. Intrinsic = שינה, Extrinsic = הוספה.
</details>

<details>
<summary>4. מהם 3 שיטות ההערכה ומתי משתמשים בכל אחת?</summary>

1. **Human Evaluation** - אנשים מדרגים. הכי מדויק אבל איטי ויקר. מתאים ל-gold standard.
2. **LLM-as-Judge** - LLM נוסף מעריך תשובות. מהיר וזול. מתאים ל-CI/CD.
3. **Automated Metrics** - נוסחאות קבועות (BLEU, ROUGE, F1). הכי זול ומהיר, פחות נואנסי.
</details>

<details>
<summary>5. איך LLM-as-Judge עובד?</summary>

שולחים ל-LLM חזק (GPT-4o) את: (1) השאלה המקורית, (2) התשובה שניתנה, (3) ה-context שסופק, (4) רובריקה עם קריטריונים ("score 1-5 for relevance, groundedness..."). ה-LLM מחזיר ציון + נימוק. יתרון: סקיילבילי וזול. חיסרון: LLM bias.
</details>

<details>
<summary>6. מה זה A/B Testing ב-context של Agents?</summary>

מריצים **שתי גרסאות** של Agent במקביל: גרסה A (נוכחית) וגרסה B (חדשה - prompt/model/tools שונים). מנתבים חלק מהתעבורה לכל גרסה ומשווים מדדים (איכות, latency, עלות). מאפשר להחליט מבוסס-data איזה גרסה עדיפה.
</details>

<details>
<summary>7. למה חשוב לשלב Evaluation ב-CI/CD?</summary>

כי Agents הם **לא-דטרמיניסטיים** - שינוי prompt קטן יכול לשבור הכל. unit tests לא מספיקים. לכן: בכל שינוי (prompt, model, tools) מריצים eval suite אוטומטי שבודק: האם האיכות נשמרה? האם יש regression? רק אם pass → deploy.
</details>

---

**[⬅️ חזרה לפרק 9: Runtime Plane](09-runtime-plane.md)** | **[➡️ המשך לפרק 11: Observability & Cost →](11-observability-cost.md)**
