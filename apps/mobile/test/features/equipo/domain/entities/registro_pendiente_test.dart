import 'package:carrousel_app/features/equipo/domain/entities/registro_pendiente.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EstadoRegistro', () {
    test('interpreta los estados del flujo de altas', () {
      expect(EstadoRegistro.parse('pendiente'), EstadoRegistro.pendiente);
      expect(EstadoRegistro.parse('aprobado'), EstadoRegistro.aprobado);
      expect(EstadoRegistro.parse('rechazado'), EstadoRegistro.rechazado);
    });

    test('un estado desconocido cae en pendiente', () {
      expect(EstadoRegistro.parse('otro'), EstadoRegistro.pendiente);
      expect(EstadoRegistro.parse(null), EstadoRegistro.pendiente);
    });
  });

  group('RegistroPendiente', () {
    test('solo está pendiente cuando el estado lo es', () {
      RegistroPendiente registro(EstadoRegistro estado) => RegistroPendiente(
        id: 'r1',
        empresaId: 'e1',
        usuarioId: 'u1',
        email: 'ana@example.com',
        nombreCompleto: 'Ana Pérez',
        estado: estado,
        creadoEn: DateTime(2026, 11, 10),
      );

      expect(registro(EstadoRegistro.pendiente).pendiente, isTrue);
      expect(registro(EstadoRegistro.aprobado).pendiente, isFalse);
    });
  });
}
