-- Run this once in the Supabase SQL editor for your project
-- https://app.supabase.com → your project → SQL Editor

create table if not exists daily_logs (
  user_id    text        not null default 'shameek',
  date       date        not null,
  data       jsonb       not null default '{}',
  updated_at timestamptz          default now(),
  primary key (user_id, date)
);

-- Disable RLS — this is a personal tool, access is controlled
-- by keeping your anon key private. Re-enable and add auth later
-- if you ever want to share the app with others.
alter table daily_logs disable row level security;
