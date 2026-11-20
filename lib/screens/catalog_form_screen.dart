import 'package:material_ui/material_ui.dart';

import '../data/catalog_data.dart';
import 'lines_screen.dart';

class CatalogFormScreen extends StatefulWidget {
  final CatalogStore store;
  final CatalogKind kind;
  final int? recordId;
  const CatalogFormScreen({
    super.key,
    required this.store,
    required this.kind,
    this.recordId,
  });
  @override
  State<CatalogFormScreen> createState() => _CatalogFormScreenState();
}

class _CatalogFormScreenState extends State<CatalogFormScreen> {
  final formKey = GlobalKey<FormState>();
  final fields = <String, TextEditingController>{};
  int? lineId;
  int? trainId;
  String type = CatalogStore.types.first;
  String status = CatalogStore.statuses.first;
  CatalogStore get store => widget.store;
  String get noun => switch (widget.kind) {
    CatalogKind.line => 'linha',
    CatalogKind.train => 'metrô',
    CatalogKind.carriage => 'vagão',
  };
  String value(String key) => fields[key]!.text.trim();
  int number(String key) => int.parse(value(key));

  @override
  void initState() {
    super.initState();
    final data = <String, String>{};
    final id = widget.recordId;
    switch (widget.kind) {
      case CatalogKind.line:
        if (id != null) {
          final line = store.line(id);
          data.addAll({
            'number': '${line.number}',
            'name': line.name,
            'origin': line.origin,
            'destination': line.destination,
          });
          type = line.type;
        }
      case CatalogKind.train:
        if (id != null) {
          final train = store.train(id);
          data['code'] = train.code;
          lineId = train.lineId;
          status = train.status;
        }
      case CatalogKind.carriage:
        if (id != null) {
          final car = store.carriages.firstWhere((car) => car.id == id);
          data.addAll({
            'number': '${car.number}',
            'capacity': '${car.capacity}',
            'occupancy': '${car.occupancy}',
          });
          trainId = car.trainId;
        } else {
          data.addAll({'capacity': '200', 'occupancy': '0'});
        }
    }
    for (final key in [
      'number',
      'name',
      'origin',
      'destination',
      'code',
      'capacity',
      'occupancy',
    ]) {
      fields[key] = TextEditingController(text: data[key] ?? '');
    }
  }

