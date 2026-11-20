# Projeto FLUXO - Global Solution 2026/2 Mobile

## Sobre o projeto

A lotação no transporte público ferroviário dificulta o embarque e pode concentrar passageiros em alguns vagões enquanto outros ainda possuem espaço.

O **FLUXO** propõe usar contagens de pessoas para informar a ocupação dos vagões e ajudar a companhia a acompanhar a demanda nas plataformas. O passageiro poderá identificar onde há mais espaço antes de embarcar. A operadora poderá comparar quantas pessoas estão esperando com a capacidade disponível de um trem e avaliar a necessidade de reforço do serviço.

Este repositório contém o **aplicativo Flutter** da solução CitizenTech desenvolvida para a **Global Solution 2026/2 da FIAP**, na disciplina **Mobile Application Development**, no eixo Cidades, com foco em mobilidade. O protótipo utiliza dados simulados e armazenamento em memória, sem depender de serviços externos.

A integração com câmeras e visores físicos são possibilidades de evolução da solução.

## Integrantes - 2TDSPR

| Nome | RM |
| --- | --- |
| Luana Alves de Oliveira | 566621 |
| Isabely Marques da Silva | 566663 |
| Mateus Ribeiro Azevedo | 566630 |
| Paulo Gustavo Moraes de Sousa | 568580 |

## Cidadão beneficiado

O público principal são os passageiros de metrô e trem que enfrentam lotação e dificuldade de embarque no deslocamento diário, incluindo estudantes e trabalhadores. A proposta é oferecer informação sobre a distribuição de passageiros para apoiar a escolha de um vagão menos ocupado.

As equipes de operação também se beneficiam da visualização da ocupação, dos eventos que podem aumentar a demanda e do registro de solicitações de reforço. Esses recursos buscam apoiar decisões sobre o serviço prestado ao cidadão.

## ODS relacionados

| ODS | Relação com a proposta |
| --- | --- |
| **ODS 11 - Cidades e comunidades sustentáveis** | É o principal alinhamento do FLUXO. A meta 11.2 trata do acesso ao transporte seguro, acessível e sustentável e da ampliação do transporte público. A proposta busca apoiar esse objetivo com informação sobre lotação e demanda. |
| **ODS 9 - Indústria, inovação e infraestrutura** | Como alinhamento complementar à meta 9.1, o projeto propõe usar informação e tecnologia para apoiar a gestão da infraestrutura de mobilidade e a qualidade do serviço. |

