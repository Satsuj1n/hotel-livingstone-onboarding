# Cards Redesign Implementation Plan

> **Modo de execução:** **Q&A guiado por task** (regra do projeto Hotel Livingstone — memória `feedback_estilo_comunicacao.md`). Felipe executa via UI Liferay/CLI, Claude valida com tool calls (`curl`, `git status`, `Read`, `Bash`). NÃO usar `superpowers:subagent-driven-development` nem `superpowers:executing-plans` — anti-objetivo de aprendizado. Steps usam checkbox (`- [ ]`) pra tracking visual.

**Goal:** Substituir o fragment "Card de Quarto" e adicionar grid container responsivo na page `/quartos`, conforme spec aprovado em `docs/specs/2026-05-04-cards-redesign-design.md`.

**Architecture:** Fragment Liferay (HTML + CSS armazenados no DB) ganha estrutura nova com 4 amenidades como editables fixos + CTA URL `/contato`. Page Quartos ganha container grid externo (caminho final decidido empiricamente em Task 6 — Section nativa Liferay vs CSS utility no tema). Tema custom `hotellivingstonetheme` recebe utilitário `.hl-card-grid` no `_custom.scss` apenas se Section nativa não der.

**Tech Stack:** Liferay 7.4 CE GA132, Fragment HTML/CSS, FreeMarker (read-only — não tocamos no portal_normal), SCSS no tema (Gradle workspace), CSS Grid `auto-fit`, `aspect-ratio`.

**Branch:** `feat/m1.3-cards-redesign` (já criada em `05090f5`).

**Estimativa:** ~4-6h em 8 tasks (média 30min/task).

---

## File Structure

| Arquivo / Artefato | Tipo | Mudança |
|---|---|---|
| `docs/specs/2026-05-04-cards-redesign-design.md` | Doc no repo | Já commitado em `05090f5` (referência canônica) |
| Fragment "Card de Quarto" (Fragment Collection "Hotel Livingstone Components") | DB Liferay | HTML + CSS substituídos completamente |
| `workspace/themes/hotel-livingstone-theme/src/css/_custom.scss` | Repo | Adicionar `.hl-card-grid` utility (apenas se Task 6 fallback for usado) |
| Page Quartos (`/quartos` no DB Liferay) | DB Liferay | Wrapper grid envolvendo os 3 cards existentes |
| Os 3 cards instanciados na Page Quartos | DB Liferay | Re-mapping (4 amenidades por card + CTA URL `/contato`) |
| `docs/learning-log/2026-05-04-cards-redesign.md` | Repo | Learning-log dos achados de implementação |

**Por que essa decomposição:**

- **Spec → fragment definition → instances → grid → page** é a ordem de dependência natural. Mudar fragment definition antes de mexer nas instâncias evita re-trabalho
- **Tema só toca se grid nativa não funcionar** — evita commit no tema se a opção idiomática Liferay (Section nativa) cobrir
- **Learning-log no fim** — captura achados que aparecem só durante execução (gotchas Liferay 7.4 GA132, escolha real do grid container, mapping quirks)

---

## Task 1: Branch sanity + baseline visual

**Files:**
- N/A (só validação + screenshot baseline)

- [ ] **Step 1: Confirmar branch e working tree**

Run: `git branch --show-current && git status`
Expected: `feat/m1.3-cards-redesign` + `nothing to commit, working tree clean`

- [ ] **Step 2: Confirmar Liferay up**

Run:
```bash
curl -s -o /dev/null -w "Quartos PT: %{http_code} | EN: " http://localhost:8081/pt-BR/web/hotel-livingstone/quartos && curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8081/en-US/web/hotel-livingstone/rooms
```
Expected: `Quartos PT: 200 | EN: 200`

Se HTTP 000: Felipe sobe Liferay com `cd workspace && blade server run` em terminal separado.

- [ ] **Step 3: Capturar HTML baseline do primeiro card pra comparar depois**

Run:
```bash
curl -s "http://localhost:8081/pt-BR/web/hotel-livingstone/quartos" | python3 -c "
import sys, re
html = sys.stdin.read()
m = re.search(r'<article class=\"hl-card\".*?</article>', html, re.DOTALL)
print(m.group(0) if m else 'NÃO ENCONTROU')
" > /tmp/card-baseline.html
wc -l /tmp/card-baseline.html
```
Expected: arquivo criado, com 15-25 linhas

