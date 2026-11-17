import 'package:carrousel_app/features/auth/domain/entities/perfil.dart';
import 'package:carrousel_app/features/auth/domain/entities/rol_usuario.dart';
import 'package:carrousel_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/centro_costo.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/lugar_catalogo.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/parque.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/parque_centro.dart';
import 'package:carrousel_app/features/catalogo/domain/entities/puesto.dart';
import 'package:carrousel_app/features/catalogo/domain/repositories/catalogo_repository.dart';
import 'package:carrousel_app/features/catalogo/presentation/providers/catalogo_providers.dart';
import 'package:carrousel_app/features/equipo/presentation/pages/puestos_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _admin = Perfil(
  id: 'admin-id',
  empresaId: 'empresa-id',
  centroCostoId: 'centro-id',
  rol: RolUsuario.admin,
  nombreCompleto: 'Admin Carrousel',
);

class _FakeCatalogo implements CatalogoRepository {
  _FakeCatalogo(this._puestos);

  final List<Puesto> _puestos;
  final creados = <Puesto>[];
  final actualizados = <Puesto>[];
  final eliminados = <String>[];

  @override
  Future<List<CentroCosto>> centros() async => const [];

  @override
  Future<List<Parque>> parques() async => const [];

  @override
  Future<List<ParqueCentro>> parquesCentros() async => const [];

  @override
  Future<List<LugarCatalogo>> lugares() async => const [];

  @override
  Future<Map<String, String>> nombresDePerfiles() async => const {};

  @override
  Future<List<Puesto>> puestos() async => List.of(_puestos);

  @override
  Future<void> crearPuesto({
    required String empresaId,
    required String codigo,
    required String nombre,
    String? descripcion,
  }) async {
    final puesto = Puesto(
      id: 'p${_puestos.length + 1}',
      empresaId: empresaId,
      codigo: codigo,
      nombre: nombre,
      descripcion: descripcion,
      activo: true,
    );
    creados.add(puesto);
    _puestos.add(puesto);
  }

  @override
  Future<void> actualizarPuesto({
    required String id,
    required String codigo,
    required String nombre,
    String? descripcion,
    required bool activo,
  }) async {
    final puesto = Puesto(
      id: id,
      empresaId: 'empresa-id',
      codigo: codigo,
      nombre: nombre,
      descripcion: descripcion,
      activo: activo,
    );
    actualizados.add(puesto);
    final indice = _puestos.indexWhere((item) => item.id == id);
    if (indice >= 0) _puestos[indice] = puesto;
  }

  @override
  Future<void> eliminarPuesto(String id) async {
    eliminados.add(id);
    _puestos.removeWhere((puesto) => puesto.id == id);
  }
}

Widget _app(_FakeCatalogo repo) {
  return ProviderScope(
    overrides: [
      perfilProvider.overrideWith((ref) async => _admin),
      catalogoRepositoryProvider.overrideWithValue(repo),
    ],
    child: const MaterialApp(home: Scaffold(body: PuestosPage())),
  );
}

void main() {
  testWidgets('lista los puestos de la empresa', (tester) async {
    final repo = _FakeCatalogo([
      const Puesto(
        id: 'p1',
        empresaId: 'empresa-id',
        codigo: 'OP',
        nombre: 'Operador',
        activo: true,
      ),
      const Puesto(
        id: 'p2',
        empresaId: 'empresa-id',
        codigo: 'ADM',
        nombre: 'Administrativo',
        activo: false,
      ),
    ]);

    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    expect(find.text('Catálogo de puestos'), findsOneWidget);
    expect(find.text('Operador'), findsOneWidget);
    expect(find.text('Administrativo'), findsOneWidget);
    expect(find.text('2 puestos · 1 activos.'), findsOneWidget);
  });

  testWidgets('crea un puesto y refresca el catálogo', (tester) async {
    final repo = _FakeCatalogo([]);

    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    expect(find.text('Sin puestos'), findsOneWidget);

    await tester.tap(find.text('Nuevo'));
    await tester.pumpAndSettle();

    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'MEC');
    await tester.enterText(campos.at(1), 'Mecánico');
    await tester.enterText(campos.at(2), 'Mantenimiento de juegos.');
    await tester.tap(find.text('Crear'));
    await tester.pumpAndSettle();

    expect(repo.creados, hasLength(1));
    expect(repo.creados.single.codigo, 'MEC');
    expect(repo.creados.single.nombre, 'Mecánico');
    expect(find.text('Mecánico'), findsOneWidget);
  });
}
