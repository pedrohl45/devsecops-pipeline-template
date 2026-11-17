# devsecops-pipeline-template

Pipeline de CI/CD com segurança embutida, pronto para copiar para um repositório novo. Tem um app mínimo em FastAPI só para o pipeline ter o que buildar, testar e escanear.

Montei a versão original no meu estágio. Este repositório é uma reescrita do zero, genérica, com um app de exemplo.

## O que roda

```
PR / push na main
   |
   +-- lint ........ ruff (inclui regras de segurança)
   +-- testes ...... pytest
   +-- seguranca ... Gitleaks (segredos) · Trivy (dependências e Dockerfile) · Semgrep (código)
   |
   '-- build (só se tudo acima passou)
         build local -> Trivy escaneia a imagem -> publica no GHCR (só na main)
```

Outros workflows:
- `pr-title`: o título do PR precisa seguir Conventional Commits.
- `release`: uma tag `vX.Y.Z` promove a imagem que já passou pelo CI, sem rebuild, para a tag da versão.
- `comentario-dependabot`: um bot (GitHub App) comenta nos PRs do Dependabot. É opcional: sem as credenciais, o job termina sem falhar.

## O que foi testado
- `ci`: roda em PR e na `main` (lint, testes, scans, build com scan da imagem e publicação no GHCR).
- `release`: a tag `v0.1.0` promoveu a imagem da `main` sem rebuild.
- `pr-title` e `dependabot`: já rodaram em PRs reais do Dependabot.
- `comentario-dependabot`: ainda **não foi testado de ponta a ponta**. Ele depende de um GitHub App criado por você; sem as credenciais o job só termina sem falhar.

## O que reprova o build de propósito
- Segredo em qualquer commit do histórico.
- CVE alta ou crítica nas dependências ou na imagem.
- Dockerfile sem `USER` (imagem rodando como root).
- Padrão inseguro de código encontrado pelo Semgrep ou pelo ruff.

## Como usar
1. Copie este repositório para o seu e troque o app.
2. Implemente `scripts/ci/lint.sh` e `scripts/ci/test.sh` para a sua stack. São os ganchos do pipeline.
3. Ajuste o `Dockerfile` (a porta, o comando e o usuário).
4. Rode os scans na sua máquina: `bash scripts/ci/seguranca.sh segredos` (ou `dependencias`, `sast`, `imagem <tag>`).
5. Para o bot de PR do Dependabot: crie um GitHub App, guarde `BOT_APP_ID` e `BOT_APP_KEY` nos **segredos do Dependabot** do repositório (os do Actions não chegam nesses PRs) e edite `.github/bot/frases.json`.

## Decisões
As decisões e as lições (por que a imagem não é refeita no release, por que os binários têm checksum, etc.) estão em [docs/decisoes.md](docs/decisoes.md).

## Licença
MIT.
