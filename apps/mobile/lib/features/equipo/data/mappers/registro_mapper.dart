import 'package:carrousel_app/features/equipo/domain/entities/registro_pendiente.dart';

RegistroPendiente registroPendienteDesdeMapa(Map<String, dynamic> map) =>
    RegistroPendiente(
      id: map['id'] as String,
      empresaId: map['empresa_id'] as String,
      usuarioId: map['usuario_id'] as String,
      email: map['email'] as String,
      nombreCompleto: map['nombre_completo'] as String,
      estado: EstadoRegistro.parse(map['estado'] as String?),
      creadoEn: DateTime.parse(map['creado_en'] as String).toLocal(),
      centroCostoId: map['centro_costo_id'] as String?,
      puestoId: map['puesto_id'] as String?,
      motivoRechazo: map['motivo_rechazo'] as String?,
      revisadoPor: map['revisado_por'] as String?,
      revisadoEn: map['revisado_en'] == null
          ? null
          : DateTime.parse(map['revisado_en'] as String).toLocal(),
    );
