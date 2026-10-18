# Aula 3 — Repositório GitOps com Argo CD

**Onde roda:** Codespaces (gratuito). **Tempo:** ~27 min (passos 0 a 2), logo depois do intervalo. O `selfHeal` do passo 2 e o bônus de quebrar a política são **bônus** para quem terminar antes: a teoria de drift e de PR como gate vem depois do laboratório.

Pré-requisito: o repositório precisa ser **público** e o código na branch `main`. O Argo CD lê o Git do repositório do **seu
Codespace** (o `origin`), ou seja, da sua cópia: abra o Codespace dela, não o do template. A pasta `gitops/` já veio na cópia que você
criou na Aula 1; não precisa atualizar nada.

> Não cole chave, senha ou token **reais** no chat nem fale em voz alta: a gravação fica disponível. A `sk-123` do bônus é falsa de propósito.

## Passo 0 · Preparo do ambiente: subir o cluster

Este passo só termina quando o `consultar.sh` mostrar **staging em `v12`, produção em `v11` e os dois `Application` como *Synced***.
Só então comece o passo 1. Se travar aqui, o problema é o preparo do ambiente, não o GitOps: avise no chat.

```bash
gitops/scripts/subir-cluster.sh
gitops/scripts/consultar.sh
```

Staging roda o prompt `v12` e produção o `v11`: `diff` dos dois overlays responde "o que ainda não foi promovido":

```bash
diff gitops/overlays/staging/inference-config.env gitops/overlays/producao/inference-config.env
```

## Passo 1 · Promover pelo Git

Mude `PROMPT_VERSAO=v12` em `gitops/overlays/producao/inference-config.env`, abra um **Pull Request**
e veja o workflow *Aula 3 · Checks do PR* (`gitops/politicas/verificar.py`). Depois do merge, em menos de 1 min:

```bash
gitops/scripts/consultar.sh      # produção agora responde prompt=v12
```

## Passo 2 · Provocar *drift*

```bash
kubectl -n agente-producao scale deploy/agente-suporte --replicas=5
gitops/scripts/consultar.sh      # produção fica OutOfSync; o Git ainda diz 3 réplicas
```

**Bônus:** produção tem `selfHeal: false` (só alerta). Troque para `true` em `gitops/apps/agente-producao.yaml`,
faça o merge e repita o drift. **Qual política vocês escolhem para produção, e por quê?**

**Nos últimos 3 minutos:** poste no chat uma linha por grupo: *o que decidimos / o que quebrou*. O debrief parte dessas linhas.

## Bônus · Quebrar a política de propósito

Em um PR, troque `PROMPT_VERSAO=v12` por `latest` e adicione `OPENAI_API_KEY=sk-123`. O check do PR
deve reprovar com os dois motivos. Rollback do prompt: `git revert` do merge — em quanto tempo
produção volta?

## Perguntas dos critérios da aula

Onde está declarado qual modelo e prompt rodam em cada ambiente? Onde fica a chave do LLM sem estar
em texto claro? Quem muda produção sem revisão? (Ative `CODEOWNERS` e a proteção da `main`.)
