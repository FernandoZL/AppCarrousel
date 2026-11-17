import 'package:carrousel_app/features/equipo/domain/entities/ajuste_jornada.dart';

DateTime _fecha(Object? valor) => switch (valor) {
  DateTime() => valor,
  String() => DateTime.parse(valor),
  _ => throw ArgumentError('Fecha de ajuste no válida: $valor'),
};

AjusteJornada ajusteJornadaDesdeMapa(Map<String, dynamic> map) => AjusteJornada(
  id: map['id'] as String,
  jornadaId: map['jornada_id'] as String,
  empleadoId: map['empleado_id'] as String,
  ajustadoPor: map['ajustado_por'] as String,
  motivo: map['motivo'] as String,
  entradaEnAnterior: _fecha(map['entrada_en_anterior']),
  salidaEnAnterior: _fecha(map['salida_en_anterior']),
  entradaEnNueva: _fecha(map['entrada_en_nueva']),
  salidaEnNueva: _fecha(map['salida_en_nueva']),
  creadoEn: _fecha(map['creado_en']),
);