Esse arquivo serve de comparação visual quando reaplicarmos a renderização no fim.

- [ ] **Step 4: Felipe abre Page Editor da page Quartos no browser pra ver baseline**

URL: `http://localhost:8081/web/hotel-livingstone/quartos?p_l_mode=edit`

Confirmar visualmente: 3 cards um embaixo do outro, sem amenidades, CTA "Ver detalhes" com `href="#"`.

---

## Task 2: Substituir HTML do fragment Card de Quarto

**Files:**
- DB Liferay: Fragment "Card de Quarto" (`Site Administration → Site Builder → Fragments → Hotel Livingstone Components → Card de Quarto`)

- [ ] **Step 1: Felipe abre o fragment no Fragment Editor**

Caminho na UI: menu hamburguer → Site Hotel Livingstone → **Site Builder → Fragments → Hotel Livingstone Components → Card de Quarto** → click no nome do fragment pra abrir.

Vai abrir um editor com 3 abas/painéis: HTML, CSS, e às vezes Configuration. Foca na aba HTML.

- [ ] **Step 2: Substituir o conteúdo da aba HTML pelo novo**

Selecionar tudo (Cmd+A) na aba HTML e colar o novo conteúdo:

```html
<article class="hl-card">
  <picture data-lfr-editable-id="card-photo" data-lfr-editable-type="image">
    <img class="hl-card__photo"
         src=""
         alt="Foto do quarto" />
  </picture>

  <div class="hl-card__body">
    <h2 class="hl-card__title"
        data-lfr-editable-id="card-title"
        data-lfr-editable-type="text">Suíte Carmilla</h2>

    <p class="hl-card__subtitle"
       data-lfr-editable-id="card-subtitle"
       data-lfr-editable-type="rich-text">Charme íntimo entre rosas e velas</p>

    <div class="hl-card__amenities">
      <span class="hl-card__amenity"
            data-lfr-editable-id="amenity-1"
            data-lfr-editable-type="text">Vista panorâmica</span>
      <span class="hl-card__amenity"
            data-lfr-editable-id="amenity-2"
            data-lfr-editable-type="text">Lareira</span>
      <span class="hl-card__amenity"
            data-lfr-editable-id="amenity-3"
            data-lfr-editable-type="text">Banheira</span>
      <span class="hl-card__amenity"
            data-lfr-editable-id="amenity-4"
            data-lfr-editable-type="text">Wi-Fi</span>
    </div>

    <div class="hl-card__footer">
      <p class="hl-card__price">
        A partir de <strong data-lfr-editable-id="card-price"
                            data-lfr-editable-type="text">720</strong>
        / noite
      </p>
      <a href="#"
         class="hl-btn hl-btn--small"
         data-lfr-editable-id="card-cta"
         data-lfr-editable-type="link">Ver detalhes</a>
    </div>
  </div>
</article>
```

- [ ] **Step 3: NÃO publicar ainda** — só salvar como rascunho (botão "Salvar"). CSS vem na Task 3.

Validar: a aba HTML deve mostrar o novo código sem warning de syntax error.

---

## Task 3: Substituir CSS do fragment Card de Quarto

**Files:**
- DB Liferay: mesma fragment, aba CSS

- [ ] **Step 1: Trocar pra aba CSS**

Continua no mesmo editor de fragment.

- [ ] **Step 2: Substituir o conteúdo da aba CSS**

Selecionar tudo (Cmd+A) e colar:

