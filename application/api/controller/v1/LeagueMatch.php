<?php
/**
 * Created by PhpStorm.
 * User: gaozh
 * Date: 2018/10/10
 * Time: 14:25
 */

namespace app\api\controller\v1;

use think\Db;
use think\Exception;
use think\facade\Cache;
use think\facade\Config;

class LeagueMatch
{
    private $l_m_expire = 3600;      //联赛数据缓存时间

    /*
     * 联赛关卡和倒计时等数据获取
     * @return json
     */
    public function start()
    {
        $now_time = time();
        //中午赛场
        $noon_start_time = strtotime(Config::get('config.noon_start_time'));
        $noon_stop_time = strtotime(Config::get('config.noon_stop_time'));

        //判断当前是否是中午赛场
        if($noon_start_time < $now_time && $noon_stop_time > $now_time){
            //查询是否已随机生成联赛关卡
            $is = $this->queryCheckpoint($noon_start_time,$noon_stop_time);
            if ($is){
                return json(['data'=>$is,'message'=>'请求成功','code'=>200]);
            }else{
                $insert['create_time'] = $now_time;
                $insert['checkpoint'] = $this->randomPass();
                $res = $this->insertCheckpoint($insert);
                //联赛倒计时
                $res['count_down'] = $noon_stop_time - time();
                return json(['data'=>$res,'message'=>'请求成功','code'=>200]);
            }
        }

        //晚间赛场
        $night_start_time = strtotime(Config::get('config.night_start_time'));
        $night_stop_time = strtotime(Config::get('config.night_stop_time'));

        //判断当前是否是晚间赛场
        if($night_start_time < $now_time && $night_stop_time > $now_time){
            //查询是否已随机生成联赛关卡
            $is = $this->queryCheckpoint($night_start_time,$night_stop_time);
            if ($is){
                return json(['data'=>$is,'message'=>'请求成功','code'=>200]);
            }else{
                $insert['create_time'] = $now_time;
                $insert['checkpoint'] = $this->randomPass();
                $res = $this->insertCheckpoint($insert);
                //联赛倒计时
                $res['count_down'] = $night_stop_time - time();
                return json(['data'=>$res,'message'=>'请求成功','code'=>200]);
            }
        }

        //计算距离下次联赛时间
        $distance_noon = $noon_start_time - $now_time;
        $distance_night = $night_start_time - $now_time;
        $distance_time = $distance_noon < $distance_night ? $distance_noon : $distance_night;
        //条件通过则说明当天中午联赛已过，计算距离晚间联赛时间
        if ($distance_noon < 0){
            $distance_time = $distance_night;
        }
        //条件通过则表明当天联赛时间都过了，计算距离明天联赛时间
        if ($distance_night < 0){
            $distance_time = $noon_start_time + 3600*24 - $now_time;
        }

        return json(['data'=>['distance_time'=>$distance_time,'open'=>false],'message'=>'请求成功','code'=>200]);
    }

    /*
     * 获取最近一场联赛排行
     * @return json
     */
    public function rankings($page=1,$limit=10)
    {
        //最新一次挑战时间，排名查询用
        $latest_time = Db::name('league_match')->max('create_time');
        $res['total_limit'] = Db::name('record_challenge')
            ->alias('r_c')
            ->field('user.img,user.name,r_c.clearance_num')
            ->leftJoin('user','r_c.user_id = user.id')
            ->where('r_c.challenge_time',$latest_time)
            ->count();
        $res['total_page'] = ceil($res['total_limit']/$limit);
        $res['current_page'] = $page;

        try{
            $res['list'] = Db::name('record_challenge')
                ->alias('r_c')
                ->field('user.img,user.name,user.openid,r_c.clearance_num')
                ->leftJoin('user','r_c.user_id = user.id')
                ->where('r_c.challenge_time',$latest_time)
                ->order('r_c.clearance_num','desc')
                ->page($page)
                ->limit($limit)
                ->select();
            return json(['data'=>$res,'message'=>'请求成功','code'=>200]);
        }catch (Exception $e){
            return json(['data'=>false,'message'=>$e->getMessage(),'code'=>500]);
        }
    }

