#!/usr/bin/env bash
# Prepara o Codespaces: dependências Python, kind e (opcional) Ollama.
set -euo pipefail

pip install -r requirements.txt -r mlops/requirements.txt

# O pip cai em instalação de usuário (~/.local/bin), que não está no PATH desta imagem:
# sem isto, `ruff`, `mlflow` e `uvicorn` dariam "command not found" no terminal.
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  grep -qs '.local/bin' "$rc" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
done
export PATH="$HOME/.local/bin:$PATH"

sudo curl -fsSLo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.33.0/kind-linux-amd64
sudo chmod +x /usr/local/bin/kind

# O instalador do Ollama extrai um .tar.zst e a imagem base (Debian trixie) não traz o zstd
sudo apt-get update -qq && sudo apt-get install -y -qq zstd

# Ollama: LLM 100% gratuito para o agent gate (a Aula 6 usa o provedor "openai" apontando para ele).
# Baixar o modelo (~2 GB) leva alguns minutos; o servidor sobe sob demanda com: ollama serve &
curl -fsSL https://ollama.com/install.sh | sh || echo "Ollama não instalou — o agent gate roda com o provedor simulado."

echo "Pronto. Próximos passos: roteiros/README.md"
