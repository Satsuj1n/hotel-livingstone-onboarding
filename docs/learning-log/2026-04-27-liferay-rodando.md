# 2026-04-27 — Liferay rodando localmente (Task 4)

## O que tentei

- Subir Liferay 7.4 GA132 local na porta 8081 (em vez do padrão 8080) pra coexistir com instâncias do GDF/negocia-df sem conflito.
- Validar fim-a-fim: bundle baixado → porta trocada → servidor de pé → HTTP respondendo.

## O que errei

- O comando `sed` que recebi tinha o path `bundles/tomcat-*/conf/server.xml`, mas o GA132 extrai o Tomcat numa pasta `tomcat/` (sem versão no nome). Glob não bateu, sed falhou silenciosamente. Resolvi manualmente abrindo o `server.xml` e fazendo "Replace All" 8080 → 8081 no editor.
- Aprendizado meta: comando com glob (`*`) precisa ser validado contra a estrutura real antes de mandar pro terminal.

## O que firmou

- Cadeia de validação Liferay local: `blade server init` → editar `server.xml` → `blade server run` → curl 200/302 → setup wizard no browser. Nada quebrou.
- `blade server init` reaproveita ZIP de `~/.liferay/bundles/` se já existir — por isso o init levou 37s em vez de ~10min de download. Boa pra rebuild de ambiente.

## Dúvida aberta

- Achei tranquilo até aqui — quase tudo é boilerplate de configuração inicial. A real começa nas próximas tasks (criar o site, multi-idioma, navegação). Sem dúvida técnica concreta no momento.
