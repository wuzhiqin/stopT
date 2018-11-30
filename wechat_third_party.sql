/*
Navicat MySQL Data Transfer

Source Server         : game
Source Server Version : 50628
Source Host           : gz-cdb-ebqjvubu.sql.tencentcdb.com:62608
Source Database       : wechat_third_party

Target Server Type    : MYSQL
Target Server Version : 50628
File Encoding         : 65001

Date: 2018-11-30 11:03:08
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for admin
-- ----------------------------
DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 NOT NULL COMMENT '用户名',
  `password` varchar(255) CHARACTER SET utf8mb4 NOT NULL COMMENT '密码',
  `pwd_salt` varchar(255) CHARACTER SET utf8mb4 NOT NULL COMMENT '用户密码加Salt散列',
  `role_id` int(5) NOT NULL COMMENT '用户角色id',
  `creator_id` int(11) DEFAULT NULL COMMENT '创建者id',
  `last_login_time` int(10) DEFAULT NULL COMMENT '最后一次登录时间',
  `update_time` int(10) DEFAULT NULL COMMENT '更新时间',
  `create_time` int(10) DEFAULT NULL COMMENT '创建时间',
  `last_login_ip` varchar(255) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '最后一次登录ip',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for admin_auth
-- ----------------------------
DROP TABLE IF EXISTS `admin_auth`;
CREATE TABLE `admin_auth` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `auth_name` varchar(255) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '权限名',
  `auth_url` varchar(255) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '权限url',
  `auth_parent` int(11) DEFAULT NULL COMMENT '父级权限id，0代表最高权限',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for admin_role
-- ----------------------------
DROP TABLE IF EXISTS `admin_role`;
CREATE TABLE `admin_role` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_name` varchar(255) CHARACTER SET utf8mb4 NOT NULL COMMENT '权限名',
  `role_auth` varchar(255) CHARACTER SET utf8mb4 NOT NULL COMMENT '操作权限，逗号隔开',
  `description` varchar(255) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '描述',
  `isDelete` int(1) DEFAULT '1' COMMENT '是否删除（1-否 2-是）',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for advertiser_attract
-- ----------------------------
DROP TABLE IF EXISTS `advertiser_attract`;
CREATE TABLE `advertiser_attract` (
  `id` int(11) NOT NULL COMMENT '主键（与wechat_account_advertiser表id相同）',
  `appid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'appid',
  `attract_switch` int(1) DEFAULT '0' COMMENT '带号开关（与公众号功能相同，减少连表做的冗余字段）',
  `last_user_sub_time` int(10) DEFAULT '0' COMMENT '最近用户关注时间',
  `threshold` int(7) DEFAULT '2000' COMMENT '阈值',
  `level` tinyint(2) DEFAULT '1' COMMENT '层级',
  `attract_relation` tinyint(3) DEFAULT '0' COMMENT '带号分组',
  `sub_url` text COLLATE utf8mb4_unicode_ci COMMENT '带号',
  `today_user_num` int(11) DEFAULT '0' COMMENT '今日用户数量',
  `total_user_num` int(11) DEFAULT '0' COMMENT '总用户数量',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for advertiser_public_msg
-- ----------------------------
DROP TABLE IF EXISTS `advertiser_public_msg`;
CREATE TABLE `advertiser_public_msg` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` int(11) DEFAULT '1' COMMENT '类型（1菜单 2关注回复 3关键词回复）',
  `menu` text COLLATE utf8mb4_unicode_ci COMMENT '菜单数据json',
  `ext_msg` text COLLATE utf8mb4_unicode_ci COMMENT 'json（菜单时存放附加消息json，自定义回复时存放自定义消息json）',
  `create_time` int(10) DEFAULT NULL COMMENT '创建时间',
  `remark` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '无备注' COMMENT 'remark',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for advertiser_relation
-- ----------------------------
DROP TABLE IF EXISTS `advertiser_relation`;
CREATE TABLE `advertiser_relation` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `relation` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '分组名',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for advertiser_wechat_reply
-- ----------------------------
DROP TABLE IF EXISTS `advertiser_wechat_reply`;
CREATE TABLE `advertiser_wechat_reply` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `wechat_id` int(11) NOT NULL COMMENT '微信公众id',
  `type` int(3) DEFAULT NULL COMMENT '类型  1-click_button   2-subscribe  3-keyword',
  `key` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '关键词',
  `return_type` int(3) DEFAULT '1' COMMENT '回复类型 被动回复（1-文本 2-图文 3-图片）客服消息（3-文本 4-图文1条 6-图片） 模板消息（7）',
  `random` int(3) DEFAULT '0' COMMENT '0-指定    1-随机',
  `send_time` int(10) DEFAULT '0' COMMENT '发送时间',
  `return_msg` text CHARACTER SET utf8mb4 COMMENT '返回消息',
  `create_time` int(10) DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=93 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for attach
-- ----------------------------
DROP TABLE IF EXISTS `attach`;
CREATE TABLE `attach` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hf_type` int(1) NOT NULL COMMENT '头尾类型（1头部2尾部3中部）',
  `m_type` int(2) NOT NULL COMMENT '1图片 2超链接 3小程序卡片 4小程序图片 5小程序超链接',
  `value` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '内容（图片为图片名，超链接为富文本）',
  `remark` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '无' COMMENT '备注信息',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for authorize_param
-- ----------------------------
DROP TABLE IF EXISTS `authorize_param`;
CREATE TABLE `authorize_param` (
  `name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '参数名',
  `value` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '参数值',
  `update_time` int(11) DEFAULT '0' COMMENT '更新时间 ',
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for config
-- ----------------------------
DROP TABLE IF EXISTS `config`;
CREATE TABLE `config` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `config_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '备注',
  `config_value` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '0' COMMENT '值',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for custom_reply
-- ----------------------------
DROP TABLE IF EXISTS `custom_reply`;
CREATE TABLE `custom_reply` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ext_msg` text CHARACTER SET utf8mb4 NOT NULL COMMENT '自定义回复json数据',
  `create_time` int(10) NOT NULL COMMENT '创建时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for delay_send
-- ----------------------------
DROP TABLE IF EXISTS `delay_send`;
CREATE TABLE `delay_send` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `appid` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'appid（用来换取token）',
  `post` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '客服消息数据（json）',
  `send_time` int(10) NOT NULL COMMENT '发送时间(由创建时间和延迟时间计算生成)',
  `status` int(1) DEFAULT '0' COMMENT '发送状态（0未发送 1发送完成）',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1530 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for error
-- ----------------------------
DROP TABLE IF EXISTS `error`;
CREATE TABLE `error` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `err_type` int(11) NOT NULL COMMENT '错误类型(1函数错误|2微信api错误)',
  `err_msg` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '错误信息',
  `time` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '时间（日期形式）',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=13624 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for gallery
-- ----------------------------
DROP TABLE IF EXISTS `gallery`;
CREATE TABLE `gallery` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `pic_url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '图片地址（腾讯云对象存储）',
  `type` int(2) NOT NULL COMMENT '1头部 2尾部 3中部 4菜单图片 5活动图片 6通用图片',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for material_account
-- ----------------------------
DROP TABLE IF EXISTS `material_account`;
CREATE TABLE `material_account` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `account_name` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '账号名称',
  `type` int(2) DEFAULT NULL COMMENT '素材来源（1百家号 2UC头条 3趣头条）',
  `account_id` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '素材账号id',
  `account_url` text COLLATE utf8mb4_unicode_ci COMMENT '账号地址',
  `last_update_time` int(11) DEFAULT '0',
  `material_type` int(2) DEFAULT '0' COMMENT '账号分类（来源于分类表）',
  `news_num` int(11) DEFAULT '0' COMMENT '文章数量',
  `remark` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '备注',
  `admin_id` int(10) NOT NULL COMMENT '标识哪个用户添加的账号',
  `create_time` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=25419 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for material_account_del
-- ----------------------------
DROP TABLE IF EXISTS `material_account_del`;
CREATE TABLE `material_account_del` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` varchar(255) CHARACTER SET utf8mb4 NOT NULL COMMENT '被删除的素材账号',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=161 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for material_content
-- ----------------------------
DROP TABLE IF EXISTS `material_content`;
CREATE TABLE `material_content` (
  `content_id` int(11) NOT NULL COMMENT '主键(不自增，与material_news表id同步)',
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '文章内容',
  PRIMARY KEY (`content_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for material_news
-- ----------------------------
DROP TABLE IF EXISTS `material_news`;
CREATE TABLE `material_news` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `referer_id` int(2) DEFAULT NULL COMMENT '来源id(1百家号)',
  `news_id` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '素材id',
  `account_local_id` int(11) DEFAULT NULL,
  `material_account_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '素材账号id',
  `material_type` int(2) DEFAULT '1' COMMENT '素材分类',
  `title` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '文章标题',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '暂无简介' COMMENT '简介',
  `cover_pic_url` text COLLATE utf8mb4_unicode_ci COMMENT '封面图url',
  `content_pic_url` text COLLATE utf8mb4_unicode_ci COMMENT '内容图url',
  `content_source_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '阅读原文地址',
  `use_type` int(1) NOT NULL DEFAULT '0' COMMENT '使用状态',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `material_account_id` (`material_account_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=436620 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for menu_reply_error
-- ----------------------------
DROP TABLE IF EXISTS `menu_reply_error`;
CREATE TABLE `menu_reply_error` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `wechat_id` int(11) NOT NULL COMMENT '微信公众id',
  `err_msg` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '错误信息',
  `err_time` int(11) DEFAULT NULL COMMENT '错误产生时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for public_msg
-- ----------------------------
DROP TABLE IF EXISTS `public_msg`;
CREATE TABLE `public_msg` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` int(11) DEFAULT '1' COMMENT '类型（1菜单 2关注回复 3关键词回复）',
  `menu` text COLLATE utf8mb4_unicode_ci COMMENT '菜单数据json',
  `ext_msg` text COLLATE utf8mb4_unicode_ci COMMENT 'json（菜单时存放附加消息json，自定义回复时存放自定义消息json）',
  `create_time` int(10) DEFAULT NULL COMMENT '创建时间',
  `remark` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '无备注' COMMENT 'remark',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for relation
-- ----------------------------
DROP TABLE IF EXISTS `relation`;
CREATE TABLE `relation` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `relation_name` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '类型名称',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=72 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for reply_audio
-- ----------------------------
DROP TABLE IF EXISTS `reply_audio`;
CREATE TABLE `reply_audio` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value` text COLLATE utf8mb4_unicode_ci COMMENT '音频地址',
  `type` int(2) DEFAULT '-1' COMMENT '类型（-1通用 具体类型type表)',
  `create_time` int(10) DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for reply_pic
-- ----------------------------
DROP TABLE IF EXISTS `reply_pic`;
CREATE TABLE `reply_pic` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `value` text COLLATE utf8mb4_unicode_ci COMMENT '图片地址',
  `type` int(2) DEFAULT '-1' COMMENT '类型（-1通用 具体类型type表)',
  `create_time` int(10) DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for reply_title
-- ----------------------------
DROP TABLE IF EXISTS `reply_title`;
CREATE TABLE `reply_title` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `value` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '标题',
  `type` int(2) DEFAULT '-1' COMMENT '类型(-1通用 具体对应分类id)',
  `create_time` int(10) DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for reply_video
-- ----------------------------
DROP TABLE IF EXISTS `reply_video`;
CREATE TABLE `reply_video` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value` varchar(255) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '视频地址',
  `type` int(2) DEFAULT '-1' COMMENT '类型（-1通用 具体类型type表)',
  `create_time` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for send
-- ----------------------------
DROP TABLE IF EXISTS `send`;
CREATE TABLE `send` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `send_id` int(11) NOT NULL COMMENT '群发id(分组用)',
  `send_time` int(10) DEFAULT '0' COMMENT '发送时间',
  `send_num` int(1) DEFAULT '0' COMMENT '发送数量',
  `wechat_id` int(11) NOT NULL COMMENT '微信公众号id',
  `status` int(6) NOT NULL DEFAULT '0' COMMENT '0 待发送|1 正在发送|2 待检查|200 发送完成|500 发送失败',
  `media_id` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '素材id',
  `msg_id` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '群发消息id',
  `msg_data_id` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '图文消息数据id',
  `return_msg` text COLLATE utf8mb4_unicode_ci COMMENT '返回信息',
  `verify_type` tinyint(2) NOT NULL DEFAULT '0' COMMENT '类型：-1未认证公众号，0已认证',
  `json_log` text COLLATE utf8mb4_unicode_ci COMMENT 'json日志',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `send_id` (`send_id`) USING BTREE,
  KEY `wechat_id` (`wechat_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=14857 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for send_list
-- ----------------------------
DROP TABLE IF EXISTS `send_list`;
CREATE TABLE `send_list` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `send_time` int(11) DEFAULT '2147443200' COMMENT '定时发送时间，默认为2147443200（2038年）',
  `send_count` int(11) NOT NULL,
  `send_success` int(11) unsigned DEFAULT '0' COMMENT '已发送数量',
  `create_time` int(11) NOT NULL COMMENT '创建时间',
  `success_time` int(11) DEFAULT NULL COMMENT '完成时间',
  `send_md5` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '发送信息校验码',
  `remark` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT '无' COMMENT '备注',
  `return_msg` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '返回信息',
  `verify_type` tinyint(2) NOT NULL COMMENT '-1未认证，0已认证',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `send_md5` (`send_md5`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=122 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for type
-- ----------------------------
DROP TABLE IF EXISTS `type`;
CREATE TABLE `type` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `type_name` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '类型名称',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for wechat_account
-- ----------------------------
DROP TABLE IF EXISTS `wechat_account`;
CREATE TABLE `wechat_account` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `gh_id` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '原始id',
  `appid` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'appid',
  `nick_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '公众号名称',
  `service_type_info` int(2) DEFAULT NULL COMMENT '公众号类型，0代表订阅号，1代表由历史老帐号升级后的订阅号，2代表服务号，3原账号迁移',
  `verify_type_info` int(2) DEFAULT '-1' COMMENT '授权方认证类型，-1代表未认证，0代表认证',
  `refresh_token` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '刷新token',
  `func_info` text COLLATE utf8mb4_unicode_ci COMMENT '授权信息',
  `authorization_time` int(11) DEFAULT NULL COMMENT '授权时间',
  `material_type` int(2) DEFAULT '0' COMMENT '账号类型（type表id）',
  `relation_id` int(11) DEFAULT '0' COMMENT '分组id',
  `scan_account` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '未知' COMMENT '扫码号',
  `login_password` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'wduaxzg1987' COMMENT '未认证登陆密码',
  `login_token` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '未认证登陆成功保存的token',
  `login_cookie` text COLLATE utf8mb4_unicode_ci COMMENT '未认证登陆成功的cookie',
  `last_login_time` int(10) unsigned DEFAULT '0' COMMENT '未认证最后模拟登录时间',
  `last_send_time` int(10) unsigned DEFAULT '0' COMMENT '最后群发时间',
  `last_flow_update_time` int(10) unsigned DEFAULT '0' COMMENT '最后流量主更新信息',
  `income_total` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '总收入',
  `attract_switch` int(1) DEFAULT '0' COMMENT '带号开关(0关闭 1开启 2超限)',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4279 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for wechat_account_advertiser
-- ----------------------------
DROP TABLE IF EXISTS `wechat_account_advertiser`;
CREATE TABLE `wechat_account_advertiser` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '间隔时间(second)',
  `gh_id` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '原始id',
  `appid` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'appid',
  `nick_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '公众号名称',
  `service_type_info` int(2) DEFAULT NULL COMMENT '公众号类型，0代表订阅号，1代表由历史老帐号升级后的订阅号，2代表服务号，3原账号迁移',
  `verify_type_info` int(2) DEFAULT '-1' COMMENT '授权方认证类型，-1代表未认证，0代表认证',
  `refresh_token` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '刷新token',
  `func_info` text COLLATE utf8mb4_unicode_ci COMMENT '授权信息',
  `authorization_time` int(11) DEFAULT NULL COMMENT '授权时间',
  `material_type` int(2) DEFAULT '0' COMMENT '账号类型（type表id）',
  `relation_id` int(11) DEFAULT '0' COMMENT '分组id',
  `scan_account` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '未知' COMMENT '扫码号',
  `login_password` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'wduaxzg1987' COMMENT '未认证登陆密码',
  `login_token` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '未认证登陆成功保存的token',
  `login_cookie` text COLLATE utf8mb4_unicode_ci COMMENT '未认证登陆成功的cookie',
  `last_login_time` int(10) unsigned DEFAULT '0' COMMENT '未认证最后模拟登录时间',
  `last_send_time` int(10) unsigned DEFAULT '0' COMMENT '最后群发时间',
  `last_flow_update_time` int(10) unsigned DEFAULT '0' COMMENT '最后流量主更新信息',
  `income_total` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '总收入',
  `next_advertiser_time` int(10) NOT NULL DEFAULT '0' COMMENT '下一次更新广告主时间戳',
  `advertiser_limit_time` int(10) NOT NULL DEFAULT '0' COMMENT '间隔时间(seconds)',
  `advertiser_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '广告主更新状态，0关，1开，2登陆状态失效',
  `paid` decimal(10,2) unsigned NOT NULL DEFAULT '0.00' COMMENT '总花费(元)',
  `exp_pv` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '曝光次数',
  `clk_pv` int(10) NOT NULL COMMENT '点击次数',
  `ctr` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0.00' COMMENT '点击率',
  `comindex` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '转化指标',
  `cpa` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0.00' COMMENT '转化成本',
  `cpc` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0.00' COMMENT '每次点击付费广告',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2156 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for wechat_account_advertiser_data
-- ----------------------------
DROP TABLE IF EXISTS `wechat_account_advertiser_data`;
CREATE TABLE `wechat_account_advertiser_data` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '账号id',
  `time` datetime DEFAULT NULL COMMENT '时间',
  `paid` decimal(10,2) unsigned NOT NULL DEFAULT '0.00' COMMENT '总花费(元)',
  `exp_pv` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '曝光次数',
  `clk_pv` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '点击次数',
  `ctr` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '点击率',
  `comindex` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '转化指标',
  `cpa` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '转化成本',
  `cpc` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '每次点击付费广告',
  `_paid` decimal(10,2) unsigned NOT NULL DEFAULT '0.00' COMMENT '计算：总花费(元)',
  `_exp_pv` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '计算：曝光次数',
  `_clk_pv` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '计算：点击次数',
  `_ctr` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '计算：点击率',
  `_comindex` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '计算：转化指标',
  `_cpa` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '计算：转化成本',
  `_cpc` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '计算：每次点击付费广告',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for wechat_account_flow
-- ----------------------------
DROP TABLE IF EXISTS `wechat_account_flow`;
CREATE TABLE `wechat_account_flow` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '微信账号id',
  `date` date DEFAULT NULL COMMENT '日期',
  `click_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '点击量',
  `exposure_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '曝光量',
  `income` decimal(10,2) unsigned NOT NULL DEFAULT '0.00' COMMENT '进账',
  `click_rate` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '点击率',
  `avg_income` decimal(10,2) unsigned NOT NULL DEFAULT '0.00' COMMENT '平均进账',
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`) USING BTREE,
  KEY `date` (`date`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=65268 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='微信公众号流量主数据';

-- ----------------------------
-- Table structure for wechat_attach
-- ----------------------------
DROP TABLE IF EXISTS `wechat_attach`;
CREATE TABLE `wechat_attach` (
  `id` int(11) NOT NULL,
  `use_head` int(1) DEFAULT '0' COMMENT '是否使用头部信息（0不使用1使用）',
  `use_foot` int(1) DEFAULT '0' COMMENT '使用尾部（0不使用1使用）',
  `use_href` int(1) DEFAULT '0' COMMENT '是否使用原文链接（0不使用1使用）',
  `use_middle` int(1) DEFAULT '0' COMMENT '是否使用中部信息（0不使用1使用）',
  `head_type` int(2) DEFAULT '0' COMMENT '头部类型（0不存在1图片）',
  `foot_type` int(2) DEFAULT '0' COMMENT '尾部类型（0不存在1图片2超链接）',
  `middle_type` int(2) DEFAULT '0' COMMENT '中部类型（0不存在 1图片 2超链接 3小程序卡片 4小程序图片 5小程序超链接）',
  `head_value` text COLLATE utf8mb4_unicode_ci COMMENT '头部信息',
  `foot_value` text COLLATE utf8mb4_unicode_ci,
  `middle_value` text COLLATE utf8mb4_unicode_ci COMMENT '中部信息',
  `href_value` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for wechat_attach_menu
-- ----------------------------
DROP TABLE IF EXISTS `wechat_attach_menu`;
CREATE TABLE `wechat_attach_menu` (
  `id` int(11) NOT NULL COMMENT '微信公众id',
  `menu` text CHARACTER SET utf8mb4 NOT NULL COMMENT '菜单',
  `ext_msg` text CHARACTER SET utf8mb4 COMMENT '附加消息',
  `create_time` int(10) NOT NULL DEFAULT '0' COMMENT '创建时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '备注',
  `status` int(2) NOT NULL DEFAULT '1' COMMENT '1-未设置 2-设置但未使用  3-已使用'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for wechat_reply
-- ----------------------------
DROP TABLE IF EXISTS `wechat_reply`;
CREATE TABLE `wechat_reply` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `wechat_id` int(11) NOT NULL COMMENT '微信公众id',
  `type` int(3) DEFAULT NULL COMMENT '类型  1-click_button   2-subscribe  3-keyword',
  `key` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '关键词',
  `return_type` int(3) DEFAULT '1' COMMENT '回复类型 被动回复（1-文本 2-图文 3-图片）客服消息（3-文本 4-图文1条 6-图片） 模板消息（7）',
  `random` int(3) DEFAULT '0' COMMENT '0-指定    1-随机',
  `send_time` int(10) DEFAULT '0' COMMENT '发送时间',
  `return_msg` text CHARACTER SET utf8mb4 COMMENT '返回消息',
  `create_time` int(10) DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=275 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
