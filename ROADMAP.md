# Roadmap — Hotel Livingstone

Cronograma e checkpoints dos 3 milestones do projeto. Datas contratuais (apresentações marcadas pelo RH).

| Milestone | Data | Cursos cobertos | Status |
|---|---|---|---|
| **M1** — Site via UI | 2026-05-25 | Liferay Fundamentals + Content Creator | 🚧 Em execução (M1.2 próximo) |
| **M2** — Workflow + Docker | 2026-06-29 | Liferay Content Management | ⏸️ Bloqueado por M1 |
| **M3** — SB + REST + Tests + Upgrade C | 2026-07-27 | Service Builder + REST Builder + Junior I/II/III + Pleno I/II via workshop | ⏸️ Bloqueado por M2 |

## M1 — Detalhamento

Sub-dividido em 3 fases internas:

### M1.1 — Setup + Site base ✅

| Task | Status | Commit |
|---|---|---|
| 1. README + ROADMAP iniciais | ✅ | `7c8050c` |
| 2. ADR-001 workspace nativo no M1 | ✅ | `ec16ded` |
| Setup Java 21 Liberica + `.sdkmanrc` (extra) | ✅ | `46583c3` |
| Atualização stack GA129 → GA132 (extra) | ✅ | `781eeb3` |
| 3. Inicializar Liferay Workspace | ✅ | `d2032a1` |
| 4. Baixar bundle + ajustar porta + iniciar Liferay | ✅ | `a7b6553` |
| 5. Setup admin + login | ✅ | `93edb84` |
| 6. Criar site + 6 pages | ✅ | `5d51bac` |
| 7. Multi-idioma PT/EN | ✅ | `b3462d2` |
| 8. Navigation menu principal | ✅ | `b3397eb` |
| 9. Retrospectiva M1.1 + tag git | ✅ | _(este commit)_ |

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
