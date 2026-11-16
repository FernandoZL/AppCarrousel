import 'package:carrousel_app/features/equipo/data/mappers/reporte_mapper.dart';
import 'package:carrousel_app/features/solicitudes/domain/entities/solicitud_horas_extras.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('reporteHorasExtrasDesdeMapa', () {
    test('resuelve nombres y revisor de la vista', () {
      final fila = reporteHorasExtrasDesdeMapa({
        'id': 'r1',
        'empresa_id': 'e1',
        'empleado_id': 'u1',
        'empleado': 'Ana Pérez',
        'centro_costo_id': 'c1',
        'centro_nombre': 'Operaciones',
        'parque_id': 'p1',
        'parque_nombre': 'Parque Central',
        'inicio': '2026-11-10T15:00:00Z',
        'fin': '2026-11-10T17:30:00Z',
        'horas': 2.5,
        'estado': 'aprobada',
        'creado_en': '2026-11-10T14:00:00Z',
        'comentario_admin': 'Correcto',
        'revisor': 'Luis Admin',
        'revisado_en': '2026-11-10T18:00:00Z',
      });

      expect(fila.empleado, 'Ana Pérez');
      expect(fila.parqueNombre, 'Parque Central');
      expect(fila.horas, 2.5);
      expect(fila.estado, EstadoSolicitud.aprobada);
      expect(fila.revisor, 'Luis Admin');
      expect(fila.revisadoEn, isNotNull);
    });

    test('una solicitud histórica sin lugar queda con parque nulo', () {
      final fila = reporteHorasExtrasDesdeMapa({
        'id': 'r2',
        'empresa_id': 'e1',
        'empleado_id': 'u1',
        'centro_costo_id': 'c1',
        'inicio': '2026-11-10T15:00:00Z',
        'fin': '2026-11-10T17:30:00Z',
        'horas': 1.25,
        'estado': 'pendiente',
        'creado_en': '2026-11-10T14:00:00Z',
      });

      expect(fila.empleado, 'Empleado');
      expect(fila.centroNombre, 'Centro de costo');
      expect(fila.parqueId, isNull);
      expect(fila.parqueNombre, isNull);
      expect(fila.revisor, isNull);
      expect(fila.revisadoEn, isNull);
      expect(fila.estado, EstadoSolicitud.pendiente);
    });
  });
}