```css
.hl-card {
  background: var(--hl-surface, #24253A);
  border-radius: var(--hl-radius-md, 12px);
  overflow: hidden;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.3);
  transition: transform 0.25s ease-out, box-shadow 0.25s ease-out;
  display: flex;
  flex-direction: column;
}

.hl-card:hover {
  transform: translateY(-6px);
  box-shadow: 0 12px 32px rgba(0, 0, 0, 0.5),
              0 0 0 1px rgba(189, 147, 249, 0.2);
}

.hl-card__photo {
  width: 100%;
  aspect-ratio: 16 / 10;
  object-fit: cover;
  display: block;
}

.hl-card__body {
  padding: var(--hl-spacing-lg, 24px);
  flex: 1;
  display: flex;
  flex-direction: column;
}

.hl-card__title {
  margin: 0 0 6px;
  font-size: 22px;
  font-weight: 600;
  letter-spacing: -0.01em;
  line-height: 1.2;
  color: var(--hl-text);
}

.hl-card__subtitle {
  margin: 0 0 16px;
  color: var(--hl-text-muted);
  font-size: 14px;
  line-height: 1.5;
  font-style: italic;
}

.hl-card__amenities {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-bottom: 20px;
}

.hl-card__amenity {
  font-size: 11px;
  padding: 4px 10px;
  background: rgba(189, 147, 249, 0.12);
  color: var(--hl-primary);
  border-radius: 999px;
  font-weight: 500;
}

.hl-card__footer {
  margin-top: auto;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-top: 16px;
  border-top: 1px solid rgba(255, 255, 255, 0.08);
}

.hl-card__price {
  font-size: 14px;
  color: var(--hl-text-muted);
  margin: 0;
}

.hl-card__price strong {
  font-size: 20px;
  color: var(--hl-primary);
  font-weight: 600;
  margin-right: 2px;
}

.hl-btn--small {
  font-size: 12px;
  padding: 8px 16px;
  background: var(--hl-primary);
  color: var(--hl-bg, #1a1b26);
  border-radius: 8px;
  font-weight: 600;
  text-decoration: none;
  transition: background 0.2s;
}

.hl-btn--small:hover {
  background: var(--hl-pink);
}
```

- [ ] **Step 3: Salvar** (rascunho, ainda não publicar)

- [ ] **Step 4: Validar preview no painel direito do Fragment Editor**

O Fragment Editor mostra preview live. Validar visualmente:
- Card com background `--hl-surface` (azul-roxo escuro)
- Foto ocupando area 16:10 (vazia até mapping — esperado)
- Título "Suíte Carmilla" em branco bold
- Subtítulo "Charme íntimo entre rosas e velas" em itálico cinza
- 4 pills "Vista panorâmica / Lareira / Banheira / Wi-Fi" em roxo translúcido
- Linha divisória + preço "A partir de R$ **720** / noite" + botão "Ver detalhes" roxo

Se algo errado: revisar HTML/CSS no editor antes de publicar.

---

## Task 4: Publicar fragment + validar standalone

**Files:**
- DB Liferay: fragment publicação

- [ ] **Step 1: Publicar o fragment**

No Fragment Editor, botão "Publicar" (ou kebab → Publicar). Confirma.

A partir daqui o fragment é visível em todas as instâncias dele em pages do site.

- [ ] **Step 2: Curl da page Quartos pra ver HTML novo**

Run:
```bash
curl -s "http://localhost:8081/pt-BR/web/hotel-livingstone/quartos" | grep -E "hl-card__amenity|hl-card__subtitle|hl-card__title" | head -5
```
Expected: linhas com `hl-card__title`, `hl-card__subtitle`, `hl-card__amenity` (presentes no HTML, mostrando que a estrutura nova está renderizando).

- [ ] **Step 3: Validar adaptive media ainda funciona**

Run:
```bash
curl -s "http://localhost:8081/pt-BR/web/hotel-livingstone/quartos" | grep -oE '<source media[^>]*>' | head -2
```
Expected: pelo menos 1 linha mostrando `<source media="(max-width:300px)" srcset="...">` (Liferay continua injetando adaptive media nas `<picture>` mesmo com nossa mudança).

Se NÃO retornar nada: investigar — possivelmente o mapping da imagem precisa ser refeito (Task 5 cobre isso).

---

## Task 5: Re-mapear os 3 cards na Page Quartos

**Context:** Os 3 cards na page Quartos foram mapeados na Fase 4 com a estrutura ANTIGA. Agora com novos editable IDs (`card-title`, `card-subtitle`, `card-photo`, `card-price`, `card-cta` + 4 amenities), o mapping pode ter ficado órfão. Precisamos re-mapping.

**Files:**
- DB Liferay: instances dos 3 cards na page `/quartos`

- [ ] **Step 1: Felipe abre Page Editor da Quartos**

URL: `http://localhost:8081/web/hotel-livingstone/quartos?p_l_mode=edit`

