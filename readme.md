## MixWeb

**让你的网页变成小程序**

### API

#### $app.navigateTo(url)

页面跳转

**输入:**

参数  | 类型 | 说明
--- | --- | ---
url | string | 链接,支持相对路径

**示例:**

	$app.navigateTo("http://baidu.com");
	$app.navigateTo("next");

#### $app.navigateBack(delta)

页面返回

**输入:**

参数  | 类型 | 说明
--- | --- | ---
delta | number | 链接

**示例:**

	$app.navigateBack();
	$app.navigateBack(2);

#### $app.setViewConfig(config)

页面设置

**输入:**

参数  | 类型 | 说明
--- | --- | ---
config | Object | 配置，参见Config段

**示例:**

	$app.setViewConfig({backgroundColor: "#FFF", navBar: {hidden: true}});

#### $app.showTextHUD(text, opts)

文字HUD

**输入:**

参数  | 类型 | 说明
--- | --- | ---
text | string | 内容
opts.delay | number | 显示时间, 毫秒，默认1000
opts.inBottom | boolean | 是否显示在底部

**示例:**

	$app.showTextHUD("Hello World", {inBottom: true});
	$app.showTextHUD({text: "Hello", delay: 1500});

#### $app.showHUD()

显示loading HUD

**示例:**

	$app.showHUD();
	
#### $app.hideHUD()

隐藏loading HUD

**示例:**

	$app.hideHUD();	

#### $app.alert(opts, cb)

show alert

**输入:**

参数  | 类型 | 说明
--- | --- | ---
opts.title | string | 标题
opts.message | string | 内容
opts.cancelTitle | string | 取消按钮标题
opts.confirmTitle | string | 确认按钮标题
cb(index) | function | 回调函数
cb~index | number | 点击项

**示例:**

	$app.alert({title: "Hello", message: "Hello World"}, function(index) {
		if (index == 1) {
			console.log("确定");
		}
	});
	
#### $app.actionSheet(opts, cb)

show actionSheet

**输入:**

参数  | 类型 | 说明
--- | --- | ---
opts.title | string | 标题
opts.message | string | 内容
opts.cancelTitle | string | 取消按钮标题
opts.otherTitles | [string] | 其他按钮标题数组
cb(index) | function | 回调函数
index | number | 点击项

**示例:**

	$app.actionSheet({title: "Hello", otherTitles: ["hello", "world"], function(index) {
		console.log(index);
	});

#### $app.popover(url, key)

弹出一个WebView

**输入:**

参数  | 类型 | 说明
--- | --- | ---
url | string | URL
key | string | key

**示例:**

	$app.popover("http://baidu.com", "baidu1");

#### $app.dismissPopover(key)

关闭WebView

**输入:**

参数  | 类型 | 说明
--- | --- | ---
key | string | key

**示例:**

	$app.dismissPopover("baidu1");

#### $app.setStorage(key, obj)

设置缓存

**输入:**

参数  | 类型 | 说明
--- | --- | ---
key | string | key
obj | Object | 值

**示例:**

	$app.setStorage("key1", {w: "hello world"});
	$app.setStorage("key2", "hello world");

#### $app.getStorage(key)

获取缓存

**输入:**

参数  | 类型 | 说明
--- | --- | ---
key | string | key

**示例:**

	var obj = $app.getStorage("key1");
	console.log(obj);

#### $app.request(url, opts, cb)

网络请求

**输入:**

参数  | 类型 | 说明
--- | --- | ---
url | string | URL
opts.body | string | 请求Body
opts.method | string | 请求方法, GET/POST
opts.timeoutInterval | number | 超时时间, 秒, 默认15
opts.headers | {key: string, value: string} | 请求头
cb(data, code, message) | function | 回调函数
data | Object | 响应数据
code | number | 返回码
message | string | 消息

**示例:**

	$app.request("http://t.weather.sojson.com/api/weather/city/101030100", function(data, code) {
		console.log(data);
	});

#### $app.makePhoneCall(phoneNumber)

打电话

**输入:**

参数  | 类型 | 说明
--- | --- | ---
phoneNumber | string | 电话号码

**示例:**

	$app.makePhoneCall("10086");

#### $app.setClipboardData(data)

设置系统剪贴板内容

**输入:**

参数  | 类型 | 说明
--- | --- | ---
data | string | 内容

**示例:**

	$app.setClipboardData("10086");

#### $app.getClipboardData(cb)

获取系统剪贴板的内容

**输入:**

参数  | 类型 | 说明
--- | --- | ---
cb(data) | functin | 回调函数
data | string | 内容

**示例:**

	$app.getClipboardData(function(data) {
		console.log(data);
	});

#### $app.setScreenBrightness(value)

设置屏幕亮度

**输入:**

参数  | 类型 | 说明
--- | --- | ---
value | number | 值

**示例:**

	$app.setScreenBrightness(0.5);

#### $app.getScreenBrightness(cb)

获取屏幕亮度

**输入:**

参数  | 类型 | 说明
--- | --- | ---
cb(value) | function | 回调函数
value | number | 值

**示例:**

	$app.getScreenBrightness(function(value) {
		console.log(value);
	});

#### $app.startTimer(funcName, timeinterval, repeats)

开启计时器

**输入:**

参数  | 类型 | 说明
--- | --- | ---
funcName | string | 要执行函数的名字
timeinterval | number | 间隔时间, 毫秒
repeats | number | 是否重复, 默认true

**示例:**

	$app.startTimer("window.worker", 2000);

#### $app.removeTimer()

移除计时器

**示例:**

	$app.removeTimer();

#### $app.registerNotification(name, cb)

注册通知, 可用于跨页面通讯

**输入:**

参数  | 类型 | 说明
--- | --- | ---
name | string | 通知名字
cb | function | 执行函数

**示例:**

	$app.registerNotification("helloNotification", function(data) {
		console.log(data);
	});

#### $app.postNotification(name, data)

推送通知, 可用于跨页面通讯

**输入:**

参数  | 类型 | 说明
--- | --- | ---
name | string | 通知名字
data | Object | 数据

**示例:**

	$app.postNotification("helloNotification", "hello world");

#### $app.chooseImage(count, cb)

选择图片

**输入:**

参数  | 类型 | 说明
--- | --- | ---
count | number | 最大数量
cb({images}) | function | 回调函数
images | [string] | 图片Base64数组

**示例:**

	$app.chooseImage(3, function(res) {
		console.log(res.images);
	});
	
#### $app.previewImage(urls, index)

预览图片

**输入:**

参数  | 类型 | 说明
--- | --- | ---
urls | [string] | 图片链接数组
index | number | 起始位置

**示例:**

	$app.previewImage(["https://gss0.bdstatic.com/5bVWsj_p_tVS5dKfpU_Y_D3/res/r/image/2019-03-19/ebf7053aa5a6b5b797147a032544d2af.jpg", "https://gss0.bdstatic.com/5bVWsj_p_tVS5dKfpU_Y_D3/res/r/image/2019-03-19/ddb6d9a8ad35dbd00c7c03724c0d9eed.jpg"]);

#### $app.saveImageToAlbum(url, cb)

保存图片到相册

**输入:**

参数  | 类型 | 说明
--- | --- | ---
url | string | 图片链接
cb | function | 回调函数

**示例:**

	$app.saveImageToAlbum("https://gss0.bdstatic.com/5bVWsj_p_tVS5dKfpU_Y_D3/res/r/image/2019-03-19/ebf7053aa5a6b5b797147a032544d2af.jpg", function(res) {
		if (res.success) {
			$app.showTextHUD("保存成功");
		}
	});


### Config


