# Learning-log — Cards Redesign (M1.3 antecipado)

| Campo | Valor |
|---|---|
| **Data** | 2026-05-09 (retomada da sessão interrompida em 2026-05-04) |
| **Branch** | `feat/m1.3-cards-redesign` |
| **Plan** | `docs/plans/2026-05-04-cards-redesign.md` (8 tasks) |
| **Spec** | `docs/specs/2026-05-04-cards-redesign-design.md` |
| **Tempo total** | ~6h em 2026-05-04 + ~1h em 2026-05-09 |

## TL;DR

Fragment Card de Quarto reescrito (HTML semântico + CSS com vars do tema), Structure Quarto refatorada via API DataEngine v2.0 (4 fields `amenity_1..4` Text + remoção do Selection múltipla), 3 Articles re-populados via Headless Delivery PUT, page Quartos com 3 cards instanciados com mapping completo (12/12 amenidades) + Liferay Grade com class `.hl-card-grid`. **Build do tema voltou a funcionar** após cleanup de 4035 files duplicados macOS no `node_modules/`. Fix de responsividade aplicado: `@media (max-width: 1023px) { 1 col }` no `_custom.scss` deployed via `main.css` do tema.

## Achados canônicos

### 1. DataEngine v2.0 REST aceita PUT pra refactor de Structure DDM

`PUT /o/data-engine/v2.0/data-definitions/{id}` substitui completamente a definition. Funcionou pra trocar Selection múltipla por 4 Text fields sem UI drag-and-drop e sem JSONWS bloqueado. **Padrão pra M2 Site Initializer:** usar essa API pra reproduzir Structures via código.

### 2. Headless Delivery PATCH `/structured-contents/{id}` falha com `RequiredValue`

Mesmo enviando todos os campos, PATCH dá `DDMFormValuesValidationException.RequiredValue`. **PUT replace funciona.** Sempre preferir PUT pra Articles em Liferay 7.4 GA132.

### 3. Liferay 7.4 NÃO auto-atualiza HTML de fragment instances quando definition muda

Mudei IDs de editable na definition e crashou as 3 instances existentes ("Erro inesperado ao renderizar este item"). Solução: deletar+re-arrastar instances. Painel direito não tem botão "Atualizar fragmento".

### 4. Liferay "Grade" gera Bootstrap row/col interno (`container-fluid > row > col-*`)

Não é wrapper atomic — gera estrutura de 3 níveis. Auto-fit no parent NÃO atinge cards reais. Override precisa selectors descendant + `!important` escopados pela class do parent (`.hl-card-grid > .container-fluid > .row { grid-template-columns: ... !important }`).

### 5. Liferay aplica `display: grid` implícito no `.lfr-layout-structure-item-row`

Computed style do `.hl-card-grid` (que tem essa classe) mostra `display: grid` E `grid-template-columns: 1168px 0px 0px` (3 cols, mas 2 de 0px porque só tem 1 child = `.container-fluid`). Não atrapalha visualmente, mas é "ruído" CSS — vem de uma rule do Liferay Layout, não do nosso tema.

### 6. Build de tema (gulp build:base) trava em filesystem com duplicados macOS

**Sintoma observado em 2026-05-09:** No `node_modules/` do workspace havia **4035 files duplicados** com padrões `<nome> 2.<ext>`, `<nome> 3.<ext>` — incluindo `liferay-frontend-theme-unstyled/images/spacer 3.png` (ENOENT silencioso porque foi parcialmente deletado, mas listing/manifest ainda apontava).

**Mitigação rápida:**
```bash
cd workspace
find . \( -name "* 2.*" -o -name "* 3.*" -o -name "* 4.*" -o -name "* 2" -o -name "* 3" -o -name "* 4" \) -depth -delete
./gradlew :themes:hotel-livingstone-theme:deploy --no-daemon
```

**UPDATE 2026-05-10 — hipótese inicial REFUTADA empiricamente:**

A primeira teoria desta sessão era "iCloud sync ou Time Machine cria duplicados". Testes empíricos rejeitaram ambas:

- `brctl status /Users/felipelima/Documents/SEA/hotel-livingstone-onboarding` → `Client zone not found` (não é zona iCloud)
- `tmutil destinationinfo` → `No destinations configured` (Time Machine inativo)
- `diskutil apfs listSnapshots /` → 1 snapshot único (OS update), sem rotação automática

**Evidência ao vivo capturada na sessão 2026-05-10:** após `find -delete` zerou os duplicados, foi disparado `:themes:hotel-livingstone-theme:deploy --no-daemon`. Em ~30s já haviam **11 duplicados** regenerados, dos quais **4 resistiam ao delete** — todos em `workspace/build/node/` (`bin 2`, `share 2`, `lib 2`, `include 2`), exatamente o destino da task `:downloadNode1` que estava extraindo Node.js naquele instante. Permissão dos duplicados: `drwx------` (owner-only restrita, padrão macOS APFS clonefile), vs `drwxr-xr-x@` dos originais.

