<?php
/**
 * Created by PhpStorm.
 * User: gaozh
 * Date: 2018/9/28
 * Time: 11:09
 */

namespace app\api\controller\v1;

use think\Db;

class Sign
{
    //签到
    public function signIn()
    {
        die(json_encode(['message'=>'停用']));
        $param = get_param(['user_id']);
        $insert['user_id'] = $param['user_id'];
        testing($insert['user_id']);

        $insert['sign_time'] = time();
        $insert['renew'] = 1;

        //当天开始和结束时间
        $beginToday=mktime(0,0,0,date('m'),date('d'),date('Y'));
        $endToday=mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;
        //昨天开始和结束时间
//        $beginYesterday=mktime(0,0,0,date('m'),date('d')-1,date('Y'));
//        $endYesterday=mktime(0,0,0,date('m'),date('d'),date('Y'))-1;
        $beginYesterday = $beginToday - 3600 * 24;
        $endYesterday = $endToday - 3600 * 24;

        //检测今天是否已经签到
        $is = Db::name('sign')
            ->where('user_id',$insert['user_id'])
            ->where('sign_time','between',[$beginToday,$endToday])
            ->find();
        if ($is){
            die(json_encode(['data'=>$is,'message'=>'您已签到','code'=>200]));
        }

        //查询昨天是否有签到
        $last_is = Db::name('sign')
            ->where('user_id',$insert['user_id'])
            ->where('sign_time','between',[$beginYesterday,$endYesterday])
            ->find();
        if($last_is){
            $insert['renew'] = intval($last_is['renew']) + 1;
        }

        $res = Db::name('sign')->insert($insert);
        if ($res){
            return json(['data'=>true,'message'=>'签到成功','code'=>200]);
        }else{
            return json(['data'=>false,'message'=>'签到失败','code'=>400]);
        }
    }
}