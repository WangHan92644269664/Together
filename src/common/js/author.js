import api from './api'
import utils from './utils'
let auth=(type)=>{
	// let url
  uni.clearStorage()
  uni.clearStorageSync()
  uni.navigateTo({
    url: "/other/userLogin/PhoneLogin"
  })
	// uni.getProvider({
	// 	service: 'oauth',
	// 	success: function (res) {
	// 		if (~res.provider.indexOf('weixin')) {
	// 			uni.login({
	// 				provider: 'weixin',
	// 				success: (res) => {
	// 					let data = {
	// 						code:res.code
	// 					}
	// 					let scene = uni.getStorageSync('scene')
	// 					if(scene){
	// 						data['recommend_account'] = scene
	// 					}
	// 					api.postAuthorize(data)
	// 					.then(res1=>{
	// 						uni.showToast({
	// 							title:res1.data.success
	// 						})
	// 						if (res1.data.success) {
	// 							if (res1.data.info.wechat_nickname) {
	// 								uni.navigateTo({
	// 									url:`/other/userLogin/UserLogin1?account=${res1.data.info.wechat_account}`
	// 								})
	// 							}else{
	// 								uni.navigateTo({
	// 									url:`/other/userLogin/UserLogin?account=${res1.data.info.wechat_account}`
	// 								})
	// 							}
	// 						} else {
	// 							uni.showToast({
	// 								title:res1.data.message,
	// 								icon:'none'
	// 							})
	// 						}
	// 					})
	// 				},
	// 				fail: () => {
	// 					uni.showToast({
	// 						title:'微信登录授权失败',
	// 						icon:'none'
	// 					})
	// 				},
	// 			})
	// 		} else {
	// 			// uni.showToast({
	// 			// 	title:'请先安装微信或升级版本',
	// 			// 	icon:'none'
	// 			// })
	// 			uni.navigateTo({
	// 				url: "/other/userLogin/PhoneLogin"
	// 			})
	// 		}
	// 	},
	// 	fail() {
	// 		uni.showToast({
	// 			title:'失败'
	// 		})
	// 	}
	// })
}

export default {
	auth
}
