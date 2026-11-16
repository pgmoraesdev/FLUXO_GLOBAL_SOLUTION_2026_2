import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'line_detail_screen.dart';
import 'events_screen.dart';
import 'notices_screen.dart';

// CORES
const black = Color(0xFF000000);
const teal = Color(0xFF33A5A5);
const tealDark = Color(0xFF1E7F80);
const muted = Color(0xFF5F6B85);
const danger = Color(0xFFE8736F);
const dangerText = Color(0xFFC2433F);
const softTeal = Color(0xFFF1FAFA);
const greyBorder = Color(0xFFA7B4B4);
const double radius = 4;

// Define quando a lotação é considerada crítica.
bool isCritical(int percent) => percent >= 85;

// Escolhe a cor da lotação de acordo com a porcentagem.
Color occupancyColor(int percent) =>
    isCritical(percent) ? danger : teal;


// MODELOS DE DADOS
class Station {
  final String name;
  final int occupancy;
  final int capacity;
  const Station(this.name, this.occupancy, this.capacity);

  int get currentPeople => (capacity * occupancy / 100).round();

}

class MetroLine {
  final int number;
  final String colorName;
  final String type;
  final Color color;
  final List<Station> stations;

  const MetroLine(
    this.number,
    this.colorName,
    this.type,
    this.color,
    this.stations,
  );

  String get name => 'Linha $number - $colorName';

  // Calcula a média de ocupação de todas as estações da linha.
  int get occupancy {
    int total = 0;

    for (final station in stations) {
      total += station.occupancy;
    }

    return stations.isEmpty ? 0 : (total / stations.length).round();
  }

  // Encontra a estação com a maior porcentagem de ocupação.
  Station get busiest {
    Station result = stations.first;

    for (final station in stations) {
      if (station.occupancy > result.occupancy) {
        result = station;
      }
    }

    return result;
  }

  // perfumaria cor da linha
  Color get onColor => color.computeLuminance() > 0.5 ? black : Colors.white;
}

// DADOS DAS LINHAS E ESTAÇÕES
// Cada linha possui seu número, nome, tipo, cor e suas estações.
// Os valores de ocupação e capacidade são dados simulados.

