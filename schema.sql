-- شغّل هذا الملف في Supabase > SQL Editor
create table if not exists public.site_content (
  id integer primary key check (id = 1),
  content jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.site_content enable row level security;

grant select on public.site_content to anon, authenticated;
grant insert, update on public.site_content to authenticated;

drop policy if exists "Public can read site content" on public.site_content;
create policy "Public can read site content"
on public.site_content for select to anon, authenticated
using (true);

drop policy if exists "Only signed-in admin can insert content" on public.site_content;
create policy "Only signed-in admin can insert content"
on public.site_content for insert to authenticated
with check (auth.uid() is not null);

drop policy if exists "Only signed-in admin can update content" on public.site_content;
create policy "Only signed-in admin can update content"
on public.site_content for update to authenticated
using (auth.uid() is not null)
with check (auth.uid() is not null);

insert into public.site_content(id, content)
values (1, '{}'::jsonb)
on conflict (id) do nothing;

-- أنشئ Storage bucket اسمه noorhan-media من Storage > New bucket واجعله Public.
-- السياسات التالية تسمح للزوار بقراءة الملفات، وللمستخدم المسجل فقط بالرفع/التعديل/الحذف.
drop policy if exists "Public can view Noorhan media" on storage.objects;
create policy "Public can view Noorhan media"
on storage.objects for select to anon, authenticated
using (bucket_id = 'noorhan-media');

drop policy if exists "Authenticated can upload Noorhan media" on storage.objects;
create policy "Authenticated can upload Noorhan media"
on storage.objects for insert to authenticated
with check (bucket_id = 'noorhan-media');

drop policy if exists "Authenticated can update Noorhan media" on storage.objects;
create policy "Authenticated can update Noorhan media"
on storage.objects for update to authenticated
using (bucket_id = 'noorhan-media')
with check (bucket_id = 'noorhan-media');

drop policy if exists "Authenticated can delete Noorhan media" on storage.objects;
create policy "Authenticated can delete Noorhan media"
on storage.objects for delete to authenticated
using (bucket_id = 'noorhan-media');
