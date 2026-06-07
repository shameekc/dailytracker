-- Run this in Supabase SQL Editor AFTER enabling Google OAuth in Auth > Providers
-- This locks each user to their own rows only

-- Enable RLS
alter table daily_logs enable row level security;

-- Drop old permissive policy if you ran supabase-setup.sql earlier
drop policy if exists "allow all" on daily_logs;

-- Each authenticated user can only read/write their own rows
create policy "own data only"
  on daily_logs for all
  using  ( auth.uid()::text = user_id )
  with check ( auth.uid()::text = user_id );
