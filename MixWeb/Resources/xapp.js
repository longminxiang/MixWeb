window.$app = {notifications: {}};

$app.registerHandle = function(name, func) {
    $br(name, func);
};

/**
 * 返回上一级
 * @param {number} delta - 级数
 */
$app.navigateBack = function(delta) {
    $b("navigateBack").p({delta: delta}).c();
};

/**
 * 导航
 * @param {string} url - url
 */
$app.navigateTo = function(url) {
    if (url.search("http") == -1) {
        var baseURL = document.URL.match(/^http.*\/\/.*?\/.*?\//)[0];
        url = baseURL + url;
    }
    $b("navigateTo").p({url: url}).c();
};

/**
 * 设置页面配置
 * @param {Object} config - 配置
 */
$app.setViewConfig = function(config) {
    $b("setViewConfig").p(config).c();
};

/**
 * 显示文字HUD
 * @param {string} text - 文字
 * @param {Object} [opts] - 选项
 * @param {number} opts.delay - 延时
 * @param {boolean} opts.inBottom - 是否在底部
 */
$app.showTextHUD = function(text, opts) {
    if (opts) opts.text = text;
    else opts = {text: text};
    $b("showTextHUD").p(opts).c();
};

/**
 * 显示菊花
 */
$app.showHUD = function() {
    $b("showHUD").c();
};

/**
 * 隐藏菊花
 */
$app.hideHUD = function() {
    $b("hideHUD").c();
};

/**
 * Alert弹窗
 * @param {Object} opts - 选项
 * @param {string} opts.title - 标题
 * @param {string} opts.message - 消息
 * @param {string} opts.cancelTitle - 取消按钮标题
 * @param {string} opts.confirmTitle - 确认按钮标题
 * @param {alertCallback} cb - 回调函数
 * @callback alertCallback
 * @param {number} buttonIndex - 点击index
 */
$app.alert = function(opts, cb) {
    $b("showAlert").p(opts).c(cb);
};

/**
 * ActionSheet弹窗
 * @param {Object} opts - 选项
 * @param {string} opts.title - 标题
 * @param {string} opts.cancelTitle - 取消按钮标题
 * @param {[string]} opts.otherTitles - 其他按钮标题数组
 * @param {actionSheetCallback} cb - 回调函数
 * @callback actionSheetCallback
 * @param {number} buttonIndex - 点击index
 */
$app.actionSheet = function(opts) {
    $b("showActionSheet").p(opts).c();
};

/**
 * Popover弹窗
 * @param {string} url - url
 * @param {string} key - key
 */
$app.popover = function(url, key) {
    $b("popover").p({url: url, key: key}).c();
};

/**
 * 关闭Popover弹窗
 */
$app.dismissPopover = function(key) {
    $b("dismissPopover").p({key: key}).c();
};

/**
 * 设置缓存
 * @param {string} key key
 * @param {Object} obj 值
 */
$app.setStorage = function(key, obj) {
    $b("setStorage").p({key: key, obj: obj}).c();
    $app.cache[key] = obj;
};
$app.setCache = $app.setStorage;

/**
 * 获取缓存
 * @param {string} key key
 */
$app.getStorage = function(key) {
    return $app.cache[key];
};

/**
 * 网络请求
 * @param {string} url - url
 * @param {Object} opts - 选项
 * @param {string} opts.body - Body
 * @param {string} opts.method - GET/POST
 * @param {number} opts.timeoutInterval - 超时时间
 * @param {{key: string, value: string}} opts.headers - Headers
 * @param {requestCallback} cb - 回调函数
 * 
 * @callback requestCallback
 * @param {Object} data - 数据
 * @param {number} code - 返回码
 * @param {string} message - 返回消息
 */
$app.request = function(url, opts, cb) {
    if (opts) opts.url = url;
    else opts = {url: url};
    $b("request").p(opts).c(function(res) {
        try {
            var str = new window.Buffer(res.data, 'base64').toString('utf8');
            res.data = JSON.parse(str);
        }
        catch (error) {}
        if (typeof cb == "function") cb(res);
    });
};

/**
 * 打电话
 * @param {string} phoneNumber 电话号码
 */
$app.makePhoneCall = function(phoneNumber) {
    $b("makePhoneCall").p({phoneNumber: phoneNumber}).c();
};

/**
 * 设置系统剪贴板的内容
 * @param {string} data 内容
 */
$app.setClipboardData = function(data) {
    $b("setClipboardData").p({data: data}).c();
};

/**
 * 获取系统剪贴板的内容
 * @param {getClipboardDataCallback} cb - 回调函数
 * 
 * @callback getClipboardDataCallback
 * @param {string} data - 内容
 */
$app.getClipboardData = function(cb) {
    $b("getClipboardData").c(function(res) {
        if (typeof cb == "function") cb(res.data);
    });
};

/**
 * 设置屏幕亮度
 * @param {number} value 值
 */
$app.setScreenBrightness = function(value) {
    $b("setScreenBrightness").p({value: value}).c();
};

/**
 * 获取屏幕亮度
 * @param {getScreenBrightnessCallback} cb - 回调函数
 * 
 * @callback getScreenBrightnessCallback
 * @param {number} value - 值
 */
$app.getScreenBrightness = function(cb) {
    $b("getScreenBrightness").c(function(res) {
        if (typeof cb == "function") cb(res.value);
    });
};

/**
 * 开启计时器
 * @param {string} funcName - 执行函数名字
 * @param {number} timeinterval - 间隔时间
 * @param {boolean} repeats - 是否重复, 默认true
 */
$app.startTimer = function(funcName, timeinterval, repeats) {
    if (typeof repeats == "undefined") repeats = true;
    $b("startTimer").p({func: funcName, timeinterval: timeinterval, repeats: repeats}).c();
};

/**
 * 移除计时器
 */
$app.removeTimer = function() {
    $b("removeTimer").c();
};

/**
 * 注册通知
 * @param {string} name - 通知名字
 */
$app.registerNotification = function(name, cb) {
    $app.notifications[name] = cb;
};

/**
 * 推送通知
 * @param {string} name - 通知名字
 * @param {Object} data - 数据
 */
$app.postNotification = function(name, data) {
    $b("postNotification").p({name: name, data: data}).c();
};

/**
 * 选择图片
 * @param {number} count - 数量
 * @param {chooseImageCallback} cb - 回调函数
 * 
 * @callback chooseImageCallback
 * @param {[Object]} images - 图片
 */
$app.chooseImage = function(count, cb) {
    $b("chooseImage").p({count: count}).c(function(res) {
        if (typeof cb == "function") cb(res);
    });
};

/**
 * 预览图片
 * @param {[string]} urls - 图片链接数组
 * @param {number} index - 开始位置
 */
$app.previewImage = function(urls, index) {
    $b("previewImage").p({urls: urls, index: index}).c();
};

/**
 * 保存图片到相册
 * @param {string} url - 图片链接
 * @param {function} cb - 回调
 */
$app.saveImageToAlbum = function(url, cb) {
    $b("saveImageToAlbum").p({url: url}).c(cb);
};