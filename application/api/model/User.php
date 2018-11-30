<?php
/**
 * Created by PhpStorm.
 * User: len0v0
 * Date: 2018/8/21
 * Time: 17:55
 */

namespace app\api\model;
use think\Model;

class User extends Model{
	// 模型初始化
	protected static function init() {
		
	}
	public function profile() {
		return $this->hasOne('game');
	}

}