const List<MetroLine> metroLines = [
  MetroLine(1, 'Azul', 'metrô', Color(0xFF0053A0), [
    Station('Tucuruvi', 64, 900),
    Station('Parada Inglesa', 60, 900),
    Station('Jd. São Paulo-Ayrton Senna', 60, 900),
    Station('Santana', 60, 900),
    Station('Carandiru', 92, 1200),
    Station('Portuguesa-Tietê', 85, 900),
    Station('Armênia', 78, 800),
    Station('Tiradentes', 60, 900),
    Station('Luz', 81, 1500),
    Station('São Bento', 60, 900),
    Station('Sé', 60, 1200),
    Station('Japão-Liberdade', 60, 900),
    Station('São Joaquim', 60, 900),
    Station('Vergueiro', 60, 900),
    Station('Paraíso', 60, 1200),
    Station('Ana Rosa', 60, 900),
    Station('Vila Mariana', 60, 900),
    Station('Santa Cruz', 60, 1200),
    Station('Praça da Árvore', 60, 900),
    Station('Saúde', 60, 900),
    Station('São Judas', 60, 900),
    Station('Conceição', 60, 900),
    Station('Jabaquara Comitê Paralímpico', 60, 1200),
  ]),
  MetroLine(2, 'Verde', 'metrô', Color(0xFF008062), [
    Station('Vila Madalena', 55, 800),
    Station('Sumaré', 60, 900),
    Station('Clínicas', 60, 900),
    Station('Consolação', 63, 900),
    Station('Trianon-Masp', 60, 900),
    Station('Brigadeiro', 60, 900),
    Station('Paraíso', 60, 1200),
    Station('Ana Rosa', 60, 900),
    Station('Chácara Klabin', 60, 900),
    Station('Santos-Imigrantes', 60, 900),
    Station('Alto do Ipiranga', 60, 900),
    Station('Sacomã', 60, 900),
    Station('Tamanduateí', 60, 1200),
    Station('Vila Prudente', 48, 900),
  ]),
  MetroLine(3, 'Vermelha', 'metrô', Color(0xFFEF4135), [
    Station('Palmeiras-Barra Funda', 94, 1500),
    Station('Mal. Deodoro', 60, 900),
    Station('Santa Cecília', 60, 900),
    Station('República', 88, 1400),
    Station('Anhangabaú', 60, 900),
    Station('Sé', 60, 1200),
    Station('Pedro II', 60, 900),
    Station('Brás', 91, 1300),
    Station('Bresser-Mooca', 60, 900),
    Station('Belém', 60, 900),
    Station('Tatuapé', 79, 1100),
    Station('Carrão Assaí Atacadista', 60, 900),
    Station('Penha Lojas Besni', 60, 900),
    Station('Vila Matilde', 60, 900),
    Station('Guilhermina-Esperança', 60, 900),
    Station('Patriarca-Vila Ré', 60, 900),
    Station('Artur Alvim', 60, 900),
    Station('Corinthians-Itaquera', 86, 1600),
  ]),
  MetroLine(4, 'Amarela', 'metrô', Color(0xFFFFD400), [
    Station('Luz', 70, 1200),
    Station('República', 60, 1200),
    Station('Higienópolis-Mackenzie', 60, 900),
    Station('Paulista Pernambucanas', 62, 1000),
    Station('Oscar Freire', 60, 900),
    Station('Fradique Coutinho', 60, 900),
    Station('Faria Lima PayBank', 60, 1000),
    Station('Pinheiros', 58, 1000),
    Station('Butantã', 75, 800),
    Station('São Paulo-Morumbi', 60, 1000),
    Station('Vila Sônia Profª Elisabeth Tenreiro', 60, 900),
  ]),
  MetroLine(5, 'Lilás', 'metrô', Color(0xFF794E9F), [
    Station('Capão Redondo', 40, 800),
    Station('Campo Limpo', 60, 900),
    Station('Vila das Belezas', 60, 900),
    Station('Giovanni Gronchi', 60, 900),
    Station('Santo Amaro', 35, 1200),
    Station('Largo Treze', 60, 900),
    Station('Adolfo Pinheiro', 60, 900),
    Station('Alto da Boa Vista', 60, 900),
    Station('Borba Gato', 60, 900),
    Station('Brooklin', 52, 700),
    Station('Campo Belo', 60, 900),
    Station('Eucaliptos', 60, 900),
    Station('Moema', 60, 900),
    Station('AACD-Servidor', 60, 900),
    Station('Hospital São Paulo', 60, 900),
    Station('Santa Cruz', 60, 1200),
    Station('Chácara Klabin', 44, 800),
  ]),
  MetroLine(6, 'Laranja', 'metrô', Color(0xFFF47422), [
    Station('João Paulo I', 18, 700),
    Station('Freguesia do Ó', 22, 700),
    Station('Santa Marina', 15, 800),
    Station('Água Branca', 15, 800),
    Station('SESC-Pompéia', 20, 900),
    Station('Perdizes', 20, 900),
  ]),
  MetroLine(7, 'Rubi', 'trem', Color(0xFFA01866), [
    Station('Jundiaí', 58, 700),
    Station('Várzea Paulista', 60, 700),
    Station('Campo Limpo Paulista', 60, 700),
    Station('Botujuru', 60, 600),
    Station('Francisco Morato', 81, 800),
    Station('Baltazar Fidélis', 60, 600),
    Station('Franco da Rocha', 60, 800),
    Station('Caieiras', 60, 700),
    Station('Perus', 60, 700),
    Station('Vila Aurora', 60, 700),
    Station('Jaraguá', 60, 700),
    Station('Vila Clarice', 60, 700),
    Station('Pirituba', 60, 900),
    Station('Piqueri', 60, 700),
    Station('Lapa', 72, 900),
    Station('Água Branca', 60, 900),
    Station('Palmeiras-Barra Funda', 60, 1500),
  ]),
  MetroLine(8, 'Diamante', 'trem', Color(0xFF9F9F94), [
    Station('Amador Bueno', 60, 700),
    Station('Ambuitá', 60, 600),
    Station('Santa Rita', 60, 600),
    Station('Itapevi', 73, 700),
    Station('Engº Cardoso', 60, 700),
    Station('Sagrado Coração', 60, 700),
    Station('Jandira', 60, 700),
    Station('Jd. Silveira', 60, 700),
    Station('Jd. Belval', 60, 700),
    Station('Barueri', 60, 900),
    Station('Antonio João', 60, 700),
    Station('Santa Terezinha', 60, 700),
    Station('Carapicuíba', 69, 700),
    Station('Gen. Miguel Costa', 60, 700),
    Station('Quitaúna', 60, 700),
    Station('Com. Sampaio', 60, 700),
    Station('Osasco', 84, 1100),
    Station('Pres. Altino', 60, 900),
    Station('Imperatriz Leopoldina', 60, 700),
    Station('Domingos de Moraes', 60, 700),
    Station('Lapa', 60, 900),
    Station('Palmeiras-Barra Funda', 60, 1500),
    Station('Júlio Prestes', 77, 1000),
  ]),
  MetroLine(9, 'Esmeralda', 'trem', Color(0xFF00A88E), [
    Station('Osasco', 38, 1100),
    Station('Pres. Altino', 60, 900),
    Station('Ceasa', 60, 700),
    Station('Villa Lobos-Jaguaré', 60, 900),
    Station('Cidade Universitária', 60, 900),
    Station('Pinheiros', 45, 1000),
    Station('Hebraica-Rebouças', 60, 700),
    Station('Cidade Jardim', 60, 700),
    Station('Vila Olímpia', 60, 900),
    Station('Berrini Casas Bahia', 60, 900),
    Station('Morumbi Claro', 60, 1000),
    Station('Granja Julieta', 60, 700),
    Station('João Dias', 60, 700),
    Station('Santo Amaro', 52, 900),
    Station('Socorro', 60, 700),
    Station('Jurubatuba Senac', 60, 900),
    Station('Autódromo', 60, 700),
    Station('Primavera-Interlagos', 60, 700),
    Station('Grajaú', 41, 700),
    Station('Bruno Covas/Mendes-Vila Natal', 60, 700),
    Station('Varginha', 60, 700),
  ]),
  MetroLine(10, 'Turquesa', 'trem', Color(0xFF057F91), [
    Station('Palmeiras-Barra Funda', 60, 1500),
    Station('Luz', 60, 1200),
    Station('Brás', 61, 1300),
    Station('Juventus-Mooca', 60, 900),
    Station('Ipiranga', 60, 900),
    Station('Tamanduateí', 60, 1200),
    Station('São Caetano do Sul Pref. Walter Braido', 60, 900),
    Station('Utinga', 60, 700),
    Station('Pref. Saladino', 60, 700),
    Station('Pref. Celso Daniel-Santo André', 58, 900),
    Station('Capuava', 60, 700),
    Station('Mauá', 60, 900),
    Station('Guapituba', 60, 700),
    Station('Ribeirão Pires Antônio Bespalec', 60, 700),
    Station('Rio Grande da Serra', 70, 600),
  ]),
  MetroLine(11, 'Coral', 'trem', Color(0xFFF05428), [
    Station('Palmeiras-Barra Funda', 60, 1500),
    Station('Luz', 82, 1200),
    Station('Brás', 88, 1300),
    Station('Tatuapé', 60, 1100),
    Station('Corinthians-Itaquera', 60, 1600),
    Station('Dom Bosco', 60, 700),
    Station('José Bonifácio', 60, 700),
    Station('Guaianases', 79, 800),
    Station('Antonio Gianetti Neto', 60, 700),
    Station('Ferraz de Vasconcelos', 60, 700),
    Station('Poá', 60, 700),
    Station('Calmon Viana', 60, 600),
    Station('Suzano', 60, 900),
    Station('Jundiapeba', 60, 700),
    Station('Braz Cubas', 60, 700),
    Station('Mogi das Cruzes', 60, 900),
    Station('Estudantes', 90, 700),
  ]),
  MetroLine(12, 'Safira', 'trem', Color(0xFF0E478E), [
    Station('Brás', 49, 1300),
    Station('Tatuapé', 57, 1100),
    Station('Engº Goulart', 60, 900),
    Station('USP Leste', 60, 700),
    Station('Comendador Ermelino', 60, 700),
    Station('São Miguel Paulista', 60, 900),
    Station('Jd. Helena-Vila Mara', 60, 700),
    Station('Itaim Paulista', 60, 900),
    Station('Jd. Romano', 60, 700),
    Station('Engº Manoel Feio', 60, 700),
    Station('Itaquaquecetuba', 60, 900),
    Station('Aracaré', 60, 700),
    Station('Calmon Viana', 44, 600),
  ]),
  MetroLine(13, 'Jade', 'trem', Color(0xFF0DB064), [
    Station('Engº Goulart', 22, 900),
    Station('Guarulhos-Cecap', 35, 700),
    Station('Aeroporto-Guarulhos', 41, 800),
  ]),
  MetroLine(15, 'Prata', 'monotrilho', Color(0xFF879093), [
    Station('Vila Prudente', 72, 1000),
    Station('Oratório', 55, 600),
    Station('São Lucas', 48, 600),
    Station('Camilo Haddad', 60, 600),
    Station('Vila Tolstoi', 60, 600),
    Station('Vila União', 60, 600),
    Station('Jd. Planalto', 60, 600),
    Station('Sapopemba', 60, 800),
    Station('Fazenda da Juta', 60, 600),
    Station('São Mateus', 60, 800),
    Station('Jd. Colonial', 60, 600),
  ]),
  MetroLine(17, 'Ouro', 'monotrilho', Color(0xFFA0906D), [
    Station('Morumbi Claro', 33, 700),
    Station('Chucri Zaidan', 60, 700),
    Station('Vila Cordeiro', 60, 700),
    Station('Campo Belo', 60, 900),
    Station('Vereador José Diniz', 60, 700),
    Station('Brooklin Paulista', 60, 700),
    Station('Aeroporto de Congonhas', 28, 800),
    Station('Washington Luís', 30, 800),
  ]),
];

