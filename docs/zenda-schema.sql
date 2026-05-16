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
CREATE TYPE recommendation_type       AS ENUM ('SAVINGS', 'BUDGET', 'GOAL');
CREATE TYPE survey_type               AS ENUM ('PRE', 'POST', 'SUS');
CREATE TYPE notification_type         AS ENUM (
  'BUDGET_ALERT', 'ANOMALY_ALERT', 'PREDICTION_READY',
  'CHALLENGE_REMINDER', 'DAILY_REMINDER', 'BADGE_EARNED'
);
CREATE TYPE feedback_type             AS ENUM ('BUG', 'SUGGESTION', 'GENERAL');
CREATE TYPE audit_status              AS ENUM ('SUCCESS', 'FAILURE');
CREATE TYPE auth_challenge_kind       AS ENUM ('RESET_TOKEN', 'OTP');

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
  notification_prefs       JSONB                   NOT NULL DEFAULT '{}', -- { NotificationType: boolean }; missing keys default to true
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
-- NOTIFICATIONS — preferences live as JSON on users.notification_prefs
-- ─────────────────────────────────────────────────────────────────

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
  id             UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  topic_id       UUID          NOT NULL REFERENCES educational_topics(id) ON DELETE CASCADE,
  completed_at   TIMESTAMP,
  score          NUMERIC(5, 2),                  -- 0–100, latest quiz score for this topic
  attempts_count INTEGER       NOT NULL DEFAULT 0,
  created_at     TIMESTAMP     NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, topic_id)
);

