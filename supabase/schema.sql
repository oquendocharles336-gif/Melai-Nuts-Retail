-- =============================================================================
-- Melai Nuts — Supabase schema (customer-facing business data)
-- =============================================================================
-- Run this once against a fresh Supabase project (SQL Editor > New query >
-- paste > Run). Firebase Authentication remains the identity provider; this
-- database never stores passwords or session tokens. Every customer-owned
-- row is keyed by `firebase_uid`, the Firebase Auth UID.
--
-- REQUIRED one-time dashboard step (cannot be done via SQL):
--   Supabase Dashboard > Authentication > Sign In / Providers
--   > Third Party Auth > Add provider > Firebase
--   > paste this app's Firebase **Project ID** (not the API key).
-- This lets Postgres verify the Firebase ID token the app attaches to every
-- request and exposes it to policies as `auth.jwt() ->> 'sub'`. Until this
-- is configured, RLS below will reject every authenticated request.
-- =============================================================================

create extension if not exists pgcrypto;

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

-- The signed-in Firebase UID for the current request, or null for anon/guest.
create or replace function public.current_firebase_uid()
returns text
language sql
stable
as $$
  select nullif(auth.jwt() ->> 'sub', '')
$$;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- -----------------------------------------------------------------------------
-- Branches, catalog (public read; managed by staff/owner tooling later)
-- -----------------------------------------------------------------------------