**Hipótese refinada:** race condition durante extract paralelo do gradle plugin (`downloadNode1` + concorrente). Suspeita primária: Spotlight `mds_stores` indexando concorrente com extract → APFS clonefile fast-path falha → macOS materializa cópia com sufixo numérico. Pendência empírica: testar `mdutil -i off /Users/felipelima/Documents/SEA/hotel-livingstone-onboarding` numa próxima sessão e ver se duplicados param.

**Mitigação versionada:** `scripts/clean-macos-dups.sh` (varre workspace inteiro com `find -depth -delete`, idempotente, reporta count antes/depois). Rodar ANTES de cada `gradle deploy` enquanto root cause não vem.

**.gitignore defensivo NÃO é necessário:** `workspace/build/`, `workspace/bundles/`, `workspace/node_modules/` (via `**/build/` e implícitos do plugin) já estão fora do git. O problema é funcional (build trava), não de versionamento.

### 7. CSS Grid `auto-fit minmax(300px, 1fr)` cria layout 2+1 em viewports intermediários

Em ~700-1023px, com 3 cards e minmax 300px, o auto-fit decide 2 cols (cabem) + 1 sobra na 2ª linha. Tecnicamente correto, **esteticamente assimétrico**. **Decisão UX:** trocar por `@media (max-width: 1023px) { grid-template-columns: 1fr }` — força transição direta 3→1 sem o intermediário 2+1.

### 8. DevTools-first vence "tentar e ver"

