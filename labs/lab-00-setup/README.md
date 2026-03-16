# Lab 00 — Environment Setup (Zero to Ready)

## 🎯 Objective

Get your environment ready for all 7 labs with **minimal friction**. By the end of this module, you'll have:
- All Azure resources deployed (one command!)
- Your `.env` file configured automatically
- Everything validated with a health-check notebook

---

## ☁️ Azure Resources Deployed

One Bicep template deploys everything all labs need:

```
┌─────────────────────────────────────────────────────────────────────┐
│                  Azure Resource Group                                │
│                  rg-agent-platform-labs                              │
│                                                                      │
│   ┌──────────────────────────────────────────────────────────────┐  │
│   │  🧠 Azure OpenAI (AI Services)                               │  │
│   │     • gpt-41          (primary model)        Labs 01-07     │  │
│   │     • gpt-4o-mini     (cheap model)          Lab 02, 04     │  │
│   │     • text-embedding-3-large (embeddings)    Lab 03         │  │
│   └──────────────────────────────────────────────────────────────┘  │
│                                                                      │
│   ┌──────────────────────────────────────────────────────────────┐  │
│   │  🏗️ Azure AI Foundry Project                                 │  │
│   │   Agents, Evaluations, Tracing                               │  │
│   └──────────────────────────────────────────────────────────────┘  │
│                                                                      │
│   ┌────────────────────┐  ┌────────────────────────────────────┐   │
│   │  🔍 Azure AI Search │  │  💾 Azure Cosmos DB (Serverless)   │   │
│   │   Vector + Semantic │  │   threads container                │   │
│   │   Lab 03 (RAG)      │  │   memory container                │   │
│   └────────────────────┘  │   Lab 03 (Memory & State)          │   │
│                            └────────────────────────────────────┘   │
│                                                                      │
│   ┌────────────────────┐  ┌────────────────────────────────────┐   │
│   │  🛡️ Content Safety  │  │  📦 Storage Account                │   │
│   │   Guardrails API    │  │   documents container              │   │
│   │   Lab 05            │  │   Lab 03 (RAG docs)               │   │
│   └────────────────────┘  └────────────────────────────────────┘   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Which Lab Uses Which Resource?

| Resource | Lab 01 | Lab 02 | Lab 03 | Lab 04 | Lab 05 | Lab 06 | Lab 07 | Lab 09 |
|----------|--------|--------|--------|--------|--------|--------|--------|--------|
| Azure OpenAI GPT-4.1 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Azure OpenAI GPT-4o-mini | | ✅ | | ✅ | | | | |
| Azure OpenAI Embeddings | | | ✅ | | | | | |
| Azure AI Search | | | ✅ | | | | | |
| Azure Cosmos DB | | | ✅ | | | | | |
| Azure Content Safety | | | | | ✅ | | | |
| Storage Account | | | ✅ | | | | | |
| AI Foundry Project | | | | | | | | ✅ |

### 💰 Cost Estimate

| Resource | Cost/Day | Note |
|----------|----------|------|
| Azure OpenAI | ~$0-3 | Pay per token (no idle cost) |
| Azure AI Search (Basic) | ~$2.5 | Fixed cost while running |
| Azure Cosmos DB (Serverless) | ~$0-1 | Pay per request |
| Content Safety | ~$0 | Pay per call |
| Storage | ~$0 | Minimal data |
| **Total** | **~$3-7/day** | **Delete when done!** |

> ⚠️ **Remember to run `cleanup.sh` when you're done** to avoid ongoing charges.

---

## 🚀 Quick Start

### Prerequisites

| Requirement | Version | How to Check |
|------------|---------|-------------|
| Azure subscription | Owner or Contributor | `az account show` |
| Python | 3.11+ | `python --version` |
| Azure CLI | Latest | `az --version` |
| Git | Latest | `git --version` |
| VS Code | Latest | `code --version` |
| jq | Latest | `jq --version` |

> 🆕 **Brand new to these tools?** See [PREREQUISITES.md](PREREQUISITES.md) for step-by-step installation with screenshots.

### Step 1: Clone the Repository

```bash
git clone https://github.com/roie9876/AI-Agent-Platform.git
cd AI-Agent-Platform
```

### Step 2: Install Python Dependencies

```bash
cd labs
python -m venv .venv
source .venv/bin/activate   # macOS/Linux
# .venv\Scripts\activate    # Windows

pip install -r requirements.txt
```

### Step 3: Deploy Azure Resources

**Option A: Interactive Notebook (Recommended for beginners)**
```
Open labs/lab-00-setup/setup.ipynb and run all cells
```

**Option B: Command Line (For experienced users)**
```bash
cd ../infra
./deploy.sh
```

Both options will:
1. ✅ Check Azure CLI login
2. ✅ Create resource group
3. ✅ Deploy all resources via Bicep (~5-10 min)
4. ✅ Generate `.env` file with all connection strings

### Step 4: Validate Setup

```
Open labs/lab-00-setup/health-check.ipynb and run all cells
```

---

## 📁 Files in This Module

| File | Description |
|------|-------------|
| `PREREQUISITES.md` | Step-by-step tool installation guide (Windows & macOS) |
| `setup.ipynb` | Interactive setup wizard — deploys Azure resources |
| `health-check.ipynb` | Validates all connections work |

---

## 🔧 Troubleshooting

| Problem | Solution |
|---------|----------|
| `az login` fails | Try `az login --use-device-code` for remote terminals |
| Deployment fails with quota error | Try a different region: `LOCATION=eastus2 ./deploy.sh` |
| GPT-4.1 not available | Check region availability; may need to request quota |
| Cosmos DB creation fails | Ensure subscription has Cosmos DB provider registered |
| `.env` file not generated | Check that `jq` is installed: `brew install jq` (macOS) |

---

## ⏱️ Estimated Time

| Step | Time |
|------|------|
| Install prerequisites | 10-15 min (first time only) |
| Deploy Azure resources | 5-10 min |
| Validate setup | 5 min |
| **Total** | **~20-30 min** |

---

**Next**: [Lab 01 — Build a ReAct Agent from Scratch](../lab-01-react-agent/README.md)
