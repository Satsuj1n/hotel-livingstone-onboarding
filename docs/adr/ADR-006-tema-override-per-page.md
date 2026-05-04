# ADR-006 — Site default theme = Classic; tema custom via override per-page

| Campo | Valor |
|---|---|
| **Data** | 2026-05-03 |
| **Status** | Aceito |
| **Decisor** | Felipe Lima (projeto pessoal) |

## Contexto

O M1.2 entregou o tema custom `hotellivingstonetheme` (parent Styled, ADR-003) cobrindo 21 CSS vars + `portal_normal.ftl` HTML5 semântico + header/footer custom. A pergunta operacional é: **qual o caminho de aplicação do tema nas pages do site?**

Liferay 7.4 oferece dois mecanismos:

1. **Site default theme** (`Site Settings → Look and Feel`) — define o tema padrão herdado por todas as pages do site. Tem efeito global.
2. **Page-level override** (`Configurar Página → Look and Feel → Defina um tema personalizado`) — sobrescreve o tema só naquela page específica.

Durante a Fase 4 do M1.2 (composição das 6 pages), descobrimos empiricamente um problema: **com `hotellivingstonetheme` setado como Site default, o Page Editor e o Site Admin do Liferay quebram visualmente** — páginas internas renderizam com layout caótico (ex: "Heading Exa..." gigante onde devia ter sidebar de configuração).

## Causa raiz

Liferay aplica o Site default theme não só nas pages do site público, mas também em **contextos internos**: control_panel views, configuration iframes embedded no Page Editor, modais de Site Administration. O parent Styled (`liferay-frontend-theme-styled`) traz só os templates FTL essenciais pra portal_normal — **não inclui templates pra control_panel/configuration**.

Quando o Liferay tenta renderizar control_panel usando o tema custom, ele cai no fallback do parent — e Styled sem override pra control_panel resulta em renderização quebrada (CSS do tema aplicado em contexto que ele não estiliza, sem isolamento).

Classic herda de `liferay-frontend-theme-classic-styled` que **inclui** templates pra todos os contextos internos — por isso "tema vanilla = funciona em tudo, mas sem identidade".

## Opções consideradas

### Opção A: Tema custom completo (cobrir control_panel/configuration)

**Prós:**
- Site default = `hotellivingstonetheme`, identidade aplicada em 100% dos contextos
- Sem necessidade de override per-page — page nasce com tema correto

**Cons:**
- Requer adicionar ~10-15 templates FTL extras no tema (`portlet.ftl` pra contextos diversos, `control_panel_*.ftl`, etc.) — engenharia de tema completa
- Custo estimado: 8-12h só pra cobrir control_panel; mais 4-6h pra configuration/admin
- **Anti-objetivo do M1.2** — Felipe está aprendendo Liferay como content creator/dev frontend, não como theme architect
- Manutenção contínua: cada upgrade Liferay pode introduzir templates internos novos → tema custom precisa acompanhar

### Opção B: Site default = Classic, override `hotellivingstonetheme` per-page

**Prós:**
- Site Admin e Page Editor permanecem funcionais (Classic cobre control_panel)
- Pages públicas ganham identidade gothic via override explícito (Configurar Página → Look and Feel)
- Tema custom fica enxuto — só `portal_normal.ftl` + header + footer + paleta. Suficiente pro M1
- Reversível: voltar pra Classic puro = remover overrides via UI (1 page por vez ou via JSONWS)

**Cons:**
- 6 pages precisam de override manual via UI (uma vez só, mas é repetição)
- Não automatizável via JSONWS pública — `useThemeSettings` é coluna interna da tabela `Layout` não exposta pelo `update-look-and-feel`. Tentativa via `update-type-settings` adicionando `useThemeSettings=true` em typeSettings também não funciona
- Achado da Fase 4: **automação de override per-page = só via UI ou SQL direto no DB** (ou Site Initializer no M2)
- Page nova criada via wizard nasce com **override Classic explícito** (não "Use Site Default"). Precisa lembrar de trocar pro custom em cada page nova

