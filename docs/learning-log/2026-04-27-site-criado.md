# 2026-04-27 — Site Hotel Livingstone + 6 pages criados (Task 6)

## O que tentei

- Criar Site "Hotel Livingstone" + 6 pages (Home, Quartos, Restaurante, Eventos, Sobre, Contato) via Control Panel, conforme plan M1.1 Task 6.
- Validar fim-a-fim com `curl` retornando HTTP 200 em cada friendly URL.

## O que o plan supôs e a realidade GA132 desmentiu

Cinco coisas que o plan assumiu mas o GA132 entregou diferente:

1. **Site "Hotel Livingstone" já existia.** O Setup Wizard cria automaticamente um Default Site usando o "Nome da empresa" do setup. Não precisei criar — só configurar.
2. **Friendly URL nascia como `/guest`.** Convenção Liferay: o site default tem friendly URL `/guest` independente do display name. Mudei manualmente em Configuração do site → URL Amigável → `/hotel-livingstone`.
3. **Membership Type estava "Restringido".** Plan pedia "Open". Mudei pra "Aberto" pra alinhar com o plan e evitar 403 em testes deslogados.
4. **Page "Home" também já existia** com o conteúdo padrão "Bem vindo ao Liferay / Enjoy using the best DXP on Earth!". Aproveitei.
5. **Page "Buscar" extra apareceu.** GA132 cria automaticamente uma Search Page (Widget Page) em todo site novo — é onde a barra "Procurar..." renderiza resultados. Decidi manter (apagar removeria funcionalidade real). Curiosidade: friendly URL técnica é `/search` (inglês), label PT-BR é "Buscar".

## O que firmou

- **Content Page tem workflow draft → published no Liferay 7.4+.** Criar a page não publica — fica como `RASCUNHOS` até clicar em Publicar. Sem publicar, `curl` na friendly URL retorna 404. Diferente da Widget Page, que publica direto.
- **`Vazio` em "MODELOS BÁSICO" é o template de Content Page.** "Página de Widget" em "OUTRO" é o tipo clássico (drag-and-drop de portlets). Decidi manter Content Page (modelo moderno do 7.4+, mais alinhado com portal de hotel = conteúdo).
- **Default Landing Page é implícito no GA132.** Acessar `/web/hotel-livingstone` direto renderiza a primeira page da lista (Home, no caso). O `<title>` do HTML retorna `Home - Hotel Livingstone`, confirmando. Plan pedia "Set as Default Landing Page" explicitamente — não foi necessário.
- **Cadeia de validação curl funcionou pra todas as 6 do plan.** HTTP 200 em `/web/hotel-livingstone/{home,quartos,restaurante,eventos,sobre,contato}`.

## Dúvida aberta

- A Buscar Page funciona com `/search` técnico, mas o nome de exibição PT-BR é "Buscar". Em sites multi-idioma (Task 7), a friendly URL muda por locale (`/pt-br/search` vs `/en/search`)? Precisa testar quando montar PT/EN.

## Screenshot

`docs/learning-log/screenshots/2026-04-27-pages/lista-paginas-publicadas.png` — lista das 7 páginas no admin (Home + Buscar + 5 do plan, todas publicadas).