  @override
  void dispose() {
    for (final controller in fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!formKey.currentState!.validate()) return;
    try {
      switch (widget.kind) {
        case CatalogKind.line:
          store.saveLine(
            id: widget.recordId,
            number: number('number'),
            name: value('name'),
            origin: value('origin'),
            destination: value('destination'),
            type: type,
          );
        case CatalogKind.train:
          store.saveTrain(
            id: widget.recordId,
            code: value('code'),
            lineId: lineId!,
            status: status,
          );
        case CatalogKind.carriage:
          store.saveCarriage(
            id: widget.recordId,
            trainId: trainId!,
            number: number('number'),
            capacity: number('capacity'),
            occupancy: number('occupancy'),
          );
      }
      Navigator.pop(context, true);
    } on StateError catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: fluxoBackAppBar(context),
    body: Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          ScreenTitle(
            title: '${widget.recordId == null ? 'Cadastrar' : 'Editar'} $noun',
            subtitle:
                'Preencha os dados do cadastro. Os campos são obrigatórios.',
          ),
          const SizedBox(height: 16),
          ...switch (widget.kind) {
            CatalogKind.line => _lineFields(),
            CatalogKind.train => _trainFields(),
            CatalogKind.carriage => _carriageFields(),
          },
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              backgroundColor: tealDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
            child: const Text('Salvar cadastro'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: muted)),
          ),
        ],
      ),
    ),
  );

  List<Widget> _lineFields() => [
    _input(
      'number',
      'Número da linha',
      numeric: true,
      extra: (text) =>
          store.lines.any(
            (line) =>
                line.id != widget.recordId && line.number == int.tryParse(text),
          )
          ? 'Já existe uma linha com este número.'
          : null,
    ),
    _input('name', 'Nome da linha'),
    _input('origin', 'Estação de origem'),
    _input(
      'destination',
      'Estação de destino',
      extra: (text) => text.toLowerCase() == value('origin').toLowerCase()
          ? 'Origem e destino devem ser diferentes.'
          : null,
    ),
    _dropdown<String>('Tipo de transporte', type, [
      for (final item in CatalogStore.types)
        DropdownMenuItem(value: item, child: Text(item)),
    ], (value) => setState(() => type = value!)),
  ];

  List<Widget> _trainFields() => [
    _input(
      'code',
      'Identificação do metrô',
      extra: (text) =>
          store.trains.any(
            (train) =>
                train.id != widget.recordId && train.code == text.toUpperCase(),
          )
          ? 'Esta identificação já está cadastrada.'
          : null,
    ),
    _dropdown<int>('Linha vinculada', lineId, [
      for (final line in store.lines)
        DropdownMenuItem(
          value: line.id,
          child: Text(line.label, overflow: TextOverflow.ellipsis),
        ),
    ], (value) => setState(() => lineId = value)),
    _dropdown<String>('Status operacional', status, [
      for (final item in CatalogStore.statuses)
        DropdownMenuItem(value: item, child: Text(item)),
    ], (value) => setState(() => status = value!)),
    if (widget.recordId != null)
      _summary(
        '${store.carsFor(widget.recordId!).length} vagões · ${store.capacityFor(widget.recordId!)} pessoas',
        'Capacidade calculada pela soma dos vagões cadastrados.',
      ),
  ];

  List<Widget> _carriageFields() {
    final capacity = int.tryParse(value('capacity')) ?? 0;
    final occupancy = int.tryParse(value('occupancy')) ?? 0;
    return [
      _dropdown<int>('Metrô vinculado', trainId, [
        for (final train in store.trains)
          DropdownMenuItem(value: train.id, child: Text(train.code)),
      ], (value) => setState(() => trainId = value)),
      _input(
        'number',
        'Número do vagão',
        numeric: true,
        extra: (text) =>
            store.carriages.any(
              (car) =>
                  car.id != widget.recordId &&
                  car.trainId == trainId &&
                  car.number == int.tryParse(text),
            )
            ? 'Este metrô já possui um vagão com este número.'
            : null,
      ),
      _input('capacity', 'Capacidade de pessoas', numeric: true, refresh: true),
      _input(
        'occupancy',
        'Ocupação estimada (%)',
        numeric: true,
        min: 0,
        max: 100,
        refresh: true,
      ),
      if (capacity > 0 && occupancy >= 0 && occupancy <= 100)
        _summary(
          '${(capacity * occupancy / 100).round()} de $capacity pessoas',
          'Estimativa calculada pela ocupação informada.',
        ),
    ];
  }

  Widget _input(
    String key,
    String label, {
    bool numeric = false,
    int min = 1,
    int? max,
    bool refresh = false,
    String? Function(String)? extra,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: fields[key],
      decoration: fluxoFieldDecoration(label),
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      textCapitalization: numeric
          ? TextCapitalization.none
          : TextCapitalization.sentences,
      onChanged: refresh ? (_) => setState(() {}) : null,
      validator: (text) {
        final cleaned = text?.trim() ?? '';
        if (cleaned.isEmpty) return 'Preencha este campo.';
        if (numeric) {
          final parsed = int.tryParse(cleaned);
          if (parsed == null || parsed < min || (max != null && parsed > max)) {
            return max == null
                ? 'Informe um número inteiro maior que zero.'
                : 'Informe um inteiro entre $min e $max.';
          }
        }
        return extra?.call(cleaned);
      },
    ),
  );

  Widget _dropdown<T>(
    String label,
    T? selected,
    List<DropdownMenuItem<T>> items,
    ValueChanged<T?> onChanged,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: DropdownButtonFormField<T>(
      initialValue: selected,
      isExpanded: true,
      decoration: fluxoFieldDecoration(label),
      items: items,
      onChanged: onChanged,
      validator: (value) => value == null ? 'Selecione uma opção.' : null,
    ),
  );

  Widget _summary(String title, String description) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: softTeal,
      border: Border.all(color: black, width: 1.5),
      borderRadius: BorderRadius.circular(radius),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: tealDark, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(description, style: const TextStyle(color: muted, fontSize: 12)),
      ],
    ),
  );
}