Achado da Fase 4: Page Editor pode crashar com layout default quebrado. Se crashar com "Erro inesperado ao renderizar este item", workaround: deletar a page e recriar com template "Vazio", depois re-adicionar Hero + 3 Cards. **Pausa o Felipe pra reportar se travar — não force.**

- [ ] **Step 2: Para cada um dos 3 cards (Carmilla, Lestat, Drácula), re-mapping:**

Sequência por card:
- Click no editable individual `card-title` → painel direito → Mapear → escolher Article correspondente (Suíte Carmilla / Suíte Lestat / Suíte Drácula) → Field: **Title** (seção "Informação Básica")
- Click no `card-subtitle` → Mapear → mesmo Article → Field: **Subtítulo** (seção "Conteúdo (Quarto)")
- Click no `card-price` → Mapear → mesmo Article → Field: **Preço** (Conteúdo (Quarto))
- Aba **Navegador** (sidebar esquerda 2º ícone) → click `card-photo` na árvore → Mapear → mesmo Article → Field: **Foto** (Conteúdo (Quarto)). Click direto na imagem abre Document Picker (não mapping) — usar Navegador

- [ ] **Step 3: Para cada card, editar amenidades (texto livre por instance):**

Click em cada amenity individualmente e digitar:

| Card | amenity-1 | amenity-2 | amenity-3 | amenity-4 |
|---|---|---|---|---|
| Suíte Carmilla | Vista panorâmica | Lareira | Banheira | Wi-Fi |
| Suíte Lestat | Varanda privativa | Banheira de pedra | Lareira | Wi-Fi |
| Suíte Drácula | Master | Jacuzzi | Vitral | Sala de leitura |

(Felipe pode customizar — esses são placeholders coerentes com o mockup)

- [ ] **Step 4: Para cada card, editar CTA:**

Click em `card-cta` (botão "Ver detalhes") → painel direito → aba **Link** → digitar URL `/contato` → confirmar.

Em todos os 3 cards.

- [ ] **Step 5: Publicar a Page Quartos**

Botão "Publicar" no Page Editor. Confirma.

- [ ] **Step 6: Validar HTML pós-publish**

Run:
```bash
curl -s "http://localhost:8081/pt-BR/web/hotel-livingstone/quartos" | grep -oE 'class="hl-card__amenity"[^>]*>[^<]+' | head -8
```
Expected: 8-12 linhas mostrando textos como `Vista panorâmica`, `Lareira`, `Varanda privativa`, etc. (3 cards × 4 amenities).

```bash
curl -s "http://localhost:8081/pt-BR/web/hotel-livingstone/quartos" | grep -oE 'href="/contato"[^>]*>Ver detalhes' | wc -l
```
Expected: `3` (3 CTAs apontando pra `/contato`).

---

## Task 6: Aplicar grid container — investigação empírica

**Context:** O spec lista 3 caminhos. Vamos tentar opção 1 (Section nativa Liferay com Grid) primeiro. Se não der, fallback opção 3 (CSS utility no tema).

**Files:**
- DB Liferay: page `/quartos` (wrapper grid)
- Possivelmente: `workspace/themes/hotel-livingstone-theme/src/css/_custom.scss` (apenas se fallback)

- [ ] **Step 1: Felipe explora a UI do Page Editor procurando "Grid" ou "Container" com layout customizável**

No Page Editor da Quartos, sidebar esquerda tem painéis "Fragments" e "Layout Elements" (ou "Elementos de Layout"). Procurar por:
- "Grid" / "Grade"
- "Container"
- "Section" / "Seção"

**Validar empiricamente:** o componente expõe configuração de `grid-template-columns: repeat(auto-fit, minmax(...))` ou equivalente?

Achado típico Liferay 7.4 GA132: Section permite escolher número de colunas (1, 2, 3, 4, 6, 12) mas é **fixo** — não é auto-fit. Isso provavelmente força fallback pra opção 3.

- [ ] **Step 2: Se Section/Grid nativa expor auto-fit:**

Aplicar Section ao redor dos 3 cards existentes:
1. Adicionar Section vazia acima dos cards
2. Drag cards pra dentro da Section
3. Configurar Section com auto-fit `minmax(300px, 1fr)` + gap 24px + max-width 1200px
4. Pular pra Step 5 (validação)

- [ ] **Step 3: Se Section nativa NÃO expor auto-fit (caminho esperado):**

