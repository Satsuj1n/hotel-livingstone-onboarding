# ADR-003 — Parent theme = Styled

| Campo | Valor |
|---|---|
| **Data** | 2026-04-29 |
| **Status** | Aceito |
| **Decisor** | Felipe Lima (projeto pessoal) |

## Contexto

Ao criar um tema custom no Liferay 7.4, é obrigatório escolher um **parent theme** — base CSS+FTL que o tema custom estende. O Liferay distribui 3 parents oficiais via `liferay-frontend-theme-*` no npm:

- **Unstyled** (`liferay-frontend-theme-unstyled`) — só estrutura HTML/FTL, zero CSS de apresentação
- **Styled** (`liferay-frontend-theme-styled`) — CSS base mínimo (reset, layout primário, FTL skeleton)
- **Classic** (default herdado de `liferay-frontend-theme-classic-styled`) — UI completa do "Liferay vanilla" (cores, componentes, navbar do produto)

O Hotel Livingstone precisa de identidade visual própria (paleta Dracula+Apple, tipografia SF Pro/Inter, header gothic) — não é uma intranet corporativa que se beneficiaria de "Liferay com cores trocadas".

## Opções consideradas

### Opção A: Classic

**Prós:**
- Default da indústria pra intranets — UX consistente com outras instalações Liferay
- Componentes prontos (navbar, breadcrumbs, search box estilizados)
- Menor curva de aprendizado pra dev novo

**Cons:**
- Resultado fica "Liferay vanilla com cores trocadas" — identidade do hotel nunca emerge
- CSS herdado precisa ser reescrito ou sobrescrito com `!important` em vários pontos
- Estilos do produto (`.product-menu`, `.lfr-*`) vazam no header/footer custom — limpeza demorada

### Opção B: Unstyled

**Prós:**
- Zero CSS herdado — controle total da apresentação
- Performance: bundle CSS menor

**Cons:**
- Reset completo, normalize, layout primário, tipografia base **tudo do zero** — custo fora do orçamento M1.2
- Fica fácil esquecer detalhes (tabela com bordas inconsistentes, listas sem indent, form controls sem padding)
- Precisa importar/recriar utilitários que vêm de graça em Styled

### Opção C: Styled

**Prós:**
- CSS base + FTL skeleton mínimo — partida saudável sem "cara de Liferay"
- Reset + layout primário + tipografia base já vêm prontos
- Identidade própria emerge naturalmente (paleta + fonts + spacing definidos no tema custom sobrescrevem o mínimo herdado)
- Caminho documentado oficialmente em `learn.liferay.com/w/dxp/site-building/developer-guide/themes`

**Cons:**
- Pequeno débito de CSS herdado a entender (variáveis SCSS expostas, utilitários `_clay-` se ativados)
- Não é tão "limpo" quanto Unstyled

## Trade-offs

A questão central é **velocidade de partida vs. controle total da apresentação**.

- Opção A vai rápido mas o resultado parece outra coisa (intranet Liferay) — anti-objetivo
- Opção B dá controle total mas custa horas refazendo o que Styled já dá pronto
- Opção C entrega "começa feio mas funcional, polimento progressivo" — aderente ao princípio de fases do plan M1.2

## Decisão

**Opção C — parent Styled.** Tema custom `hotellivingstonetheme` herda de `liferay-frontend-theme-styled@6.0.54` (versão pinada no `package.json` do tema, 2026-04-29).

## Consequências

### Positivas
- Fase 1 do M1.2 entregou skeleton tema funcional em ~12-15h (estimado e cumprido) — Styled cobriu reset/layout sem custo dev
- Identidade Dracula+Apple emergiu via 21 CSS vars no `:root` + `portal_normal.ftl` HTML5 semântico — total controle de paleta sem fight com herdado
- `nav_items` do Styled funciona out-of-the-box (Primary Navigation sem código adicional)

### Negativas
- Algumas variáveis SCSS herdadas precisam override explícito quando entrarem em conflito (ex: `$body-bg` do Styled vs `--hl-color-bg` custom)
- Validação empírica do prompt `yo liferay-theme` ficou pendente — generator-liferay-theme 10.2.0 não pediu prompts interativos, só gerou com defaults (que coincidiram com Styled). Não conseguimos confirmar se Classic é sempre o default em GA132 ou se há heurística

### Mitigações
- Manter parent Styled pinado em version exato no `package.json` (não `^6.x`) — evita bump silencioso quebrar build entre máquinas
- Documentar variáveis SCSS herdadas conflitantes em learning-log se aparecerem (não houve nenhuma na Fase 1)
- Pra futuro: se time SEA padronizar parent diferente (ex: tema corporativo SEA derivado de Classic), reavaliar — mas projeto pessoal otimiza pra ideal técnico, não pra alinhamento com base instalada
