# ADR-004 — Template de scaffolding = `js-theme`

| Campo | Valor |
|---|---|
| **Data** | 2026-04-29 |
| **Status** | Aceito |
| **Decisor** | Felipe Lima (projeto pessoal) |

## Contexto

Pra criar um tema custom no Liferay 7.4 GA132, o Blade CLI oferece dois templates de scaffolding:

- **`blade create -t theme`** (legado) — scaffolding "puro Liferay", FTL + SCSS sem toolchain Node.js
- **`blade create -t js-theme`** (atual) — scaffolding via generator-liferay-theme (Yeoman) por baixo, integra Gulp + npm pra build/watch/extend

Existe ainda **`-t theme-contributor`** (não considerado), que é pra distribuir CSS/JS sem FTL — fora do escopo do Hotel Livingstone, que precisa customizar `portal_normal.ftl`.

A documentação oficial Liferay 7.4 (`learn.liferay.com/w/dxp/site-building/developer-guide/themes/creating-a-theme`) recomenda explicitamente `js-theme` como caminho atual. O template `theme` legacy é mencionado como histórico — possivelmente removido em GA132 (validação empírica pendente).

## Opções consideradas

### Opção A: `blade create -t theme` (legacy)

**Prós:**
- Scaffolding puro Liferay, sem dependência Node.js no workspace
- Build 100% via Gradle do workspace — fluxo único

**Cons:**
- Sem watch task pronto pra dev — precisa redeploy manual a cada mudança SCSS
- Sem `extend`, `kickstart`, `upgrade` — utilitários Yeoman que ajudam em manutenção
- Documentação oficial não cobre mais — qualquer dúvida vira "arqueologia" em fóruns antigos
- Risco real de o template ter sido **removido em GA132** (validar empiricamente custaria tempo)

### Opção B: `blade create -t js-theme`

**Prós:**
- Caminho oficial documentado pra Liferay 7.4 (confirmado via Context7 lookup `/websites/learn_liferay_w_dxp` em 2026-04-29)
- Toolchain Yeoman/Gulp/npm familiar a devs frontend (overlap com career-ops/iZJob)
- Watch task automática (`gulp watch`) pra dev local — em workspace, integra com Gradle plugin que já constrói/deploya
- Utilitários `extend`, `kickstart`, `upgrade`, `status` — ajudam em manutenção/migração de versão
- `package.json` versionado deixa parent theme pinado explícito (suporte ao ADR-003)

**Cons:**
- Depende de Node.js + npm/yarn no workspace (já presentes via Liferay Gradle plugin — custo zero efetivo)
- Mais arquivos gerados (`.gitignore`, `gulpfile.js`, `package.json`, `liferay-theme.json`) — workspace fica maior
- Se o time SEA não usar Yeoman/Gulp, dev novo precisa entender fluxo

## Trade-offs

A questão central é **fluxo único Gradle vs. fluxo recomendado oficial (com toolchain Node)**.

- Opção A é mais "limpa" em projeto Java puro mas perde watch + utilitários
- Opção B adiciona Node.js no fluxo — custo cognitivo baixo (já está no workspace) e ganha alinhamento com doc oficial

## Decisão

**Opção B — `blade create -t js-theme`.** Tema `hotellivingstonetheme` foi gerado em 2026-04-29 via:

```bash
cd workspace/themes
blade create -t js-theme -p hotel-livingstone-theme hotel-livingstone-theme
```

Build/deploy diário roda via Gradle do workspace (`./gradlew :themes:hotel-livingstone-theme:deploy`) — não usa Gulp diretamente. Toolchain Node fica como fallback pra utilitários Yeoman quando precisar (`gulp extend`, `gulp upgrade`).

## Consequências

### Positivas
- Tema construído em conformidade com doc oficial — qualquer dúvida tem fonte autoritativa pra consultar
- `package.json` versiona explicitamente parent theme (`liferay-frontend-theme-styled@6.0.54`) — aderente ao ADR-003 (mitigação de bump silencioso)
- Fluxo Gradle do workspace deploya tema com 1 comando — não precisamos de `gulp deploy` (Gulp serve só pra utilitários do generator)

### Negativas
- Workspace gera `workspace/.yarnrc`, `workspace/package.json`, `workspace/yarn.lock` — arquivos do Liferay Gradle plugin que ficam untracked. Resolvido via `.gitignore` raiz na Fase 1 (commit `fix(workspace): ignore yarn/node artifacts`)
- AI tooling de generator (`.cursor/`, `.gemini/`, etc.) foi gerado e teve que ser apagado manualmente (pendência registrada em memory `project_hotel_livingstone_onboarding.md`)
- Validação empírica do prompt `yo liferay-theme` não foi feita — generator-liferay-theme 10.2.0 gerou com defaults sem prompts interativos. Não confirmamos se há flag pra forçar prompts (não bloqueante)

### Mitigações
- `.gitignore` raiz inclui `workspace/.yarnrc`, `workspace/package.json`, `workspace/yarn.lock`, `workspace/themes/*/build/`, `workspace/themes/*/node_modules/` — protege contra commits acidentais de artefatos gerados
- Achado da Fase 1: em workspace Liferay, **fluxo Gulp é desnecessário** pro build/deploy do dia-a-dia — Gradle plugin do workspace constrói/deploya tudo. `gulp init` skip; `liferay-theme.json` no `.gitignore`. Decisão consciente de **não** rodar `gulp init` (que pediria configuração de URL/credenciais do Liferay e gravaria em `liferay-theme.json` non-versionado)
- Pendência fechada na sessão Igor (2026-05-04): confirmar template `theme` legacy não foi a tentativa investigada (Igor mexeu em versão de parent). Validação empírica de remoção em GA132 segue pendente — não bloqueante