Fallback opção 3 — CSS utility no tema.

Felipe adiciona este CSS ao `workspace/themes/hotel-livingstone-theme/src/css/_custom.scss` (no fim do arquivo):

```scss
// Grid container responsivo pra cards (M1.3 cards-redesign)
.hl-card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 24px;
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 16px;
}
```

Build + deploy do tema:
```bash
cd ~/Documents/SEA/hotel-livingstone-onboarding/workspace
./gradlew :themes:hotel-livingstone-theme:deploy
```

Aguarda ~30s. Logs do `blade server run` mostram `STARTED hotel-livingstone-theme_WAR_hotellivingstonetheme`.

- [ ] **Step 4: Aplicar a classe `.hl-card-grid` na page Quartos**

Adicionar Section neutra no Page Editor da Quartos envolvendo os 3 cards. Configurar a Section com **CSS class custom** = `hl-card-grid` (campo "CSS Class" ou "Classes" nas opções da Section).

Caminho típico: click na Section → painel direito → aba "Estilos" ou kebab → campo "CSS Classes" → digitar `hl-card-grid`.

Publicar a page.

- [ ] **Step 5: Validar grid via curl + DevTools**

Run:
```bash
curl -s "http://localhost:8081/pt-BR/web/hotel-livingstone/quartos" | grep -oE 'class="[^"]*hl-card-grid[^"]*"' | head -1
```
Expected: linha com `class="... hl-card-grid ..."` (ou similar).

Se Step 2 (Section nativa): confirmar inline style ou class equivalente no curl.

- [ ] **Step 6: Hard-refresh no browser**

Felipe abre `http://localhost:8081/web/hotel-livingstone/quartos` e Cmd+Shift+R. Esperado: 3 cards lado a lado em desktop wide, com gap entre eles.

- [ ] **Step 7: Commit do CSS no tema (apenas se fallback opção 3 foi usado)**

```bash
cd ~/Documents/SEA/hotel-livingstone-onboarding
git add workspace/themes/hotel-livingstone-theme/src/css/_custom.scss
git commit -m "feat(theme): adicionar utilitario .hl-card-grid

Grid responsivo auto-fit pra cards. Decisao Task 6 do plan
cards-redesign — Section nativa Liferay 7.4 nao expoe auto-fit
na UI, fallback pra CSS utility no tema."
```

Se opção 1 (Section nativa) cobriu: nada pra commitar — todo o trabalho fica no DB Liferay.

---

## Task 7: Validação E2E + responsividade

**Files:**
- N/A (validação only)

- [ ] **Step 1: HTTP 200 em todas as 12 chamadas (PT/EN × 6 pages)**

Run:
```bash
echo "=== PT-BR ==="
for slug in home quartos restaurante eventos sobre contato; do
  result=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8081/pt-BR/web/hotel-livingstone/$slug")
  echo "  /$slug → HTTP $result"
done
echo ""
echo "=== EN-US ==="
for slug in home rooms restaurant events about contact; do
  result=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8081/en-US/web/hotel-livingstone/$slug")
  echo "  /$slug → HTTP $result"
done
```
Expected: 12/12 HTTP 200.

Se algum não for 200: pause e investigar. Mudança em fragment global pode ter quebrado page que usa o fragment em outro lugar.

- [ ] **Step 2: Critério de pronto do spec — checklist de validação**

Validar cada item do critério (linhas 259-269 do spec):

1. ✓ Visual Refined Premium aplicado — confirmar visualmente em `/quartos`
2. ✓ Grid responsivo — testar em 3 viewports (DevTools Toggle device toolbar): 375px / 768px / 1280px
3. ✓ Amenidades pills — confirmar 3-4 pills da paleta primary em cada card
4. ✓ CTA → `/contato` — click em "Ver detalhes" leva pra page de contato
5. ✓ Adaptive media — Step 3 da Task 4 já validou
6. ✓ HTTP 200 PT/EN — Step 1 desta task
7. ✓ Sem hardcode de cores — confirma no código que CSS aplicado usa `var(--hl-*)` (já assegurado pelo CSS do spec)

- [ ] **Step 3: Hover state**

Felipe passa o mouse sobre 1 card no `/quartos`. Confirma:
- Card sobe levemente (translateY -6px)
- Sombra aumenta
- Ring sutil roxo aparece

