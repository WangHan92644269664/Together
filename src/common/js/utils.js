// http://coder:9045
		// http://192.168.31.85:8002
		// api.award.youtuoweb.com
		// https://api.youtuosoft.com
		// api.award.youtuoweb.com
		import moment from 'moment'
		const token = uni.getStorageSync('token')
		const code_text = uni.getStorageSync('userInfo').memberinfo_account
		import author from './author.js'

		function Url(url) {
			return process.env.VUE_APP_API_URL + url
		}
		const webImg = process.env.VUE_APP_RECOMMEND_URL
		const imgUrl = process.env.VUE_APP_IMG_URL
		const webImg2 = process.env.VUE_APP_IMG_URL + 'mobile/'
		const classImg = process.env.VUE_APP_IMG_URL + 'product-class/'
		const productImg = process.env.VUE_APP_IMG_URL + 'product/'
		const year = moment().year();
		const month = moment().month() + 1
		const day = moment().date()


		function checkMobile(mobile) {
			return RegExp(/^[1]([3-9])[0-9]{9}$/).test(mobile);
		}

		function sliStr(value) {
			let val = value.length - 4;
			let star = ''
			for (let i = 0; i < val; i++) {
				star += '*'
			}
			return star + value.slice(-4)
		}

		function wainToast(text) {
			return uni.showToast({
				title: text,
				icon: 'none',
				duration: 2500
			})
		}

		function hideToast() {
			return uni.hideToast()
		}

		function postUrl(method = 'GET', url, data) {
			uni.showLoading({
				title: '加载中...',
			})
			let header = null;
			let token = uni.getStorageSync('token')
			let pwd = uni.getStorageSync('pwd')
			if (url !== '/site/login' || url !== '/memberinfos') {
				if (url === '/transfers' || url === '/withdrawals' || url === '/exchanges') {
					header = {
						'authorization': 'Bearer ' + token,
						'trade-password': pwd
					}
				} else {
					header = {
						'authorization': 'Bearer ' + token
					}
				}
			}
			return new Promise((resolve, reject) => {
				uni.request({
					url: Url(url),
					data: data,
					method: method || 'POST',
					dataType: 'json',
					header: header,
					success(res) {
						uni.hideLoading()
						if (res.data.code === 401) {
							wainToast('登录失效,请重新登录')
							resolve('error')
						} else if (res.data.code === '401.6') {
							wainToast(res.data.message)
						} else if (res.data.status === 503) {
							resolve('503')
							wainToast('系统维护中...')
						} else {
							resolve(res)
						}
					},
				})
			})
		}

		//获取之后的6天
		function getDate(val) {
			let weeks = new Array("星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六")
			let today = new Date()
			let targetday = today.getTime() + 1000 * 60 * 60 * 24 * val
			today.setTime(targetday)
			let tYear = today.getFullYear()
			let tMonth = today.getMonth() + 1
			let tDate = today.getDate()
			let date = new Date(`${tYear}/${tMonth}/${tDate}`)
			let days = date.getDay()
			let week = weeks[days]
			if (val === 0) {
				week = "今天"
			}
			return `${tMonth}月${tDate}日(${week})`
		}

		//获取当前时间
		function getNow() {
			let date = new Date()
			let year = date.getFullYear()
			let month = Minus(date.getMonth() + 1)
			let day = date.getDate()
			let hours = date.getHours()
			let min = date.getMinutes()
			let second = date.getSeconds()
			return `${year}-${month}-${day} ${hours}:${min}:${second}`
		}

		// 格式化返回的图片
		function getImageLists(lists) {
			let imgs = []
			for (let item of lists.split(';')) {
				imgs.push(item)
			}
			return imgs
		}

		// 显示model  type是否去掉取消按钮,  msg提示文字
		function Model(type, msg) {
			return uni.showModal({
				title: '提示',
				content: msg,
				showCancel: type,
				success(res) {
					if (res.confirm) {
						console.log('用户点击确定');
					} else if (res.cancel) {
						console.log('用户点击取消');
					}
				}
			})
		}

		// 显示消息提示框 icon 图标, msg提示文字
		function Toast(msg, icon = '') {
			return uni.showToast({
				title: msg,
				icon: icon?icon:'none',
				duration: 2500
			})
		}

		// 定时器页面的跳转  type  跳转的类型, url跳转的路径, duration延迟的时间,默认1500s
		function setTimeoutUrl(url, type, duration = 1500) {
			return setTimeout(() => {
				uni.redirectTo({
					url: url
				})
			}, duration)
		}

		// 分享转发
		function shareAppMessage(title = '爱拼',page = '/pages/home/index?scene='+code_text,img=''){
			 if (token) {
				let shareObj = {
					title: title,
					path: page,
					imageUrl:img,
				}
				return shareObj
			} else {
				author.auth()
			}
		}
		
		// 判断是否是微信浏览器还是普通浏览器
		function isWeixin () {
		  const ua = window.navigator.userAgent.toLowerCase()
		  if (ua.indexOf('micromessenger') !== -1) {
		    return true
		  } else {
		    return false
		  }
		}
		// android
		function isAndroid () {
		  const ua = window.navigator.userAgent.toLowerCase()
		  if (ua.indexOf('android') !== -1) {
		    return true
		  } else {
		    return false
		  }
		}
		// android
		function isIos () {
		  const ua = window.navigator.userAgent.toLowerCase()
		  if (ua.indexOf('iphone') !== -1) {
		    return true
		  } else {
		    return false
		  }
		}
    
    // 支付宝支付
    function alipayPay (info) {
      window.cordova.plugins.alipay.payment(info, function success (e){
        console.log('支付成功')
        uni.navigateTo({
          url: '/src/orders/paySuccess/PaySuccess.vue'
        })
      }, function error (e) {
        console.log('支付失败' + e)
        uni.showToast({title: '支付失败', icon: 'none'})
      })
    }

		module.exports = {
			checkMobile,
			wainToast,
			postUrl,
			hideToast,
			sliStr,
			Url,
			imgUrl,
			webImg,
			webImg2,
			getDate,
			getNow,
			getImageLists,
			classImg,
			productImg,
			Model,
			Toast,
			setTimeoutUrl,
			year,
			month,
			day,
			shareAppMessage,
			isWeixin,
			isAndroid,
			isIos,
      alipayPay
		}
