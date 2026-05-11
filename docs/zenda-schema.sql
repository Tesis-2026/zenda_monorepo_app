-- ─────────────────────────────────────────────────────────────────
-- Zenda — PostgreSQL Schema
-- ─────────────────────────────────────────────────────────────────

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ─────────────────────────────────────────────────────────────────
-- ENUMS
-- ─────────────────────────────────────────────────────────────────

CREATE TYPE transaction_type          AS ENUM ('INCOME', 'EXPENSE');
CREATE TYPE category_type             AS ENUM ('SYSTEM', 'CUSTOM');
CREATE TYPE income_type               AS ENUM ('SCHOLARSHIP', 'PART_TIME', 'FAMILY', 'MIXED');
CREATE TYPE financial_literacy_level  AS ENUM ('LOW', 'MEDIUM', 'HIGH');
CREATE TYPE topic_difficulty          AS ENUM ('BEGINNER', 'INTERMEDIATE', 'ADVANCED');
CREATE TYPE user_challenge_status     AS ENUM ('AVAILABLE', 'ACTIVE', 'COMPLETED');
CREATE TYPE recommendation_type       AS ENUM ('SAVINGS', 'BUDGET', 'GOAL');
CREATE TYPE survey_type               AS ENUM ('PRE', 'POST', 'SUS');
CREATE TYPE notification_type         AS ENUM (
  'BUDGET_ALERT', 'ANOMALY_ALERT', 'PREDICTION_READY',
  'CHALLENGE_REMINDER', 'DAILY_REMINDER', 'BADGE_EARNED'
);
CREATE TYPE feedback_type             AS ENUM ('BUG', 'SUGGESTION', 'GENERAL');

-- ─────────────────────────────────────────────────────────────────
-- CORE
-- ─────────────────────────────────────────────────────────────────

CREATE TABLE users (
  id                       UUID                    PRIMARY KEY DEFAULT gen_random_uuid(),
  email                    VARCHAR                 NOT NULL UNIQUE,
  password_hash            VARCHAR                 NOT NULL,
  full_name                VARCHAR                 NOT NULL,
  age                      INTEGER,
  university               VARCHAR,
  income_type              income_type,
  average_monthly_income   NUMERIC(12, 2),
  financial_literacy_level financial_literacy_level,
  profile_completed        BOOLEAN                 NOT NULL DEFAULT FALSE,
  currency                 VARCHAR                 NOT NULL DEFAULT 'PEN',
  consent_given            BOOLEAN                 NOT NULL DEFAULT FALSE,
  consent_at               TIMESTAMP,
  failed_login_attempts    INTEGER                 NOT NULL DEFAULT 0,
  locked_until             TIMESTAMP,
  created_at               TIMESTAMP               NOT NULL DEFAULT NOW(),
  updated_at               TIMESTAMP               NOT NULL DEFAULT NOW(),
  deleted_at               TIMESTAMP
);

CREATE TABLE categories (
  id               UUID             PRIMARY KEY DEFAULT gen_random_uuid(),
  name             VARCHAR          NOT NULL,
  type             category_type    NOT NULL DEFAULT 'CUSTOM',
  transaction_type transaction_type,                         -- null = applies to both types
  user_id          UUID             REFERENCES users(id) ON DELETE CASCADE, -- null = system category
  created_at       TIMESTAMP        NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMP        NOT NULL DEFAULT NOW(),
  deleted_at       TIMESTAMP
);

CREATE TABLE transactions (
  id          UUID             PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID             NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  category_id UUID             REFERENCES categories(id) ON DELETE SET NULL,
  type        transaction_type NOT NULL,
  amount      NUMERIC(12, 2)   NOT NULL,
  currency    VARCHAR          NOT NULL DEFAULT 'PEN',
  description VARCHAR          NOT NULL,
  occurred_at TIMESTAMP        NOT NULL DEFAULT NOW(),
  created_at  TIMESTAMP        NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMP        NOT NULL DEFAULT NOW(),
  deleted_at  TIMESTAMP
);

CREATE TABLE savings_goals (
  id             UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID           NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name           VARCHAR        NOT NULL,
  target_amount  NUMERIC(12, 2) NOT NULL,
  current_amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
  due_date       TIMESTAMP,
  created_at     TIMESTAMP      NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMP      NOT NULL DEFAULT NOW(),
  deleted_at     TIMESTAMP
);

CREATE TABLE goal_contributions (
  id         UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
  goal_id    UUID           NOT NULL REFERENCES savings_goals(id) ON DELETE CASCADE,
  amount     NUMERIC(12, 2) NOT NULL,
  created_at TIMESTAMP      NOT NULL DEFAULT NOW()
);

