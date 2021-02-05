import MinRequest from './config.js'
import author from './author.js'
const minRequest = new MinRequest()

// 请求拦截器
minRequest.interceptors.request((request) => {
	return request
})

// 响应拦截器
minRequest.interceptors.response((response) => {
	if (response.data.code === 401) {
		uni.clearStorage()
		author.auth()
	} else if (response.data.code === 503) {
		uni.clearStorage()
		uni.showToast({
			title: '服务器错误',
			icon: 'none'
		})
	} else if (response.data.code === '401.7') {
		uni.showModal({
			title: '提示',
			content: '先去设置交易密码?',
			success(res) {
				if (res.confirm) {
					uni.navigateTo({
						url: '/center/pwd/Pwd?type=2'
					})
				} else if (res.cancel) {
					uni.navigateBack({
						delta: 1
					})
				}
			}
		})
	}
	// 不返回到data是因为返回的头部page数在header中
	return response
})

// 设置默认配置
minRequest.setConfig((config) => {
	config.baseURL = process.env.VUE_APP_API_URL
	return config
})

export default {
	// 这里统一管理api请求
	getConfig() {
		return minRequest.get('site/config')
	},
	getUserInfo() {
		return minRequest.get('site/contact')
	},
	getMemberinfos(data) {
		return minRequest.get('memberinfos', data);
	},
	// 获取个人资料
	getMemberView() {
		return minRequest.get('memberinfos/view-my?expand=memberinfoRecommendInfo,membermap')
	},
	// getMemberinfos(data) {
	// 	return minRequest.get('memberinfos', data);
	// },

	getAccount(data, id) {
		const url = 'announcements'
		return id ? minRequest.get(`${url}/${id}`, data) : minRequest.get(`${url}?sort=-announcement_update_datetime`, data)
	},
	// 获取验证码
	getCodeVerify (phone, type, method) {
	  return minRequest.get(`site/code-verify?phone=${phone}&type=${type}&method=${method}`)
	},
	getProduct(data, id) {
		if (id) {
			return minRequest.get('products/' + id + '?expand=productSeckill,productSku', data)
		} else {
			return minRequest.get('products?per-page=6&product_is_sale=1', data)
		}
	},
	getCategory(data, id) {
		if (id) {
			return minRequest.get(`product-classes/${id}?per-page=100&sort=product_class_sort`, data)
		} else {
			return minRequest.get('product-classes?sort=product_class_sort', data)
		}
	},
	getProductGroup(data, id) {
		if (id) {
			return minRequest.get(`product-groups/${id}?per-page=100`, data)
		} else {
			return minRequest.get('product-groups', data)
		}
	},
	getCarts(data) {
		return minRequest.get('carts?expand=cartProduct,cartProductSku', data)
	},
	getFinances(data) {
		return minRequest.get('finance?expand=financeType&sort=finance_type', data)
	},
	getCodeVerify(phone, type, method) {
		return minRequest.get(`site/code-verify?phone=${phone}&type=${type}&method=${method}`);
	},
	// 获取所有的银行卡
	getBanks() {
		return minRequest.get('banks');
	},
	// 获取二维码
	getCode() {
		return minRequest.get('memberinfo/qrcode')
	},
	getMemberTypes() {
		return minRequest.get('membertypes?sort=membertype_type');
	},
	getCaptcha() {
		return minRequest.get('site/captcha');
	},
	// 我的战队
	getRecommend(data) {
		return minRequest.get('memberinfos/recommend', data);
	},
	// 获取会员等级
	getMemberLevel() {
		return minRequest.get('memberlevels?sort=memberlevel_level')
	},
	getAddresses(data) {
		return minRequest.get('addresses?expand=addressProvience,addressArea,addressCounty', data);
	},
	getAddresses1(id, data) {
		return minRequest.get('addresses/' + id + '?expand=addressProvience,addressArea,addressCounty', data);
	},
	getAreas(name, data) {
		return minRequest.get('areas/' + name, data);
	},
	getAllAreas () {
		return minRequest.get('areas')
	},

	delAddress(id) {
		return minRequest.delete('addresses/' + id);
	},
	delCarts(id) {
		return minRequest.delete(`carts/${id}`);
	},
	delUser(id) {
		return minRequest.delete('memberinfos/' + id);
	},

	putAddress(id, data) {
		return minRequest.put('addresses/' + id, data);
	},

	postMemberinfos(data) {
		return minRequest.post('memberinfos', data);
	},
	postLogin(data) {
		return minRequest.post('site/login', data);
	},
	reqAddress (type, data, id) {
		const url = 'addresses'
		if (type === 'get') {
			return id ? minRequest.get(`${url}/${id}`) : minRequest.get(url)
		}
		if (type === 'del') {
			return minRequest.delete(`${url}/${id}`)
		}
		return type === 'post' ? minRequest.post(url, data) : minRequest.put(`${url}/${id}`, data)
	},
	postAddresses(data) {
		return minRequest.post('addresses', data);
	},

	patchForget(data) {
		return minRequest.patch('memberinfos/forget-password', data);
	},
	patchCarts(id, data) {
		return minRequest.patch('carts/' + id, data);
	},
	patchMemVerify(id) {
		return minRequest.patch('memberinfos/verify/' + id);
	},
	getLogout() {
		return minRequest.get('site/logout')
	},
	putUpdateMy(data) {
		return minRequest.put('memberinfos/update-my', data)
	},
	getVerifyChange(data) {
		return minRequest.get('site/verify-change', data)
	},
	patchChangePwd(data) {
		return minRequest.patch('memberinfos/change-password', data);
	},
	getMessages(data) {
		return minRequest.get(
			'messages?expand=messagesReceiverAccount,messagesSenderAccount,messagesAccount&sort=messages_add_datetime', data)
	},
	postMessage(data) {
		return minRequest.post('messages', data)
	},
	getVconfig() {
		return minRequest.get('site/verify-config');
	},
	postTransfers(data, type) {
		return type === 'post' ? minRequest.post('transfers', data) : minRequest.get('transfers')
	},
	// 提现
	reqWithdrawals(data, type) {
		let url = 'withdrawals'
		return type === 'post' ? minRequest.post(url, data) : minRequest.get(url);
	},
	// 会员充值
	reqCharges(data, type) {
		let url = 'member-charges'
		return type === 'post' ? minRequest.post(url, data) : minRequest.get(url);
	},
	// 分销佣金
	getAwardPeriodSums(data) {
		return minRequest.get(
			'award-period-sums?expand=awardPeriodSumAwardPeriods,awardPeriodSumAwardPeriods.awardPeriodType,awardPeriodSumType,awardPeriodSumOrder.orderAccount,awardPeriodSumOrder',
			data);
	},
	// 分销订单
	getOrderDistribute(data) {
		return minRequest.get('order/distribution?expand=orderAccount,orderAwardPeriodSum', data)
	},
	// 团队佣金
	getAwardPeriods(data) {
		return minRequest.get('award-periods?expand=awardPeriodAccount', data)
	},
	// 我的战队
	getMemberMaps() {
		return minRequest.get('membermaps')
	},
	getFinanceTypes(data) {
		return minRequest.get('finance-types', data);
	},
	postExchanges(data, type) {
		return type === 'post' ? minRequest.post('exchanges', data) : minRequest.get('exchanges', data);
	},
	postOrdersSettle(data) {
		return minRequest.post('orders/settle', data);
	},
	// 订单
	reqOrders(data, type, id) {
		let url = 'orders'
		let params = 'expand=orderOrderProducts&per-page=6'
		if (type === 'post') {
			return minRequest.post(url, data);
		} else if (type === 'del') {
			return minRequest.delete(`${url}/${id}`)
		} else {
			return id ? minRequest.get(`${url}/${id}`, data) : minRequest.get(`${url}?${params}`, data)
		}
	},
	// 拼团列表数据
	getGroupLists (data) {
		return minRequest.get('group-rules?expand=groupRulesProduct.productMonthSale', data)
	},
	// 获取拼团数量
	getGroupProductCount (id) {
	  return minRequest.get(`group-rules/group-number/${id}?expand=groupMemberMemberinfoAccount`)
	},
	changeGroupStatus (id, data) {
	  return minRequest.patch(`group-rules/auto-product/${id}`, data)
	},
	// 获取拼团记录
	getGroups (data) {
		return minRequest.get('group-member', data)
	},
	postPays(data) {
		return minRequest.post('pays', data);
	},
  // 获取微信公众号分享的配置
  getWeixinConfig (data) {
    return minRequest.post('site/get-jssdk', data)
  },
	patchConfirm(id) {
		return minRequest.patch(`orders/confirm-receipt/${id}`);
	},
	getFinanceLog(data) {
		return minRequest.get('finance-logs', data);
	},
	reqSigns(data, type) {
		return type === 'get' ? minRequest.get("signs", data) : minRequest.post("signs", data)
	},
	// 优惠券
	reqCoupon(data, type) {
		let url = 'coupons'
		return type === 'post' ? minRequest.post(url, data) : minRequest.get(url, data)
	},
	getCodeCoupon(code) {
		return minRequest.get('coupons/receive?code=' + code)
	},
	getTown(data) {
		return minRequest.get("area-towns", data)
	},
	getGroupLists(data) {
		return minRequest.get('group-rules?expand=groupRulesProduct', data)
	},
	getComments(data, id) {
		const url = 'product-comments'
		return id ? minRequest.get(url + '?pre_page=5&expand=memberInfo&product_comment_product_id=' + id, data) : minRequest
			.get(url, data)
	},
	postComments(data) {
		return minRequest.post("product-comments", data)
	},
	postRefunds(data) {
		return minRequest.post("refund-goods", data)
	},
	getRefunds(data) {
		return minRequest.get("refund-goods?expand=refundProduct", data)
	},
	getAftersales(data) {
		return minRequest.get("aftersales?expand=aftersaleProduct", data)
	},
	postAftersales(data) {
		return minRequest.post("aftersales", data)
	},
	getGroup(data) {
		return minRequest.get('group-rules?expand=groupRulesProduct', data)
	},
	reqCarts(type = 'get', data) {
		let url = 'carts'
		return type === 'get' ? minRequest.get(url, data) : minRequest.put(url, data)
	},
	postPhoneLogin(data) {
		return minRequest.post('site/login', data)
	},
	postAuthorize(data) {
		return minRequest.post('site/login1', data)
	},
	postAuthorize2(data) {
		return minRequest.post('site/login2', data)
	},
	postAuthorize3(data) {
		return minRequest.post('site/login3', data)
	},
	// 提现统计
	getWithdrawChart(data) {
		return minRequest.get('withdrawals/chart')
	},
}
