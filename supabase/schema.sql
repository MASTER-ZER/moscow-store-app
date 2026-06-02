-- Moscow Store Database Schema
-- PostgreSQL on Supabase

-- 1. ADMIN USERS
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  display_name VARCHAR(100),
  role VARCHAR(20) DEFAULT 'admin',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. CUSTOMERS
CREATE TABLE customers (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  phone VARCHAR(20) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  balance DECIMAL(12,2) DEFAULT 0,
  points INTEGER DEFAULT 0,
  level VARCHAR(20) DEFAULT 'starter',
  referral_code VARCHAR(20) UNIQUE,
  referred_by INTEGER REFERENCES customers(id),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. CUSTOMER SESSIONS
CREATE TABLE customer_sessions (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  token VARCHAR(255) UNIQUE NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. GAMES
CREATE TABLE games (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  name_ar VARCHAR(100) NOT NULL,
  slug VARCHAR(100) UNIQUE NOT NULL,
  description TEXT,
  icon VARCHAR(255),
  image VARCHAR(255),
  color VARCHAR(7) DEFAULT '#00B3E5',
  login_type VARCHAR(20) DEFAULT 'id',
  is_active BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. PACKAGES
CREATE TABLE packages (
  id SERIAL PRIMARY KEY,
  game_id INTEGER NOT NULL REFERENCES games(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  amount VARCHAR(50),
  category VARCHAR(50),
  price DECIMAL(10,2) NOT NULL,
  original_price DECIMAL(10,2),
  is_active BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. ACCOUNTS (for sale)
CREATE TABLE accounts (
  id SERIAL PRIMARY KEY,
  game_id INTEGER NOT NULL REFERENCES games(id) ON DELETE CASCADE,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  original_price DECIMAL(10,2),
  rank VARCHAR(50),
  level INTEGER,
  images TEXT[],
  is_sold BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. COURSES
CREATE TABLE courses (
  id SERIAL PRIMARY KEY,
  game_id INTEGER REFERENCES games(id) ON DELETE SET NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  original_price DECIMAL(10,2),
  features TEXT[],
  image VARCHAR(255),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. ORDERS
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  order_number VARCHAR(20) UNIQUE NOT NULL,
  customer_id INTEGER REFERENCES customers(id),
  customer_name VARCHAR(100),
  customer_phone VARCHAR(20),
  game_id INTEGER REFERENCES games(id),
  package_id INTEGER REFERENCES packages(id),
  account_id INTEGER REFERENCES accounts(id),
  course_id INTEGER REFERENCES courses(id),
  order_type VARCHAR(20) DEFAULT 'topup',
  login_type VARCHAR(20),
  player_id VARCHAR(100),
  account_username VARCHAR(100),
  account_password VARCHAR(100),
  payment_method VARCHAR(50),
  payment_type VARCHAR(20) DEFAULT 'transfer',
  total_amount DECIMAL(10,2) NOT NULL,
  status VARCHAR(20) DEFAULT 'pending',
  notes TEXT,
  admin_notes TEXT,
  source VARCHAR(20) DEFAULT 'app',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. PAYMENT METHODS
CREATE TABLE payment_methods (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  name_ar VARCHAR(100) NOT NULL,
  type VARCHAR(20) DEFAULT 'bank',
  details TEXT,
  account_number VARCHAR(100),
  account_name VARCHAR(100),
  icon VARCHAR(255),
  is_active BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. SETTINGS
CREATE TABLE settings (
  id SERIAL PRIMARY KEY,
  key VARCHAR(100) UNIQUE NOT NULL,
  value TEXT NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. NOTIFICATIONS
CREATE TABLE notifications (
  id SERIAL PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  body TEXT,
  type VARCHAR(50) DEFAULT 'info',
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 12. CHAT MESSAGES (order-specific)
CREATE TABLE chat_messages (
  id SERIAL PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  sender_type VARCHAR(20) NOT NULL,
  sender_name VARCHAR(100),
  message TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 13. SUPPORT MESSAGES
CREATE TABLE support_messages (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER REFERENCES customers(id),
  customer_name VARCHAR(100),
  customer_phone VARCHAR(20),
  message TEXT NOT NULL,
  admin_reply TEXT,
  is_closed BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  replied_at TIMESTAMPTZ
);

-- 14. CUSTOMER INBOX
CREATE TABLE customer_inbox (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  title VARCHAR(200) NOT NULL,
  body TEXT,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 15. WALLET TRANSACTIONS
CREATE TABLE wallet_transactions (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  type VARCHAR(20) NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  balance_before DECIMAL(12,2) NOT NULL,
  balance_after DECIMAL(12,2) NOT NULL,
  reason VARCHAR(200),
  reference_id INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 16. LOYALTY TRANSACTIONS
CREATE TABLE loyalty_transactions (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  type VARCHAR(20) NOT NULL,
  points INTEGER NOT NULL,
  points_before INTEGER NOT NULL,
  points_after INTEGER NOT NULL,
  reason VARCHAR(200),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 17. WALLET REQUESTS
CREATE TABLE wallet_requests (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  amount DECIMAL(12,2) NOT NULL,
  payment_method VARCHAR(50),
  proof_image VARCHAR(255),
  notes TEXT,
  status VARCHAR(20) DEFAULT 'pending',
  admin_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 18. CUSTOMER GAME IDS
CREATE TABLE customer_game_ids (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  game_id INTEGER NOT NULL REFERENCES games(id) ON DELETE CASCADE,
  player_id VARCHAR(100) NOT NULL,
  login_type VARCHAR(20) DEFAULT 'id',
  account_username VARCHAR(100),
  account_password VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 19. PUSH SUBSCRIPTIONS
CREATE TABLE push_subscriptions (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER REFERENCES customers(id) ON DELETE CASCADE,
  endpoint TEXT NOT NULL,
  p256dh TEXT NOT NULL,
  auth TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- INDEXES
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX idx_packages_game_id ON packages(game_id);
CREATE INDEX idx_accounts_game_id ON accounts(game_id);
CREATE INDEX idx_chat_messages_order_id ON chat_messages(order_id);
CREATE INDEX idx_wallet_transactions_customer_id ON wallet_transactions(customer_id);
CREATE INDEX idx_customer_sessions_token ON customer_sessions(token);

-- SEED DATA: Payment Methods
INSERT INTO payment_methods (name, name_ar, type, account_number, account_name, sort_order) VALUES
('instapay', 'إنستاباي', 'bank', '01000000000', 'Moscow Store', 1),
('vodafone_cash', 'فودافون كاش', 'wallet', '01000000000', 'Moscow Store', 2),
('bank_transfer', 'تحويل بنكي', 'bank', '123456789', 'Moscow Store', 3);

-- SEED DATA: Settings
INSERT INTO settings (key, value) VALUES
('store_name', 'Moscow Store'),
('store_description', 'متجرك المتخصص في شحن الألعاب'),
('maintenance_mode', 'false'),
('contact_phone', '01000000000'),
('contact_email', 'info@moscowstore.com'),
('min_wallet_deposit', '10'),
('loyalty_points_rate', '10'),
('referral_points', '50');

-- ROW LEVEL SECURITY
ALTER TABLE games ENABLE ROW LEVEL SECURITY;
ALTER TABLE packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Public read for games, packages, accounts, payment methods
CREATE POLICY "Public read games" ON games FOR SELECT USING (true);
CREATE POLICY "Public read packages" ON packages FOR SELECT USING (true);
CREATE POLICY "Public read accounts" ON accounts FOR SELECT USING (true);
CREATE POLICY "Public read payment_methods" ON payment_methods FOR SELECT USING (true);
CREATE POLICY "Public read settings" ON settings FOR SELECT USING (true);

-- Customers can read their own data
CREATE POLICY "Customers read own" ON customers FOR SELECT USING (auth.role() = 'authenticated' AND id::text = auth.uid()::text);
CREATE POLICY "Customers update own" ON customers FOR UPDATE USING (auth.role() = 'authenticated' AND id::text = auth.uid()::text);

-- Customers can read their own orders
CREATE POLICY "Customers read own orders" ON orders FOR SELECT USING (auth.role() = 'authenticated' AND customer_id::text = auth.uid()::text);
CREATE POLICY "Customers create orders" ON orders FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Customers can read their own wallet transactions
CREATE POLICY "Customers read own wallet" ON wallet_transactions FOR SELECT USING (auth.role() = 'authenticated' AND customer_id::text = auth.uid()::text);

-- Customers can read their own chat messages
CREATE POLICY "Customers read own chat" ON chat_messages FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Customers create chat" ON chat_messages FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Admin full access (using a custom claim or service role)
CREATE POLICY "Admin all games" ON games FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "Admin all packages" ON packages FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "Admin all accounts" ON accounts FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "Admin all orders" ON orders FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "Admin all customers" ON customers FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "Admin all settings" ON settings FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "Admin all payment_methods" ON payment_methods FOR ALL USING (auth.role() = 'service_role');