CREATE TABLE budgets (
  id           UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID           NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  category_id  UUID           REFERENCES categories(id) ON DELETE SET NULL, -- null = global budget
  amount_limit NUMERIC(12, 2) NOT NULL,
  month        INTEGER        NOT NULL,
  year         INTEGER        NOT NULL,
  created_at   TIMESTAMP      NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMP      NOT NULL DEFAULT NOW(),
  deleted_at   TIMESTAMP,
  UNIQUE (user_id, category_id, month, year)
);

-- ─────────────────────────────────────────────────────────────────
-- NOTIFICATIONS
-- ─────────────────────────────────────────────────────────────────

CREATE TABLE notification_preferences (
  id         UUID              PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID              NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type       notification_type NOT NULL,
  enabled    BOOLEAN           NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP         NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP         NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, type)
);

-- ─────────────────────────────────────────────────────────────────
-- EDUCATION & GAMIFICATION
-- ─────────────────────────────────────────────────────────────────

CREATE TABLE educational_topics (
  id         UUID             PRIMARY KEY DEFAULT gen_random_uuid(),
  title      VARCHAR          NOT NULL,
  content    TEXT             NOT NULL,
  difficulty topic_difficulty NOT NULL DEFAULT 'BEGINNER',
  "order"    INTEGER          NOT NULL DEFAULT 0,
  created_at TIMESTAMP        NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP        NOT NULL DEFAULT NOW()
);

CREATE TABLE quiz_questions (
  id                 UUID             PRIMARY KEY DEFAULT gen_random_uuid(),
  topic_id           UUID             REFERENCES educational_topics(id) ON DELETE SET NULL,
  question_group_key VARCHAR          NOT NULL, -- groups EN + ES variants of the same question
  language           VARCHAR          NOT NULL, -- 'en' or 'es'
  difficulty         topic_difficulty NOT NULL,
  text               TEXT             NOT NULL,
  options            JSONB            NOT NULL, -- String[]
  correct_answer     VARCHAR          NOT NULL,
  created_at         TIMESTAMP        NOT NULL DEFAULT NOW(),
  updated_at         TIMESTAMP        NOT NULL DEFAULT NOW()
);

CREATE TABLE user_topic_progress (
  id           UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  topic_id     UUID      NOT NULL REFERENCES educational_topics(id) ON DELETE CASCADE,
  completed_at TIMESTAMP,
  created_at   TIMESTAMP NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, topic_id)
);

CREATE TABLE challenges (
  id            UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
  title         VARCHAR   NOT NULL,
  description   TEXT      NOT NULL,
  criteria_json JSONB     NOT NULL,
  reward        VARCHAR,
  created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE user_challenges (
  id           UUID                  PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID                  NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  challenge_id UUID                  NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
  status       user_challenge_status NOT NULL DEFAULT 'AVAILABLE',
  accepted_at  TIMESTAMP,
  completed_at TIMESTAMP,
  created_at   TIMESTAMP             NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMP             NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, challenge_id)
);

CREATE TABLE badges (
  id          UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
  name        VARCHAR   NOT NULL UNIQUE,
  description TEXT      NOT NULL,
  criteria    VARCHAR   NOT NULL,
  icon_url    VARCHAR,
  created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE user_badges (
  id        UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id   UUID      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  badge_id  UUID      NOT NULL REFERENCES badges(id) ON DELETE CASCADE,
  earned_at TIMESTAMP NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, badge_id)
);

-- ─────────────────────────────────────────────────────────────────
-- AI / ML
-- ─────────────────────────────────────────────────────────────────

CREATE TABLE predictions (
  id                    UUID             PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id               UUID             NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  period                VARCHAR          NOT NULL, -- Format: YYYY-MM
  type                  transaction_type NOT NULL,
  predicted_total       NUMERIC(12, 2)   NOT NULL,
  predicted_by_category JSONB,           -- {category_id, category_name, amount}[]
  confidence_interval   JSONB,           -- {lower, upper}
  model_version         VARCHAR,
  actual_total          NUMERIC(12, 2),  -- filled after period ends
  accuracy              NUMERIC(5, 2),   -- retrospective accuracy %
  created_at            TIMESTAMP        NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMP        NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, period, type)
);

CREATE TABLE recommendations (
  id               UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID                NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type             recommendation_type NOT NULL,
  message          TEXT                NOT NULL,
  suggested_action VARCHAR,
  is_active        BOOLEAN             NOT NULL DEFAULT TRUE,
  created_at       TIMESTAMP           NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMP           NOT NULL DEFAULT NOW()
);

