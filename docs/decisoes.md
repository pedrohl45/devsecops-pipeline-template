# Decisões

**A imagem que sobe é a mesma que foi escaneada.** O build fica local, o Trivy escaneia essa imagem e só então ela é publicada com a tag `sha-<7 caracteres>`. No release, a tag `vX.Y.Z` só aponta para essa mesma imagem (`imagetools create`), sem rebuild. Refazer a imagem no release publicaria algo que ninguém testou.

**O release falha se o commit da tag nunca passou pelo CI.** Sem imagem `sha-...` não há o que promover. A mensagem de erro diz isso.

**Ferramentas com versão fixa e checksum.** Gitleaks e Trivy são baixados de uma versão específica e o SHA-256 é conferido antes de usar (o valor vem do arquivo de checksums oficial de cada release). Se alguém trocar o binário no meio do caminho, o pipeline para.

**Actions fixadas pelo SHA do commit**, com a versão no comentário. O Dependabot atualiza.

**`--ignore-unfixed` no Trivy.** Reprova CVE alta/crítica que já tem correção. CVE sem correção disponível não é algo que o time consiga resolver, e deixar isso reprovar o build só ensina a ignorar o scan.

**A base Docker precisa de `apt-get upgrade`.** A imagem oficial é publicada de tempos em tempos e os CVEs aparecem entre uma publicação e outra. Sem o upgrade, o scan da imagem reprova por pacote do sistema.

**O Gitleaks lê o histórico inteiro** (`fetch-depth: 0`). Segredo apagado num commit antigo continua vazado.

**Segredos de Dependabot são separados dos do Actions.** Num PR aberto pelo Dependabot, o workflow só enxerga os segredos do Dependabot. Por isso o bot de comentário não funcionava até eu guardar as credenciais no lugar certo.

**Segredos por repositório, não por organização**, no plano gratuito. Em conta pessoal ou organização gratuita com repositório privado, o segredo de organização não está disponível.

**Sem proteção de branch.** Em repositório privado de conta gratuita não existe. Em um repositório de verdade, proteja a `main` e exija o check `ci`.
