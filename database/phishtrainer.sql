CREATE DATABASE IF NOT EXISTS phishtrainer
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE phishtrainer;

CREATE TABLE IF NOT EXISTS users (
 user_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(100) NOT NULL,
 email VARCHAR(190) NOT NULL UNIQUE,
 password_hash VARCHAR(255) NOT NULL,
 role ENUM('admin','user') NOT NULL DEFAULT 'user',
 account_status ENUM('active','inactive','pending') NOT NULL DEFAULT 'pending',
 email_verified_at DATETIME NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS learning_modules (
 module_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 title VARCHAR(160) NOT NULL,
 slug VARCHAR(180) NOT NULL UNIQUE,
 fraud_category ENUM('banking_fraud','sms_fraud','phone_call_fraud','delivery_fraud','social_media_fraud','email_phishing','qr_code_fraud','other') NOT NULL,
 short_description VARCHAR(500) NULL,
 learning_content LONGTEXT NOT NULL,
 youtube_url VARCHAR(500) NULL,
 estimated_minutes SMALLINT UNSIGNED NULL,
 visibility ENUM('public','registered') NOT NULL DEFAULT 'public',
 status ENUM('draft','published','archived') NOT NULL DEFAULT 'draft',
 created_by BIGINT UNSIGNED NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 CONSTRAINT fk_modules_creator FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS module_progress (
 progress_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id BIGINT UNSIGNED NOT NULL,
 module_id BIGINT UNSIGNED NOT NULL,
 progress_status ENUM('not_started','in_progress','completed') NOT NULL DEFAULT 'not_started',
 started_at DATETIME NULL,
 completed_at DATETIME NULL,
 last_accessed_at DATETIME NULL,
 UNIQUE KEY uq_user_module_progress (user_id,module_id),
 CONSTRAINT fk_progress_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
 CONSTRAINT fk_progress_module FOREIGN KEY (module_id) REFERENCES learning_modules(module_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS quiz_questions (
 question_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 module_id BIGINT UNSIGNED NOT NULL,
 question_text TEXT NOT NULL,
 option_a VARCHAR(500) NOT NULL,
 option_b VARCHAR(500) NOT NULL,
 option_c VARCHAR(500) NOT NULL,
 option_d VARCHAR(500) NOT NULL,
 correct_option ENUM('A','B','C','D') NOT NULL,
 explanation TEXT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_question_module FOREIGN KEY (module_id) REFERENCES learning_modules(module_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS quiz_attempts (
 attempt_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id BIGINT UNSIGNED NOT NULL,
 module_id BIGINT UNSIGNED NOT NULL,
 score DECIMAL(5,2) NOT NULL DEFAULT 0,
 total_questions SMALLINT UNSIGNED NOT NULL,
 correct_answers SMALLINT UNSIGNED NOT NULL DEFAULT 0,
 attempted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_attempt_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
 CONSTRAINT fk_attempt_module FOREIGN KEY (module_id) REFERENCES learning_modules(module_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS content_analyses (
 analysis_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id BIGINT UNSIGNED NOT NULL,
 submitted_type ENUM('url','message_text','email_text') NOT NULL,
 submitted_content_redacted TEXT NOT NULL,
 predicted_category ENUM('banking_fraud','sms_fraud','phone_call_fraud','delivery_fraud','social_media_fraud','email_phishing','qr_code_fraud','other','unknown') NOT NULL DEFAULT 'unknown',
 risk_level ENUM('low','medium','high','unknown') NOT NULL DEFAULT 'unknown',
 confidence DECIMAL(5,2) NULL,
 explanation TEXT NULL,
 provider_name VARCHAR(100) NULL,
 analysis_status ENUM('completed','pending','failed') NOT NULL DEFAULT 'pending',
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_analysis_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS user_experiences (
 experience_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id BIGINT UNSIGNED NOT NULL,
 module_id BIGINT UNSIGNED NULL,
 experience_text TEXT NOT NULL,
 moderation_status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_experience_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
 CONSTRAINT fk_experience_module FOREIGN KEY (module_id) REFERENCES learning_modules(module_id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS campaigns (
 campaign_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 campaign_name VARCHAR(160) NOT NULL,
 description TEXT NULL,
 module_id BIGINT UNSIGNED NOT NULL,
 start_at DATETIME NOT NULL,
 deadline_at DATETIME NOT NULL,
 campaign_status ENUM('draft','published','active','completed','cancelled') NOT NULL DEFAULT 'draft',
 created_by BIGINT UNSIGNED NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_campaign_module FOREIGN KEY (module_id) REFERENCES learning_modules(module_id),
 CONSTRAINT fk_campaign_creator FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS campaign_assignments (
 assignment_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 campaign_id BIGINT UNSIGNED NOT NULL,
 user_id BIGINT UNSIGNED NOT NULL,
 assignment_status ENUM('assigned','in_progress','completed','overdue','cancelled') NOT NULL DEFAULT 'assigned',
 assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 completed_at DATETIME NULL,
 UNIQUE KEY uq_campaign_user (campaign_id,user_id),
 CONSTRAINT fk_assignment_campaign FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id) ON DELETE CASCADE,
 CONSTRAINT fk_assignment_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS notifications (
 notification_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id BIGINT UNSIGNED NOT NULL,
 notification_type ENUM('module_reminder','campaign_assigned','campaign_deadline','completion','account') NOT NULL,
 subject VARCHAR(200) NOT NULL,
 message TEXT NOT NULL,
 scheduled_at DATETIME NULL,
 sent_at DATETIME NULL,
 delivery_status ENUM('queued','sent','failed') NOT NULL DEFAULT 'queued',
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_notification_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS user_reports (
 report_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id BIGINT UNSIGNED NOT NULL,
 analysis_id BIGINT UNSIGNED NULL,
 report_category VARCHAR(100) NULL,
 report_description TEXT NOT NULL,
 review_status ENUM('pending','reviewed','closed') NOT NULL DEFAULT 'pending',
 admin_notes TEXT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_report_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
 CONSTRAINT fk_report_analysis FOREIGN KEY (analysis_id) REFERENCES content_analyses(analysis_id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS audit_logs (
 log_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id BIGINT UNSIGNED NULL,
 action VARCHAR(120) NOT NULL,
 module_name VARCHAR(100) NOT NULL,
 description TEXT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB;
