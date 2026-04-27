# 2026-04-26 — Setup inicial do projeto

## O que tentei

- Criar README.md + ROADMAP.md como ponto de partida do projeto seguindo princípio doc-first.

## O que errei

(preencher conforme aparecer)

## O que firmou

- Doc-first não é só burocracia: serve como spec executável que o próprio dev consulta enquanto trabalha.
- README do GitHub público é a página de entrada do portfolio — investir na clareza paga.

## ADR-001 escrita

- Estrutura "Contexto → Opções → Trade-offs → Decisão → Consequências" força raciocinar contra a decisão antes de tomá-la
- A seção "Opções consideradas" é onde mora o aprendizado — defender por que NÃO escolheu B é mais útil que justificar C

## Workspace Liferay inicializado (Task 3)

- `blade init -v 7.4 workspace` gera Gradle multi-projeto (`modules/`, `themes/`, `configs/`, `gradlew`). Equivalente Liferay do `django-admin startproject`
- `liferay.workspace.product` em `gradle.properties` define a versão alvo. Blade default em 2026-04 = `portal-7.4-ga132` (3 patches à frente do GDF)
- Template moderno (2026) injeta config pra 6 IAs (`.cursor/`, `.gemini/`, `.windsurf/`, `.claude/`, `.github/copilot-*`, `.workspace-rules/`). Apaguei todas — regras steering pra Client Extensions conflitavam com M3 (Service Builder/REST Builder), e nenhuma era IA que eu uso
- `.gitignore` segue separation por escopo: `workspace/.gitignore` cobre Gradle/IDE/build internos; raiz cobre OS/credenciais/AI tooling residual

## Dúvida aberta

(preencher conforme aparecer)
