<?php
// +----------------------------------------------------------------------
// | ThinkPHP [ WE CAN DO IT JUST THINK ]
// +----------------------------------------------------------------------
// | Copyright (c) 2006-2016 http://thinkphp.cn All rights reserved.
// +----------------------------------------------------------------------
// | Licensed ( http://www.apache.org/licenses/LICENSE-2.0 )
// +----------------------------------------------------------------------
// | Author: 流年 <liu21st@gmail.com>
// +----------------------------------------------------------------------

// 应用公共文件
/**
 * curl封装，用于获取微信接口信息
 * @param $url
 * @return mixed
 */
function ext_curl($url) {
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($ch, CURLOPT_HEADER, 0);
	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
	curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE);
	$result = curl_exec($ch);
	curl_close($ch);
	return $result;
}

/**
 * 必填参数检查
 * @param $map array
 * @return array
 */
function get_param($map) {
	$param = Request::param();
	if(isset($param['arrdata']) && !empty($param['arrdata'])){
		foreach ($param['arrdata'] as $key=>$value){
			$param[$key]=$value;
		}
	}
	$res = array();
	foreach ($map as $value) {
		if (isset($param[$value])) {
			$res[$value] = $param[$value];
		} else {
			die(json_encode(['data' => false, 'code' => 300, 'message' => '缺少参数' . $value],320));
		}
	}
	return $res;
}

//带参数 加密
function apiAudit($json){
	if (empty($json)) {
		die(json_encode(['code'=>400,'message'=>'请不要直接访问接口']));
	}
	$serverArray= json_decode($json,TRUE);
	if (empty($serverArray['sign'])) {
		die(json_encode(['code'=>400,'message'=>'没有签名信息-S-ERROR']));
	}
	$clientSign = $serverArray['sign'];
	$clientappid = $serverArray['appid'];
	$appid = config("paginate.appid");
	$secret = config("paginate.appscecret");
	if($clientappid != $appid){
		die(json_encode(['code'=>301,'message'=>'未知错误-A-ERROR']));
	}
	unset($serverArray['sign']);
	unset($serverArray['arrdata']);
	unset($serverArray['appid']);
	$arr = array();
	foreach ($serverArray as $key=>$value){
		$arr[$key] = $key;
	}
	sort($arr);  //字典序
	$str = "appid".$clientappid;
	foreach ($arr as $k => $v) {
		$str = $str.$arr[$k].$serverArray[$v];
	}
	$reserSign = $str.$secret;
	$reserSign = base64_encode($reserSign);
	$reserverSign = strtoupper(sha1($reserSign));

	if($clientSign!= $reserverSign){
		die(json_encode(['code'=>300,'message'=>'签名错误']));
	}else{

		// 验证通过
		return $serverArray;
	}
}

//对象存储公共函数
function base64Toimg($img_name,$image){
	require Env::get('extend_path').'/cos/cos-autoloader.php';
	$bucket = 'gamebox-1257007004';
	if (strstr($image, ",")) {
		$image = explode(',', $image);
		$image = $image[1];
	}
	$img_file = base64_decode($image);
	$cosClient = new \Qcloud\Cos\Client(array('region' => 'ap-guangzhou',
		'credentials'=> array(
			'secretId'    => 'AKIDT97rS6U8YvQEyqK7JZkBPYWYRHwUY3CA',
			'secretKey' => 'EICJseLF1e6d1EFMNEAHYKCvTq25QbEx')));

	try {
		$result = $cosClient->putObject(array(
			'Bucket' => $bucket,
			'Key' => $img_name,
			'Body' => $img_file,
		));
	} catch (\Exception $e) {
		// print_r("$e\n");
	}
	return $img_name;
}


/*
 * 限制传参为空
 * @param array or string $data
 */
function testing($data){
    if(is_array($data)){
        foreach ($data as $k){
            if ($k === '' || ($k == 'undefined' && $k != 0)){
                die(json_encode(['data'=>false,'message'=>'参数不能为空','code'=>403]));
            }
        }
    }else{
        if ($data === '' || ($data == 'undefined' && $data != 0)){
            die(json_encode(['data'=>false,'message'=>'参数不能为空','code'=>403]));
        }
    }
}

/*
* 检测是否符合标准
* @param array $data_arr   需检测的数据
* @param array $range_arr  允许出现的值   例[1,2,3]
* @param bool $tof  开启则只会返回true或false
*/
function restrict($data_arr,$range_arr,$tof=false){
    foreach ($data_arr as $k){
        if ($k === '' || $k === null || !in_array($k, $range_arr)){
            if ($tof){
                return false;
            }else{
                die(json_encode(['data'=>false,'message'=>'操作有误,数据不符合规则','code'=>403]));
            }
        }
    }
    return true;
}

/**
 * 获取用户openid
 * @param string $appid  对应小程序appid
 * @param string $secret 对应小程序secret
 * @param string $js_code 前端传
 * @return string
 */
function get_openid($appid='',$secret='',$js_code)
{
    if ($appid == ''){
        die([json_encode(['data'=>false,'message'=>'请填写小程序appid','code'=>400])]);
    }
    if ($secret == ''){
        die([json_encode(['data'=>false,'message'=>'请填写小程序secret','code'=>400])]);
    }
    $url = "https://api.weixin.qq.com/sns/jscode2session?appid=" . $appid ."&secret=". $secret ."&js_code=".$js_code."&grant_type=authorization_code";
    $res = file_get_contents($url);
    $info = json_decode($res,true);
    if (!isset($info['openid'])){
        die(json_encode(['date'=>$res,'message'=>'错了','Code'=>300]));
    }
    return $info['openid'];
}

/*
 * curl_post请求
 * url - 提交地址
 * data - 提交数据
 */
function curlPost($url,$data,$referer_url='',$cookieSuccess='',$cookie_jar='')
{
    $ch = curl_init ();
    curl_setopt ( $ch, CURLOPT_URL, $url );
    curl_setopt ( $ch, CURLOPT_POST, 1 );
    curl_setopt ( $ch, CURLOPT_HEADER, 0 );
    curl_setopt ( $ch, CURLOPT_RETURNTRANSFER, 1 );
    curl_setopt($ch,CURLOPT_SSL_VERIFYPEER,false);    //跳过证书验证
    curl_setopt($ch,CURLOPT_SSL_VERIFYHOST,false);    // 从证书中检查SSL加密算法是否存在
    if ($referer_url){
        curl_setopt($ch, CURLOPT_REFERER, $referer_url);      //模拟来路
    }
    if($cookieSuccess){
        curl_setopt($ch, CURLOPT_COOKIE, $cookieSuccess);     //使用上面获取的cookies
    }
    if ($cookie_jar){
        curl_setopt($ch, CURLOPT_COOKIEFILE, $cookie_jar);   //cookie_file
    }
    curl_setopt($ch, CURLOPT_COOKIEJAR, 'cookie.txt');//把返回来的cookie信息保存在$cookie_jar文件中
    curl_setopt ( $ch, CURLOPT_POSTFIELDS, $data );
    $response = curl_exec($ch);
    if (curl_errno($ch)) {
        die(json_encode(['data'=>false,'message'=>curl_error($ch),'code'=>500])); //若错误打印错误信息
    }
    curl_close($ch);    //关闭curl
    return $response;
}



