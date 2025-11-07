-- MySQL 데이터베이스 스크립트 (DDL 및 DML)
-- 이 스크립트는 운동 영상 추천 및 리뷰 서비스를 위한 8개의 테이블을 생성하고 더미 데이터를 삽입합니다.

-- -----------------------------------------------------
-- 1. 데이터베이스 설정 (필수: 스크립트 실행 전에 데이터베이스를 생성하고 선택합니다.)
-- 데이터베이스가 없으면 새로 생성하며, 문자 인코딩을 utf8mb4로 설정하여 한글을 지원합니다.

USE fitness_service;
-- -----------------------------------------------------

-- 기존 테이블이 있을 경우 안전하게 제거 (역순으로 제거)
DROP TABLE IF EXISTS `CommunityComments`;
DROP TABLE IF EXISTS `CommunityPosts`;
DROP TABLE IF EXISTS `PlanItems`;
DROP TABLE IF EXISTS `WorkoutPlans`;
DROP TABLE IF EXISTS `Reviews`;
DROP TABLE IF EXISTS `VideoBodyParts`;
DROP TABLE IF EXISTS `Videos`;
DROP TABLE IF EXISTS `Users`;

-- =====================================================
-- DDL (Data Definition Language): 테이블 생성
-- =====================================================

-- 1. Users (사용자 정보)
CREATE TABLE `Users` (
    `user_id` INT NOT NULL PRIMARY KEY,
    `username` VARCHAR(50) NOT NULL UNIQUE COMMENT '사용자 이름 (표시명)',
    `email` VARCHAR(100) NOT NULL UNIQUE COMMENT '사용자 이메일 (로그인 ID)',
    `joined_date` DATE NOT NULL COMMENT '가입일',
    `level` VARCHAR(10) COMMENT '사용자 운동 수준 (초보, 중급, 고급)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='사용자 정보';

-- 2. Videos (운동 영상 정보)
CREATE TABLE `Videos` (
    `video_id` INT NOT NULL PRIMARY KEY,
    `title` VARCHAR(255) NOT NULL COMMENT '영상 제목',
    `url` VARCHAR(255) NOT NULL COMMENT '영상 URL (예: YouTube)',
    `duration_seconds` INT NOT NULL COMMENT '영상 길이 (초)',
    `difficulty` INT NOT NULL CHECK (`difficulty` BETWEEN 1 AND 5) COMMENT '난이도 (1:쉬움 ~ 5:어려움)',
    `uploader` VARCHAR(100) COMMENT '영상 채널/업로더 이름',
    `upload_date` DATE COMMENT '영상 업로드 날짜'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='운동 영상 정보';

-- 3. VideoBodyParts (영상-운동 부위 연결)
CREATE TABLE `VideoBodyParts` (
    `video_body_part_id` INT NOT NULL PRIMARY KEY,
    `video_id` INT NOT NULL COMMENT '영상 ID',
    `body_part` VARCHAR(50) NOT NULL COMMENT '운동 부위 (전신, 하체, 가슴, 등, 코어 등)',
    FOREIGN KEY (`video_id`) REFERENCES `Videos`(`video_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='영상-운동 부위 연결';

-- 4. Reviews (영상 리뷰 및 평점)
CREATE TABLE `Reviews` (
    `review_id` INT NOT NULL PRIMARY KEY,
    `video_id` INT NOT NULL COMMENT '리뷰 대상 영상 ID',
    `user_id` INT NOT NULL COMMENT '리뷰 작성자 ID',
    `rating` INT NOT NULL CHECK (`rating` BETWEEN 1 AND 5) COMMENT '평점 (1~5점)',
    `content` TEXT NOT NULL COMMENT '리뷰 내용',
    `created_at` DATETIME NOT NULL COMMENT '리뷰 작성 시간',
    FOREIGN KEY (`video_id`) REFERENCES `Videos`(`video_id`) ON DELETE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='영상 리뷰 및 평점';

-- 5. WorkoutPlans (운동 계획)
CREATE TABLE `WorkoutPlans` (
    `plan_id` INT NOT NULL PRIMARY KEY,
    `user_id` INT NOT NULL COMMENT '계획 생성 사용자 ID',
    `plan_name` VARCHAR(100) NOT NULL COMMENT '운동 계획 이름',
    `description` TEXT COMMENT '계획 상세 설명',
    `created_at` DATETIME NOT NULL COMMENT '계획 생성 시간',
    FOREIGN KEY (`user_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='운동 계획';

-- 6. PlanItems (계획 항목)
CREATE TABLE `PlanItems` (
    `plan_item_id` INT NOT NULL PRIMARY KEY,
    `plan_id` INT NOT NULL COMMENT '소속된 계획 ID',
    `video_id` INT NOT NULL COMMENT '포함된 영상 ID',
    `order_index` INT NOT NULL COMMENT '계획 내 순서',
    FOREIGN KEY (`plan_id`) REFERENCES `WorkoutPlans`(`plan_id`) ON DELETE CASCADE,
    FOREIGN KEY (`video_id`) REFERENCES `Videos`(`video_id`) ON DELETE CASCADE,
    UNIQUE KEY `unique_plan_item` (`plan_id`, `video_id`) -- 한 계획에 같은 영상 중복 방지
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='계획 항목';

-- 7. CommunityPosts (커뮤니티 게시글)
CREATE TABLE `CommunityPosts` (
    `post_id` INT NOT NULL PRIMARY KEY,
    `user_id` INT NOT NULL COMMENT '작성자 ID',
    `title` VARCHAR(255) NOT NULL COMMENT '게시글 제목',
    `content` TEXT NOT NULL COMMENT '게시글 내용',
    `created_at` DATETIME NOT NULL COMMENT '작성 시간',
    `views` INT DEFAULT 0 COMMENT '조회수',
    FOREIGN KEY (`user_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='커뮤니티 게시글';

-- 8. CommunityComments (커뮤니티 댓글)
CREATE TABLE `CommunityComments` (
    `comment_id` INT NOT NULL PRIMARY KEY,
    `post_id` INT NOT NULL COMMENT '소속 게시글 ID',
    `user_id` INT NOT NULL COMMENT '작성자 ID',
    `content` TEXT NOT NULL COMMENT '댓글 내용',
    `created_at` DATETIME NOT NULL COMMENT '작성 시간',
    FOREIGN KEY (`post_id`) REFERENCES `CommunityPosts`(`post_id`) ON DELETE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='커뮤니티 댓글';

-- =====================================================
-- DML (Data Manipulation Language): 더미 데이터 삽입
-- =====================================================

-- 1. Users 더미 데이터
INSERT INTO `Users` (`user_id`, `username`, `email`, `joined_date`, `level`) VALUES
(1, '김헬스', 'kim.health@example.com', '2024-01-10', '중급'),
(2, '박필라테스', 'park.pilates@example.com', '2024-02-15', '초보'),
(3, '최요가', 'choi.yoga@example.com', '2024-03-20', '고급');

-- 2. Videos 더미 데이터
INSERT INTO `Videos` (`video_id`, `title`, `url`, `duration_seconds`, `difficulty`, `uploader`, `upload_date`) VALUES
(101, '10분 전신 유산소 운동', 'https://www.google.com/search?q=youtube.com/v101', 600, 2, '핏블리', '2024-05-01'),
(102, '초보자를 위한 하체 근력 루틴', 'https://www.google.com/search?q=youtube.com/v102', 900, 1, '땅크부부', '2024-05-03'),
(103, '고강도 복근 운동 챌린지', 'https://www.google.com/search?q=youtube.com/v103', 1200, 4, '운동의신', '2024-05-05'),
(104, '폼롤러를 이용한 등 근육 이완', 'https://www.google.com/search?q=youtube.com/v104', 720, 2, '릴렉스요가', '2024-05-08');

-- 3. VideoBodyParts 더미 데이터
INSERT INTO `VideoBodyParts` (`video_body_part_id`, `video_id`, `body_part`) VALUES
(1, 101, '전신'),
(2, 101, '유산소'),
(3, 102, '하체'),
(4, 102, '근력'),
(5, 103, '코어'),
(6, 103, '복근'),
(7, 104, '등'),
(8, 104, '스트레칭');

-- 4. Reviews 더미 데이터
INSERT INTO `Reviews` (`review_id`, `video_id`, `user_id`, `rating`, `content`, `created_at`) VALUES
(501, 101, 1, 5, '땀이 많이 났어요! 짧은 시간에 효과 최고입니다.', '2024-05-15 10:00:00'),
(502, 102, 2, 4, '초보자도 따라하기 쉬웠지만, 설명이 조금 부족했어요.', '2024-05-16 14:30:00'),
(503, 103, 3, 5, '난이도 4 맞네요. 복근 터지는 줄 알았습니다!', '2024-05-17 19:10:00'),
(504, 104, 1, 5, '운동 후 이완용으로 최고입니다. 자세 설명도 친절해요.', '2024-05-18 08:45:00');

-- 5. WorkoutPlans 더미 데이터
INSERT INTO `WorkoutPlans` (`plan_id`, `user_id`, `plan_name`, `description`, `created_at`) VALUES
(701, 1, '주 3회 체지방 불태우기', '월, 수, 금 루틴입니다. 유산소와 근력 병행.', '2024-05-10 11:20:00'),
(702, 3, '코어 강화와 유연성', '매일 아침 진행하는 요가 및 코어 루틴.', '2024-05-12 09:00:00');

-- 6. PlanItems 더미 데이터
INSERT INTO `PlanItems` (`plan_item_id`, `plan_id`, `video_id`, `order_index`) VALUES
(801, 701, 101, 1),
(802, 701, 102, 2),
(803, 701, 104, 3),
(804, 702, 103, 1),
(805, 702, 104, 2);

-- 7. CommunityPosts 더미 데이터
INSERT INTO `CommunityPosts` (`post_id`, `user_id`, `title`, `content`, `created_at`, `views`) VALUES
(901, 1, '오늘 운동 완료 인증!', '10분 유산소 챌린지 성공했습니다. 다들 화이팅!', '2024-05-19 12:00:00', 55),
(902, 2, '초보인데 하체 루틴 추천 부탁드려요', '난이도 1~2 정도의 영상으로 루틴 짜고 싶어요.', '2024-05-19 15:30:00', 30);

-- 8. CommunityComments 더미 데이터
INSERT INTO `CommunityComments` (`comment_id`, `post_id`, `user_id`, `content`, `created_at`) VALUES
(951, 901, 3, '대단하십니다! 저도 도전해봐야겠어요.', '2024-05-19 12:30:00'),
(952, 902, 1, '102번 영상 추천합니다! 난이도도 낮고 좋아요.', '2024-05-19 16:00:00');