Se hover não aparece: cache do browser — Cmd+Shift+R. Se ainda não aparece: validar CSS deployed no curl `<style>` injetado.

- [ ] **Step 4: Mobile (375px)**

DevTools → Toggle device toolbar → iPhone 12 Pro (390px) ou Pixel 5 (393px).

Esperado: 1 coluna, cards full-width com padding nas laterais (do `.hl-card-grid` padding 16px), foto e texto legíveis.

- [ ] **Step 5: Tablet (768px)**

DevTools → resize manual pra ~768px.

Esperado: 2 colunas (porque `minmax(300px, 1fr)` cabe 2 cards de 300+gap+300 em 768px).

- [ ] **Step 6: Desktop wide (1280px+)**

Voltar ao tamanho normal do browser.

Esperado: 3 colunas de cards.

---

## Task 8: Learning-log + commit + merge

**Files:**
- `docs/learning-log/2026-05-04-cards-redesign.md` (novo)
- Repo: commit + push + merge

- [ ] **Step 1: Criar learning-log**

Documentar achados de implementação relevantes:
- Qual caminho de grid container venceu (opção 1 ou 3)
- Se Page Editor crashou ao re-editar (Risco #1 do spec)
- Se mapping de imagem com `<picture>` envolvendo `<img>` deu trabalho (Risco #3)
- Diferenças entre o que estava no spec vs o que precisou ajustar
- Tempo total real vs estimado (~4-6h)

Estrutura padrão (igual aos learning-logs anteriores em `docs/learning-log/`):

```markdown
# Learning Log — Cards Redesign (M1.3 antecipado)

**Data:** 2026-05-04
**Branch:** `feat/m1.3-cards-redesign`
**Spec:** `docs/specs/2026-05-04-cards-redesign-design.md`
**Plan:** `docs/plans/2026-05-04-cards-redesign.md`

## O que foi feito

[lista de entregas com paths/IDs]

## Achados-chave

[bullets com descobertas durante a implementação]

## Pendências carregadas

[itens que apareceram e foram movidos pra M1.3 buffer continuação]
```

- [ ] **Step 2: Commit do learning-log**

```bash
cd ~/Documents/SEA/hotel-livingstone-onboarding
git add docs/learning-log/2026-05-04-cards-redesign.md
git commit -m "docs(m1.3): learning-log do cards redesign"
```

- [ ] **Step 3: Push da branch**

```bash
git push -u origin feat/m1.3-cards-redesign
```

- [ ] **Step 4: Merge em main**

```bash
git checkout main
git merge --no-ff feat/m1.3-cards-redesign -m "merge: M1.3 cards redesign — fragment + grid responsivo"
git push origin main
```

- [ ] **Step 5: Cleanup branch**

```bash
git branch -d feat/m1.3-cards-redesign
git push origin --delete feat/m1.3-cards-redesign
```

- [ ] **Step 6: Validação final pós-merge**

```bash
git log --oneline --graph --decorate -5
git branch
git status
```
Expected:
- HEAD em merge commit em `main`
- Apenas `main` viva (local + origin)
- `nothing to commit, working tree clean`

- [ ] **Step 7: Atualizar memória do projeto**

Atualizar `~/.claude/projects/-Users-felipelima-Documents-SEA/memory/project_hotel_livingstone_onboarding.md` seção "Estado atual" com:
- M1.3 buffer iniciado em 2026-05-04 com cards redesign (1º item dos 18 candidatos)
- Branch deletada
- Próximos itens do M1.3 buffer prováveis: fotos próprias dos Cards, refactor Template Quarto, responsividade do Hero/Footer

---

## Notas de execução (não tasks)

- **Conflito ES sidecar GDF×Hotel** — se durante o plan o Felipe precisar parar o Liferay Hotel pra trabalhar com o GDF, lembrar que ES roda na 9200/9201 e os 2 brigam. Parar 1 antes de subir o outro
- **Achado da Fase 4 que continua válido:** mapping de fragment via Chrome DevTools MCP é não-confiável — drag REAL do mouse continua sendo o caminho
- **Bug `themeDisplay.getURLHome()`** — não afeta este plan (CTA usa URL `/contato` direto, não macro do tema)