// Busca uma linha pelo número. Usado pelos filtros e pelos avisos.
MetroLine lineByNumber(int number) =>
    metroLines.firstWhere((line) => line.number == number);

// WIDGETS USADOS EM OUTRAS TELAS

// Logo do app
Widget fluxoLogo({double height = 28}) => Image.asset(
      'assets/images/simbolo_trama.png',
      height: height
    );

// Barra visual de porcentagem de ocupação
class OccupancyBar extends StatelessWidget {
  final int percent;
  final double height;

  const OccupancyBar({
    super.key,
    required this.percent,
    this.height = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: black, width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      clipBehavior: Clip.antiAlias,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: percent.clamp(0, 100) / 100,
          heightFactor: 1,
          child: ColoredBox(color: occupancyColor(percent)),
        ),
      ),
    );
  }
}

// Mostra a porcentagem e o texto "da capacidade".
class OccupancyLabel extends StatelessWidget {
  final int percent;
  final double size;

  const OccupancyLabel({
    super.key,
    required this.percent,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$percent%',
          style: TextStyle(
            color: black,
            fontWeight: FontWeight.bold,
            fontSize: size,
          ),
        ),
        const Text(
          'da capacidade',
          style: TextStyle(color: muted, fontSize: 10),
        ),
      ],
    );
  }
}

