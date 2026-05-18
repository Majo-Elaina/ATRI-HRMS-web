/*
 Navicat Premium Data Transfer

 Source Server         : Local
 Source Server Type    : MySQL
 Source Server Version : 80045 (8.0.45)
 Source Host           : localhost:3306
 Source Schema         : hrms_db

 Target Server Type    : MySQL
 Target Server Version : 80045 (8.0.45)
 File Encoding         : 65001

 Date: 18/05/2026 15:34:05
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for agent_approval_record
-- ----------------------------
DROP TABLE IF EXISTS `agent_approval_record`;
CREATE TABLE `agent_approval_record`  (
  `approval_id` int NOT NULL AUTO_INCREMENT,
  `task_id` int NOT NULL,
  `approver_user_id` int NOT NULL,
  `action` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`approval_id`) USING BTREE,
  INDEX `idx_agent_approval_task_id`(`task_id` ASC) USING BTREE,
  INDEX `idx_agent_approval_user_id`(`approver_user_id` ASC) USING BTREE,
  CONSTRAINT `fk_agent_approval_task` FOREIGN KEY (`task_id`) REFERENCES `agent_task` (`task_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_agent_approval_user` FOREIGN KEY (`approver_user_id`) REFERENCES `sys_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of agent_approval_record
-- ----------------------------

-- ----------------------------
-- Table structure for agent_execution_log
-- ----------------------------
DROP TABLE IF EXISTS `agent_execution_log`;
CREATE TABLE `agent_execution_log`  (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `task_id` int NOT NULL,
  `step_no` int NOT NULL DEFAULT 0,
  `log_level` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `idx_agent_execution_task_id`(`task_id` ASC) USING BTREE,
  INDEX `idx_agent_execution_step_no`(`step_no` ASC) USING BTREE,
  CONSTRAINT `fk_agent_execution_task` FOREIGN KEY (`task_id`) REFERENCES `agent_task` (`task_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of agent_execution_log
-- ----------------------------
INSERT INTO `agent_execution_log` VALUES (5, 3, 0, 'info', '计划已生成，来源：local-rule', '2026-05-18 13:55:11');
INSERT INTO `agent_execution_log` VALUES (6, 3, 0, 'warn', '当前支持的操作：个人请假申请、个人考勤补录、角色权限调整。', '2026-05-18 13:55:11');
INSERT INTO `agent_execution_log` VALUES (9, 5, 0, 'info', '计划已生成，来源：chat-provider:openai-compatible-primary', '2026-05-18 14:10:23');
INSERT INTO `agent_execution_log` VALUES (10, 6, 0, 'info', '计划已生成，来源：local-rule-fallback', '2026-05-18 14:48:01');
INSERT INTO `agent_execution_log` VALUES (11, 6, 0, 'info', '任务已被用户取消', '2026-05-18 15:00:25');

-- ----------------------------
-- Table structure for agent_task
-- ----------------------------
DROP TABLE IF EXISTS `agent_task`;
CREATE TABLE `agent_task`  (
  `task_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `command_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `intent` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `risk_level` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `provider_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `requires_approval` tinyint(1) NOT NULL DEFAULT 1,
  `executable` tinyint(1) NOT NULL DEFAULT 0,
  `plan_json` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `result_summary` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`task_id`) USING BTREE,
  INDEX `idx_agent_task_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_agent_task_status`(`status` ASC) USING BTREE,
  INDEX `idx_agent_task_create_time`(`create_time` ASC) USING BTREE,
  CONSTRAINT `fk_agent_task_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of agent_task
-- ----------------------------
INSERT INTO `agent_task` VALUES (3, 9, '帮我提交 1 天事假申请，原因是个人事务', 'unknown', 'medium', 'planned', 'local-rule', 1, 0, '{\"intent\":\"unknown\",\"summary\":\"当前指令未匹配到可执行的白名单操作\",\"riskLevel\":\"medium\",\"requiresApproval\":true,\"executable\":false,\"warnings\":[\"当前支持的操作：个人请假申请、个人考勤补录、角色权限调整。\"],\"entities\":[],\"preview\":{},\"steps\":[{\"stepNo\":1,\"title\":\"仅生成计划\",\"method\":\"LOCAL\",\"api\":\"agentPlanner\",\"payloadPreview\":{}}],\"rollbackPlan\":[]}', NULL, '2026-05-18 13:55:11', '2026-05-18 13:55:11');
INSERT INTO `agent_task` VALUES (5, 9, '帮我提交 2 天病假申请', 'leave.create', 'low', 'planned', 'chat-provider:openai-compatible-primary', 1, 1, '{\"intent\":\"leave.create\",\"summary\":\"为当前员工提交请假申请\",\"riskLevel\":\"low\",\"requiresApproval\":true,\"executable\":true,\"warnings\":[],\"entities\":[{\"type\":\"employee\",\"id\":16,\"name\":\"云月\"}],\"preview\":{\"leaveType\":\"病假\",\"startDate\":\"2023-10-01\",\"endDate\":\"2023-10-02\",\"days\":2,\"reason\":\"\"},\"steps\":[{\"stepNo\":1,\"title\":\"校验请假参数\",\"method\":\"LOCAL\",\"api\":\"agentValidator\",\"payloadPreview\":{\"leaveType\":\"病假\",\"startDate\":\"2023-10-01\",\"endDate\":\"2023-10-02\",\"days\":2,\"reason\":\"\"}},{\"stepNo\":2,\"title\":\"匹配审批链\",\"method\":\"LOCAL\",\"api\":\"approvalRuleRepository\",\"payloadPreview\":{\"identityTag\":\"ADMIN\",\"days\":2}},{\"stepNo\":3,\"title\":\"创建请假申请\",\"method\":\"POST\",\"api\":\"/api/leave-requests\",\"payloadPreview\":{\"leaveType\":\"病假\",\"startDate\":\"2023-10-01\",\"endDate\":\"2023-10-02\",\"days\":2,\"reason\":\"\"}}],\"rollbackPlan\":[\"如果提交有误，可在审批通过前撤销申请。\"]}', NULL, '2026-05-18 14:10:23', '2026-05-18 14:10:23');
INSERT INTO `agent_task` VALUES (6, 9, '为财务专员增加薪资记录查看权限', 'role-permission.update', 'high', 'cancelled', 'local-rule-fallback', 1, 1, '{\"intent\":\"role-permission.update\",\"summary\":\"增加一个角色的一项权限\",\"riskLevel\":\"high\",\"requiresApproval\":true,\"executable\":true,\"warnings\":[],\"entities\":[{\"type\":\"role\",\"id\":6,\"name\":\"财务专员\"},{\"type\":\"permission\",\"id\":32,\"name\":\"薪资记录查看\"}],\"preview\":{\"action\":\"add\",\"roleId\":6,\"roleName\":\"财务专员\",\"permissionId\":32,\"permissionName\":\"薪资记录查看\"},\"steps\":[{\"stepNo\":1,\"title\":\"读取角色当前权限集\",\"method\":\"GET\",\"api\":\"/api/role-permissions/role/6/perm-ids\",\"payloadPreview\":{}},{\"stepNo\":2,\"title\":\"应用权限变更\",\"method\":\"PUT\",\"api\":\"/api/role-permissions/role/6\",\"payloadPreview\":{\"action\":\"add\",\"roleId\":6,\"roleName\":\"财务专员\",\"permissionId\":32,\"permissionName\":\"薪资记录查看\"}}],\"rollbackPlan\":[\"如需恢复，可使用旧权限集重新覆盖。\"]}', '用户主动取消', '2026-05-18 14:48:01', '2026-05-18 15:00:25');

-- ----------------------------
-- Table structure for ai_chat_message
-- ----------------------------
DROP TABLE IF EXISTS `ai_chat_message`;
CREATE TABLE `ai_chat_message`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色：user/assistant',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '消息内容',
  `provider_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'AI提供商名称',
  `model_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '模型名称',
  `used_system_data` tinyint(1) NULL DEFAULT 0 COMMENT '是否使用了系统数据',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'AI聊天记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ai_chat_message
-- ----------------------------
INSERT INTO `ai_chat_message` VALUES (5, 9, 'user', '最近请假审批规则是什么？', NULL, NULL, NULL, '2026-03-14 01:09:19');
INSERT INTO `ai_chat_message` VALUES (6, 9, 'assistant', '主人，我来把当前系统里生效的请假审批规则清晰地梳理给你：\n\n**第一步：判断申请人身份**  \n系统会先识别申请人的角色标签（比如 ADMIN、EMPLOYEE、MANAGER 等），再匹配对应规则。\n\n**第二步：按身份 + 天数条件决定审批路径**  \n目前对不同身份的规则如下（已结合你作为 ADMIN 的权限确认）：\n\n- ✅ **如果你（ADMIN）发起请假**：无论请假几天，都只需 **总经理（GENERAL_MANAGER）一级审批** 即可通过；  \n- 🟡 如果是普通员工（EMPLOYEE）：  \n　→ 3天及以内：HR专员（HR_SPECIALIST）初审 → HR经理（HR_MANAGER）终审；  \n　→ 超过3天：同样走这两级，顺序不变；  \n- 🟡 如果是部门经理（MANAGER）或HR经理（HR_MANAGER）：  \n　→ 均需两级审批，第二级为总经理；  \n- 🟡 总经理本人请假：则由HR经理审批即可。\n\n📌 **补充说明**：  \n- 所有规则均基于系统当前配置，无需手动切换，提交时自动触发对应流程；  \n- 当前系统共启用 **6 条请假审批规则**（属于“请假审批规则”这一大类，该类共含 6 条，全部已激活）；  \n- 你作为总经办管理员，拥有全局查看权限，也可以在「系统设置 → 审批管理 → 请假审批规则」中随时核对或导出规则详情。\n\n需要我帮你展开某一条规则的具体配置逻辑，或者演示如何在后台查看/导出这些规则吗？', 'openai-compatible-primary', 'qwen-plus', 1, '2026-03-14 01:09:28');
INSERT INTO `ai_chat_message` VALUES (7, 9, 'user', '最近请假审批规则是什么？', NULL, NULL, NULL, '2026-03-14 01:09:57');
INSERT INTO `ai_chat_message` VALUES (8, 9, 'assistant', '主人，我刚刚再次确认了系统当前生效的请假审批规则——它们没有更新变动，和上次一致，但既然你又问了一次，说明可能想更清晰地掌握要点。那我用更聚焦的方式，为你重新梳理一遍：\n\n✅ **核心原则**：审批路径由「申请人身份」+「请假天数」共同决定，系统自动匹配，无需手动选择。\n\n🔍 **针对你（云月，身份标签=ADMIN）的规则**（最简明的一条）：  \n> 无论请1小时、1天，还是连续多日，**只需总经理（GENERAL_MANAGER）审批一次**，流程即结束。  \n→ 这是系统为 ADMIN 角色特别设置的高效路径，毕竟你是总经办管理员，也常需统筹协调呢。\n\n📎 其他常见角色作为参考（方便你日常管理或协助同事时对照）：  \n- 普通员工（EMPLOYEE）：≤3天 → HR专员初审 + HR经理终审；＞3天 → 同样两级，不加额外环节；  \n- 部门经理（MANAGER）：HR经理初审 → 总经理终审；  \n- HR经理本人：直接由总经理审批；  \n- 总经理本人：由HR经理审批。\n\n📊 补充事实（来自系统实时读取）：  \n- 当前共启用 **6 条请假审批规则**，全部归属「请假审批规则」类型；  \n- 所有规则均已发布生效，无草稿或待启用项；  \n- 规则逻辑已嵌入审批引擎，提交即触发，无需人工干预路径。\n\n需要我带你一步步查看这些规则在后台的具体配置界面？或者帮你生成一份可打印的规则速查表？请交给我吧～', 'openai-compatible-primary', 'qwen-plus', 1, '2026-03-14 01:10:06');
INSERT INTO `ai_chat_message` VALUES (9, 9, 'user', '今天绵阳市的天气', NULL, NULL, NULL, '2026-04-10 19:23:48');
INSERT INTO `ai_chat_message` VALUES (10, 9, 'assistant', '主人，我刚刚调取了系统实时天气数据——  \n今天（2026年4月10日）四川·绵阳市的天气是：**阴**，气温 **19℃**，西北风，风力 ≤3级，湿度 **76%**。  \n更新时间是今天 19:05:03，数据来自权威气象接口，已同步至系统。\n\n嗯，这也是高性能的判断：这样的天气很适合在办公室窗边泡一杯温茶，处理完手头事务后，稍作放松～  \n需要我帮你查明天的预报，或者提醒你带伞/添衣的小建议吗？', 'openai-compatible-primary', 'qwen-plus', 1, '2026-04-10 19:23:52');
INSERT INTO `ai_chat_message` VALUES (11, 6, 'user', '今天有谁请假了', NULL, NULL, NULL, '2026-04-10 20:00:22');
INSERT INTO `ai_chat_message` VALUES (12, 6, 'assistant', '主人，我刚刚查询了系统里的请假数据——但需要说明的是：当前系统中**所有请假记录均未包含具体的请假开始日期或结束日期字段**，因此无法按“今天（2026-04-10）”这个时间点筛选出“今日正在请假”或“今日发起请假”的人员。\n\n不过我可以确认：  \n✅ 系统当前共存有 9 条请假记录；  \n✅ 您本人（陈静）最近有两条已通过的请假：一次事假、一次年假（具体日期需点开记录查看）；  \n❌ 其余记录的申请人姓名、部门、请假起止时间等关键信息，在本次读取中未被系统返回，暂时无法确认。\n\n如果您需要进一步了解某位同事的请假情况，可以告诉我姓名或部门，我来帮您查是否有对应记录；或者，您也可以在“考勤管理 → 请假管理”页面中，使用日期范围筛选功能手动查看——系统支持按“申请日期”或“开始日期”检索哦。\n\n需要我陪您一起操作吗？😊', 'openai-compatible-primary', 'qwen-plus', 1, '2026-04-10 20:00:39');
INSERT INTO `ai_chat_message` VALUES (13, 9, 'user', '今天绵阳市的天气', NULL, NULL, NULL, '2026-05-18 14:01:30');
INSERT INTO `ai_chat_message` VALUES (14, 9, 'assistant', '我是亚托莉。虽然这次模型连接没有成功，不过主人先别着急，高性能的我还是会先把能确认的信息告诉你。\n\n抱歉，我暂时找不到「绵阳」的天气信息。\n\n这些内容来自当前系统里的只读数据，所以可以先把它当成可靠依据。\n\n如果你愿意，可以把问题再问得更具体一点。请交给我吧，我会继续认真回答你。', 'openai-compatible-primary', 'qwen-plus', 1, '2026-05-18 14:01:37');
INSERT INTO `ai_chat_message` VALUES (15, 9, 'user', '今天绵阳市的天气', NULL, NULL, NULL, '2026-05-18 14:04:52');
INSERT INTO `ai_chat_message` VALUES (16, 9, 'assistant', '主人，我刚刚核对了系统里最新同步的气象数据——  \n**今天（2026年5月18日）四川·绵阳市：阴，29℃，西北风4级，湿度42%。**  \n更新时间是今天 14:03:06，数据真实有效，已通过系统气象接口校验。\n\n嗯，这也是高性能的判断：风力稍强、湿度适中，适合开窗通风，但外出时记得留意防晒和防风哦～  \n需要我帮你查接下来两天的趋势，或者提醒你是否适合安排户外会议？', 'openai-compatible-primary', 'qwen-plus', 1, '2026-05-18 14:04:56');
INSERT INTO `ai_chat_message` VALUES (17, 9, 'user', '本公司员工总数是多少？', NULL, NULL, NULL, '2026-05-18 14:05:02');
INSERT INTO `ai_chat_message` VALUES (18, 9, 'assistant', '主人，我刚刚核对了系统里的最新数据：  \n**本公司当前员工总数是 16 人。**  \n\n这个数字是系统实时统计的只读结果，包含所有在职及试用期员工（例如周洋目前在技术部处于试用状态，也已计入），不包含离职、待入职或外包人员。\n\n需要我为你展开看看各部门分布，或者导出一份简明的部门-人数对照表吗？请交给我吧～', 'openai-compatible-primary', 'qwen-plus', 1, '2026-05-18 14:05:06');

-- ----------------------------
-- Table structure for approval_rule
-- ----------------------------
DROP TABLE IF EXISTS `approval_rule`;
CREATE TABLE `approval_rule`  (
  `rule_id` int NOT NULL AUTO_INCREMENT,
  `type_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `applicant_tag` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `days_op` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `days_value` decimal(6, 2) NOT NULL DEFAULT 0.00,
  `first_approver_tag` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `second_approver_tag` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `second_approver_scope` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `sort_order` int NOT NULL DEFAULT 0,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`rule_id`) USING BTREE,
  INDEX `idx_approval_rule_type_code`(`type_code` ASC) USING BTREE,
  INDEX `idx_approval_rule_applicant_tag`(`applicant_tag` ASC) USING BTREE,
  CONSTRAINT `fk_approval_rule_type` FOREIGN KEY (`type_code`) REFERENCES `approval_rule_type` (`type_code`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of approval_rule
-- ----------------------------
INSERT INTO `approval_rule` VALUES (1, 'leave', 'ADMIN', 'any', 0.00, 'GENERAL_MANAGER', NULL, NULL, 0, '2024-01-01 09:00:00', '2026-04-10 10:00:00');
INSERT INTO `approval_rule` VALUES (2, 'leave', 'FINANCE_SPECIALIST', '<=', 3.00, 'HR_SPECIALIST', NULL, NULL, 1, '2024-01-01 09:00:00', '2026-04-10 19:11:18');
INSERT INTO `approval_rule` VALUES (3, 'leave', 'FINANCE_SPECIALIST', '>', 3.00, 'HR_SPECIALIST', 'HR_MANAGER', 'company', 2, '2024-01-01 09:00:00', '2026-04-10 10:00:00');
INSERT INTO `approval_rule` VALUES (4, 'leave', 'HR_SPECIALIST', 'any', 0.00, 'HR_MANAGER', NULL, NULL, 3, '2024-01-01 09:00:00', '2026-04-10 19:13:00');
INSERT INTO `approval_rule` VALUES (5, 'leave', 'EMPLOYEE', '<=', 3.00, 'HR_SPECIALIST', NULL, NULL, 4, '2024-01-01 09:00:00', '2026-04-10 19:11:04');
INSERT INTO `approval_rule` VALUES (6, 'leave', 'EMPLOYEE', '>', 3.00, 'HR_SPECIALIST', 'HR_MANAGER', 'company', 5, '2024-01-01 09:00:00', '2026-04-10 10:00:00');
INSERT INTO `approval_rule` VALUES (7, 'leave', 'MANAGER', 'any', 0.00, 'HR_MANAGER', 'GENERAL_MANAGER', 'company', 6, '2024-01-01 09:00:00', '2026-04-10 10:00:00');
INSERT INTO `approval_rule` VALUES (8, 'leave', 'FINANCE_MANAGER', 'any', 0.00, 'HR_MANAGER', 'GENERAL_MANAGER', 'company', 7, '2024-01-01 09:00:00', '2026-04-10 10:00:00');
INSERT INTO `approval_rule` VALUES (9, 'leave', 'HR_MANAGER', 'any', 0.00, 'GENERAL_MANAGER', NULL, NULL, 8, '2024-01-01 09:00:00', '2026-04-10 10:00:00');
INSERT INTO `approval_rule` VALUES (10, 'leave', 'GENERAL_MANAGER', 'any', 0.00, 'HR_MANAGER', NULL, NULL, 9, '2026-03-14 01:08:31', '2026-04-10 10:00:00');
INSERT INTO `approval_rule` VALUES (11, 'salary_record', 'FINANCE_SPECIALIST', 'any', 0.00, 'FINANCE_MANAGER', NULL, 'company', 1, '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `approval_rule` VALUES (12, 'salary_config', 'FINANCE_SPECIALIST', 'any', 0.00, 'FINANCE_MANAGER', NULL, 'company', 1, '2024-01-01 09:00:00', '2024-01-01 09:00:00');

-- ----------------------------
-- Table structure for approval_rule_type
-- ----------------------------
DROP TABLE IF EXISTS `approval_rule_type`;
CREATE TABLE `approval_rule_type`  (
  `type_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `type_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `type_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '启用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`type_code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of approval_rule_type
-- ----------------------------
INSERT INTO `approval_rule_type` VALUES ('leave', '请假审批规则', '请假申请的审批流转规则', '启用', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `approval_rule_type` VALUES ('salary_config', '薪资配置审批规则', '薪资配置提交与审批流程', '启用', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `approval_rule_type` VALUES ('salary_record', '薪资记录审批规则', '薪资记录提交与审批流程', '启用', '2024-01-01 09:00:00', '2024-01-01 09:00:00');

-- ----------------------------
-- Table structure for attendance
-- ----------------------------
DROP TABLE IF EXISTS `attendance`;
CREATE TABLE `attendance`  (
  `attendance_id` int NOT NULL AUTO_INCREMENT,
  `emp_id` int NOT NULL,
  `attendance_date` date NOT NULL,
  `clock_in` time NULL DEFAULT NULL,
  `clock_out` time NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`attendance_id`) USING BTREE,
  UNIQUE INDEX `uk_attendance_emp_date`(`emp_id` ASC, `attendance_date` ASC) USING BTREE,
  INDEX `idx_attendance_date_status`(`attendance_date` ASC, `status` ASC) USING BTREE,
  CONSTRAINT `fk_attendance_emp` FOREIGN KEY (`emp_id`) REFERENCES `employee` (`emp_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of attendance
-- ----------------------------
INSERT INTO `attendance` VALUES (1, 1, '2024-01-15', '08:55:00', '18:05:00', '正常', NULL, '2024-01-15 18:05:00');
INSERT INTO `attendance` VALUES (2, 2, '2024-01-15', '09:10:00', '18:00:00', '迟到', '早会迟到10分钟', '2024-01-15 18:00:00');
INSERT INTO `attendance` VALUES (3, 3, '2024-01-15', '08:50:00', '17:30:00', '早退', '身体不适提前离岗', '2024-01-15 17:30:00');
INSERT INTO `attendance` VALUES (4, 4, '2024-01-15', '08:45:00', '18:10:00', '正常', NULL, '2024-01-15 18:10:00');
INSERT INTO `attendance` VALUES (5, 5, '2024-01-15', NULL, NULL, '请假', '年假中', '2024-01-15 09:00:00');
INSERT INTO `attendance` VALUES (6, 6, '2024-01-15', '08:30:00', '20:00:00', '加班', '项目上线支持', '2024-01-15 20:00:00');
INSERT INTO `attendance` VALUES (7, 7, '2024-01-15', '08:58:00', '18:02:00', '正常', NULL, '2024-01-15 18:02:00');
INSERT INTO `attendance` VALUES (8, 8, '2024-01-15', NULL, NULL, '缺勤', '未打卡且无请假记录', '2024-01-15 18:00:00');
INSERT INTO `attendance` VALUES (9, 1, '2026-03-13', '00:05:00', '00:11:00', '早退', '', '2026-03-14 00:05:52');

-- ----------------------------
-- Table structure for department
-- ----------------------------
DROP TABLE IF EXISTS `department`;
CREATE TABLE `department`  (
  `dept_id` int NOT NULL AUTO_INCREMENT,
  `dept_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `dept_desc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `parent_id` int NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`dept_id`) USING BTREE,
  UNIQUE INDEX `uk_department_name`(`dept_name` ASC) USING BTREE,
  INDEX `idx_department_parent_id`(`parent_id` ASC) USING BTREE,
  CONSTRAINT `fk_department_parent` FOREIGN KEY (`parent_id`) REFERENCES `department` (`dept_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of department
-- ----------------------------
INSERT INTO `department` VALUES (1, '总经办', '公司最高管理层', NULL, '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `department` VALUES (2, '人力资源部', '负责人力资源管理', 1, '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `department` VALUES (3, '财务部', '负责财务管理', 1, '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `department` VALUES (4, '技术部', '负责技术研发', 1, '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `department` VALUES (5, '市场部', '负责市场运营', 1, '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `department` VALUES (6, '行政部', '负责行政事务', 1, '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `department` VALUES (7, '综合部', '负责后勤与综合事务', 1, '2024-01-01 09:00:00', '2024-01-01 09:00:00');

-- ----------------------------
-- Table structure for dept_permission_template
-- ----------------------------
DROP TABLE IF EXISTS `dept_permission_template`;
CREATE TABLE `dept_permission_template`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `dept_id` int NOT NULL,
  `module_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_dept_permission_template`(`dept_id` ASC, `module_code` ASC) USING BTREE,
  INDEX `idx_dept_permission_template_module_code`(`module_code` ASC) USING BTREE,
  CONSTRAINT `fk_dept_permission_template_dept` FOREIGN KEY (`dept_id`) REFERENCES `department` (`dept_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_dept_permission_template_module` FOREIGN KEY (`module_code`) REFERENCES `module_scope_rule` (`module_code`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of dept_permission_template
-- ----------------------------
INSERT INTO `dept_permission_template` VALUES (1, 2, 'base:employee', '2024-01-01 09:00:00');
INSERT INTO `dept_permission_template` VALUES (2, 2, 'base:department', '2024-01-01 09:00:00');
INSERT INTO `dept_permission_template` VALUES (3, 2, 'base:position', '2024-01-01 09:00:00');
INSERT INTO `dept_permission_template` VALUES (4, 2, 'attendance:record', '2024-01-01 09:00:00');
INSERT INTO `dept_permission_template` VALUES (5, 2, 'attendance:leave', '2024-01-01 09:00:00');
INSERT INTO `dept_permission_template` VALUES (6, 2, 'report', '2024-01-01 09:00:00');
INSERT INTO `dept_permission_template` VALUES (7, 3, 'salary:record', '2024-01-01 09:00:00');
INSERT INTO `dept_permission_template` VALUES (8, 3, 'salary:config', '2024-01-01 09:00:00');
INSERT INTO `dept_permission_template` VALUES (9, 3, 'report', '2024-01-01 09:00:00');
INSERT INTO `dept_permission_template` VALUES (10, 4, 'attendance:record', '2024-01-01 09:00:00');
INSERT INTO `dept_permission_template` VALUES (11, 4, 'base:employee', '2024-01-01 09:00:00');
INSERT INTO `dept_permission_template` VALUES (12, 1, 'attendance:leave', '2026-03-14 00:05:29');
INSERT INTO `dept_permission_template` VALUES (13, 1, 'salary:config', '2026-03-14 00:05:29');
INSERT INTO `dept_permission_template` VALUES (14, 1, 'base:employee', '2026-03-14 00:05:29');
INSERT INTO `dept_permission_template` VALUES (15, 1, 'salary:record', '2026-03-14 00:05:29');
INSERT INTO `dept_permission_template` VALUES (16, 1, 'base:position', '2026-03-14 00:05:29');
INSERT INTO `dept_permission_template` VALUES (17, 1, 'attendance:record', '2026-03-14 00:05:29');
INSERT INTO `dept_permission_template` VALUES (18, 1, 'base:department', '2026-03-14 00:05:29');
INSERT INTO `dept_permission_template` VALUES (19, 1, 'report', '2026-03-14 00:05:29');

-- ----------------------------
-- Table structure for employee
-- ----------------------------
DROP TABLE IF EXISTS `employee`;
CREATE TABLE `employee`  (
  `emp_id` int NOT NULL AUTO_INCREMENT,
  `emp_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `gender` enum('男','女') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `id_card` varchar(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `birthday` date NULL DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `hire_date` date NOT NULL,
  `leave_date` date NULL DEFAULT NULL,
  `dept_id` int NOT NULL,
  `position_id` int NOT NULL,
  `identity_tag_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '在职',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`emp_id`) USING BTREE,
  UNIQUE INDEX `uk_employee_phone`(`phone` ASC) USING BTREE,
  UNIQUE INDEX `uk_employee_email`(`email` ASC) USING BTREE,
  UNIQUE INDEX `uk_employee_id_card`(`id_card` ASC) USING BTREE,
  INDEX `idx_employee_dept_id`(`dept_id` ASC) USING BTREE,
  INDEX `idx_employee_position_id`(`position_id` ASC) USING BTREE,
  INDEX `idx_employee_hire_date`(`hire_date` ASC) USING BTREE,
  INDEX `idx_employee_identity_tag_code`(`identity_tag_code` ASC) USING BTREE,
  CONSTRAINT `fk_employee_dept` FOREIGN KEY (`dept_id`) REFERENCES `department` (`dept_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_employee_identity_tag` FOREIGN KEY (`identity_tag_code`) REFERENCES `identity_tag` (`tag_code`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_employee_position` FOREIGN KEY (`position_id`) REFERENCES `job_position` (`position_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of employee
-- ----------------------------
INSERT INTO `employee` VALUES (1, '张伟', '男', '13800000001', 'zhangwei@company.com', '110101199001010011', '1990-01-01', '北京市海淀区', '2020-01-15', NULL, 1, 1, 'GENERAL_MANAGER', '在职', '2024-01-01 09:00:00', '2026-03-14 00:03:42');
INSERT INTO `employee` VALUES (2, '李娜', '女', '13800000002', 'lina@company.com', '110101199203120022', '1992-03-12', '北京市朝阳区', '2020-03-01', NULL, 2, 3, 'HR_SPECIALIST', '在职', '2024-01-01 09:00:00', '2026-03-14 00:03:42');
INSERT INTO `employee` VALUES (3, '王芳', '女', '13800000003', 'wangfang@company.com', '110101199508080033', '1995-08-08', '北京市丰台区', '2021-06-15', NULL, 2, 3, 'HR_SPECIALIST', '在职', '2024-01-01 09:00:00', '2026-03-14 00:03:42');
INSERT INTO `employee` VALUES (4, '刘强', '男', '13800000004', 'liuqiang@company.com', '110101198909210044', '1989-09-21', '北京市西城区', '2020-05-20', NULL, 3, 4, 'FINANCE_MANAGER', '在职', '2024-01-01 09:00:00', '2026-03-14 00:03:42');
INSERT INTO `employee` VALUES (5, '陈静', '女', '13800000005', 'chenjing@company.com', '110101199704150055', '1997-04-15', '北京市通州区', '2022-01-10', NULL, 3, 5, 'FINANCE_SPECIALIST', '在职', '2024-01-01 09:00:00', '2026-03-14 00:03:42');
INSERT INTO `employee` VALUES (6, '赵明', '男', '13800000006', 'zhaoming@company.com', '110101198811180066', '1988-11-18', '北京市昌平区', '2019-08-01', NULL, 4, 6, 'MANAGER', '在职', '2024-01-01 09:00:00', '2026-03-14 00:03:42');
INSERT INTO `employee` VALUES (7, '孙磊', '男', '13800000007', 'sunlei@company.com', '110101199402140077', '1994-02-14', '北京市顺义区', '2021-03-15', NULL, 4, 7, 'EMPLOYEE', '在职', '2024-01-01 09:00:00', '2026-03-14 00:03:42');
INSERT INTO `employee` VALUES (8, '周洋', '男', '13800000008', 'zhouyang@company.com', '110101199909090088', '1999-09-09', '北京市大兴区', '2022-07-01', NULL, 4, 8, 'EMPLOYEE', '试用', '2024-01-01 09:00:00', '2026-03-14 00:03:42');
INSERT INTO `employee` VALUES (9, '吴敏', '女', '13800000009', 'wumin@company.com', '110101199105260099', '1991-05-26', '北京市石景山区', '2020-11-01', NULL, 5, 9, 'MANAGER', '在职', '2024-01-01 09:00:00', '2026-03-14 00:03:42');
INSERT INTO `employee` VALUES (10, '郑涛', '男', '13800000010', 'zhengtao@company.com', '110101199612300010', '1996-12-30', '北京市房山区', '2023-02-15', NULL, 5, 10, 'EMPLOYEE', '在职', '2024-01-01 09:00:00', '2026-03-14 00:03:42');
INSERT INTO `employee` VALUES (11, '黄丽', '女', '13800000011', 'huangli@company.com', '110101199303030011', '1993-03-03', '北京市门头沟区', '2021-09-01', NULL, 6, 11, 'MANAGER', '在职', '2024-01-01 09:00:00', '2026-03-14 00:03:42');
INSERT INTO `employee` VALUES (12, '林峰', '男', '13800000012', 'linfeng@company.com', '110101199807170012', '1998-07-17', '北京市延庆区', '2023-05-01', NULL, 6, 12, 'EMPLOYEE', '在职', '2024-01-01 09:00:00', '2026-03-14 00:03:42');
INSERT INTO `employee` VALUES (13, '何军', '男', '13800000013', 'hejun@company.com', '110101199211110013', '1992-11-11', '北京市密云区', '2021-11-01', NULL, 7, 13, 'MANAGER', '在职', '2024-01-01 09:00:00', '2026-03-14 00:03:42');
INSERT INTO `employee` VALUES (14, '许洁', '女', '13800000014', 'xujie@company.com', '110101199606060014', '1996-06-06', '北京市怀柔区', '2022-10-18', NULL, 7, 14, 'EMPLOYEE', '在职', '2024-01-01 09:00:00', '2026-03-14 00:03:42');
INSERT INTO `employee` VALUES (15, '郭婷', '女', '13800000015', 'guoting@company.com', '110101199410100015', '1994-10-10', '北京市东城区', '2019-12-20', NULL, 2, 2, 'HR_MANAGER', '在职', '2024-01-01 09:00:00', '2026-03-14 00:03:42');
INSERT INTO `employee` VALUES (16, '云月', '男', '13800000000', 'yunyue@company.com', NULL, NULL, NULL, '2020-01-01', NULL, 1, 15, 'ADMIN', '在职', '2026-03-14 00:20:43', '2026-03-14 00:25:46');

-- ----------------------------
-- Table structure for identity_tag
-- ----------------------------
DROP TABLE IF EXISTS `identity_tag`;
CREATE TABLE `identity_tag`  (
  `tag_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `tag_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `tag_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`tag_code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of identity_tag
-- ----------------------------
INSERT INTO `identity_tag` VALUES ('ADMIN', '管理员', '系统管理员身份标签', '2024-01-01 09:00:00');
INSERT INTO `identity_tag` VALUES ('EMPLOYEE', '普通员工', '普通员工身份标签', '2024-01-01 09:00:00');
INSERT INTO `identity_tag` VALUES ('FINANCE_MANAGER', '财务经理', '财务经理身份标签', '2024-01-01 09:00:00');
INSERT INTO `identity_tag` VALUES ('FINANCE_SPECIALIST', '财务专员', '财务专员身份标签', '2024-01-01 09:00:00');
INSERT INTO `identity_tag` VALUES ('HR_MANAGER', 'HR经理', '人力资源经理身份标签', '2024-01-01 09:00:00');
INSERT INTO `identity_tag` VALUES ('HR_SPECIALIST', 'HR专员', '人力资源专员身份标签', '2024-01-01 09:00:00');
INSERT INTO `identity_tag` VALUES ('MANAGER', '部门经理', '普通业务部门经理身份标签', '2024-01-01 09:00:00');

-- ----------------------------
-- Table structure for job_position
-- ----------------------------
DROP TABLE IF EXISTS `job_position`;
CREATE TABLE `job_position`  (
  `position_id` int NOT NULL AUTO_INCREMENT,
  `position_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `position_desc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `dept_id` int NOT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`position_id`) USING BTREE,
  INDEX `idx_job_position_dept_id`(`dept_id` ASC) USING BTREE,
  CONSTRAINT `fk_job_position_dept` FOREIGN KEY (`dept_id`) REFERENCES `department` (`dept_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of job_position
-- ----------------------------
INSERT INTO `job_position` VALUES (1, '总经理', '公司总负责人', 1, '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `job_position` VALUES (2, 'HR经理', '人力资源部负责人', 2, '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `job_position` VALUES (3, 'HR专员', '人力资源专员', 2, '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `job_position` VALUES (4, '财务经理', '财务部负责人', 3, '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `job_position` VALUES (5, '财务专员', '财务日常处理', 3, '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `job_position` VALUES (6, '技术总监', '技术部负责人', 4, '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `job_position` VALUES (7, '高级工程师', '技术骨干岗位', 4, '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `job_position` VALUES (8, '软件工程师', '技术研发岗位', 4, '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `job_position` VALUES (9, '市场经理', '市场部负责人', 5, '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `job_position` VALUES (10, '市场专员', '市场运营岗位', 5, '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `job_position` VALUES (11, '行政经理', '行政部负责人', 6, '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `job_position` VALUES (12, '行政专员', '行政事务岗位', 6, '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `job_position` VALUES (13, '综合部经理', '综合部负责人', 7, '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `job_position` VALUES (14, '后勤专员', '后勤与宿舍管理', 7, '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `job_position` VALUES (15, '管理员', '负责公司系统管理', 1, '2026-03-14 00:19:47', '2026-03-14 00:19:47');

-- ----------------------------
-- Table structure for leave_request
-- ----------------------------
DROP TABLE IF EXISTS `leave_request`;
CREATE TABLE `leave_request`  (
  `leave_id` int NOT NULL AUTO_INCREMENT,
  `emp_id` int NOT NULL,
  `leave_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `days` decimal(6, 2) NOT NULL,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `approver_id` int NULL DEFAULT NULL,
  `pending_approver_tag` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `pending_approver_scope` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `next_approver_tag` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `next_approver_scope` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `apply_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `approve_time` datetime NULL DEFAULT NULL,
  `approve_remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`leave_id`) USING BTREE,
  INDEX `idx_leave_request_emp_id`(`emp_id` ASC) USING BTREE,
  INDEX `idx_leave_request_apply_time`(`apply_time` ASC) USING BTREE,
  INDEX `idx_leave_request_status`(`status` ASC) USING BTREE,
  INDEX `idx_leave_request_approver_id`(`approver_id` ASC) USING BTREE,
  CONSTRAINT `fk_leave_request_approver` FOREIGN KEY (`approver_id`) REFERENCES `sys_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_leave_request_emp` FOREIGN KEY (`emp_id`) REFERENCES `employee` (`emp_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of leave_request
-- ----------------------------
INSERT INTO `leave_request` VALUES (1, 5, '年假', '2024-01-15', '2024-01-17', 3.00, '回老家探亲', '已通过', 2, NULL, NULL, NULL, NULL, '2024-01-10 09:30:00', '2024-01-11 14:00:00', '资料齐全，同意请假');
INSERT INTO `leave_request` VALUES (2, 3, '病假', '2024-01-20', '2024-01-21', 2.00, '感冒发烧需要休息', '待审批', NULL, 'HR_MANAGER', 'company', NULL, NULL, '2024-01-18 14:20:00', NULL, NULL);
INSERT INTO `leave_request` VALUES (3, 8, '事假', '2024-01-22', '2024-01-22', 1.00, '处理个人事务', '已通过', 3, NULL, NULL, NULL, NULL, '2024-01-19 10:00:00', '2024-01-19 16:10:00', '先由HR继续处理');
INSERT INTO `leave_request` VALUES (4, 10, '婚假', '2024-02-01', '2024-02-10', 10.00, '办理婚礼', '待审批', NULL, 'HR_SPECIALIST', 'company', 'HR_MANAGER', 'company', '2024-01-20 16:00:00', NULL, NULL);
INSERT INTO `leave_request` VALUES (5, 7, '年假', '2024-01-25', '2024-01-26', 2.00, '个人休假', '已拒绝', 3, NULL, NULL, NULL, NULL, '2024-01-15 11:30:00', '2024-01-16 09:30:00', '项目关键期暂不批准');
INSERT INTO `leave_request` VALUES (6, 1, '年假', '2024-03-01', '2024-03-03', 3.00, '总经理请假测试', '待审批', NULL, 'HR_MANAGER', 'company', NULL, NULL, '2024-02-28 10:00:00', NULL, NULL);
INSERT INTO `leave_request` VALUES (7, 15, '事假', '2024-03-05', '2024-03-05', 1.00, 'HR经理请假测试', '待审批', NULL, 'GENERAL_MANAGER', 'company', NULL, NULL, '2024-03-04 14:00:00', NULL, NULL);
INSERT INTO `leave_request` VALUES (8, 9, '事假', '2026-04-10', '2026-04-11', 2.00, '答辩', '已取消', NULL, NULL, NULL, NULL, NULL, '2026-04-10 19:16:53', NULL, NULL);
INSERT INTO `leave_request` VALUES (9, 5, '事假', '2026-04-10', '2026-04-11', 2.00, '答辩', '已通过', 2, NULL, NULL, NULL, NULL, '2026-04-10 19:18:22', '2026-04-10 19:18:53', NULL);

-- ----------------------------
-- Table structure for module_scope_detail
-- ----------------------------
DROP TABLE IF EXISTS `module_scope_detail`;
CREATE TABLE `module_scope_detail`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `module_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `tag_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `scope` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_module_scope_detail`(`module_code` ASC, `tag_code` ASC) USING BTREE,
  INDEX `idx_module_scope_detail_tag_code`(`tag_code` ASC) USING BTREE,
  CONSTRAINT `fk_module_scope_detail_rule` FOREIGN KEY (`module_code`) REFERENCES `module_scope_rule` (`module_code`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_module_scope_detail_tag` FOREIGN KEY (`tag_code`) REFERENCES `identity_tag` (`tag_code`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 45 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of module_scope_detail
-- ----------------------------
INSERT INTO `module_scope_detail` VALUES (1, 'base:employee', 'ADMIN', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (2, 'base:employee', 'HR_SPECIALIST', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (3, 'base:employee', 'HR_MANAGER', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (4, 'base:employee', 'FINANCE_SPECIALIST', 'dept', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (5, 'base:employee', 'FINANCE_MANAGER', 'dept', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (6, 'base:employee', 'MANAGER', 'dept', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (7, 'base:employee', 'EMPLOYEE', 'self', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (8, 'base:department', 'ADMIN', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (9, 'base:department', 'HR_SPECIALIST', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (10, 'base:department', 'HR_MANAGER', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (11, 'base:department', 'FINANCE_SPECIALIST', 'dept', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (12, 'base:department', 'FINANCE_MANAGER', 'dept', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (13, 'base:department', 'MANAGER', 'dept', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (14, 'base:department', 'EMPLOYEE', 'dept', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (15, 'base:position', 'ADMIN', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (16, 'base:position', 'HR_SPECIALIST', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (17, 'base:position', 'HR_MANAGER', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (18, 'base:position', 'FINANCE_SPECIALIST', 'dept', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (19, 'base:position', 'FINANCE_MANAGER', 'dept', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (20, 'base:position', 'MANAGER', 'dept', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (21, 'base:position', 'EMPLOYEE', 'dept', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (22, 'attendance:record', 'ADMIN', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (23, 'attendance:record', 'HR_SPECIALIST', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (24, 'attendance:record', 'HR_MANAGER', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (25, 'attendance:record', 'MANAGER', 'dept', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (26, 'attendance:record', 'EMPLOYEE', 'self', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (27, 'attendance:leave', 'ADMIN', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (28, 'attendance:leave', 'HR_SPECIALIST', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (29, 'attendance:leave', 'HR_MANAGER', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (30, 'attendance:leave', 'MANAGER', 'dept', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (31, 'attendance:leave', 'EMPLOYEE', 'self', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (32, 'salary:record', 'ADMIN', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (33, 'salary:record', 'FINANCE_SPECIALIST', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (34, 'salary:record', 'FINANCE_MANAGER', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (35, 'salary:config', 'ADMIN', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (36, 'salary:config', 'FINANCE_SPECIALIST', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (37, 'salary:config', 'FINANCE_MANAGER', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (38, 'report', 'ADMIN', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (39, 'report', 'HR_SPECIALIST', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (40, 'report', 'HR_MANAGER', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (41, 'report', 'FINANCE_SPECIALIST', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (42, 'report', 'FINANCE_MANAGER', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (43, 'report', 'MANAGER', 'dept', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_detail` VALUES (44, 'report', 'EMPLOYEE', 'self', '2024-01-01 09:00:00', '2024-01-01 09:00:00');

-- ----------------------------
-- Table structure for module_scope_rule
-- ----------------------------
DROP TABLE IF EXISTS `module_scope_rule`;
CREATE TABLE `module_scope_rule`  (
  `module_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `module_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `default_scope` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'dept',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`module_code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of module_scope_rule
-- ----------------------------
INSERT INTO `module_scope_rule` VALUES ('attendance:leave', '请假管理', 'dept', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_rule` VALUES ('attendance:record', '考勤记录', 'dept', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_rule` VALUES ('base:department', '部门管理', 'dept', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_rule` VALUES ('base:employee', '员工管理', 'dept', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_rule` VALUES ('base:position', '职位管理', 'dept', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_rule` VALUES ('report', '报表中心', 'dept', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_rule` VALUES ('salary:config', '薪资配置', 'company', '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `module_scope_rule` VALUES ('salary:record', '薪资记录', 'dept', '2024-01-01 09:00:00', '2024-01-01 09:00:00');

-- ----------------------------
-- Table structure for operation_log
-- ----------------------------
DROP TABLE IF EXISTS `operation_log`;
CREATE TABLE `operation_log`  (
  `log_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NULL DEFAULT NULL,
  `operation_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `operation_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `operation_module` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `operation_desc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `idx_operation_log_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_operation_log_time`(`operation_time` ASC) USING BTREE,
  CONSTRAINT `fk_operation_log_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of operation_log
-- ----------------------------
INSERT INTO `operation_log` VALUES (1, 1, '2024-01-01 09:30:00', '登录', '认证中心', '系统管理员首次登录系统');
INSERT INTO `operation_log` VALUES (2, 2, '2024-01-10 09:35:00', '审批', '请假管理', 'HR专员审批了陈静的请假申请');
INSERT INTO `operation_log` VALUES (3, 5, '2024-01-25 10:00:00', '审批', '薪资管理', '财务经理审批了2024年1月薪资记录');

-- ----------------------------
-- Table structure for permission
-- ----------------------------
DROP TABLE IF EXISTS `permission`;
CREATE TABLE `permission`  (
  `perm_id` int NOT NULL AUTO_INCREMENT,
  `perm_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `perm_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `perm_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'BUTTON',
  `parent_id` int NULL DEFAULT NULL,
  `path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `icon` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `sort_order` int NOT NULL DEFAULT 0,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`perm_id`) USING BTREE,
  UNIQUE INDEX `uk_permission_code`(`perm_code` ASC) USING BTREE,
  INDEX `idx_permission_parent_id`(`parent_id` ASC) USING BTREE,
  CONSTRAINT `fk_permission_parent` FOREIGN KEY (`parent_id`) REFERENCES `permission` (`perm_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 65 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of permission
-- ----------------------------
INSERT INTO `permission` VALUES (1, '仪表盘', 'dashboard', 'MENU', NULL, '/dashboard', 'DataLine', 1, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (2, '仪表盘查看', 'dashboard:view', 'BUTTON', 1, NULL, NULL, 1, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (3, '基础信息', 'base', 'MENU', NULL, '/base', 'Menu', 2, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (4, '员工管理', 'base:employee', 'MENU', 3, '/base/employee', 'User', 1, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (5, '部门管理', 'base:department', 'MENU', 3, '/base/department', 'OfficeBuilding', 2, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (6, '职位管理', 'base:position', 'MENU', 3, '/base/position', 'Suitcase', 3, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (7, '员工查看', 'base:employee:view', 'BUTTON', 4, NULL, NULL, 1, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (8, '部门查看', 'base:department:view', 'BUTTON', 5, NULL, NULL, 1, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (9, '职位查看', 'base:position:view', 'BUTTON', 6, NULL, NULL, 1, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (10, '员工新增', 'base:employee:add', 'BUTTON', 4, NULL, NULL, 2, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (11, '员工编辑', 'base:employee:edit', 'BUTTON', 4, NULL, NULL, 3, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (12, '员工删除', 'base:employee:delete', 'BUTTON', 4, NULL, NULL, 4, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (13, '部门新增', 'base:department:add', 'BUTTON', 5, NULL, NULL, 2, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (14, '部门编辑', 'base:department:edit', 'BUTTON', 5, NULL, NULL, 3, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (15, '部门删除', 'base:department:delete', 'BUTTON', 5, NULL, NULL, 4, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (16, '职位新增', 'base:position:add', 'BUTTON', 6, NULL, NULL, 2, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (17, '职位编辑', 'base:position:edit', 'BUTTON', 6, NULL, NULL, 3, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (18, '职位删除', 'base:position:delete', 'BUTTON', 6, NULL, NULL, 4, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (19, '考勤管理', 'attendance', 'MENU', NULL, '/attendance', 'Calendar', 3, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (20, '考勤记录', 'attendance:record', 'MENU', 19, '/attendance/record', 'Calendar', 1, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (21, '请假管理', 'attendance:leave', 'MENU', 19, '/attendance/leave', 'Document', 2, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (22, '考勤查看', 'attendance:record:view', 'BUTTON', 20, NULL, NULL, 1, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (23, '请假查看', 'attendance:leave:view', 'BUTTON', 21, NULL, NULL, 1, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (24, '考勤新增', 'attendance:record:add', 'BUTTON', 20, NULL, NULL, 2, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (25, '考勤编辑', 'attendance:record:edit', 'BUTTON', 20, NULL, NULL, 3, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (26, '请假申请', 'attendance:leave:add', 'BUTTON', 21, NULL, NULL, 2, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (27, '请假审批', 'attendance:leave:approve', 'BUTTON', 21, NULL, NULL, 3, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (28, '请假撤销', 'attendance:leave:cancel', 'BUTTON', 21, NULL, NULL, 4, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (29, '薪资管理', 'salary', 'MENU', NULL, '/salary', 'Money', 4, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (30, '薪资记录', 'salary:record', 'MENU', 29, '/salary/record', 'List', 1, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (31, '薪资配置', 'salary:config', 'MENU', 29, '/salary/config', 'Tools', 2, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (32, '薪资记录查看', 'salary:record:view', 'BUTTON', 30, NULL, NULL, 1, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (33, '薪资配置查看', 'salary:config:view', 'BUTTON', 31, NULL, NULL, 1, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (34, '薪资记录新增', 'salary:record:add', 'BUTTON', 30, NULL, NULL, 2, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (35, '薪资记录编辑', 'salary:record:edit', 'BUTTON', 30, NULL, NULL, 3, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (36, '薪资记录提交', 'salary:record:submit', 'BUTTON', 30, NULL, NULL, 4, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (37, '薪资记录审批', 'salary:record:approve', 'BUTTON', 30, NULL, NULL, 5, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (38, '薪资记录发放', 'salary:record:pay', 'BUTTON', 30, NULL, NULL, 6, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (39, '薪资配置新增', 'salary:config:add', 'BUTTON', 31, NULL, NULL, 2, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (40, '薪资配置编辑', 'salary:config:edit', 'BUTTON', 31, NULL, NULL, 3, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (41, '薪资配置提交', 'salary:config:submit', 'BUTTON', 31, NULL, NULL, 4, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (42, '薪资配置审批', 'salary:config:approve', 'BUTTON', 31, NULL, NULL, 5, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (43, '权限管理', 'permission', 'MENU', NULL, '/permission', 'Lock', 5, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (44, '用户管理', 'permission:user', 'MENU', 43, '/permission/user', 'UserFilled', 1, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (45, '角色管理', 'permission:role', 'MENU', 43, '/permission/role', 'Avatar', 2, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (46, '用户查看', 'permission:user:view', 'BUTTON', 44, NULL, NULL, 1, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (47, '角色查看', 'permission:role:view', 'BUTTON', 45, NULL, NULL, 1, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (48, '部门模板查看', 'permission:dept-template:view', 'BUTTON', 43, NULL, NULL, 3, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (49, '身份标签查看', 'permission:identity:view', 'BUTTON', 43, NULL, NULL, 4, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (50, '模块范围查看', 'permission:module-scope:view', 'BUTTON', 43, NULL, NULL, 5, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (51, '审批规则查看', 'permission:approval-rule:view', 'BUTTON', 43, NULL, NULL, 6, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (52, '用户新增', 'permission:user:add', 'BUTTON', 44, NULL, NULL, 2, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (53, '用户编辑', 'permission:user:edit', 'BUTTON', 44, NULL, NULL, 3, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (54, '用户删除', 'permission:user:delete', 'BUTTON', 44, NULL, NULL, 4, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (55, '角色新增', 'permission:role:add', 'BUTTON', 45, NULL, NULL, 2, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (56, '角色编辑', 'permission:role:edit', 'BUTTON', 45, NULL, NULL, 3, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (57, '角色删除', 'permission:role:delete', 'BUTTON', 45, NULL, NULL, 4, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (58, '角色授权', 'permission:role:perm', 'BUTTON', 45, NULL, NULL, 5, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (59, '报表中心', 'report', 'MENU', NULL, '/report', 'PieChart', 6, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (60, '报表查看', 'report:view', 'BUTTON', 59, NULL, NULL, 1, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (61, '亚托莉', 'dashboard:ai', 'MENU', 1, '/ai-assistant', 'ChatDotRound', 2, '2024-01-01 09:00:00');
INSERT INTO `permission` VALUES (62, '亚托莉查看', 'dashboard:ai:view', 'BUTTON', 61, NULL, NULL, 1, '2024-01-01 09:00:00');

-- ----------------------------
-- Table structure for role
-- ----------------------------
DROP TABLE IF EXISTS `role`;
CREATE TABLE `role`  (
  `role_id` int NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `role_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `role_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`role_id`) USING BTREE,
  UNIQUE INDEX `uk_role_code`(`role_code` ASC) USING BTREE,
  UNIQUE INDEX `uk_role_name`(`role_name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of role
-- ----------------------------
INSERT INTO `role` VALUES (1, '系统管理员', 'ADMIN', '拥有系统全部权限', '2024-01-01 09:00:00');
INSERT INTO `role` VALUES (2, 'HR专员', 'HR', '负责人事基础信息与请假处理', '2024-01-01 09:00:00');
INSERT INTO `role` VALUES (3, '部门经理', 'MANAGER', '管理本部门员工与审批', '2024-01-01 09:00:00');
INSERT INTO `role` VALUES (4, '普通员工', 'EMPLOYEE', '普通员工自助权限', '2024-01-01 09:00:00');
INSERT INTO `role` VALUES (5, '财务经理', 'FINANCE_MANAGER', '负责薪资审批与发放', '2024-01-01 09:00:00');
INSERT INTO `role` VALUES (6, '财务专员', 'FINANCE', '负责薪资制单与配置提交', '2024-01-01 09:00:00');
INSERT INTO `role` VALUES (7, 'HR经理', 'HR_MANAGER', '负责人事审批与管理', '2024-01-01 09:00:00');
INSERT INTO `role` VALUES (8, '总经理', 'GENERAL_MANAGER', '公司负责人', '2026-03-14 00:14:01');

-- ----------------------------
-- Table structure for role_permission
-- ----------------------------
DROP TABLE IF EXISTS `role_permission`;
CREATE TABLE `role_permission`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `role_id` int NOT NULL,
  `perm_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_role_permission`(`role_id` ASC, `perm_id` ASC) USING BTREE,
  INDEX `idx_role_permission_perm_id`(`perm_id` ASC) USING BTREE,
  CONSTRAINT `fk_role_permission_perm` FOREIGN KEY (`perm_id`) REFERENCES `permission` (`perm_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_role_permission_role` FOREIGN KEY (`role_id`) REFERENCES `role` (`role_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 281 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of role_permission
-- ----------------------------
INSERT INTO `role_permission` VALUES (1, 1, 1);
INSERT INTO `role_permission` VALUES (7, 1, 2);
INSERT INTO `role_permission` VALUES (2, 1, 3);
INSERT INTO `role_permission` VALUES (9, 1, 4);
INSERT INTO `role_permission` VALUES (10, 1, 5);
INSERT INTO `role_permission` VALUES (11, 1, 6);
INSERT INTO `role_permission` VALUES (12, 1, 7);
INSERT INTO `role_permission` VALUES (16, 1, 8);
INSERT INTO `role_permission` VALUES (20, 1, 9);
INSERT INTO `role_permission` VALUES (13, 1, 10);
INSERT INTO `role_permission` VALUES (14, 1, 11);
INSERT INTO `role_permission` VALUES (15, 1, 12);
INSERT INTO `role_permission` VALUES (17, 1, 13);
INSERT INTO `role_permission` VALUES (18, 1, 14);
INSERT INTO `role_permission` VALUES (19, 1, 15);
INSERT INTO `role_permission` VALUES (21, 1, 16);
INSERT INTO `role_permission` VALUES (22, 1, 17);
INSERT INTO `role_permission` VALUES (23, 1, 18);
INSERT INTO `role_permission` VALUES (3, 1, 19);
INSERT INTO `role_permission` VALUES (24, 1, 20);
INSERT INTO `role_permission` VALUES (25, 1, 21);
INSERT INTO `role_permission` VALUES (26, 1, 22);
INSERT INTO `role_permission` VALUES (29, 1, 23);
INSERT INTO `role_permission` VALUES (27, 1, 24);
INSERT INTO `role_permission` VALUES (28, 1, 25);
INSERT INTO `role_permission` VALUES (30, 1, 26);
INSERT INTO `role_permission` VALUES (31, 1, 27);
INSERT INTO `role_permission` VALUES (32, 1, 28);
INSERT INTO `role_permission` VALUES (4, 1, 29);
INSERT INTO `role_permission` VALUES (33, 1, 30);
INSERT INTO `role_permission` VALUES (34, 1, 31);
INSERT INTO `role_permission` VALUES (35, 1, 32);
INSERT INTO `role_permission` VALUES (41, 1, 33);
INSERT INTO `role_permission` VALUES (36, 1, 34);
INSERT INTO `role_permission` VALUES (37, 1, 35);
INSERT INTO `role_permission` VALUES (38, 1, 36);
INSERT INTO `role_permission` VALUES (39, 1, 37);
INSERT INTO `role_permission` VALUES (40, 1, 38);
INSERT INTO `role_permission` VALUES (42, 1, 39);
INSERT INTO `role_permission` VALUES (43, 1, 40);
INSERT INTO `role_permission` VALUES (44, 1, 41);
INSERT INTO `role_permission` VALUES (45, 1, 42);
INSERT INTO `role_permission` VALUES (5, 1, 43);
INSERT INTO `role_permission` VALUES (46, 1, 44);
INSERT INTO `role_permission` VALUES (47, 1, 45);
INSERT INTO `role_permission` VALUES (52, 1, 46);
INSERT INTO `role_permission` VALUES (56, 1, 47);
INSERT INTO `role_permission` VALUES (48, 1, 48);
INSERT INTO `role_permission` VALUES (49, 1, 49);
INSERT INTO `role_permission` VALUES (50, 1, 50);
INSERT INTO `role_permission` VALUES (51, 1, 51);
INSERT INTO `role_permission` VALUES (53, 1, 52);
INSERT INTO `role_permission` VALUES (54, 1, 53);
INSERT INTO `role_permission` VALUES (55, 1, 54);
INSERT INTO `role_permission` VALUES (57, 1, 55);
INSERT INTO `role_permission` VALUES (58, 1, 56);
INSERT INTO `role_permission` VALUES (59, 1, 57);
INSERT INTO `role_permission` VALUES (60, 1, 58);
INSERT INTO `role_permission` VALUES (6, 1, 59);
INSERT INTO `role_permission` VALUES (61, 1, 60);
INSERT INTO `role_permission` VALUES (8, 1, 61);
INSERT INTO `role_permission` VALUES (62, 1, 62);
INSERT INTO `role_permission` VALUES (90, 2, 1);
INSERT INTO `role_permission` VALUES (91, 2, 2);
INSERT INTO `role_permission` VALUES (74, 2, 3);
INSERT INTO `role_permission` VALUES (80, 2, 4);
INSERT INTO `role_permission` VALUES (75, 2, 5);
INSERT INTO `role_permission` VALUES (85, 2, 6);
INSERT INTO `role_permission` VALUES (84, 2, 7);
INSERT INTO `role_permission` VALUES (79, 2, 8);
INSERT INTO `role_permission` VALUES (89, 2, 9);
INSERT INTO `role_permission` VALUES (81, 2, 10);
INSERT INTO `role_permission` VALUES (83, 2, 11);
INSERT INTO `role_permission` VALUES (82, 2, 12);
INSERT INTO `role_permission` VALUES (76, 2, 13);
INSERT INTO `role_permission` VALUES (78, 2, 14);
INSERT INTO `role_permission` VALUES (77, 2, 15);
INSERT INTO `role_permission` VALUES (86, 2, 16);
INSERT INTO `role_permission` VALUES (88, 2, 17);
INSERT INTO `role_permission` VALUES (87, 2, 18);
INSERT INTO `role_permission` VALUES (64, 2, 19);
INSERT INTO `role_permission` VALUES (70, 2, 20);
INSERT INTO `role_permission` VALUES (65, 2, 21);
INSERT INTO `role_permission` VALUES (73, 2, 22);
INSERT INTO `role_permission` VALUES (69, 2, 23);
INSERT INTO `role_permission` VALUES (71, 2, 24);
INSERT INTO `role_permission` VALUES (72, 2, 25);
INSERT INTO `role_permission` VALUES (66, 2, 26);
INSERT INTO `role_permission` VALUES (67, 2, 27);
INSERT INTO `role_permission` VALUES (68, 2, 28);
INSERT INTO `role_permission` VALUES (94, 2, 29);
INSERT INTO `role_permission` VALUES (95, 2, 30);
INSERT INTO `role_permission` VALUES (96, 2, 32);
INSERT INTO `role_permission` VALUES (92, 2, 59);
INSERT INTO `role_permission` VALUES (93, 2, 60);
INSERT INTO `role_permission` VALUES (273, 2, 61);
INSERT INTO `role_permission` VALUES (272, 2, 62);
INSERT INTO `role_permission` VALUES (201, 3, 1);
INSERT INTO `role_permission` VALUES (202, 3, 2);
INSERT INTO `role_permission` VALUES (197, 3, 3);
INSERT INTO `role_permission` VALUES (198, 3, 4);
INSERT INTO `role_permission` VALUES (200, 3, 7);
INSERT INTO `role_permission` VALUES (199, 3, 11);
INSERT INTO `role_permission` VALUES (190, 3, 19);
INSERT INTO `role_permission` VALUES (195, 3, 20);
INSERT INTO `role_permission` VALUES (191, 3, 21);
INSERT INTO `role_permission` VALUES (196, 3, 22);
INSERT INTO `role_permission` VALUES (194, 3, 23);
INSERT INTO `role_permission` VALUES (192, 3, 27);
INSERT INTO `role_permission` VALUES (193, 3, 28);
INSERT INTO `role_permission` VALUES (205, 3, 29);
INSERT INTO `role_permission` VALUES (206, 3, 30);
INSERT INTO `role_permission` VALUES (207, 3, 32);
INSERT INTO `role_permission` VALUES (203, 3, 59);
INSERT INTO `role_permission` VALUES (204, 3, 60);
INSERT INTO `role_permission` VALUES (277, 3, 61);
INSERT INTO `role_permission` VALUES (276, 3, 62);
INSERT INTO `role_permission` VALUES (228, 4, 1);
INSERT INTO `role_permission` VALUES (229, 4, 2);
INSERT INTO `role_permission` VALUES (221, 4, 19);
INSERT INTO `role_permission` VALUES (226, 4, 20);
INSERT INTO `role_permission` VALUES (222, 4, 21);
INSERT INTO `role_permission` VALUES (227, 4, 22);
INSERT INTO `role_permission` VALUES (225, 4, 23);
INSERT INTO `role_permission` VALUES (223, 4, 26);
INSERT INTO `role_permission` VALUES (224, 4, 28);
INSERT INTO `role_permission` VALUES (230, 4, 29);
INSERT INTO `role_permission` VALUES (231, 4, 30);
INSERT INTO `role_permission` VALUES (232, 4, 32);
INSERT INTO `role_permission` VALUES (267, 4, 61);
INSERT INTO `role_permission` VALUES (266, 4, 62);
INSERT INTO `role_permission` VALUES (236, 5, 1);
INSERT INTO `role_permission` VALUES (237, 5, 2);
INSERT INTO `role_permission` VALUES (238, 5, 29);
INSERT INTO `role_permission` VALUES (242, 5, 30);
INSERT INTO `role_permission` VALUES (239, 5, 31);
INSERT INTO `role_permission` VALUES (245, 5, 32);
INSERT INTO `role_permission` VALUES (241, 5, 33);
INSERT INTO `role_permission` VALUES (243, 5, 37);
INSERT INTO `role_permission` VALUES (244, 5, 38);
INSERT INTO `role_permission` VALUES (240, 5, 42);
INSERT INTO `role_permission` VALUES (271, 5, 61);
INSERT INTO `role_permission` VALUES (270, 5, 62);
INSERT INTO `role_permission` VALUES (251, 6, 1);
INSERT INTO `role_permission` VALUES (252, 6, 2);
INSERT INTO `role_permission` VALUES (253, 6, 29);
INSERT INTO `role_permission` VALUES (259, 6, 30);
INSERT INTO `role_permission` VALUES (254, 6, 31);
INSERT INTO `role_permission` VALUES (263, 6, 32);
INSERT INTO `role_permission` VALUES (258, 6, 33);
INSERT INTO `role_permission` VALUES (260, 6, 34);
INSERT INTO `role_permission` VALUES (261, 6, 35);
INSERT INTO `role_permission` VALUES (262, 6, 36);
INSERT INTO `role_permission` VALUES (255, 6, 39);
INSERT INTO `role_permission` VALUES (256, 6, 40);
INSERT INTO `role_permission` VALUES (257, 6, 41);
INSERT INTO `role_permission` VALUES (269, 6, 61);
INSERT INTO `role_permission` VALUES (268, 6, 62);
INSERT INTO `role_permission` VALUES (153, 7, 1);
INSERT INTO `role_permission` VALUES (154, 7, 2);
INSERT INTO `role_permission` VALUES (137, 7, 3);
INSERT INTO `role_permission` VALUES (143, 7, 4);
INSERT INTO `role_permission` VALUES (138, 7, 5);
INSERT INTO `role_permission` VALUES (148, 7, 6);
INSERT INTO `role_permission` VALUES (147, 7, 7);
INSERT INTO `role_permission` VALUES (142, 7, 8);
INSERT INTO `role_permission` VALUES (152, 7, 9);
INSERT INTO `role_permission` VALUES (144, 7, 10);
INSERT INTO `role_permission` VALUES (146, 7, 11);
INSERT INTO `role_permission` VALUES (145, 7, 12);
INSERT INTO `role_permission` VALUES (139, 7, 13);
INSERT INTO `role_permission` VALUES (141, 7, 14);
INSERT INTO `role_permission` VALUES (140, 7, 15);
INSERT INTO `role_permission` VALUES (149, 7, 16);
INSERT INTO `role_permission` VALUES (151, 7, 17);
INSERT INTO `role_permission` VALUES (150, 7, 18);
INSERT INTO `role_permission` VALUES (127, 7, 19);
INSERT INTO `role_permission` VALUES (133, 7, 20);
INSERT INTO `role_permission` VALUES (128, 7, 21);
INSERT INTO `role_permission` VALUES (136, 7, 22);
INSERT INTO `role_permission` VALUES (132, 7, 23);
INSERT INTO `role_permission` VALUES (134, 7, 24);
INSERT INTO `role_permission` VALUES (135, 7, 25);
INSERT INTO `role_permission` VALUES (129, 7, 26);
INSERT INTO `role_permission` VALUES (130, 7, 27);
INSERT INTO `role_permission` VALUES (131, 7, 28);
INSERT INTO `role_permission` VALUES (157, 7, 29);
INSERT INTO `role_permission` VALUES (158, 7, 30);
INSERT INTO `role_permission` VALUES (159, 7, 32);
INSERT INTO `role_permission` VALUES (155, 7, 59);
INSERT INTO `role_permission` VALUES (156, 7, 60);
INSERT INTO `role_permission` VALUES (275, 7, 61);
INSERT INTO `role_permission` VALUES (274, 7, 62);

-- ----------------------------
-- Table structure for salary_config
-- ----------------------------
DROP TABLE IF EXISTS `salary_config`;
CREATE TABLE `salary_config`  (
  `config_id` int NOT NULL AUTO_INCREMENT,
  `config_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `config_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `config_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `effective_date` date NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '草稿',
  `submit_date` date NULL DEFAULT NULL,
  `approve_date` date NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`config_id`) USING BTREE,
  UNIQUE INDEX `uk_salary_config_key_effective`(`config_key` ASC, `effective_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of salary_config
-- ----------------------------
INSERT INTO `salary_config` VALUES (1, '社保比例', 'social_insurance_rate', '0.105', '员工个人社保扣缴比例', '2024-01-01', '已审批', '2023-12-25', '2023-12-28', '2023-12-25 09:00:00', '2023-12-28 10:00:00');
INSERT INTO `salary_config` VALUES (2, '公积金比例', 'housing_fund_rate', '0.08', '员工公积金扣缴比例', '2024-01-01', '已审批', '2023-12-25', '2023-12-28', '2023-12-25 09:00:00', '2023-12-28 10:00:00');
INSERT INTO `salary_config` VALUES (3, '个税起征点', 'tax_threshold', '5000', '工资薪金个税起征点', '2024-01-01', '已审批', '2023-12-25', '2023-12-28', '2023-12-25 09:00:00', '2023-12-28 10:00:00');
INSERT INTO `salary_config` VALUES (4, '迟到扣款', 'late_deduct', '50', '每次迟到扣款金额', '2024-01-01', '已审批', '2023-12-25', '2023-12-28', '2023-12-25 09:00:00', '2023-12-28 10:00:00');

-- ----------------------------
-- Table structure for salary_record
-- ----------------------------
DROP TABLE IF EXISTS `salary_record`;
CREATE TABLE `salary_record`  (
  `salary_id` int NOT NULL AUTO_INCREMENT,
  `emp_id` int NOT NULL,
  `salary_month` date NOT NULL,
  `base_salary` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `position_salary` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `bonus` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `overtime_pay` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `gross_salary` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `social_insurance` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `housing_fund` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `attendance_deduct` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `tax` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `other_deduct` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `net_salary` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '待发放',
  `pending_approver_role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '当前待审批角色',
  `next_approver_role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '下一级审批角色',
  `next_approver_scope` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '下一级审批范围(self/dept/company)',
  `submit_date` date NULL DEFAULT NULL,
  `approve_date` date NULL DEFAULT NULL,
  `pay_date` date NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`salary_id`) USING BTREE,
  UNIQUE INDEX `uk_salary_record_emp_month`(`emp_id` ASC, `salary_month` ASC) USING BTREE,
  INDEX `idx_salary_record_month`(`salary_month` ASC) USING BTREE,
  INDEX `idx_salary_record_status`(`status` ASC) USING BTREE,
  CONSTRAINT `fk_salary_record_emp` FOREIGN KEY (`emp_id`) REFERENCES `employee` (`emp_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of salary_record
-- ----------------------------
INSERT INTO `salary_record` VALUES (1, 1, '2024-01-01', 25000.00, 5000.00, 3000.00, 0.00, 33000.00, 2475.00, 2400.00, 0.00, 2590.00, 0.00, 25535.00, '已发放', NULL, NULL, NULL, '2024-01-20', '2024-01-25', '2024-01-31', '2024-01-20 09:00:00', '2024-01-31 12:00:00');
INSERT INTO `salary_record` VALUES (2, 2, '2024-01-01', 15000.00, 3000.00, 1500.00, 0.00, 19500.00, 1575.00, 1440.00, 50.00, 1045.00, 0.00, 15390.00, '已发放', NULL, NULL, NULL, '2024-01-20', '2024-01-25', '2024-01-31', '2024-01-20 09:00:00', '2024-01-31 12:00:00');
INSERT INTO `salary_record` VALUES (3, 3, '2024-01-01', 10000.00, 2000.00, 800.00, 0.00, 12800.00, 1050.00, 960.00, 50.00, 434.00, 0.00, 10306.00, '已发放', NULL, NULL, NULL, '2024-01-20', '2024-01-25', '2024-01-31', '2024-01-20 09:00:00', '2024-01-31 12:00:00');
INSERT INTO `salary_record` VALUES (4, 6, '2024-01-01', 20000.00, 5000.00, 2000.00, 1500.00, 28500.00, 2100.00, 1920.00, 0.00, 2095.00, 0.00, 22385.00, '已发放', NULL, NULL, NULL, '2024-01-20', '2024-01-25', '2024-01-31', '2024-01-20 09:00:00', '2024-01-31 12:00:00');
INSERT INTO `salary_record` VALUES (5, 8, '2024-01-01', 8000.00, 1500.00, 500.00, 0.00, 10000.00, 840.00, 720.00, 200.00, 144.00, 0.00, 8096.00, '待发放', 'FINANCE_MANAGER', NULL, NULL, '2024-01-20', NULL, NULL, '2024-01-20 09:00:00', '2024-01-20 09:00:00');

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `emp_id` int NOT NULL,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `role_id` int NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '启用',
  `last_login` datetime NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE INDEX `uk_sys_user_emp_id`(`emp_id` ASC) USING BTREE,
  UNIQUE INDEX `uk_sys_user_username`(`username` ASC) USING BTREE,
  INDEX `idx_sys_user_role_id`(`role_id` ASC) USING BTREE,
  CONSTRAINT `fk_sys_user_emp` FOREIGN KEY (`emp_id`) REFERENCES `employee` (`emp_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_sys_user_role` FOREIGN KEY (`role_id`) REFERENCES `role` (`role_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 1, 'gm', '123456', 8, '启用', NULL, '2024-01-01 09:00:00', '2026-03-14 00:21:56');
INSERT INTO `sys_user` VALUES (2, 2, 'hr_lina', '123456', 2, '启用', '2026-04-10 19:18:40', '2024-01-01 09:00:00', '2026-04-10 19:18:40');
INSERT INTO `sys_user` VALUES (3, 6, 'manager_zhao', '123456', 3, '启用', NULL, '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `sys_user` VALUES (4, 8, 'emp_zhou', '123456', 4, '启用', NULL, '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `sys_user` VALUES (5, 4, 'finance_liu', '123456', 5, '启用', NULL, '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `sys_user` VALUES (6, 5, 'finance_chen', '123456', 6, '启用', '2026-04-10 19:59:56', '2024-01-01 09:00:00', '2026-04-10 19:59:56');
INSERT INTO `sys_user` VALUES (7, 15, 'hr_manager', '123456', 7, '启用', NULL, '2024-01-01 09:00:00', '2024-01-01 09:00:00');
INSERT INTO `sys_user` VALUES (8, 9, 'emp_wu', '123456', 4, '启用', '2026-04-10 19:16:30', '2024-01-01 09:00:00', '2026-04-10 19:16:30');
INSERT INTO `sys_user` VALUES (9, 16, 'yunyue', 'yunyue', 1, '启用', '2026-05-18 15:00:08', '2026-03-14 00:22:55', '2026-05-18 15:00:08');

SET FOREIGN_KEY_CHECKS = 1;
