# Spec — Redesign do Fragment Card de Quarto + grid responsivo

| Campo | Valor |
|---|---|
| **Data** | 2026-05-04 |
| **Status** | Aprovado (brainstorm 2026-05-04 com mockups visual companion) |
| **Decisor** | Felipe Lima |
| **Branch alvo** | `feat/m1.3-cards-redesign` (a criar) |
| **Milestone** | M1.3 (buffer condicional) — antecipação de Task 21 que tinha sido cortada da Fase 5 |
| **Estimativa** | ~4-6h |

## Contexto

O fragment **Card de Quarto** foi entregue na Fase 3 do M1.2 com estrutura mínima funcional (foto + título + subtítulo poético + preço + CTA). Em produção (`/quartos`), os 3 cards renderizam **um embaixo do outro** sem container grid externo, sem responsividade explícita, e com amenidades **não renderizadas** (apesar do field `amenities` existir na Web Content Structure "Quarto" como Selection múltipla).

Pendências cobertas neste spec (vinham herdadas das retrospectivas M1.1/M1.2):
- "Cards 1 coluna mobile, Header colapsa em hamburger" (Task 21 cortada da Fase 5)
- "Fotos próprias dos Cards (Carmilla/Lestat/Drácula) — qualidade aquém pro aspect ratio" — adoção de `aspect-ratio: 16/10` cria target claro de framing pras fotos próprias virem
- "Bug descrição duplicada Article Carmilla" — não resolvido aqui (é fix no Article via Web Content admin, não no fragment)

## Objetivos

- **G1.** Resolver "um embaixo do outro" — grid responsivo auto-fit que escala de 1 a N cards sem quebrar visual
- **G2.** Subir o nível visual dos cards mantendo identidade Dracula+Apple dark (paleta `--hl-*` do tema sem hardcode)
- **G3.** Adicionar amenidades como pills clicáveis (4 max por card) editáveis por instance
- **G4.** Redirecionar CTA "Ver detalhes" pra `/contato` (UX real até existir Display Page por quarto no M2/M3)

## Decisões aprovadas (brainstorm)

| # | Decisão | Escolha | Alternativa descartada |
|---|---|---|---|
| 1 | Direção visual | **A — Refined Premium** (clean, sombra sutil, paleta gothic em accents) | B Editorial Gothic (foto vertical full-bleed, serif itálica), C Glassmorphism Luxe (blur + gradient text) |
| 2 | Layout grid em desktop | **A — Auto-fit responsivo** (`repeat(auto-fit, minmax(300px, 1fr))`) | B 2 colunas sempre + 3º centralizado |
| 3 | Escopo de conteúdo | **B — Meio-termo** (subtítulo poético + amenidades pills + preço + CTA "Ver detalhes") | A mínimo viável (sem amenidades), C máximo (subtítulo + descrição funcional + amenidades) |
| 4 | Renderização de amenidades | **A — 4 editables fixos** (`amenity-1` a `amenity-4`, type `text`, livre por instance) | B Display Page Template + FreeMarker (mantém sync com Article mas adiciona infra), C Editor Configuration do fragment |
| 5 | Destino do CTA "Ver detalhes" | **B — URL `/contato`** (UX real pra M1 — leva pra page de contato existente) | A `href="#"` placeholder, C Display Page por quarto (M2/M3) |

## Estrutura HTML do fragment (final)

Substitui o HTML atual do fragment "Card de Quarto" (Fragment Collection "Hotel Livingstone Components"). Estrutura semântica + `data-lfr-editable-*` pra mapping no Page Editor:

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

**Notas estruturais:**
- `<picture>` agora envolve a `<img>` editável pra compatibilidade com adaptive media do Liferay (mantém comportamento de hoje — Liferay injeta `<source>` automaticamente quando o mapping liga foto Article → editable image)
- `<strong>` envolvendo só o número do preço — mantém pattern atual onde "A partir de R$" e "/ noite" são literais e o número é o editable
- 4 amenities fixas — overflow visual cabe em 1 ou 2 linhas dependendo do tamanho dos textos. Cards no mockup mostram tanto 3 quanto 4 funcionando

## CSS contract (a aplicar)

CSS do fragment substitui completamente o atual. Mantém uso de CSS vars do tema — sem hardcode.

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

## Grid container — onde aplicar

O fragment Card hoje renderiza um `<article>` por instance, sem container envolvente. Pra fazer 3 cards lado a lado em desktop, precisamos de **um container grid externo** envolvendo as instâncias do Card na page Quartos.

3 caminhos viáveis no Liferay 7.4:

1. **Section nativa do Liferay com grid layout** — Liferay 7.4 oferece "Grid" como componente de layout no Page Editor. Configurar a grid com 3 colunas em desktop e arrastar 3 Cards dentro. Caminho mais idiomático Liferay.
2. **Fragment "Cards Grid" customizado** — fragment com 1 drop zone que aceita N cards filhos, com `display: grid` no CSS. Mais reutilizável mas adiciona infra.
3. **CSS no tema com seletor `.hl-card-grid`** — adicionar classe utilitária no tema (`workspace/themes/hotel-livingstone-theme/src/css/_custom.scss`) e envolver os cards num container HTML que use essa classe via "Section" do Page Editor com classe customizada.

