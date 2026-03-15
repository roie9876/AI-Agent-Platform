# 🛠️ Prerequisites Installation Guide

> **Step-by-step guide** for installing all required tools.
> Choose your OS: [Windows](#-windows) | [macOS](#-macos)

---

## 📋 Required Tools

| Tool | Why You Need It | Minimum Version |
|------|----------------|-----------------|
| **VS Code** | Code editor — where you'll work throughout the labs | Latest |
| **Python** | Programming language for all labs | 3.11+ |
| **Git** | Download workshop materials | Latest |
| **Azure CLI** | Deploy cloud resources | Latest |
| **jq** | Parse deployment outputs (used by setup script) | Latest |

---

## 🪟 Windows

### Step 1: Install VS Code

1. Go to [https://code.visualstudio.com/download](https://code.visualstudio.com/download)
2. Click **"Download for Windows"**
3. Run the installer
4. During installation:
   - ✅ Check **"Add to PATH"** (important!)
   - ✅ Check **"Register Code as an editor"**
   - ✅ Check **"Add 'Open with Code' action"**
5. Click **Install** then **Finish**

**Verify:** Open Command Prompt and type:
```bash
code --version
```

### Step 2: Install Python

> ⚠️ **Important**: Use Python 3.11, 3.12, or 3.13. Not 3.14+.

1. Go to [https://www.python.org/downloads/](https://www.python.org/downloads/)
2. Download Python 3.13.x (or 3.12/3.11)
3. Run the installer
4. **On the first screen**: ✅ **Check "Add python.exe to PATH"** (bottom of screen!)
5. Click **"Install Now"**

**Verify:** Open a **new** terminal:
```bash
python --version
```

> 💡 If `python` is not recognized, try `python3` or `py`

### Step 3: Install Git

1. Go to [https://git-scm.com/downloads/win](https://git-scm.com/downloads/win)
2. Download and run the installer
3. Use default settings (click **Next** through all screens)

**Verify:**
```bash
git --version
```

### Step 4: Install Azure CLI

1. Go to [https://learn.microsoft.com/cli/azure/install-azure-cli-windows](https://learn.microsoft.com/cli/azure/install-azure-cli-windows)
2. Download the MSI installer
3. Run it: **Next** → **I accept** → **Install** → **Finish**

**Verify:**
```bash
az --version
```

**Log in to Azure:**
```bash
az login
```
A browser will open — sign in with your Azure account.

### Step 5: Install jq

```bash
# Using winget (Windows 11):
winget install jqlang.jq

# Or download from: https://jqlang.github.io/jq/download/
```

**Verify:**
```bash
jq --version
```

### Step 6: Install VS Code Extensions

Open VS Code, press `Ctrl+Shift+X`, then search and install:

| Extension | Search For |
|-----------|-----------|
| Python | `ms-python.python` |
| Jupyter | `ms-toolsai.jupyter` |

Or run in terminal:
```bash
code --install-extension ms-python.python
code --install-extension ms-toolsai.jupyter
```

### Step 7: Clone and Set Up

```bash
git clone https://github.com/roie9876/AI-Agent-Platform.git
cd AI-Agent-Platform/labs
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

**Verify:**
```bash
python -c "import langchain; print('✅ All good!')"
```

---

## 🍎 macOS

### Step 1: Install Homebrew

Homebrew makes installing tools on Mac much easier:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the on-screen instructions. You may need to run an `eval` command shown at the end.

**Verify:**
```bash
brew --version
```

### Step 2: Install VS Code

```bash
brew install --cask visual-studio-code
```

Or download from [https://code.visualstudio.com/download](https://code.visualstudio.com/download)

**Add `code` to PATH:**
1. Open VS Code
2. Press `Cmd+Shift+P`
3. Type: **"Shell Command: Install 'code' command in PATH"**

**Verify:**
```bash
code --version
```

### Step 3: Install Python

```bash
brew install python@3.13
```

**Verify:**
```bash
python3 --version
```

### Step 4: Install Git

```bash
brew install git
```

**Verify:**
```bash
git --version
```

### Step 5: Install Azure CLI

```bash
brew install azure-cli
```

**Verify and log in:**
```bash
az --version
az login
```

### Step 6: Install jq

```bash
brew install jq
```

**Verify:**
```bash
jq --version
```

### Step 7: Install VS Code Extensions

```bash
code --install-extension ms-python.python
code --install-extension ms-toolsai.jupyter
```

### Step 8: Clone and Set Up

```bash
git clone https://github.com/roie9876/AI-Agent-Platform.git
cd AI-Agent-Platform/labs
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

**Verify:**
```bash
python -c "import langchain; print('✅ All good!')"
```

---

## ✅ Checklist

Before proceeding to deploy Azure resources, verify:

- [ ] VS Code opens and works
- [ ] `python --version` shows 3.11+
- [ ] `git --version` works
- [ ] `az --version` works
- [ ] `az login` succeeds
- [ ] `jq --version` works
- [ ] `pip install -r requirements.txt` completed without errors

**All checked?** Head to [Lab 00 Setup](README.md) to deploy Azure resources!
