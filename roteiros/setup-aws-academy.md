# Setup — AWS Academy Learner Lab

Usado nas Aulas 2 (deploy), 4 (canary) e 5 (MLflow, e Bedrock se estiver liberado).

> **Este roteiro não foi testado contra um Learner Lab real.** Os limites abaixo vêm da lista
> oficial de serviços do Learner Lab e do guia do educador (ambos em `02_Apoio_Referencia/05_AWS_Academy/`),
> que são de 2021 e podem ter mudado. A primeira pessoa a rodar deve conferir cada passo.

## O que o Learner Lab permite (e o que atrapalha)

| Limite | Efeito nos laboratórios |
|---|---|
| Só `us-east-1` e `us-west-2` | Todos os scripts usam `us-east-1` |
| Sessão de **4 horas**; credenciais novas a cada "Start Lab" | O GitHub Actions precisa dos secrets atualizados **a cada aula** (passo 3) |
| IAM quase bloqueado: sem criar usuário, role ou provedor OIDC | Só existem a `LabRole` e a `LabInstanceProfile`; o Actions não consegue usar OIDC |
| Crédito de US$ 100 por aluno | Lambda, ECR e S3 custam centavos; **pare o EC2 do MLflow** ao fim da aula |
| EC2 só `nano` a `large`; Lambda, ECR, S3, SSM, CloudWatch, Secrets Manager liberados | Cabe nos labs |
| Bedrock, ECS e EKS **não aparecem** na lista de 2021 | Confira no console antes da Aula 5; se o Bedrock não aparecer, use Ollama (veja `agente/llm.py`) |

## 1. Primeiro acesso (faça antes da aula)

1. Entre no AWS Academy → o curso **Learner Lab** → **Launch AWS Academy Learner Lab**.
2. **Start Lab** e espere a bolinha ficar verde. **AWS** abre o console.
3. No console, procure por cada serviço que vamos usar e veja se abre sem erro de acesso:
   **Lambda**, **ECR**, **S3**, **EC2**, **Systems Manager**, **Bedrock** (este é o que mais varia).
4. Anote o resultado — define o provedor de LLM da Aula 5 (`bedrock` ou `openai`/Ollama).

## 2. Credenciais para o terminal (Codespaces)

No Learner Lab, clique em **AWS Details → AWS CLI → Show** e copie o bloco. No terminal do Codespaces:

```bash
mkdir -p ~/.aws && cat > ~/.aws/credentials   # cole o bloco [default] e termine com Ctrl+D
export AWS_REGION=us-east-1
aws sts get-caller-identity                   # deve mostrar a LabRole
```

## 3. Credenciais para o GitHub Actions (a cada aula)

Os três valores mudam a cada "Start Lab". No repositório: **Settings → Secrets and variables → Actions → New repository secret**:

| Secret | Valor (de AWS Details → AWS CLI) |
|---|---|
| `AWS_ACCESS_KEY_ID` | `aws_access_key_id` |
| `AWS_SECRET_ACCESS_KEY` | `aws_secret_access_key` |
| `AWS_SESSION_TOKEN` | `aws_session_token` |

Pelo `gh`, mais rápido (com as variáveis já exportadas no terminal):

```bash
gh secret set AWS_ACCESS_KEY_ID     --body "$(aws configure get aws_access_key_id)"
gh secret set AWS_SECRET_ACCESS_KEY --body "$(aws configure get aws_secret_access_key)"
gh secret set AWS_SESSION_TOKEN     --body "$(aws configure get aws_session_token)"
```

Crie também o environment `producao` (Settings → Environments) — os workflows de deploy o usam.

**Se o workflow falhar com "Credenciais do Academy expiradas":** o lab foi reiniciado. Repita este passo.

## 4. Por que o capstone (Aula 6) não usa o Academy

Ele precisa ficar de pé por dias, e as credenciais do lab expiram em 4 horas. O agente vai para o
**Azure Web Apps** (`roteiros/setup-azure.md`), cujo publish profile não expira.

## 5. Limpeza ao fim

```bash
mlops/servidor-mlflow-ec2.sh destruir     # EC2, security group e bucket do MLflow
aws lambda delete-function --function-name classificador-avaliacoes
aws ecr delete-repository --repository-name classificador-avaliacoes --force
```
