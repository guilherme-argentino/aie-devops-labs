# Como atualizar a sua cópia do repositório de labs

Você criou o seu repositório com **Use this template**. Isso faz uma **cópia independente**: ela **não** é um *fork* e não
recebe as correções e os arquivos novos que o professor publica depois (por isso o botão "Sync fork" não aparece). Este
roteiro mostra como trazer essas mudanças para a sua cópia, ou quando é mais simples começar uma nova.

## Qual caminho escolher

| Situação | Caminho |
|---|---|
| Você quase não mexeu na cópia, ou vai começar uma nova aula do zero | **A · Criar uma nova cópia** (mais simples) |
| Você tem trabalho seu na cópia e quer só **trazer arquivos novos ou corrigidos** | **B · Trazer arquivos do template** (recomendado) |
| Você é experiente em Git e quer o histórico mesclado | C · `merge` (avançado, dá conflito em quase tudo) |

## A · Criar uma nova cópia

1. Abra `github.com/guilherme-argentino/aie-devops-labs`, **logado no GitHub**, e clique em **Use this template → Create a new repository**
   (público).
2. Recoloque os *secrets* da AWS (`roteiros/setup-aws-academy.md`) e, se precisar, adicione de novo a sua dupla como
   colaboradora.

A cópia antiga continua existindo; você só deixa de usá-la.

## B · Trazer arquivos do template (sem apagar o seu trabalho)

No terminal do Codespace, dentro do seu repositório:

```bash
# 1) Só na primeira vez: aponte para o repositório do professor (apelido "template")
git remote add template https://github.com/guilherme-argentino/aie-devops-labs.git

# 2) Baixe o que o professor publicou
git fetch template

# 3) Veja o que mudou (esquerda = a sua cópia, direita = o template)
git diff --stat HEAD template/main
git diff --name-only HEAD template/main
```

Para cada arquivo ou pasta da lista que **você não editou**, traga a versão do template:

```bash
git checkout template/main -- classificador/deploy/publicar.sh roteiros
git status
```

Cuidado com os arquivos que **você** editou (por exemplo `.github/CODEOWNERS` e o teste do laboratório da Aula 1): **não** os
traga com o comando acima, porque ele sobrescreve a sua versão. Compare antes, e copie à mão só o que quiser:

```bash
git diff HEAD template/main -- .github/CODEOWNERS
```

Se um arquivo foi **apagado** no template, ele aparece como `deleted` no `git diff` e continua na sua cópia: apague-o à mão se não precisar.

Depois, registre e envie:

```bash
git add -A
git commit -m "Atualiza do template"
git push
```

### Se a sua `main` está protegida (laboratório da Aula 1)

O `git push` direto na `main` será recusado. Faça numa branch e abra um Pull Request:

```bash
git switch -c atualiza-template
# ... os comandos "git checkout template/main -- ..." e o commit acima ...
git push -u origin atualiza-template
gh pr create --fill
```

Peça a aprovação à sua dupla (ninguém aprova o próprio PR) e faça o merge.

### Se o `push` for recusado por causa de `.github/workflows`

Mudanças em workflows podem exigir uma permissão extra do token. Se o `git push` falhar com uma mensagem sobre `workflow`,
edite aquele arquivo pelo navegador, no GitHub, colando o conteúdo da versão do template.

## C · `merge` (avançado)

```bash
git fetch template
git merge template/main --allow-unrelated-histories
```

Como as duas cópias não têm histórico em comum, o Git marca **conflito em todo arquivo que mudou** (`add/add`), mesmo nos que
você nunca tocou. Resolva um a um (ou use o caminho B).

## Quando atualizar

Quando o professor avisar que o template mudou (ou antes de uma aula nova). Não precisa a cada aula: o caminho **A** costuma
ser mais rápido do que atualizar uma cópia com muitos arquivos mudados.
