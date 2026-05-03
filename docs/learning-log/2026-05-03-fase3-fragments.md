# Learning-log Fase 3 — Fragments (Collection + Hero + Card mapeado + Galeria)

**Data:** 2026-05-02 → 2026-05-03
**Branch:** `feat/m1.2-tema-content-fragments`
**Status:** Fase 3 fechada (Tasks 11 + 12 + 13 + 14 + 15 do plan M1.2 concluídas)
**Tempo investido:** ~5h em 2 sessões

---

## O que tentei

1. **Fragment Collection "Hotel Livingstone Components"** — Site Builder → Design → Fragments → Add Collection. Container para os 3 fragments custom da Fase 3.
2. **Fragment Hero** (HTML/CSS estático, sem mapping) — full-bleed com imagem de fundo, título, subtítulo e CTA. Imagem via `data-lfr-editable-type="image"` editável no Page Editor.
3. **Fragment Card de Quarto com mapping pro Article** — achado canônico do M1.2. Title/subtitle/description/photo/price mapeados pros campos da Structure "Quarto"; CTA do card sem mapping (precisa Display Page Template pra ter URL canônica do Article — Fase 5).
4. **Fragment Galeria** (HTML/CSS estático) — grid 2x2 mobile / 4x1 desktop, 4 imagens livres editáveis no Page Editor.
5. **Page de teste `/teste-fragments`** (Content Page vazia, oculta de navs) — sandbox pra validar os 3 fragments isolados antes de compor as pages reais na Fase 4.
6. **Critério de prova canônico do M1.2:** alterar título do Article "Suíte Carmilla" → reabrir page → card reflete o novo título sem republicar fragment. **Passou.**

---

## O que errei

- **Tentei drag-and-drop via Playwright/CDP** pra automatizar arrastar fragment pro Page Editor. **Não funciona** — Liferay 7.4 GA132 usa react-dnd HTML5 backend, que ouve eventos nativos do mouse (`mousedown`/`mousemove`/`mouseup` REAIS do SO). Dispatch sintético via CDP (`dispatchMouseEvent`) é ignorado pelo backend. Só drag REAL do mouse OU **click "Adicionar X" + Enter** via teclado (modo a11y do Liferay).
- **Tentei click "Adicionar fragment" numa page com layout pré-existente** (Home, que vinha com Contêiner > Grade 2-col + texto "Bem-vindo ao Liferay" gerado pelo wizard) — falhou porque o "primeiro target válido" fica ambíguo entre N drop zones. Fix: criar Content Page nova **completamente do zero** (não a Home) — drop zone fica única, click+Enter funciona.
- **Cliquei direto na imagem do Card no Page Editor** esperando abrir mapping → abriu **Document Picker** (escolher imagem fixa). Mapping de imagem é por outro caminho: **aba "Navegador" (sidebar esquerda 2º ícone) → clicar `card-photo` na árvore** → painel direito troca pra abas Mapear/Link.
- **Não percebi que a page `/teste-fragments` está com tema Classic** (default Liferay), não com `hl-theme`. Fragment funciona standalone porque CSS é interno; mas as vars `--hl-*` do tema não resolvem. Decisão: deixar Classic na page de teste; ativar `hl-theme` é polimento Fase 5 nas pages reais.
- **Article Suíte Carmilla está com texto duplicado na descrição** — renderiza 2x no card. É bug no Article (Fase 2), não no mapping. Fix manual via Conteúdo Web admin (corrigir o campo). Não bloqueia Fase 3.

---

## O que firmou

### Bloco — Onde mora cada coisa (regra mestra do M1.2)

| Camada | Mecanismo | Cobre | Quem edita | Onde mora |
|---|---|---|---|---|
| Casca global | Tema custom (`hl-theme`) | Header, footer, paleta, tipografia | Dev (código) | Repo (FTL/SCSS) |
| Bloco apresentacional | Fragment custom | Card, Hero, Galeria — *como mostrar* | Content creator (Page Editor) | DB Liferay |
| Dado estruturado | Web Content Structure + Article | Quarto — *o que mostrar* | Content creator (Web Content) | DB Liferay |

Fragment é **estrutura visual reutilizável**; Article é **fonte de verdade do dado**. Mapping cola os dois em runtime.

### Bloco — Mapping fragment → Article (achado canônico do M1.2)

Fluxo correto no Liferay 7.4 GA132:

1. **No fragment HTML:** marcar editables individuais (`<h2 data-lfr-editable-id="card-title" data-lfr-editable-type="text">`, etc), **não** wrapper do card inteiro. Pra imagem: `<img data-lfr-editable-id="card-photo" data-lfr-editable-type="image" />`.
2. **Arrastar fragment** pro Page Editor.
3. **Pra texto** (h2/p): clicar no editable → painel DIREITO troca pra abas **Mapear / Link**.
4. **Pra imagem:** clicar direto abre Document Picker (escolher imagem fixa). Pra mapping: usar **aba "Navegador" (sidebar esquerda 2º ícone)** → clicar no editable na árvore (`card-photo`) → painel direito troca pra Mapear/Link.
5. **Aba Mapear → Item:** botão **+** abre modal Web Content → selecionar Article. **Campo:** dropdown popula com Field References da Structure.
6. **Confirmação visual:** sidebar esquerda passa a mostrar `ARTIGO DE CONTEÚDO WEB → Suíte Carmilla (Quarto)`.

**Tipos de editable** (`data-lfr-editable-type`):
- `text` — plain text simples
- `rich-text` — toolbar inline (B/I/link) no Page Editor
- `image` — abre Document Picker (ou Mapear via aba Navegador)
- `link` — abre URL chooser

