/*
Navicat MySQL Data Transfer

Source Server         : game
Source Server Version : 50628
Source Host           : gz-cdb-ebqjvubu.sql.tencentcdb.com:62608
Source Database       : stop_me

Target Server Type    : MYSQL
Target Server Version : 50628
File Encoding         : 65001

Date: 2018-11-30 11:05:38
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for gold_record
-- ----------------------------
DROP TABLE IF EXISTS `gold_record`;
CREATE TABLE `gold_record` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL COMMENT '用户id',
  `status` int(1) DEFAULT NULL COMMENT '使用状态（1-增加 2-减少）',
  `gold` int(10) DEFAULT NULL COMMENT '获取或减少的金币数',
  `channel` int(2) DEFAULT NULL COMMENT '使用或获取途径（1-开启关卡2-抽奖3-分享4-挑战5-看视频6-购买皮肤7-签到8-关卡中获取）',
  `use_time` int(11) DEFAULT NULL COMMENT '获取或使用时间',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=623774 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for invite_log
-- ----------------------------
DROP TABLE IF EXISTS `invite_log`;
CREATE TABLE `invite_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '发出邀请的用户uid',
  `invite_uid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '邀请进来的用户uid',
  `invite_time` datetime DEFAULT NULL COMMENT '邀请用户进来时间',
  `reward_status` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '邀请奖励领取状态 0未领取，1已领取',
  `pull_reward_time` datetime DEFAULT NULL COMMENT '领取邀请奖励时间',
  `date` date DEFAULT NULL COMMENT '日期',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `uid` (`uid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=535 DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Table structure for league_match
-- ----------------------------
DROP TABLE IF EXISTS `league_match`;
CREATE TABLE `league_match` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `create_time` int(10) NOT NULL COMMENT '创建时间',
  `checkpoint` varchar(255) NOT NULL COMMENT '随机创建关卡集',
  PRIMARY KEY (`id`),
  KEY `index_create_time` (`create_time`)
) ENGINE=InnoDB AUTO_INCREMENT=93 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for record_challenge
-- ----------------------------
DROP TABLE IF EXISTS `record_challenge`;
CREATE TABLE `record_challenge` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL COMMENT '用户id',
  `challenge_time` int(10) NOT NULL COMMENT '挑战对应联赛时间',
  `clearance_num` int(11) NOT NULL COMMENT '通关数',
  PRIMARY KEY (`id`),
  KEY `index_challenge_time` (`challenge_time`)
) ENGINE=InnoDB AUTO_INCREMENT=784 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for sign
-- ----------------------------
DROP TABLE IF EXISTS `sign`;
CREATE TABLE `sign` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL COMMENT '用户id',
  `sign_time` int(11) DEFAULT NULL COMMENT '签到时间',
  `receive_status` int(1) DEFAULT '1' COMMENT '领取状态（1-未领取，2-领取）',
  `renew` int(5) DEFAULT '0' COMMENT '签到天数',
  PRIMARY KEY (`id`),
  KEY `sign_time` (`sign_time`) USING BTREE,
  KEY `user_id` (`user_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=57122 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(125) DEFAULT NULL COMMENT '用户名',
  `openid` varchar(128) NOT NULL COMMENT '用户openid',
  `gender` varchar(12) DEFAULT NULL COMMENT '性别',
  `img` varchar(255) DEFAULT NULL COMMENT '用户头像',
  `checkpoint` int(3) DEFAULT '0' COMMENT '通关数',
  `gold` int(11) NOT NULL DEFAULT '200' COMMENT '金币',
  `skin_id` varchar(255) DEFAULT '0' COMMENT '皮肤id集（逗号隔开的字符串）',
  `use_skin` int(2) DEFAULT '0' COMMENT '当前使用皮肤id',
  `open_cards` int(3) DEFAULT NULL COMMENT '最新解锁关卡数',
  `coiling` int(2) DEFAULT '0' COMMENT '卡卷数',
  `cash` int(4) DEFAULT '0' COMMENT '提现现金',
  `update_time` int(10) DEFAULT NULL COMMENT '用户更新数据时间',
  `luck_draw_num` int(2) DEFAULT '0' COMMENT '抽奖次数',
  `last_share_time` int(10) DEFAULT NULL COMMENT '最后一次分享时间',
  `share_num` int(2) DEFAULT '0' COMMENT '当天分享次数记录',
  `last_advertise_time` int(10) DEFAULT NULL COMMENT '最后一次观看广告时间',
  `advertise_num` int(2) DEFAULT '0' COMMENT '当天广告次数记录',
  `unlock_gold` int(10) DEFAULT '10' COMMENT '解锁关卡所需金币数',
  `add_app` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '是否加入我的小程序',
  `last_unlock_time` int(10) DEFAULT NULL COMMENT '最后一次解锁关卡的时间(每天重置用）',
  PRIMARY KEY (`id`),
  KEY `openid` (`openid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=45999 DEFAULT CHARSET=utf8;
