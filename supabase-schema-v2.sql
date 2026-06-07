-- ─────────────────────────────────────────────────────────────────
-- Daily Tracker — normalized schema  (run in Supabase SQL Editor)
-- ─────────────────────────────────────────────────────────────────

-- 1. Body measurements: weight, fasting, sleep, steps
create table if not exists body_metrics (
  user_id       uuid        not null references auth.users(id) on delete cascade,
  date          date        not null,
  weight_kg     decimal(5,2),
  fasting_hours smallint,
  sleep_hours   decimal(4,1),
  steps         integer,
  primary key (user_id, date)
);

-- 2. Nutrition: macros, water, fibre
create table if not exists nutrition (
  user_id         uuid     not null references auth.users(id) on delete cascade,
  date            date     not null,
  protein_g       smallint,
  carbs_g         smallint,
  fat_g           smallint,
  water_l         decimal(4,2),
  fibre_breakfast boolean  not null default false,
  fibre_lunch     boolean  not null default false,
  fibre_dinner    boolean  not null default false,
  primary key (user_id, date)
);

-- 3. Habits: supplements, meditation, alcohol, content, reading
create table if not exists habits (
  user_id           uuid     not null references auth.users(id) on delete cascade,
  date              date     not null,
  multivitamin      boolean  not null default false,
  magnesium         boolean  not null default false,
  meditation_min    smallint not null default 0,
  no_alcohol        boolean  not null default false,
  content_published boolean  not null default false,
  content_note      text,
  book_pages        smallint not null default 0,
  notes             text,
  primary key (user_id, date)
);

-- 4. Workouts: rest day or up to 2 sessions
create table if not exists workouts (
  user_id         uuid    not null references auth.users(id) on delete cascade,
  date            date    not null,
  rest_day        boolean not null default false,
  session_1_done  boolean not null default false,
  session_1_notes text,
  session_2_done  boolean not null default false,
  session_2_notes text,
  primary key (user_id, date)
);

-- ─────────────────────────────────────────────────────────────────
-- RLS: each user sees only their own rows
-- ─────────────────────────────────────────────────────────────────

alter table body_metrics enable row level security;
alter table nutrition     enable row level security;
alter table habits        enable row level security;
alter table workouts      enable row level security;

create policy "own rows" on body_metrics for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own rows" on nutrition     for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own rows" on habits        for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own rows" on workouts      for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
