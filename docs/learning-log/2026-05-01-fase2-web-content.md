# Learning-log Fase 2 — Web Content (Structure + Template + 3 Articles)

**Data:** 2026-05-01
**Branch:** `feat/m1.2-tema-content-fragments`
**Status:** Fase 2 fechada (Tasks 8 + 9 + 10 do plan M1.2 concluídas)
**Tempo investido:** ~3h em 1 sessão (incluindo battle Headless API)

---

## O que tentei

1. **Structure "Quarto" via UI** — Site Builder → Conteúdo Web → Estruturas → Novo. 6 campos: `title`, `subtitle`, `description`, `photo`, `price`, `amenities`. Field References em inglês kebab/camelCase, Localizable só nos textuais (title/subtitle/description/amenities), required nos críticos.
2. **Template "Quarto Default" em FreeMarker** — renderiza 1 Article completo (h1+subtítulo+foto+desc+preço+lista de amenities). Sintaxe `${field.getData()}`, `<#if ?has_content>`, `<#list>`, `<#attempt>/<#recover>`.
3. **3 Articles via UI** (Carmilla) + **2 via Headless Delivery API** (Lestat/Drácula) — fallback pra UI quando API quebrou.
4. **Validar render do Template** via Web Content Display widget numa Widget Page de teste oculta da nav (`/teste`).

---

## O que errei

- **Pulei do plan: amenities Text Repeatable → Selection múltipla.** O plan original previa Repeatable (digitar livre). Selection é melhor (vocabulário fixo, sem variação tipo "Wi-Fi"/"WiFi"/"WIFI"). Registrado como desvio consciente.
- **Achei que `${field.getData()}` em Selection múltipla retornava keys técnicas** — na verdade retorna **labels traduzidos no locale corrente**. O JSON real do Article tem campo dual: `data` (labels) + `value` (keys). Conclusão: o `<#assign amenityLabels = {...} />` no Template é **redundante** — está fazendo lookup numa estrutura que já vem traduzida.
- **Confiei na memória da Fase 1** que dizia `nav_items` renderiza Navigation Menu Principal automaticamente. Não é verdade — `nav_items` em parent Styled lê **Public Pages do site**. Por isso a page "Teste" apareceu no header mesmo sem ser adicionada ao Menu Principal.
- **Insisti ~10min na Headless Delivery POST** apesar do erro genérico "No value defined for field name" não dar pista. Custo-benefício pior que voltar pra UI (10min total pros 2 Articles).
- **Colei texto Rich Text com markdown `**bold**`** — Liferay Rich Text editor quer HTML/toolbar. Os `**` ficaram literais. Fix manual: selecionar trechos + botão **B**.
- **Esqueci de marcar "Hide from Navigation Menus"** ao criar a Widget Page de teste — apareceu como item "Teste" no header do site.

---

## O que firmou

### Bloco — 3 templates do Liferay (não confundir)

| Tipo | Cobre | Onde mora |
|---|---|---|
| **Web Content Template** | renderização do conteúdo (FTL → bloco HTML) | Conteúdo Web → aba Modelos |
| **Display Page Template** | página inteira (header + slot do Article + footer) — usado quando se acessa URL canônica do Article | Site Builder → Page Templates |
| **Application Display Template (ADT)** | renderização de widgets (Asset Publisher, Nav, etc.) | Site Builder → Application Display Templates |

Os 3 são DDMTemplate por baixo (mesma tabela), mas com `classNameId` diferente.

### Bloco — Pipeline canônico

```
Structure (schema)  ←  define os campos
   │
   ▼
Template (FTL)  ←  consome ${field.getData()} dos campos
   │
   ▼
Article (instância preenchida)  ←  conteúdo real
   │
   ▼ (renderizado por Web Content Display widget OU Display Page Template OU Asset Publisher)
HTML
```

Relação: 1 Structure : N Templates : N Articles. Pode ter múltiplos Templates pro mesmo schema (`card-compact`, `hero-large`, `table-row`).

### Bloco — Field References são contrato

Field Reference (key técnica) é o nome usado em `${title.getData()}` no FTL. Sempre em **inglês kebab/camelCase**, manual — Liferay 7.4 não deriva bem do Label PT-BR (geraria `titulo` ou `tItulo`). Não muda depois que Articles existirem (quebra Templates e Articles).

