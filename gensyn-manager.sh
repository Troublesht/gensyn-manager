#!/bin/bash

# 🚀 Gensyn RL-Swarm Manager (Final Patch for tmux reliability)
set -e
export DEBIAN_FRONTEND=noninteractive
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

apt update -qq
apt install -y -qq apt-utils locales tmux git curl unzip \
  python3 python3-venv python3-pip software-properties-common \
  gnupg ca-certificates lsb-release >/dev/null

locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8

# Node.js setup
if ! command -v node >/dev/null || [[ "$(node -v)" != v20* ]]; then
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash - >/dev/null
  apt install -y -qq nodejs >/dev/null
fi

# ngrok setup
if ! command -v ngrok >/dev/null; then
  curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | \
    tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
  echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | \
    tee /etc/apt/sources.list.d/ngrok.list
  apt update -qq && apt install -y -qq ngrok >/dev/null
fi

# Clone rl-swarm if not exists
[[ ! -d "rl-swarm" ]] && git clone https://github.com/gensyn-ai/rl-swarm.git
cd rl-swarm

PROJECT_DIR="$PWD"
VENV_DIR="$PROJECT_DIR/.venv"

install_deps() {
  echo "[+] Setting up Python venv..."
  python3 -m venv "$VENV_DIR"
  source "$VENV_DIR/bin/activate"
  echo "[+] Installing Python packages ($1 mode)..."
  if [[ "$1" == "GPU" ]]; then
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
  else
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
  fi
  pip install wandb hivemind sentencepiece transformers accelerate datasets einops scipy scikit-learn
  echo "[✓] Dependencies installed."
}

open_ngrok_tmux() {
  read -p "[?] Enter ngrok auth token: " token
  [[ -n "$token" ]] && ngrok config add-authtoken "$token"
  tmux new-session -d -s ngrok 'ngrok http 3000'
  echo "[✓] Ngrok session started ('ngrok')."
}

run_gensyn_tmux() {
  if [[ ! -f "$VENV_DIR/bin/activate" ]]; then
    echo "[!] Install dependencies first."
    return
  fi

  # Check for existing session
  if tmux has-session -t gensyn 2>/dev/null; then
    echo "[i] 'gensyn' session already exists."
  else
    echo "[+] Starting Gensyn session..."
    tmux new-session -d -s gensyn \
      "cd '$PROJECT_DIR'; \
       source '$VENV_DIR/bin/activate'; \
       export PYTHONPATH='$PROJECT_DIR'; \
       [[ '$1' == 'GPU' ]] && export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True; \
       echo '[*] Running Gensyn ($1)'; \
       bash run_rl_swarm.sh --accelerator $([[ '$1' == 'GPU' ]] && echo cuda || echo cpu) \
       || echo '[!] Gensyn exited unexpectedly. Check session logs.'; \
       read -n 1 -s -r -p 'Press any key to close session.'"
    echo "[✓] 'gensyn' session started."
  fi
}

manual_shell() {
  echo "[🔧] Opening manual shell. Type 'exit' to return."
  bash
}

# Main Menu
while true; do
  clear
  cat <<EOF
============================================
🚀  Gensyn RL-Swarm Manager
============================================
1) Install Dependencies (CPU)
2) Install Dependencies (GPU)
3) Open ngrok tunnel (tmux)
4) Run Gensyn (CPU - tmux)
5) Run Gensyn (GPU - tmux)
6) Attach to ngrok session
7) Attach to gensyn session
8) Manual Shell 🔧
9) Exit
============================================
EOF
  read -p "👉 Pick an option: " opt
  case $opt in
    1) install_deps "CPU"; read -p "Press Enter..." ;;
    2) install_deps "GPU"; read -p "Press Enter..." ;;
    3) open_ngrok_tmux; read -p "Press Enter..." ;;
    4) run_gensyn_tmux "CPU"; read -p "Press Enter..." ;;
    5) run_gensyn_tmux "GPU"; read -p "Press Enter..." ;;
    6) tmux attach -t ngrok ;;
    7) tmux attach -t gensyn ;;
    8) manual_shell ;;
    9) echo "👋 Bye!"; exit ;;
    *) echo "[!] Invalid option."; sleep 1 ;;
  esac
done
