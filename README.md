# Hotel Livingstone — Onboarding Liferay SEA

Projeto pessoal de onboarding na SEA Tecnologia cobrindo os desafios backend Liferay de 30/60/90 dias + trilha de carreira Junior I/II/III + Pleno I/II.

## O que é

Implementação evolutiva do site fictício "Hotel Livingstone" em Liferay 7.4 CE GA129. Cada milestone adiciona uma camada técnica nova:

- **M1 (até 25/05/2026):** Site funcional via UI (Pages, Web Content, Fragments, Theme, Navigation, multi-idioma PT/EN)
- **M2 (até 29/06/2026):** Workflow Kaleo + dynamic content + migração pra Docker Compose
- **M3 (até 27/07/2026):** Service Builder + REST Builder + tests + CI/CD GitLab + Workshop testes (gravado) + Liferay Objects + Diagnóstico real

## Stack

- Liferay 7.4 CE GA129
- Java 21 (Liberica)
- Blade CLI 8.0.0
- Gradle (via wrapper)
- Docker Compose (M2+)

## Status

🚧 **M1.1 em execução** (setup + site base) — apresentação M1 marcada pra 25/05/2026.

## Como rodar

```bash
cd workspace/
blade server init    # primeira vez — baixa bundle ~500MB
# Editar bundles/tomcat-*/conf/server.xml e trocar port="8080" por port="8081"
blade server start
# Aguarde ~15s e abra http://localhost:8081
```

## Estrutura do repo

Ver [ROADMAP.md](./ROADMAP.md) e [docs/specs/2026-04-26-design.md](./docs/specs/2026-04-26-design.md) pra detalhes completos.

## Convenções

- Docs em PT-BR; código em inglês; commits PT-BR Conventional Commits
- ADRs em `docs/adr/` com estrutura: Contexto → Opções consideradas → Trade-offs → Decisão → Consequências
- Learning log por sessão em `docs/learning-log/`

## Autor

Felipe Lima (felipenehz2003@gmail.com) — backend dev na SEA Tecnologia desde abril/2026.
