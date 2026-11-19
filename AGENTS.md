# Orientações do projeto

## Padrão visual

- Todas as telas novas e alterações em telas existentes devem seguir o estilo visual já adotado no projeto.
- Imagens de referência orientam a organização do conteúdo; cores, tipografia, espaçamentos, bordas e componentes devem seguir o app, salvo pedido explícito do usuário para mudar o estilo.
- Use as telas de linhas, detalhes de linha, eventos e comunicados como referência. Reutilize os componentes e constantes compartilhados em `lib/screens/lines_screen.dart`, incluindo `fluxoBackAppBar`, `ScreenTitle`, `LineBadge`, `OccupancyBar`, `OccupancyLabel` e `fluxoNavBar` quando aplicáveis.
- Preserve o fundo branco, os cards com borda preta de 1,5 e raio `radius`, os espaçamentos de 12–16, textos pretos e secundários `muted`, e os destaques em `teal`, `tealDark` e `softTeal`.
- Use `isCritical` e `occupancyColor` para os indicadores de ocupação. As cores próprias das linhas ficam reservadas à identificação das linhas.
- Não crie uma paleta ou um estilo de cabeçalho independente para cada tela.
