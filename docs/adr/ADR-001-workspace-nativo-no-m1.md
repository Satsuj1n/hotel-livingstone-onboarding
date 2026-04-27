# ADR-001 — Workspace Liferay nativo no M1, Docker Compose a partir do M2

| Campo | Valor |
|---|---|
| **Data** | 2026-04-26 |
| **Status** | Aceito |
| **Decisor** | Felipe Lima (projeto pessoal) |

## Contexto

O projeto Hotel Livingstone precisa de uma instância Liferay 7.4 CE GA132 rodando localmente pra desenvolvimento. O ambiente do desenvolvedor (macOS, Apple Silicon, Docker Desktop instalado) suporta múltiplas estratégias de deploy local.

Restrição importante: o workspace GDF (`~/Documents/SEA/dados-aberto-lf7_4-workspace/`) já roda Liferay nativo na porta 8080. O Hotel Livingstone precisa coexistir sem conflito.

## Opções consideradas

### Opção A: Workspace Liferay nativo (blade server init/start)

**Prós:**
- Setup mais rápido (1 comando após blade init)
- Performance native melhor que Docker no macOS (Apple Silicon ainda penaliza Docker x86 emulation)
- Logs e debug diretos via Tomcat embarcado
- Menor consumo de RAM (sem overhead de containerização)
- Mesmo padrão do GDF (consistência mental)

**Cons:**
- HSQLDB embarcado (não é production-like)
- Configuração de porta requer edição manual de `server.xml` do Tomcat
- Não simula ambiente de produção (Docker é mais próximo de prod)
- Não treina Docker (pilar de Production-readiness do projeto)

### Opção B: Docker Compose desde o dia 1

**Prós:**
- Production-readiness desde o início
- Postgres 14 (real) em vez de HSQLDB
- Reproduzível 100% (1 `docker-compose up`)
- Treina Docker desde a primeira hora

**Cons:**
- Liferay + Postgres + Elasticsearch no Docker Desktop macOS = ~6-8GB RAM, lento no boot
- Curso Liferay Fundamentals (M1) assume bundle local
- Setup inicial mais complexo (~3-4h vs ~30min nativo)
- Configuração via UI no Liferay Docker é mais difícil de exportar

### Opção C: Híbrido — nativo no M1, Docker no M2

**Prós:**
- Aprendizado por camadas (1 conceito novo por milestone)
- M1 foca em UI Liferay (alinhado com curso Fundamentals)
- M2 introduz Docker quando começa a ter sentido (workflow + dynamic content + Postgres)
- Distribui curva de aprendizado

**Cons:**
- Migração no meio do projeto (custo de transição)
- Configurações feitas via UI no M1 podem precisar ser refeitas no M2 (Site Initializer mitiga, mas adiciona trabalho)

## Trade-offs

A questão central é **velocidade de aprendizado vs. realismo de produção**.

- Opção A maximiza velocidade no curto prazo mas adia o aprendizado de Docker pra M3 (ou nunca)
- Opção B maximiza realismo mas pode atrapalhar o aprendizado dos fundamentos Liferay no M1
- Opção C distribui ambos no tempo, com custo de uma migração no meio

## Decisão

**Opção C — Híbrido.** No M1.1, M1.2 e M1.3, usar workspace Liferay nativo na porta 8081. A partir do M2, migrar pra Docker Compose com Postgres 14 + Elasticsearch 7.17.

## Consequências

### Positivas
- M1 inteiro foca em UI Liferay sem distração de container tooling
- Docker entra no M2 quando workflow + dynamic content já justificam Postgres real
- Cada milestone adiciona EXATAMENTE 1 camada técnica nova (princípio do roadmap)

### Negativas
- M2 vai começar com ~4-6h dedicadas a Docker setup (não-código)
- Site Hotel Livingstone configurado via UI no M1 vai precisar ser reproduzido no Docker no M2 — ou manualmente, ou via Site Initializer (decisão pra M2)

### Mitigações
- Documentar todas as configurações do M1 em screenshots no learning-log → re-execução manual no M2 fica viável
- Considerar Site Initializer no M2 pra tornar configuração reproduzível via código
