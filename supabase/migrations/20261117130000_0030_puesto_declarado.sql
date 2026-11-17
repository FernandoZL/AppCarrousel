-- =============================================================================
-- MT-02 / Archivo 30: puesto declarado por la persona al solicitar su alta
-- =============================================================================
-- El puesto no es un catálogo administrable: la persona que se registra elige
-- "Especialista" o escribe su propio puesto ("Otro"). Se guarda como texto en
-- la solicitud y se materializa en el perfil al aprobarse, sin escribir nunca
-- `app_metadata.rol` desde el cliente.
--
-- La RPC de dos argumentos se conserva como envoltorio para clientes antiguos
-- y equivale a declarar "Especialista".
-- =============================================================================

alter table public.registros_pendientes
  add column puesto text;

alter table public.perfiles
  add column puesto text;

alter table public.registros_pendientes
  add constraint registros_puesto_valido
    check (puesto is null or length(btrim(puesto)) between 1 and 120);

alter table public.perfiles
  add constraint perfiles_puesto_valido
    check (puesto is null or length(btrim(puesto)) between 1 and 120);

comment on column public.registros_pendientes.puesto is
  'Puesto declarado por el solicitante: Especialista o texto libre escrito por la persona.';
comment on column public.perfiles.puesto is
  'Puesto vigente del perfil, materializado desde app_metadata al aprobar el alta.';

