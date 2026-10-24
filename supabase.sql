-- Run this in Supabase > SQL Editor

create table if not exists public.kk_respondents (
  id uuid primary key default gen_random_uuid(),
  no bigint generated always as identity,
  created_at timestamptz not null default now(),
  last_name text not null,
  first_name text not null,
  middle_name text,
  sex text not null,
  birthday date not null,
  age int not null check (age between 15 and 30),
  civil_status text,
  email text,
  contact text not null,
  barangay text not null,
  purok text,
  classification text not null check (classification in ('In-School Youth','Out-of-School Youth')),
  education text,
  work_status text,
  sk_voter boolean not null default false,
  voted_last boolean not null default false,
  attended_assembly boolean not null default false
);

-- Prevent duplicates: same person = same name + birthday
-- (case-insensitive, ignores extra spaces)
create unique index if not exists kk_respondents_unique_person
  on public.kk_respondents (
    lower(btrim(last_name)),
    lower(btrim(first_name)),
    lower(btrim(coalesce(middle_name, ''))),
    birthday
  );

alter table public.kk_respondents enable row level security;

-- Kabataan (anonymous) can ONLY submit; they cannot read anyone's data
create policy "public can submit" on public.kk_respondents
  for insert to anon with check (true);

-- Logged-in SK officials can view and manage records
create policy "officials read" on public.kk_respondents
  for select to authenticated using (true);
create policy "officials update" on public.kk_respondents
  for update to authenticated using (true);
create policy "officials delete" on public.kk_respondents
  for delete to authenticated using (true);

-- Then create official accounts in Authentication > Users (Add user)
-- and turn OFF "Allow new users to sign up" in Authentication > Sign In / Providers.
