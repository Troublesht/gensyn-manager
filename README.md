<details> <summary>📄 Click to expand the full README content</summary>

# 🚀 Gensyn RL-Swarm Manager

A powerful Bash script to easily manage and run your Gensyn RL-Swarm setup with GPU/CPU support, ngrok tunneling, and tmux session handling.

---

## 📅 Last Updated: 2025-07-16

---

## 🧰 Features

- 🖥️ Run Gensyn RL-Swarm with CPU or GPU  
- 🌐 Automatically open ngrok tunnel (in tmux)  
- 🧠 Intelligent login flow via modal 
- 🛠 Fixes Python venv, CUDA fragmentation & PyTorch GPU usage  
---

## 📦 Requirements

- Ubuntu 22.04+ or WSL2  
- Git, curl, tmux   `sudo apt install git curl tmux -y`
- [ngrok](https://ngrok.com/)

---

## 🛠️ Installation

### Step 1: Run the installer

```bash
bash <(curl -s https://gist.githubusercontent.com/Troublesht/0a0f0df568201226da0d008a918d83eb/raw)
```

---

## 📋 Menu Options

```text
🚀  Gensyn RL-Swarm Manager
============================================
1) Install Dependencies (CPU)
2) Install Dependencies (GPU)
3) Open ngrok tunnel (tmux)
4) Run Gensyn (CPU - tmux)
5) Run Gensyn (GPU - tmux)
6) Attach to ngrok session
7) Attach to gensyn session
8) Manual Shell for Fixes 🔧
9) Exit
```

---

## 🚦 How to Use

### ✅ Setup

1. Choose **1** or **2** to install dependencies (based on your hardware)  
2. Choose **3** to open ngrok tunnel (it runs in a `tmux` session)  
3. Copy ngrok link and **login via browser**  
4. After login, choose **4** or **5** to run Gensyn RL-Swarm  

### 🔁 Session Management

- Reattach ngrok tunnel:  
  ```bash
  tmux attach -t ngrok
  ```  
- Reattach Gensyn session:  
  ```bash
  tmux attach -t gensyn
  ```  
- Detach session: Press `Ctrl + B`, then press `D`

---

## 📊 Optimize GPU Usage

Set this before launching Gensyn (or add it to your bashrc):

```bash
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
```

---

## 🧪 Advanced

If anything breaks or logs need checking, use option **8** to drop into the `rl-swarm` shell manually.

---

## 📎 GitHub Repo

Feel free to fork or contribute:  
👉 [https://github.com/Troublesht/gensyn-manager](https://github.com/Troublesht/gensyn-manager)

---

## 🧑‍💻 Author

Script by [Troublesht](https://github.com/Troublesht)

[X link](https://x.com/Ankurzk) 
