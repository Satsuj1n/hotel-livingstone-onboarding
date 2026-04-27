# Roadmap — Hotel Livingstone

Cronograma e checkpoints dos 3 milestones do projeto. Datas contratuais (apresentações marcadas pelo RH).

| Milestone | Data | Cursos cobertos | Status |
|---|---|---|---|
| **M1** — Site via UI | 2026-05-25 | Liferay Fundamentals + Content Creator | 🚧 Em execução (M1.1) |
| **M2** — Workflow + Docker | 2026-06-29 | Liferay Content Management | ⏸️ Bloqueado por M1 |
| **M3** — SB + REST + Tests + Upgrade C | 2026-07-27 | Service Builder + REST Builder + Junior I/II/III + Pleno I/II via workshop | ⏸️ Bloqueado por M2 |

## M1 — Detalhamento

Sub-dividido em 3 fases internas:

### M1.1 — Setup + Site base ⬅️ ATUAL

| Task | Status | Commit |
|---|---|---|
| 1. README + ROADMAP iniciais | 🚧 | — |
| 2. ADR-001 workspace nativo no M1 | ⏸️ | — |
| 3. Inicializar Liferay Workspace | ⏸️ | — |
| 4. Baixar bundle + ajustar porta + iniciar Liferay | ⏸️ | — |
| 5. Setup admin + login | ⏸️ | — |
| 6. Criar site + 6 pages | ⏸️ | — |
| 7. Multi-idioma PT/EN | ⏸️ | — |
| 8. Navigation menu principal | ⏸️ | — |
| 9. Retrospectiva M1.1 + tag git | ⏸️ | — |

### M1.2 — Tema + Web Content + Fragments
A planejar após conclusão de M1.1.

### M1.3 — Polish + Retrospectiva M1 + Slides + Apresentação 25/05
A planejar após conclusão de M1.2.

## M2 — Visão geral

Migração workspace nativo → Docker Compose (Liferay + Postgres 14 + Elasticsearch 7.17). Workflow Kaleo customizado (Reserva → Aprovação → Notificação). Web Content Structures + Templates. Asset Publisher dinâmico.

## M3 — Visão geral

Service Builder (Room, Booking, Guest, Package + finders + validações TDD). REST Builder (`/rooms`, `/bookings`, `/availability`). Tests unit + integration. CI GitLab. Upgrade C: workshop testes gravado (Pleno I+II), Liferay Objects (Pleno III parcial), sessão diagnóstico real.

## Próximos passos imediatos

1. Concluir M1.1 (este plan)
2. Criar plan M1.2 (tema + content + fragments)
3. Criar repo no GitHub pessoal + `git remote add origin` + `git push -u origin main`
