<?php
/**
 * Created by PhpStorm.
 * User: len0v0
 * Date: 2018/8/20
 * Time: 17:37
 */

namespace app\api\controller\v1;
use think\Db;
use think\Exception;
use think\facade\Config;

class User {
    private $day=3;                 //设置头像和用户名更新时间（单位:天）
    private $luck_draw_max=10;     //抽奖次数叠加上限
    private $share = 3;             //每天分享次数
    private $advertise = 10;       //每天观看广告次数
    private $unlock_gold = 10;     //重置每天开启关卡所需金币数

    /*
     * 新增和获取用户信息
     * @param string js_code 微信用户code
     */
    public function user()
    {
        $param = get_param(['js_code','img','name']);
        testing($param['js_code']);
        $appid ='wxd4b382fb6d063d6e';
        $secret = '924703b0abc5d583a2b014c7b4f276eb';
        $param['openid'] = get_openid($appid,$secret,$param['js_code']);
        unset($param['js_code']);
        foreach ($param as $k=>$v){
            $param[$k] = trim($v);
        }
        $param['update_time'] = time();

        $user_data = Db::name('user')->where('openid',$param['openid'])->find();

        //条件通过则更新头像和用户名
        if (time()-intval($user_data['update_time']) > 3600*24*$this->day){
            $update['img'] = $param['img'];
            $update['name'] = $param['name'];
            $update['update_time'] = time();
            try{
                Db::name('user')->where('id',$user_data['id'])->update($update);
            }catch (Exception $e){
                return json(['data'=>false,'message'=>$e->getMessage(),'code'=>500]);
            }
        }

        //有数据则直接返回用户数据
        if ($user_data){
            $user_data['skin_id'] = explode(',',$user_data['skin_id']);

            /************************* 签到 **************************/
            $user_data['sign_status'] = false;      //当天签到状态
            $user_data['renew'] = 0;                 //连签天数

            //昨天开始和今天结束时间
            $beginYesterday=mktime(0,0,0,date('m'),date('d')-1,date('Y'));
            $endToday=mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;

            //昨天到今天签到数据查询
            try{
                $is = Db::name('sign')
                    ->where('user_id',$user_data['id'])
                    ->where('sign_time','between',[$beginYesterday,$endToday])
                    ->select();
            }catch (Exception $e){
                die(json_encode(['data'=>false,'message'=>$e->getMessage(),'code'=>500]));
            }

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


            //当天开始和结束时间
            $beginToday=mktime(0,0,0,date('m'),date('d'),date('Y'));
            $endToday=mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;

            /************************** 分享 ***********************/
            if($beginToday < $user_data['last_share_time'] && $endToday > $user_data['last_share_time']){
                $user_data['share_num'] = $this->share - intval($user_data['share_num']);
            }else{
                //重置抽奖分享次数
                Db::name('user')->where('openid',$param['openid'])->update(['share_num'=>0]);
                $user_data['share_num'] = $this->share;
            }

            /************************* 观看广告 **********************/
            if($beginToday < $user_data['last_advertise_time'] && $endToday > $user_data['last_advertise_time']){
                $user_data['advertise_num'] = $this->advertise - intval($user_data['advertise_num']);
            }else{
                //重置观看广告次数
                Db::name('user')->where('openid',$param['openid'])->update(['advertise_num'=>0]);
                $user_data['advertise_num'] = $this->advertise;
            }

            /*********************** 开启关卡所需金币数 ***************/
            if($beginToday > $user_data['last_unlock_time']){
                //重置开启关卡所需金币数
                Db::name('user')->where('openid',$param['openid'])->update(['unlock_gold'=>10]);
                $user_data['unlock_gold'] = $this->unlock_gold;
            }

            unset($user_data['last_share_time'],$user_data['last_advertise_time'],$user_data['last_unlock_time']);
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

    /*
     * 购买皮肤与获取皮肤
     * @param int user_id 用户id
     * @param int skin_id 皮肤id（前端写死的）
     */
    public function buySkin($gold=0)
    {
        $param = get_param(['user_id','skin_id']);
        $user_id = intval(trim($param['user_id']));
        $skin_id = trim($param['skin_id']);
        testing([$user_id,$skin_id]);
        if ($gold < 0){
            die(json_encode(['data'=>false,'message'=>'参数有误','code'=>400]));
        }
        //查询该用户是否存并验证金币是否够用
        $user_data = $this->UserTesting($user_id,$gold);
        //判断皮肤是否已购买，防止重复
        if ($user_data){
            $update['skin_id'] = [];
            if ($user_data['skin_id'] != ''){
                $update['skin_id'] = explode(',',$user_data['skin_id']);
            }

            if (in_array($skin_id,$update['skin_id'])){
                die(json_encode(['data'=>false,'message'=>'该皮肤已购买','code'=>400]));
            }
            array_push($update['skin_id'],$skin_id);
            $update['skin_id'] = implode(',',$update['skin_id']);
        }
        $res = '';
        if ($gold != ''){
            $res = Db::name('user')->where('id',$user_id)->dec('gold',$gold)->update($update);
        }

        if ($res){
            //领取成功，记录领取方式
            $this->recordGold($user_id,2,$gold,6);
            return json(['data'=>true,'message'=>'购买成功','code'=>200]);
        }else{
            return json(['data'=>false,'message'=>'购买失败','code'=>400]);
        }

    }

    /*
     * 开启游戏关卡
     * @param int user_id 用户id
     * @param int gold 开启关卡所需金币数
     */
    public function openCard()
    {
        $param = get_param(['user_id','gold']);
        $user_id = trim($param['user_id']);
        $gold = trim($param['gold']);
        if ($gold <= 0){
            die(json_encode(['data'=>false,'message'=>'参数有误','code'=>400]));
        }
        //检测用户是否存在和金币是否有够用
        $this->UserTesting($user_id,$gold);
        //开启关卡更新解锁的最新关卡数和金币
        $res = Db::name('user')
            ->where('id',$user_id)
            ->dec('gold',$gold)
            ->inc('unlock_gold')
            ->update([
                'open_cards' => Db::raw('checkpoint+1'),
                'last_unlock_time'=>time(),
            ]);

        if ($res){
            //领取成功，记录领取或使用方式
            $this->recordGold($user_id,2,$gold,1);
            return json(['data'=>true,'message'=>'成功','code'=>200]);
        }else{
            return json(['data'=>false,'message'=>'失败','code'=>400]);
        }
    }

    /*
     * 游戏通关，保存关卡数
     */
    public function gameOver()
    {
        $param = get_param(['user_id','checkpoint','gold']);
        $user_id = intval(trim($param['user_id']));

        //查询该用户是否存在
        $this->UserTesting($user_id);

        $checkpoint = intval($param['checkpoint']);
        //关卡数检测，最小1，最大100
        if ($checkpoint < Config::get('config.checkpoint_min') || $checkpoint > Config::get('config.checkpoint_max')){
            die(json_encode(['data'=>false,'message'=>'参数有误','code'=>400]));
        }

        $res = Db::name('user')
            ->where('id',$user_id)
            ->inc('gold',$param['gold'])
            ->update(['checkpoint'=>Db::raw("IF(checkpoint > $checkpoint,checkpoint,$checkpoint)")]);

        if ($res){
            if ($param['gold'] > 0){
                //领取成功，记录领取方式
                $this->recordGold($user_id,1,$param['gold'],8);
            }
            return json(['data'=>true,'message'=>'成功','code'=>200]);
        }else{
            return json(['data'=>false,'message'=>'失败','code'=>400]);
        }
    }

    /*
     * 领取金币奖励（签到金币领取）
     * @param int user_id 用户id
     * @param int gold          领取到的金币数
     * @param int coiling       领取到的卡卷数
     * @param int channel       获取到金币的途径 2-抽奖3-分享4-挑战5-看视频7-签到
     */
    public function receiveGold()
    {
        $param = get_param(['user_id','gold','channel','coiling']);
        $user_id = trim($param['user_id']);
        $gold = trim($param['gold']);
        $coiling = trim($param['coiling']);
        testing([$user_id,$gold,$coiling]);
        restrict([$param['channel']],[2,3,4,5,7]);        //获取途径 2-抽奖3-分享4-挑战5-看视频7-签到
        //查询该用户是否存在
        $this->UserTesting($user_id);

        //获取当天开始和结束时间戳
        $beginToday=mktime(0,0,0,date('m'),date('d'),date('Y'));
        $endToday=mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;


        /************************ 分享 ***************************/
        if ($param['channel'] == 3){
            $this->share($param['user_id']);
        }

        /*********************** 观看广告 ************************/
        if ($param['channel'] == 5){
            $this->advertise($param['user_id']);
        }

        /************************* 领奖签到 *************************/
        if ($param['channel'] == 7){
            //检测是否已经领取奖品
            $this->isSign($user_id);

            $insert['receive_status'] = 2;
            $insert['sign_time'] = time();
            $insert['renew'] = 1;
            $insert['user_id'] = $user_id;
            //查询昨天是否有签到
            $beginYesterday = $beginToday - 3600 * 24;
            $endYesterday = $endToday - 3600 * 24;
            $last_is = Db::name('sign')
                ->field('renew')
                ->where('user_id',$insert['user_id'])
                ->where('sign_time','between',[$beginYesterday,$endYesterday])
                ->find();
            if($last_is){
                $insert['renew'] = intval($last_is['renew']) + 1;
            }
            Db::name('sign')->insert($insert);
            unset($insert);
        }

        $res = Db::name('user')->where('id',$user_id)->inc('user.gold',$gold)->inc('user.coiling',$coiling)->update();

        if ($res){
            //领取成功，记录领取方式
            $this->recordGold($user_id,1,$gold,$param['channel']);
            return json(['data'=>true,'message'=>'领取成功','code'=>200]);
        }else{
            return json(['data'=>false,'message'=>'领取失败','code'=>400]);
        }
    }

    /*
     * 当天是否已经领取签到奖品
     */
    public function isSign($user_id)
    {
        //当天开始和结束时间
        $beginToday=mktime(0,0,0,date('m'),date('d'),date('Y'));
        $endToday=mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;
        $is = Db::name('sign')
            ->where(['user_id'=>$user_id,'receive_status'=>2])
            ->whereBetweenTime('sign_time',$beginToday,$endToday)
            ->find();
        if ($is){
            die(json_encode(['data'=>false,'message'=>'您今天已领取签到奖励','code'=>200]));
        }
    }

    /*
     * 记录最后一次分享时间
     */
    public function share($id)
    {
        if ($this->isShare($id)) die(json_encode(['data'=>false,'message'=>'当天分享次数已达上限','code'=>200]));
        $update['last_share_time'] = time();
        $res = Db::name('user')->where('id',$id)->inc('share_num')->update($update);
        if ($res){
            return json(['data'=>true,'message'=>'成功','code'=>200]);
        }else{
            return json(['data'=>false,'message'=>'失败','code'=>400]);
        }
    }

    //查询用户是否还有分享次数
    public function isShare($user_id)
    {
        //当天开始和结束时间
        $beginToday=mktime(0,0,0,date('m'),date('d'),date('Y'));
        $endToday=mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;
        return (bool) (Db::name('user')
            ->where('id',$user_id)
            ->where('share_num','>=',$this->share)
            ->whereBetweenTime('last_share_time',$beginToday,$endToday)
            ->find());
    }

    /*
     * 记录最后一次观看广告时间
     */
    public function advertise($id)
    {
        if ($this->isAdvertise($id)) die(json_encode(['data'=>false,'message'=>'当天观看次数已达上限','code'=>200]));
        $update['last_advertise_time'] = time();
        $res = Db::name('user')->where('id',$id)->inc('advertise_num')->update($update);
        if ($res){
            return json(['data'=>true,'message'=>'成功','code'=>200]);
        }else{
            return json(['data'=>false,'message'=>'失败','code'=>400]);
        }
    }

    //查询用户是否还有观看视频次数
    public function isAdvertise($user_id)
    {
        //当天开始和结束时间
        $beginToday=mktime(0,0,0,date('m'),date('d'),date('Y'));
        $endToday=mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;
        return (bool) (Db::name('user')
            ->where('id',$user_id)
            ->where('advertise_num','>=',$this->advertise)
            ->whereBetweenTime('last_advertise_time',$beginToday,$endToday)
            ->find());
    }


    /*
     * 获得钱啊,得存起来
     * @param int $user_id 用户id
     * @param int $cash 获取的现金数
     * @return json
     */
    public function saveCash()
    {
        $param = get_param(['user_id','cash']);
        testing($param);
        $this->UserTesting($param['user_id']);
        try{
            Db::name('user')
                ->where('id',$param['user_id'])
                ->setInc('cash',$param['cash']);
            return json(['data'=>true,'message'=>'恭喜，存钱成功','code'=>200]);
        }catch (Exception $e){
            return json(['data'=>false,'message'=>$e->getMessage(),'code'=>500]);
        }
    }

    /*
     * 使用皮肤
     * @param int user_id 用户id
     * @param int skin_id 皮肤id
     */
    public function useSkin()
    {
        $param = get_param(['user_id','skin_id']);
        testing($param);
        $user_id = intval(trim($param['user_id']));
        $update['use_skin'] = intval(trim($param['skin_id']));
        $user_data = $this->UserTesting($user_id);

        //判断是否拥有该皮肤
        if($user_data){
            $skin_arr = explode(',',$user_data['skin_id']);
            if (!in_array($update['use_skin'],$skin_arr)){
                die(json_encode(['data'=>false,'message'=>'你还未获得该皮肤','code'=>400]));
            }
        }

        $res = Db::name('user')->where('id',$user_id)->update($update);
        if ($res){
            return json(['data'=>true,'message'=>'更换成功','code'=>200]);
        }else{
            return json(['data'=>true,'message'=>'更换失败','code'=>200]);
        }
    }

    /*
     * 领取金币记录,记录领取方式和金币使用情况
     * @param int $user_id 用户id
     * @param int $status  1-增加 2-减少
     * @param int $gold 使用或增加的金币数
     * @param int $channel 1-开启关卡2-抽奖3-分享4-挑战5-看视频6-购买皮肤7-签到8-关卡中获取
     */
    public function recordGold($user_id,$status,$gold,$channel)
    {
        //领取成功，记录领取方式
        $insert['user_id'] = $user_id;
        $insert['channel'] = $channel;
        $insert['use_time'] = time();
        $insert['status'] = $status;
        $insert['gold'] = $gold;
        try{
            Db::name('gold_record')->insert($insert);
        }catch (Exception $e){
            die(json_encode(['data'=>false,'message'=>$e->getMessage(),'code'=>400]));
        }
    }

    /*
     * 用户和金币,卡卷等存量验证
     * @param int id 用户id
     * @param int gold 要使用的金币数
     * @param int coiling 要使用的卡卷数
     * @return array 通过验证则返回用户数据
     */
    public function UserTesting($id,$gold=0,$coiling=0)
    {
        $user_data = Db::name('user')->where('id',$id)->find();
        if (!$user_data){
            die(json_encode(['data'=>false,'message'=>'该用户不存在','code'=>400]));
        }
        if ($user_data['gold']-$gold < 0){
            die(json_encode(['data'=>false,'message'=>'金币不够','code'=>400]));
        }
        if ($user_data['coiling']-$coiling < 0){
            die(json_encode(['data'=>false,'message'=>'卡卷不够','code'=>400]));
        }
        return $user_data;
    }

    /*
     * 添加抽奖次数
     * @param int $user_id 用户id
     * @param int $luck_draw_num 添加抽奖次数
     * @return json
     */
    public function luckDraw()
    {
        $param = get_param(['user_id','luck_draw_num']);
        testing($param);
        $param['user_id'] = trim($param['user_id']);
        $luck_draw_num = trim($param['luck_draw_num']);
        $max = $this->luck_draw_max;
        try{
            $res = Db::name('user')
                ->where('id',$param['user_id'])
                ->update(['luck_draw_num'=>Db::raw("IF(luck_draw_num>=$max,luck_draw_num,luck_draw_num+$luck_draw_num)")]);
            if ($res){
                return json(['data'=>true,'message'=>'抽奖次数叠加成功','code'=>200]);
            }else{
                return json(['data'=>true,'message'=>'抽奖次数无法叠加,已达上限','code'=>200]);
            }
        }catch (Exception $e){
            return json(['data'=>false,'message'=>$e->getMessage(),'code'=>500]);
        }

    }

//    public function receiveGold()
//    {
//        $param = get_param(['user_id','gold','channel']);
//        $user_id = trim($param['user_id']);
//        $gold = trim($param['gold']);
//        testing([$user_id,$gold]);
//        restrict([$param['channel']],[2,3,4,5]);        //获取途径 2-抽奖3-分享4-挑战5-看视频7-签到
//
//        $update['sign.receive_status'] = 2;
//        //获取当天开始和结束时间戳
//        $beginToday=mktime(0,0,0,date('m'),date('d'),date('Y'));
//        $endToday=mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;
//
//        //判断是否已经领取奖品
//        $is = Db::name('sign')
//            ->where(['user_id'=>$user_id,'receive_status'=>2])
//            ->where('sign_time','between',[$beginToday,$endToday])
//            ->find();
//        if ($is){
//            die(json_encode(['data'=>false,'message'=>'您今天已领取签到奖励','code'=>200]));
//        }
//
//        $res = Db::name('sign')
//            ->leftJoin('user','user.id = sign.user_id')
//            ->where('sign.user_id',$user_id)
//            ->where('sign.sign_time','between',[$beginToday,$endToday])
//            ->inc('user.gold',$gold)
//            ->update($update);
//
//        if ($res){
//            //领取成功，记录领取方式
//            $insert['channel'] = $param['channel'];
//            $insert['use_time'] = time();
//            $insert['user_id'] = $user_id;
//            $insert['status'] = 1;          //1-增加 2-减少
//            $insert['gold'] = $gold;
//            Db::name('gold_record')->insert($insert);
//            return json(['data'=>true,'message'=>'领取成功','code'=>200]);
//        }else{
//            return json(['data'=>false,'message'=>'领取失败','code'=>400]);
//        }
//    }

}