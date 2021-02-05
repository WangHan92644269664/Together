
class MinRequest {
  // 默认配置
  config = {
    baseURL: '',
    header: {
      'content-type': 'application/json',
	    'accept':'application/json'
    },
    method: 'GET',
    dataType: 'json',
    responseType: 'text'
  }

  // 拦截器
  interceptors = {
    request: (func) => {
      if (func) {
        MinRequest.requestBefore = func
      } else {
        MinRequest.requestBefore = (request) => request
      }
      
    },
    response: (func) => {
      if (func) {
        MinRequest.requestAfter = func
      } else {
        MinRequest.requestAfter = (response) => response
      }
    }
  }

  static requestBefore (config) {
    return config
  }

  static requestAfter (response) {
    return response
  }

  // 判断url是否完整
  static isCompleteURL (url) {
    return /(http|https):\/\/([\w.]+\/?)\S*/.test(url)
  }

  // 设置配置
  setConfig (func) {
    this.config = func(this.config)
  }

  // 请求
  request (options = {}) {
    // 获取token
    let token = uni.getStorageSync('token')// 获取本地数据缓存
    let pwd = uni.getStorageSync('pwd')
    if(token){
		let url = options.url.split('/')[0]
      if(url==='withdrawals' ||  url==='exchanges' ||url==='pays' ||url==='transfers'){
        options.header = {
            'authorization':'Bearer '+token,
            'trade-password':pwd
        }
      }else{
        options.header = {
          'authorization':'Bearer '+token
        }
      }
    }
    
    if(options.patch){
      options.header = {'X-HTTP-Method-Override':'PATCH','Authorization':`Bearer ${token}`}
    }
    options.baseURL = options.baseURL || this.config.baseURL
    options.dataType = options.dataType || this.config.dataType
    options.url = MinRequest.isCompleteURL(options.url) ? options.url : (options.baseURL + options.url)
    options.data = options.data
    options.header = {...options.header, ...this.config.header}
    options.method = options.method || this.config.method
    options = {...options, ...MinRequest.requestBefore(options)}
    return new Promise((resolve, reject) => {
      options.success = function (res) {
        resolve(MinRequest.requestAfter(res))
      }
      options.fail= function (err) {
        reject(MinRequest.requestAfter(err))
      }
      uni.request(options)
    })
  }
// minRequest.get('announcements?sort=-announcement_update_datetime', data)
// minRequest.get('product-groups?per-page=50&sort=product_group_id', data)
// minRequest.get('products?per-page=6', params)
  get (url, data, options = {}) {
    options.url = url
    options.data = data
    options.method = 'GET'
    return this.request(options)
  }

  post (url, data, options = {}) {
    options.url = url
    options.data = data
    options.method = 'POST'
    return this.request(options)
  }
  put (url, data, options = {}) {
    options.url = url
    options.data = data
    options.method = 'PUT'
    return this.request(options)
  }
  
  patch (url, data, options = {}) {
    options.url = url
    options.data = data
    options.method = 'POST'
    options.patch = true
    return this.request(options)
  }

  put (url, data, options = {}) {
    options.url = url
    options.data = data
    options.method = 'PUT'
    return this.request(options)
  }

  delete (url, data, options = {}) {
    options.url = url
    options.data = data
    options.method = 'DELETE'
    return this.request(options)
  }
}

export default MinRequest