    /*
     * 记录用户联赛挑战记录
     * @param int $user_id 用户id
     * @param int $challenge_time 对应联赛的创建时间
     * @param int $clearance_num  通关总数
     * @return json
     */
    public function recordChallenge()
    {
        $param = get_param(['user_id','challenge_time','clearance_num']);
        foreach ($param as $k=>$v){
            $param[$k] = trim($v);
        }
        testing($param);
        //查询该用户是否有对应的联赛记录
        $is = Db::name('record_challenge')
            ->where('user_id',$param['user_id'])
            ->where('challenge_time',$param['challenge_time'])
            ->find();
        if ($is){
            $clearance_num = $param['clearance_num'];
            try{
                Db::name('record_challenge')
                    ->where('user_id',$param['user_id'])
                    ->where('challenge_time',$param['challenge_time'])
                    ->update(['clearance_num'=>Db::raw("IF(clearance_num > $clearance_num,clearance_num,$clearance_num)")]);
                return json(['data'=>true,'message'=>'记录成功','code'=>200]);
            }catch (Exception $e){
                return json(['data'=>false,'message'=>$e->getMessage(),'code'=>500]);
            }
        }else{
            $res = Db::name('record_challenge')->insert($param);
            if ($res){
                return json(['data'=>true,'message'=>'记录成功','code'=>200]);
            }else{
                return json(['data'=>false,'message'=>'记录失败','code'=>400]);
            }
        }
    }

    /*
     * 开启联赛 消费卡卷
     */
    public function coiling()
    {
        $param = get_param(['user_id','coiling']);
        $user = NEW User();
        $id = trim($param['user_id']);
        $coiling = trim($param['coiling']);
        testing([$id,$coiling]);
        //验证用户和卡卷等信息
        $user->UserTesting($id,0,$coiling);
        $res = Db::name('user')->where('id',$id)->setDec('coiling',$coiling);
        if ($res){
            return json(['data'=>true,'message'=>'开启成功','code'=>200]);
        }else{
            return json(['data'=>false,'message'=>'开启失败','code'=>400]);
        }
    }

    /*
     * 获取联赛随机关卡
     * @return string
     */
    public function randomPass()
    {
        //创建随机关卡
        $checkpoint_min = Config::get('config.checkpoint_min');
        $checkpoint_max = Config::get('config.checkpoint_max');
        $checkpoint_num = Config::get('config.checkpoint_num');
        //计算第一个关卡随机生成最大值
        $max_num = floor($checkpoint_max / $checkpoint_num);
        //随机关卡
        $random_pass = array();
        for ($i=0,$f=0,$j=$max_num;$i<$checkpoint_num;$i++){
            $random_pass[$i] = rand($checkpoint_min+$f,$j);
            $j += $max_num;
            $f += $max_num;
        }
        return implode(',',$random_pass);
    }

    /*
     * 查询是否已随机生成联赛关卡
     * @param   int $start 开始时间戳
     * @param   int $stop 结束时间戳
     * @return   array
     */
    public function queryCheckpoint($start,$stop)
    {
        $is_cache = Cache::get('league_match_data');
        if ($is_cache){
            //联赛倒计时
            $is_cache['count_down'] = $stop - time();
            $is_cache['checkpoint'] = explode(',',$is_cache['checkpoint']);
            $is_cache['open'] = true;
            return $is_cache;
        }
        try{
            $res = Db::name('league_match')
                ->where('create_time','between',"$start,$stop")
                ->cache('league_match_data',$this->l_m_expire)
                ->find();
            if ($res){
                //联赛倒计时
                $res['count_down'] = $stop - time();
                $res['checkpoint'] = explode(',',$res['checkpoint']);
                $res['open'] = true;
            }
            return $res;
        }catch (Exception $e){
            return json(['data'=>false,'message'=>$e->getMessage(),'code'=>500]);
        }

    }

    /*
     * 添加新联赛关卡等数据
     * @param array $data
     * @return array 返回刚生成的数据
     */
    public function insertCheckpoint($data)
    {
        try{
            $insert_id = Db::name('league_match')->insertGetId($data);
            $res = Db::name('league_match')
                ->where('id',$insert_id)
                ->cache('league_match_data',$this->l_m_expire)
                ->find();
            $res['checkpoint'] = explode(',',$res['checkpoint']);
            $res['open'] = true;
            return $res;
        }catch (Exception $e){
            return json(['data'=>false,'message'=>$e->getMessage(),'code'=>500]);
        }
    }

    //清除所有缓存
    public function clearCache()
    {
        Cache::clear();
    }

}