CREATE TABLE recommendation_feedback (
  id                UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
  recommendation_id UUID      NOT NULL UNIQUE REFERENCES recommendations(id) ON DELETE CASCADE,
  accepted          BOOLEAN   NOT NULL,
  created_at        TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ─────────────────────────────────────────────────────────────────
-- SURVEYS
-- ─────────────────────────────────────────────────────────────────

CREATE TABLE surveys (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  type       survey_type NOT NULL,
  created_at TIMESTAMP   NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP   NOT NULL DEFAULT NOW()
);

CREATE TABLE survey_questions (
  id             UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
  survey_id      UUID      NOT NULL REFERENCES surveys(id) ON DELETE CASCADE,
  "order"        INTEGER   NOT NULL,
  text           TEXT      NOT NULL,
  options        JSONB     NOT NULL, -- String[]
  correct_answer VARCHAR            -- null = open-ended question
);

CREATE TABLE survey_responses (
  id           UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID           NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  survey_id    UUID           NOT NULL REFERENCES surveys(id) ON DELETE CASCADE,
  answers_json JSONB          NOT NULL, -- question_id → selected_option
  score        NUMERIC(5, 2),           -- 0–100
  completed_at TIMESTAMP      NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, survey_id)
);

-- ─────────────────────────────────────────────────────────────────
-- ANALYTICS & SECURITY
-- ─────────────────────────────────────────────────────────────────

CREATE TABLE analytics_events (
  id         UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  event_type VARCHAR   NOT NULL,
  metadata   JSONB,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE audit_logs (
  id         UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID      REFERENCES users(id) ON DELETE SET NULL, -- null = system action
  action     VARCHAR   NOT NULL,
  resource   VARCHAR   NOT NULL,
  metadata   JSONB,
  ip_address VARCHAR,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE password_reset_tokens (
  id         UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token      VARCHAR   NOT NULL UNIQUE,
  expires_at TIMESTAMP NOT NULL,
  used_at    TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE password_reset_otps (
  id         UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  email      VARCHAR   NOT NULL,
  code       VARCHAR   NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  used_at    TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE refresh_tokens (
  id         UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token      VARCHAR   NOT NULL UNIQUE,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE feedback (
  id          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type        feedback_type NOT NULL DEFAULT 'GENERAL',
  message     TEXT          NOT NULL,
  screen_name VARCHAR,
  rating      INTEGER       CHECK (rating BETWEEN 1 AND 5),
  created_at  TIMESTAMP     NOT NULL DEFAULT NOW()
);

-- ─────────────────────────────────────────────────────────────────
-- INDEXES
-- ─────────────────────────────────────────────────────────────────

-- users
CREATE INDEX idx_users_email                   ON users(email);

-- categories
CREATE INDEX idx_categories_type_user          ON categories(type, user_id, deleted_at);

-- transactions
CREATE INDEX idx_transactions_user_date        ON transactions(user_id, occurred_at);
CREATE INDEX idx_transactions_user_category    ON transactions(user_id, category_id);
CREATE INDEX idx_transactions_user_type_date   ON transactions(user_id, type, occurred_at);

-- savings_goals
CREATE INDEX idx_savings_goals_user            ON savings_goals(user_id);

-- goal_contributions
CREATE INDEX idx_goal_contributions_goal       ON goal_contributions(goal_id);

-- budgets
CREATE INDEX idx_budgets_user_period           ON budgets(user_id, month, year);

-- notification_preferences
CREATE INDEX idx_notification_prefs_user       ON notification_preferences(user_id);

-- quiz_questions
CREATE INDEX idx_quiz_questions_topic          ON quiz_questions(topic_id, difficulty, language);
CREATE INDEX idx_quiz_questions_group_key      ON quiz_questions(question_group_key);

-- user_topic_progress
CREATE INDEX idx_user_topic_progress_user      ON user_topic_progress(user_id);

-- user_challenges
CREATE INDEX idx_user_challenges_user_status   ON user_challenges(user_id, status);

-- user_badges
CREATE INDEX idx_user_badges_user              ON user_badges(user_id);

-- predictions
CREATE INDEX idx_predictions_user_period       ON predictions(user_id, period);

-- recommendations
CREATE INDEX idx_recommendations_user_active   ON recommendations(user_id, is_active);

-- survey_questions
CREATE INDEX idx_survey_questions_survey_order ON survey_questions(survey_id, "order");

-- survey_responses
CREATE INDEX idx_survey_responses_user         ON survey_responses(user_id);

-- analytics_events
CREATE INDEX idx_analytics_events_user_type    ON analytics_events(user_id, event_type);
CREATE INDEX idx_analytics_events_created      ON analytics_events(created_at);

-- audit_logs
CREATE INDEX idx_audit_logs_user               ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action_resource    ON audit_logs(action, resource);
CREATE INDEX idx_audit_logs_created            ON audit_logs(created_at);

-- password_reset_tokens
CREATE INDEX idx_reset_tokens_user             ON password_reset_tokens(user_id);

-- password_reset_otps
CREATE INDEX idx_reset_otps_email              ON password_reset_otps(email);
CREATE INDEX idx_reset_otps_user               ON password_reset_otps(user_id);

-- refresh_tokens
CREATE INDEX idx_refresh_tokens_user           ON refresh_tokens(user_id);

-- feedback
CREATE INDEX idx_feedback_user                 ON feedback(user_id);
CREATE INDEX idx_feedback_type                 ON feedback(type);