Hipótese inicial era "specificity perdida pra Bootstrap". Em 30s de inspeção via Chrome DevTools (computed styles + matched rules), provei ela errada: override estava funcionando perfeitamente em desktop e mobile, problema era só em tablet por causa do auto-fit (achado #7). **30s de DevTools mata 30min de retrabalho cego.**

### 9. Tema vs Page Look and Feel — last-wins quando specificity é igual

CSS do tema (`<link>` em `<head>`) e CSS Personalizado da page (`<style>` inline em `<head>`) ambos com `!important`. Liferay injeta o `<style>` inline DEPOIS do `<link>` do tema → PLF vence. Quando ambos tinham o mesmo override Bootstrap, era no-op. Quando o tema ganhou a media query e o PLF não tinha → PLF venceu em tablet, anulando o fix do tema. **Padrão:** evitar redundância tema + PLF; manter override em UM lugar só (preferência: tema, é versionado).

### 10. JSONWS `update-css` / `update-look-and-feel` retorna `{}` em GA132 mas NÃO persiste

Curl com Basic Auth + parâmetros corretos (plid, themeId, css="") retornou `{}` (não erro). Mas reload da page mostrou CSS Personalizado intacto. Provavelmente endpoint deprecated ou requer mais context que não documentei. **CSS Personalizado da page é só editável via UI** em Liferay 7.4 GA132 (Configurar Página → Avançado → CSS Personalizado).

### 11. Felix File Install processa WAR em ~10s

`bundles/deploy/<war>` desaparece em ~10s (Felix copia pra `bundles/osgi/war/` e faz hot install). CSS atualizado disponível imediatamente em `/o/<theme>/css/main.css`. Sem reload de Tomcat.

### 12. Drag de fragment via Chrome DevTools MCP é não-confiável

Re-confirmado nesta sessão. MCP faz UI bem (login, click, snapshot, evaluate_script, take_screenshot, navigate) **mas drag e operações react-dnd falham**. Drag REAL do mouse continua canônico pra inserção de fragments na Page Editor.

### 13. Hover global em `<a>` colide com botões `<a>` que têm fundo da mesma cor

Bug visual descoberto via screenshot do Felipe: botão "Reserve agora" (`a.hl-btn`) com `color: --hl-text` (off-white) + `background: --hl-secondary` (pink) ficava com **texto invisível no hover**. Causa: regra global `a:hover { color: var(--hl-secondary) }` no `_custom.scss` linha 81-84 (com specificity `0,1,1`) sobrescrevia o `color` do `.hl-btn` (`0,1,0`) — texto virava pink, igual ao bg.

**Fix idiomático:** override pontual `.hl-btn:hover, .hl-btn:focus-visible { color: var(--hl-text); background: var(--hl-primary); }` (specificity `0,2,0` vence `0,1,1`). Bonus: pink → roxo Drácula no hover dá feedback visual claro mantendo paleta.

**Alternativa descartada:** refatorar `a:hover` global pra `a:hover:not(.hl-btn)`. Trade-off: `:not()` resolve na origem mas força manter lista de exceções; override pontual é localizado e fácil de aposentar quando o botão for removido.

### 14. Card de Quarto: HTML do fragment tem texto estático mistura com editables

Estrutura `<p class="hl-card__price"> A partir de <strong data-lfr-editable-id="card-price" ...>720</strong> / noite </p>` mistura **texto estático** (`A partir de`, `/ noite`) com **editable mapeado pro Article**. Pra adicionar prefixo `R$`, edita o HTML estático do fragment via UI Liferay (Site Builder → Fragments → Card de Quarto → publicar). Mudança propaga pros 3 cards instanciados imediatamente.

**Tentativa de automatizar via Headless Delivery API** falhou: `/o/headless-delivery/v1.0/sites/{id}/fragment-collections` retornou HTTP 404 em GA132. Endpoint pode estar gated ou ter prefix diferente. **Pesquisa pendente:** identificar a API REST correta pra atualizar fragment HTML/CSS/JS programaticamente (importante pro M2 Site Initializer).

### 15. Liferay field type `numeric` aplica locale formatting (en-US default = vírgula em milhares)

Sessão 2026-05-10. Cards renderizavam `1,200` no preço da Suíte Drácula, não `1.200` (formato pt-BR). Causa: o field `price` da Structure Quarto era `fieldType: numeric` + `dataType: integer`. Liferay aplica `Locale`-aware formatting via `NumberFormat.getNumberInstance(locale)` — em ambiente sem locale pt-BR explícito no contexto (caso da Headless Delivery), cai no `Locale.US` default → separador de milhares vira vírgula.

**Fix aplicado:** refactor da Structure via `PUT /o/data-engine/v2.0/data-definitions/32625` trocando `fieldType: numeric` → `text` + `dataType: integer` → `string`. 3 Articles re-`PUT` via Headless Delivery com valores literais formatados (`"720"`, `"850"`, `"1.200"`).

**Trade-off aceito:** perde tipagem semântica numérica (não dá pra fazer queries `price > 1000` via Structured Query nem ordenar numericamente). Ganha controle total da apresentação sem dependência de locale resolvido em runtime. Pra o caso de uso (3 Articles com preços fixos exibidos como string) o trade-off é benigno; em catálogo grande com filtros numéricos seria inaceitável — aí a solução correta seria garantir locale pt-BR no contexto da request (header `Accept-Language` ou config do site).

**Padrão genérico:** quando precisar controle exato de apresentação numérica em Liferay e o conjunto é pequeno + estático, **string formatada literal vence** numeric com locale-aware. Pra dados numéricos reais com agregação/filtro, configurar locale é o caminho.

## Decisão UX cravada (2026-05-09)

| # | Pergunta | Escolha | Alternativas descartadas | Trade-off |
|---|---|---|---|---|
| 1 | Como resolver layout 2+1 em tablet? | **3 col → 1 col (sem 2-col)** via `@media (max-width: 1023px)` | (B) 3→2→1 com nth-child spanning; (C) auto-fit + min(); (D) aceitar 2+1 | Em tablet (768px) desperdiça espaço horizontal mostrando 1 card largo, mas elimina assimetria visual do 2+1 |

## Estado entregue (validado via DevTools)

| Viewport | Layout | Validação |
|---|---|---|
| 1280px | 3 cards lado a lado, 373px cada | ✅ `gridTemplateColumns: "373.328px 373.336px 373.336px"` |
| 768px | 1 card por linha (com tema sozinho) | ✅ via media query do tema |
| 500px | 1 card por linha | ✅ |

## Arquivos modificados

- `workspace/themes/hotel-livingstone-theme/src/css/_custom.scss` — adicionou `.hl-card-grid` com override Bootstrap escopado + media query `(max-width: 1023px)` + `min-height` nas amenities
- `docs/plans/2026-05-04-cards-redesign.md` — fix naming (`--hl-bg` → `--hl-background`, `--hl-pink` → `--hl-secondary`)
- `docs/specs/2026-05-04-cards-redesign-design.md` — mesmo fix de naming
- Fragment "Card de Quarto" (DB) — HTML + CSS substituídos
- Structure "Quarto" (DB) — 4 fields amenity_1..4 (substitui Selection múltipla)
- 3 Articles (DB) — re-populados com 12 amenidades
- Page Quartos (DB) — 3 cards instanciados + mapping completo + Liferay Grade com class `hl-card-grid`

## Pendências (não bloqueiam merge)

1. **CSS Personalizado da page Quartos (PLF) ainda contém o override antigo.** Tema cobre tudo agora, PLF é redundante e atrapalha em <1024px (anula media query do tema). **Felipe limpa via UI:** Configurar Página → Avançado → CSS Personalizado → apagar conteúdo → Salvar. ~30s de trabalho.
2. **Tema da page Quartos pode estar em Classic** (Felipe trocou pra editar). Validar se voltar pra `hotellivingstonetheme` quebra Page Editor (hipótese: crash original era do mapping órfão dos fragments antigos, não do tema). Re-testar agora que mappings estão íntegros.
3. **Lixo macOS no workspace** — duplicados (`* 2`, `* 3`) regeneram durante builds (vide UPDATE no achado #6). Mitigação versionada: `scripts/clean-macos-dups.sh` (rodar antes de cada `gradle deploy`). Root cause em aberto: hipótese forte é race do extract com Spotlight `mds_stores`; testar `mdutil -i off` em sessão futura.

## Próximo passo (após merge)

Continuar M1.3 buffer com itens dos 17 candidatos remaining, ou pular pra M1.4 prova de estudos (sempre antes de M2). Decisão pra próxima sessão.