// BARRA DE NAVEGAÇÃO NAVBAR
Widget fluxoNavBar(int index, ValueChanged<int> onTap) {
  const icons = [
    LucideIcons.house,
    LucideIcons.trainFront,
    LucideIcons.zap,
    LucideIcons.calendar,
    LucideIcons.megaphone,
  ];

  const labels = ['Home', 'Linhas', 'Ações', 'Eventos', 'Comunicados'];

  return SafeArea(
    top: false,
    child: Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: black, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onTap(i),
                borderRadius: BorderRadius.circular(radius),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 38,
                      decoration: BoxDecoration(
                        color: i == index ? teal : const Color(0xFFE9EDED),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icons[i],
                        size: 20,
                        color: i == index ? Colors.white : black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 11,
                          color: i == index ? tealDark : black,
                          fontWeight:
                              i == index ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

// Abre a tela correspondente à aba selecionada.
// As telas Home e Ações PAULO ADICIONA DEPOIS
void goToTab(BuildContext context, int index) {
  late final Widget page;

  switch (index) {
     //case 0: 
     // page = const HomeScreen();, NAO SEI SE TA CERTO ISSO RS
     // break;
    //home aqui

    case 1:
      page = const LinesScreen();
      break;

    // case 2: actions aq

    case 3:
      page = const EventsScreen();
      break;

    case 4:
      page = const NoticesScreen();
      break;

    default:
      return;
  }

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => page),
    (route) => false,
  );
}

// Volta para a tela anterior.
void goBack(BuildContext context) {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  } else {
    goToTab(context, 0);
  }
}