**Escolha:** opção **1 (Grid nativa do Liferay)** se a UI permite configurar `grid-template-columns: repeat(auto-fit, minmax(300px, 1fr))` ou equivalente. Senão, **opção 3** (utilitário no tema). A escolha final será validada empiricamente durante o plan — Liferay 7.4 GA132 evoluiu nesse aspecto e nem toda config CSS de grid é exposta na UI.

**Spec do grid (independente do caminho de implementação):**

```css
.hl-card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 24px;
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 16px;
}
```

Esse CSS — em qualquer um dos 3 caminhos — vive em **um lugar só** (preferencialmente no `_custom.scss` do tema, exportado como utilitário de layout reutilizável em outras pages do hotel).

## Mapping (Page Editor)

Pra cada instance de Card na page `/quartos`, o usuário (Felipe) faz mapping no Page Editor:

| Editable ID | Tipo | Mapeia pra | Origem |
|---|---|---|---|
| `card-photo` | image | Field `photo` da Structure Quarto | Web Content Article |
| `card-title` | text | Field **Title** do Article (metadata) | Web Content Article |
| `card-subtitle` | rich-text | Field `subtitle` da Structure Quarto | Web Content Article |
| `amenity-1` a `amenity-4` | text | **Não mapeado** — texto livre por instance | Editado direto no Page Editor |
| `card-price` | text | Field `price` da Structure Quarto | Web Content Article |
| `card-cta` | link | **Não mapeado** — `href="/contato"` setado por instance | Editado direto no Page Editor |

**Observação importante:** o mapping de `card-cta` é por instance, não pelo fragment default. Default do fragment é `href="#"` — Felipe edita pra `/contato` em cada um dos 3 cards.

**Achado da Fase 3 que vale lembrar:** mapping de imagem requer aba **Navegador** da sidebar esquerda (não click direto na foto, que abre Document Picker).

## Out of scope

Coisas que poderiam parecer parte deste redesign mas NÃO entram:
- **Display Page Template por Quarto** — fica pro M2/M3 quando booking ou detalhes longos justificarem
- **CTA "Reservar" funcional** — projeto não tem booking real até o M3+
- **Fotos próprias dos Cards** — ficam pendentes (substituição de imagem é trabalho separado, faz parte da pendência M1.3 mas não é parte deste fragment redesign)
- **Refactor do Template "Quarto Default"** (dictionary `amenityLabels` redundante) — pendência separada do M1.3
- **Bug descrição duplicada Article Carmilla** — fix no Article via Web Content admin, não no fragment
- **Investigação Primary Navigation Menu setting** — pendência herdada da Fase 2, separada

## Pendências e dependências

- **Depende de:** Liferay rodando + Site Hotel Livingstone + 3 Articles "Suíte" publicados + tema `hotellivingstonetheme` aplicado per-page (estado pós-M1.2)
- **Bloqueia:** nada — é antecipação opcional do M1.3 buffer

## Critério de pronto

Após implementação, deve cumprir:

1. **Visual** — 3 cards em `/quartos` renderizando no estilo Refined Premium aprovado, com hover sutil ativo
2. **Grid responsivo** — em desktop wide (≥1024px) os 3 cards ficam em 3 colunas; em tablet (~768px) em 2 colunas; em mobile (<480px) em 1 coluna. Validar via Chrome DevTools Toggle device toolbar nos 3 viewports
3. **Amenidades pills** — cada card mostra 3-4 amenidades como pills da paleta primary, editadas por instance (text livre por card)
4. **CTA** — botão "Ver detalhes" leva pra URL `/contato` (page de contato existente do site, em ambos locales PT-BR e EN-US)
5. **Adaptive media** — `<picture>` continua com `<source>` srcset gerado automaticamente pelo Liferay (validar via curl ver se `<source media=...` aparece no HTML)
6. **HTTP 200 PT/EN** mantido — `/quartos` e `/rooms` ambos renderizam sem erro
7. **Sem hardcode de cores** — todos os valores de cor no CSS usam `var(--hl-*)` do tema

## Arquivos afetados

- **Fragment "Card de Quarto"** (DB Liferay) — HTML + CSS substituídos
- **Tema `hotellivingstonetheme`** (`workspace/themes/hotel-livingstone-theme/src/css/_custom.scss`) — adicionar utilitário `.hl-card-grid` se a opção 3 for escolhida
- **Page Quartos** (DB Liferay) — wrapper grid (Section nativa Liferay ou fragment Cards Grid) envolvendo os 3 cards existentes
- **`docs/learning-log/2026-05-04-cards-redesign.md`** — novo learning-log documentando achados de implementação

## Riscos

| # | Risco | Prob | Impacto | Mitigação |
|---|---|---|---|---|
| 1 | Page Editor crash ao re-editar a page Quartos (achado da Fase 4) | M | M | Se acontecer, deletar+recriar a page Quartos com template Vazio (workaround documentado) |
| 2 | Grid nativa do Liferay 7.4 não expõe `auto-fit` na UI | M | B | Fallback pra opção 3 (CSS utility no tema) |
| 3 | Mapping de imagem quebrar com a mudança pra `<picture>` envolvendo `<img>` | B | M | Validar via Page Editor que mapping continua funcionando após save do fragment novo |
| 4 | 4 amenidades fixas serem insuficientes pra algum quarto futuro | B | B | Aceitável no M1; M2 pode evoluir pra fragment com configuration de N amenidades |
