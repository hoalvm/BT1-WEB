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
    ('Smartphones', 'default.png', 1),
    ('Laptops', 'default.png', 0),
    ('Tablets', 'default.png', 1),
    ('Smartwatches', 'default.png', 0),
    ('Headphones', 'default.png', 1),
    ('Cameras', 'default.png', 0),
    ('Televisions', 'default.png', 1),
    ('Speakers', 'default.png', 0),
    ('Accessories', 'default.png', 1),
    ('Gaming', 'default.png', 0);