### Opção C: Tema híbrido — `hotellivingstonetheme` Site default + correções pontuais nos templates internos

**Prós:**
- Meio-termo: identidade aplicada a quase tudo, fix só onde quebrar
- Custo menor que Opção A (não cobre 100%, só o que aparece quebrado)

**Cons:**
- Cobertura imprevisível — descobre o que quebra durante uso real
- Risco de regressão: cada nova versão Liferay pode introduzir contexto novo
- "Tema custom incompleto disfarçado" — pior dos mundos a longo prazo
- Não há doc oficial pra guiar quais templates priorizar

## Trade-offs

A questão central é **completude de cobertura do tema custom vs. esforço de engenharia + manutenção**.

- Opção A maximiza cobertura mas estoura orçamento M1 e exige perfil "theme architect" (não é o foco do projeto)
- Opção B minimiza esforço dev mas cria fricção operacional (6 overrides + nova page = lembrar de trocar)
- Opção C tenta meio-termo mas perde a clareza de qualquer dos extremos

## Decisão

**Opção B — Site default = Classic; tema custom via override per-page.** Decisão tomada 2026-05-03 durante Fase 4 do M1.2 quando o problema apareceu empiricamente. Operacionalizada via:

1. Site Settings → Look and Feel → Tema padrão = **Classic**
2. Cada page do site Hotel Livingstone (Home + 5 Content Pages) tem override per-page → **Hotel Livingstone Theme** (`hotellivingstonetheme_WAR_hotellivingstonetheme`)
3. Page Buscar (search nativo) fica com Classic — não tem fragments custom, identidade lá não importa
4. Pages novas criadas via wizard "Vazio" → checklist obrigatório de trocar override pro custom antes de publicar

## Consequências

### Positivas
- Site Admin + Page Editor permanecem 100% funcionais — Felipe pode continuar editando pages sem fight com layout quebrado
- Tema `hotellivingstonetheme` fica enxuto e fácil de manter — só portal_normal + header + footer + 21 CSS vars
- Caminho reversível: se algum dia quiser cobrir control_panel (ex: Hotel Livingstone vira intranet), basta adicionar templates e mudar Site default
- Comportamento reproduzível em qualquer instalação Liferay 7.4 — não depende de hack ou patch interno

### Negativas
- 6 overrides via UI + lembrar pra cada page nova — fricção operacional
- API JSONWS pública (`/api/jsonws/layout/update-look-and-feel`) **NÃO** ativa override per-page. O endpoint só seta `themeId` no objeto Layout — não ativa o flag interno `useThemeSettings=true` (coluna **separada** na tabela `Layout`, não exposta via JSONWS). Tentar via `update-type-settings` adicionando `useThemeSettings=true` em typeSettings também não funciona empiricamente
- Page Editor exibe override no canto superior — content creator pode confundir-se ou desativar acidentalmente
- Bug latente: tema novo deployado não atualiza override per-page automaticamente — precisa "Use Site Default" → "Hotel Livingstone Theme" novamente em cada page (validar empiricamente em deploys futuros)

### Mitigações
- **M2 — Site Initializer:** ao implementar o Site Initializer (reproduzir site via código), incluir `useThemeSettings=true` no SQL de seed das pages. Site Initializer tem acesso ao Service Layer Java, não fica limitado ao JSONWS público. Resolve a fricção dos 6 overrides manuais
- **Pendência pesquisa:** validar se Liferay 7.4.x.y mais recente expõe `useThemeSettings` via algum endpoint REST/Headless novo (não foi exposto até GA132). Se sim, automação fica mais simples
- **Documentação operacional:** o achado canônico ("Site default = Classic + override per-page") está consolidado em `project_hotel_livingstone_onboarding.md` (memória) e nas notas Fase 4 (`docs/learning-log/2026-05-03-fase4-composicao.md`). Próximo dev que entrar não vai redescobrir
- **ADR-002 (regra "quem edita = onde mora")** continua válido — esse override é decisão de **dev/configurador de site**, não de content creator. Content creator não toca override; segue editando conteúdo via Page Editor + Web Content normalmente
