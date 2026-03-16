# 📚 AI Agent Platform - Education Hub

## מטרת המסמך
מסמך זה הוא חומר לימודי מקיף שנועד ללמד את כל המושגים, הטכנולוגיות והאדריכלויות הנדרשים לתכנון ובניית **AI Agent Platform as a Service (PaaS)**.

כל פרק עומד בפני עצמו, אך יחד הם יוצרים תמונה שלמה של מערכת ברמת Production.

---

## 🗂️ סדר הלימוד המומלץ

| # | נושא | קובץ |
|---|-------|-------|
| 1 | **מושגי יסוד — מהו AI Agent?** | [01-fundamentals.md](01-fundamentals.md) |
| 2 | **Model Abstraction & Routing** | [02-model-abstraction-routing.md](02-model-abstraction-routing.md) |
| 3 | **Memory Management & RAG** | [03-memory-management.md](03-memory-management.md) |
| 4 | **Thread & State Management** | [04-thread-state-management.md](04-thread-state-management.md) |
| 5 | **Orchestration Patterns** | [05-orchestration.md](05-orchestration.md) |
| 6 | **Tools & Marketplace** | [06-tools-marketplace.md](06-tools-marketplace.md) |
| 7 | **Policy & Governance** | [07-policy-governance.md](07-policy-governance.md) |
| 8 | **Control Plane** | [08-control-plane.md](08-control-plane.md) |
| 9 | **Runtime Plane** | [09-runtime-plane.md](09-runtime-plane.md) |
| 10 | **Evaluation Engine** | [10-evaluation-engine.md](10-evaluation-engine.md) |
| 11 | **Observability & Cost** | [11-observability-cost.md](11-observability-cost.md) |
| 12 | **Security & Isolation** | [12-security-isolation.md](12-security-isolation.md) |
| 13 | **Scalability Patterns** | [13-scalability.md](13-scalability.md) |
| 14 | **HLD — Full Architecture** | [14-hld-architecture.md](14-hld-architecture.md) |
| 15 | **Microsoft Stack Mapping** | [15-microsoft-stack.md](15-microsoft-stack.md) |
| 16 | **Agent Frameworks & Ecosystem** | [16-agent-frameworks.md](16-agent-frameworks.md) |

---

## 🎯 איך להשתמש בחומר הזה

1. **קרא לפי הסדר** - הפרקים בנויים מהבסיס למורכב
2. **עצור על כל תרשים** - התרשימים (Mermaid) מדגימים את הזרימות והקשרים בין הרכיבים
3. **שים לב לטבלאות היתרונות/חסרונות** - הן יעזרו לך להבין מתי כל טכנולוגיה מתאימה
4. **בסוף כל פרק** יש סיכום ושאלות לבדיקה עצמית

---

## 🧭 מפת הנושאים - מבט מלמעלה

```mermaid
graph TB
    subgraph "🎛️ Control Plane"
        API[API Gateway]
        IAM[Identity & Access]
        Registry[Agent Registry]
        Policy[Policy Engine]
        Eval[Evaluation Engine]
        Cost[Cost Dashboard]
        Marketplace[Tool Marketplace]
    end

    subgraph "⚙️ Runtime Plane"
        Orch[Orchestrator]
        Model[Model Layer]
        Mem[Memory Manager]
        Thread[Thread Manager]
        State[State Manager]
        Sandbox[Secure Sandbox]
        Tools[Tool Executor]
    end

    subgraph "📊 Cross-Cutting"
        Obs[Observability]
        Sec[Security]
        Scale[Scalability]
    end

    API --> Orch
    IAM --> API
    Registry --> Orch
    Orch --> Model
    Orch --> Mem
    Orch --> Thread
    Orch --> State
    Orch --> Tools
    Tools --> Sandbox
    Policy --> Orch
    Eval --> Orch
    Cost --> Obs
    Obs --> Orch
    Sec --> Sandbox
    Scale --> Orch
```

---

> **הערה:** כל תרשימי ה-Mermaid במסמכים אלה ניתנים לצפייה ישירות ב-VS Code עם תוסף Mermaid, או באתרים כמו [mermaid.live](https://mermaid.live).