As relações acima representam o alinhamento proposto para a solução; o protótipo não mede o cumprimento dessas metas. Referências: [ODS 11, ONU](https://sdgs.un.org/goals/goal11) e [ODS 9, ONU](https://sdgs.un.org/goals/goal9).

## O que foi desenvolvido

Foi desenvolvido um protótipo funcional em **Flutter e Dart**, com navegação entre telas, consultas de dados simulados, gerenciamento de estado e formulários com validação.

| Tela ou fluxo | Funcionalidades |
| --- | --- |
| **Visão geral** | Resumo da rede, ocupação média, linhas em destaque, pesquisa por linha ou estação e alerta do próximo evento. |
| **Linhas** | Listagem das linhas, busca e indicadores de ocupação. |
| **Detalhes da linha** | Lista de estações, filtro por nome, capacidade, ocupação e acesso à composição simulada da estação. |
| **Detalhes do metrô** | Ocupação total, capacidade por vagão, seleção de vagões, recomendação do menos ocupado, sentido e próxima parada. |
| **Ações** | Menu para solicitar reforço, acessar cadastros, monitorar linhas e consultar eventos e comunicados. |
| **Reforço de frota** | Seleção de linha e quantidade de composições, confirmação e registro da solicitação. Ao confirmar, gera um comunicado e abre a tela de Comunicados. |
| **Comunicados** | Avisos da operação e das solicitações de reforço, filtro de não lidos e marcação de leitura. |
| **Eventos** | Consulta de eventos com filtro por linha e controle visual de lembrete. |
| **Cadastros (CRUD)** | Consulta, inclusão, edição e exclusão de linhas, metrôs e vagões, com proteção dos vínculos entre os registros. |
| **Formulários de cadastro** | Dados da linha, identificação e status do metrô, vínculo do vagão, capacidade e ocupação. A capacidade da composição é calculada pela soma dos vagões. |

### Navegação e estado

O menu inferior conecta **Home, Linhas, Ações, Eventos e Comunicados**. As telas internas usam `Navigator` e `MaterialPageRoute`, com passagem de parâmetros como linha, estação e composição selecionadas.

O gerenciamento de estado utiliza `StatefulWidget` e `setState()` para buscas, seleção de vagões, filtros, leitura de comunicados e campos dos formulários. Os registros compartilhados em memória utilizam `ChangeNotifier` e `ListenableBuilder` para atualizar listas e contagens.

### Formulários, validação e feedback

Os cadastros utilizam **`TextFormField`**, **`Form`** e **`GlobalKey<FormState>`**, com validação no envio. As regras incluem campos obrigatórios, números inteiros positivos, origem e destino diferentes, identificações sem duplicidade, vínculos obrigatórios e ocupação entre 0% e 100%.

O aplicativo apresenta feedback com **`SnackBar`** ao salvar ou excluir e **`AlertDialog`**, via `showDialog`, para confirmar exclusões e solicitações de reforço. Linhas com metrôs vinculados e metrôs com vagões vinculados só podem ser excluídos após remover ou transferir os vínculos.

### Limites do protótipo

Os dados de lotação, chegada e composições são simulados. O reforço não aciona uma frota real, e o controle de lembrete dos eventos não agenda notificações no dispositivo.

Cadastros, solicitações e novos comunicados são mantidos apenas durante a execução do aplicativo e são reiniciados ao encerrá-lo. O CRUD possui um catálogo próprio em memória: suas alterações não reconfiguram automaticamente os dados simulados das telas de monitoramento. Não há autenticação nem persistência em banco nesta versão.

## Tecnologias

- Flutter e Dart.
- `material_ui` para componentes de interface.
- `lucide_flutter` e `cupertino_icons` para ícones.
- Git e GitHub para versionamento incremental.
- GitHub Actions com workflow configurado para build Web e publicação no GitHub Pages.

## Como executar

### Pré-requisitos

- Git instalado.
- Flutter instalado com Dart compatível com o `pubspec.yaml`: **Dart >= 3.13.7 e < 4.0.0**.
- Para Android: Android SDK configurado e um emulador iniciado ou dispositivo físico conectado com depuração USB.

Confira o ambiente:

```bash
flutter doctor
flutter --version
```

### Instalação e execução no dispositivo

```bash
git clone https://github.com/pgmoraesdev/FLUXO_GLOBAL_SOLUTION_2026_2.git
cd FLUXO_GLOBAL_SOLUTION_2026_2
flutter pub get
flutter devices
flutter run
```

Selecione o emulador ou dispositivo Android caso o Flutter apresente mais de uma opção. Não é necessário configurar banco de dados, Postman, credenciais ou uma API para usar este protótipo.

Para uma prévia no navegador, com Chrome instalado:

```bash
flutter run -d chrome
```

## Links da entrega

- **Repositório:** [FLUXO no GitHub](https://github.com/pgmoraesdev/FLUXO_GLOBAL_SOLUTION_2026_2).
- **Vídeo de demonstração:** `INSERIR_LINK_DO_VIDEO_NO_YOUTUBE`.

## Declaração de uso de IA generativa

Foi utilizado o **Codex, da OpenAI**, como assistente de IA generativa para apoiar a implementação das telas e fluxos em Flutter/Dart, a organização dos dados simulados, as validações dos formulários, a divisão das alterações em commits e a elaboração deste README a partir da proposta e dos requisitos fornecidos.

A IA foi utilizada como apoio ao desenvolvimento. A compreensão do código, sua revisão e validação e a apresentação da solução são de responsabilidade dos integrantes.