### Bloco — Aba "Conteúdo da página" como debug visual

Sidebar esquerda 4º ícone abre painel com TODOS os editables da page agrupados:
- **ARTIGO DE CONTEÚDO WEB** — editables mapeados pra Articles
- **DOCUMENTO** — editables de imagem
- **TEXTO EMBUTIDO** — editables estáticos (não mapeados)

Útil pra ver rapidamente o que tá mapeado vs o que ficou estático.

### Bloco — Critério de prova canônico passou

Sequência testada:
1. Card de Quarto na page com 4 mappings ativos pro Article Carmilla
2. Editar Article Carmilla → mudar `title` "Suíte Carmilla" → "REVISADA"
3. Reabrir `/teste-fragments` (sem republicar fragment, sem rebuild)
4. Card mostra "REVISADA" ✅

**Conclusão:** mapping = runtime. Article é fonte de verdade. Fragment é só apresentação. Republicar fragment só é necessário quando muda HTML/CSS (estrutura), não conteúdo.

### Bloco — Drag-and-drop no Liferay 7.4 GA132

| Caminho | Funciona? | Quando usar |
|---|---|---|
| Drag REAL do mouse na UI | ✅ | Default — humano usando |
| Click "Adicionar X" + Enter (teclado/a11y) | ✅ | Page vazia (drop zone única) |
| Click "Adicionar X" + Enter em page com layout | ❌ | "Primeiro target válido" ambíguo |
| `dispatchMouseEvent` via CDP/Playwright | ❌ | react-dnd ouve eventos nativos do SO |
| `dragEvent` HTML5 sintético | ❌ | Mesmo motivo |

Implicação pro M3: **automação E2E de Page Editor não rola via Playwright clássico.** Pra testar páginas montadas vai ter que ser por outro caminho (Page Template via API, Site Initializer, ou screenshot diff).

---

## Dúvidas em aberto / TODOs

| # | TODO | Onde resolve |
|---|---|---|
| 1 | Article Suíte Carmilla com descrição duplicada (renderiza 2x no card) | Fix manual via Conteúdo Web admin — pode resolver na Fase 4 antes de compor Home |
| 2 | Page `/teste-fragments` está em tema Classic, não `hl-theme` (vars `--hl-*` não resolvem) | Polimento Fase 5 — ativar `hl-theme` nas pages reais |
| 3 | Card CTA sem mapping (não tem URL canônica do Article) — precisa Display Page Template | Fase 5 do M1.2 (DPT) ou aceitar como limitação até lá |
| 4 | Fragment com mapping pra Selection múltipla (`amenities`) ainda não testado | Fase 4 ou Fase 5 quando o card crescer pra mostrar amenities |
| 5 | Fragments moram no DB Liferay — sem versionamento via git (mesma limitação herdada M1.1/M1.2) | M2 (Site Initializer) tenta fechar ou plano alternativo |
| 6 | Imagens da Galeria deixadas como placeholders na page de teste — content creator escolhe ao compor pages reais | Fase 4 (Task 16+ — composição das pages) |

---

## Artefatos da Fase 3

| Item | Localização | Notas |
|---|---|---|
| Fragment Collection "Hotel Livingstone Components" | DB Liferay | Container pros 3 fragments |
| Fragment Hero | DB Liferay | Imagem castelo Bran (Romênia, Unsplash photo-1680003935289) |
| Fragment Card de Quarto | DB Liferay | 4 mappings pro Article (`card-title`, `card-subtitle`, `card-description`, `card-photo`); CTA estático |
| Fragment Galeria | DB Liferay | 4 image editables livres, grid 2x2 mobile / 4x1 desktop |
| Content Page "Teste Fragments" | URL `/teste-fragments`, plid 33 | Oculta de navs, sandbox dos fragments |
| Article Suíte Carmilla mapeado no card | StructuredContent id `32655` (Fase 2) | Crítico canônico passou em cima dele |

---

## Decisões consolidadas

1. **Page sandbox separada (`/teste-fragments`)** vs reusar a `/teste` da Fase 2 — escolhida nova page Content (a `/teste` é Widget Page, incompatível com Page Editor de fragments).
2. **`<figure>` envolvendo `<img>` na Galeria** — semântica HTML5 + dá `background` placeholder enquanto imagem não carrega (em vez do `<img>` quebrado feio).
3. **`aspect-ratio: 4/3` fixo + `object-fit: cover`** na Galeria — content creator vai upar imagens de tamanhos variados; isso garante grid uniforme sem distorção.
4. **`loading="lazy"` em todas as imagens da Galeria** — porque fica below-the-fold (Hero vem antes). Se um dia botar Galeria no topo, primeira imagem deveria virar `eager` (LCP / Core Web Vitals).
5. **CSS dos fragments é self-contained** (valores hex + spacing fixos, não vars `--hl-*` do tema) — fragments funcionam standalone independente do tema ativo na page. Trade-off: duplicação de tokens entre tema e fragments. Aceitável pra M1; consolidar via Style Book ou Page Editor settings é polimento Fase 5/M1.3.

---

## Próximo: Fase 4 — Composição das pages

Conforme plan M1.2:
- Task 16: compor Home (Hero full-width + 3 Cards + Galeria com 4 imagens reais)
- Task 17: compor Quartos (Hero + 3 Cards detalhados)
- Task 18: compor Restaurante/Eventos/Sobre/Contato
- Task 19: validar fluxo de navegação E2E (12 pages PT/EN HTTP 200)

Trabalho real começa aqui: **escolher e upar 4 fotos da Galeria via Document & Media** (gothic vibe coerente com Hero/Card/paleta), preencher conteúdo de pages que ainda estão genéricas, validar visual end-to-end.
