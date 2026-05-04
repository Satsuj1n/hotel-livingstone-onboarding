# ADR-002 — Tema custom + Fragment Collection com escopos definidos

| Campo | Valor |
|---|---|
| **Data** | 2026-04-29 |
| **Status** | Aceito |
| **Decisor** | Felipe Lima (projeto pessoal) |

## Contexto

O M1.2 do Hotel Livingstone precisa entregar identidade visual (paleta gothic, tipografia, header/footer) **e** blocos reutilizáveis de página (Hero, Card de Quarto, Galeria) editáveis pelo content creator. O Liferay 7.4 oferece dois mecanismos com sobreposição parcial:

- **Tema custom** (parent Styled, FreeMarker + SCSS) — cobre a casca da página: header, footer, paleta global, tipografia, navegação. Vive em código, deploy via Gradle.
- **Fragment Collection** — blocos apresentacionais inseríveis via Page Editor com drag-and-drop. Vive parcialmente em código (HTML/CSS estático) e parcialmente no banco (instância colocada na page, mapping pra Article).

O spec original de design (`2026-04-26-design.md`) tratava as duas camadas como excludentes ("ou tema completo, ou Fragment Collection completa"). Reframe necessário antes do M1.2 começar.

## Opções consideradas

### Opção A: Tema-only (sem Fragments)

**Prós:**
- 1 mecanismo só, mental model simples
- Identidade 100% controlada por dev

**Cons:**
- Content creator precisa editar FTL pra mudar bloco de Quarto (anti-padrão)
- Page Editor fica subutilizado (drag-and-drop só pra widgets de portlet)
- Tema vira "monolito apresentacional" — toda mudança visual pede deploy

### Opção B: Fragment-only (tema vanilla)

**Prós:**
- Toda apresentação editável via UI
- Deploy mínimo (Fragments são DB)

**Cons:**
- Header/footer/paleta global vivem em **cada page** (cópia em cada layout) — sem source of truth
- Identidade visual escapa do controle dev — conteúdo pode quebrar paleta
- Tipografia e variáveis CSS globais ficam órfãs

### Opção C: Os dois com escopos definidos

**Prós:**
- Cada camada tem responsabilidade clara: casca = tema, bloco = fragment, dado = Web Content
- Content creator edita o que faz sentido editar (bloco e conteúdo)
- Dev mantém soberania da identidade global
- Aderente ao caminho oficial Liferay 7.4 (Page Editor + tema custom é o stack documentado)

**Cons:**
- 2 mecanismos pra entender (custo cognitivo inicial)
- Linha entre "casca" e "bloco" precisa ser disciplinada — risco de feature creep no fragment ou no tema

## Trade-offs

A questão central é **autonomia do content creator vs. controle de dev**.

- Opção A maximiza controle dev mas obriga dev a virar gargalo de qualquer mudança visual
- Opção B maximiza autonomia mas perde source of truth da identidade
- Opção C distribui responsabilidades por **quem edita** — mais código pra entender, mas cada arquivo tem dono claro

## Decisão

**Opção C — Tema custom + Fragment Collection com escopos definidos.** Cada camada tem mecanismo dedicado, separado pelo princípio **"quem edita = onde mora; estrutura ≠ conteúdo"**.

**Mapa de camadas:**

| Camada | Mecanismo | Cobre | Quem edita |
|---|---|---|---|
| Casca global | Tema custom (`hotellivingstonetheme`) | header skeleton, footer skeleton, paleta, tipografia, font stack | Dev (código) |
| Bloco apresentacional | Fragment custom (Hero, Card de Quarto, Galeria) | *como mostrar* | Content creator (Page Editor) |
| Dado estruturado | Web Content Structure + Article (Quarto) | *o que mostrar* | Content creator (Web Content) |

A regra de decisão pra novas features fica: **se conteúdo muda sem deploy → fragment ou Web Content; se identidade global muda → tema**.

## Consequências

### Positivas
- Page Editor ganha valor real — content creator compõe pages com Hero+Card+Galeria mapeados pra Articles, sem tocar código
- Tema fica enxuto (header + footer + 21 CSS vars) — manutenção barata
- Mapping fragment → Article (via Conteúdo Web) cria pipeline `Schema → Template → Article → HTML` validado na Fase 3 (critério canônico do M1.2 passou: alterar Article reflete na page sem republicar fragment)

### Negativas
- 2 caminhos de edição = 2 mental models pra content creator aprender (Page Editor pra layout, Web Content pra dados)
- Fragments customs (HTML/CSS) ainda exigem dev — não é "Liferay vanilla" puro
- Linha "casca vs bloco" pode borrar com o tempo se o time não disciplinar (ex: alguém quer "Hero global no tema" — quebra a regra)

### Mitigações
- Documentar o mapa de camadas em `docs/specs/2026-04-26-design.md` (já feito) e revisitar a cada feature nova
- Adotar **template wizard "Vazio"** ao criar Content Pages — page nasce limpa, content creator escolhe quais fragments compor (não vem com layout default que confunde a regra)
- Achados Fase 4: tema custom como Site default theme **quebra Page Editor + Site Admin** (faltam templates pra control_panel/configuration). Solução documentada em ADR-006 — Site default = Classic + override `hotellivingstonetheme` per-page via UI
