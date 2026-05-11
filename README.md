# Hotel Livingstone — Onboarding Liferay

Projeto pessoal de onboarding na SEA Tecnologia cobrindo os desafios backend Liferay de 30/60/90 dias + trilha de carreira Junior I/II/III + Pleno I/II.

## O que é

Implementação evolutiva do site fictício "Hotel Livingstone" em Liferay 7.4 CE GA132. Cada milestone adiciona uma camada técnica nova:

- **M1 (até 25/05/2026):** Site funcional via UI (Pages, Web Content, Fragments, Theme, Navigation, multi-idioma PT/EN)
- **M2 (até 29/06/2026):** Workflow Kaleo + dynamic content + migração pra Docker Compose
- **M3 (até 27/07/2026):** Service Builder + REST Builder + tests + CI/CD GitLab + Workshop testes (gravado) + Liferay Objects + Diagnóstico real

## Stack

- Liferay 7.4 CE GA132
- Java 21 (Liberica)
- Blade CLI 8.0.0
- Gradle (via wrapper)
- Docker Compose (M2+)

## Status

🚧 **M1.1 em execução** (setup + site base) — apresentação M1 marcada pra 25/05/2026.

## Como rodar

```bash
cd workspace/
blade server init    # primeira vez — baixa bundle ~500MB (ou usa cache em ~/.liferay/bundles/)

# Trocar porta 8080 por 8081 (evita conflito com Liferay GDF):
sed -i '' 's/port="8080"/port="8081"/g' bundles/tomcat/conf/server.xml

blade server run     # foreground (logs visíveis); use 'start' pra background
# Aguardar ~30-90s pelo log "Liferay 7.4.X.X (Athanasius) started in N.Ns"
# Abrir http://localhost:8081
```

## Estrutura do repo

Ver [ROADMAP.md](./ROADMAP.md) e [docs/specs/2026-04-26-design.md](./docs/specs/2026-04-26-design.md) pra detalhes completos.

## Convenções

- Docs em PT-BR; código em inglês; commits PT-BR Conventional Commits
- ADRs em `docs/adr/` com estrutura: Contexto → Opções consideradas → Trade-offs → Decisão → Consequências
- Learning log por sessão em `docs/learning-log/`

## Autor

Felipe Lima (felipenehz2003@gmail.com) — backend dev na SEA Tecnologia desde abril/2026.
