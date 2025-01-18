/*
 Navicat Premium Data Transfer

 Source Server         : test
 Source Server Type    : MySQL
 Source Server Version : 80039
 Source Host           : localhost:3306
 Source Schema         : tutor_system

 Target Server Type    : MySQL
 Target Server Version : 80039
 File Encoding         : 65001

 Date: 18/01/2025 23:57:02
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for available_times
-- ----------------------------
DROP TABLE IF EXISTS `available_times`;
CREATE TABLE `available_times`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `teacher_id` int NOT NULL,
  `day_of_week` tinyint NOT NULL,
  `time_slot` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `teacher_id`(`teacher_id` ASC) USING BTREE,
  CONSTRAINT `available_times_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 30 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of available_times
-- ----------------------------
INSERT INTO `available_times` VALUES (4, 2, 2, '下午');
INSERT INTO `available_times` VALUES (5, 2, 4, '晚上');
INSERT INTO `available_times` VALUES (6, 2, 6, '上午');
INSERT INTO `available_times` VALUES (7, 3, 3, '上午');
INSERT INTO `available_times` VALUES (8, 3, 5, '下午');
INSERT INTO `available_times` VALUES (9, 3, 7, '晚上');
INSERT INTO `available_times` VALUES (10, 4, 2, '上午');
INSERT INTO `available_times` VALUES (11, 4, 4, '下午');
INSERT INTO `available_times` VALUES (12, 4, 6, '晚上');
INSERT INTO `available_times` VALUES (13, 5, 1, '下午');
INSERT INTO `available_times` VALUES (14, 5, 3, '晚上');
INSERT INTO `available_times` VALUES (15, 5, 5, '上午');
INSERT INTO `available_times` VALUES (16, 6, 2, '晚上');
INSERT INTO `available_times` VALUES (17, 6, 4, '上午');
INSERT INTO `available_times` VALUES (18, 6, 6, '下午');
INSERT INTO `available_times` VALUES (19, 7, 1, '晚上');
INSERT INTO `available_times` VALUES (20, 7, 3, '上午');
INSERT INTO `available_times` VALUES (21, 7, 5, '下午');
INSERT INTO `available_times` VALUES (22, 8, 2, '下午');
INSERT INTO `available_times` VALUES (23, 8, 4, '晚上');
INSERT INTO `available_times` VALUES (24, 8, 6, '上午');
INSERT INTO `available_times` VALUES (26, 1, 0, 'morning');
INSERT INTO `available_times` VALUES (27, 1, 0, 'afternoon');
INSERT INTO `available_times` VALUES (28, 1, 0, 'evening');
INSERT INTO `available_times` VALUES (29, 1, 1, 'afternoon');

-- ----------------------------
-- Table structure for certificates
-- ----------------------------
DROP TABLE IF EXISTS `certificates`;
CREATE TABLE `certificates`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `teacher_id` int NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `issue_date` date NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `teacher_id`(`teacher_id` ASC) USING BTREE,
  CONSTRAINT `certificates_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of certificates
-- ----------------------------
INSERT INTO `certificates` VALUES (1, 1, '高级教师资格证', '/static/uploads/certificates/cert_1_1735821674_1696814441488533.png', '2020-01-15', '2025-01-02 20:23:01');
INSERT INTO `certificates` VALUES (2, 2, '雅思教学认证', '/static/uploads/certificates/cert_1_1735821674_1696814441488533.png', '2019-06-20', '2025-01-02 20:23:01');
INSERT INTO `certificates` VALUES (3, 3, '物理学科带头人', '/static/uploads/certificates/cert_1_1735821674_1696814441488533.png', '2021-03-10', '2025-01-02 20:23:01');
INSERT INTO `certificates` VALUES (4, 4, '语文教学特级教师', '/static/uploads/certificates/cert_1_1735821674_1696814441488533.png', '2019-08-15', '2025-01-02 20:30:48');
INSERT INTO `certificates` VALUES (5, 5, '数学竞赛指导老师', '/static/uploads/certificates/cert_1_1735821674_1696814441488533.png', '2018-05-20', '2025-01-02 20:30:48');
INSERT INTO `certificates` VALUES (6, 6, '剑桥英语教学认证', '/static/uploads/certificates/cert_1_1735821674_1696814441488533.png', '2020-03-10', '2025-01-02 20:30:48');
INSERT INTO `certificates` VALUES (7, 7, '青年教师教学能手', '/static/uploads/certificates/cert_1_1735821674_1696814441488533.png', '2021-06-18', '2025-01-02 20:30:48');
INSERT INTO `certificates` VALUES (8, 8, '实验教学优秀教师', '/static/uploads/certificates/cert_1_1735821674_1696814441488533.png', '2020-09-25', '2025-01-02 20:30:48');
INSERT INTO `certificates` VALUES (9, 1, '高级教师证', '/static/uploads/certificates/cert_1_1735821674_1696814441488533.png', '2025-01-09', '2025-01-02 20:41:14');

-- ----------------------------
-- Table structure for courses
-- ----------------------------
DROP TABLE IF EXISTS `courses`;
CREATE TABLE `courses`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `subject` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `teacher_id` int NOT NULL,
  `grade_level` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '高中',
  `price` decimal(10, 2) NULL DEFAULT 200.00,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `course_type` enum('online','offline','both') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'both' COMMENT '课程形式：线上、线下或两者都可',
  `max_students` int NOT NULL DEFAULT 20 COMMENT '报名限额',
  `current_students` int NOT NULL DEFAULT 0 COMMENT '当前报名人数',
  `location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '上课地点（线下课程）',
  `online_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '线上课程链接',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `teacher_id`(`teacher_id` ASC) USING BTREE,
  CONSTRAINT `courses_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 39 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of courses
-- ----------------------------
INSERT INTO `courses` VALUES (1, '高中数学基础强化', NULL, '数学', 1, '高中', 200.00, 'active', '2025-01-05 00:18:52', 'both', 20, 0, NULL, NULL);
INSERT INTO `courses` VALUES (2, '高考英语冲刺班', NULL, '英语', 2, '高中', 250.00, 'active', '2025-01-05 00:18:52', 'both', 20, 0, NULL, NULL);
INSERT INTO `courses` VALUES (3, '物理思维训练营', NULL, '物理', 3, '高中', 220.00, 'active', '2025-01-05 00:18:52', 'both', 20, 0, NULL, NULL);
INSERT INTO `courses` VALUES (4, '语文阅读写作提升', NULL, '语文', 4, '高中', 180.00, 'active', '2025-01-05 00:18:52', 'both', 20, 0, NULL, NULL);
INSERT INTO `courses` VALUES (5, '高考数学冲刺班', NULL, '数学', 5, '高中', 280.00, 'active', '2025-01-05 00:18:52', 'both', 20, 0, NULL, NULL);
INSERT INTO `courses` VALUES (6, '初中数学培优班', NULL, '数学', 1, '初中', 180.00, 'active', '2025-01-05 00:18:52', 'both', 20, 0, NULL, NULL);
INSERT INTO `courses` VALUES (7, '小学奥数提高班', NULL, '数学', 2, '小学', 150.00, 'active', '2025-01-05 00:18:52', 'both', 20, 0, NULL, NULL);
INSERT INTO `courses` VALUES (20, '高中数学基础强化', '针对高中数学基础知识的系统性强化训练', '数学', 1, '高中', 200.00, 'active', '2025-01-02 21:04:10', 'offline', 20, 10, '教学楼A301', NULL);
INSERT INTO `courses` VALUES (21, '高考数学冲刺班', '针对高考重点题型，系统性复习和提高', '数学', 5, '高中', 280.00, 'active', '2025-01-02 21:04:10', 'online', 20, 8, '教学楼A301', NULL);
INSERT INTO `courses` VALUES (22, '初中数学培优班', '夯实初中数学基础，培养数学思维', '数学', 1, '初中', 180.00, 'active', '2025-01-02 21:04:10', 'offline', 20, 5, '教学楼A301', NULL);
INSERT INTO `courses` VALUES (23, '小学奥数提高班', '培养数学兴趣，开发数学思维', '数学', 5, '小学', 150.00, 'active', '2025-01-02 21:04:10', 'both', 20, 7, '教学楼A301', NULL);
INSERT INTO `courses` VALUES (24, '高考英语冲刺班', '针对高考英语考试的专项训练和重点复习', '英语', 2, '高中', 250.00, 'active', '2025-01-02 21:04:10', 'online', 20, 16, '教学楼A301', NULL);
INSERT INTO `courses` VALUES (25, '高考英语写作班', '系统提高英语写作能力，掌握高分技巧', '英语', 2, '高中', 260.00, 'active', '2025-01-02 21:04:10', 'both', 20, 6, '教学楼A301', NULL);
INSERT INTO `courses` VALUES (26, '初中英语听说班', '提高英语听说能力，培养英语兴趣', '英语', 6, '初中', 200.00, 'active', '2025-01-02 21:04:10', 'both', 20, 4, '教学楼A301', NULL);
INSERT INTO `courses` VALUES (27, '小学英语启蒙班', '趣味英语教学，培养语感', '英语', 6, '小学', 160.00, 'active', '2025-01-02 21:04:10', 'offline', 20, 9, '教学楼A301', NULL);
INSERT INTO `courses` VALUES (28, '物理思维训练营', '培养物理思维，提高解题能力', '物理', 3, '高中', 220.00, 'active', '2025-01-02 21:04:10', 'both', 20, 9, '实验楼B201', NULL);
INSERT INTO `courses` VALUES (29, '高考物理实验班', '重点讲解物理实验，提高实验能力', '物理', 7, '高中', 260.00, 'active', '2025-01-02 21:04:10', 'both', 20, 13, '实验楼B201', NULL);
INSERT INTO `courses` VALUES (30, '初中物理思维班', '培养物理思维，建立物理概念', '物理', 3, '初中', 200.00, 'active', '2025-01-02 21:04:10', 'offline', 20, 16, '实验楼B201', NULL);
INSERT INTO `courses` VALUES (31, '语文阅读写作提升', '提高语文阅读理解和写作水平', '语文', 4, '高中', 180.00, 'active', '2025-01-02 21:04:10', 'both', 20, 2, '教学楼A301', NULL);
INSERT INTO `courses` VALUES (32, '作文高分技巧班', '系统讲解作文写作技巧，提高写作水平', '语文', 4, '高中', 240.00, 'active', '2025-01-02 21:04:10', 'both', 20, 8, '教学楼A301', NULL);
INSERT INTO `courses` VALUES (33, '初中语文阅读班', '提高阅读理解能力，培养文学素养', '语文', 4, '初中', 190.00, 'active', '2025-01-02 21:04:10', 'both', 20, 11, '教学楼A301', NULL);
INSERT INTO `courses` VALUES (34, '小学语文基础班', '夯实语文基础，提高阅读写作能力', '语文', 4, '小学', 140.00, 'active', '2025-01-02 21:04:10', 'online', 20, 7, '教学楼A301', NULL);
INSERT INTO `courses` VALUES (35, '高考化学专题班', '针对性讲解化学难点，突破重点', '化学', 8, '高中', 250.00, 'active', '2025-01-02 21:04:10', 'both', 1, 1, '实验楼B201', NULL);
INSERT INTO `courses` VALUES (36, '初中化学入门班', '化学基础知识讲解，实验操作训练', '化学', 7, '初中', 190.00, 'active', '2025-01-02 21:04:10', 'both', 20, 3, '实验楼B201', NULL);
INSERT INTO `courses` VALUES (37, '高考生物复习班', '系统复习生物知识，突破考点', '生物', 8, '高中', 230.00, 'active', '2025-01-02 21:04:10', 'offline', 20, 6, '教学楼A301', NULL);
INSERT INTO `courses` VALUES (38, '初中生物提高班', '加深对生物学的理解，培养学习兴趣', '生物', 8, '初中', 180.00, 'active', '2025-01-02 21:04:10', 'both', 1, 0, '教学楼A301', NULL);

-- ----------------------------
-- Table structure for enrollments
-- ----------------------------
DROP TABLE IF EXISTS `enrollments`;
CREATE TABLE `enrollments`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `course_id` int NOT NULL,
  `enroll_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'pending',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `student_id`(`student_id` ASC) USING BTREE,
  INDEX `course_id`(`course_id` ASC) USING BTREE,
  CONSTRAINT `enrollments_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `enrollments_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of enrollments
-- ----------------------------

-- ----------------------------
-- Table structure for learning_records
-- ----------------------------
DROP TABLE IF EXISTS `learning_records`;
CREATE TABLE `learning_records`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `course_id` int NOT NULL,
  `teacher_id` int NOT NULL,
  `date` date NOT NULL,
  `duration` int NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `student_id`(`student_id` ASC) USING BTREE,
  INDEX `course_id`(`course_id` ASC) USING BTREE,
  INDEX `teacher_id`(`teacher_id` ASC) USING BTREE,
  CONSTRAINT `learning_records_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `learning_records_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `learning_records_ibfk_3` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 40 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of learning_records
-- ----------------------------

-- ----------------------------
-- Table structure for ratings
-- ----------------------------
DROP TABLE IF EXISTS `ratings`;
CREATE TABLE `ratings`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `teacher_id` int NOT NULL,
  `student_id` int NOT NULL,
  `rating` decimal(2, 1) NOT NULL,
  `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `course_id` int NULL DEFAULT NULL,
  `attitude_rating` decimal(2, 1) NULL DEFAULT NULL,
  `teaching_rating` decimal(2, 1) NULL DEFAULT NULL,
  `content_rating` decimal(2, 1) NULL DEFAULT NULL,
  `tags` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `teacher_id`(`teacher_id` ASC) USING BTREE,
  INDEX `student_id`(`student_id` ASC) USING BTREE,
  INDEX `course_id`(`course_id` ASC) USING BTREE,
  CONSTRAINT `ratings_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ratings_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ratings_ibfk_3` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 45 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ratings
-- ----------------------------
INSERT INTO `ratings` VALUES (9, 1, 1, 4.5, '李老师讲课很细致，特别是对数学概念的讲解非常到位，让人容易理解。', '2024-12-15 14:30:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (10, 1, 1, 5.0, '数学成绩提升很快，李老师的教学方法很适合我。', '2024-12-20 16:45:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (11, 1, 1, 4.0, '讲课认真负责，但有时候讲得太快了。', '2024-12-25 09:15:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (12, 1, 1, 4.8, '很耐心，会针对学生的薄弱环节反复讲解。', '2024-12-30 10:20:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (13, 2, 1, 4.8, '王老师的英语发音标准，听力训练效果明显。', '2024-12-10 15:20:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (14, 2, 1, 5.0, '上课氛围很好，互动性强，学习英语变得有趣了。', '2024-12-18 11:30:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (15, 2, 1, 4.7, '作文指导很有帮助，分数提高了不少。', '2024-12-22 14:40:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (16, 2, 1, 4.9, '口语训练方法很实用，现在说英语更自信了。', '2024-12-28 16:15:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (17, 3, 1, 4.6, '物理概念讲解到位，举例生动，很容易理解。', '2024-12-12 10:45:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (18, 3, 1, 4.8, '实验课讲解很详细，对考试很有帮助。', '2024-12-19 13:50:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (19, 3, 1, 4.5, '题目讲解思路清晰，但有时候例题可以多一些。', '2024-12-24 15:30:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (20, 3, 1, 4.7, '善于用生活中的例子解释物理现象，很生动。', '2024-12-29 11:20:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (21, 4, 1, 4.7, '赵老师的语文课很有趣，让枯燥的知识变得生动。', '2024-12-11 09:30:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (22, 4, 1, 4.9, '作文指导非常专业，文章结构和用词都有很大提升。', '2024-12-17 14:20:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (23, 4, 1, 4.8, '课堂氛围活跃，阅读理解能力提升明显。', '2024-12-23 16:40:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (24, 4, 1, 4.6, '古文讲解很到位，但课后作业量有点大。', '2024-12-27 10:15:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (25, 5, 1, 4.9, '钱老师数学教得很好，重点难点讲解特别清晰。', '2024-12-13 11:25:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (26, 5, 1, 5.0, '押题特别准，考试很有帮助。', '2024-12-16 15:40:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (27, 5, 1, 4.8, '讲课有条理，思路清晰，易于理解。', '2024-12-21 13:35:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (28, 5, 1, 4.7, '题型讲解很全面，但节奏稍快。', '2024-12-26 14:50:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (29, 6, 1, 4.6, '孙老师的口语课很棒，发音进步很大。', '2024-12-14 10:30:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (30, 6, 1, 4.8, '课堂活动丰富，学习英语变得很有趣。', '2024-12-18 15:45:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (31, 6, 1, 4.7, '听力训练方法很实用，但课后作业量较大。', '2024-12-22 11:20:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (32, 6, 1, 4.5, '教学经验丰富，但有时候语速太快。', '2024-12-28 14:30:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (33, 7, 1, 4.7, '周老师理科功底很强，讲解通俗易懂。', '2024-12-15 13:40:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (34, 7, 1, 4.8, '实验课讲解细致，操作示范清楚。', '2024-12-19 16:25:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (35, 7, 1, 4.6, '习题讲解很到位，但偶尔概念讲得太深。', '2024-12-24 10:50:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (36, 7, 1, 4.9, '善于总结知识点，考试复习很有帮助。', '2024-12-29 15:15:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (37, 8, 1, 4.5, '吴老师的实验课很精彩，让化学变得有趣。', '2024-12-12 14:20:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (38, 8, 1, 4.7, '生物知识讲解很生动，举例贴近生活。', '2024-12-17 11:30:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (39, 8, 1, 4.8, '实验操作讲解仔细，安全意识强。', '2024-12-23 15:40:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (40, 8, 1, 4.6, '课堂互动多，学习氛围好，但课后练习可以再多一些。', '2024-12-27 16:20:00', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `ratings` VALUES (43, 4, 1, 4.5, '老师讲课很细致，讲解到位，举例生动', '2024-12-27 00:00:00', 4, 4.5, 4.5, 4.5, '讲解清晰,耐心细致,举例生动');
INSERT INTO `ratings` VALUES (44, 5, 1, 5.0, '老师非常专业，课程内容丰富，互动性强', '2024-12-25 00:00:00', 5, 5.0, 5.0, 5.0, '讲解清晰,互动性强,重点突出');

-- ----------------------------
-- Table structure for schedules
-- ----------------------------
DROP TABLE IF EXISTS `schedules`;
CREATE TABLE `schedules`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `course_id` int NOT NULL,
  `teacher_id` int NOT NULL,
  `date` date NOT NULL,
  `time` time NOT NULL,
  `location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `status` enum('pending','confirmed','cancelled','completed','rated') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `duration` int NULL DEFAULT 90 COMMENT '课程时长(分钟)',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `student_id`(`student_id` ASC) USING BTREE,
  INDEX `course_id`(`course_id` ASC) USING BTREE,
  INDEX `teacher_id`(`teacher_id` ASC) USING BTREE,
  CONSTRAINT `schedules_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `schedules_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `schedules_ibfk_3` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 36 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of schedules
-- ----------------------------
INSERT INTO `schedules` VALUES (26, 1, 1, 1, '2025-01-03', '14:00:00', NULL, 'completed', '2025-01-05 00:18:52', 120);
INSERT INTO `schedules` VALUES (27, 1, 2, 2, '2025-01-02', '16:00:00', NULL, 'completed', '2025-01-05 00:18:52', 90);
INSERT INTO `schedules` VALUES (28, 1, 3, 3, '2024-12-31', '09:00:00', NULL, 'completed', '2025-01-05 00:18:52', 120);
INSERT INTO `schedules` VALUES (29, 1, 4, 4, '2024-12-26', '15:00:00', NULL, 'rated', '2025-01-05 00:18:52', 90);
INSERT INTO `schedules` VALUES (30, 1, 5, 5, '2024-12-24', '10:00:00', NULL, 'rated', '2025-01-05 00:18:52', 120);
INSERT INTO `schedules` VALUES (31, 1, 6, 1, '2025-01-06', '14:00:00', NULL, 'confirmed', '2025-01-05 00:18:52', 120);
INSERT INTO `schedules` VALUES (32, 1, 7, 2, '2025-01-08', '16:00:00', NULL, 'confirmed', '2025-01-05 00:18:52', 90);
INSERT INTO `schedules` VALUES (33, 1, 1, 1, '2025-01-03', '14:00:00', NULL, 'completed', '2025-01-05 00:23:29', 120);
INSERT INTO `schedules` VALUES (34, 1, 2, 2, '2025-01-02', '16:00:00', NULL, 'completed', '2025-01-05 00:23:29', 90);
INSERT INTO `schedules` VALUES (35, 1, 3, 3, '2024-12-31', '09:00:00', NULL, 'completed', '2025-01-05 00:23:29', 120);

-- ----------------------------
-- Table structure for students
-- ----------------------------
DROP TABLE IF EXISTS `students`;
CREATE TABLE `students`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `grade` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `avatar_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of students
-- ----------------------------
INSERT INTO `students` VALUES (1, 'student1', 'password', '13800138000', 'zhangsan@example.com', '2025-01-02 20:23:01', '张三', '高三', '/static/images/default-avatar.png');

-- ----------------------------
-- Table structure for teachers
-- ----------------------------
DROP TABLE IF EXISTS `teachers`;
CREATE TABLE `teachers`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `years_of_experience` int NULL DEFAULT 0,
  `subjects` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `introduction` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `avatar_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of teachers
-- ----------------------------
INSERT INTO `teachers` VALUES (1, 'teacher1', 'password', '李老师', '13800138002', 'teacher1@example.com', '2025-01-02 20:23:01', 5, '英语,化学,生物,历史', '具有多年教学经验，擅长因材施教。', '/static/uploads/avatars/1_1736003994_202412231622383.jpg');
INSERT INTO `teachers` VALUES (2, 'teacher2', 'password', '王老师', '13800138003', 'teacher2@example.com', '2025-01-02 20:23:01', 8, '英语', '专注英语教学8年，善于激发学习兴趣', '/static/uploads/avatars/2_1735822005_20241223162238.jpg');
INSERT INTO `teachers` VALUES (3, 'teacher3', 'password', '张老师', '13800138004', 'teacher3@example.com', '2025-01-02 20:23:01', 6, '物理', '物理教学经验丰富，注重培养解题思维', '/static/uploads/avatars/3_1735822779_202412231622394.jpg');
INSERT INTO `teachers` VALUES (4, 'teacher4', 'password', '赵老师', '13800138005', 'teacher4@example.com', '2025-01-02 20:30:47', 10, '语文', '从教十年，善于培养学生的语文素养和写作能力', '/static/uploads/avatars/4_1735823094_202412231622382.jpg');
INSERT INTO `teachers` VALUES (5, 'teacher5', 'password', '钱老师', '13800138006', 'teacher5@example.com', '2025-01-02 20:30:47', 15, '数学', '特级教师，多年高考押题经验', '/static/uploads/avatars/5_1735823108_202412231622392.jpg');
INSERT INTO `teachers` VALUES (6, 'teacher6', 'password', '孙老师', '13800138007', 'teacher6@example.com', '2025-01-02 20:30:47', 7, '英语', '海外留学背景，口语教学见长', '/static/uploads/avatars/6_1735823123_202412231622383.jpg');
INSERT INTO `teachers` VALUES (7, 'teacher7', 'password', '周老师', '13800138008', 'teacher7@example.com', '2025-01-02 20:30:47', 12, '物理,化学', '理工科复合型教师，善于举一反三', '/static/uploads/avatars/7_1735823201_202412231622381.jpg');
INSERT INTO `teachers` VALUES (8, 'teacher8', 'password', '吴老师', '13800138009', 'teacher8@example.com', '2025-01-02 20:30:47', 9, '化学,生物', '化学教学能手，实验教学经验丰富', '/static/uploads/avatars/8_1735823219_20241223162239.jpg');

SET FOREIGN_KEY_CHECKS = 1;
