-- ─────────────────────────────────────────────────────────────────
-- Migrate existing data from daily_logs (JSONB) → normalized tables
-- Run AFTER supabase-schema-v2.sql
-- ─────────────────────────────────────────────────────────────────

insert into body_metrics (user_id, date, weight_kg, fasting_hours, sleep_hours, steps)
select
  user_id::uuid,
  date,
  nullif(data->>'weight', '')::decimal,
  nullif(data->>'fast',   '0')::smallint,
  nullif(data->>'sleep',  '0')::decimal,
  nullif(data->>'steps',  '')::integer
from daily_logs
on conflict (user_id, date) do nothing;

insert into nutrition (user_id, date, protein_g, carbs_g, fat_g, water_l,
                       fibre_breakfast, fibre_lunch, fibre_dinner)
select
  user_id::uuid,
  date,
  nullif(data->>'protein', '')::smallint,
  nullif(data->>'carbs',   '')::smallint,
  nullif(data->>'fat',     '')::smallint,
  nullif(data->>'water',   '')::decimal,
  coalesce((data->'fibre'->0)::text::boolean, false),
  coalesce((data->'fibre'->1)::text::boolean, false),
  coalesce((data->'fibre'->2)::text::boolean, false)
from daily_logs
on conflict (user_id, date) do nothing;

insert into habits (user_id, date, multivitamin, magnesium, meditation_min,
                    no_alcohol, content_published, content_note, book_pages, notes)
select
  user_id::uuid,
  date,
  coalesce((data->>'multivitamin')::boolean,      false),
  coalesce((data->>'magnesium')::boolean,         false),
  coalesce((data->>'meditation')::smallint,        0),
  coalesce((data->>'noAlcohol')::boolean,         false),
  coalesce((data->>'contentPublished')::boolean,  false),
  nullif(data->>'contentNote', ''),
  coalesce((data->>'bookPages')::smallint,        0),
  nullif(data->>'notes', '')
from daily_logs
on conflict (user_id, date) do nothing;

insert into workouts (user_id, date, rest_day,
                      session_1_done, session_1_notes,
                      session_2_done, session_2_notes)
select
  user_id::uuid,
  date,
  coalesce((data->>'restDay')::boolean,   false),
  coalesce((data->>'workout1')::boolean,  false),
  nullif(data->>'workout1notes', ''),
  coalesce((data->>'workout2')::boolean,  false),
  nullif(data->>'workout2notes', '')
from daily_logs
on conflict (user_id, date) do nothing;
