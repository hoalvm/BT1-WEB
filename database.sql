CREATE DATABASE IF NOT EXISTS jpa_web
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE jpa_web;

CREATE TABLE IF NOT EXISTS categories (
    category_id INT NOT NULL AUTO_INCREMENT,
    category_name VARCHAR(255) NOT NULL,
    images VARCHAR(500) NULL,
    status INT NOT NULL DEFAULT 1,
    PRIMARY KEY (category_id),
    CONSTRAINT uk_categories_category_name UNIQUE (category_name),
    CONSTRAINT chk_categories_status CHECK (status IN (0, 1))
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS videos (
    video_id VARCHAR(100) NOT NULL,
    active INT NOT NULL DEFAULT 1,
    description TEXT NULL,
    poster VARCHAR(500) NULL,
    title VARCHAR(255) NULL,
    views INT NOT NULL DEFAULT 0,
    category_id INT NULL,
    PRIMARY KEY (video_id),
    INDEX idx_videos_category_id (category_id),
    CONSTRAINT fk_videos_categories
        FOREIGN KEY (category_id)
        REFERENCES categories (category_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_videos_active CHECK (active IN (0, 1)),
    CONSTRAINT chk_videos_views CHECK (views >= 0)
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

INSERT IGNORE INTO categories (category_name, images, status) VALUES
    ('Điện thoại', 'default.png', 1),
    ('Laptop', 'default.png', 0),
    ('Tablet', 'default.png', 1),
    ('Smart Watch', 'default.png', 0),
    ('Tai nghe', 'default.png', 1),
    ('Camera', 'default.png', 0),
    ('Tivi', 'default.png', 1),
    ('Loa', 'default.png', 0),
    ('Phụ kiện', 'default.png', 1),
    ('Gaming', 'default.png', 0);
