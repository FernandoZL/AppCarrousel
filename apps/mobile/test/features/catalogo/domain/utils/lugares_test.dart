import 'package:carrousel_app/features/catalogo/domain/entities/centro_costo.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/parque.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/parque_centro.dart';
import 'package:carrousel_app/features/catalogo/domain/utils/lugares.dart';
import 'package:flutter_test/flutter_test.dart';

CentroCosto centro(String id, {String? nombre, String? padre}) => CentroCosto(
  id: id,
  codigo: id.toUpperCase(),
  nombre: nombre ?? 'Centro $id',
  padreId: padre,
);

Parque parque(
  String id, {
  required String centroPrincipal,
  String? nombre,
  bool activo = true,
}) => Parque(
  id: id,
  empresaId: 'e1',
  centroCostoId: centroPrincipal,
  codigo: id.toUpperCase(),
  nombre: nombre ?? 'Parque $id',
  latitud: 9.9,
  longitud: -84.1,
  radioMetros: 120,
  activo: activo,
);

ParqueCentro enlace(
  String parqueId,
  String centroId, {
  bool principal = false,
  bool activo = true,
}) => ParqueCentro(
  id: '$parqueId-$centroId',
  empresaId: 'e1',
  parqueId: parqueId,
  centroCostoId: centroId,
  principal: principal,
  activo: activo,
);

void main() {
  group('construirLugares', () {
    test('arma cada parque con sus CECOs y el principal primero', () {
      final lugares = construirLugares(
        parques: [parque('p1', centroPrincipal: 'c2', nombre: 'Parque Uno')],
        centros: [
          centro('c1', nombre: 'Alimentos'),
          centro('c2', nombre: 'Operaciones'),
          centro('c3', nombre: 'Tienda'),
        ],
        enlaces: [
          enlace('p1', 'c1'),
          enlace('p1', 'c2', principal: true),
          enlace('p1', 'c3'),
        ],
      );

      expect(lugares, hasLength(1));
      expect(lugares.first.centroPrincipalId, 'c2');
      expect(lugares.first.centros.map((centro) => centro.id), [
        'c2',
        'c1',
        'c3',
      ]);
    });

    test('descarta parques inactivos y enlaces inactivos', () {
      final lugares = construirLugares(
        parques: [
          parque('p1', centroPrincipal: 'c1'),
          parque('p2', centroPrincipal: 'c2', activo: false),
        ],
        centros: [centro('c1'), centro('c2')],
        enlaces: [
          enlace('p1', 'c1', principal: true),
          enlace('p1', 'c2', activo: false),
          enlace('p2', 'c2', principal: true),
        ],
      );

      expect(lugares.map((lugar) => lugar.parque.id), ['p1']);
      expect(lugares.first.centros.map((centro) => centro.id), ['c1']);
    });

    test('un parque sin enlaces activos no aparece', () {
      final lugares = construirLugares(
        parques: [parque('p1', centroPrincipal: 'c1')],
        centros: [centro('c1')],
        enlaces: [enlace('p1', 'c1', principal: true, activo: false)],
      );

      expect(lugares, isEmpty);
    });

    test(
      'usa el centro del parque si ningún enlace está marcado principal',
      () {
        final lugares = construirLugares(
          parques: [parque('p1', centroPrincipal: 'c2')],
          centros: [centro('c1'), centro('c2')],
          enlaces: [enlace('p1', 'c1'), enlace('p1', 'c2')],
        );

        expect(lugares.single.centroPrincipalId, 'c2');
      },
    );

    test('ordena los lugares por nombre', () {
      final lugares = construirLugares(
        parques: [
          parque('p1', centroPrincipal: 'c1', nombre: 'Zona Sur'),
          parque('p2', centroPrincipal: 'c1', nombre: 'Zona Norte'),
        ],
        centros: [centro('c1')],
        enlaces: [
          enlace('p1', 'c1', principal: true),
          enlace('p2', 'c1', principal: true),
        ],
      );

      expect(lugares.map((lugar) => lugar.parque.nombre), [
        'Zona Norte',
        'Zona Sur',
      ]);
    });
  });

  group('centroSugerido y lugarSugerido', () {
    final lugares = construirLugares(
      parques: [
        parque('p1', centroPrincipal: 'c1', nombre: 'Parque Uno'),
        parque('p2', centroPrincipal: 'c2', nombre: 'Parque Dos'),
      ],
      centros: [centro('c1'), centro('c2'), centro('c3')],
      enlaces: [
        enlace('p1', 'c1', principal: true),
        enlace('p1', 'c3'),
        enlace('p2', 'c2', principal: true),
      ],
    );
    final lugarUno = lugares.firstWhere((lugar) => lugar.parque.id == 'p1');

    test('conserva el centro preferido si está habilitado', () {
      expect(centroSugerido(lugarUno, 'c3'), 'c3');
    });

    test('cae al principal cuando el preferido no aplica', () {
      expect(centroSugerido(lugarUno, 'c2'), 'c1');
      expect(centroSugerido(lugarUno, null), 'c1');
    });

    test('elige el lugar que contiene el centro preferido', () {
      expect(lugarSugerido(lugares, 'c2')?.parque.id, 'p2');
      expect(lugarSugerido(lugares, 'c3')?.parque.id, 'p1');
      expect(lugarSugerido(lugares, 'desconocido')?.parque.id, 'p2');
    });

    test('sin lugares devuelve nulo', () {
      expect(lugarSugerido(const [], 'c1'), isNull);
    });
  });
}
