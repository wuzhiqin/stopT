<?php
/**
 * Created by PhpStorm.
 * User: gaozh
 * Date: 2018/9/26
 * Time: 17:53
 */

namespace app\api\controller\v1;


use think\Db;
use think\facade\Config;
use think\Request;

class Test
{
    public function test()
    {
        $time = time();
        echo $time.'<br>';
        //当天开始和结束时间
        $beginToday=mktime(0,0,0,date('m'),date('d'),date('Y'));
        $endToday=mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;
        $beginYesterday = $beginToday - 3600 * 24;
        $endYesterday = $endToday - 3600 * 24;
        echo $beginYesterday.'<br>';
        echo date('Y-m-d H:i:s',$beginYesterday).'<br>';
        echo date('Y-m-d H:i:s',$endYesterday).'<br>';

        echo '关卡数';
        echo Config::get('config.checkpoint_min');
    }

    public function test1()
    {
        $a = '0';
        testing($a);
    }

    public function test2()
    {
        $url = 'https://mp.weixin.qq.com/';
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_HEADER, 0);
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE);
        curl_setopt($ch, CURLOPT_COOKIEJAR, '2.txt');//把返回来的cookie信息保存在$cookie_jar文件中
        $result = curl_exec($ch);
        curl_close($ch);
    }

    public function test3()
    {
        $url = 'https://mp.weixin.qq.com/cgi-bin/bizlogin?action=startlogin';
        $res = curlPost($url,http_build_query([
            'username'=> '13112568950@163.com',
            'pwd' => '98944746wzq',
            'imgcode' => '',
            'f'=> 'json',
            'userlang'=> 'zh_CN',
            'token'=> '',
            'lang' => 'zh_CN',
            'ajax'=> 1,
        ]),'https://mp.weixin.qq.com/','','2.txt');
        dump($res);
    }


    //第一种测试
    public function user1()
    {
        $param = get_param(['openid','name','img','gender']);
        foreach ($param as $k=>$v){
            $param[$k] = trim($v);
        }
        testing($param['openid']);
        $user_data = Db::name('user')->where('openid',$param['openid'])->find();

        //有数据则直接返回用户数据
        if ($user_data){
            $user_data['skin_id'] = explode(',',$user_data['skin_id']);
            $user_data['sign_status'] = false;
            $user_data['renew'] = 0;

            //当天开始和结束时间
            $beginToday=mktime(0,0,0,date('m'),date('d'),date('Y'));
            $endToday=mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;
            //昨天开始和结束时间
            $beginYesterday = $beginToday - 3600 * 24;
            $endYesterday = $endToday - 3600 * 24;

            //检测今天是否已经签到
            $is = Db::name('sign')
                ->where('user_id',$user_data['id'])
                ->where('sign_time','between',[$beginToday,$endToday])
                ->find();
            //返回今天是否签到状态
            $is ? $user_data['sign_status'] = true : '';

            //查询昨天是否有签到
            $last_is = Db::name('sign')
                ->where('user_id',$user_data['id'])
                ->where('sign_time','between',[$beginYesterday,$endYesterday])
                ->find();
            //返回昨天的连签状态
            $last_is ? $user_data['renew'] = $last_is['renew'] : '';

            return json(['data'=>$user_data,'message'=>'请求成功','code'=>200]);
        }else{
            $res['id'] = Db::name('user')->insertGetId($param);

            if ($res){
                return json(['data'=>$res,'message'=>'新增成功','code'=>200]);
            }else{
                return json(['data'=>false,'message'=>'新增失败','code'=>400]);
            }

        }
    }

    //第二种测试
    public function user2()
    {
        $param = get_param(['openid','name','img','gender']);
        foreach ($param as $k=>$v){
            $param[$k] = trim($v);
        }
        testing($param['openid']);
        $user_data = Db::name('user')->where('openid',$param['openid'])->find();

        //有数据则直接返回用户数据
        if ($user_data){
            $user_data['skin_id'] = explode(',',$user_data['skin_id']);
            $user_data['sign_status'] = false;      //当天签到状态
            $user_data['renew'] = 0;                 //连签天数

            //昨天开始和结束时间
            $beginYesterday=mktime(0,0,0,date('m'),date('d')-1,date('Y'));
            $endToday=mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;

            //昨天到今天签到数据查询
            $is = Db::name('sign')
                ->where('user_id',$user_data['id'])
                ->where('sign_time','between',[$beginYesterday,$endToday])
                ->select();
            $last_date = date('Ymd',$beginYesterday);
            $now_date = date('Ymd',$endToday);

            //数据对比检测
            if ($is){
                foreach($is as $k=>$v){
                    //今天签到检查
                    if (date('Ymd',$v['sign_time']) == $now_date){
                        $user_data['sign_status'] = true;
                    }
                    //昨天签到检查
                    if(date('Ymd',$v['sign_time']) == $last_date){
                        $user_data['renew'] = $v['renew'];
                    }
                }
            }

            return json(['data'=>$user_data,'message'=>'请求成功','code'=>200]);
        }else{
            $res['id'] = Db::name('user')->insertGetId($param);

            if ($res){
                return json(['data'=>$res,'message'=>'新增成功','code'=>200]);
            }else{
                return json(['data'=>false,'message'=>'新增失败','code'=>400]);
            }

        }
    }



    public function login(){
        $param = get_param_no_empty(['appid','js_code']);
        $find = Db::name('wechatlist')->where('appid',$param['appid'])->find();
        $url = "https://api.weixin.qq.com/sns/jscode2session?appid=".$find['appid']."&secret=".$find['secret']."&js_code=".$param['js_code']."&grant_type=authorization_code";

        $res = file_get_contents($url);
        $info = json_decode($res,true);
        // dump($info);exit;
        if (isset($info['errMsg'])) {
            return json(['item'=>$res,'errMsg'=>'错了','errCode'=>300]);
            exit;
        }
        $is = Db::name('user')->where('openid',$info['openid'])->find();
        if ($is) {
            return json(['item'=>$is,'errMsg'=>'用户已经保存','errCode'=>200]);
            exit;
        }
        $user = Db::name('user')->insertGetId(['openid'=>$info['openid'],'score'=>0]);
        if ($user) {
            $find = Db::name('user')->find($user);
            return json(['item'=>$find,'errMsg'=>'用户保存成功','errCode'=>200]);
        }
    }


}