// AppBar padrão usada nas telas internas.
PreferredSizeWidget fluxoBackAppBar(BuildContext context) => AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        tooltip: 'Voltar',
        icon: const Icon(LucideIcons.arrowLeft, color: black),
        onPressed: () => goBack(context),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: fluxoLogo(),
        ),
      ],
    );

// PADRÕES DE CAMPO DE BUSCA

OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );

// PADRONIZANDO A DECORAÇÃO DO SEARCH
InputDecoration searchDecoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF7C8499)),
      prefixIcon: const Icon(LucideIcons.search, color: greyBorder, size: 20),
      isDense: true,
      border: _border(greyBorder, 1.5),
      enabledBorder: _border(greyBorder, 1.5),
      focusedBorder: _border(greyBorder, 2),
    );

// TÍTULO PADRÃO DE SEÇÃO
class ScreenTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const ScreenTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: muted, fontSize: 12, height: 1.35),
        ),
      ],
    );
  }
}

// CHIP DE FILTRO
// É o botão usado para selecionar "Todas" ou uma linha específica.
class FluxoChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color? dotColor;
  final VoidCallback onTap;

  const FluxoChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: active ? tealDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(
            color: active ? tealDark : greyBorder,
            width: 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (dotColor != null) ...[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: dotColor,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: active ? Colors.white : Colors.black26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    color: active ? Colors.white : black,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Organiza os filtros de linha em uma faixa horizontal.
class LineFilterBar extends StatelessWidget {
  final List<int> lines;
  final int? selected;
  final ValueChanged<int?> onChanged;

  const LineFilterBar({
    super.key,
    required this.lines,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FluxoChip(
            label: 'Todas',
            active: selected == null,
            onTap: () => onChanged(null),
          ),
          for (final number in lines)
            FluxoChip(
              label: 'Linha $number',
              dotColor: lineByNumber(number).color,
              active: selected == number,
              onTap: () => onChanged(selected == number ? null : number),
            ),
        ],
      ),
    );
  }
}

// IDENTIFICAÇÃO DA LINHA
// Ao tocar no badge, o usuário abre os detalhes daquela linha.
class LineBadge extends StatelessWidget {
  final MetroLine line;

