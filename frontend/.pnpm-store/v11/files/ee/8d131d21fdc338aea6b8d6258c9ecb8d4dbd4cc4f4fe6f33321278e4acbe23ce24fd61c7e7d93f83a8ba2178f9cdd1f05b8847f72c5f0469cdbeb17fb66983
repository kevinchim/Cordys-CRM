var ww = (function (exports) {
  'use strict';

  const win = typeof window !== 'undefined' ? window : undefined;
  const doc = typeof document !== 'undefined' ? document : undefined;
  const nav = typeof navigator !== 'undefined' ? navigator : undefined;
  const loc = typeof location !== 'undefined' ? location : undefined;
  function getHref() {
      return loc?.href || '';
  }
  function getTitle() {
      return doc?.title || '';
  }

  const ua = nav?.userAgent || '';
  const platform = nav?.platform || '';
  const wecomVersion = ua?.match(/wxwork\/([\d.]+)/i)?.[1];
  const isWeCom = !!wecomVersion;
  const isWeChat = !isWeCom && /micromessenger/i.test(ua);
  const isAndroid = /\bAndroid\b/i.test(ua);
  const isWindows = /Win/i.test(platform);
  const { isIOS, isMac } = getAppleDeviceType();
  function getAppleDeviceType() {
      const maxTouchPoints = nav?.maxTouchPoints ?? 1;
      const isMac = /Mac/i.test(platform);
      // https://stackoverflow.com/questions/56934826/distinguish-between-ipad-and-mac-on-ipad-with-ipados
      if (isMac && maxTouchPoints > 2) {
          return {
              isMac: false,
              isIOS: true
          };
      }
      return {
          isMac,
          isIOS: /\b(iPhone|iPad|iPod)\b/i.test(ua)
      };
  }

  let registerOptions;
  let corpConfigTask;
  let agentConfigTask;
  function setRegisterOptions(options) {
      if (!options.corpId) {
          throw new Error('Missing corpId');
      }
      registerOptions = options;
  }
  function getRegisterOptions() {
      return registerOptions;
  }
  function getCorpConfigTask() {
      return corpConfigTask;
  }
  function setCorpConfigTask(task) {
      corpConfigTask = task;
  }
  function getCorpConfigParams() {
      return corpConfigTask?.getResult()?.params;
  }
  function getAgentConfigTask() {
      return agentConfigTask;
  }
  function setAgentConfigTask(task) {
      agentConfigTask = task;
  }
  function getAgentConfigParams() {
      return agentConfigTask?.getResult()?.params;
  }
  function getConfigParams() {
      const registerOptions = getRegisterOptions();
      if (isWeCom && registerOptions?.getAgentConfigSignature) {
          return getAgentConfigParams();
      }
      return getCorpConfigParams();
  }
  function getConfigCorpId() {
      const registerOptions = getRegisterOptions();
      if (isWeCom && registerOptions?.getAgentConfigSignature) {
          const params = getAgentConfigParams();
          return params?.corpid;
      }
      const params = getCorpConfigParams();
      return params?.appId;
  }
  /**
   * 获取 config 或 agentConfig 传入的相关参数
   *
   * 用于外部 sdk 调用私有方法
   */ function getVerifyParams() {
      const verifyParams = getConfigParams();
      if (!verifyParams) {
          return;
      }
      const corpId = getConfigCorpId();
      return {
          appId: corpId,
          verifyAppId: corpId,
          verifySignType: 'sha1',
          verifyTimestamp: verifyParams.timestamp,
          verifyNonceStr: verifyParams.nonceStr,
          verifySignature: verifyParams.signature
      };
  }

  const webToClientJsApiMap = {
      config: 'preVerifyJsApi',
      onMenuShareTimeline: 'menu:share:timeline',
      onMenuShareAppMessage: 'menu:share:appmessage',
      onMenuShareWechat: 'menu:share:wechat',
      onMenuShareQQ: 'menu:share:qq',
      onMenuShareWeibo: 'menu:share:weiboApp',
      onMenuShareQZone: 'menu:share:QZone',
      previewImage: 'imagePreview',
      getLocation: 'geoLocation',
      openProductSpecificView: 'openProductViewWithPid',
      addCard: 'batchAddCard',
      openCard: 'batchViewCard',
      chooseWXPay: 'getBrandWCPayRequest',
      openEnterpriseRedPacket: 'getRecevieBizHongBaoRequest',
      startSearchBeacons: 'startMonitoringBeacons',
      stopSearchBeacons: 'stopMonitoringBeacons',
      onSearchBeacons: 'onBeaconsInRange',
      consumeAndShareCard: 'consumedShareCard',
      openAddress: 'editAddress',
      getBrandWCPayRequest: 'getBrandWCPayRequest'
  };
  const clientToWebJsApiMap = {};
  for (const key of Object.keys(webToClientJsApiMap)){
      clientToWebJsApiMap[webToClientJsApiMap[key]] = key;
  }
  function mapJsApiNameToClient(name) {
      return webToClientJsApiMap[name] || name;
  }
  function mapJsApiNameToWeb(name) {
      return clientToWebJsApiMap[name] || name;
  }
  function mapJsApiListToClient(list) {
      return list.map(mapJsApiNameToClient);
  }

  function error(...args) {
      console.error('[wwsdk]', ...args);
  }

  const originalHref = getHref();
  /**
   * 两个 SemVer 相减，取差的符号
   */ function semverSubtract(v1, v2) {
      const v1Seg = v1?.split('.') || [];
      const v2Seg = v2?.split('.') || [];
      for(let i = 0, ii = Math.max(v1Seg.length, v2Seg.length); i < ii; i++){
          const v1Num = parseInt(v1Seg[i]) || 0;
          const v2Num = parseInt(v2Seg[i]) || 0;
          if (v1Num > v2Num) {
              return 1;
          }
          if (v1Num < v2Num) {
              return -1;
          }
      }
      return 0;
  }
  function arrayBufferToBase64(buffer) {
      if (typeof Buffer !== 'undefined') {
          return Buffer.from(buffer).toString('base64');
      }
      let binary = '';
      const bytes = new Uint8Array(buffer);
      const len = bytes.byteLength;
      for(let i = 0; i < len; i++){
          binary += String.fromCharCode(bytes[i]);
      }
      return btoa(binary);
  }
  function base64ToArrayBuffer(base64) {
      if (typeof Buffer !== 'undefined') {
          return Buffer.from(base64, 'base64').buffer;
      }
      const binary = atob(base64);
      const length = binary.length;
      const bytes = new Uint8Array(length);
      for(let i = 0; i < length; i++){
          bytes[i] = binary.charCodeAt(i);
      }
      return bytes.buffer;
  }
  function safeRun(fn, param, thisArg) {
      if (!isFunction(fn)) {
          return;
      }
      try {
          return fn.call(thisArg, param);
      } catch (error$1) {
          error(error$1);
      }
  }
  function startsWith(str, search) {
      return str.slice(0, search.length) === search;
  }
  function getSignURL(original) {
      if (original) {
          return originalHref.split('#')[0];
      }
      return getHref().split('#')[0];
  }
  function extractErrMsgKeyword(errMsg) {
      if (!isString(errMsg)) {
          return '';
      }
      return errMsg.slice(errMsg.indexOf(':') + 1);
  }
  function isFalsy(val) {
      return val === false || val === 0;
  }
  function isObject$1(val) {
      if (!val) {
          return false;
      }
      return typeof val === 'object';
  }
  function isFunction(val) {
      return typeof val === 'function';
  }
  function isString(val) {
      return typeof val === 'string';
  }
  function joinList(list) {
      if (!list) {
          return list;
      }
      if (isString(list)) {
          return list;
      }
      return list.join(';');
  }

  /**
   * WeixinJSBridge 是否已注入到 window
   */ exports.isWeixinJSBridgeReady = !!win?.WeixinJSBridge;
  /**
   * 等待 WeixinJSBridge 注入到 window
   */ exports.onWeixinJSBridgeReady = Promise.resolve();
  if (!exports.isWeixinJSBridgeReady) {
      exports.onWeixinJSBridgeReady = new Promise((resolve)=>{
          doc?.addEventListener('WeixinJSBridgeReady', ()=>{
              exports.isWeixinJSBridgeReady = true;
              resolve();
          });
      });
  }
  /**
   * 监听 JSSDK 未定义的事件
   *
   * @example
   * ```ts
   * ww.on('onBeaconsInRange', res => {
   *   console.log(res)
   * })
   * ```
   *
   * @param name 事件名称
   * @param callback 监听回调
   */ async function on(name, callback) {
      if (!exports.isWeixinJSBridgeReady) {
          await exports.onWeixinJSBridgeReady;
      }
      win.WeixinJSBridge.on(name, callback);
  }
  /**
   * 调用 JSSDK 未定义的 JSAPI
   *
   * @example
   * ```ts
   * ww.invoke('openEnterpriseChat', params, res => {
   *   console.log(res)
   * })
   * ```
   *
   * @param name JSAPI 名称
   * @param params JSAPI 参数
   * @param callback 回调函数
   * @returns JSAPI 返回值
   */ async function invoke(name, params = {}, callback) {
      if (!exports.isWeixinJSBridgeReady) {
          await exports.onWeixinJSBridgeReady;
      }
      const result = await new Promise((resolve)=>{
          const fullParams = {
              ...params,
              ...getVerifyParams()
          };
          win.WeixinJSBridge.invoke(name, fullParams, resolve);
      });
      if (!result.errMsg) {
          result.errMsg = formatErrMsg(name, result.err_msg || result.errmsg);
      }
      const keyword = extractErrMsgKeyword(result.errMsg);
      if (result.errCode == null) {
          if (result.err_code != null) {
              result.errCode = result.err_code;
          } else {
              result.errCode = keyword === 'ok' ? 0 : -1;
          }
      }
      safeRun(callback, result);
      if (keyword !== 'ok' && keyword !== 'yes') {
          throw result;
      }
      return result;
  }
  function formatErrMsg(name, errMsg) {
      const apiName = mapJsApiNameToWeb(name);
      if (!errMsg) {
          return `${apiName}:ok`;
      }
      let keyword = extractErrMsgKeyword(errMsg);
      if (keyword === 'confirm') {
          keyword = 'ok';
      }
      if (keyword === 'failed') {
          keyword = 'fail';
      }
      if (startsWith(keyword, 'failed_')) {
          keyword = keyword.slice(7);
      }
      if (startsWith(keyword, 'fail_')) {
          keyword = keyword.slice(5);
      }
      keyword = keyword.replace(/_/g, '').toLowerCase();
      if (keyword === 'access denied' || keyword === 'no permission to execute') {
          keyword = 'permission denied';
      }
      if (apiName === 'config' && keyword === 'function not exist') {
          keyword = 'ok';
      }
      if (!keyword) {
          keyword = 'fail';
      }
      return `${apiName}:${keyword}`;
  }

  class SDKError extends Error {
      constructor(message){
          super(`SDK Error: ${message}`);
      }
  }
  class AbortError extends SDKError {
      constructor(){
          super('Aborted');
      }
  }

  function _define_property(obj, key, value) {
      if (key in obj) {
          Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true });
      } else obj[key] = value;

      return obj;
  }

  const CONFIG_TYPE_CORP = 1;
  const CONFIG_TYPE_AGENT = 2;
  class ConfigTask {
      checkValid() {
          if (isWeCom && this.url !== getSignURL(this.useOriginalURL)) {
              this.error = new AbortError();
          }
          return !this.error;
      }
      getResult() {
          if (this.checkValid()) {
              return this.result;
          }
      }
      async awaitPromise(promise) {
          try {
              this.result = await promise;
              return this.result;
          } catch (error) {
              this.error = error;
              throw error;
          }
      }
      constructor(type, factory){
          _define_property(this, "type", void 0);
          _define_property(this, "url", void 0);
          _define_property(this, "promise", void 0);
          _define_property(this, "result", void 0);
          _define_property(this, "error", void 0);
          _define_property(this, "useOriginalURL", void 0);
          this.type = type;
          this.useOriginalURL = isWeChat && !isWindows && !isMac && type === CONFIG_TYPE_CORP;
          this.url = getSignURL(this.useOriginalURL);
          this.promise = this.awaitPromise(factory(this.url));
      }
  }

  /**
   * 触发或等待 config 返回
   */ async function ensureCorpConfigReady() {
      const originalTask = getCorpConfigTask();
      if (originalTask?.checkValid()) {
          return originalTask.promise;
      }
      const task = new ConfigTask(CONFIG_TYPE_CORP, async (url)=>{
          const registerOptions = getRegisterOptions();
          if (!registerOptions?.getConfigSignature) {
              throw new SDKError('Missing getConfigSignature');
          }
          // 1. 获取 config 签名参数
          const data = await registerOptions.getConfigSignature(url);
          if (!task.checkValid()) {
              throw new AbortError();
          }
          // 2. 构建参数
          const params = buildCorpConfigParams(registerOptions, data);
          // 3. 调用 JSAPI
          const result = await invoke('preVerifyJSAPI', {
              appId: params.appId,
              verifyJsApiList: params.jsApiList,
              verifyOpenTagList: params.openTagList,
              verifyAppId: params.appId,
              verifySignType: 'sha1',
              verifyTimestamp: params.timestamp,
              verifyNonceStr: params.nonceStr,
              verifySignature: params.signature
          });
          if (!task.checkValid()) {
              throw new AbortError();
          }
          return {
              params,
              result
          };
      });
      task.promise.then((res)=>{
          const registerOptions = getRegisterOptions();
          safeRun(registerOptions?.onConfigSuccess, res.result);
          safeRun(registerOptions?.onConfigComplete, res.result);
      }, (error)=>{
          const registerOptions = getRegisterOptions();
          safeRun(registerOptions?.onConfigFail, error);
          safeRun(registerOptions?.onConfigComplete, error);
      });
      setCorpConfigTask(task);
      return task.promise;
  }
  function buildCorpConfigParams(options, data) {
      return {
          appId: options.corpId,
          timestamp: `${data.timestamp}`,
          nonceStr: data.nonceStr,
          signature: data.signature,
          jsApiList: mapJsApiListToClient(options.jsApiList || [
              'config'
          ]),
          openTagList: mapJsApiListToClient(options.openTagList || [])
      };
  }

  /**
   * 触发或等待 agentConfig 返回
   */ async function ensureAgentConfigReady() {
      const originalTask = getAgentConfigTask();
      if (originalTask?.checkValid()) {
          return originalTask.promise;
      }
      const task = new ConfigTask(CONFIG_TYPE_AGENT, async (url)=>{
          // 1. 若为低版本企业微信，agentConfig 需要在 config 成功后执行
          let configPromise;
          if (isWeCom && semverSubtract(wecomVersion, '3.0.24') < 0) {
              configPromise = ensureCorpConfigReady();
          }
          // 2. 等待 config 成功的时候同时获取 agentConfig 签名参数
          const [params] = await Promise.all([
              resolveAgentConfigParams(url),
              configPromise
          ]);
          if (!task.checkValid()) {
              throw new AbortError();
          }
          // 4. 调用 JSAPI
          const result = await invoke('agentConfig', params);
          if (!task.checkValid()) {
              throw new AbortError();
          }
          return {
              params,
              result
          };
      });
      task.promise.then((res)=>handleAgentConfigSuccess(res.result), (error)=>handleAgentConfigFail(error));
      setAgentConfigTask(task);
      return task.promise;
  }
  async function resolveAgentConfigParams(url) {
      const registerOptions = getRegisterOptions();
      if (!registerOptions?.getAgentConfigSignature) {
          throw new SDKError('Missing getAgentConfigSignature');
      }
      const data = await registerOptions.getAgentConfigSignature(url);
      return {
          corpid: registerOptions.corpId,
          agentid: `${registerOptions.agentId}`,
          timestamp: `${data.timestamp}`,
          nonceStr: data.nonceStr,
          signature: data.signature,
          jsApiList: mapJsApiListToClient(registerOptions.jsApiList || [
              'agentConfig'
          ])
      };
  }
  function handleAgentConfigSuccess(result) {
      const registerOptions = getRegisterOptions();
      safeRun(registerOptions?.onAgentConfigSuccess, result);
      safeRun(registerOptions?.onAgentConfigComplete, result);
  }
  function handleAgentConfigFail(error) {
      const registerOptions = getRegisterOptions();
      safeRun(registerOptions?.onAgentConfigFail, error);
      safeRun(registerOptions?.onAgentConfigComplete, error);
  }

  /**
   * 触发或等待 config、agentConfig 完成
   *
   * @example
   * ```ts
   * await ww.ensureConfigReady()
   * ```
   */ function ensureConfigReady() {
      const registerOptions = getRegisterOptions();
      if (isWeCom && registerOptions?.getAgentConfigSignature) {
          return ensureAgentConfigReady();
      }
      return ensureCorpConfigReady();
  }
  /**
   * 在提供了 registerOptions 的情况下保证 config、agentConfig 完成
   *
   * @private
   */ function tryEnsureConfigReady() {
      const registerOptions = getRegisterOptions();
      if (!registerOptions) {
          return;
      }
      if (isWeCom && registerOptions.getAgentConfigSignature) {
          return ensureAgentConfigReady();
      }
      if (registerOptions.getConfigSignature) {
          return ensureCorpConfigReady();
      }
  }

  /**
   * 注册应用信息。
   *
   * @example
   * ```ts
   * ww.register({
   *   corpId: 'ww7ca4776b2a70000',
   *   jsApiList: ['getExternalContact'],
   *   getConfigSignature
   * })
   * ```
   */ function register(options) {
      setRegisterOptions(options);
      if (isWeChat || isWeCom) {
          tryEnsureConfigReady();
      }
  }

  /**
   * 透传 JSAPI 调用
   */ async function passthrough(name, params, jsapiParams = params) {
      return promiseToCallback(params, async ()=>{
          await tryEnsureConfigReady();
          return invoke(name, jsapiParams);
      });
  }
  /**
   * 绑定事件
   */ async function bindShare(name, params, handler) {
      await tryEnsureConfigReady();
      on(name, ()=>{
          promiseToCallback(params, handler);
      });
  }
  /**
   * 把 promise 转为 success/fail callbacak 回调
   */ function promiseToCallback(params, factory) {
      return factory(params).then((result)=>{
          safeRun(params?.success, result);
          safeRun(params?.complete, result);
          return result;
      }, (error)=>{
          const keyword = extractErrMsgKeyword(error.errMsg);
          if (keyword === 'cancel') {
              safeRun(params?.cancel, error);
          } else {
              safeRun(params?.fail, error);
          }
          safeRun(params?.complete, error);
          throw error;
      });
  }

  var Proximity = /*#__PURE__*/ function(Proximity) {
      /**
     * CLProximityUnknown
     */ Proximity["CLProximityUnknown"] = "0";
      /**
     * CLProximityImmediate
     */ Proximity["CLProximityImmediate"] = "1";
      /**
     * CLProximityNear
     */ Proximity["CLProximityNear"] = "2";
      /**
     * CLProximityFar
     */ Proximity["CLProximityFar"] = "3";
      return Proximity;
  }({});
  /**
   * 开启查找周边 iBeacon 设备。
   *
   * @see https://developers.weixin.qq.com/doc/offiaccount/OA_Web_Apps/JS-SDK.html
   * @compat WeChat
   */ function startSearchBeacons(params = {}) {
      return passthrough('startMonitoringBeacons', params);
  }
  /**
   * 关闭查找周边 iBeacon 设备。
   *
   * @see https://developers.weixin.qq.com/doc/offiaccount/OA_Web_Apps/JS-SDK.html
   * @compat WeChat
   */ function stopSearchBeacons(params = {}) {
      return passthrough('stopMonitoringBeacons', params);
  }
  /**
   * 监听周边 iBeacon 设备接口。
   *
   * @see https://developers.weixin.qq.com/doc/offiaccount/OA_Web_Apps/JS-SDK.html
   * @compat WeChat
   */ function onSearchBeacons(callback) {
      on('onBeaconsInRange', callback);
  }

  /**
   * 连接低功耗蓝牙设备。
   *
   * @note
   * - 安卓手机上如果多次调用 createBLEConnection 创建连接，有可能导致系统持有同一设备多个连接的实例，导致调用 closeBLEConnection 的时候并不能真正的断开与设备的连接。因此请保证尽量成对的调用 create 和 close 接口
   * - 蓝牙链接随时可能断开，建议监听 onBLEConnectionStateChange 回调事件，当蓝牙设备断开时按需执行重连操作
   * - 若对未连接的设备或已断开连接的设备调用数据读写操作的接口，会返回 10006 错误，建议进行重连操作
   *
   * @compat WeCom
   *
   * @example
   * ```ts
   * ww.createBLEConnection({
   *   deviceId: deviceId
   * })
   * ```
   */ function createBLEConnection(params) {
      return passthrough('createBLEConnection', params);
  }
  /**
   * 断开与低功耗蓝牙设备的连接。
   *
   * @compat WeCom
   *
   * @example
   * ```ts
   * ww.closeBLEConnection({
   *   deviceId: deviceId
   * })
   * ```
   */ function closeBLEConnection(params) {
      return passthrough('closeBLEConnection', params);
  }
  /**
   * 监听低功耗蓝牙连接状态的改变事件，包括开发者主动连接或断开连接，设备丢失，连接异常断开等等。
   *
   * @compat WeCom
   *
   * @example
   * ```ts
   * ww.onBLEConnectionStateChange(function(event) {
   *   console.log(event)
   * })
   * ```
   */ function onBLEConnectionStateChange(callback) {
      on('onBLEConnectionStateChange', callback);
  }
  /**
   * 获取蓝牙设备所有 service（服务）。
   *
   * @compat WeCom
   *
   * @example
   * ```ts
   * ww.getBLEDeviceServices({
   *   deviceId: deviceId
   * })
   * ```
   */ function getBLEDeviceServices(params) {
      return passthrough('getBLEDeviceServices', params);
  }
  /**
   * 获取蓝牙设备某个服务中的所有 characteristic（特征值）。
   *
   * @compat WeCom
   *
   * @example
   * ```ts
   * ww.getBLEDeviceCharacteristics({
   *   deviceId: deviceId,
   *   serviceId: serviceId
   * })
   * ```
   */ function getBLEDeviceCharacteristics(params) {
      return passthrough('getBLEDeviceCharacteristics', params);
  }
  /**
   * 读取低功耗蓝牙设备的特征值的二进制数据值。
   *
   * @note
   * - 设备的特征值必须支持 read 才可以成功调用，具体参照 characteristic 的 properties 属性
   * - 并行调用多次读写接口存在读写失败的可能性
   * - 接口读取到的信息需要在 onBLECharacteristicValueChange 的回调中获取
   *
   * @compat WeCom
   *
   * @example
   * ```ts
   * ww.readBLECharacteristicValue({
   *   deviceId: deviceId,
   *   serviceId: serviceId,
   *   characteristicId: characteristicId
   * })
   * ```
   */ function readBLECharacteristicValue(params) {
      return passthrough('readBLECharacteristicValue', params);
  }
  /**
   * 向低功耗蓝牙设备特征值中写入二进制数据。
   *
   * @note
   * - 设备的特征值必须支持 write 才可以成功调用，具体参照 characteristic 的 properties 属性
   * - 并行调用多次读写接口存在读写失败的可能性
   * - 接口不会对写入数据包大小做限制，但系统与蓝牙设备会确定蓝牙 4.0 单次传输的数据大小，超过最大字节数后会发生写入错误，建议每次写入不超过 20 字节
   * - 安卓平台上，在调用 notify 成功后立即调用 write 接口，在部分机型上会发生 10008 系统错误
   * - 若单次写入数据过长，iOS 平台上存在系统不会有任何回调的情况（包括错误回调）
   *
   * @compat WeCom
   *
   * @example
   * ```ts
   * ww.writeBLECharacteristicValue({
   *   deviceId: deviceId,
   *   serviceId: serviceId,
   *   characteristicId: characteristicId,
   *   value: arrayBufferValue
   * })
   * ```
   */ function writeBLECharacteristicValue(params) {
      return passthrough('writeBLECharacteristicValue', params, {
          deviceId: params.deviceId,
          serviceId: params.serviceId,
          characteristicId: params.characteristicId,
          value: arrayBufferToBase64(params.value)
      });
  }
  /**
   * 启用低功耗蓝牙设备特征值变化时的 notify 功能，订阅特征值。
   *
   * @note
   * - 设备的特征值必须支持 notify 或者 indicate 才可以成功调用，具体参照 characteristic 的 properties 属性
   * - 订阅操作成功后需要设备主动更新特征值的 value 才会触发 onBLECharacteristicValueChange 回调
   * - 安卓平台上，在调用 notify 成功后立即调用 write 接口，在部分机型上会发生 10008 系统错误
   *
   * @compat WeCom
   *
   * @example
   * ```ts
   * ww.notifyBLECharacteristicValueChange({
   *   deviceId: deviceId,
   *   serviceId: serviceId,
   *   characteristicId: characteristicId,
   *   state: true
   * })
   * ```
   */ function notifyBLECharacteristicValueChange(params) {
      return passthrough('notifyBLECharacteristicValueChange', params);
  }
  /**
   * 监听低功耗蓝牙设备的特征值变化。
   *
   * 必须先启用 notify 才能接收到设备推送的 notification。
   *
   * @compat WeCom
   *
   * @example
   * ```ts
   * ww.onBLECharacteristicValueChange(function(event) {
   *   console.log(event)
   * })
   * ```
   */ function onBLECharacteristicValueChange(callback) {
      on('onBLECharacteristicValueChange', (event)=>{
          if (typeof event?.value === 'string') {
              event.value = base64ToArrayBuffer(event.value);
          }
          callback(event);
      });
  }

  /**
   * 初始化蓝牙模块。
   *
   * @compat WeCom
   *
   * @example
   * ```ts
   * ww.openBluetoothAdapter()
   * ```
   */ function openBluetoothAdapter(params = {}) {
      return passthrough('openBluetoothAdapter', params);
  }
  /**
   * 关闭蓝牙模块。
   *
   * @note
   * - 调用该方法将断开所有已建立的链接并释放系统资源
   *
   * @compat WeCom
   *
   * @example
   * ```ts
   * ww.closeBluetoothAdapter()
   * ```
   */ function closeBluetoothAdapter(params = {}) {
      return passthrough('closeBluetoothAdapter', params);
  }
  /**
   * 获取本机蓝牙适配器状态。
   *
   * @compat WeCom
   *
   * @example
   * ```ts
   * ww.getBluetoothAdapterState()
   * ```
   */ function getBluetoothAdapterState(params = {}) {
      return passthrough('getBluetoothAdapterState', params);
  }
  /**
   * 监听蓝牙适配器状态变化。
   *
   * @compat WeCom
   *
   * @example
   * ```ts
   * ww.onBluetoothAdapterStateChange(function(event) {
   *   console.log(event)
   * })
   * ```
   */ function onBluetoothAdapterStateChange(callback) {
      on('onBluetoothAdapterStateChange', callback);
  }
  /**
   * 开始搜寻附近的蓝牙外围设备。
   *
   * @compat WeCom
   *
   * @example
   * ```ts
   * ww.startBluetoothDevicesDiscovery({
   *   services: ['FEE7']
   * })
   * ```
   */ function startBluetoothDevicesDiscovery(params = {}) {
      return passthrough('startBluetoothDevicesDiscovery', params);
  }
  /**
   * 停止搜寻附近的蓝牙外围设备。
   *
   * 若已经找到需要的蓝牙设备并不需要继续搜索时，建议调用该接口停止蓝牙搜索。
   *
   * @compat WeCom
   *
   * @example
   * ```ts
   * ww.stopBluetoothDevicesDiscovery()
   * ```
   */ function stopBluetoothDevicesDiscovery(params = {}) {
      return passthrough('stopBluetoothDevicesDiscovery', params);
  }
  /**
   * 获取在蓝牙模块生效期间所有已发现的蓝牙设备。
   *
   * @note
   * - 该接口获取到的设备列表为蓝牙模块生效期间所有搜索到的蓝牙设备，若在蓝牙模块使用流程结束后未及时调用 closeBluetoothAdapter 释放资源，调用该接口可能会返回之前蓝牙使用流程中搜索到的蓝牙设备，可能设备已经不在用户身边，无法连接
   * - 蓝牙设备在被搜索到时，系统返回的 name 字段一般为广播包中的 LocalName 字段中的设备名称，而如果与蓝牙设备建立连接，系统返回的 name 字段会改为从蓝牙设备上获取到的 GattName。若需要动态改变设备名称并展示，建议使用 localName 字段
   *
   * @compat WeCom
   *
   * @example
   * ```ts
   * ww.getBluetoothDevices()
   * ```
   */ function getBluetoothDevices(params = {}) {
      return promiseToCallback(params, async ()=>{
          await tryEnsureConfigReady();
          const res = await invoke('getBluetoothDevices');
          for (const device of res.devices || []){
              normalizeBluetoothDevice(device);
          }
          return res;
      });
  }
  /**
   * 监听寻找到新设备。
   *
   * @note
   * - 若在该接口中回调了某个设备，则此设备会添加到 getBluetoothDevices 接口返回的设备列表中
   *
   * @compat WeCom
   *
   * @example
   * ```ts
   * ww.onBluetoothDeviceFound(function(event) {
   *   console.log(event)
   * })
   * ```
   */ function onBluetoothDeviceFound(callback) {
      on('onBluetoothDeviceFound', (res)=>{
          for (const device of res.devices || []){
              normalizeBluetoothDevice(device);
          }
          callback(res);
      });
  }
  /**
   * 根据 uuid 获取处于已连接状态的设备。
   *
   * @compat WeCom
   *
   * @example
   * ```ts
   * ww.getConnectedBluetoothDevices({
   *   services: ['FEE7']
   * })
   * ```
   */ function getConnectedBluetoothDevices(params) {
      return passthrough('getConnectedBluetoothDevices', params);
  }
  function normalizeBluetoothDevice(device) {
      if (typeof device.advertisData === 'string') {
          device.advertisData = base64ToArrayBuffer(device.advertisData);
      }
      /**
     * @desc 客户端返回字段为 serviceDataV2，sdk 统一转换为 serviceData 字段后对外返回
     */ if (device.serviceDataV2) {
          const finalServiceData = device.serviceDataV2;
          for (const key of Object.keys(finalServiceData)){
              if (typeof finalServiceData[key] === 'string') {
                  finalServiceData[key] = base64ToArrayBuffer(finalServiceData[key]);
              }
          }
          device.serviceData = finalServiceData;
          delete device.serviceDataV2;
      }
  }

  /**
   * 设置系统剪贴板的内容。
   *
   * @compat WeCom iOS, Android >= 2.4.16; WeCom PC, Mac >= 3.1.2
   *
   * @example
   * ```ts
   * ww.setClipboardData({
   *   data: 'data'
   * })
   * ```
   */ function setClipboardData(params) {
      return passthrough('setClipboardData', params);
  }
  /**
   * 获取系统剪贴板内容。
   *
   * @compat WeCom >= 3.1.2
   *
   * @example
   * ```ts
   * ww.getClipboardData()
   * ```
   */ function getClipboardData(params = {}) {
      return passthrough('getClipboardData', params);
  }

  /**
   * 开始搜索附近的 iBeacon 设备。
   *
   * @compat WeCom
   *
   * @example
   * ```ts
   * ww.startBeaconDiscovery({
   *   uuids: ['uuid']
   * })
   * ```
   */ function startBeaconDiscovery(params) {
      return passthrough('startBeaconDiscovery', params);
  }
  /**
   * 停止搜索附近的 iBeacon 设备。
   *
   * @compat WeCom
   *
   * @example
   * ```ts
   * ww.stopBeaconDiscovery()
   * ```
   */ function stopBeaconDiscovery(params = {}) {
      return passthrough('stopBeaconDiscovery', params);
  }
  /**
   * 获取所有已搜索到的 iBeacon 设备。
   *
   * @compat WeCom
   *
   * @example
   * ```ts
   * ww.getBeacons()
   * ```
   */ function getBeacons(params = {}) {
      return passthrough('getBeacons', params);
  }
  /**
   * 监听 iBeacon 设备的更新事件。
   *
   * @compat WeCom
   *
   * @example
   * ```ts
   * ww.onBeaconUpdate(function(event) {
   *   console.log(event)
   * })
   * ```
   */ function onBeaconUpdate(callback) {
      on('onBeaconUpdate', callback);
  }
  /**
   * 监听 iBeacon 服务的状态变化。
   *
   * @compat WeCom
   *
   * @example
   * ```ts
   * ww.onBeaconServiceChange(function(event) {
   *   console.log(event)
   * })
   * ```
   */ function onBeaconServiceChange(callback) {
      on('onBeaconServiceChange', callback);
  }

  var LocationType = /*#__PURE__*/ function(LocationType) {
      /**
     * gps 坐标
     */ LocationType["wgs84"] = "wgs84";
      /**
     * 火星坐标
     */ LocationType["gcj02"] = "gcj02";
      return LocationType;
  }({});
  /**
   * 使用企业微信内置地图查看位置。
   *
   * @example
   * ```ts
   * ww.openLocation({
   *   latitude: 0,
   *   longitude: 0,
   *   name: 'name',
   *   address: 'address',
   *   scale: 1
   * })
   * ```
   */ function openLocation(params) {
      return passthrough('openLocation', params, {
          latitude: params.latitude,
          longitude: params.longitude,
          name: params.name || '',
          address: params.address || '',
          scale: params.scale || 28,
          infoUrl: params.infoUrl || ''
      });
  }
  /**
   * 获取地理位置。
   *
   * @example
   * ```ts
   * ww.getLocation({
   *   type: 'wgs84'
   * })
   * ```
   */ function getLocation(params = {}) {
      return promiseToCallback(params, async ()=>{
          await tryEnsureConfigReady();
          const res = await invoke('geoLocation', {
              type: params.type || 'wgs84'
          });
          delete res.type;
          return res;
      });
  }
  /**
   * 打开持续定位。
   *
   * @compat WeCom >= 2.4.20
   *
   * @example
   * ```ts
   * ww.startAutoLBS({
   *   type: 'gcj02'
   * })
   * ```
   */ function startAutoLBS(params) {
      return passthrough('startAutoLBS', params);
  }
  /**
   * 停止持续定位。
   *
   * @compat WeCom >= 2.4.20
   *
   * @example
   * ```ts
   * ww.stopAutoLBS()
   * ```
   */ function stopAutoLBS(params = {}) {
      return passthrough('stopAutoLBS', params);
  }
  /**
   * 监听地理位置的变化。
   *
   * @limit
   * - 需要提前调用 startAutoLBS
   * - 需要用户停留在当前页面
   *
   * @compat WeCom >= 2.4.20
   *
   * @example
   * ```ts
   * ww.onLocationChange(function(event) {
   *   console.log(event)
   * })
   * ```
   *
   * @throws
   * | errMsg | 说明 | 兼容性 |
   * | --- | --- | --- |
   * | auto:location:report:ok | 执行成功 | |
   * | auto:location:report:fail, gps closed. | 用户关闭了 GPS | 企业微信 3.0.26 |
   */ function onLocationChange(callback) {
      on('auto:location:report', callback);
  }

  var NetworkType = /*#__PURE__*/ function(NetworkType) {
      /**
     * wifi
     */ NetworkType["wifi"] = "wifi";
      /**
     * 2g
     */ NetworkType["network2g"] = "2g";
      /**
     * 3g
     */ NetworkType["network3g"] = "3g";
      /**
     * 4g
     */ NetworkType["network4g"] = "4g";
      /**
     * edge
     */ NetworkType["networkEdge"] = "edge";
      /**
     * wwan
     */ NetworkType["networkWwan"] = "wwan";
      /**
     * 无网络
     */ NetworkType["none"] = "none";
      /**
     * Android下不常见的网络类型
     */ NetworkType["unknown"] = "unknown";
      return NetworkType;
  }({});
  /**
   * 获取网络状态。
   *
   * @compat WeCom iOS, Android; WeChat
   *
   * @example
   * ```ts
   * ww.getNetworkType()
   * ```
   */ function getNetworkType(params = {}) {
      return promiseToCallback(params, async ()=>{
          await tryEnsureConfigReady();
          try {
              const commRes = await invoke('getNetworkType', params);
              return commRes;
          } catch (errRes) {
              if (errRes?.subtype) {
                  return {
                      errMsg: 'getNetworkType:ok',
                      errCode: 0,
                      networkType: errRes.subtype
                  };
              }
              const index = errRes?.errMsg?.indexOf(':');
              const keyword = errRes?.errMsg?.substring(index + 1);
              if ([
                  'wifi',
                  'edge',
                  'wwan'
              ].includes(keyword)) {
                  return {
                      errMsg: 'getNetworkType:ok',
                      errCode: 0,
                      networkType: keyword
                  };
              }
              throw {
                  errMsg: 'getNetworkType:fail',
                  errCode: -1
              };
          }
      });
  }
  /**
   * 监听网络状态变化。
   *
   * @compat WeCom iOS, Android
   *
   * @example
   * ```ts
   * ww.onNetworkStatusChange(function(event) {
   *   console.log(event)
   * })
   * ```
   */ function onNetworkStatusChange(callback) {
      on('onNetworkStatusChange', callback);
  }

  /**
   * 初始化 Wi-Fi 模块。
   *
   * @compat WeCom iOS, Android >= 2.4.16
   *
   * @example
   * ```ts
   * ww.startWifi()
   * ```
   */ function startWifi(params = {}) {
      return passthrough('startWifi', params);
  }
  /**
   * 关闭 Wi-Fi 模块。
   *
   * @compat WeCom iOS, Android >= 2.4.16
   *
   * @example
   * ```ts
   * ww.stopWifi()
   * ```
   */ function stopWifi(params = {}) {
      return passthrough('stopWifi', params);
  }
  /**
   * 连接 Wi-Fi。
   *
   * @compat WeCom iOS, Android >= 2.4.16
   *
   * @example
   * ```ts
   * ww.connectWifi({
   *   SSID: 'vincenthome',
   *   BSSID: '8c:a6:df:c8:f7:4b',
   *   password: 'test1234',
   * })
   * ```
   */ function connectWifi(params) {
      return passthrough('connectWifi', params);
  }
  /**
   * 获取 Wi-Fi 列表。
   *
   * @compat WeCom iOS, Android >= 2.4.16
   *
   * @example
   * ```ts
   * ww.getWifiList()
   * ```
   */ function getWifiList(params = {}) {
      return passthrough('getWifiList', params);
  }
  /**
   * 监听 Wi-Fi 列表更新。
   *
   * @compat WeCom Android >= 2.4.16
   *
   * @example
   * ```ts
   * ww.onGetWifiList(function(event) {
   *   console.log(event)
   * })
   * ```
   */ function onGetWifiList(callback) {
      on('onGetWifiList', callback);
  }
  /**
   * 监听 Wi-Fi 连接成功。
   *
   * @compat WeCom iOS, Android >= 2.4.16
   *
   * @example
   * ```ts
   * ww.onWifiConnected(function(event) {
   *   console.log(event)
   * })
   * ```
   */ function onWifiConnected(callback) {
      on('onWifiConnected', callback);
  }
  /**
   * 获取已连接中的 Wi-Fi 信息。
   *
   * @compat WeCom iOS, Android >= 2.4.16
   *
   * @example
   * ```ts
   * ww.getConnectedWifi()
   * ```
   */ function getConnectedWifi(params = {}) {
      return passthrough('getConnectedWifi', params);
  }

  /**
   * 预览文件
   *
   * @compat WeCom iOS, Android
   *
   * @note
   * 本接口将 URL 对应的文件下载后，在内置浏览器中预览。目前支持图片、音频、视频、文档等格式的文件。
   * 从 2.4.6 版本开始，iOS 版企业微信浏览器升级为 WkWebView，企业微信原生层面的网络请求读取不到WKWebview中设置的cookie，即使域名是相同的。
   * **问题说明：**
   * 如果页面的资源或图片存储的服务器依赖校验Cookie来返回数据的情况，在切换到WKWebview后，在企业微信内长按保存，或者点击预览文件时，原生层面发起的网络请求将不会完整地带上所设置的Cookie，会导致图片保存失败或预览失败。
   * **适配建议：**
   * 建议静态资源cookie free。如果确实有信息需要传递，可通过业务后台存储需要传递的信息，然后给页面一个存储信息相对应的access_token加密码，再通过Url中加入自己业务的access_token进行页面间信息传递。
   *
   * @example
   * ```ts
   * ww.previewFile({
   *   url: 'http://open.work.weixin.qq.com/wwopen/downloadfile/wwapi.zip',
   *   name: 'Android开发工具包集合',
   *   size: 22189
   * })
   * ```
   */ function previewFile(params) {
      return passthrough('previewFile', params);
  }
  var ChooseMessageFileType = /*#__PURE__*/ function(ChooseMessageFileType) {
      /**
     * 仅选择视频文件
     */ ChooseMessageFileType["video"] = "video";
      /**
     * 仅选择图片文件
     */ ChooseMessageFileType["image"] = "image";
      /**
     * 可选择除了图片和视频之外的其它的文件
     */ ChooseMessageFileType["file"] = "file";
      /**
     * 可同时选择视频与图片
     */ ChooseMessageFileType["video_and_image"] = "video_and_image";
      return ChooseMessageFileType;
  }({});
  var TempFileType = /*#__PURE__*/ function(TempFileType) {
      /**
     * 视频文件
     */ TempFileType["video"] = "video";
      /**
     * 图片文件
     */ TempFileType["image"] = "image";
      /**
     * 除图片和视频的文件
     */ TempFileType["file"] = "file";
      return TempFileType;
  }({});
  /**
   * 从企业微信会话中选择文件，用户选择文件之后，返回临时文件 localId，可再调用 [getLocalFileData](#56784) 获取文件内容。
   *
   * @compat WeCom iOS, Android >= 4.0.20
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 当前成员必须在应用的可见范围之中
   *
   * @example
   * ```ts
   * ww.chooseMessageFile({
   *  count: 10,
   *  type: 'image',
   * })
   * ```
   */ function chooseMessageFile(params) {
      return passthrough('chooseMessageFile', params);
  }
  /**
   * 获取 chooseMessageFile 返回的 localId 对应的文件内容。
   *
   * @compat WeCom iOS, Android >= 4.0.20
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 当前成员必须在应用的可见范围之中
   *
   * @example
   * ```ts
   * ww.getLocalFileData({
   *   localId: '',
   * })
   * ```
   *
   * @throws
   * | errMsg | 说明 |
   * | --- | --- |
   * | getLocalFileData:ok | 执行成功 |
   * | no permission | 应用签名校验失败，或成员不在应用的可见范围内 |
   * | no such file | localId不存在或者文件已删除 |
   * | file exceed size limit | 不支持超过20M的文件 |
   */ function getLocalFileData(params) {
      return passthrough('getLocalFileData', params);
  }

  var SizeType = /*#__PURE__*/ function(SizeType) {
      /**
     * 原图
     */ SizeType["original"] = "original";
      /**
     * 压缩后的图片
     */ SizeType["compressed"] = "compressed";
      return SizeType;
  }({});
  var SourceType = /*#__PURE__*/ function(SourceType) {
      /**
     * 相册
     */ SourceType["album"] = "album";
      /**
     * 相机，企业微信 2.3 及以后版本支持相机连拍
     */ SourceType["camera"] = "camera";
      return SourceType;
  }({});
  var CameraMode = /*#__PURE__*/ function(CameraMode) {
      /**
     * 单拍
     */ CameraMode["normal"] = "normal";
      /**
     * 连拍
     *
     * @compat WeCom >= 2.3.0
     */ CameraMode["batch"] = "batch";
      /**
     * 前置摄像头单拍
     *
     * @compat WeCom >= 3.0.26
     */ CameraMode["front"] = "front";
      /**
     * 前置摄像头连拍
     *
     * @compat WeCom >= 3.0.26
     */ CameraMode["batch_front"] = "batch_front";
      return CameraMode;
  }({});
  /**
   * 拍照或从手机相册中选图。
   *
   * @compat WeCom iOS, Android; WeChat
   *
   * @example
   * ```ts
   * ww.chooseImage({
   *   count: 1,
   *   sizeType: ['original', 'compressed'],
   *   sourceType: ['album', 'camera'],
   *   defaultCameraMode: 'batch',
   *   isSaveToAlbum: true
   * })
   * ```
   */ function chooseImage(params = {}) {
      return promiseToCallback(params, async ()=>{
          await tryEnsureConfigReady();
          const res = await invoke('chooseImage', {
              scene: '1|2',
              count: params.count || 9,
              sizeType: params.sizeType || [
                  'original',
                  'compressed'
              ],
              sourceType: params.sourceType || [
                  'album',
                  'camera'
              ],
              defaultCameraMode: params.defaultCameraMode || 'normal',
              isSaveToAlbum: isFalsy(params.isSaveToAlbum) ? 0 : 1
          });
          if (isAndroid && res.localIds) {
              res.localIds = res.localIds || '[]';
              try {
                  res.localIds = JSON.parse(res.localIds);
              } catch (error) {
              // noop
              }
          }
          return res;
      });
  }
  /**
   * 预览图片
   *
   * @note
   * 从2.4.6版本开始，IOS版企业微信浏览器升级为WkWebView，企业微信原生层面的网络请求读取不到WKWebview中设置的cookie，即使域名是相同的。
   * **问题说明：**
   * 如果页面的资源或图片存储的服务器依赖校验Cookie来返回数据的情况，在切换到WKWebview后，在企业微信内长按保存，或者点击预览大图时，原生层面发起的网络请求将不会完整地带上所设置的Cookie，会导致图片保存失败或预览失败。
   * **适配建议**
   * 建议静态资源cookie free。如果确实有信息需要传递，可通过业务后台存储需要传递的信息，然后给页面一个存储信息相对应的access_token加密码，再通过Url中加入自己业务的access_token进行页面间信息传递。
   *
   * @example
   * ```ts
   * ww.previewImage({
   *   current: imgURL,
   *   urls: [imgURL]
   * });
   * ```
   */ function previewImage(params) {
      return passthrough('imagePreview', params);
  }
  /**
   * 上传图片。
   *
   * @note
   * 上传的图片有效期 3 天，可用[素材管理](#10115)接口下载图片到自己的服务器，此处获得的 serverId 即 media_id。
   *
   * @example
   * ```ts
   * ww.uploadImage({
   *   localId: localId,
   *   isShowProgressTips: true
   * })
   * ```
   */ function uploadImage(params) {
      return passthrough('uploadImage', params, {
          localId: params.localId,
          isShowProgressTips: isFalsy(params.isShowProgressTips) ? 0 : 1
      });
  }
  /**
   * 下载图片。
   *
   * @example
   * ```ts
   * ww.downloadImage({
   *   serverId: serverId,
   *   isShowProgressTips: true
   * })
   * ```
   */ function downloadImage(params) {
      return passthrough('downloadImage', params, {
          serverId: params.serverId,
          isShowProgressTips: isFalsy(params.isShowProgressTips) ? 0 : 1
      });
  }
  /**
   * 获取本地图片内容。
   *
   * @limit
   * 仅在 iOS WKWebView 下支持。
   *
   * @compat WeCom iOS >= 2.4.6
   *
   * @example
   * ```ts
   * ww.getLocalImgData({
   *   localId: localId
   * })
   * ```
   */ function getLocalImgData(params) {
      return passthrough('getLocalImgData', params);
  }

  /**
   * 开始录音。
   *
   * @example
   * ```ts
   * ww.startRecord()
   * ```
   */ function startRecord(params = {}) {
      return passthrough('startRecord', params);
  }
  /**
   * 停止录音。
   *
   * @example
   * ```ts
   * ww.stopRecord()
   * ```
   */ function stopRecord(params = {}) {
      return passthrough('stopRecord', params);
  }
  /**
   * 监听录音自动停止。
   *
   * @note
   * 录音时间超过一分钟没有停止的时候会执行 complete 回调
   *
   * @example
   * ```ts
   * ww.onVoiceRecordEnd(function(event) {
   *   console.log(event)
   * })
   * ```
   */ function onVoiceRecordEnd(callback) {
      on('onVoiceRecordEnd', callback);
  }
  /**
   * 播放语音。
   *
   * @example
   * ```ts
   * ww.playVoice({
   *   localId: localId
   * })
   * ```
   */ function playVoice(params) {
      return passthrough('playVoice', params);
  }
  /**
   * 暂停播放。
   *
   * @example
   * ```ts
   * ww.pauseVoice({
   *   localId: localId
   * })
   * ```
   */ function pauseVoice(params) {
      return passthrough('pauseVoice', params);
  }
  /**
   * 停止播放。
   *
   * @example
   * ```ts
   * ww.stopVoice({
   *   localId: localId
   * })
   * ```
   */ function stopVoice(params) {
      return passthrough('stopVoice', params);
  }
  /**
   * 监听语音播放完毕。
   *
   * @example
   * ```ts
   * ww.onVoicePlayEnd(function(event) {
   *   console.log(event)
   * })
   * ```
   */ function onVoicePlayEnd(callback) {
      on('onVoicePlayEnd', callback);
  }
  /**
   * 上传语音。
   *
   * @note
   * 上传语音有效期 3 天，可以通过[素材管理](#10115)接口下载语音到自己的服务器，接口返回的的 `serverId` 即 `media_id`。
   *
   * @example
   * ```ts
   * ww.uploadVoice({
   *   localId: localId,
   *   isShowProgressTips: true
   * })
   * ```
   */ function uploadVoice(params) {
      return passthrough('uploadVoice', params, {
          localId: params.localId,
          isShowProgressTips: isFalsy(params.isShowProgressTips) ? 0 : 1
      });
  }
  /**
   * 下载语音。
   *
   * @example
   * ```ts
   * ww.downloadVoice({
   *   serverId: serverId,
   *   isShowProgressTips: true
   * })
   * ```
   */ function downloadVoice(params) {
      return passthrough('downloadVoice', params, {
          serverId: params.serverId,
          isShowProgressTips: isFalsy(params.isShowProgressTips) ? 0 : 1
      });
  }
  /**
   * 语音转文字。
   *
   * @compat WeCom iOS, Android >= 2.7.5
   *
   * @example
   * ```ts
   * ww.translateVoice({
   *   localId: localId,
   *   isShowProgressTips: true
   * })
   * ```
   */ function translateVoice(params) {
      return passthrough('translateVoice', params, {
          localId: params.localId,
          isShowProgressTips: isFalsy(params.isShowProgressTips) ? 0 : 1
      });
  }

  var LiveType = /*#__PURE__*/ function(LiveType) {
      /**
     * 通用直播
     */ LiveType[LiveType["common"] = 0] = "common";
      /**
     * 企业培训
     */ LiveType[LiveType["corp_training"] = 1] = "corp_training";
      /**
     * 大班课
     */ LiveType[LiveType["edu_normal_class"] = 2] = "edu_normal_class";
      /**
     * 小班课
     */ LiveType[LiveType["edu_small_class"] = 3] = "edu_small_class";
      return LiveType;
  }({});
  function startLiving(params = {}) {
      return passthrough('startLiving', params);
  }
  /**
   * 调起直播间回放页面。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 应用需具有直播使用权限，参考[配置可使用直播的应用](#25967/配置可使用直播的应用)
   *
   * @compat WeCom >= 3.1.0
   *
   * @example
   * ```ts
   * ww.replayLiving({
   *   livingId: 'LIVINGID'
   * })
   * ```
   *
   * @throws
   * | errMsg | 说明 |
   * | --- | --- |
   * | replayLiving:ok | 执行成功 |
   * | replayLiving:fail no permission | 应用签名校验失败，或应用不具备直播权限 |
   * | replayLiving:fail invalid living id | 不合法的直播ID |
   * | replayLiving:fail not allow to cross corp | 不可跨企业使用直播ID |
   * | replayLiving:fail not allow to cross app | 不可跨应用使用直播ID |
   * | replayLiving:fail living has no replay | 不存在直播回放 |
   * | replayLiving:fail replay is beging creating | 正在直播中，或回放正在生成中，稍后观看回放 |
   * | replayLiving:fail create replay failed | 回放创建失败 |
   * | replayLiving:fail invalid parameter | 参数不合法 |
   */ function replayLiving(params) {
      return passthrough('replayLiving', params);
  }
  /**
   * 调起直播回放下载页面。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 应用需具有直播使用权限，参考[配置可使用直播的应用](#25967/配置可使用直播的应用)
   * - 只允许直播的发起人下载直播回放
   *
   * @compat WeCom PC >= 3.1.0
   *
   * @example
   * ```ts
   * ww.downloadLivingReplay({
   *   livingId: 'LIVINGID'
   * })
   * ```
   *
   * @throws
   * | errMsg | 说明 |
   * | --- | --- |
   * | downloadLivingReplay:ok | 执行成功 |
   * | downloadLivingReplay:fail no permission | 应用签名校验失败，或应用不具备直播权限 |
   * | downloadLivingReplay:fail invalid living id | 不合法的直播ID |
   * | downloadLivingReplay:fail not allow to cross corp | 不可跨企业使用直播ID |
   * | downloadLivingReplay:fail not allow to cross app | 不可跨应用使用直播ID |
   * | downloadLivingReplay:fail invalid parameter | 参数不合法 |
   * | downloadLivingReplay:fail living has no replay | 不存在直播回放 |
   * | downloadLivingReplay:fail replay is beging creating | 正在直播中，或回放正在生成中，稍后观看回放 |
   * | downloadLivingReplay:fail create replay failed | 回放创建失败 |
   * | downloadLivingReplay:fail invalid operator | 只允许直播的发起人下载直播回放 |
   */ function downloadLivingReplay(params) {
      return passthrough('downloadLivingReplay', params);
  }

  function startMeeting(params = {}) {
      return passthrough('startMeeting', params);
  }

  /**
   * 调起企业微信原生的待办创建页，让用户在 H5 页面内快速新建一条待办，
   * 可预填内容、参与人和截止时间。创建成功后从 `res.todoId` 取得待办 id，
   * 可配合 [viewTodo](#viewTodo) 跳转查看。
   *
   * @limit
   * - 必须先使用 ww.register 进行应用身份注册
   * - 应用必须是全员可见的自建应用，否则报 `createTodo:fail no permission`
   * - 当前成员必须在应用的可见范围内
   * - 第三方应用、代开发应用暂不支持
   *
   * @compat WeCom >= 5.0.9
   *
   * @example
   * ```ts
   * ww.createTodo({
   *   content: '待办内容',
   *   attendees: ['jack', 'jason'],
   *   endTime: 1667318400,
   * })
   * ```
   */ function createTodo(params = {}) {
      return passthrough('createTodo', params);
  }
  /**
   * 根据待办 id 拉起企业微信原生的待办详情页，
   * 让用户在 H5 页面内查看本应用此前创建的某条待办的完整内容、参与人、截止时间等信息。
   *
   * @limit
   * - 必须先使用 ww.register 进行应用身份注册
   * - 应用必须是全员可见的自建应用，否则报 `viewTodo:fail no permission`
   * - 当前成员必须在应用的可见范围内
   * - 待办必须由本应用自己创建（即 `todoId` 来自本应用的 createTodo 回调）
   * - 第三方应用、代开发应用暂不支持
   *
   * @compat WeCom >= 5.0.9
   *
   * @example
   * ```ts
   * ww.viewTodo({
   *   todoId: 'TODO_ID',
   * })
   * ```
   */ function viewTodo(params) {
      return passthrough('viewTodo', params);
  }

  /**
   * 新建文档、表格或者收集表。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 签名应用必须具有文档使用权限
   * - 当前用户必须在应用的可见范围之内
   * - 在 Mac 端使用时，macOS 版本需 > 10.12
   *
   * @compat WeCom >= 4.1.0
   *
   * @example
   * ```
   * ww.createDoc({
   *  docType: 3
   * })
   * ```
   *
   * @throws
   * | errMsg | 说明 |
   * | --- | --- |
   * | createDoc:ok | 执行成功 |
   * | createDoc:fail no permission | 应用签名校验失败，或成员不在应用的可见范围内，或应用未开启文档使用权限 |
   * | createDoc:fail doc app closed. | 基础应用“文档”如果未启用 |
   * | createDoc:fail form app closed. | 基础应用“收集表”如果没有启用 |
   */ function createDoc(params) {
      return passthrough('createDoc', params);
  }
  var WedocSelectedFileType = /*#__PURE__*/ function(WedocSelectedFileType) {
      /**
     * 其他
     */ WedocSelectedFileType[WedocSelectedFileType["other"] = 0] = "other";
      /**
     * 文档
     */ WedocSelectedFileType[WedocSelectedFileType["doc"] = 3] = "doc";
      /**
     * 表格
     */ WedocSelectedFileType[WedocSelectedFileType["sheet"] = 4] = "sheet";
      /**
     * 收集表
     */ WedocSelectedFileType[WedocSelectedFileType["form"] = 5] = "form";
      /**
     * 幻灯片
     */ WedocSelectedFileType[WedocSelectedFileType["slide"] = 6] = "slide";
      /**
     * 思维导图
     */ WedocSelectedFileType[WedocSelectedFileType["mindmap"] = 7] = "mindmap";
      /**
     * 流程图
     */ WedocSelectedFileType[WedocSelectedFileType["flowchart"] = 8] = "flowchart";
      /**
     * 智能表格
     */ WedocSelectedFileType[WedocSelectedFileType["smartsheet"] = 10] = "smartsheet";
      return WedocSelectedFileType;
  }({});
  /**
   * 选择一个或多个文档，返回对应文档的 URL。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册，签名应用必须具有文档使用权限
   * - 当前用户必须在应用的可见范围之内
   * - Mac 端使用时，macOS 版本需 > 10.12
   *
   * @compat WeCom >= 4.0.12
   *
   * @example
   * ```
   * ww.wedocSelectDoc({
   *  selectedFileNum: 1
   * })
   * ```
   *
   * @throws
   * | errMsg | 说明 |
   * | --- | --- |
   * | wedocSelectDoc:ok | 执行成功 |
   * | wedocSelectDoc:cancel | 取消选择 |
   * | wedocSelectDoc:fail no permission | 应用签名失败，或应用无文档使用权限，或用户不在应用可见范围内 |
   * | wedocSelectDoc:fail param error | 参数错误 |
   * | wedocSelectDoc:fail context error | 选择器异常 |
   * | wedocSelectDoc:fail not supported system version| 低系统版本不支持 |
   */ function wedocSelectDoc(params) {
      return passthrough('wedocSelectDoc', params);
  }

  /**
   * 在微盘中选择一个具有可上传权限的目录/空间，返回选中目录/空间对应的 selectedTicket。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 所使用的应用必须具有微盘权限
   * - 当前成员必须在应用的可见范围之内
   * - 若用户在某一目录位置不具备「上传」权限（微盘权限值为“可下载”/“仅预览”或自定义权限取消勾选“上传”权限），则无法选择该目录
   * - 在 Mac 端使用时，macOS 版本需 > 10.12
   *
   * @compat WeCom >= 4.0.12
   *
   * @example
   * ```
   * ww.wedriveSelectDir()
   * ```
   *
   * @throws
   * | errMsg | 说明 |
   * | --- | --- |
   * | wedriveSelectDir:ok | 执行成功 |
   * | wedriveSelectDir:cancel | 取消选择 |
   * | wedriveSelectDir:fail no permission | 无权限 |
   * | wedriveSelectDir:fail param error | 参数错误 |
   * | wedriveSelectDir:fail context error | 选择器异常 |
   * | wedriveSelectDir:fail not supported system version | 低系统版本不支持 |
   */ function wedriveSelectDir(params = {}) {
      return passthrough('wedriveSelectDir', params);
  }
  /**
   * 唤起微盘选择器，选择微盘中的文件
   *
   * 在微盘中选择一个或多个具有可分享权限的微盘文件或在线文档，返回选中文件的 url。
   *
   * @compat WeCom >= 4.0.12
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 所使用的应用必须具有微盘和文档使用权限
   * - 当前成员必须在应用的可见范围之内
   * - 若用户对某文件不具备「分享」权限（微盘自定义权限取消勾选“分享”权限），则无法选择该文件。
   * - 在 Mac 端使用时，macOS 版本需 > 10.12
   *
   * @example
   * ```
   * ww.wedriveSelectFile({
   *    selectedFileNum: 1,
   * })
   * ```
   *
   * @throws
   * | errMsg | 说明 |
   * | --- | --- |
   * | wedriveSelectFile:ok | 执行成功 |
   * | wedriveSelectFile:cancel | 取消选择 |
   * | wedriveSelectFile:fail no permission | 无权限 |
   * | wedriveSelectFile:fail param error | 参数错误 |
   * | wedriveSelectFile:fail context error | 选择器异常 |
   * | wedriveSelectFile:fail not supported system version | 低系统版本不支持 |
   */ function wedriveSelectFile(params) {
      return passthrough('wedriveSelectFile', params);
  }
  /**
   * 选择可分享的文件
   *
   * 在微盘中选择一个或多个具有可分享权限的微盘文件或在线文档，返回选中文件的 url。
   *
   * @deprecated 该接口即将废弃，请使用 wedriveSelectFile 代替
   *
   * @compat WeCom >= 4.0.12
   */ function wedriveSelectFileForShare(params) {
      return passthrough('wedriveSelectFileForShare', params);
  }
  /**
   * 在微盘中选择一个或多个具有下载权限的文件（只能是微盘文件，不支持在线文档），返回选中文件对应的 selectedTickets 列表。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 应用必须具有微盘使用权限
   * - 当前成员必须在应用的可见范围之中
   * - 自建应用不支持调用
   *
   * @compat WeCom >= 4.0.12
   *
   * @example
   * ```
   * ww.wedriveSelectFileForDownload({
   *  selectedFileNum: 1
   * })
   * ```
   *
   * @throws
   * | errMsg | 说明 |
   * | --- | --- |
   * | wedriveSelectFileForDownload:ok | 执行成功 |
   * | wedriveSelectFileForDownload:cancel | 取消选择 |
   * | wedriveSelectFileForDownload:fail no permission | 无权限 |
   * | wedriveSelectFileForDownload:fail param error | 参数错误 |
   * | wedriveSelectFileForDownload:fail context error | 选择器异常 |
   * | wedriveSelectFileForDownload:fail not supported system version | 低系统版本不支持 |
   */ function wedriveSelectFileForDownload(params) {
      return passthrough('wedriveSelectFileForDownload', params);
  }

  /**
   * 监听页面返回事件。
   *
   * @param callback 回调函数，返回 false 则表示中断此次返回操作
   *
   * @limit
   * - 当页面左上角没有关闭按钮，不产生该事件
   * - iOS 系统下使用手势返回时，不产生该事件
   *
   * @compat WeCom iOS, Android >= 2.2.0; WeCom PC, Mac >= 2.4.5
   *
   * @example
   * ```ts
   * ww.onHistoryBack(function() {
   *   return confirm('确定放弃当前页面的修改？')
   * })
   * ```
   */ function onHistoryBack(callback) {
      on('historyBack', callback);
  }
  /**
   * 隐藏右上角菜单。
   *
   * @example
   * ```ts
   * ww.hideOptionMenu()
   * ```
   */ function hideOptionMenu(params = {}) {
      return passthrough('hideOptionMenu', params);
  }
  /**
   * 显示右上角菜单。
   *
   * @example
   * ```ts
   * ww.showOptionMenu()
   * ```
   */ function showOptionMenu(params = {}) {
      return passthrough('showOptionMenu', params);
  }
  /**
   * 关闭当前网页窗口。
   *
   * @example
   * ```ts
   * ww.closeWindow()
   * ```
   */ function closeWindow(params = {}) {
      return passthrough('closeWindow', params);
  }
  /**
   * 批量隐藏功能按钮。
   *
   * @note
   * 完整功能按钮列表请参考[所有菜单项列表](#14926)。
   *
   * @example
   * ```ts
   * ww.hideMenuItems({
   *   menuList: ['menuItem:setFont']
   * })
   * ```
   */ function hideMenuItems(params) {
      return passthrough('hideMenuItems', params);
  }
  /**
   * 批量显示功能按钮。
   *
   * @note
   * 完整功能按钮列表请参考[所有菜单项列表](#14926)。
   *
   * @example
   * ```ts
   * ww.showMenuItems({
   *   menuList: ['menuItem:setFont']
   * })
   * ```
   */ function showMenuItems(params) {
      return passthrough('showMenuItems', params);
  }
  /**
   * 隐藏所有非基础按钮。
   *
   * @example
   * ```ts
   * ww.hideAllNonBaseMenuItem()
   * ```
   */ function hideAllNonBaseMenuItem(params = {}) {
      return passthrough('hideAllNonBaseMenuItem', params);
  }
  /**
   * 显示所有功能按钮。
   *
   * @example
   * ```ts
   * ww.showAllNonBaseMenuItem()
   * ```
   */ function showAllNonBaseMenuItem(params = {}) {
      return passthrough('showAllNonBaseMenuItem', params);
  }
  /**
   * 使用系统浏览器打开指定 URL，支持传入 oauth2 链接，从而实现在系统浏览器内免登录的效果。
   *
   * @compat WeCom PC >= 2.3.0
   *
   * @example
   * ```ts
   * ww.openDefaultBrowser({
   *   url: 'https://work.weixin.qq.com/'
   * })
   * ```
   */ function openDefaultBrowser(params) {
      return passthrough('openDefaultBrowser', params);
  }
  /**
   * 监听用户截屏事件。
   *
   * @compat WeCom iOS, Android >= 2.5.0
   *
   * @example
   * ```ts
   * ww.onUserCaptureScreen(function() {
   *   console.log('用户截屏了')
   * })
   * ```
   */ function onUserCaptureScreen(callback) {
      on('onUserCaptureScreen', callback);
  }

  /**
   * 获取「转发」按钮点击状态并自定义分享内容。
   *
   * @note
   * 微信客户端即将废弃该接口。
   *
   * @limit
   * - 仅激活成员数超过 200 人且已经认证的企业才可在微信上调用
   *
   * @example
   * ```ts
   * ww.onMenuShareAppMessage({
   *   title: '企业微信',
   *   desc: '让每个企业都有自己的微信',
   *   link: 'https://work.weixin.qq.com/',
   *   imgUrl: 'https://res.mail.qq.com/node/ww/wwmng/style/images/index_share_logo$13c64306.png',
   *   success() {
   *     // 用户确认分享后回调
   *   },
   *   cancel() {
   *     // 用户取消分享后回调
   *   }
   * })
   * ```
   */ function onMenuShareAppMessage(params) {
      bindShare('menu:share:appmessage', params, ()=>invoke('sendAppMessage', {
              title: params.title || getTitle(),
              desc: params.desc || '',
              link: params.link || getHref(),
              img_url: params.imgUrl || '',
              type: params.type || 'link',
              data_url: params.dataUrl || '',
              finder_feed: params.finderFeed || params.finder_feed,
              finder_topic: params.finderTopic || params.finder_topic,
              finder_profile: params.finderProfile || params.finder_profile,
              enableIdTrans: params.enableIdTrans ? 1 : 0
          }));
  }
  /**
   * 获取「分享到朋友圈」按钮点击状态并自定义分享内容。
   *
   * @note
   * 微信客户端即将废弃该接口。
   *
   * @example
   * ```ts
   * ww.onMenuShareTimeline({
   *   title: '企业微信',
   *   link: 'https://work.weixin.qq.com/',
   *   imgUrl: 'https://res.mail.qq.com/node/ww/wwmng/style/images/index_share_logo$13c64306.png',
   *   success() {
   *     // 用户确认分享后回调
   *   },
   *   cancel() {
   *     // 用户取消分享后回调
   *   }
   * })
   * ```
   */ function onMenuShareTimeline(params) {
      bindShare('menu:share:timeline', params, ()=>invoke('shareTimeline', {
              title: params.title || getTitle(),
              desc: params.title || getTitle(),
              img_url: params.imgUrl || '',
              link: params.link || getHref(),
              type: params.type || 'link',
              data_url: params.dataUrl || '',
              enableIdTrans: params.enableIdTrans ? 1 : 0
          }));
  }
  /**
   * 获取「微信」按钮点击状态并自定义分享内容。
   *
   * @compat WeCom
   *
   * @example
   * ```ts
   * ww.onMenuShareWechat({
   *   title: '企业微信',
   *   desc: '让每个企业都有自己的微信',
   *   link: 'https://work.weixin.qq.com/',
   *   imgUrl: 'https://res.mail.qq.com/node/ww/wwmng/style/images/index_share_logo$13c64306.png',
   *   success() {
   *     // 用户确认分享后回调
   *   },
   *   cancel() {
   *     // 用户取消分享后回调
   *   }
   * })
   * ```
   */ function onMenuShareWechat(params) {
      bindShare('menu:share:wechat', params, ()=>invoke('shareWechat', {
              title: params.title || getTitle(),
              desc: params.desc || '',
              link: params.link || getHref(),
              img_url: params.imgUrl || '',
              type: params.type || 'link',
              data_url: params.dataUrl || '',
              enableIdTrans: params.enableIdTrans ? 1 : 0
          }));
  }
  /**
   * 获取「分享到QQ」按钮点击状态并自定义分享内容。
   *
   * @note
   * 微信客户端即将废弃该接口。
   *
   * @compat WeChat
   */ function onMenuShareQQ(params) {
      bindShare('menu:share:qq', params, ()=>invoke('shareQQ', {
              title: params.title || getTitle(),
              desc: params.desc || '',
              img_url: params.imgUrl || '',
              link: params.link || getHref()
          }));
  }
  /**
   * 获取「分享到微博」按钮点击状态并自定义分享内容。
   *
   * @compat WeChat
   */ function onMenuShareWeibo(params) {
      bindShare('menu:share:weiboApp', params, ()=>invoke('shareWeiboApp', {
              title: params.title || getTitle(),
              desc: params.desc || '',
              img_url: params.imgUrl || '',
              link: params.link || getHref()
          }));
  }
  /**
   * 获取「分享到QQ空间」按钮点击状态并自定义分享内容。
   *
   * @note
   * 微信客户端即将废弃该接口。
   *
   * @compat WeChat
   */ function onMenuShareQZone(params) {
      bindShare('menu:share:QZone', params, ()=>invoke('shareQZone', {
              title: params.title || getTitle(),
              desc: params.desc || '',
              img_url: params.imgUrl || '',
              link: params.link || getHref()
          }));
  }
  /**
   * 自定义转发到会话。
   *
   * @compat WeCom >= 2.4.5
   *
   * @example
   * ```ts
   * ww.shareAppMessage({
   *   title: '企业微信',
   *   desc: '让每个企业都有自己的微信',
   *   link: 'https://work.weixin.qq.com/',
   *   imgUrl: 'https://res.mail.qq.com/node/ww/wwmng/style/images/index_share_logo$13c64306.png',
   * })
   * ```
   */ function shareAppMessage(params) {
      return passthrough('shareAppMessage', params);
  }
  /**
   * 自定义转发到微信。
   *
   * @compat WeCom >= 2.4.5
   *
   * @example
   * ```ts
   * ww.shareWechatMessage({
   *   title: '企业微信',
   *   desc: '让每个企业都有自己的微信',
   *   link: 'https://work.weixin.qq.com/',
   *   imgUrl: 'https://res.mail.qq.com/node/ww/wwmng/style/images/index_share_logo$13c64306.png',
   * })
   * ```
   */ function shareWechatMessage(params) {
      return passthrough('shareWechatMessage', params);
  }
  /**
   * 自定义「分享到朋友圈」及「分享到QQ空间」按钮的分享内容。
   *
   * @compat WeChat
   */ function updateTimelineShareData(params = {}) {
      return passthrough('updateTimelineShareData', params);
  }
  /**
   * 自定义「分享给朋友」及「分享到QQ」按钮的分享内容。
   *
   * @compat WeChat
   */ function updateAppMessageShareData(params = {}) {
      return passthrough('updateAppMessageShareData', params);
  }

  /**
   * 批量添加卡券。
   *
   * @see https://developers.weixin.qq.com/doc/offiaccount/OA_Web_Apps/JS-SDK.html#批量添加卡券接口
   */ function addCard(params) {
      return promiseToCallback(params, async ()=>{
          await tryEnsureConfigReady();
          const res = await invoke('batchAddCard', {
              card_list: params.cardList.map((card)=>({
                      card_id: card.cardId,
                      card_ext: card.cardExt
                  }))
          });
          if (!res.card_list) {
              return res;
          }
          for (const card of res.card_list){
              card.cardId = card.card_id;
              delete card.card_id;
              card.cardExt = card.card_ext;
              delete card.card_ext;
              card.isSuccess = !!card.is_succ;
              delete card.is_succ;
          }
          res.cardList = res.card_list;
          delete res.card_list;
          return res;
      });
  }
  /**
   * 拉取适用卡券列表并获取用户选择信息。
   *
   * @see https://developers.weixin.qq.com/doc/offiaccount/OA_Web_Apps/JS-SDK.html#拉取适用卡券列表并获取用户选择信息
   */ function chooseCard(params) {
      return promiseToCallback(params, async ()=>{
          await tryEnsureConfigReady();
          const res = await invoke('chooseCard', {
              app_id: getConfigCorpId(),
              location_id: params.shopId || '',
              sign_type: params.signType || 'SHA1',
              card_id: params.cardId || '',
              card_type: params.cardType || '',
              card_sign: params.cardSign,
              time_stamp: `${params.timestamp}`,
              nonce_str: params.nonceStr
          });
          res.cardList = res.choose_card_info;
          delete res.choose_card_info;
          return res;
      });
  }
  /**
   * 查看微信卡包中的卡券。
   *
   * @see https://developers.weixin.qq.com/doc/offiaccount/OA_Web_Apps/JS-SDK.html#查看微信卡包中的卡券接口
   */ function openCard(params) {
      return passthrough('batchViewCard', params, {
          card_list: params.cardList.map((card)=>({
                  card_id: card.cardId,
                  code: card.code
              }))
      });
  }
  /**
   * 核销并分享卡券。
   *
   * @deprecated
   */ function consumeAndShareCard(params) {
      return passthrough('consumedShareCard', params, {
          consumedCardId: params.cardId,
          consumedCode: params.code
      });
  }

  var ProductViewType = /*#__PURE__*/ function(ProductViewType) {
      ProductViewType[ProductViewType["normal"] = 0] = "normal";
      ProductViewType[ProductViewType["scan"] = 1] = "scan";
      return ProductViewType;
  }({});
  /**
   * 跳转微信商品页。
   *
   * @see https://developers.weixin.qq.com/doc/offiaccount/OA_Web_Apps/JS-SDK.html#跳转微信商品页接口
   */ function openProductSpecificView(params) {
      return passthrough('openProductViewWithPid', params, {
          pid: params.productId,
          view_type: params.viewType || 0,
          ext_info: params.extInfo
      });
  }

  /**
   * 发起一个微信支付请求。
   *
   * @see https://developers.weixin.qq.com/doc/offiaccount/OA_Web_Apps/JS-SDK.html#发起一个微信支付请求
   */ function chooseWXPay(params) {
      return passthrough('getBrandWCPayRequest', params, normalizeParams(params));
  }
  /**
   * 领取企业红包。
   */ function openEnterpriseRedPacket(params) {
      return passthrough('getRecevieBizHongBaoRequest', params, normalizeParams(params));
  }
  function normalizeParams(params) {
      return {
          timeStamp: `${params.timestamp}`,
          nonceStr: params.nonceStr,
          package: params.package,
          paySign: params.paySign,
          signType: params.signType || 'SHA1'
      };
  }

  /**
   * 添加设备。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 发起用户需要有设备添加权限（超级管理员/设备管理员）
   *
   * @compat WeCom iOS, Android >= 4.0.18
   *
   * @example
   * ```ts
   * ww.addDevice({
   *   type: 'qrcode',
   *   qrcode_url: 'https://open.work.weixin.qq.com/connect?xxx',
   * })
   * ```
   */ function addDevice(params) {
      return passthrough('addDevice', params);
  }

  /**
   * 判断当前客户端版本是否支持指定 JS 接口。
   *
   * @example
   * ```ts
   * ww.checkJsApi({
   *   jsApiList: ['chooseImage']
   * })
   * ```
   */ async function checkJsApi(params) {
      return promiseToCallback(params, async ()=>{
          await tryEnsureConfigReady();
          const res = await invoke('checkJsApi', {
              jsApiList: mapJsApiListToClient(params.jsApiList)
          });
          if (typeof res.checkResult === 'string') {
              try {
                  res.checkResult = JSON.parse(res.checkResult);
              } catch (error) {
                  res.checkResult = {};
              }
          }
          res.checkResult = normalize(flatten(res.checkResult));
          return res;
      });
  }
  function normalize(data) {
      const result = {
          ...data
      };
      for (const key of Object.keys(data)){
          result[mapJsApiNameToWeb(key)] = data[key];
      }
      return result;
  }
  function flatten(data) {
      const result = {};
      for (const key of Object.keys(data)){
          if (!isObject$1(data[key])) {
              result[key] = data[key];
              continue;
          }
          const child = flatten(data[key]);
          for (const childKey of Object.keys(child)){
              result[`${key}.${childKey}`] = child[childKey];
          }
      }
      return result;
  }

  /**
   * 查看其他成员某段时间内日程中的闲忙状态。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 当前成员必须在应用可见范围内
   * - 应用需具有日程使用权限
   *
   * @compat WeCom >= 4.0.20
   *
   * @example
   * ```ts
   * ww.checkSchedule({
   *   start_time: 1667232000,
   *   end_time: 1667318400,
   *   users: ['jack', 'jason']
   * })
   * ```
   */ function checkSchedule(params) {
      return passthrough('checkSchedule', params);
  }

  /**
   * 拉起电子发票列表。
   *
   * @compat WeCom iOS, Android >= 2.1.0
   *
   * @example
   * ```ts
   * ww.chooseInvoice({
   *   timestamp: timestamp,
   *   nonceStr: nonceStr,
   *   signType: signType,
   *   cardSign: cardSign
   * })
   * ```
   *
   * @throws
   * | errMsg | 说明 |
   * | --- | --- |
   * | choose_invoice:ok | 执行成功 |
   * | choose_invoice: fail | 选取发票失败 |
   * | choose_invoice: cancel | 选取发票取消 |
   */ function chooseInvoice(params) {
      return passthrough('chooseInvoice', params);
  }

  /**
   * 跳转到认领班级的界面。
   *
   * @compat WeCom >= 3.1.8
   *
   * @limit 本接口必须使用应用身份进行注册
   *
   * @example
   * ```ts
   * ww.claimClassAdmin()
   * ```
   *
   * @throws
   * | errMsg | 说明 |
   * | --- | --- |
   * | claimClassAdmin:ok | 执行成功 |
   * | claimClassAdmin:fail no permission | 应用身份鉴权失败 |
   * | claimClassAdmin:fail user not in allow list | 当前成员不在应用可见范围 |
   */ function claimClassAdmin(params = {}) {
      return passthrough('claimClassAdmin', params);
  }

  /**
   * 向用户申请给指定范围发送消息。
   *
   * 调用接口后，用户可在选人界面对群聊范围进行修改，当创建群聊成功时会返回新建的群聊 ID。
   *
   * @limit
   * - 仅第三方应用（非通讯录应用）与代开发应用可调用
   * - 本接口必须使用应用身份进行注册
   *
   * @compat WeCom >= 3.1.8
   *
   * @example
   * ```ts
   * ww.createChatWithMsg({
   *   selectedOpenUserIds: ['zhangsan','lisi'],
   *   selectedTickets: ['tick1','token2'],
   *   chatName: 'discussName',
   *   msg: {
   *     msgtype: 'link',
   *     link: {
   *       title: 'title1',
   *       desc: 'desc1',
   *       url: 'link1',
   *       imgUrl: 'imgurl1'
   *     }
   *   }
   * })
   * ```
   *
   * @throws
   * | errMsg | 说明 |
   * | --- | --- |
   * | createChatWithMsg:ok | 执行成功 |
   * | createChatWithMsg:fail_unsupported_msgtype | msgtype不合法 |
   * | createChatWithMsg:fail_msg_link_missing_url | msg.link.url未传入 |
   */ function createChatWithMsg(params) {
      return passthrough('createChatWithMsg', params);
  }

  /**
   * 创建企业互联/上下游会话。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 企业必须开启互联群功能
   * - 仅局校互联和上下游企业可调用
   * - 当前成员必须在应用的可见范围
   * - 群成员人数不能超过 2000 人
   * - 如果创建的会话有外部联系人，群成员人数不能超过 40 人
   * - 当前成员为下游企业成员时，需要打开上下游空间中的“允许外部单位之间互相查看”配置，群成员中才可以包含其他下游企业成员
   *
   * @compat WeCom iOS, Android, PC >= 3.1.8
   *
   * @example
   * ```ts
   * ww.createCorpGroupChat({
   *   groupName: '讨论组',
   *   userIds: ['lisi', 'lisi2'],
   *   openUserIds: ['wabc3', 'wbcde'],
   *   externalUserIds: ['exid1', 'exid2'],
   *   corpGroupUserIds: [
   *     {
   *       corpId: 'ww3333',
   *       userId: 'userid123',
   *       openUserId: 'wx1111'
   *     },
   *     {
   *       corpId: 'ww4444',
   *       userId: 'userid123',
   *       openUserId: 'wx1111'
   *     }
   *   ]
   * })
   * ```
   *
   * @throws
   * | errMsg | 说明 |
   * | --- | --- |
   * | createCorpGroupChat:ok | 执行成功 |
   * | createCorpGroupChat:fail no permission | 应用签名校验失败 |
   * | createCorpGroupChat:fail exceed user id list size | 超过人数上限 |
   * | createCorpGroupChat:fail invalid parameter | 参数不合法 |
   * | createCorpGroupChat:fail need open corp group chat | 企业未开启企业互联群功能 |
   * | createCorpGroupChat:fail exceed external user id list size | 超过包含外部联系人群人数上限 |
   */ function createCorpGroupChat(params) {
      return passthrough('createCorpGroupChat', params, {
          groupName: params.groupName || '',
          userIds: params.userIds,
          openUserIds: params.openUserIds,
          externalUserIds: params.externalUserIds,
          corpGroupUserIds: params.corpGroupUserIds
      });
  }

  var CreateExternalPaymentType = /*#__PURE__*/ function(CreateExternalPaymentType) {
      /**
     * 在聊天中收款
     */ CreateExternalPaymentType[CreateExternalPaymentType["chat"] = 0] = "chat";
      /**
     * 收款码收款
     */ CreateExternalPaymentType[CreateExternalPaymentType["qrcode"] = 1] = "qrcode";
      return CreateExternalPaymentType;
  }({});
  /**
   * 发起对外收款。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 所使用的应用必须具有对外收款权限
   * - 发起的用户必须在应用可见范围并实名
   * - 允许第三方应用、代开发应用和自建应用调用
   *
   * @compat WeCom >= 4.0.12
   *
   * @example
   * ```ts
   * ww.createExternalPayment({
   *   paymentType: 0,
   *   totalFee: 300,
   *   description: '可乐一罐'
   * })
   * ```
   */ function createExternalPayment(params = {}) {
      return passthrough('createExternalPayment', params);
  }

  /**
   * 发起班级收款。
   *
   * 用于老师对学生家长发起付款请求，接口调用成功后会通过家校通知发送付款小程序给家长。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 所使用的应用必须具有对外收款权限
   * - 仅支持配置在家长可使用范围内的应用
   * - 企业必须已验证或者已认证
   * - 发起的用户必须在应用可见范围并实名
   * - 发起的用户需在个人微信零钱账户的可用范围内
   *
   * @compat WeCom iOS, Android, PC >= 3.1.10
   *
   * @note
   * - 用户可以手动调整收款金额，收款项目和收款范围
   * - 通过接口发起的收款，默认收款账户为“我的微信零钱账户”，且不可修改
   * - 若用户未授权个人付款码权限，会唤起授权付款码权限页面，授权完成返回页面后会返回错误信息 `'require authorize the payment qr code'`。用户授权完成后可引导用户重新发起收款
   *
   * @example
   * ```ts
   * ww.createSchoolPayment({
   *   projectName: '1班班费',
   *   amount: 100,
   *   payers: {
   *     students: ['zhagnshan', 'lisi'],
   *     departments: [1, 2]
   *   }
   * })
   * ```
   */ function createSchoolPayment(params) {
      return passthrough('createSchoolPayment', params);
  }

  /**
   * 添加设备。
   *
   * @deprecated 请使用 addDevice 接口
   *
   * @limit
   * 调用者必须为企业超级管理员
   *
   * @compat WeCom iOS, Android >= 2.5.8
   *
   * @example
   * ```ts
   * ww.discoverDevice({
   *   type: 'qrcode',
   *   qrcode_url: 'https://open.work.weixin.qq.com/connect?xxx'
   * })
   * ```
   */ function discoverDevice(params) {
      return passthrough('discoverDevice', params);
  }

  /**
   * 加入视频会议。
   *
   * @limit
   * 只能加入同企业硬件创建的视频会议。
   *
   * @compat WeCom >= 2.5.0
   *
   * @example
   * ```ts
   * ww.enterHWOpenTalk({
   *   code: code,
   *   ticket: ticket
   * })
   * ```
   */ function enterHWOpenTalk(params) {
      return passthrough('enterHWOpenTalk', params);
  }

  /**
   * 跳转认证界面。
   *
   * @compat WeCom iOS, Android >= 2.8.7
   *
   * @example
   * ```ts
   * ww.enterpriseVerify()
   * ```
   */ function enterpriseVerify(params = {}) {
      return passthrough('enterpriseVerify', params);
  }

  /**
   * 获取 saveApprovalSelectedItems 保存的审批选项。
   *
   * 当用户打开网页后，应该先调用一次该接口获取用户已经选择的数据作为初始数据。获取到初始数据后，应该恢复已经选择的选项。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 所签名的应用必须具有审批权限
   *
   * @note
   * - 网页应该做好深色模式适配
   * - 接口仅用于审批设置外部选项场景，请勿用作其他场景
   *
   * @compat WeCom >= 4.0.18
   *
   * @example
   * ```ts
   * ww.getApprovalSelectedItems({
   *   key: 'key'
   * })
   * ```
   */ function getApprovalSelectedItems(params) {
      return promiseToCallback(params, async ()=>{
          await tryEnsureConfigReady();
          const res = await invoke('getApprovalSelectedItems', {
              key: params.key
          });
          if (!res.selectedData) {
              return res;
          }
          try {
              res.selectedData = JSON.parse(res.selectedData);
          } catch (error) {
              res.selectedData = [];
          }
          return res;
      });
  }

  var EntryType = /*#__PURE__*/ function(EntryType) {
      /**
     * 从联系人详情进入
     */ EntryType["contact_profile"] = "contact_profile";
      /**
     * 从单聊会话的工具栏进入
     */ EntryType["single_chat_tools"] = "single_chat_tools";
      /**
     * 从群聊会话的工具栏进入
     */ EntryType["group_chat_tools"] = "group_chat_tools";
      /**
     * 从会话的聊天附件栏进入
     *
     * @compat WeCom >= 3.1.6
     */ EntryType["chat_attachment"] = "chat_attachment";
      /**
     * 从微信客服的工具栏进入
     *
     * @compat WeCom >= 3.1.10
     */ EntryType["single_kf_tools"] = "single_kf_tools";
      /**
     * 上下游单聊会话的工具栏
     *
     * @compat WeCom >= 4.0.8
     */ EntryType["chain_single_chat_tools"] = "chain_single_chat_tools";
      /**
     * 上下游群聊会话的工具栏
     *
     * @compat WeCom >= 4.0.8
     */ EntryType["chain_group_chat_tools"] = "chain_group_chat_tools";
      /**
     * 从内部群群看板进入
     *
     * @compat WeCom >= 4.1.36
     */ EntryType["internal_group_chat_board"] = "internal_group_chat_board";
      /**
     * 除以上场景之外进入，例如工作台，聊天会话等
     */ EntryType["normal"] = "normal";
      return EntryType;
  }({});
  /**
   * 获取当前页面打开场景。
   *
   * @note
   * 调用该接口可以判断用户是从哪个入口打开页面，从而决定是否可以调用客户联系相关的接口。
   *
   * @compat WeCom >= 3.0.24
   *
   * @example
   * ```ts
   * ww.getContext()
   * ```
   */ function getContext(params = {}) {
      return passthrough('getContext', params);
  }

  /**
   * 页面在聊天工具栏中打开时，获取当前上下游互联群的群 ID.
   *
   * @compat WeCom >= 4.0.12
   *
   * @limit
   * - 仅支持上下游聊天工具栏中进入的页面调用，即 getContext 返回 `entry` 为 `chain_single_chat_tools` 或 `chain_group_chat_tools` 的场景
   * - 本接口必须使用应用身份进行注册
   * - 当前成员必须在应用的可见范围
   *
   * @example
   * ```
   * ww.getCurCorpGroupChat()
   * ```
   * @throws
   * | errMsg | 说明 |
   * | --- | --- |
   * | getCurCorpGroupChat:ok| 执行成功 |
   * | getCurCorpGroupChat:no permission | 应用身份鉴权失败 |
   * | getCurCorpGroupChat:without context of corpgroup contact | 当前页面入口不支持调用 |
   */ function getCurCorpGroupChat(params = {}) {
      return passthrough('getCurCorpGroupChat', params);
  }

  /**
   * 页面在上下游聊天工具栏中打开时，获取当前上下游联系人用户 ID。
   *
   * @compat WeCom >= 4.0.8
   *
   * @limit
   * - 仅支持上下游聊天工具栏中进入的页面调用，即 getContext 返回 `entry` 为 `chain_single_chat_tools` 或 `chain_group_chat_tools` 的场景
   * - 本接口必须使用应用身份进行注册
   * - 当前成员必须在应用的可见范围
   *
   * @example
   * ```
   * ww.getCurCorpGroupContact()
   * ```
   * @throws
   * | errMsg | 说明 |
   * | --- | --- |
   * | getCurCorpGroupContact:ok| 执行成功 |
   * | getCurCorpGroupContact:no permission | 应用身份鉴权失败 |
   * | getCurCorpGroupContact:without context of corpgroup contact | 当前页面入口不支持调用 |
   */ function getCurCorpGroupContact(params) {
      return passthrough('getCurCorpGroupContact', params);
  }

  /**
   * 获取当前客户群的群 ID。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 从客户群或班级群的聊天工具栏进入页面时才可成功调用该接口
   * - 「营销获客」应用仅可获取该应用带来的客户群
   * - 不同的入口对应用及用户有相应的限制
   *   | 入口 | getContext 接口返回的 entry 值 | 自建应用 | 第三方应用 | 用户 | 兼容性 |
   *   | --- | --- | --- | --- | --- | --- |
   *   | 外部群聊工具栏 | group_chat_tools | 需有[客户联系功能权限](#13473/配置可使用客户联系接口的应用) | 需有“企业客户权限->客户基础信息”权限 | 配置了[客户联系功能](#13473/配置可使用客户联系功能的成员) | 企业微信 2.8.17 |
   *   | 班级群的聊天工具栏 | group_chat_tools | 所有 | 需有「家校沟通」使用权限 | 所有 | 企业微信 3.0.36 |
   *   | 学生群的聊天工具栏 | group_chat_tools | 所有 | 需有「家校沟通」使用权限 | 所有 | 企业微信 4.0.8 |
   *
   * @compat WeCom >= 2.8.17
   *
   * @example
   * ```ts
   * ww.getCurExternalChat()
   * ```
   *
   * @throws
   * | errMsg | 说明 |
   * | --- | --- |
   * | getCurExternalChat:ok | 执行成功 |
   * | getCurExternalChat:fail no permission | 应用签名校验失败，或签名所使用的应用不满足权限要求 |
   * | getCurExternalChat:fail without context of external contact | 当前页面入口不支持调用 |
   */ function getCurExternalChat(params = {}) {
      return passthrough('getCurExternalChat', params);
  }

  /**
   * 获取当前外部联系人 userId。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 「营销获客」应用只能获取到该应用带来的客户
   * - 不同的入口对应用及用户有相应的限制，目前支持的入口有联系人详情页、外部单聊工具栏
   *   | getContext 接口返回的 entry 值 | 自建应用 | 第三方应用 | 用户 | 支持的最低版本 |
   *   | --- | --- | --- | --- | --- |
   *   | contact_profile | [客户联系功能权限](#13473/配置可使用客户联系接口的应用) | 需有“企业客户权限->客户基础信息”权限 | 配置了[客户联系功能](#13473/配置可使用客户联系功能的成员) | 企业微信 2.5.8 |
   *   | single_chat_tools | [客户联系功能权限](#13473/配置可使用客户联系接口的应用) | 需有“企业客户权限->客户基础信息”权限 | 配置了[客户联系功能](#13473/配置可使用客户联系功能的成员) | 企业微信 2.8.10 |
   *   | single_kf_tools | 所有 | 需有“微信客服权限->获取基础信息”权限 | 所有 | 企业微信 3.1.10 |
   *
   * @compat WeCom >= 2.5.8
   *
   * @example
   * ```ts
   * ww.getCurExternalContact()
   * ```
   *
   * @throws
   * | errMsg | 说明 |
   * | --- | --- |
   * | getCurExternalContact:ok | 执行成功 |
   * | getCurExternalContact:fail no permission | 应用签名校验失败或应用不满足权限条件 |
   * | getCurExternalContact:fail without context of external contact | 当前页面入口不支持调用 |
   */ function getCurExternalContact(params = {}) {
      return passthrough('getCurExternalContact', params);
  }

  /**
   * 获取私密消息信息。
   *
   * @compat WeCom >= 3.1.8
   *
   * @limit
   * 本接口必须使用应用身份进行注册
   *
   * @example
   * ```ts
   * ww.getShareInfo({
   *   shareTicket: 'xxx'
   * })
   * ```
   */ function getShareInfo(params) {
      return passthrough('getShareInfo', params);
  }

  /**
   * 页面在聊天附件栏中打开时，隐藏聊天附件栏的发送按钮。开发者可以通过[分享消息到当前会话](#sendChatMessage)接口灵活适配对页面或页面中具体内容的转发。
   *
   * @limit
   * - 仅支持聊天附件栏进入的页面调用，即 getContext 返回 `entry` 为 `chat_attachment` 的场景
   * - 本接口必须使用应用身份进行注册
   *
   * @compat WeCom >= 3.1.6
   *
   * @example
   * ```
   * ww.hideChatAttachmentMenu({
   *  menuList: ["sendMessage"]
   * })
   * ```
   *
   * @throws
   * | errMsg | 说明 |
   * | --- | --- |
   * | hideChatAttachmentMenu:ok | 执行成功 |
   * | hideChatAttachmentMenu:invalid menuList | menuList不合法 |
   * | hideChatAttachmentMenu:without context of chat_attachment | 未在聊天附件栏打开场景下调用 |
   */ function hideChatAttachmentMenu(params) {
      return passthrough('hideChatAttachmentMenu', params);
  }

  /**
   * 跳转到小程序。
   *
   * @note
   * 打开小程序时如果需要关闭页面，需同步调用 closeWindow，不推荐用 setTimeout 延迟关闭。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 跳转的小程序必须属于页面所属的企业
   * - 跳转的小程序必须已关联到工作台
   * - 应用必须与要跳转的小程序应用同属于一个企业
   * - 跳转的小程序必须已经关联到工作台
   *
   * @compat WeCom >= 3.0.36
   *
   * @example
   * ```ts
   * ww.launchMiniprogram({
   *   appid: 'wx062f7a5507909000',
   *   path: 'pages/home/index'
   * })
   * ```
   */ function launchMiniprogram(params) {
      return passthrough('launchMiniprogram', params, {
          appid: params.appid,
          path: addHTMLToPath(params.path),
          envVersion: params.envVersion
      });
  }
  function addHTMLToPath(url) {
      if (!url || !isString(url)) {
          return;
      }
      const [path, ...query] = url.split('?');
      if (!query.length) {
          return `${path}.html`;
      }
      return `${path}.html?${query.join('?')}`;
  }

  /**
   * 在企业微信内快速跳转到添加客户的界面。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 应用需有[客户联系功能权限](#13473/配置可使用客户联系接口的应用)
   * - 当前成员必须配置了客户联系功能
   *
   * @compat WeCom iOS, Android >= 3.0.36
   *
   * @example
   * ```ts
   * ww.navigateToAddCustomer()
   * ```
   */ function navigateToAddCustomer(params = {}) {
      return passthrough('navigateToAddCustomer', params);
  }

  /**
   * 进入微信客服消息界面。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 应用必须具有“微信客服->获取基础信息”权限
   * - 当前企业须已开启「微信客服」应用
   * - 当前成员须是指定客服账号的坐席
   *
   * @compat WeCom iOS, Android, PC >= 3.1.12
   *
   * @example
   * ```ts
   * ww.navigateToKfChat({
   *   openKfId: 'wkAJ2GCAAAZSfhHCt7IFSvLKtMPxyAAA',
   *   externalUserId: 'wmAJ2GCAAAZSfhHCt7IFSvLKtMPxyBBB'
   * })
   * ```
   */ function navigateToKfChat(params) {
      return passthrough('navigateToKfChat', params);
  }

  /**
   * 共享收货地址。
   *
   * @see https://developers.weixin.qq.com/doc/offiaccount/OA_Web_Apps/JS-SDK.html#共享收货地址接口
   */ function openAddress(params = {}) {
      return promiseToCallback(params, async ()=>{
          await tryEnsureConfigReady();
          const res = await invoke('editAddress');
          res.postalCode = res.addressPostalCode;
          delete res.addressPostalCode;
          res.provinceName = res.proviceFirstStageName;
          delete res.proviceFirstStageName;
          res.cityName = res.addressCitySecondStageName;
          delete res.addressCitySecondStageName;
          res.countryName = res.addressCountiesThirdStageName;
          delete res.addressCountiesThirdStageName;
          res.detailInfo = res.addressDetailInfo;
          delete res.addressDetailInfo;
          return res;
      });
  }

  /**
   * 打开应用评价页面。
   *
   * 第三方应用可以使用该接口提供按钮，让用户快速打开应用评价页面。
   *
   * @compat WeCom iOS, Android, PC >= 4.0.2
   *
   * @limit
   * - 本接口必须使用应用身份进行注册，
   * - 仅第三方应用可调用
   * - 对成员授权的应用，当前用户在应用可见范围内，可以进行应用评价
   * - 管理员授权的应用，当前用户在可见范围内，或者当前用户为超管或有应用管理权限的分管，可以进行应用评价
   *
   * @example
   * ```
   * ww.openAppComment()
   * ```
   *
   * @throws
   * | errMsg | 说明 |
   * | --- | --- |
   * | openAppComment:ok| 执行成功 |
   * | openAppComment:fail:no permission | 调用人身份不符合 |
   * | openAppComment:fail:unknown app | 应用信息获取失败 |
   * | openAppComment:fail:unsupported app type | 应用类型不符合要求 |
   * | openAppComment:fail | 其它错误 |
   */ function openAppComment(params = {}) {
      return passthrough('openAppComment', params);
  }

  /**
   * 获取设备数据授权。
   *
   * 唤起设备选择列表，企业管理员选择设备后，应用可以通过云端接口获取到设备上报的数据。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 应用必须具有智慧硬件接口权限
   * - 仅第三方应用使用
   *
   * @compat WeCom >= 4.0.12
   *
   * @example
   * ```ts
   * ww.openAppDeviceDataAuth()
   * ```
   */ function openAppDeviceDataAuth(params = {}) {
      return passthrough('openAppDeviceDataAuth', params);
  }

  var OpenAppManagePageType = /*#__PURE__*/ function(OpenAppManagePageType) {
      /**
     * 应用权限详情页
     */ OpenAppManagePageType["permission"] = "permission";
      /**
     * 数据专区-会话内容权限授权页
     *
     * 需要满足：
     *
     * - 调用身份为超级管理员
     * - 应用需要满足勾选了"数据与智能专区权限"（灰度服务商，则为"数据与智能专区权限-分析企业会话内容数据"）
     * - 应用类型为第三方应用/代开发应用（注：不支持上下游共享应用）
     */ OpenAppManagePageType["datazone_chat_permission"] = "datazone_chat_permission";
      /**
     * 数据专区-文档权限授权页
     *
     * 需要满足：
     *
     * - 调用身份为超级管理员
     * - 应用需要满足勾选了"数据与智能专区权限-分析企业文档数据"
     * - 应用类型为第三方应用（注：不支持上下游共享应用）
     */ OpenAppManagePageType["datazone_doc_permission"] = "datazone_doc_permission";
      /**
     * 数据专区-知识集权限授权页
     *
     * 需要满足：
     *
     * - 调用身份为超级管理员
     * - 应用需要满足勾选了"数据与智能专区权限-分析企业知识集数据"
     * - 应用类型为第三方应用（注：不支持上下游共享应用）
     */ OpenAppManagePageType["datazone_knowledge_permission"] = "datazone_knowledge_permission";
      /**
     * 数据与智能专区权限授权页
     *
     * @deprecated 现网权限调整，后续将去除，请使用 {@link datazone_chat_permission} 代替
     *
     * 需要满足：
     *
     * - 调用身份为超级管理员
     * - 应用需要满足勾选了"数据与智能专区权限"（灰度服务商，则为"数据与智能专区权限-分析企业会话内容数据"）
     * - 应用类型为第三方应用/代开发应用（注：不支持上下游共享应用）
     */ OpenAppManagePageType["datazone_permission"] = "datazone_permission";
      /**
     * 获客助手权限授权页
     *
     * 需要满足：
     *
     * - 调用身份为超级管理员或应用分级管理员
     * - 应用需要满足勾选了"获客助手权限"
     * - 应用类型为第三方应用/代开发应用（注：不支持上下游共享应用）
     */ OpenAppManagePageType["customer_acquisition_permission"] = "customer_acquisition_permission";
      return OpenAppManagePageType;
  }({});
  /**
   * 打开应用管理页面。
   *
   * 应用可以使用该接口提供按钮，让企业管理员快速打开应用的管理页面。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 当前用户需要是企业超级管理员，或具有应用管理权限
   *
   * @compat WeCom >= 4.0.2
   *
   * @example
   * ```
   * ww.openAppManage({
   *	  page: "permission",
   *	  suiteId: "wwabcdefghijk",
   *	})
   * ```
   */ function openAppManage(params = {}) {
      return passthrough('openAppManage', params);
  }

  /**
   * 进入应用购买页面。
   *
   * 第三方应用可以使用该接口提供按钮，让用户可快速进入应用购买流程。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 当前用户应在应用的可见范围内
   * - 仅正式授权的第三方应用可调用
   * - 第三方应用已配置了付费版本
   *
   * @compat WeCom >= 4.1.6
   *
   * @example
   * ```
   * ww.openAppPurchase()
   * ```
   *
   * @throws
   * | errMsg | 说明 |
   * | --- | --- |
   * | openAppPurchase:ok | 执行成功 |
   * | openAppPurchase:fail:no permission | 应用签名校验失败，或成员不在应用的可见范围内 |
   * | openAppPurchase:fail | 其它错误 |
   */ function openAppPurchase(params) {
      return passthrough('openAppPurchase', params);
  }

  var EnvVersion = /*#__PURE__*/ function(EnvVersion) {
      EnvVersion["release"] = "release";
      EnvVersion["trial"] = "trial";
      EnvVersion["develop"] = "develop";
      return EnvVersion;
  }({});
  /**
   * 商户小程序跳转微信支付分小程序。
   *
   * @see https://pay.weixin.qq.com/wiki/doc/apiv3/payscore.php?chapter=29_3&index=3
   */ function openBusinessView(params) {
      return promiseToCallback(params, async ()=>{
          await tryEnsureConfigReady();
          const res = await invoke('openBusinessView', {
              businessType: params.businessType,
              queryString: params.queryString || '',
              envVersion: params.envVersion
          });
          if (!isAndroid || !res.extraData) {
              return res;
          }
          try {
              res.extraData = JSON.parse(res.extraData);
          } catch (error) {
              res.extraData = {};
          }
          return res;
      });
  }

  /**
   * 查看设备。
   *
   * @limit
   * 调用者必须拥有指定 deviceSn 的管理权限。
   *
   * @note
   * 若开发者需要在 web 端引导跳转设备管理，可以构造链接跳转：`https://work.weixin.qq.com/wework_admin/frame#hardware/device?sn={{DEVICESN}}`。
   *
   * @compat WeCom iOS, Android >= 2.8.2
   *
   * @example
   * ```ts
   * ww.openDeviceProfile({
   *   deviceSn: 'QYWX001'
   * })
   * ```
   *
   * @throws
   * | errMsg | 说明 |
   * | --- | --- |
   * | openDeviceProfile:ok | 执行成功 |
   * | openDeviceProfile:fail_device_permission_denied | 管理员无设备管理权限 |
   * | openDeviceProfile:fail_device_not_found | 不存在此设备 |
   */ function openDeviceProfile(params) {
      return passthrough('openDeviceProfile', params);
  }

  /**
   * 打开会话。
   *
   * @limit
   * - 内部群最多 2000 人，外部群最多 500 人
   * - 若创建的会话包含微信联系人，群成员人数不能超过 40 人
   * - 第三方应用与代开发应用必须使用应用身份进行注册
   *
   * @compat WeCom >= 2.0.0
   *
   * @example
   * ```ts
   * ww.openEnterpriseChat({
   *   groupName: '讨论组',
   *   userIds: [
   *     'zhangsan',
   *     'lisi'
   *   ],
   *   externalUserIds: [
   *     'wmEAlECwAAHrbWYDOK5u3Bf13xlYDAAA',
   *     'wmEAlECwAAHibWYDOK5u3Af13xlYDAAA'
   *   ]
   * })
   * ```
   */ function openEnterpriseChat(params = {}) {
      return passthrough('openEnterpriseChat', params, {
          chatId: params.chatId || '',
          chatname: params.groupName || '',
          groupName: params.groupName || '',
          useridlist: joinList(params.userIds),
          userIds: joinList(params.userIds),
          openIds: joinList(params.openIds),
          externalUserIds: joinList(params.externalUserIds)
      });
  }

  /**
   * 打开已有群聊并可选发送一条链接消息（link消息）。支持打开企业内部群、外部群、互联群。
   *
   * @compat WeCom >= 3.1.8
   *
   * @limit
   * 本接口必须使用应用身份进行注册
   *
   * @example
   * ```ts
   * ww.openExistedChatWithMsg({
   *   chatId: 'chatId123',
   *   msg: {
   *     msgtype: 'link',
   *     link: {
   *       title: 'title1',
   *       desc: 'desc1',
   *       url: 'link1',
   *       imgUrl: 'imgurl1'
   *     }
   *   }
   * })
   * ```
   *
   * @throws
   * | errMsg | 说明 |
   * | --- | --- |
   * | openExistedChatWithMsg:ok | 执行成功 |
   * | openExistedChatWithMsg:fail_unsupported_msgtype | msgtype不合法 |
   * | openExistedChatWithMsg:fail_msg_link_missing_url | msg.link.url未传入 |
   */ function openExistedChatWithMsg(params) {
      return passthrough('openExistedChatWithMsg', params);
  }

  /**
   * 进入应用客服会话。
   *
   * 第三方应用可以使用该接口提供按钮，让用户快速打开应用客服的会话。。
   *
   * @compat WeCom iOS, Android >= 3.1.18; WeCom PC, Mac >= 4.1.6
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 仅第三方应用可调用
   * - 第三方应用需要提前配置客服
   * - 当前用户需要有添加外部联系人权限
   *
   * @example
   * ```
   * ww.openThirdAppServiceChat()
   * ```
   */ function openThirdAppServiceChat(params = {}) {
      return passthrough('openThirdAppServiceChat', params);
  }

  var OpenUserProfileType = /*#__PURE__*/ function(OpenUserProfileType) {
      /**
     * 企业成员
     */ OpenUserProfileType[OpenUserProfileType["internal"] = 1] = "internal";
      /**
     * 外部联系人
     */ OpenUserProfileType[OpenUserProfileType["external"] = 2] = "external";
      return OpenUserProfileType;
  }({});
  /**
   * 唤起成员或外部联系人的个人信息页面。
   *
   * @compat WeCom >= 2.4.20
   *
   * @limit
   * - 第三方应用调用时，需使用应用身份进行注册
   *
   * @example
   * ```ts
   * ww.openUserProfile({
   *   type: 1,
   *   userid: 'wmEAlECwAAHrbWYDetiu3Af13xlYDAAA'
   * })
   * ```
   */ function openUserProfile(params) {
      return passthrough('openUserProfile', params);
  }

  var PrintFileIdType = /*#__PURE__*/ function(PrintFileIdType) {
      /**
     * mediaid
     */ PrintFileIdType[PrintFileIdType["mediaid"] = 1] = "mediaid";
      /**
     * url
     */ PrintFileIdType[PrintFileIdType["url"] = 2] = "url";
      /**
     * localId
     *
     * 可通过以下方式获得：
     * 1. [从会话选择文件](#34301)
     * 2. [拍照或从手机相册中选图接口](#14915)
     */ PrintFileIdType[PrintFileIdType["localId"] = 4] = "localId";
      return PrintFileIdType;
  }({});
  /**
   * 发起文件打印。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 应用必须具有“设备信息-打印扫描设备-发起文件打印权限”授权
   * - 当前触发调用人员身份需要在应用的可见范围内
   * - 当前企业有安装企业微信打印设备
   * - 仅第三方应用使用
   *
   * @compat WeCom >= 4.0.12
   *
   * @example
   * ```ts
   * ww.printFile({
   *   fileId: 'fileId',
   *   fileIdType: 1,
   *   fileName: 'fileName.jpg'
   * })
   * ```
   */ function printFile(params) {
      return passthrough('printFile', params);
  }

  var InTalkType = /*#__PURE__*/ function(InTalkType) {
      /**
     * 当前不在任何通话中
     */ InTalkType["None"] = "None";
      /**
     * 视频会议中
     */ InTalkType["HWOpenTalk"] = "HWOpenTalk";
      /**
     * voip通话中
     */ InTalkType["VoIP"] = "VoIP";
      /**
     * 系统通话中
     */ InTalkType["SystemCall"] = "SystemCall";
      return InTalkType;
  }({});
  /**
   * 查询当前是否在视频会议。
   *
   * @compat WeCom >= 2.5.0
   *
   * @example
   * ```ts
   * ww.queryCurrHWOpenTalk()
   * ```
   */ function queryCurrHWOpenTalk(params = {}) {
      return passthrough('queryCurrHWOpenTalk', params);
  }

  /**
   * 发起退款。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 应用必须具有对外收款权限
   * - 发起的用户必须在应用可见范围并实名
   * - 只允许退款由应用本身发起的收款
   *
   * @compat WeCom >= 4.0.12
   *
   * @example
   * ```ts
   * ww.refundExternalPayment({
   *   paymentId: 'xxxx',
   *   outTradeNo: 'yyyy',
   *   refundFee: 100,
   *   refundComment: '7天无理由退货'
   * })
   * ```
   */ function refundExternalPayment(params) {
      return passthrough('refundExternalPayment', params);
  }

  /**
   * 保存用户选择的审批选项。
   *
   * 用户在网页中修改审批选项时，调用该接口保存用户的选择。
   *
   * @note
   * - 接口仅用于审批设置外部选项场景，请勿用作其他场景
   * - 网页应该做好深色模式适配
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 应用必须具有审批权限
   *
   * @compat WeCom >= 4.0.18
   *
   * @example
   * ```ts
   * ww.saveApprovalSelectedItems({
   *   key: 'key',
   *   selectedData: [
   *     {
   *       key: 'item-1',
   *       value: '选项1'
   *     },
   *     {
   *       key: 'item-2',
   *       value: '选项2'
   *     }
   *   ]
   * })
   * ```
   */ function saveApprovalSelectedItems(params) {
      return passthrough('saveApprovalSelectedItems', params, {
          key: params.key,
          selectedData: typeof params.selectedData === 'string' ? params.selectedData : JSON.stringify(params.selectedData)
      });
  }

  var ScanQRCodeType = /*#__PURE__*/ function(ScanQRCodeType) {
      /**
     * 扫描二维码
     */ ScanQRCodeType["qrCode"] = "qrCode";
      /**
     * 扫描条形码
     */ ScanQRCodeType["barCode"] = "barCode";
      return ScanQRCodeType;
  }({});
  /**
   * 调起企业微信扫一扫。
   *
   * @example
   * ```ts
   * ww.scanQRCode({
   *   needResult: true,
   *   scanType: ['qrCode']
   * })
   * ```
   */ function scanQRCode(params = {}) {
      return promiseToCallback(params, async ()=>{
          await tryEnsureConfigReady();
          const res = await invoke('scanQRCode', {
              needResult: params.needResult ? 1 : 0,
              scanType: params.scanType || [
                  'qrCode',
                  'barCode'
              ]
          });
          if (!isIOS) {
              return res;
          }
          const resultStr = res.resultStr;
          if (!resultStr) {
              return res;
          }
          let data;
          try {
              data = JSON.parse(resultStr);
          } catch (error) {
          // noop
          }
          res.resultStr = data?.scan_code?.scan_result;
          return res;
      });
  }

  var InputCorpGroupContactMode = /*#__PURE__*/ function(InputCorpGroupContactMode) {
      /**
     * 单选
     */ InputCorpGroupContactMode["single"] = "single";
      /**
     * 多选
     */ InputCorpGroupContactMode["multi"] = "multi";
      return InputCorpGroupContactMode;
  }({});
  var InputCorpGroupContactType = /*#__PURE__*/ function(InputCorpGroupContactType) {
      /**
     * 选择部门
     */ InputCorpGroupContactType["department"] = "department";
      /**
     * 选择成员
     */ InputCorpGroupContactType["user"] = "user";
      return InputCorpGroupContactType;
  }({});
  /**
   * 企业互联/上下游选人
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 该接口仅可选择应用可见范围内的成员和部门
   *
   * @compat WeCom iOS, Android, PC >= 3.1.6
   *
   * @note
   * 自建应用调用该接口时userid返回的是企业内部的userid，对于服务商该字段返回的是open_userid，同一个服务商，不同应用获取到企业内同一个成员的open_userid是相同的，最多64个字节
   *
   * @example
   * ```ts
   * ww.selectCorpGroupContact({
   *   fromDepartmentId: -1,
   *   mode: 'single',
   *   type: ['department', 'user'],
   *   selectedDepartmentIds: ['2','3'],
   *   selectedUserIds: ['lisi','lisi2'],
   *   selectedOpenUserIds: ['wabc3','wbcde'],
   *   selectedChainDepartmentIds: [
   *     {
   *       corpId: 'ww3333',
   *       departmentId: '2'
   *     },
   *     {
   *       corpId: 'ww4444',
   *       departmentId: '3'
   *     }
   *   ],
   *   selectedChainUserIds: [
   *     {
   *       corpId: 'ww3333',
   *       userId: 'userid123',
   *       openUserId: 'wx1111'
   *     },
   *     {
   *       corpId: 'ww4444',
   *       userId: 'userid123',
   *       openUserId: 'wx1111'
   *     }
   *   ],
   *   selectedCorpGroupDepartmentIds: [
   *     {
   *       corpId: 'ww3333',
   *       departmentId: '2'
   *     },
   *     {
   *       corpId: 'ww4444',
   *       departmentId: '3'
   *     }
   *   ],
   *   selectedCorpGroupUserIds: [
   *     {
   *       corpId: 'ww3333',
   *       userId: 'userid123',
   *       openUserId: 'wx1111'
   *     },
   *     {
   *       corpId: 'ww4444',
   *       userId: 'userid123',
   *       openUserId: 'wx1111'
   *     }
   *   ]
   * })
   * ```
   * @throws
   * | errMsg | 说明 |
   * | --- | --- |
   * | selectCorpGroupContact:ok | 执行成功 |
   * | selectCorpGroupContact:fail no permission | 应用身份鉴权失败 |
   *
   */ function selectCorpGroupContact(params) {
      return promiseToCallback(params, async ()=>{
          await tryEnsureConfigReady();
          const res = await invoke('selectCorpGroupContact', params);
          if (!isString(res.result)) {
              return res;
          }
          try {
              res.result = JSON.parse(res.result);
          } catch (error) {
          // noop
          }
          return res;
      });
  }

  var DatazoneDocType = /*#__PURE__*/ function(DatazoneDocType) {
      /**
     * 其他
     */ DatazoneDocType[DatazoneDocType["other"] = 0] = "other";
      /**
     * 文档
     */ DatazoneDocType[DatazoneDocType["doc"] = 3] = "doc";
      /**
     * 表格
     */ DatazoneDocType[DatazoneDocType["sheet"] = 4] = "sheet";
      /**
     * 收集表
     */ DatazoneDocType[DatazoneDocType["form"] = 5] = "form";
      /**
     * 幻灯片
     */ DatazoneDocType[DatazoneDocType["slide"] = 6] = "slide";
      /**
     * 思维导图
     */ DatazoneDocType[DatazoneDocType["mindmap"] = 7] = "mindmap";
      /**
     * 流程图
     */ DatazoneDocType[DatazoneDocType["flowchart"] = 8] = "flowchart";
      /**
     * 智能表格
     */ DatazoneDocType[DatazoneDocType["smartsheet"] = 10] = "smartsheet";
      /**
     * 智能文档
     */ DatazoneDocType[DatazoneDocType["smartdoc"] = 11] = "smartdoc";
      return DatazoneDocType;
  }({});
  /**
   * 选择一个或多个自己创建的doc文档，选中后返回对应文档的docid与url。
   * 应用可在数据与智能专区中使用这些文档调用通用模型能力进行分析（灰度内测中）。
   *
   * @limit
   * - 本接口必须先使用 ww.register 进行应用身份注册
   * - 当前成员必须在应用的可见范围内，且在该应用的文档存档范围内，否则调用时会报"no permission"错误
   * - 应用需具有「数据与智能专区文档存档权限」（灰度内测中）
   *
   * @compat WeCom >= 5.0.8
   *
   * @example
   * ```ts
   * ww.selectDatazoneDoc()
   * ```
   */ function selectDatazoneDoc(params = {}) {
      return passthrough('selectDatazoneDoc', params);
  }

  /**
   * 调起企业微信原生的微盘文件选择面板，让用户从自己所在的所有空间中、
   * 本人上传的微盘文件里勾选若干，返回文件的 `fileId` 与 `url` 列表给业务网页。
   * 应用可在数据与智能专区中使用这些文件调用通用模型能力进行分析（灰度内测中）。
   *
   * @limit
   * - 必须先使用 ww.register 进行应用身份注册
   * - 当前成员必须在应用的可见范围内，否则报 `selectDatazoneFile:fail no permission`
   * - 应用必须具有「数据与智能专区文档存档权限」，且成员在该应用的文档存档范围内
   * - 自建 / 第三方 / 代开发应用均需先获得灰度准入
   *
   * @compat WeCom >= 5.0.9
   *
   * @example
   * ```ts
   * ww.selectDatazoneFile()
   * ```
   */ function selectDatazoneFile(params = {}) {
      return passthrough('selectDatazoneFile', params);
  }

  var SelectEnterpriseContactMode = /*#__PURE__*/ function(SelectEnterpriseContactMode) {
      /**
     * 单选
     */ SelectEnterpriseContactMode["single"] = "single";
      /**
     * 多选
     */ SelectEnterpriseContactMode["multi"] = "multi";
      return SelectEnterpriseContactMode;
  }({});
  var SelectEnterpriseContactType = /*#__PURE__*/ function(SelectEnterpriseContactType) {
      /**
     * 选择部门
     */ SelectEnterpriseContactType["department"] = "department";
      /**
     * 选择成员
     */ SelectEnterpriseContactType["user"] = "user";
      return SelectEnterpriseContactType;
  }({});
  /**
   * 选择通讯录成员。
   *
   * @compat WeCom >= 1.3.11; WeChat iOS, Android >= 6.5.10
   *
   * @example
   * ```ts
   * ww.selectEnterpriseContact({
   *   fromDepartmentId: -1,
   *   mode: 'multi',
   *   type: ['department', 'user'],
   *   selectedDepartmentIds: ['2', '3'],
   *   selectedUserIds: ['lisi', 'lisi2']
   * })
   * ```
   */ function selectEnterpriseContact(params) {
      return promiseToCallback(params, async ()=>{
          await tryEnsureConfigReady();
          const res = await invoke('selectEnterpriseContact', params);
          if (!isString(res.result)) {
              return res;
          }
          try {
              res.result = JSON.parse(res.result);
          } catch (error) {
          // noop
          }
          return res;
      });
  }

  /**
   * 唤起客户群列表，选择并返回客户群ID。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 仅支持「营销获客」分类的第三方应用调用
   * - 调用成员必须在应用的可见范围内
   *
   * @compat WeCom iOS, Android, PC >= 5.0.2
   *
   * @example
   * ```ts
   * ww.selectExternalChat()
   * ```
   */ function selectExternalChat(params = {}) {
      return passthrough('selectExternalChat', params);
  }

  var SelectExternalContactType = /*#__PURE__*/ function(SelectExternalContactType) {
      /**
     * 展示全部外部联系人列表
     */ SelectExternalContactType[SelectExternalContactType["all"] = 0] = "all";
      /**
     * 仅展示未曾选择过的外部联系人
     */ SelectExternalContactType[SelectExternalContactType["unselected"] = 1] = "unselected";
      return SelectExternalContactType;
  }({});
  /**
   * 唤起该成员的外部联系人列表，并返回员工选择的外部联系人的 userId。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 应用须配置[客户联系功能权限](#13473/配置可使用客户联系接口的应用)
   * - 当前成员必须配置[客户联系功能](#13473/开始开发)
   *
   * @compat WeCom >= 2.4.20
   *
   * @example
   * ```ts
   * ww.selectExternalContact({
   *   filterType: 0
   * })
   * ```
   */ function selectExternalContact(params = {}) {
      return passthrough('selectExternalContact', params);
  }

  var SelectPrivilegedContactMode = /*#__PURE__*/ function(SelectPrivilegedContactMode) {
      /**
     * 单选
     */ SelectPrivilegedContactMode["single"] = "single";
      /**
     * 多选
     */ SelectPrivilegedContactMode["multi"] = "multi";
      return SelectPrivilegedContactMode;
  }({});
  /**
   * 返回 ticket 的选人接口。
   *
   * 用于第三方应用唤起选择企业通讯录成员，用户选择的范围区分成两部分回传给第三方应用：
   *
   * 1. 过滤应用可见范围后的 openUserId 列表
   * 2. 完整列表的 ticket，ticket 后续可用于[创建群聊](#30292) 或者[发送模板消息](#94515)
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 仅第三方应用（非通讯录应用）可调用
   *
   * @compat WeCom >= 3.1.8
   *
   * @example
   * ```ts
   * ww.selectPrivilegedContact({
   *   fromDepartmentId: -1,
   *   mode: 'multi',
   *   selectedContextContact: 1
   *   selectedOpenUserIds: ['xxx', 'yyy'],
   *   selectedTickets: ['ticket1', 'ticket2']
   * })
   * ```
   */ function selectPrivilegedContact(params) {
      return passthrough('selectPrivilegedContact', params);
  }

  /**
   * 从聊天工具栏或附件栏打开的页面中向当前会话发送消息
   *
   * @note
   * 消息格式支持文本(“text”)，图片(“image”)，视频(“video”)，文件(“file”)，H5(“news”），小程序(“miniprogram”)，菜单消息（“msgmenu”）和视频号商品（“channels_shop_product”）
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 仅从特定入口进入页面才可调用，可通过 getContext 接口进行判断
   * - 不同的入口对应用及用户有相应的限制
   *   | getContext 接口返回的 entry 值 | 自建应用 | 第三方应用 | 用户 | 支持的最低版本 |
   *   | --- | --- | --- | --- | --- |
   *   | single_chat_tools | 需有[客户联系功能权限](#13473/配置可使用客户联系接口的应用) | 需有“企业客户权限->客户基础信息”权限 | 配置了|[配置了客户联系功能](#13473/配置可使用客户联系功能的成员) | 企业微信 2.8.10 |
   *   | group_chat_tools | 需有[客户联系功能权限](#13473/配置可使用客户联系接口的应用) | 需有“企业客户权限->客户基础信息”权限 | 配置了|[配置了客户联系功能](#13473/配置可使用客户联系功能的成员) | 企业微信 2.8.10 |
   *   | group_chat_tools | 所有 | 需有「家校沟通」使用权限 | 所有 | 企业微信 3.0.36 |
   *   | group_chat_tools | 所有 | 需有「家校沟通」使用权限 | 所有 | 企业微信 4.0.8 |
   *   | chat_attachment | 所有 | 所有 | 所有 | 企业微信 3.1.6（mac 端暂不支持） |
   *   | single_kf_tools | 所有 | 需有“微信客服权限->获取基础信息”权限 | 所有 | 企业微信 3.1.10 |
   * - 消息中的 mediaId 可通过[素材管理](#10112)接口获得，暂不支持公众平台的 mediaId
   *
   * @compat WeCom >= 2.8.10
   *
   * @example
   * ```ts
   * ww.sendChatMessage({
   *   msgtype: 'text',
   *   text: {
   *     content: '你好'
   *   }
   * })
   * ```
   *
   * @throws
   * | errMsg | 说明 |
   * | --- | --- |
   * | sendChatMessage:ok | 执行成功 |
   * | claimClassAdmin:fail without context of external contact | 当前页面打开的场景不支持调用 |
   * | claimClassAdmin:fail no permission | 应用签名错误，或不满足权限要求 |
   * | claimClassAdmin:fail invalid imgUrl | 小程序消息封面图不合法 |
   */ function sendChatMessage(params) {
      return passthrough('sendChatMessage', params);
  }

  /**
   * 设置私密消息。
   *
   * @compat WeCom >= 3.1.8
   *
   * @limit
   * 本接口必须使用应用身份进行注册
   *
   * @example
   * ```ts
   * ww.setShareAttr({
   *   withShareTicket: true,
   *   state: 'STATE'
   * })
   * ```
   */ function setShareAttr(params = {}) {
      return passthrough('setShareAttr', params);
  }

  /**
   * 具有客户联系权限的企业成员，可通过该接口将文本内容和附件传递到客户群群发、发送到客户群。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 应用需有[客户联系功能权限](#13473/配置可使用客户联系接口的应用)
   * - 当前成员必须配置了[客户联系功能](#13473/配置可使用客户联系功能的成员)
   *
   * @note
   * - 为防止滥用，同一个成员每日向一个客户最多可群发一条消息，每次群发最多可选 2000 个最近活跃的客户群
   *
   * @compat WeCom >= 2.8.7
   *
   * @example
   * ```ts
   * // WeCom >= 3.1.6
   * ww.shareToExternalChat({
   *   chatIds: ["wr2GCAAAXAAAaWJHDDGasdadAAA","wr2GCAAAXBBBaWJHDDGasdadBBB"],
   *   text: {
   *     content: '企业微信'
   *   },
   *   attachments: [
   *     {
   *       msgtype: 'image',
   *       image: {
   *         imgUrl: 'https://res.mail.qq.com/node/ww/wwmng/style/images/index_share_logo$13c64306.png'
   *       }
   *     }
   *   ]
   * })
   * // 或者
   * ww.shareToExternalChat({
   *   title: '', // 消息的标题
   *   desc: '', // 消息的描述
   *   link: '', // 消息链接
   *   imgUrl: '' // 消息封面
   * })
   * ```
   */ function shareToExternalChat(params) {
      return passthrough('shareToExternalChat', params);
  }

  /**
   * 具有客户联系权限的企业成员，可通过该接口将文本内容和附件传递到群发助手、发送给客户。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 应用需有[客户联系功能权限](#13473/配置可使用客户联系接口的应用)
   * - 当前成员必须配置了[客户联系功能](#13473/配置可使用客户联系功能的成员)
   *
   * @note
   * - 为防止滥用，同一个成员每日向一个客户最多可群发一条消息，每次群发最多可选 20000 个客户
   *
   *
   * @compat WeCom >= 2.8.7
   *
   * @example
   * ```ts
   * // WeCom >= 3.1.6
   * ww.shareToExternalContact({
   *   externalUserIds: ["wr2GCAAAXAAAaWJHDDGasdadAAA","wr2GCAAAXBBBaWJHDDGasdadBBB"],
   *   text: {
   *     content: '企业微信'
   *   },
   *   attachments: [
   *     {
   *       msgtype: 'image',
   *       image: {
   *         imgUrl: 'https://res.mail.qq.com/node/ww/wwmng/style/images/index_share_logo$13c64306.png'
   *       }
   *     }
   *   ]
   * })
   *
   * // 或者
   * ww.shareToExternalContact({
   *   title: '', // 消息的标题
   *   desc: '', // 消息的描述
   *   link: '', // 消息链接
   *   imgUrl: '' // 消息封面
   * })
   * ```
   */ function shareToExternalContact(params) {
      return passthrough('shareToExternalContact', params);
  }

  /**
   * 发表内容到客户朋友圈。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 应用需有[客户联系功能权限](#13473/配置可使用客户联系接口的应用)
   * - 当前成员必须配置了客户联系功能
   * - 当前成员必须在客户朋友圈使用范围
   * - 当前成员必须具备外部沟通管理成员使用权限
   *
   * @compat WeCom iOS, Android >= 3.1.12
   *
   * @example
   * ```ts
   * ww.shareToExternalMoments({
   *   text: {
   *     content: '企业微信'
   *   },
   *   attachments: [
   *     {
   *       msgtype: 'image',
   *       image: {
   *         imgUrl: 'https://res.mail.qq.com/node/ww/wwmng/style/images/index_share_logo$13c64306.png'
   *       }
   *     }
   *   ]
   * })
   * ```
   */ function shareToExternalMoments(params) {
      return passthrough('shareToExternalMoments', params);
  }

  /**
   * 发起无线投屏。
   *
   * @compat WeCom
   *
   * @limit
   * 仅支持第三方服务商接入。
   * 需要配合硬件设备使用，硬件接入流程参考 [无线投屏](#14789)。
   *
   * @example
   * ```ts
   * ww.startWecast()
   * ```
   */ function startWecast(params = {}) {
      return passthrough('startWecast', params);
  }

  var OAType = /*#__PURE__*/ function(OAType) {
      /**
     * 发起审批
     */ OAType["create_approval"] = "10001";
      /**
     * 查看审批详情
     */ OAType["view_approval"] = "10002";
      return OAType;
  }({});
  var OaExtDataType = /*#__PURE__*/ function(OaExtDataType) {
      /**
     * 链接
     */ OaExtDataType["link"] = "link";
      /**
     * 文本
     */ OaExtDataType["text"] = "text";
      return OaExtDataType;
  }({});
  /**
   * 在应用页面中发起审批流程。之后审批流程的每次状态变化都会通知开发者，开发者可按需进行拓展开发。具体参见[审批流程引擎](#14584)。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 应用必须具有审批权限
   *
   * @compat WeCom >= 2.5.0
   *
   * @example
   * ```ts
   * ww.thirdPartyOpenPage({
   *   oaType: '10001',
   *   templateId: '46af67a118a6ebf000002',
   *   thirdNo: 'thirdNo',
   *   extData: {
   *     fieldList: [
   *       {
   *         type: 'text',
   *         title: '采购类型',
   *         value: '市场活动'
   *       },
   *       {
   *         type: 'link',
   *         title: '订单链接',
   *         value: 'https://work.weixin.qq.com'
   *       }
   *     ]
   *   }
   * })
   * ```
   * @throws
   * | errMsg | 说明 |
   * | --- | --- |
   * | 已存在相同的审批编号 | oaType为10001时，传入的thirdNo已经被其他审批单占用。 |
   * | 审批申请不存在 | oaType为10002时，在历史记录中，传入的thirdNo对应的审批单不存在。 |
   * | 审批模板ID不正确 | 调用接口时传入了错误的templateId |
   * | 应用ID不正确 | 使用了错误的 agentId |
   */ function thirdPartyOpenPage(params) {
      return passthrough('thirdPartyOpenPage', params);
  }

  /**
   * 变更企业互联/上下游群成员
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 当前成员必须在应用的可见范围
   * - 仅支持往群里添加企业内部成员/企业互联成员
   * - 仅限企业互联/上下游企业可调用
   * - 当前成员为下游企业成员时，需要打开上下游空间中的“允许外部单位之间互相查看”配置才可以往群里添加其他下游企业成员
   *
   * @compat WeCom >= 3.1.8
   *
   * @example
   * ```ts
   * ww.updateCorpGroupChat({
   *   chatId: 'CHATID',
   *   userIdsToAdd: ['lisi', 'lisi2'],
   *   openUserIdsToAdd: ['wabc3', 'wbcde'],
   *   corpGroupUserIdsToAdd: [
   *     {
   *       corpId: 'ww3333',
   *       userId: 'userid123',
   *       openUserId: 'wx1111'
   *     },
   *     {
   *       corpId: 'ww4444',
   *       userId: 'userid123',
   *       openUserId: 'wx1111'
   *     }
   *   ]
   * })
   * ```
   *
   * @throws
   * | errMsg | 说明 |
   * | --- | --- |
   * | updateCorpGroupChat:ok | 执行成功 |
   * | updateCorpGroupChat:fail no permission | 应用签名校验失败 |
   * | updateCorpGroupChat:fail exceed user id list size | 超过人数上限 |
   * | updateCorpGroupChat:fail invalid parameter | 参数不合法 |
   * | updateCorpGroupChat:fail unsupported chat | 不支持群类型 |
   */ function updateCorpGroupChat(params) {
      return passthrough('updateCorpGroupChat', params);
  }

  /**
   * 变更群成员。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 目前仅支持添加企业内部成员
   * - 仅支持客户群调用
   *
   * @compat WeCom iOS, Android, PC >= 3.0.36
   *
   * @example
   * ```ts
   * ww.updateEnterpriseChat({
   *   chatId: 'CHATID',
   *   userIdsToAdd: [
   *     'zhangsan',
   *     'lisi'
   *   ]
   * })
   * ```
   */ function updateEnterpriseChat(params) {
      return passthrough('updateEnterpriseChat', params, {
          chatId: params.chatId,
          userIdsToAdd: joinList(params.userIdsToAdd)
      });
  }

  /**
   * 设置朋友圈封面与签名。
   *
   * @compat WeCom iOS, Android >= 3.1.12
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 应用需有[客户联系功能权限](#13473/配置可使用客户联系接口的应用)
   * - 当前成员必须配置了客户联系功能
   * - 当前成员必须在客户朋友圈使用范围
   * - 当前成员必须具备外部沟通管理成员使用权限
   *
   * @note
   * 同时设置了签名跟封面url，客户端更新顺序为先更新签名，再更新封面图url（封面图若不符合要求会让用户重新调整）。
   *
   * @example
   * ```ts
   * ww.updateMomentsSetting({
   *   signature: '个性签名',
   *   imgUrl: 'https://work.weixin.qq.com/'
   * })
   * ```
   */ function updateMomentsSetting(params) {
      return passthrough('updateMomentsSetting', params);
  }

  /**
   * 保持屏幕常亮。
   *
   * 在企业微信内打开 H5 页面时，调用该接口让屏幕保持常亮。
   *
   * @note
   * 仅在当前页面生效，离开页面后设置失效。
   *
   * @limit
   * - 本接口必须使用应用身份进行注册
   * - 成员必须在应用可见范围内
   *
   * @compat @compat WeCom iOS, Android >= 4.0.20
   *
   * @example
   * ```ts
   * ww.setKeepScreenOn({
   *  keepScreenOn: true,
   * })
   * ```
   */ function setKeepScreenOn(params) {
      return passthrough('setKeepScreenOn', params);
  }

  /**
   * **注意：页面上需要提前引入 `jwxwork-1.0.0.js`：**
   *
   * ```html
   * <script src="https://open.work.weixin.qq.com/wwopen/js/jwxwork-1.0.0.js" referrerpolicy="origin"></script>
   * ```
   *
   * 初始化[通讯录展示组件](#91958)。
   *
   * 在该接口返回成功后，可以直接调用通讯录展示组件的相关方法。
   *
   * @example
   * ```ts
   * ww.initOpenData()
   * ```
   */ function initOpenData(params = {}) {
      return promiseToCallback(params, async ()=>{
          if (!isWeCom) {
              return invokeOpenDataAgentConfig();
          }
          const { result } = await ensureAgentConfigReady();
          if (!isWindows && !win?.WeixinSandBox) {
              throw new SDKError('Missing WeixinSandBox');
          }
          if (!win?.WWOpenData) {
              await invoke('wwapp.initWwOpenData');
          }
          if (!win?.WWOpenData) {
              throw new SDKError('Init WWOpenData failed');
          }
          if (win.WWOpenData.initJSSDK) {
              win.WWOpenData.initJSSDK({
                  invoke,
                  ensureAgentConfigReady
              });
          }
          return result;
      });
  }
  async function invokeOpenDataAgentConfig() {
      if (!win?.WWOpenData?.agentConfig) {
          throw new SDKError('Missing WWOpenData.agentConfig');
      }
      const params = await resolveAgentConfigParams(getSignURL());
      const promise = new Promise((success, fail)=>{
          win.WWOpenData.agentConfig({
              ...params,
              success,
              fail
          });
      });
      promise.then(handleAgentConfigSuccess, handleAgentConfigFail);
      return promise;
  }

  function createTransparentIFrame(el) {
      const iframeEl = document.createElement('iframe');
      const { style } = iframeEl;
      style.display = 'block';
      style.border = 'none';
      style.background = 'transparent';
      iframeEl.referrerPolicy = 'origin';
      iframeEl.setAttribute('frameborder', '0');
      iframeEl.setAttribute('allowtransparency', 'true');
      const containerEl = resolveEl(el);
      if (containerEl) {
          containerEl.appendChild(iframeEl);
      }
      return iframeEl;
  }
  function resolveEl(el) {
      if (typeof el === 'string') {
          return document.querySelector(el);
      }
      return el;
  }

  const clientId = random();
  let uid = 0;
  function genUid() {
      return `${clientId}-${uid++}`;
  }
  function random() {
      return Math.random().toString(36).slice(2);
  }

  function normalizeError(error) {
      if (!error || typeof error !== 'object') {
          return error;
      }
      return {
          ...error,
          message: error.message,
          stack: error.stack
      };
  }
  function tryParseJSON(data) {
      try {
          if (typeof data === 'string') {
              return JSON.parse(data);
          }
          return data;
      } catch (error) {
      // noop
      }
  }

  function useRemoteInvoke(postMessage, callback) {
      const messageMap = new Map();
      function invoke(args, opts) {
          if (opts?.dropResult) {
              postMessage({
                  type: 'ww-iframe-handle:call',
                  args
              }, opts);
              return Promise.resolve(undefined);
          }
          return new Promise((resolve, reject)=>{
              const uid = genUid();
              messageMap.set(uid, {
                  resolve,
                  reject
              });
              postMessage({
                  type: 'ww-iframe-handle:call',
                  uid,
                  args
              }, opts);
          });
      }
      async function handleCallMessage(msg, event) {
          if (!msg.uid) {
              return callback(msg.args, event);
          }
          try {
              postMessage({
                  type: 'ww-iframe-handle:response',
                  uid: msg.uid,
                  kind: 'resolve',
                  args: await callback(msg.args, event)
              });
          } catch (error) {
              postMessage({
                  type: 'ww-iframe-handle:response',
                  uid: msg.uid,
                  kind: 'reject',
                  args: normalizeError(error)
              });
              throw error;
          }
      }
      function handleResponseMessage(msg) {
          const handle = messageMap.get(msg.uid);
          if (!handle) {
              return;
          }
          handle[msg.kind](msg.args);
          messageMap.delete(msg.uid);
      }
      return {
          invoke,
          handleCallMessage,
          handleResponseMessage
      };
  }

  function useIframeClient(iframeEl, origin, callback) {
      const messageQueue = [];
      let iframeReady = false;
      let useChannel = false;
      window.addEventListener('message', handleWindowMessage);
      function handleWindowMessage(event) {
          if (event.origin !== origin || iframeEl.contentWindow !== event.source) {
              return;
          }
          const msg = tryParseJSON(event.data);
          if (typeof msg?.type !== 'string') {
              return;
          }
          if (msg.type.startsWith('ww-iframe-handle:')) {
              handleMessage(msg, event);
          }
      }
      const channel = new MessageChannel();
      channel.port1.onmessage = (event)=>{
          const msg = tryParseJSON(event.data);
          handleMessage(msg, event);
      };
      const { invoke, handleCallMessage, handleResponseMessage } = useRemoteInvoke(enqueueMsg, callback);
      function handleMessage(msg, event) {
          switch(msg.type){
              case 'ww-iframe-handle:ready':
                  return handleReadyMessage(msg);
              case 'ww-iframe-handle:call':
                  return handleCallMessage(msg, event);
              case 'ww-iframe-handle:response':
                  handleResponseMessage(msg);
                  return;
          }
      }
      function handleReadyMessage(msg) {
          if (iframeReady) {
              return;
          }
          iframeReady = true;
          if (msg.supportChannel) {
              switchToChannel();
          }
          for (const info of messageQueue){
              postMessage(info.msg, info.opts);
          }
      }
      iframeEl.addEventListener('load', ()=>{
          if (!iframeReady) {
              postMessage({
                  type: 'ww-iframe-handle:init'
              });
          }
      });
      function switchToChannel() {
          postMessage({
              type: 'ww-iframe-handle:set-port',
              port: channel.port2
          }, {
              transfer: [
                  channel.port2
              ],
              serialize: false
          });
          useChannel = true;
      }
      function enqueueMsg(msg, opts) {
          if (!iframeReady) {
              messageQueue.push({
                  msg,
                  opts
              });
          } else {
              postMessage(msg, opts);
          }
      }
      function postMessage(msg, opts) {
          const data = opts?.serialize === false ? msg : JSON.stringify(msg);
          if (useChannel) {
              channel.port1.postMessage(data, opts?.transfer);
          } else {
              iframeEl.contentWindow?.postMessage(data, origin, opts?.transfer);
          }
      }
      function dispose() {
          window.removeEventListener('message', handleWindowMessage);
          channel.port1.onmessage = null;
      }
      return {
          el: iframeEl,
          invoke,
          dispose
      };
  }

  async function resolveSuiteConfigParams(url) {
      const registerOptions = getRegisterOptions();
      if (!registerOptions?.getSuiteConfigSignature) {
          throw new SDKError('Missing getSuiteConfigSignature');
      }
      const data = await registerOptions.getSuiteConfigSignature(url);
      return {
          suiteid: registerOptions.suiteId,
          timestamp: `${data.timestamp}`,
          nonceStr: data.nonceStr,
          signature: data.signature,
          jsApiList: mapJsApiListToClient(registerOptions.jsApiList || [
              'agentConfig'
          ])
      };
  }

  function has$1(obj, key) {
      return Object.prototype.hasOwnProperty.call(obj, key);
  }

  function handleCallMsg(msg, options, thisArg) {
      safeRun(options[msg.name], msg.payload || msg.data, thisArg);
  }

  function createMsgDispatcher() {
      const handlers = new Map();
      function subscribe(type, handler) {
          handlers.set(type, handler);
      }
      function handleMessage(msg) {
          return handlers.get(msg.type)?.(msg);
      }
      return {
          subscribe,
          handleMessage
      };
  }

  let disposeModalFrame;
  function showModalFrame(url, callback) {
      disposeModalFrame?.();
      const iframeEl = createTransparentIFrame(document.body);
      const { style } = iframeEl;
      style.position = 'fixed';
      style.left = '0';
      style.top = '0';
      style.zIndex = '1000';
      style.width = '100vw';
      style.height = '100vh';
      iframeEl.classList.add('wecom-jssdk-modal');
      iframeEl.setAttribute('src', url);
      const { origin } = new URL(url);
      const client = useIframeClient(iframeEl, origin, (msg)=>{
          if (msg.type === 'close') {
              handleCloseMsg();
          }
          return callback?.(msg);
      });
      function handleCloseMsg() {
          client.dispose();
          iframeEl.parentNode?.removeChild(iframeEl);
      }
      disposeModalFrame = handleCloseMsg;
      return client;
  }

  const FRAME_ORIGIN$1 = 'https://login.work.weixin.qq.com';
  /**
   * 创建 JSAPI 触发面板。
   *
   * 在非企业微信内置浏览器环境下，开发者可以创建 JSAPI 触发面板。当用户点击面板时，内置的 iframe 将调起用户本地的企业微信客户端并调用指定的 JSAPI。
   *
   * @param name 要调用的 JSAPI 名称
   *
   * @limit
   * - 应用必须经过 SSO 登录获取 web_token
   * - 用户必须登录了企业微信桌面端且当前用户身份和页面身份一致
   */ function createJSAPIPanel(name, options) {
      const iframeEl = createTransparentIFrame(options.el);
      const { style } = iframeEl;
      style.width = '100%';
      style.height = '100%';
      const jsapiParamsMap = new Map();
      const { subscribe, handleMessage } = createMsgDispatcher();
      const { dispose } = useIframeClient(iframeEl, FRAME_ORIGIN$1, handleMessage);
      subscribe('call', (msg)=>{
          handleCallMsg(msg, options);
      });
      subscribe('getStaticOptions', ()=>{
          return {
              name,
              options: {
                  ...options,
                  el: undefined,
                  params: undefined
              }
          };
      });
      subscribe('jsapiCallback', (msg)=>{
          if (!jsapiParamsMap.has(msg.seq)) {
              return;
          }
          const jsapiParams = jsapiParamsMap.get(msg.seq);
          jsapiParamsMap.delete(msg.seq);
          if (msg.kind === 'success') {
              safeRun(jsapiParams?.success, msg.payload);
          } else {
              safeRun(jsapiParams?.fail, msg.payload);
          }
          safeRun(jsapiParams?.complete, msg.payload);
      });
      subscribe('getJSAPIParams', async (msg)=>{
          const jsapiParams = isFunction(options.params) ? await options.params() : options.params;
          const signUrl = getSignURL();
          jsapiParamsMap.set(msg.seq, jsapiParams);
          return {
              webToken: options.webToken,
              url: signUrl,
              configParams: msg.payload?.skipSignature ? undefined : await resolveSignatureData(signUrl, msg.payload?.preferSignatureTypeList || [
                  'agentConfig'
              ]),
              jsapi: name,
              jsapiParams
          };
      });
      subscribe('openModalFrame', (msg)=>{
          showModalFrame(msg.payload.url);
      });
      iframeEl.style.opacity = '0';
      iframeEl.src = 'https://login.work.weixin.qq.com/wwopen/ww-jsapi-transparent-frame';
      return {
          /**
       * JSAPI 触发面板的 iframe 元素
       */ el: iframeEl,
          /**
       * 卸载 JSAPI 触发面板
       */ unmount () {
              dispose();
              iframeEl.parentNode?.removeChild(iframeEl);
          }
      };
  }
  const resolveSignatureFnMap = {
      agentConfig: resolveAgentConfigParams,
      suiteConfig: resolveSuiteConfigParams
  };
  async function resolveSignatureData(url, typeList) {
      let lastError = new Error('Missing signature handler');
      for (const type of typeList){
          try {
              if (!has$1(resolveSignatureFnMap, type)) {
                  continue;
              }
              return {
                  type,
                  params: await resolveSignatureFnMap[type](url)
              };
          } catch (error) {
              lastError = error;
          }
      }
      throw lastError;
  }

  function has(object, key) {
      return Object.prototype.hasOwnProperty.call(object, key);
  }
  function isObject(val) {
      return typeof val === 'object' && val !== null;
  }
  function includes(list, value) {
      if (!list) {
          return false;
      }
      return list.indexOf(value) >= 0;
  }
  var createIdentifier = createBuilder("Identifier" /* Types.Identifier */ , 'name');
  var createLiteral = createBuilder("Literal" /* Types.Literal */ , 'value');
  function createBuilder(type, key) {
      return function(val) {
          var _a;
          return _a = {
              type: type
          }, _a[key] = val, _a;
      };
  }
  function isIdentifierStart(ch) {
      return isInRange(ch, 65, 90) // A-Z
       || isInRange(ch, 97, 122) // a-z
       || ch === 36 /* Code.dollarSign */  || ch === 95 /* Code.underscore */ ;
  }
  function isIdentifierPart(ch) {
      return isIdentifierStart(ch) || isDecimalDigit(ch);
  }
  function isDecimalDigit(ch) {
      return isInRange(ch, 48, 57); // 0-9
  }
  function isHexDigit(ch) {
      return isDecimalDigit(ch) || isInRange(ch, 65, 70) // A-F
       || isInRange(ch, 97, 102); // a-f
  }
  function isInRange(val, min, max) {
      return val >= min && val <= max;
  }
  /**
   * 12.6 Names and Keywords & 13.1 Identifiers
   */ var LITERAL_NAME = {
      "null": null,
      "true": true,
      "false": false,
      NaN: NaN,
      Infinity: Infinity
  };
  var reserveWords = ('await break case catch class const continue ' + 'debugger default delete do else enum export ' + 'extends false finally for function if import ' + 'in instanceof new null return super switch ' + 'this throw true try typeof var void while ' + 'with yield').split(' ');
  var reserveWordMap = {};
  for(var _i = 0, reserveWords_1 = reserveWords; _i < reserveWords_1.length; _i++){
      var word = reserveWords_1[_i];
      reserveWordMap[word] = true;
  }
  /**
   * IdentifierReference
   *
   * https://tc39.es/ecma262/#prod-IdentifierReference
   */ function parseIdentifierReference(ctx) {
      var name = parseIdentifierName(ctx);
      if (has(LITERAL_NAME, name)) {
          return ctx.build(createLiteral(LITERAL_NAME[name]));
      }
      if (has(reserveWordMap, name)) {
          ctx.unexpected(name);
      }
      return ctx.build(createIdentifier(name));
  }
  /**
   * Identifier
   *
   * https://tc39.es/ecma262/#prod-Identifier
   */ function parseIdentifier(ctx) {
      var name = parseIdentifierName(ctx);
      return ctx.build(createIdentifier(name));
  }
  /**
   * IdentifierName
   *
   * https://tc39.es/ecma262/#prod-IdentifierName
   */ function parseIdentifierName(ctx) {
      if (!isIdentifierStart(ctx.peek())) {
          ctx.unexpected();
      }
      var start = ctx.index;
      do {
          ctx.next();
      }while (isIdentifierPart(ctx.peek()))
      return ctx.expr.slice(start, ctx.index);
  }
  /**
   * 12.8.3 Numeric Literals
   */ /**
   * NumericLiteral
   *
   * https://tc39.es/ecma262/#prod-NumericLiteral
   */ function parseNumericLiteral(ctx) {
      var number = '';
      while(isDecimalDigit(ctx.peek())){
          number += ctx.nextCh();
      }
      if (number === '0') {
          // HexIntegerLiteral
          // https://tc39.es/ecma262/#prod-HexIntegerLiteral
          if (ctx.eat(120 /* Code.lowercaseX */ ) || ctx.eat(88 /* Code.uppercaseX */ )) {
              number = '';
              while(isHexDigit(ctx.peek())){
                  number += ctx.nextCh();
              }
              if (!number) {
                  ctx.unexpected();
              }
              return ctx.build(createLiteral(parseInt(number, 16)));
          }
          // BinaryIntegerLiteral
          // https://tc39.es/ecma262/#prod-BinaryIntegerLiteral
          if (ctx.eat(98 /* Code.lowercaseB */ ) || ctx.eat(66 /* Code.uppercaseB */ )) {
              number = '';
              while(ctx.peek() === 48 /* Code.digit0 */  || ctx.peek() === 49 /* Code.digit1 */ ){
                  number += ctx.nextCh();
              }
              if (!number) {
                  ctx.unexpected();
              }
              return ctx.build(createLiteral(parseInt(number, 2)));
          }
      }
      if (ctx.peek() === 46 /* Code.dot */ ) {
          number += ctx.nextCh();
          while(isDecimalDigit(ctx.peek())){
              number += ctx.nextCh();
          }
      }
      // ExponentPart
      // https://tc39.es/ecma262/#prod-ExponentPart
      if (ctx.peek() === 101 /* Code.lowercaseE */  || ctx.peek() === 69 /* Code.uppercaseE */ ) {
          number += ctx.nextCh();
          if (ctx.peek() === 43 /* Code.plusSign */  || ctx.peek() === 45 /* Code.dash */ ) {
              number += ctx.nextCh();
          }
          var hasDecimal = false;
          while(isDecimalDigit(ctx.peek())){
              hasDecimal = true;
              number += ctx.nextCh();
          }
          if (!hasDecimal) {
              ctx.unexpected();
          }
      }
      if (isIdentifierStart(ctx.peek())) {
          ctx["throw"]("Variable name cannot start with a number (".concat(number).concat(ctx.peekCh(), ")."));
      }
      if (ctx.peek() === 46 /* Code.dot */  || number === '.') {
          ctx.unexpected();
      }
      return ctx.build(createLiteral(parseFloat(number)));
  }
  /**
   * 12.8.4 String Literals
   */ var ESCAPE_CHARACTER = {
      n: '\n',
      r: '\r',
      t: '\t'
  };
  /**
   * StringLiteral
   *
   * https://tc39.es/ecma262/#prod-StringLiteral
   */ function parseStringLiteral(ctx) {
      var quote = ctx.nextCh();
      var value = '';
      var ch;
      while(ch = ctx.nextCh()){
          if (ch === quote) {
              return ctx.build(createLiteral(value));
          }
          if (ch !== '\\') {
              value += ch;
              continue;
          }
          ch = ctx.nextCh();
          if (has(ESCAPE_CHARACTER, ch)) {
              value += ESCAPE_CHARACTER[ch];
          } else {
              value += ch;
          }
      }
      ctx.unexpected();
  }
  /**
   * 13.2 Primary Expression
   */ /**
   * PrimaryExpression
   *
   * https://tc39.es/ecma262/#prod-PrimaryExpression
   */ function parsePrimaryExpression(ctx) {
      var code = ctx.peek();
      if (isDecimalDigit(code) || code === 46 /* Code.dot */ ) {
          return parseNumericLiteral(ctx);
      }
      if (code === 39 /* Code.singleQuote */  || code === 34 /* Code.doubleQuote */ ) {
          return parseStringLiteral(ctx);
      }
      if (isIdentifierStart(code)) {
          return parseIdentifierReference(ctx);
      }
      ctx.unexpected();
  }
  /**
   * 13.3 Left-Hand-Side Expressions
   */ /**
   * LeftHandSideExpression
   *
   * https://tc39.es/ecma262/#prod-LeftHandSideExpression
   */ function parseLeftHandSideExpression(ctx) {
      var content = parsePrimaryExpression(ctx);
      var code;
      while(code = ctx.peek()){
          // base [ prop ]
          if (code === 91 /* Code.leftSquareBracket */ ) {
              content = buildMemberExpression(ctx, content, true);
              continue;
          }
          // base . prop
          if (ctx.eat(46 /* Code.dot */ )) {
              content = buildMemberExpression(ctx, content);
              continue;
          }
          break;
      }
      return content;
  }
  /**
   * MemberExpression
   *
   * https://tc39.es/ecma262/#prod-MemberExpression
   */ function buildMemberExpression(ctx, object, computed) {
      if (computed === void 0) {
          computed = false;
      }
      var property;
      if (computed) {
          ctx.expect(91 /* Code.leftSquareBracket */ );
          property = parseExpression(ctx);
          ctx.expect(93 /* Code.rightSquareBracket */ );
      } else {
          property = parseIdentifier(ctx);
      }
      return ctx.build({
          type: "MemberExpression" /* Types.MemberExpression */ ,
          object: object,
          property: property,
          computed: computed
      });
  }
  /**
   * 13.16 Comma Operator ( , )
   */ /**
   * Expression
   *
   * https://tc39.es/ecma262/#prod-Expression
   */ function parseExpression(ctx) {
      return parseLeftHandSideExpression(ctx);
  }
  function createParserContext(expr) {
      return {
          expr: expr,
          index: 0,
          peek: function() {
              return this.expr.charCodeAt(this.index);
          },
          peekCh: function() {
              return this.expr.charAt(this.index);
          },
          next: function() {
              this.index += 1;
          },
          nextCh: function() {
              this.index += 1;
              return this.expr.charAt(this.index - 1);
          },
          eat: function(ch) {
              if (this.peek() !== ch) {
                  return false;
              }
              this.next();
              this.skipWhitespace();
              return true;
          },
          expect: function(ch) {
              if (!this.eat(ch)) {
                  this.unexpected();
              }
          },
          skip: function(length) {
              this.index += length;
              this.skipWhitespace();
          },
          skipWhitespace: function() {
              var ch = expr.charCodeAt(this.index);
              while(ch === 32 /* Code.space */  || ch === 9 /* Code.tab */  || ch === 13 /* Code.carriageReturn */  || ch === 10 /* Code.lineFeed */ ){
                  this.index += 1;
                  ch = expr.charCodeAt(this.index);
              }
              return this.index;
          },
          build: function(expr) {
              this.skipWhitespace();
              return expr;
          },
          unexpected: function(token) {
              if (!token && this.index >= expr.length) {
                  throw this["throw"]('Unexpected end of input.');
              }
              throw this["throw"]("Unexpected token '".concat(token || this.peekCh(), "'."));
          },
          "throw": function(msg) {
              throw new SyntaxError("".concat(msg, " (1:").concat(this.index, ")"));
          }
      };
  }
  function parseDataPath(input) {
      var ctx = createParserContext(input.trim());
      var ast = parseExpression(ctx);
      if (ctx.index !== ctx.expr.length) {
          ctx.unexpected();
      }
      return ast;
  }
  var DEFAULT_PROTECTED_KEYS = [
      'constrcutor',
      'prototype',
      '__proto__'
  ];
  function patch(data, update, options) {
      if (options === void 0) {
          options = {};
      }
      var protectedKeys = options.protectedKeys || DEFAULT_PROTECTED_KEYS;
      var set = options.set || defaultSet;
      for(var _i = 0, _a = Object.keys(update); _i < _a.length; _i++){
          var key = _a[_i];
          if (includes(protectedKeys, key)) {
              continue;
          }
          if (!includes(key, '[') && !includes(key, '.')) {
              set(data, key, update[key]);
              continue;
          }
          try {
              var path = extractPath(parseDataPath(key), protectedKeys || []);
              if (path) {
                  setIn(data, path, update[key], set);
              } else {
                  set(data, key, update[key]);
              }
          } catch (error) {
              set(data, key, update[key]);
          }
      }
  }
  function extractPath(expr, protectedKeys, path) {
      if (protectedKeys === void 0) {
          protectedKeys = [];
      }
      if (path === void 0) {
          path = [];
      }
      if (expr.type === "Identifier" /* Types.Identifier */ ) {
          path.unshift(expr.name);
          return path;
      }
      if (expr.type !== "MemberExpression" /* Types.MemberExpression */ ) {
          return;
      }
      var object = expr.object, property = expr.property, computed = expr.computed;
      if (computed) {
          if (property.type !== "Literal" /* Types.Literal */ ) {
              return;
          }
          var value = property.value;
          if (includes(protectedKeys, value)) {
              return;
          }
          path.unshift(value);
      } else {
          if (property.type !== "Identifier" /* Types.Identifier */ ) {
              return;
          }
          var name_1 = property.name;
          if (includes(protectedKeys, name_1)) {
              return;
          }
          path.unshift(name_1);
      }
      return extractPath(object, protectedKeys, path);
  }
  function setIn(data, path, value, set) {
      var ptr = data;
      for(var i = 0, ii = path.length - 1; i < ii; i++){
          var key = path[i];
          if (!has(ptr, key) || !isObject(ptr[key])) {
              set(ptr, key, typeof path[i + 1] === 'string' ? {} : []);
          }
          ptr = ptr[key];
      }
      set(ptr, path[path.length - 1], value);
      return ptr;
  }
  function defaultSet(object, key, value) {
      // eslint-disable-next-line no-param-reassign
      object[key] = value;
  }

  function cloneDeep(value) {
      if (Array.isArray(value)) {
          return value.map(cloneDeep);
      }
      if (value == null || typeof value !== 'object') {
          return value;
      }
      const result = {};
      for (const key of Object.keys(value)){
          result[key] = cloneDeep(value[key]);
      }
      return result;
  }

  const contextMap = new WeakMap();
  function setPluginContext(instance, internal) {
      contextMap.set(instance, internal);
  }
  function getPluginContext(instance) {
      return contextMap.get(instance);
  }

  function createOpenSessionInjector(params) {
      return new Promise((resolve, reject)=>{
          win.WWOpenData.createOpenSessionInjector(params, (error, injectOpenSession)=>{
              if (error || !injectOpenSession) {
                  reject(error || new Error('System error'));
              } else {
                  resolve(injectOpenSession);
              }
          });
      });
  }

  function getHookNames(options) {
      return Object.keys(options).filter((name)=>typeof options[name] === 'function');
  }
  function removeHooks(options) {
      return Object.entries(options).reduce((acc, [name, value])=>{
          if (typeof value !== 'function') {
              acc[name] = value;
          }
          return acc;
      }, {});
  }

  const FRAME_ORIGIN = 'https://open.work.weixin.qq.com';
  const BUSINESS_URL = `${FRAME_ORIGIN}/wwopen/ww-open-data-frame`;
  const PROTECTED_DATA_KEYS = [
      'constructor',
      'prototype',
      '__proto__',
      '__ob__'
  ];
  /**
   * 创建 open-data frame 工厂对象。
   *
   * @compat WeCom >= 4.0.20
   *
   * @example
   * ```ts
   * const factory = ww.createOpenDataFrameFactory()
   * const instance = factory.createOpenDataFrame(options)
   *
   * containerEl.appendChild(instance.el)
   * ```
   */ function createOpenDataFrameFactory(params) {
      const initOpenDataPromise = isWeCom ? initOpenData() : undefined;
      let openSessionInjectorPromise = createSessionInjector();
      async function createSessionInjector() {
          if (!isWeCom) {
              return;
          }
          try {
              await initOpenDataPromise;
              return createOpenSessionInjector({
                  url: BUSINESS_URL
              });
          } catch (error) {
              safeRun(params?.onError, error);
              safeRun(params?.handleError, error);
              throw error;
          }
      }
      async function injectOpenSession(iframe) {
          if (!isWeCom) {
              return;
          }
          const injectSession = await openSessionInjectorPromise;
          if (injectSession) {
              injectSession(iframe);
          }
      }
      function createOpenDataFrame(options) {
          if (!options.template) {
              throw new Error('options.template is required');
          }
          const iframeEl = createTransparentIFrame(options.el);
          const registerOpenFramePromise = initOpenDataPromise?.then(()=>win?.WWOpenData?.registerOpenFrame(iframeEl));
          const { subscribe, handleMessage } = createMsgDispatcher();
          const { invoke: invoke$1, dispose } = useIframeClient(iframeEl, FRAME_ORIGIN, handleMessage);
          const publicInstance = {
              el: iframeEl,
              data: cloneDeep(options.data) || {},
              setData,
              dispose: disposeComponent,
              ...options.methods
          };
          async function setData(partialData) {
              patch(publicInstance.data, partialData, {
                  protectedKeys: PROTECTED_DATA_KEYS
              });
              await invoke$1({
                  type: 'update',
                  options: {
                      data: partialData
                  }
              });
          }
          function disposeComponent() {
              dispose();
              registerOpenFramePromise?.then((iframeId)=>{
                  win?.WWOpenData?.unregisterOpenFrame(iframeId);
              });
          }
          setPluginContext(publicInstance, {
              frame: publicInstance,
              invoke: invoke$1,
              subscribe
          });
          iframeEl.src = BUSINESS_URL;
          subscribe('init', async ()=>{
              return {
                  id: isWeCom ? await registerOpenFramePromise : undefined,
                  hooks: getHookNames(options),
                  options: removeHooks({
                      ...options,
                      el: undefined,
                      methods: undefined,
                      data: publicInstance.data
                  }),
                  config: {
                      support: [
                          'injectSession'
                      ]
                  }
              };
          });
          subscribe('call', (msg)=>{
              let base = options;
              if (msg.kind === 'method') {
                  base = base.methods;
              }
              return handleCallMsg(msg, base, publicInstance);
          });
          subscribe('injectSession', async ()=>{
              await injectOpenSession(iframeEl);
          });
          subscribe('refreshSession', async ()=>{
              openSessionInjectorPromise = createSessionInjector();
              await injectOpenSession(iframeEl);
          });
          subscribe('invokeJsapi', (msg)=>{
              return invoke('wwapp.invokeJsApiByCallInfo', {
                  callInfo: msg.callInfo
              });
          });
          subscribe('invokeDownload', (msg)=>{
              if (!msg.url.startsWith('https://open.work.weixin.qq.com/')) {
                  throw new Error('Invalid download url');
              }
              const el = document.createElement('a');
              el.href = msg.url;
              el.target = '_blank';
              el.style.display = 'none';
              el.click();
          });
          subscribe('agentConfig', async ()=>{
              const url = getSignURL();
              return {
                  url,
                  params: await resolveAgentConfigParams(url)
              };
          });
          subscribe('modal', async (msg)=>{
              const defaultPreviewType = isWeCom ? 'wecom-window' : undefined;
              if (typeof options.handleModal !== 'function') {
                  return {
                      modalType: defaultPreviewType
                  };
              }
              const res = options.handleModal({
                  modalUrl: msg.modalUrl,
                  modalSize: msg.modalSize
              });
              return {
                  modalType: res === false ? 'iframe' : defaultPreviewType
              };
          });
          return publicInstance;
      }
      return {
          /**
       * 创建 open-data frame 组件
       */ createOpenDataFrame
      };
  }

  /**
   * 显示确认安全网关配置页面。
   *
   * 在桌面端页面以 iframe 弹窗的形式覆盖在页面上；在移动端页面将跳转至确认页面，返回后页面需要主动确认 confirm_id 的确认情况。
   */ function showSecurityGatewayConfirmModal(options) {
      const url = new URL('https://open.work.weixin.qq.com/wwopen/secureGateway/confirm');
      url.searchParams.set('confirm_id', options.confirmId);
      if (isIOS || isAndroid) {
          location.href = url.href;
          return;
      }
      url.searchParams.set('modal', 'true');
      const client = showModalFrame(url.href, (msg)=>{
          switch(msg.type){
              case 'call':
                  return handleCallMsg(msg, options);
              case 'close':
                  return;
              default:
                  throw new Error(`Unknown message type '${msg.type}'`);
          }
      });
      return {
          /**
       * 弹窗面板的 iframe 元素
       */ el: client.el,
          /**
       * 卸载弹窗面板
       */ unmount () {
              client.dispose();
              client.el.parentNode?.removeChild(client.el);
          }
      };
  }

  const SDK_VERSION = "2.4.2";

  /**
   * 登录类型
   */ var WWLoginType = /*#__PURE__*/ function(WWLoginType) {
      /**
     * [第三方应用登录](#45846)
     */ WWLoginType["serviceApp"] = "ServiceApp";
      /**
     * [企业自建应用登录](/document/path/98151)、[服务商代开发应用登录](/document/path/98173)
     */ WWLoginType["corpApp"] = "CorpApp";
      return WWLoginType;
  }({});
  /**
   * 语言类型
   */ var WWLoginLangType = /*#__PURE__*/ function(WWLoginLangType) {
      /**
     * 中文
     */ WWLoginLangType["zh"] = "zh";
      /**
     * 英文
     */ WWLoginLangType["en"] = "en";
      return WWLoginLangType;
  }({});
  /**
   * 登录成功跳转类型
   */ var WWLoginRedirectType = /*#__PURE__*/ function(WWLoginRedirectType) {
      /**
     * 默认 `top window` 顶层页面跳转
     */ WWLoginRedirectType["top"] = "top";
      /**
     * 通过 `onLoginSuccess` 回调用户授权 `code`，开发者自行处理跳转
     */ WWLoginRedirectType["callback"] = "callback";
      /**
     * 登录组件跳转
     */ WWLoginRedirectType["self"] = "self";
      return WWLoginRedirectType;
  }({});
  /**
   * 登录面板大小
   */ var WWLoginPanelSizeType = /*#__PURE__*/ function(WWLoginPanelSizeType) {
      /**
     * 默认: 480x416px
     */ WWLoginPanelSizeType["middle"] = "middle";
      /**
     * 小尺寸: 320x380px
     */ WWLoginPanelSizeType["small"] = "small";
      return WWLoginPanelSizeType;
  }({});
  /**
   * 主题色
   */ var ColorScheme = /*#__PURE__*/ function(ColorScheme) {
      /**
     * 浅色
     */ ColorScheme["Light"] = "light";
      /**
     * 深色
     */ ColorScheme["Dark"] = "dark";
      /**
     * 自动切换
     */ ColorScheme["Auto"] = "auto";
      return ColorScheme;
  }({});

  const PANEL_SIZE = {
      [WWLoginPanelSizeType.middle]: [
          '480px',
          '416px'
      ],
      [WWLoginPanelSizeType.small]: [
          '320px',
          '380px'
      ]
  };
  /**
   * 初始化企业微信Web登录组件，创建登录面板。
   *
   * @example
   * ```ts
   * // 初始化登录组件
   * const wwLogin = ww.createWWLoginPanel({
   *   el: '#ww_login',
   *   params: {
   *     login_type: 'CorpApp',
   *     appid: 'wwbbb6a7b539f2xxxxx',
   *     agentid: '10000xx',
   *     redirect_uri: 'https://work.weixin.qq.com',
   *     state: 'loginState',
   *     redirect_type: 'callback',
   *   },
   *   onCheckWeComLogin({ isWeComLogin }) {
   *     console.log(isWeComLogin)
   *   },
   *   onLoginSuccess({ code }) {
   *     console.log({ code })
   *   },
   *   onLoginFail(err) {
   *     console.log(err)
   *   },
   * })
   * ```
   */ function createWWLoginPanel(options) {
      const { width, height } = getPanelSize(options.params?.panel_size);
      const iframeEl = createTransparentIFrame(options.el);
      iframeEl.setAttribute('allow', 'local-network-access');
      if (options.params?.redirect_type === WWLoginRedirectType.top) {
          const topOrigin = getTopOrigin();
          const redirectOrigin = getOrigin(options.params?.redirect_uri);
          if (topOrigin !== redirectOrigin) {
              iframeEl.setAttribute('sandbox', 'allow-top-navigation allow-scripts allow-same-origin');
          }
      }
      const { style } = iframeEl;
      style.width = width;
      style.height = height;
      const { dispose } = useIframeClient(iframeEl, 'https://login.work.weixin.qq.com', (msg)=>{
          if (msg.type === 'call') {
              return handleCallMsg(msg, options);
          }
          throw new Error(`Unknown message type '${msg.type}'`);
      });
      const url = new URL('https://login.work.weixin.qq.com/wwlogin/sso/login');
      for (const key of Object.keys(options.params || {})){
          url.searchParams.set(key, options.params[key]);
      }
      url.searchParams.set('version', SDK_VERSION);
      iframeEl.src = url.href;
      return {
          el: iframeEl,
          unmount () {
              dispose();
              iframeEl.parentNode?.removeChild(iframeEl);
          }
      };
  }
  function getPanelSize(panelSizeType = WWLoginPanelSizeType.middle) {
      const size = PANEL_SIZE[panelSizeType] || PANEL_SIZE[WWLoginPanelSizeType.middle];
      return {
          width: size[0],
          height: size[1]
      };
  }
  function getOrigin(uri = '') {
      try {
          return new URL(uri)?.origin;
      } catch (error) {
          return '';
      }
  }
  function getTopOrigin() {
      let topOrigin;
      try {
          topOrigin = getOrigin(window.top?.origin ?? '');
      } catch (error) {
          topOrigin = getOrigin(document.referrer);
      }
      return topOrigin;
  }

  function createSingleton(factory) {
      const map = new WeakMap();
      return (object, ...args)=>{
          if (!map.has(object)) {
              map.set(object, factory(object, ...args));
          }
          return map.get(object);
      };
  }

  function createWeakRef(target) {
      if (typeof WeakRef !== 'undefined') {
          return new WeakRef(target);
      }
      return {
          deref: ()=>target
      };
  }

  function createPlugin(factory) {
      return createSingleton((instance)=>{
          const context = getPluginContext(instance);
          if (!context) {
              throw new TypeError('Illegal invocation');
          }
          return factory(context);
      });
  }

  const useRefManager = createPlugin(({ frame, invoke, subscribe })=>{
      const refid2refMap = new Map();
      const refid2eventMap = new Map();
      subscribe('ref.event', (msg)=>{
          const subscribers = refid2eventMap.get(msg.refId);
          if (!subscribers) {
              return;
          }
          for (const fn of subscribers){
              fn(msg.data);
          }
      });
      subscribe('refDispose', (msg)=>{
          refid2refMap.delete(msg.refId);
          refid2eventMap.delete(msg.refId);
      });
      async function getRef(name) {
          const res = await invoke({
              type: 'ref.get',
              name
          });
          if (!res) {
              return;
          }
          const ref = refid2refMap.get(res.refId)?.deref();
          if (ref) {
              return ref;
          }
          const newRef = createRef(res.refId);
          refid2refMap.set(res.refId, createWeakRef(newRef));
          return newRef;
      }
      function createRef(refId) {
          if (!refid2eventMap.has(refId)) {
              refid2eventMap.set(refId, []);
          }
          const subscribers = refid2eventMap.get(refId);
          function invokeRef(name, data, opts) {
              return invoke({
                  type: 'ref.call',
                  refId,
                  name,
                  data
              }, opts);
          }
          function subscribeRef(fn) {
              subscribers.push(fn);
              return ()=>{
                  const index = subscribers.indexOf(fn);
                  if (index >= 0) {
                      subscribers.splice(index, 1);
                  }
              };
          }
          return {
              frame,
              invoke: invokeRef,
              subscribe: subscribeRef
          };
      }
      return {
          get: getRef
      };
  });

  function createSymbolKey(name) {
      if (typeof Symbol === 'function') {
          return Symbol(name);
      }
      return name;
  }

  /// <reference types="../../../types/arraybuffer.d.ts" />
  const MIN_PAGE_SIZE = 64 * 1024;
  const MAX_PAGE_SIZE = 1024 * 1024;
  class BufferList {
      concat() {
          if (this.list.length === 1) {
              return stabilizeBufferItem(this.current);
          }
          const result = new Uint8Array(this.list.reduce((total, item)=>total + item.offset, 0));
          this.list.reduce((offset, item)=>{
              result.set(new Uint8Array(stabilizeBufferItem(item)), offset);
              return offset + item.offset;
          }, 0);
          return result.buffer;
      }
      ensureCapacity(size) {
          const current = this.current;
          const minNewSize = current.offset + size;
          if (minNewSize <= current.size) {
              return;
          }
          const buffer = current.buffer;
          if (!buffer.resizable || minNewSize > buffer.maxByteLength) {
              this.current = this.createBufferItem();
              this.list.push(this.current);
          } else {
              current.size = Math.min(current.size * 2, buffer.maxByteLength);
              buffer.resize(current.size);
          }
      }
      createBufferItem() {
          const buffer = new ArrayBuffer(MIN_PAGE_SIZE, {
              maxByteLength: MAX_PAGE_SIZE
          });
          return {
              view: new DataView(buffer),
              buffer,
              size: buffer.byteLength,
              offset: 0
          };
      }
      constructor(){
          _define_property(this, "list", void 0);
          _define_property(this, "current", void 0);
          this.current = this.createBufferItem();
          this.list = [
              this.current
          ];
      }
  }
  function stabilizeBufferItem(item) {
      if (item.offset >= item.size) {
          return item.buffer;
      }
      if (item.buffer.resizable && item.buffer.transfer) {
          return item.buffer.transfer(item.offset);
      }
      return item.buffer.slice(0, item.offset);
  }

  const MIN_INT32 = -Math.pow(2, 31);
  const MAX_INT32 = Math.pow(2, 31);
  function create() {
      return {
          buffer: new BufferList(),
          values: [],
          stringIndexMap: new Map()
      };
  }
  function encode(state) {
      return {
          buffer: state.buffer.concat(),
          values: state.values
      };
  }
  function uint8(state, value) {
      state.buffer.ensureCapacity(1);
      const current = state.buffer.current;
      current.view.setUint8(current.offset, value);
      current.offset += 1;
  }
  function int32(state, value) {
      state.buffer.ensureCapacity(4);
      const current = state.buffer.current;
      current.view.setInt32(current.offset, value);
      current.offset += 4;
  }
  function uint32(state, value) {
      state.buffer.ensureCapacity(4);
      const current = state.buffer.current;
      current.view.setUint32(current.offset, value);
      current.offset += 4;
  }
  function float64(state, value) {
      state.buffer.ensureCapacity(8);
      const current = state.buffer.current;
      current.view.setFloat64(current.offset, value);
      current.offset += 8;
  }
  function string(state, value) {
      let index = state.stringIndexMap.get(value);
      if (!index) {
          index = state.values.push(value);
          state.stringIndexMap.set(value, index);
      }
      uint32(state, index - 1);
  }
  function unknown(state, value) {
      uint32(state, state.values.push(value) - 1);
  }
  function variant(state, value) {
      if (value === null) {
          uint8(state, 4);
          return;
      }
      switch(typeof value){
          case 'number':
              if (isInt32(value)) {
                  uint8(state, 1);
                  int32(state, value);
                  break;
              }
              uint8(state, 2);
              float64(state, value);
              break;
          case 'string':
              uint8(state, 6);
              string(state, value);
              break;
          case 'boolean':
              uint8(state, 3);
              uint8(state, value ? 1 : 0);
              break;
          case 'undefined':
              uint8(state, 5);
              break;
          default:
              uint8(state, 6);
              unknown(state, value);
              break;
      }
  }
  function isInt32(value) {
      if (!Number.isInteger(value)) {
          return false;
      }
      return MIN_INT32 <= value && value < MAX_INT32;
  }

  const KEY_REFLECT_ID = createSymbolKey('__WECOM_REFLECT_ID__');
  const useReflectStore = createPlugin(({ invoke })=>{
      const finalizationRegistry = typeof FinalizationRegistry === 'function' ? new FinalizationRegistry(cleanup) : null;
      // WHY: weakSet.has(obj) + obj[key] 速度远快于 weakMap.get(obj)
      const reflectObjectSet = new WeakSet();
      let nextReflectId = 1;
      const flushPromise = Promise.resolve();
      let flushPending = false;
      let writer = create();
      function bind(obj, reflectId = genReflectId()) {
          if (reflectObjectSet.has(obj)) {
              return obj[KEY_REFLECT_ID];
          }
          obj[KEY_REFLECT_ID] = reflectId;
          reflectObjectSet.add(obj);
          finalizationRegistry?.register(obj, reflectId);
          return reflectId;
      }
      function set(obj, name, value) {
          const refId = obj[KEY_REFLECT_ID];
          if (!refId) {
              throw new TypeError('Illegal invocation');
          }
          uint8(writer, 1);
          uint32(writer, refId);
          string(writer, name);
          writeCustomValue(value);
          enqueueFlush();
      }
      function call(obj, name, args, result) {
          const refId = obj[KEY_REFLECT_ID];
          if (!refId) {
              throw new TypeError('Illegal invocation');
          }
          uint8(writer, 2);
          uint32(writer, refId);
          string(writer, name);
          uint32(writer, (result ? result[KEY_REFLECT_ID] : 0) ?? 0);
          uint32(writer, args.length);
          args.forEach(writeCustomValue);
          enqueueFlush();
      }
      function cleanup(refId) {
          uint8(writer, 3);
          uint32(writer, refId);
          enqueueFlush();
      }
      function writeCustomValue(value) {
          if (reflectObjectSet.has(value)) {
              uint8(writer, 2);
              uint32(writer, value[KEY_REFLECT_ID]);
          } else {
              uint8(writer, 1);
              variant(writer, value);
          }
      }
      function enqueueFlush() {
          if (flushPending) {
              return;
          }
          flushPending = true;
          flushPromise.then(flush);
      }
      function flush() {
          flushPending = false;
          const commands = encode(writer);
          writer = create();
          invoke({
              type: 'reflect.command',
              commands
          }, {
              serialize: false,
              dropResult: true,
              transfer: [
                  commands.buffer
              ]
          });
      }
      function genReflectId() {
          return nextReflectId++;
      }
      return {
          genReflectId,
          bind,
          set,
          call
      };
  });

  function _class_apply_descriptor_get(receiver, descriptor) {
      if (descriptor.get) return descriptor.get.call(receiver);

      return descriptor.value;
  }

  function _class_extract_field_descriptor(receiver, privateMap, action) {
      if (!privateMap.has(receiver)) throw new TypeError("attempted to " + action + " private field on non-instance");

      return privateMap.get(receiver);
  }

  function _class_private_field_get(receiver, privateMap) {
      var descriptor = _class_extract_field_descriptor(receiver, privateMap, "get");
      return _class_apply_descriptor_get(receiver, descriptor);
  }

  function _check_private_redeclaration(obj, privateCollection) {
      if (privateCollection.has(obj)) {
          throw new TypeError("Cannot initialize the same private elements twice on an object");
      }
  }

  function _class_private_field_init(obj, privateMap, value) {
      _check_private_redeclaration(obj, privateMap);
      privateMap.set(obj, value);
  }

  function _class_apply_descriptor_set(receiver, descriptor, value) {
      if (descriptor.set) descriptor.set.call(receiver, value);
      else {
          if (!descriptor.writable) {
              // This should only throw in strict mode, but class bodies are
              // always strict and private fields can only be used inside
              // class bodies.
              throw new TypeError("attempted to set read only private field");
          }
          descriptor.value = value;
      }
  }

  function _class_private_field_set(receiver, privateMap, value) {
      var descriptor = _class_extract_field_descriptor(receiver, privateMap, "set");
      _class_apply_descriptor_set(receiver, descriptor, value);
      return value;
  }

  const wrapper2NativeMap = new WeakMap();
  const native2wrapperMap = new WeakMap();
  function setNativeObject(wrapped, native) {
      wrapper2NativeMap.set(wrapped, native);
      native2wrapperMap.set(native, wrapped);
  }
  function toNativeValue(wrapped) {
      if (wrapper2NativeMap.has(wrapped)) {
          return wrapper2NativeMap.get(wrapped);
      }
      return wrapped;
  }
  function toWrappedValue(native) {
      if (native2wrapperMap.has(native)) {
          return native2wrapperMap.get(native);
      }
      return native;
  }

  const PLACEHOLDER_SRC = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7';
  let placeholderImage = null;
  function getPlaceholderImage() {
      if (!placeholderImage) {
          placeholderImage = new Image();
          placeholderImage.src = PLACEHOLDER_SRC;
      }
      return placeholderImage;
  }

  var _src = /*#__PURE__*/ new WeakMap(), _complete = /*#__PURE__*/ new WeakMap(), _error = /*#__PURE__*/ new WeakMap();
  let _KEY_REFLECT_ID$3 = KEY_REFLECT_ID;
  class ImageResource {
      get src() {
          return _class_private_field_get(this, _src);
      }
      get loading() {
          return !_class_private_field_get(this, _complete);
      }
      get complete() {
          return _class_private_field_get(this, _complete);
      }
      get error() {
          return _class_private_field_get(this, _error);
      }
      __handleSettled(error) {
          _class_private_field_set(this, _complete, true);
          _class_private_field_set(this, _error, error);
          if (error) {
              safeRun(this.onerror, error);
          } else {
              safeRun(this.onload, undefined);
          }
      }
      constructor(src){
          _define_property(this, _KEY_REFLECT_ID$3, void 0);
          _define_property(this, "onload", void 0);
          _define_property(this, "onerror", void 0);
          _class_private_field_init(this, _src, {
              writable: true,
              value: void 0
          });
          _class_private_field_init(this, _complete, {
              writable: true,
              value: false
          });
          _class_private_field_init(this, _error, {
              writable: true,
              value: void 0
          });
          _class_private_field_set(this, _src, src);
          setNativeObject(this, getPlaceholderImage());
      }
  }

  const useImageStore = createPlugin(({ frame, invoke, subscribe })=>{
      const reflectStore = useReflectStore(frame);
      const imageSettledHandlerMap = new Map();
      function createImage(data, type) {
          const res = new ImageResource(data);
          const refId = reflectStore.bind(res);
          invoke({
              type: 'image.load',
              refId,
              data: getImageInfo(data, type)
          }, {
              serialize: typeof data === 'string'
          });
          imageSettledHandlerMap.set(refId, (msg)=>{
              res.__handleSettled(msg.error);
          });
          return res;
      }
      function getImageInfo(data, mime) {
          if (typeof data === 'string') {
              return {
                  type: 'url',
                  src: data
              };
          }
          return {
              type: 'arraybuffer',
              data,
              mime
          };
      }
      subscribe('image.settled', (msg)=>{
          const handler = imageSettledHandlerMap.get(msg.refId);
          imageSettledHandlerMap.delete(msg.refId);
          if (handler) {
              handler(msg);
          }
      });
      return {
          createImage
      };
  });

  const useRefEventManager = createSingleton((ref)=>{
      const listenerMap = new Map();
      ref.subscribe((msg)=>{
          if (msg.type !== 'event.trigger') {
              return;
          }
          const listeners = listenerMap.get(`${msg.capture}|${msg.name}`);
          if (!listeners?.size) {
              return;
          }
          const event = createCustomEvent(msg.event);
          for (const listener of Array.from(listeners)){
              safeRun(listener, event);
          }
      });
      function addListener(name, listener, options) {
          const capture = typeof options === 'boolean' ? options : !!options?.capture;
          if (!listenerMap.has(`${capture}|${name}`)) {
              listenerMap.set(`${capture}|${name}`, new Set());
          }
          const listeners = listenerMap.get(`${capture}|${name}`);
          if (!listeners.size) {
              ref.invoke('event.subscribe', {
                  name,
                  capture
              });
          }
          listeners.add(listener);
      }
      function removeListener(name, listener, options) {
          const capture = typeof options === 'boolean' ? options : !!options?.capture;
          if (!listenerMap.has(`${capture}|${name}`)) {
              return;
          }
          const listeners = listenerMap.get(`${capture}|${name}`);
          listeners.delete(listener);
          if (!listeners.size) {
              ref.invoke('event.unsubscribe', {
                  name,
                  capture
              });
          }
      }
      return {
          addListener,
          removeListener
      };
  });
  function createCustomEvent(info) {
      const event = new CustomEvent(info.type, {
          detail: info.detail
      });
      for (const key of Object.keys(info)){
          if (!(key in event)) {
              event[key] = info[key];
          }
      }
      Object.defineProperties(event, {
          target: {
              value: info.target
          },
          currentTarget: {
              value: info.currentTarget
          }
      });
      return event;
  }

  var _store$1 = /*#__PURE__*/ new WeakMap(), _native$1 = /*#__PURE__*/ new WeakMap();
  let _KEY_REFLECT_ID$2 = KEY_REFLECT_ID;
  class FrameCanvasPattern {
      setTransform(matrix) {
          _class_private_field_get(this, _native$1).setTransform(matrix);
          _class_private_field_get(this, _store$1).call(this, 'setTransform', [
              matrix
          ]);
      }
      constructor(store, native){
          _define_property(this, _KEY_REFLECT_ID$2, void 0);
          _class_private_field_init(this, _store$1, {
              writable: true,
              value: void 0
          });
          _class_private_field_init(this, _native$1, {
              writable: true,
              value: void 0
          });
          _class_private_field_set(this, _store$1, store);
          _class_private_field_set(this, _native$1, native);
          store.bind(this);
          setNativeObject(this, native);
      }
  }
  var _store1 = /*#__PURE__*/ new WeakMap(), _native1 = /*#__PURE__*/ new WeakMap();
  let _KEY_REFLECT_ID1 = KEY_REFLECT_ID;
  class FrameCanvasGradient {
      addColorStop(offset, color) {
          _class_private_field_get(this, _native1).addColorStop(offset, color);
          _class_private_field_get(this, _store1).call(this, 'addColorStop', [
              offset,
              color
          ]);
      }
      constructor(store, native){
          _define_property(this, _KEY_REFLECT_ID1, void 0);
          _class_private_field_init(this, _store1, {
              writable: true,
              value: void 0
          });
          _class_private_field_init(this, _native1, {
              writable: true,
              value: void 0
          });
          _class_private_field_set(this, _store1, store);
          _class_private_field_set(this, _native1, native);
          store.bind(this);
          setNativeObject(this, native);
      }
  }

  /**
   * 纯样式属性
   *
   * 修改这些属性不会改变 CANVAS_LOCAL_METHODS 的表现，因此无需映射到 native object
   */ const CANVAS_STYLE_PROPS = [
      'fillStyle',
      'filter',
      'globalAlpha',
      'globalCompositeOperation',
      'imageSmoothingEnabled',
      'imageSmoothingQuality',
      'shadowBlur',
      'shadowColor',
      'shadowOffsetX',
      'shadowOffsetY',
      'strokeStyle'
  ];
  const CANVAS_CONFIG_PROPS = [
      'direction',
      'font',
      'fontKerning',
      'fontStretch',
      'fontVariantCaps',
      'letterSpacing',
      'lineCap',
      'lineDashOffset',
      'lineJoin',
      'lineWidth',
      'miterLimit',
      'textAlign',
      'textBaseline',
      'textRendering',
      'wordSpacing'
  ];
  const CANVAS_CONFIG_METHODS = [
      'arc',
      'arcTo',
      'beginPath',
      'bezierCurveTo',
      'clip',
      'closePath',
      'ellipse',
      'lineTo',
      'moveTo',
      'quadraticCurveTo',
      'rect',
      'reset',
      'resetTransform',
      'restore',
      'rotate',
      'roundRect',
      'save',
      'scale',
      'setLineDash',
      'setTransform',
      'transform',
      'translate'
  ];
  const CANVAS_DRAW_METHODS = [
      'clearRect',
      'drawFocusIfNeeded',
      'drawImage',
      'fill',
      'fillRect',
      'fillText',
      'stroke',
      'strokeRect',
      'strokeText'
  ];
  const CANVAS_LOCAL_METHODS = [
      'getContextAttributes',
      'getLineDash',
      'getTransform',
      'isContextLost',
      'isPointInPath',
      'isPointInStroke',
      'measureText'
  ];
  const CANVAS_FACTORY_METHODS = [
      [
          'createConicGradient',
          FrameCanvasGradient
      ],
      [
          'createLinearGradient',
          FrameCanvasGradient
      ],
      [
          'createPattern',
          FrameCanvasPattern
      ],
      [
          'createRadialGradient',
          FrameCanvasGradient
      ]
  ];

  const KEY_INTERNAL = createSymbolKey('__WECOM_INTERNAL__');
  const createFrameContext = createSingleton((canvas, store, native)=>new FrameCanvasRenderingContext2D(canvas, store, native));
  let _KEY_INTERNAL = KEY_INTERNAL, _KEY_REFLECT_ID$1 = KEY_REFLECT_ID;
  class FrameCanvasRenderingContext2D {
      constructor(canvas, store, native){
          _define_property(this, "canvas", void 0);
          _define_property(this, _KEY_INTERNAL, void 0);
          _define_property(this, _KEY_REFLECT_ID$1, void 0);
          this.canvas = canvas;
          this[KEY_INTERNAL] = {
              store,
              native,
              props: Object.create(null)
          };
          store.bind(this);
          setNativeObject(this, native);
      }
  }
  const FrameContextProto = FrameCanvasRenderingContext2D.prototype;
  for (const name of CANVAS_STYLE_PROPS){
      Object.defineProperty(FrameContextProto, name, {
          configurable: true,
          enumerable: true,
          get () {
              const { native, props } = this[KEY_INTERNAL];
              return props[name] ?? toWrappedValue(native[name]);
          },
          set (value) {
              const { store, props } = this[KEY_INTERNAL];
              props[name] = toNativeValue(value);
              store.set(this, name, value);
          }
      });
  }
  for (const name of CANVAS_CONFIG_PROPS){
      Object.defineProperty(FrameContextProto, name, {
          configurable: true,
          enumerable: true,
          get () {
              return toWrappedValue(this[KEY_INTERNAL].native[name]);
          },
          set (value) {
              const { store, native } = this[KEY_INTERNAL];
              native[name] = toNativeValue(value);
              store.set(this, name, value);
          }
      });
  }
  for (const name of CANVAS_LOCAL_METHODS){
      FrameContextProto[name] = function(...args) {
          const { native } = this[KEY_INTERNAL];
          return callNative(native, name, args);
      };
  }
  for (const name of CANVAS_CONFIG_METHODS){
      FrameContextProto[name] = function(...args) {
          const { store, native } = this[KEY_INTERNAL];
          callNative(native, name, args);
          store.call(this, name, args);
      };
  }
  for (const name of CANVAS_DRAW_METHODS){
      FrameContextProto[name] = function(...args) {
          const { store } = this[KEY_INTERNAL];
          store.call(this, name, args);
      };
  }
  for (const [name, Ctor] of CANVAS_FACTORY_METHODS){
      FrameContextProto[name] = function(...args) {
          const { store, native } = this[KEY_INTERNAL];
          const nativeRes = callNative(native, name, args);
          const frameRes = new Ctor(store, nativeRes);
          store.call(this, name, args, frameRes);
          return frameRes;
      };
  }
  function callNative(native, name, args) {
      switch(args.length){
          case 1:
              return native[name](args[0]);
          case 2:
              return native[name](args[0], args[1]);
          case 3:
              return native[name](args[0], args[1], args[2]);
          case 4:
              return native[name](args[0], args[1], args[2], args[3]);
          case 5:
              return native[name](args[0], args[1], args[2], args[3], args[4]);
          case 6:
              return native[name](args[0], args[1], args[2], args[3], args[4], args[5]);
          default:
              return native[name](...args);
      }
  }

  var _native = /*#__PURE__*/ new WeakMap(), _store = /*#__PURE__*/ new WeakMap(), _imageStore = /*#__PURE__*/ new WeakMap(), _refEvent = /*#__PURE__*/ new WeakMap(), _context = /*#__PURE__*/ new WeakMap();
  let _KEY_REFLECT_ID = KEY_REFLECT_ID;
  class FrameCanvas {
      /**
     * canvas 元素宽度
     */ get width() {
          return _class_private_field_get(this, _native).width;
      }
      set width(value) {
          _class_private_field_get(this, _native).width = value;
          _class_private_field_get(this, _store).set(this, 'width', value);
      }
      /**
     * canvas 元素高度
     */ get height() {
          return _class_private_field_get(this, _native).height;
      }
      set height(value) {
          _class_private_field_get(this, _native).height = value;
          _class_private_field_get(this, _store).set(this, 'height', value);
      }
      createImage(data, type) {
          return _class_private_field_get(this, _imageStore).createImage(data, type);
      }
      /**
     * 获取 canvas 的上下文
     *
     * @param type 上下文类型，目前只支持 2d
     * @param attrs 渲染上下文配置
     */ getContext(type, attrs) {
          if (type !== '2d') {
              throw new Error(`Failed to execute 'getContext' on 'FrameCanvas': The provided value '${type}' is not a valid enum value of type RenderingContextType`);
          }
          if (_class_private_field_get(this, _context)) {
              return _class_private_field_get(this, _context);
          }
          const nativeContext = _class_private_field_get(this, _native).getContext(type, attrs);
          _class_private_field_set(this, _context, createFrameContext(this, _class_private_field_get(this, _store), nativeContext));
          _class_private_field_get(this, _store).call(this, 'getContext', [
              type,
              attrs
          ], _class_private_field_get(this, _context));
          return _class_private_field_get(this, _context);
      }
      addEventListener(type, listener, options) {
          _class_private_field_get(this, _refEvent).addListener(type, listener, options);
      }
      removeEventListener(type, listener, options) {
          _class_private_field_get(this, _refEvent).removeListener(type, listener, options);
      }
      constructor(ref, refId, info){
          /** @internal */ _define_property(this, _KEY_REFLECT_ID, void 0);
          _class_private_field_init(this, _native, {
              writable: true,
              value: void 0
          });
          _class_private_field_init(this, _store, {
              writable: true,
              value: void 0
          });
          _class_private_field_init(this, _imageStore, {
              writable: true,
              value: void 0
          });
          _class_private_field_init(this, _refEvent, {
              writable: true,
              value: void 0
          });
          _class_private_field_init(this, _context, {
              writable: true,
              value: void 0
          });
          _class_private_field_set(this, _native, new OffscreenCanvas(info.width, info.height));
          _class_private_field_set(this, _store, useReflectStore(ref.frame));
          _class_private_field_get(this, _store).bind(this, refId);
          _class_private_field_set(this, _imageStore, useImageStore(ref.frame));
          _class_private_field_set(this, _refEvent, useRefEventManager(ref));
          setNativeObject(this, _class_private_field_get(this, _native));
      }
  }

  const ref2canvasMap = new WeakMap();
  const getCanvasId = createSingleton((ref)=>{
      const { genReflectId } = useReflectStore(ref.frame);
      return genReflectId();
  });
  /**
   * 获取 open-data frame 组件内的 canvas 元素。
   *
   * @param instance open-data frame 组件实例
   * @param refName 模板引用名称
   *
   * @example
   * ```ts
   * const canvas = await ww.getCanvas(frame, 'canvas')
   * const context = canvas.getContext('2d')
   * ```
   */ async function getCanvas(instance, refName) {
      const { get: getRef } = useRefManager(instance);
      const ref = await getRef(refName);
      if (!ref) {
          return;
      }
      if (ref2canvasMap.has(ref)) {
          return ref2canvasMap.get(ref);
      }
      const refId = getCanvasId(ref);
      const info = await ref.invoke('bind', {
          refId
      });
      if (!info) {
          return;
      }
      if (!ref2canvasMap.has(ref)) {
          ref2canvasMap.set(ref, new FrameCanvas(ref, refId, info));
      }
      return ref2canvasMap.get(ref);
  }

  const getScrollViewContext = createSingleton((ref)=>{
      return {
          scrollTo (options) {
              ref.invoke('scrollTo', options);
          },
          scrollIntoView (selector, options) {
              ref.invoke('scrollIntoView', {
                  selector,
                  options
              });
          }
      };
  });
  /**
   * 创建 open-data frame 组件内指定 scroll-view 元素的上下文。
   *
   * @param instance open-data frame 组件实例
   * @param refName 模板引用名称
   *
   * @example
   * ```ts
   * const scrollView = await ww.createScrollViewContext(instance, 'scroll-view')
   *
   * scrollView.scrollTo({ top: 100 })
   * ```
   */ async function createScrollViewContext(instance, refName) {
      const { get: getRef } = useRefManager(instance);
      const ref = await getRef(refName);
      if (!ref) {
          return;
      }
      return getScrollViewContext(ref);
  }

  /**
   * 获取节点的相关信息
   *
   * @param instance open-data frame 组件实例
   * @param refName 模板引用名称
   * @param fields 需要获取的字段
   *
   * @example
   * ```ts
   * ww.getNodeInfo(instance, 'node-ref')
   * ```
   */ async function getNodeInfo(instance, refName, fields) {
      const { get: getRef } = useRefManager(instance);
      const ref = await getRef(refName);
      if (!ref) {
          return;
      }
      return ref.invoke('nodeInfo.get', {
          fields
      });
  }

  /**
   * From https://gist.github.com/schacon/12703
   */ function hex_sha1(s) {
      return rstr2hex(rstr_sha1(s));
  }
  /**
   * Calculate the SHA1 of a raw string
   */ function rstr_sha1(s) {
      return binb2rstr(binb_sha1(rstr2binb(s), s.length * 8));
  }
  /**
   * Convert a raw string to a hex string
   */ function rstr2hex(input) {
      const hex_tab = '0123456789abcdef';
      let output = '';
      let x;
      for(let i = 0; i < input.length; i++){
          x = input.charCodeAt(i);
          output += hex_tab.charAt(x >>> 4 & 0x0f) + hex_tab.charAt(x & 0x0f);
      }
      return output;
  }
  /**
   * Convert a raw string to an array of big-endian words
   * Characters >255 have their high-byte silently ignored.
   */ function rstr2binb(input) {
      const output = new Array(input.length >> 2);
      for(let i = 0; i < output.length; i++)output[i] = 0;
      for(let i = 0; i < input.length * 8; i += 8)output[i >> 5] |= (input.charCodeAt(i / 8) & 0xff) << 24 - i % 32;
      return output;
  }
  /**
   * Convert an array of little-endian words to a string
   */ function binb2rstr(input) {
      let output = '';
      for(let i = 0; i < input.length * 32; i += 8)output += String.fromCharCode(input[i >> 5] >>> 24 - i % 32 & 0xff);
      return output;
  }
  /**
   * Calculate the SHA-1 of an array of big-endian words, and a bit length
   */ function binb_sha1(x, len) {
      /* append padding */ x[len >> 5] |= 0x80 << 24 - len % 32;
      x[(len + 64 >> 9 << 4) + 15] = len;
      const w = new Array(80);
      let a = 1732584193;
      let b = -271733879;
      let c = -1732584194;
      let d = 271733878;
      let e = -1009589776;
      for(let i = 0; i < x.length; i += 16){
          const olda = a;
          const oldb = b;
          const oldc = c;
          const oldd = d;
          const olde = e;
          for(let j = 0; j < 80; j++){
              if (j < 16) w[j] = x[i + j];
              else w[j] = bit_rol(w[j - 3] ^ w[j - 8] ^ w[j - 14] ^ w[j - 16], 1);
              const t = safe_add(safe_add(bit_rol(a, 5), sha1_ft(j, b, c, d)), safe_add(safe_add(e, w[j]), sha1_kt(j)));
              e = d;
              d = c;
              c = bit_rol(b, 30);
              b = a;
              a = t;
          }
          a = safe_add(a, olda);
          b = safe_add(b, oldb);
          c = safe_add(c, oldc);
          d = safe_add(d, oldd);
          e = safe_add(e, olde);
      }
      return [
          a,
          b,
          c,
          d,
          e
      ];
  }
  /**
   * Perform the appropriate triplet combination function for the current
   * iteration
   */ function sha1_ft(t, b, c, d) {
      if (t < 20) return b & c | ~b & d;
      if (t < 40) return b ^ c ^ d;
      if (t < 60) return b & c | b & d | c & d;
      return b ^ c ^ d;
  }
  /**
   * Determine the appropriate additive constant for the current iteration
   */ function sha1_kt(t) {
      return t < 20 ? 1518500249 : t < 40 ? 1859775393 : t < 60 ? -1894007588 : -899497514;
  }
  /**
   * Add integers, wrapping at 2^32. This uses 16-bit operations internally
   * to work around bugs in some JS interpreters.
   */ function safe_add(x, y) {
      const lsw = (x & 0xffff) + (y & 0xffff);
      const msw = (x >> 16) + (y >> 16) + (lsw >> 16);
      return msw << 16 | lsw & 0xffff;
  }
  /**
   * Bitwise rotate a 32-bit number to the left.
   */ function bit_rol(num, cnt) {
      return num << cnt | num >>> 32 - cnt;
  }

  function getSignature(options) {
      let normalized = options;
      if (typeof options === 'string') {
          normalized = {
              ticket: options
          };
      }
      const nonceStr = normalized.nonceStr || random();
      const timestamp = normalized.timestamp || Math.floor(Date.now() / 1000);
      const url = normalized.url || getHref().split('#')[0];
      const ticket = normalized.ticket;
      const signature = hex_sha1(`jsapi_ticket=${ticket}&noncestr=${nonceStr}&timestamp=${timestamp}&url=${url}`);
      return {
          timestamp,
          nonceStr,
          signature
      };
  }

  const env = {
      isWeChat,
      isWeCom
  };
  const IS_WECOM_SDK = true;

  exports.CameraMode = CameraMode;
  exports.ChooseMessageFileType = ChooseMessageFileType;
  exports.ColorScheme = ColorScheme;
  exports.CreateExternalPaymentType = CreateExternalPaymentType;
  exports.DatazoneDocType = DatazoneDocType;
  exports.EntryType = EntryType;
  exports.EnvVersion = EnvVersion;
  exports.FrameCanvas = FrameCanvas;
  exports.IS_WECOM_SDK = IS_WECOM_SDK;
  exports.InTalkType = InTalkType;
  exports.InputCorpGroupContactMode = InputCorpGroupContactMode;
  exports.InputCorpGroupContactType = InputCorpGroupContactType;
  exports.LiveType = LiveType;
  exports.LocationType = LocationType;
  exports.NetworkType = NetworkType;
  exports.OAType = OAType;
  exports.OaExtDataType = OaExtDataType;
  exports.OpenAppManagePageType = OpenAppManagePageType;
  exports.OpenUserProfileType = OpenUserProfileType;
  exports.PrintFileIdType = PrintFileIdType;
  exports.ProductViewType = ProductViewType;
  exports.Proximity = Proximity;
  exports.SDK_VERSION = SDK_VERSION;
  exports.ScanQRCodeType = ScanQRCodeType;
  exports.SelectEnterpriseContactMode = SelectEnterpriseContactMode;
  exports.SelectEnterpriseContactType = SelectEnterpriseContactType;
  exports.SelectExternalContactType = SelectExternalContactType;
  exports.SelectPrivilegedContactMode = SelectPrivilegedContactMode;
  exports.SizeType = SizeType;
  exports.SourceType = SourceType;
  exports.TempFileType = TempFileType;
  exports.WWLoginLangType = WWLoginLangType;
  exports.WWLoginPanelSizeType = WWLoginPanelSizeType;
  exports.WWLoginRedirectType = WWLoginRedirectType;
  exports.WWLoginType = WWLoginType;
  exports.WedocSelectedFileType = WedocSelectedFileType;
  exports.addCard = addCard;
  exports.addDevice = addDevice;
  exports.checkJsApi = checkJsApi;
  exports.checkSchedule = checkSchedule;
  exports.chooseCard = chooseCard;
  exports.chooseImage = chooseImage;
  exports.chooseInvoice = chooseInvoice;
  exports.chooseMessageFile = chooseMessageFile;
  exports.chooseWXPay = chooseWXPay;
  exports.claimClassAdmin = claimClassAdmin;
  exports.closeBLEConnection = closeBLEConnection;
  exports.closeBluetoothAdapter = closeBluetoothAdapter;
  exports.closeWindow = closeWindow;
  exports.connectWifi = connectWifi;
  exports.consumeAndShareCard = consumeAndShareCard;
  exports.createBLEConnection = createBLEConnection;
  exports.createChatWithMsg = createChatWithMsg;
  exports.createCorpGroupChat = createCorpGroupChat;
  exports.createDoc = createDoc;
  exports.createExternalPayment = createExternalPayment;
  exports.createJSAPIPanel = createJSAPIPanel;
  exports.createOpenDataFrameFactory = createOpenDataFrameFactory;
  exports.createSchoolPayment = createSchoolPayment;
  exports.createScrollViewContext = createScrollViewContext;
  exports.createTodo = createTodo;
  exports.createWWLoginPanel = createWWLoginPanel;
  exports.discoverDevice = discoverDevice;
  exports.downloadImage = downloadImage;
  exports.downloadLivingReplay = downloadLivingReplay;
  exports.downloadVoice = downloadVoice;
  exports.ensureAgentConfigReady = ensureAgentConfigReady;
  exports.ensureConfigReady = ensureConfigReady;
  exports.ensureCorpConfigReady = ensureCorpConfigReady;
  exports.enterHWOpenTalk = enterHWOpenTalk;
  exports.enterpriseVerify = enterpriseVerify;
  exports.env = env;
  exports.getApprovalSelectedItems = getApprovalSelectedItems;
  exports.getBLEDeviceCharacteristics = getBLEDeviceCharacteristics;
  exports.getBLEDeviceServices = getBLEDeviceServices;
  exports.getBeacons = getBeacons;
  exports.getBluetoothAdapterState = getBluetoothAdapterState;
  exports.getBluetoothDevices = getBluetoothDevices;
  exports.getCanvas = getCanvas;
  exports.getClipboardData = getClipboardData;
  exports.getConnectedBluetoothDevices = getConnectedBluetoothDevices;
  exports.getConnectedWifi = getConnectedWifi;
  exports.getContext = getContext;
  exports.getCurCorpGroupChat = getCurCorpGroupChat;
  exports.getCurCorpGroupContact = getCurCorpGroupContact;
  exports.getCurExternalChat = getCurExternalChat;
  exports.getCurExternalContact = getCurExternalContact;
  exports.getLocalFileData = getLocalFileData;
  exports.getLocalImgData = getLocalImgData;
  exports.getLocation = getLocation;
  exports.getNetworkType = getNetworkType;
  exports.getNodeInfo = getNodeInfo;
  exports.getShareInfo = getShareInfo;
  exports.getSignature = getSignature;
  exports.getVerifyParams = getVerifyParams;
  exports.getWifiList = getWifiList;
  exports.hideAllNonBaseMenuItem = hideAllNonBaseMenuItem;
  exports.hideChatAttachmentMenu = hideChatAttachmentMenu;
  exports.hideMenuItems = hideMenuItems;
  exports.hideOptionMenu = hideOptionMenu;
  exports.initOpenData = initOpenData;
  exports.invoke = invoke;
  exports.launchMiniprogram = launchMiniprogram;
  exports.navigateToAddCustomer = navigateToAddCustomer;
  exports.navigateToKfChat = navigateToKfChat;
  exports.notifyBLECharacteristicValueChange = notifyBLECharacteristicValueChange;
  exports.on = on;
  exports.onBLECharacteristicValueChange = onBLECharacteristicValueChange;
  exports.onBLEConnectionStateChange = onBLEConnectionStateChange;
  exports.onBeaconServiceChange = onBeaconServiceChange;
  exports.onBeaconUpdate = onBeaconUpdate;
  exports.onBluetoothAdapterStateChange = onBluetoothAdapterStateChange;
  exports.onBluetoothDeviceFound = onBluetoothDeviceFound;
  exports.onGetWifiList = onGetWifiList;
  exports.onHistoryBack = onHistoryBack;
  exports.onLocationChange = onLocationChange;
  exports.onMenuShareAppMessage = onMenuShareAppMessage;
  exports.onMenuShareQQ = onMenuShareQQ;
  exports.onMenuShareQZone = onMenuShareQZone;
  exports.onMenuShareTimeline = onMenuShareTimeline;
  exports.onMenuShareWechat = onMenuShareWechat;
  exports.onMenuShareWeibo = onMenuShareWeibo;
  exports.onNetworkStatusChange = onNetworkStatusChange;
  exports.onSearchBeacons = onSearchBeacons;
  exports.onUserCaptureScreen = onUserCaptureScreen;
  exports.onVoicePlayEnd = onVoicePlayEnd;
  exports.onVoiceRecordEnd = onVoiceRecordEnd;
  exports.onWifiConnected = onWifiConnected;
  exports.openAddress = openAddress;
  exports.openAppComment = openAppComment;
  exports.openAppDeviceDataAuth = openAppDeviceDataAuth;
  exports.openAppManage = openAppManage;
  exports.openAppPurchase = openAppPurchase;
  exports.openBluetoothAdapter = openBluetoothAdapter;
  exports.openBusinessView = openBusinessView;
  exports.openCard = openCard;
  exports.openDefaultBrowser = openDefaultBrowser;
  exports.openDeviceProfile = openDeviceProfile;
  exports.openEnterpriseChat = openEnterpriseChat;
  exports.openEnterpriseRedPacket = openEnterpriseRedPacket;
  exports.openExistedChatWithMsg = openExistedChatWithMsg;
  exports.openLocation = openLocation;
  exports.openProductSpecificView = openProductSpecificView;
  exports.openThirdAppServiceChat = openThirdAppServiceChat;
  exports.openUserProfile = openUserProfile;
  exports.pauseVoice = pauseVoice;
  exports.playVoice = playVoice;
  exports.previewFile = previewFile;
  exports.previewImage = previewImage;
  exports.printFile = printFile;
  exports.queryCurrHWOpenTalk = queryCurrHWOpenTalk;
  exports.readBLECharacteristicValue = readBLECharacteristicValue;
  exports.refundExternalPayment = refundExternalPayment;
  exports.register = register;
  exports.replayLiving = replayLiving;
  exports.saveApprovalSelectedItems = saveApprovalSelectedItems;
  exports.scanQRCode = scanQRCode;
  exports.selectCorpGroupContact = selectCorpGroupContact;
  exports.selectDatazoneDoc = selectDatazoneDoc;
  exports.selectDatazoneFile = selectDatazoneFile;
  exports.selectEnterpriseContact = selectEnterpriseContact;
  exports.selectExternalChat = selectExternalChat;
  exports.selectExternalContact = selectExternalContact;
  exports.selectPrivilegedContact = selectPrivilegedContact;
  exports.sendChatMessage = sendChatMessage;
  exports.setClipboardData = setClipboardData;
  exports.setKeepScreenOn = setKeepScreenOn;
  exports.setShareAttr = setShareAttr;
  exports.shareAppMessage = shareAppMessage;
  exports.shareToExternalChat = shareToExternalChat;
  exports.shareToExternalContact = shareToExternalContact;
  exports.shareToExternalMoments = shareToExternalMoments;
  exports.shareWechatMessage = shareWechatMessage;
  exports.showAllNonBaseMenuItem = showAllNonBaseMenuItem;
  exports.showMenuItems = showMenuItems;
  exports.showOptionMenu = showOptionMenu;
  exports.showSecurityGatewayConfirmModal = showSecurityGatewayConfirmModal;
  exports.startAutoLBS = startAutoLBS;
  exports.startBeaconDiscovery = startBeaconDiscovery;
  exports.startBluetoothDevicesDiscovery = startBluetoothDevicesDiscovery;
  exports.startLiving = startLiving;
  exports.startMeeting = startMeeting;
  exports.startRecord = startRecord;
  exports.startSearchBeacons = startSearchBeacons;
  exports.startWecast = startWecast;
  exports.startWifi = startWifi;
  exports.stopAutoLBS = stopAutoLBS;
  exports.stopBeaconDiscovery = stopBeaconDiscovery;
  exports.stopBluetoothDevicesDiscovery = stopBluetoothDevicesDiscovery;
  exports.stopRecord = stopRecord;
  exports.stopSearchBeacons = stopSearchBeacons;
  exports.stopVoice = stopVoice;
  exports.stopWifi = stopWifi;
  exports.thirdPartyOpenPage = thirdPartyOpenPage;
  exports.translateVoice = translateVoice;
  exports.updateAppMessageShareData = updateAppMessageShareData;
  exports.updateCorpGroupChat = updateCorpGroupChat;
  exports.updateEnterpriseChat = updateEnterpriseChat;
  exports.updateMomentsSetting = updateMomentsSetting;
  exports.updateTimelineShareData = updateTimelineShareData;
  exports.uploadImage = uploadImage;
  exports.uploadVoice = uploadVoice;
  exports.viewTodo = viewTodo;
  exports.wedocSelectDoc = wedocSelectDoc;
  exports.wedriveSelectDir = wedriveSelectDir;
  exports.wedriveSelectFile = wedriveSelectFile;
  exports.wedriveSelectFileForDownload = wedriveSelectFileForDownload;
  exports.wedriveSelectFileForShare = wedriveSelectFileForShare;
  exports.writeBLECharacteristicValue = writeBLECharacteristicValue;

  return exports;

})({});
