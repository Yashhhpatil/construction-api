-- schema.sql
-- Run this script to manually create all tables in MySQL
-- Either use this OR let Sequelize auto-sync (server.js does auto-sync)
-- 
-- To run: mysql -u root -p < schema.sql
-- Or paste into MySQL Workbench / phpMyAdmin

-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS construction_db;
USE construction_db;

-- ─────────────────────────────────────────────────────────────────────────────
-- USERS TABLE
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  name         VARCHAR(100)  NOT NULL,
  email        VARCHAR(100)  NOT NULL UNIQUE,
  phone        VARCHAR(20)   NULL,
  password_hash VARCHAR(255) NOT NULL,
  role         ENUM('admin', 'manager', 'worker') NOT NULL DEFAULT 'worker',
  created_at   TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);

-- ─────────────────────────────────────────────────────────────────────────────
-- PROJECTS TABLE
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS projects (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(200)   NOT NULL,
  description TEXT           NULL,
  start_date  DATE           NOT NULL,
  end_date    DATE           NOT NULL,
  status      ENUM('planned', 'active', 'completed') NOT NULL DEFAULT 'planned',
  budget      DECIMAL(15,2)  NULL,
  location    VARCHAR(255)   NULL,
  created_by  INT            NOT NULL,
  created_at  TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,

  -- Foreign key: created_by references users.id
  -- ON DELETE RESTRICT: prevents deleting a user who has projects
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ─────────────────────────────────────────────────────────────────────────────
-- DAILY REPORTS TABLE
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS daily_reports (
  id               INT AUTO_INCREMENT PRIMARY KEY,
  project_id       INT       NOT NULL,
  user_id          INT       NOT NULL,
  date             DATE      NOT NULL,
  work_description TEXT      NOT NULL,
  weather          VARCHAR(100) NULL,
  worker_count     INT       NOT NULL DEFAULT 0,
  created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  -- Foreign keys
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (user_id)    REFERENCES users(id)    ON DELETE RESTRICT ON UPDATE CASCADE,

  -- Composite index for faster queries on project + date
  INDEX idx_project_date (project_id, date)
);

-- ─────────────────────────────────────────────────────────────────────────────
-- SAMPLE DATA (optional — useful for testing)
-- ─────────────────────────────────────────────────────────────────────────────

-- Insert a default admin user
-- Password: admin123 (bcrypt hash of 'admin123')
INSERT INTO users (name, email, phone, password_hash, role) VALUES
('Admin User', 'admin@example.com', '9999999999',
 '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin');

-- Note: The above hash is bcrypt('admin123', 10)
-- After running the API, register users through POST /auth/register instead
