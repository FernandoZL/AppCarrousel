import 'package:carrousel_app/features/registro/domain/entities/mi_registro.dart';

MiRegistro miRegistroDesdeMapa(Map<String, dynamic> map) => MiRegistro(
  id: map['id'] as String,
  empresaId: map['empresa_id'] as String,
  email: map['email'] as String,
  nombreCompleto: map['nombre_completo'] as String,
  estado: EstadoMiRegistro.parse(map['estado'] as String?),
  creadoEn: DateTime.parse(map['creado_en'] as String).toLocal(),
  motivoRechazo: map['motivo_rechazo'] as String?,
  revisadoEn: map['revisado_en'] == null
      ? null
      : DateTime.parse(map['revisado_en'] as String).toLocal(),
);