### Bloco — Selection múltipla: keys vs labels

Schema gerado pela UI tem 2 níveis:
- `option.label` = display PT-BR (Wi-Fi, Ar-condicionado...)
- `option.value` = key técnica (Liferay auto-gera `Opção22543873` se você não preencher; eu preenchi `wifi`/`tv`/etc. manualmente)

No Article preenchido, o JSON do field tem:
```json
"contentFieldValue": {
    "data": "[\"TV\",\"Ar-condicionado\",\"Wi-Fi\",\"Banheira\",\"Vista para o jardim\"]",
    "value": "[\"tv\",\"air-conditioning\",\"wifi\",\"bathtub\",\"garden-view\"]"
}
```

`getData()` no FTL retorna `data` (labels). `getValue()` se existir retornaria `value` (keys). **Comportamento NÃO documentado claramente** — descoberto empiricamente via Headless API.

---

## Dúvidas em aberto / TODOs

| # | TODO | Onde resolve |
|---|---|---|
| 1 | Refactor `Quarto Default`: remover dictionary `amenityLabels` (redundante — `getData()` já retorna labels) | M1.3 ou Fase 5 (polimento) |
| 2 | `nav_items` lê Public Pages, não Menu "Principal". Investigar **Primary Navigation Menu** setting no Site (Site Settings → Navigation) — provavelmente o Menu não foi marcado como Primary | M1.3 ou Fase 5 |
| 3 | Headless Delivery POST `/structured-contents` falha com Selection múltipla (erro genérico `DDMFormValuesValidationException.RequiredValue` "No value defined for field name") mesmo com payload idêntico ao GET. **Site Initializer no M2 vai precisar** desse caminho funcionando — ou plano alternativo (Service Layer Java, LAR import, REST diferente) | **M2 (bloqueador potencial)** |
| 4 | API canônica do Liferay 7.4 GA132 pra ler `.getOptions()` da Structure no FTL — pra evitar duplicar dictionary se quisermos manter abstração | M1.4 prova ou consultar doc oficial Liferay |
| 5 | Validar mapping Fragment → Article (sintaxe canônica em GA132) | Fase 3 — Task 13 do plan |

---

## Artefatos da Fase 2

| Item | ID/Key | Local |
|---|---|---|
| Structure "Quarto" | DDMStructure id `32625` | DB Liferay (não no git — limitação herdada M1.1) |
| Template "Quarto Default" | DDMTemplate key `32638` | DB Liferay |
| Article Suíte Carmilla | StructuredContent id `32655` (R$ 720, 5 amenities) | DB Liferay |
| Article Suíte Lestat | (R$ 850, 6 amenities) | DB Liferay |
| Article Suíte Drácula | (R$ 1200, 6 amenities) | DB Liferay |
| Widget Page "Teste" | URL `/teste`, oculta de navs | DB Liferay |
| Foto compartilhada (Carmilla) | DLFileEntry id `32663` | DB Liferay (Lestat/Drácula reusam — Felipe upa fotos próprias depois) |

---

## Decisões consolidadas (registrar em ADR-002 quando escrever)

1. **Selection múltipla > Text Repeatable** pra `amenities` (vocabulário fixo > liberdade textual).
2. **Nomes Dracula** (Carmilla/Lestat/Drácula) > Safari (Kilimanjaro/Serengeti/Okavango) do plan original — coerência com paleta+logo gothic da Fase 1. Trade-off honesto: dissonância com nome "Hotel Livingstone" vira *charme narrativo* (hotel histórico que reposicionou pro nicho gothic), explicado depois na page Sobre.
3. **Web Content Display widget em Widget Page** = caminho canônico pra testar Template em Liferay 7.4 com pages do hotel sendo Content Pages. Page reusável nas Fases 3/4 pra Fragment testing.

---

## Próximo: Fase 3 — Fragment Collection

Conforme plan M1.2:
- Task 11: criar Collection "Hotel Livingstone Components"
- Task 12: Fragment Hero (estático)
- Task 13: Fragment Card de Quarto **com mapping pro Article** (achado canônico do M1.2 — sintaxe a validar)
- Task 14: Fragment Galeria
- Task 15: validar fragments isolados na page de teste `/teste`
