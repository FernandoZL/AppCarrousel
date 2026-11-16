import 'package:carrousel_app/features/registro/domain/entities/mi_registro.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EstadoMiRegistro', () {
    test('interpreta los estados del alta propia', () {
      expect(EstadoMiRegistro.parse('pendiente'), EstadoMiRegistro.pendiente);
      expect(EstadoMiRegistro.parse('aprobado'), EstadoMiRegistro.aprobado);
      expect(EstadoMiRegistro.parse('rechazado'), EstadoMiRegistro.rechazado);
    });

    test('un estado desconocido cae en pendiente', () {
      expect(EstadoMiRegistro.parse('otro'), EstadoMiRegistro.pendiente);
      expect(EstadoMiRegistro.parse(null), EstadoMiRegistro.pendiente);
    });
  });

  group('MiRegistro', () {
    MiRegistro registro(EstadoMiRegistro estado) => MiRegistro(
      id: 'r1',
      empresaId: 'e1',
      email: 'ana@example.com',
      nombreCompleto: 'Ana Pérez',
      estado: estado,
      creadoEn: DateTime(2026, 11, 10),
    );

    test('expone el estado como banderas excluyentes', () {
      final pendiente = registro(EstadoMiRegistro.pendiente);
      expect(pendiente.pendiente, isTrue);
      expect(pendiente.aprobado, isFalse);
      expect(pendiente.rechazado, isFalse);

      final aprobado = registro(EstadoMiRegistro.aprobado);
      expect(aprobado.pendiente, isFalse);
      expect(aprobado.aprobado, isTrue);

      final rechazado = registro(EstadoMiRegistro.rechazado);
      expect(rechazado.rechazado, isTrue);
    });
  });
}