-- Per-attempt quiz history (US-1004). Powers the >=20% literacy-improvement KPI.
CREATE TABLE quiz_attempts (
  id              UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  question_id     UUID      NOT NULL REFERENCES quiz_questions(id) ON DELETE CASCADE,
  topic_id        UUID      REFERENCES educational_topics(id) ON DELETE SET NULL,
  selected_answer VARCHAR   NOT NULL,
  is_correct      BOOLEAN   NOT NULL,
  attempted_at    TIMESTAMP NOT NULL DEFAULT NOW(),
  created_at      TIMESTAMP NOT NULL DEFAULT NOW()
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

-- Status (AVAILABLE / ACTIVE / COMPLETED) is derived from (accepted_at, completed_at) — see
-- deriveChallengeStatus() in src/modules/challenges/domain/challenge.entity.ts.
CREATE TABLE user_challenges (
  id           UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  challenge_id UUID      NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
  accepted_at  TIMESTAMP,
  completed_at TIMESTAMP,
  created_at   TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMP NOT NULL DEFAULT NOW(),
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
  id                 UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id            UUID                NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type               recommendation_type NOT NULL,
  message            TEXT                NOT NULL,
  suggested_action   VARCHAR,
  is_active          BOOLEAN             NOT NULL DEFAULT TRUE,
  -- Traceability for the AI-history KPI (>=80% accuracy support)
  model_version      VARCHAR,                                       -- e.g. rules-v1 | azure-foundry-gpt-4o-2024-08-06
  source             VARCHAR,                                       -- e.g. local-rules | azure-foundry
  input_context_json JSONB,                                         -- snapshot of inputs used to generate
  -- Lifecycle history
  viewed_at          TIMESTAMP,
  dismissed_at       TIMESTAMP,
  expires_at         TIMESTAMP,
  -- Inlined feedback (was previously recommendation_feedback 1:1 table)
  feedback_accepted  BOOLEAN,
  feedback_at        TIMESTAMP,
  created_at         TIMESTAMP           NOT NULL DEFAULT NOW(),
  updated_at         TIMESTAMP           NOT NULL DEFAULT NOW()
);

-- ─────────────────────────────────────────────────────────────────
-- SURVEYS
-- ─────────────────────────────────────────────────────────────────

-- Questions are embedded as JSON inside surveys.questions_json (was a separate survey_questions table).
-- Shape: [{ id: uuid, order: int, text: string, options: string[], correctAnswer: string | null }]
CREATE TABLE surveys (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  type           survey_type NOT NULL,
  questions_json JSONB       NOT NULL DEFAULT '[]',
  created_at     TIMESTAMP   NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMP   NOT NULL DEFAULT NOW()
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
  id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID         REFERENCES users(id) ON DELETE SET NULL, -- actor; null = system/cron
  action      VARCHAR      NOT NULL,                                 -- e.g. DELETE_ACCOUNT, RESET_PASSWORD
  resource    VARCHAR      NOT NULL,                                 -- e.g. User, Transaction
  resource_id UUID,                                                  -- UUID of the affected resource
  status      audit_status NOT NULL DEFAULT 'SUCCESS',
  request_id  VARCHAR,                                               -- correlation id across same-request logs
  http_method VARCHAR,                                               -- GET, POST, PUT, DELETE…
  http_path   VARCHAR,                                               -- e.g. /api/transactions/:id
  ip_address  VARCHAR,
  user_agent  VARCHAR,
  before_json JSONB,                                                 -- state before the change
  after_json  JSONB,                                                 -- state after the change
  metadata    JSONB,
  created_at  TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- Unified auth challenges (was password_reset_tokens + password_reset_otps).
-- secret stores sha256(raw_token) for RESET_TOKEN or sha256(raw_code) for OTP.
CREATE TABLE auth_challenges (
  id         UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID                NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  kind       auth_challenge_kind NOT NULL,
  secret     VARCHAR             NOT NULL,
  email      VARCHAR,                                          -- only for OTP
  expires_at TIMESTAMP           NOT NULL,
  used_at    TIMESTAMP,
  created_at TIMESTAMP           NOT NULL DEFAULT NOW(),
  UNIQUE (kind, secret)
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

-- quiz_questions
CREATE INDEX idx_quiz_questions_topic          ON quiz_questions(topic_id, difficulty, language);
CREATE INDEX idx_quiz_questions_group_key      ON quiz_questions(question_group_key);

-- user_topic_progress
CREATE INDEX idx_user_topic_progress_user      ON user_topic_progress(user_id);

-- quiz_attempts
CREATE INDEX idx_quiz_attempts_user_topic_date ON quiz_attempts(user_id, topic_id, attempted_at);
CREATE INDEX idx_quiz_attempts_user_date       ON quiz_attempts(user_id, attempted_at);
CREATE INDEX idx_quiz_attempts_question        ON quiz_attempts(question_id);

-- user_challenges
CREATE INDEX idx_user_challenges_user_completed ON user_challenges(user_id, completed_at);
CREATE INDEX idx_user_challenges_user_accepted  ON user_challenges(user_id, accepted_at);

-- user_badges
CREATE INDEX idx_user_badges_user              ON user_badges(user_id);

-- predictions
CREATE INDEX idx_predictions_user_period       ON predictions(user_id, period);

-- recommendations
CREATE INDEX idx_recommendations_user_active    ON recommendations(user_id, is_active);
CREATE INDEX idx_recommendations_user_created   ON recommendations(user_id, created_at);
CREATE INDEX idx_recommendations_user_dismissed ON recommendations(user_id, dismissed_at);

-- survey_responses
CREATE INDEX idx_survey_responses_user         ON survey_responses(user_id);

-- analytics_events
CREATE INDEX idx_analytics_events_user_type    ON analytics_events(user_id, event_type);
CREATE INDEX idx_analytics_events_created      ON analytics_events(created_at);

-- audit_logs
CREATE INDEX idx_audit_logs_user_created       ON audit_logs(user_id, created_at);
CREATE INDEX idx_audit_logs_action_resource    ON audit_logs(action, resource);
CREATE INDEX idx_audit_logs_resource_resid     ON audit_logs(resource, resource_id);
CREATE INDEX idx_audit_logs_request            ON audit_logs(request_id);
CREATE INDEX idx_audit_logs_created            ON audit_logs(created_at);

-- auth_challenges
CREATE INDEX idx_auth_challenges_user_kind     ON auth_challenges(user_id, kind);
CREATE INDEX idx_auth_challenges_email_kind    ON auth_challenges(email, kind);

-- refresh_tokens
CREATE INDEX idx_refresh_tokens_user           ON refresh_tokens(user_id);

-- feedback
CREATE INDEX idx_feedback_user                 ON feedback(user_id);
CREATE INDEX idx_feedback_type                 ON feedback(type);
