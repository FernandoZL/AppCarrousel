-- =============================================================================
-- MT-02 / Archivo 29: el alta sincroniza el nombre visible
-- =============================================================================
-- El trigger `on_auth_user_sync_perfil` toma `public.perfiles.nombre_completo`
-- de `auth.users.raw_user_meta_data.nombre_completo`. Hasta ahora el nombre
-- declarado en `solicitar_registro` solo quedaba en `registros_pendientes`, así
-- que una cuenta creada sin nombre terminaba con el prefijo del correo.
--
-- Esta migración copia el nombre del alta a `user_metadata` dentro de la misma
-- RPC, antes de crear la solicitud. No toca `app_metadata` ni la autorización:
-- el rol y el alcance siguen viviendo solo en `app_metadata`.
-- =============================================================================

-- Nota: el CLI de Supabase aplica cada migración dentro de una transacción.
-- No se incluye BEGIN/COMMIT explícito para evitar transacciones anidadas.
-- =============================================================================

create or replace function public.solicitar_registro(
  p_codigo_empresa text,
  p_nombre_completo text
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

  -- El nombre del alta es el que verá el administrador y el que usará el
  -- perfil. Se sincroniza aquí para que la aprobación no dependa de que el
  -- cliente haya escrito user_metadata.
  update auth.users u
     set raw_user_meta_data = coalesce(u.raw_user_meta_data, '{}'::jsonb)
       || jsonb_build_object('nombre_completo', v_nombre)
   where u.id = v_usuario_id;

  insert into public.registros_pendientes (
    empresa_id, usuario_id, email, nombre_completo
  )
  values (
    v_empresa_id, v_usuario_id, v_email::extensions.citext, v_nombre
  )
  returning id into v_id;

  return v_id;
end;
$$;

comment on function public.solicitar_registro(text, text) is
  'Registra una solicitud de alta para la empresa del código indicado, sincroniza el nombre visible y deja el rol final en manos del administrador.';

revoke all on function public.solicitar_registro(text, text) from public;
grant execute on function public.solicitar_registro(text, text) to authenticated;
