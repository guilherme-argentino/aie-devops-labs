# Setup — Azure Web Apps (Aula 6 · capstone)

O agente de atendimento vai para um **Azure Web App** (Linux, Python 3.12) pelo GitHub Actions,
só depois de passar no agent gate. É a opção 2 da disciplina (GitHub Actions + Azure Web Sites):
usada porque o capstone fica no ar por dias e o AWS Academy não segura isso.

> **Este roteiro não foi testado de ponta a ponta.** O fluxo (App Service F1 + publish profile +
> `azure/webapps-deploy`) segue a documentação oficial; confira cada passo na primeira execução.

## Custo

O plano **F1 (Free)** não cobra, mas tem 60 minutos de CPU por dia e dorme quando ocioso (a
primeira chamada demora). Serve para o capstone. Para a apresentação, o **B1 (~US$ 13/mês)** evita
o limite — com o **Azure for Students** não precisa de cartão.

## 1. Criar o Web App (uma vez por grupo)

```bash
az login
GRUPO=rg-aie-capstone
APP=agente-quantum-$RANDOM            # o nome vira <nome>.azurewebsites.net e precisa ser único

az group create -n $GRUPO -l brazilsouth
az appservice plan create -g $GRUPO -n plano-aie --is-linux --sku F1
az webapp create -g $GRUPO -p plano-aie -n $APP --runtime "PYTHON:3.12"

# Comando de inicialização: o FastAPI do agente, na porta que o App Service espera
az webapp config set -g $GRUPO -n $APP \
  --startup-file "gunicorn app:app -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000 --timeout 120"
az webapp config appsettings set -g $GRUPO -n $APP --settings \
  SCM_DO_BUILD_DURING_DEPLOYMENT=true WEBSITES_PORT=8000 \
  LLM_PROVEDOR=openai LLM_BASE_URL=<endpoint do seu LLM> LLM_MODELO=<modelo> LLM_API_KEY=<chave>
```

O Web App **não roda o Ollama** (não cabe no F1). Em produção, o agente chama um LLM por API:
Microsoft Foundry / Azure OpenAI (crédito do Azure for Students) ou outro endpoint compatível com a
API da OpenAI. O Ollama é só para o agent gate no CI.

## 2. Ligar o GitHub Actions

```bash
# Publish profile: arquivo de credencial do Web App (não expira)
az webapp deployment list-publishing-profiles -g $GRUPO -n $APP --xml > perfil.xml
gh secret set AZURE_WEBAPP_PUBLISH_PROFILE < perfil.xml
rm perfil.xml                                  # não deixe a credencial no disco
gh variable set AZURE_WEBAPP_NAME --body "$APP"
```

Se `az` recusar o publish profile, habilite a autenticação básica do SCM em **Web App → Configuration →
General settings → SCM Basic Auth Publishing Credentials**.

## 3. Conferir

```bash
gh workflow run "Aula 6 · Deploy do agente (Azure Web Apps)"
curl https://$APP.azurewebsites.net/
curl -X POST https://$APP.azurewebsites.net/chamado -H 'content-type: application/json' \
  -d '{"texto": "Meu pedido está atrasado há 6 dias úteis"}'
```

## 4. Limpeza

```bash
az group delete -n rg-aie-capstone --yes --no-wait
```