  const LineBadge({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Ver lotação da ${line.name}',
      child: Material(
        color: line.color,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LineDetailScreen(line: line),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${line.number} - ${line.colorName.toLowerCase()}',
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    color: line.onColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  LucideIcons.chevronRight,
                  size: 14,
                  color: line.onColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Mostra quais linhas estão relacionadas a um evento ou comunicado.
class AffectedLines extends StatelessWidget {
  final List<int> lines;

  const AffectedLines({super.key, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Linhas afetadas:',
          style: TextStyle(color: muted, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final number in lines)
              LineBadge(line: lineByNumber(number)),
          ],
        ),
      ],
    );
  }
}

// CARD COMPARTILHADO DE EVENTOS E COMUNICADOS
// Os campos opcionais permitem usar o mesmo card em situações diferentes.
class InfoCard extends StatelessWidget {
  final String title;
  final String when;
  final List<int> lines;
  final String warning;
  final String? description;
  final Widget? trailing;
  final Widget? footer;
  final bool highlight;

  const InfoCard({
    super.key,
    required this.title,
    required this.when,
    required this.lines,
    required this.warning,
    this.description,
    this.trailing,
    this.footer,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight ? softTeal : Colors.white,
        border: Border.all(color: black, width: 1.5),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              description!,
              style: const TextStyle(color: muted, fontSize: 12),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(LucideIcons.calendar, size: 14, color: muted),
              const SizedBox(width: 6),
              Text(
                when,
                style: const TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AffectedLines(lines: lines),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(LucideIcons.users, size: 14, color: dangerText),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  warning,
                  style: const TextStyle(
                    color: dangerText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (footer != null) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFE1E5E5)),
            const SizedBox(height: 8),
            footer!,
          ],
        ],
      ),
    );
  }
}

// TELA DE LINHAS
class LinesScreen extends StatefulWidget {
  const LinesScreen({super.key});

  @override
  State<LinesScreen> createState() => _LinesScreenState();
}

class _LinesScreenState extends State<LinesScreen> {
  // Guarda o texto digitado na busca.
  String query = '';

  // Filtra linhas pelo nome, tipo de transporte ou nome de estação.
  List<MetroLine> get filtered {
    final search = query.toLowerCase();

    return metroLines.where((line) {
      return line.name.toLowerCase().contains(search) ||
          line.type.toLowerCase().contains(search) ||
          line.stations.any(
            (station) => station.name.toLowerCase().contains(search),
          );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = filtered;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            fluxoLogo(),
            const SizedBox(width: 8),
            const Text(
              'Fluxo',
              style: TextStyle(
                color: black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 4, 0, 12),
              child: Text(
                'MONITORAMENTO DE LINHAS',
                style: TextStyle(
                  color: black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            TextField(
              onChanged: (value) => setState(() => query = value),
              decoration: searchDecoration('Pesquisar linha ou estação'),
            ),
            const SizedBox(height: 14),

            // A lista ocupa o espaço restante da tela e permite rolagem.
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('Nenhuma linha encontrada'))
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (_, index) => _lineCard(items[index]),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: fluxoNavBar(
        1,
        (index) {
          if (index != 1) goToTab(context, index);
        },
      ),
    );
  }

  // Monta o card de cada linha com sua lotação e ações.
  Widget _lineCard(MetroLine line) {
    final percent = line.occupancy;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: black, width: 1.5),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.name,
                    style: const TextStyle(
                      color: black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    line.type,
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                ],
              ),
              OccupancyLabel(percent: percent),
            ],
          ),
          const SizedBox(height: 10),
          OccupancyBar(percent: percent),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: occupancyColor(percent),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: line.color,
                      borderRadius: BorderRadius.circular(radius),
                    ),
                    child: Icon(
                      LucideIcons.trainFront,
                      size: 17,
                      color: line.onColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _link(
                    'Ver detalhes →',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LineDetailScreen(line: line),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _link(
                    'Tomar ações →',
                    () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ações para ${line.name} em breve'), //paulo, linka aq com a pagina de ações, quando clicar encaminhar para a pagina de ações
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Estilo compartilhado dos links dentro dos cards.
  Widget _link(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(
          color: tealDark,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}