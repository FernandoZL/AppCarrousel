// Normaliza el catálogo de centros de costo (CECO) y arma su jerarquía.
//
// En caja chica el mismo hijo aparece escrito de tres formas: 057.01, 057-01
// y 05701. Todas son el hijo 01 del CECO 057. Aquí se unifican como 057.01.

const PADRE_HIJO_SEPARADO = /^(\d{3})[.-](\d+)$/;
const PADRE_HIJO_PEGADO = /^(\d{3})(\d{2})$/;

/** Devuelve { codigo, padre } con el código canónico, o null si viene vacío. */
export function normalizarCodigo(valor) {
  const crudo = String(valor ?? '').trim();
  if (!crudo || crudo.toUpperCase() === 'NULL') return null;

  const separado = crudo.match(PADRE_HIJO_SEPARADO);
  if (separado) return { codigo: `${separado[1]}.${separado[2]}`, padre: separado[1] };

  const pegado = crudo.match(PADRE_HIJO_PEGADO);
  if (pegado) return { codigo: `${pegado[1]}.${pegado[2]}`, padre: pegado[1] };

  return { codigo: crudo, padre: null };
}

/** Quita espacios dobles y un sufijo "(código)" que repite el CECO. */
export function limpiarNombre(nombre, codigoOriginal) {
  let limpio = String(nombre ?? '').replace(/\s+/g, ' ').trim();
  const sufijo = limpio.match(/^(.*?)\s*\(([^)]*)\)$/);
  if (sufijo && codigoOriginal && normalizarCodigo(sufijo[2])?.codigo === normalizarCodigo(codigoOriginal)?.codigo) {
    limpio = sufijo[1].trim();
  }
  return limpio;
}

// Entre dos nombres para el mismo código se prefiere el que no es genérico
// ("Otro...") y el que no traía el código entre paréntesis.
function puntaje(fila) {
  let valor = 0;
  if (/^otro/i.test(fila.nombre)) valor += 2;
  if (fila.nombreOriginal !== fila.nombre) valor += 1;
  return valor;
}

/**
 * Convierte filas { codigo, nombre } en centros listos para insertar.
 *
 * Devuelve:
 * - centros: [{ codigo, nombre, padre }] ordenados para que cada padre se
 *   inserte antes que sus hijos. padre es null para los de primer nivel.
 * - conflictos: códigos repetidos con nombres distintos (se conservó uno).
 * - sinPadre: hijos cuyo padre no estaba en el listado (quedan en primer nivel).
 * - descartadas: filas sin código.
 */
export function construirJerarquia(filas) {
  const porCodigo = new Map();
  const conflictos = [];
  const descartadas = [];

  for (const fila of filas) {
    const normal = normalizarCodigo(fila.codigo);
    if (!normal) {
      descartadas.push(fila);
      continue;
    }
    const candidato = {
      codigo: normal.codigo,
      padre: normal.padre,
      nombre: limpiarNombre(fila.nombre, fila.codigo),
      nombreOriginal: String(fila.nombre ?? '').replace(/\s+/g, ' ').trim(),
    };
    if (!candidato.nombre) candidato.nombre = normal.codigo;

    const actual = porCodigo.get(normal.codigo);
    if (!actual) {
      porCodigo.set(normal.codigo, candidato);
      continue;
    }
    if (actual.nombre.toLowerCase() !== candidato.nombre.toLowerCase()) {
      const elegido = puntaje(candidato) < puntaje(actual) ? candidato : actual;
      const descartado = elegido === actual ? candidato : actual;
      conflictos.push({ codigo: normal.codigo, conservado: elegido.nombre, descartado: descartado.nombre });
      porCodigo.set(normal.codigo, elegido);
    }
  }

  const sinPadre = [];
  for (const centro of porCodigo.values()) {
    if (centro.padre && !porCodigo.has(centro.padre)) {
      sinPadre.push({ codigo: centro.codigo, padre: centro.padre });
      centro.padre = null;
    }
  }

  const ordenar = (a, b) => a.codigo.localeCompare(b.codigo, 'es', { numeric: true });
  const primerNivel = [...porCodigo.values()].filter((c) => !c.padre).sort(ordenar);
  const hijos = [...porCodigo.values()].filter((c) => c.padre).sort(ordenar);

  const centros = [...primerNivel, ...hijos].map(({ codigo, nombre, padre }) => ({ codigo, nombre, padre }));
  return { centros, conflictos, sinPadre, descartadas };
}

/** Lee TSV (exportación de MySQL) o CSV simple con encabezado codigo,nombre. */
export function leerListado(texto) {
  const lineas = texto.replace(/^\uFEFF/, '').split(/\r?\n/).filter((l) => l.trim());
  if (lineas.length === 0) return [];
  const separador = lineas[0].includes('\t') ? '\t' : ',';
  const encabezado = lineas[0].split(separador).map((c) => c.trim().toLowerCase());
  const iCodigo = encabezado.indexOf('codigo');
  const iNombre = encabezado.indexOf('nombre');
  if (iCodigo < 0 || iNombre < 0) {
    throw new Error('El listado debe tener las columnas "codigo" y "nombre".');
  }
  return lineas.slice(1).map((linea) => {
    const columnas = linea.split(separador);
    return { codigo: columnas[iCodigo], nombre: columnas[iNombre] };
  });
}

const sql = (texto) => `'${String(texto).replace(/'/g, "''")}'`;

/**
 * SQL idempotente: crea la raíz si falta y hace upsert de cada CECO bajo su
 * padre. Re-ejecutarlo actualiza nombres y padres sin duplicar centros.
 */
export function generarSql({ centros, empresaCodigo, raizCodigo, raizNombre }) {
  const partes = [
    '-- Generado por tools/importar-ceco. No editar a mano.',
    'begin;',
    `insert into public.centros_costo (empresa_id, padre_id, codigo, nombre)
select e.id, null, ${sql(raizCodigo)}, ${sql(raizNombre)}
from public.empresas e
where e.codigo = ${sql(empresaCodigo)}
on conflict (empresa_id, codigo) do nothing;`,
  ];

  for (const centro of centros) {
    const padre = centro.padre ?? raizCodigo;
    partes.push(`insert into public.centros_costo (empresa_id, padre_id, codigo, nombre)
select e.id, p.id, ${sql(centro.codigo)}, ${sql(centro.nombre)}
from public.empresas e
join public.centros_costo p on p.empresa_id = e.id and p.codigo = ${sql(padre)}
where e.codigo = ${sql(empresaCodigo)}
on conflict (empresa_id, codigo) do update
  set nombre = excluded.nombre,
      padre_id = excluded.padre_id;`);
  }

  partes.push('commit;');
  return `${partes.join('\n\n')}\n`;
}