-- -----------------------------------------------------------------------------
-- 1. Solicitud con puesto declarado
-- -----------------------------------------------------------------------------
create or replace function public.solicitar_registro(
  p_codigo_empresa text,
  p_nombre_completo text,
  p_puesto text
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_usuario_id uuid := auth.uid();
  v_empresa_id uuid;
  v_email      text;
  v_nombre     text;
  v_puesto     text;
  v_id         uuid;
begin
  if v_usuario_id is null then
    raise exception 'Se requiere una sesión autenticada'
      using errcode = '42501';
  end if;

  v_nombre := btrim(coalesce(p_nombre_completo, ''));
  if length(v_nombre) not between 1 and 160 then
    raise exception 'El nombre completo debe tener entre 1 y 160 caracteres'
      using errcode = '23514';
  end if;

  v_puesto := btrim(coalesce(p_puesto, ''));
  if lower(v_puesto) = 'especialista' then
    v_puesto := 'Especialista';
  elsif length(v_puesto) not between 1 and 120 then
    raise exception 'El puesto debe tener entre 1 y 120 caracteres'
      using errcode = '23514';
  end if;

  if exists (select 1 from public.perfiles p where p.id = v_usuario_id) then
    raise exception 'Ya tienes un perfil aprovisionado en Carrousel'
      using errcode = '23514';
  end if;

  select e.id
    into v_empresa_id
  from public.empresas e
  where e.codigo = btrim(coalesce(p_codigo_empresa, ''))::extensions.citext
    and e.activa;

  if not found then
    raise exception 'El código de empresa no existe o la empresa está suspendida'
      using errcode = '23503';
  end if;

  if exists (
    select 1
    from public.registros_pendientes r
    where r.usuario_id = v_usuario_id
      and r.estado = 'pendiente'
  ) then
    raise exception 'Ya tienes una solicitud de alta pendiente'
      using errcode = '23505';
  end if;

  select coalesce(
           u.email,
           nullif(auth.jwt() ->> 'email', '')
         )
    into v_email
  from auth.users u
  where u.id = v_usuario_id;

  if v_email is null then
    raise exception 'La cuenta no tiene un correo asociado'
      using errcode = '23514';
  end if;

  update auth.users u
     set raw_user_meta_data = coalesce(u.raw_user_meta_data, '{}'::jsonb)
       || jsonb_build_object('nombre_completo', v_nombre)
   where u.id = v_usuario_id;

  insert into public.registros_pendientes (
    empresa_id, usuario_id, email, nombre_completo, puesto
  )
  values (
    v_empresa_id, v_usuario_id, v_email::extensions.citext, v_nombre, v_puesto
  )
  returning id into v_id;

  return v_id;
end;
$$;

comment on function public.solicitar_registro(text, text, text) is
  'Registra el alta con el puesto declarado por la persona (Especialista o texto libre), sin fijar rol ni alcance.';

revoke all on function public.solicitar_registro(text, text, text) from public;
grant execute on function public.solicitar_registro(text, text, text) to authenticated;

-- Compatibilidad: los clientes que aún llaman con dos argumentos declaran
-- "Especialista". La lógica de validación vive solo en la función de tres.
create or replace function public.solicitar_registro(
  p_codigo_empresa text,
  p_nombre_completo text
)
returns uuid
language sql
security definer
set search_path = ''
as $$
  select public.solicitar_registro(p_codigo_empresa, p_nombre_completo, 'Especialista');
$$;

comment on function public.solicitar_registro(text, text) is
  'Envoltorio compatible: registra el alta declarando Especialista.';

revoke all on function public.solicitar_registro(text, text) from public;
grant execute on function public.solicitar_registro(text, text) to authenticated;

-- -----------------------------------------------------------------------------
-- 2. La aprobación copia el puesto declarado a los claims y al registro
-- -----------------------------------------------------------------------------
create or replace function public.aprobar_registro(
  p_registro_id uuid,
  p_centro_costo_id uuid,
  p_puesto_id uuid default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_registro public.registros_pendientes%rowtype;
  v_empresa_id uuid := private.current_empresa_id();
  v_usuario_id uuid;
begin
  if auth.uid() is null or not private.es_admin() then
    raise exception 'Solo un administrador activo puede aprobar registros'
      using errcode = '42501';
  end if;

  select r.*
    into v_registro
  from public.registros_pendientes r
  where r.id = p_registro_id
    and r.empresa_id = v_empresa_id
  for update;

  if not found then
    raise exception 'El registro no existe en tu empresa'
      using errcode = '23503';
  end if;

  if v_registro.estado <> 'pendiente' then
    raise exception 'El registro ya fue resuelto'
      using errcode = '23514';
  end if;

  if exists (select 1 from public.perfiles p where p.id = v_registro.usuario_id) then
    raise exception 'La cuenta ya tiene un perfil aprovisionado'
      using errcode = '23505';
  end if;

  if p_centro_costo_id is null or not private.centro_en_alcance(p_centro_costo_id) then
    raise exception 'El centro de costo debe estar dentro de tu alcance'
      using errcode = '42501';
  end if;

  if p_puesto_id is not null and not exists (
    select 1
    from public.puestos pu
    where pu.id = p_puesto_id
      and pu.empresa_id = v_empresa_id
      and pu.activo
  ) then
    raise exception 'El puesto no existe, está inactivo o es de otra empresa'
      using errcode = '23503';
  end if;

  update auth.users u
     set raw_app_meta_data = coalesce(u.raw_app_meta_data, '{}'::jsonb)
       || jsonb_strip_nulls(
            jsonb_build_object(
              'empresa_id', v_empresa_id,
              'centro_costo_id', p_centro_costo_id,
              'puesto_id', p_puesto_id,
              'puesto', v_registro.puesto,
              'rol', 'empleado'
            )
          )
   where u.id = v_registro.usuario_id;

  if not found then
    raise exception 'La cuenta del solicitante ya no existe'
      using errcode = '23503';
  end if;

  update public.registros_pendientes r
     set estado = 'aprobado',
         centro_costo_id = p_centro_costo_id,
         puesto_id = p_puesto_id,
         puesto = v_registro.puesto,
         revisado_por = auth.uid(),
         revisado_en = now(),
         actualizado_por = auth.uid()
   where r.id = v_registro.id;

  v_usuario_id := v_registro.usuario_id;
  return v_usuario_id;
end;
$$;

comment on function public.aprobar_registro(uuid, uuid, uuid) is
  'Aprueba un alta: fija centro, conserva el puesto declarado y escribe los claims con rol empleado.';

-- -----------------------------------------------------------------------------
-- 3. El trigger de perfiles materializa el puesto declarado
-- -----------------------------------------------------------------------------
create or replace function private.sync_perfil_desde_auth()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_empresa_id uuid;
  v_centro_id  uuid;
  v_puesto_id  uuid;
  v_puesto     text;
  v_rol        public.rol_usuario;
  v_nombre     text;
begin
  v_empresa_id := private.safe_uuid(new.raw_app_meta_data ->> 'empresa_id');
  v_centro_id  := private.safe_uuid(new.raw_app_meta_data ->> 'centro_costo_id');
  v_puesto_id  := private.safe_uuid(new.raw_app_meta_data ->> 'puesto_id');
  v_puesto     := nullif(btrim(coalesce(new.raw_app_meta_data ->> 'puesto', '')), '');

  v_rol := case new.raw_app_meta_data ->> 'rol'
             when 'empleado' then 'empleado'::public.rol_usuario
             when 'admin'  then 'admin'::public.rol_usuario
             else null
           end;

  if v_empresa_id is null or v_centro_id is null or v_rol is null then
    update public.perfiles
       set activo = false
     where id = new.id
       and activo;

    return new;
  end if;

  if not exists (
    select 1
    from public.centros_costo c
    where c.id = v_centro_id
      and c.empresa_id = v_empresa_id
  ) then
    raise exception 'Alcance inválido: el centro % no pertenece a la empresa %',
      v_centro_id, v_empresa_id
      using errcode = '23503';
  end if;

  if v_puesto_id is not null and not exists (
    select 1
    from public.puestos pu
    where pu.id = v_puesto_id
      and pu.empresa_id = v_empresa_id
  ) then
    raise exception 'Puesto inválido: % no pertenece a la empresa %',
      v_puesto_id, v_empresa_id
      using errcode = '23503';
  end if;

  v_nombre := coalesce(
    nullif(btrim(new.raw_user_meta_data ->> 'nombre_completo'), ''),
    split_part(new.email, '@', 1),
    new.id::text
  );

  insert into public.perfiles (
    id, empresa_id, centro_costo_id, puesto_id, puesto, rol, nombre_completo
  )
  values (
    new.id, v_empresa_id, v_centro_id, v_puesto_id, v_puesto, v_rol, v_nombre
  )
  on conflict (id) do update
    set empresa_id      = excluded.empresa_id,
        centro_costo_id = excluded.centro_costo_id,
        puesto_id       = excluded.puesto_id,
        puesto          = excluded.puesto,
        rol             = excluded.rol,
        nombre_completo = excluded.nombre_completo;

  return new;
end;
$$;

comment on function private.sync_perfil_desde_auth() is
  'Materializa perfiles desde app_metadata, incluido el puesto declarado. Sin claims completos desactiva un perfil existente; restaurarlos no lo reactiva.';