create table if not exists public.branches (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  address text,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.product_categories (
  id uuid primary key default gen_random_uuid(),
  label text not null,
  icon_name text not null default 'category',
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  category_id uuid references public.product_categories(id) on delete set null,
  name text not null,
  price numeric(10, 2) not null check (price >= 0),
  unit text not null default 'pack',
  description text not null default '',
  icon_name text not null default 'nuts',
  color_hex text not null default '#8D6E63',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create trigger products_set_updated_at before update on public.products
  for each row execute function public.set_updated_at();

-- One row per purchasable pack size/SKU of a product. `price` is the full
-- shelf price for that variant (not a delta) — it's what the customer pays
-- per unit, matching the Flutter ProductVariant model exactly.
create table if not exists public.product_variants (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  label text not null,
  price numeric(10, 2) not null check (price >= 0),
  badge text,
  cost_price numeric(10, 2),
  sku text,
  sort_order int not null default 0
);

create table if not exists public.branch_inventory (
  id uuid primary key default gen_random_uuid(),
  branch_id uuid not null references public.branches(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  variant_id uuid references public.product_variants(id) on delete cascade,
  quantity int not null default 0 check (quantity >= 0),
  unique (branch_id, product_id, variant_id)
);

-- -----------------------------------------------------------------------------
-- Customer profile, addresses, notification preferences
-- -----------------------------------------------------------------------------

create table if not exists public.customer_profiles (
  firebase_uid text primary key,
  full_name text not null default '',
  email text not null default '',
  phone text not null default '',
  rfid_card_number text,
  default_branch_id uuid references public.branches(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create trigger customer_profiles_set_updated_at before update on public.customer_profiles
  for each row execute function public.set_updated_at();

create table if not exists public.customer_addresses (
  id uuid primary key default gen_random_uuid(),
  firebase_uid text not null references public.customer_profiles(firebase_uid) on delete cascade,
  label text not null default 'Home',
  recipient_name text not null,
  phone text not null,
  line1 text not null,
  city text not null,
  province text not null default 'Laguna',
  postal_code text not null default '',
  is_default boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.notification_preferences (
  firebase_uid text primary key references public.customer_profiles(firebase_uid) on delete cascade,
  order_updates boolean not null default true,
  promos boolean not null default true,
  loyalty_updates boolean not null default true,
  delivery_updates boolean not null default true,
  updated_at timestamptz not null default now()
);
create trigger notification_prefs_set_updated_at before update on public.notification_preferences
  for each row execute function public.set_updated_at();

-- -----------------------------------------------------------------------------
-- Cart (server-side, so it survives app restarts / device switches)
-- -----------------------------------------------------------------------------

create table if not exists public.carts (
  id uuid primary key default gen_random_uuid(),
  firebase_uid text not null references public.customer_profiles(firebase_uid) on delete cascade,
  status text not null default 'open' check (status in ('open', 'checked_out', 'abandoned')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index if not exists carts_one_open_per_customer
  on public.carts (firebase_uid) where (status = 'open');
create trigger carts_set_updated_at before update on public.carts
  for each row execute function public.set_updated_at();

create table if not exists public.cart_items (
  id uuid primary key default gen_random_uuid(),
  cart_id uuid not null references public.carts(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  variant_id uuid references public.product_variants(id) on delete set null,
  variant_label text not null default 'Regular',
  quantity int not null check (quantity > 0),
  unit_price numeric(10, 2) not null,
  created_at timestamptz not null default now(),
  unique (cart_id, product_id, variant_label)
);

-- -----------------------------------------------------------------------------
-- Orders
-- -----------------------------------------------------------------------------

create sequence if not exists public.order_code_seq start 1001;

create table if not exists public.orders (
  id text primary key default ('ORD-' || nextval('public.order_code_seq')::text),
  firebase_uid text not null references public.customer_profiles(firebase_uid),
  branch_id uuid references public.branches(id),
  branch_name text not null,
  is_delivery boolean not null default false,
  delivery_address_id uuid references public.customer_addresses(id),
  status text not null default 'pending'
    check (status in ('pending', 'confirmed', 'preparing', 'outForDelivery', 'completed', 'cancelled')),
  subtotal numeric(10, 2) not null,
  discount numeric(10, 2) not null default 0,
  delivery_fee numeric(10, 2) not null default 0,
  total numeric(10, 2) not null,
  payment_method text not null,
  points_earned int not null default 0,
  rider_name text,
  eta_label text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create trigger orders_set_updated_at before update on public.orders
  for each row execute function public.set_updated_at();

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id text not null references public.orders(id) on delete cascade,
  product_name text not null,
  variant_label text not null default 'Regular',
  quantity int not null check (quantity > 0),
  unit_price numeric(10, 2) not null
);

-- Real, automatic status history: every time an order's status changes, log
-- it. This is what powers the tracking timeline — no fabricated steps.
create table if not exists public.order_status_events (
  id uuid primary key default gen_random_uuid(),
  order_id text not null references public.orders(id) on delete cascade,
  status text not null,
  note text,
  created_at timestamptz not null default now()
);

create or replace function public.log_order_status_event()
returns trigger
language plpgsql
as $$
begin
  if (tg_op = 'INSERT') then
    insert into public.order_status_events (order_id, status, note)
    values (new.id, new.status, 'Order placed');
  elsif (new.status is distinct from old.status) then
    insert into public.order_status_events (order_id, status, note)
    values (new.id, new.status, null);
  end if;
  return new;
end;
$$;
create trigger orders_log_status_event
  after insert or update of status on public.orders
  for each row execute function public.log_order_status_event();

-- Points are earned server-side (₱50 spent = 1 point) so the client can never
-- inflate what it's awarded. Runs before insert so `points_earned` is always
-- consistent with `total`.
create or replace function public.compute_points_earned()
returns trigger
language plpgsql
as $$
begin
  new.points_earned := greatest(0, floor(new.total / 50)::int);
  return new;
end;
$$;
create trigger orders_compute_points before insert on public.orders
  for each row execute function public.compute_points_earned();

-- -----------------------------------------------------------------------------
-- Payments
-- -----------------------------------------------------------------------------

create sequence if not exists public.payment_code_seq start 5001;

create table if not exists public.payments (
  id text primary key default ('PAY-' || nextval('public.payment_code_seq')::text),
  order_id text not null references public.orders(id) on delete cascade,
  firebase_uid text not null references public.customer_profiles(firebase_uid),
  method text not null check (method in ('gcash', 'maya', 'card', 'cash')),
  status text not null default 'pending'
    check (status in ('pending', 'processing', 'success', 'failed', 'refunded')),
  amount numeric(10, 2) not null,
  reference_number text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create trigger payments_set_updated_at before update on public.payments
  for each row execute function public.set_updated_at();

-- -----------------------------------------------------------------------------
-- Refunds
-- -----------------------------------------------------------------------------

create sequence if not exists public.refund_code_seq start 7001;

create table if not exists public.refund_requests (
  id text primary key default ('RFD-' || nextval('public.refund_code_seq')::text),
  order_id text not null references public.orders(id),
  firebase_uid text not null references public.customer_profiles(firebase_uid),
  status text not null default 'pending'
    check (status in ('pending', 'approved', 'processing', 'completed', 'rejected')),
  reason text not null,
  notes text not null default '',
  amount numeric(10, 2) not null,
  payment_method text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create trigger refund_requests_set_updated_at before update on public.refund_requests
  for each row execute function public.set_updated_at();

create table if not exists public.refund_items (
  id uuid primary key default gen_random_uuid(),
  refund_request_id text not null references public.refund_requests(id) on delete cascade,
  product_name text not null,
  variant_label text not null default 'Regular',
  quantity int not null check (quantity > 0),
  unit_price numeric(10, 2) not null
);

create table if not exists public.refund_status_events (
  id uuid primary key default gen_random_uuid(),
  refund_request_id text not null references public.refund_requests(id) on delete cascade,
  status text not null,
  note text,
  created_at timestamptz not null default now()
);

create or replace function public.log_refund_status_event()
returns trigger
language plpgsql
as $$
begin
  if (tg_op = 'INSERT') then
    insert into public.refund_status_events (refund_request_id, status, note)
    values (new.id, new.status, 'Request submitted');
  elsif (new.status is distinct from old.status) then
    insert into public.refund_status_events (refund_request_id, status, note)
    values (new.id, new.status, null);
  end if;
  return new;
end;
$$;
create trigger refund_requests_log_status_event
  after insert or update of status on public.refund_requests
  for each row execute function public.log_refund_status_event();

-- -----------------------------------------------------------------------------
-- Loyalty
-- -----------------------------------------------------------------------------

create table if not exists public.loyalty_accounts (
  firebase_uid text primary key references public.customer_profiles(firebase_uid) on delete cascade,
  points_balance int not null default 0 check (points_balance >= 0),
  lifetime_points int not null default 0,
  updated_at timestamptz not null default now()
);
create trigger loyalty_accounts_set_updated_at before update on public.loyalty_accounts
  for each row execute function public.set_updated_at();

create sequence if not exists public.loyalty_tx_code_seq start 1;

create table if not exists public.loyalty_transactions (
  id text primary key default ('LTX-' || nextval('public.loyalty_tx_code_seq')::text),
  firebase_uid text not null references public.customer_profiles(firebase_uid),
  type text not null check (type in ('earn', 'redeem')),
  points int not null,
  description text not null,
  order_id text references public.orders(id),
  created_at timestamptz not null default now()
);

-- Award points automatically whenever a paid order is created.
create or replace function public.award_order_points()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.points_earned > 0 then
    insert into public.loyalty_accounts (firebase_uid, points_balance, lifetime_points)
    values (new.firebase_uid, new.points_earned, new.points_earned)
    on conflict (firebase_uid) do update
      set points_balance = public.loyalty_accounts.points_balance + excluded.points_balance,
          lifetime_points = public.loyalty_accounts.lifetime_points + excluded.lifetime_points;

    insert into public.loyalty_transactions (firebase_uid, type, points, description, order_id)
    values (new.firebase_uid, 'earn', new.points_earned, 'Order ' || new.id, new.id);
  end if;
  return new;
end;
$$;
create trigger orders_award_points after insert on public.orders
  for each row execute function public.award_order_points();

create table if not exists public.rewards (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null default '',
  points_required int not null check (points_required > 0),
  badge_label text not null default '',
  icon_name text not null default 'redeem',
  color_hex text not null default '#8D6E63',
  stock int,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.reward_redemptions (
  id uuid primary key default gen_random_uuid(),
  firebase_uid text not null references public.customer_profiles(firebase_uid),
  reward_id uuid not null references public.rewards(id),
  points_spent int not null,
  status text not null default 'redeemed',
  created_at timestamptz not null default now()
);

-- Atomic "spend points" transaction: check balance, deduct, log, decrement
-- stock — all or nothing. This is the only way points ever leave an account,
-- so a slow tap or a flaky connection can never double-charge.
create or replace function public.redeem_reward(p_reward_id uuid)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid text := public.current_firebase_uid();
  v_reward record;
  v_balance int;
begin
  if v_uid is null then
    raise exception 'Not signed in';
  end if;

  select * into v_reward from public.rewards where id = p_reward_id and is_active for update;
  if not found then
    raise exception 'Reward not available';
  end if;
  if v_reward.stock is not null and v_reward.stock <= 0 then
    raise exception 'Reward is out of stock';
  end if;

  insert into public.loyalty_accounts (firebase_uid) values (v_uid)
    on conflict (firebase_uid) do nothing;

  select points_balance into v_balance from public.loyalty_accounts
    where firebase_uid = v_uid for update;

  if v_balance < v_reward.points_required then
    raise exception 'Not enough points';
  end if;

  update public.loyalty_accounts
    set points_balance = points_balance - v_reward.points_required
    where firebase_uid = v_uid
    returning points_balance into v_balance;

  insert into public.loyalty_transactions (firebase_uid, type, points, description)
    values (v_uid, 'redeem', -v_reward.points_required, v_reward.title);

  insert into public.reward_redemptions (firebase_uid, reward_id, points_spent)
    values (v_uid, p_reward_id, v_reward.points_required);

  if v_reward.stock is not null then
    update public.rewards set stock = stock - 1 where id = p_reward_id;
  end if;

  return v_balance;
end;
$$;

-- -----------------------------------------------------------------------------
-- Notifications
-- -----------------------------------------------------------------------------

create sequence if not exists public.notification_code_seq start 1;

create table if not exists public.notifications (
  id text primary key default ('NTF-' || nextval('public.notification_code_seq')::text),
  firebase_uid text not null references public.customer_profiles(firebase_uid) on delete cascade,
  category text not null
    check (category in ('order', 'payment', 'refund', 'loyalty', 'delivery', 'promo', 'system')),
  title text not null,
  body text not null,
  read boolean not null default false,
  created_at timestamptz not null default now()
);

create or replace function public.notify_customer(
  p_uid text, p_category text, p_title text, p_body text
) returns void language sql security definer set search_path = public as $$
  insert into public.notifications (firebase_uid, category, title, body)
  values (p_uid, p_category, p_title, p_body);
$$;

-- Real, automatic notifications for real events — not fabricated client-side.
create or replace function public.notify_on_order_status()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'INSERT' then
    perform public.notify_customer(new.firebase_uid, 'order', 'Order placed',
      'Your order ' || new.id || ' has been received.');
  elsif new.status is distinct from old.status then
    perform public.notify_customer(new.firebase_uid, 'order', 'Order ' || new.id || ' updated',
      'Status changed to ' || new.status || '.');
  end if;
  return new;
end;
$$;
create trigger orders_notify after insert or update of status on public.orders
  for each row execute function public.notify_on_order_status();

create or replace function public.notify_on_refund_status()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'INSERT' then
    perform public.notify_customer(new.firebase_uid, 'refund', 'Refund request submitted',
      'Request ' || new.id || ' for order ' || new.order_id || ' is pending review.');
  elsif new.status is distinct from old.status then
    perform public.notify_customer(new.firebase_uid, 'refund', 'Refund ' || new.id || ' updated',
      'Status changed to ' || new.status || '.');
  end if;
  return new;
end;
$$;
create trigger refunds_notify after insert or update of status on public.refund_requests
  for each row execute function public.notify_on_refund_status();

-- =============================================================================
-- Row Level Security
-- =============================================================================

alter table public.branches enable row level security;
alter table public.product_categories enable row level security;
alter table public.products enable row level security;
alter table public.product_variants enable row level security;
alter table public.branch_inventory enable row level security;
alter table public.rewards enable row level security;

alter table public.customer_profiles enable row level security;
alter table public.customer_addresses enable row level security;
alter table public.notification_preferences enable row level security;
alter table public.carts enable row level security;
alter table public.cart_items enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.order_status_events enable row level security;
alter table public.payments enable row level security;
alter table public.refund_requests enable row level security;
alter table public.refund_items enable row level security;
alter table public.refund_status_events enable row level security;
alter table public.loyalty_accounts enable row level security;
alter table public.loyalty_transactions enable row level security;
alter table public.reward_redemptions enable row level security;
alter table public.notifications enable row level security;

-- Catalog: anyone (including guests browsing without an account) can read.
create policy "catalog is publicly readable" on public.branches for select using (true);
create policy "catalog is publicly readable" on public.product_categories for select using (true);
create policy "catalog is publicly readable" on public.products for select using (is_active);
create policy "catalog is publicly readable" on public.product_variants for select using (true);
create policy "catalog is publicly readable" on public.branch_inventory for select using (true);
create policy "rewards are publicly readable" on public.rewards for select using (is_active);

-- Customer profile
create policy "read own profile" on public.customer_profiles for select
  using (firebase_uid = current_firebase_uid());
create policy "create own profile" on public.customer_profiles for insert
  with check (firebase_uid = current_firebase_uid());
create policy "update own profile" on public.customer_profiles for update
  using (firebase_uid = current_firebase_uid());

-- Addresses
create policy "manage own addresses" on public.customer_addresses for all
  using (firebase_uid = current_firebase_uid())
  with check (firebase_uid = current_firebase_uid());

-- Notification preferences
create policy "manage own notification prefs" on public.notification_preferences for all
  using (firebase_uid = current_firebase_uid())
  with check (firebase_uid = current_firebase_uid());

-- Cart
create policy "manage own cart" on public.carts for all
  using (firebase_uid = current_firebase_uid())
  with check (firebase_uid = current_firebase_uid());
create policy "manage own cart items" on public.cart_items for all
  using (exists (select 1 from public.carts c where c.id = cart_id and c.firebase_uid = current_firebase_uid()))
  with check (exists (select 1 from public.carts c where c.id = cart_id and c.firebase_uid = current_firebase_uid()));

-- Orders: customers can create and read their own; status changes going
-- forward belong to staff/delivery tooling (not exposed here), so no
-- customer update/delete policy is defined.
create policy "read own orders" on public.orders for select
  using (firebase_uid = current_firebase_uid());
create policy "create own orders" on public.orders for insert
  with check (firebase_uid = current_firebase_uid());
create policy "read own order items" on public.order_items for select
  using (exists (select 1 from public.orders o where o.id = order_id and o.firebase_uid = current_firebase_uid()));
create policy "create own order items" on public.order_items for insert
  with check (exists (select 1 from public.orders o where o.id = order_id and o.firebase_uid = current_firebase_uid()));
create policy "read own order status events" on public.order_status_events for select
  using (exists (select 1 from public.orders o where o.id = order_id and o.firebase_uid = current_firebase_uid()));

-- Payments: customers can record and read their own; no update/delete.
create policy "read own payments" on public.payments for select
  using (firebase_uid = current_firebase_uid());
create policy "create own payments" on public.payments for insert
  with check (firebase_uid = current_firebase_uid());

-- Refunds
create policy "read own refund requests" on public.refund_requests for select
  using (firebase_uid = current_firebase_uid());
create policy "create own refund requests" on public.refund_requests for insert
  with check (firebase_uid = current_firebase_uid());
create policy "read own refund items" on public.refund_items for select
  using (exists (select 1 from public.refund_requests r where r.id = refund_request_id and r.firebase_uid = current_firebase_uid()));
create policy "create own refund items" on public.refund_items for insert
  with check (exists (select 1 from public.refund_requests r where r.id = refund_request_id and r.firebase_uid = current_firebase_uid()));
create policy "read own refund status events" on public.refund_status_events for select
  using (exists (select 1 from public.refund_requests r where r.id = refund_request_id and r.firebase_uid = current_firebase_uid()));

-- Loyalty: balance and history are read-only from the client — every change
-- goes through the order/redemption triggers and the redeem_reward()
-- function above, never a direct client update.
create policy "read own loyalty account" on public.loyalty_accounts for select
  using (firebase_uid = current_firebase_uid());
create policy "read own loyalty transactions" on public.loyalty_transactions for select
  using (firebase_uid = current_firebase_uid());
create policy "read own redemptions" on public.reward_redemptions for select
  using (firebase_uid = current_firebase_uid());

-- Notifications: customers can read, mark read, and delete their own; rows
-- are only ever created by the notify_* trigger functions above.
create policy "manage own notifications" on public.notifications for select
  using (firebase_uid = current_firebase_uid());
create policy "update own notifications" on public.notifications for update
  using (firebase_uid = current_firebase_uid())
  with check (firebase_uid = current_firebase_uid());
create policy "delete own notifications" on public.notifications for delete
  using (firebase_uid = current_firebase_uid());

-- =============================================================================
-- Starter seed data
-- =============================================================================
-- Real rows for the store to launch with — edit freely in the Supabase table
-- editor (or build an Owner-side admin screen later). Nothing in the Flutter
-- app is hardcoded to these ids; the catalog UI renders whatever is here.

insert into public.branches (name, address) values
  ('Calamba Branch', 'Calamba City, Laguna'),
  ('Los Baños Branch', 'Los Baños, Laguna'),
  ('Santa Cruz Branch', 'Santa Cruz, Laguna')
on conflict (name) do nothing;

insert into public.product_categories (label, icon_name, sort_order) values
  ('Roasted Nuts', 'nuts', 1),
  ('Trail Mixes', 'grain', 2),
  ('Flavored Nuts', 'local_fire_department', 3),
  ('Gift Packs', 'card_giftcard', 4)
on conflict do nothing;

insert into public.products (category_id, name, price, unit, description, icon_name, color_hex)
select c.id, p.name, p.price, p.unit, p.description, p.icon_name, p.color_hex
from (values
  ('Roasted Nuts', 'Roasted Cashew', 220.00, '250g pack', 'Slow-roasted Laguna cashews, lightly salted.', 'nuts', '#8D6E63'),
  ('Roasted Nuts', 'Roasted Peanuts', 90.00, '250g pack', 'Crunchy roasted peanuts in shell.', 'nuts', '#A1887F'),
  ('Flavored Nuts', 'Chili Garlic Peanuts', 110.00, '250g pack', 'Peanuts tossed in chili and garlic seasoning.', 'local_fire_department', '#E64A19'),
  ('Trail Mixes', 'Mixed Nuts & Raisins', 260.00, '250g pack', 'Cashew, peanut, almond and raisin blend.', 'grain', '#6D4C41'),
  ('Gift Packs', 'Melai Nuts Gift Box', 480.00, '500g box', 'Assorted nuts in a gift-ready box.', 'card_giftcard', '#8D6E63')
) as p(category_label, name, price, unit, description, icon_name, color_hex)
join public.product_categories c on c.label = p.category_label
where not exists (select 1 from public.products existing where existing.name = p.name);

insert into public.product_variants (product_id, label, price, sort_order)
select p.id, 'Regular (' || p.unit || ')', p.price, 1
from public.products p
where not exists (select 1 from public.product_variants v where v.product_id = p.id);

insert into public.branch_inventory (branch_id, product_id, variant_id, quantity)
select b.id, v.product_id, v.id, 50
from public.branches b cross join public.product_variants v
on conflict (branch_id, product_id, variant_id) do nothing;

insert into public.rewards (title, description, points_required, badge_label, icon_name, color_hex) values
  ('₱50 Off Voucher', 'Instant ₱50 off your next order.', 200, 'Instant Voucher', 'local_offer', '#8D6E63'),
  ('Free 100g Roasted Cashew', 'Redeem a free small pack of roasted cashew.', 350, 'Most Popular', 'redeem', '#6D4C41'),
  ('Free Delivery Voucher', 'Waive the delivery fee on your next order.', 150, 'Instant Voucher', 'local_shipping', '#A1887F')
on conflict do nothing;
