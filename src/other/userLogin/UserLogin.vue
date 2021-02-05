<template>
	<view class="box lighter-icon">
		<image :src="logo" mode="aspectFill" class="logo-img logo"></image>
		<view class="title">爱拼</view>
		<view class="login">
			<button open-type="getUserInfo" @getuserinfo="getUserInfo" class="wx">微信授权登录</button>
			<button @click="back" >取消</button>
		</view>
	</view>
</template>

<script>
	export default {
		data() {
			return {
				logo: this.$utils.webImg2+'logo.png',
				account: '',
				is_auth:false
			};
		},
		onLoad(options) {
			if (options.account) {
				this.account = options.account
			}
		},
		methods: {
			getUserInfo() {
				if(this.is_auth){
					return
				}
				let _self = this
				uni.showLoading()
				uni.getUserInfo({
					provider: 'weixin',
					success: (info) => { //这里请求接口
						_self.postLogin3(info.iv, info.encryptedData)
						_self.is_auth = true
						uni.setStorageSync('userDataInfo', info)
						// 送100元消费券显示与隐藏
						uni.setStorageSync('coupon',true)
					},
					fail: () => {
						_self.$utils.wainToast("微信登录授权失败");
					}
				})
			},
			// login3
			async postLogin3(iv, edata) {
				let data = {
					edata: edata,
					iv: iv,
					wechat_account: this.account
				}
				let res = await this.$api.postAuthorize3(data)
				if (res.data.success) {
					uni.navigateTo({
						url: `/other/userLogin/UserLogin1?account=${this.account}&from=login1`
					})
					uni.hideLoading()
					this.is_auth = false
				}
			},
			back() {
				uni.navigateBack()
			}
		},
	};
</script>

<style lang="scss">
	.box {
		padding-top: 200rpx;

		.title {
			text-align: center;
			font-weight: bold;
		}

		.login {
			margin: 250rpx 50rpx 0;

			.wx {
				background: #E0BF6A;
				color: #FFFFFF;
				border: none !important;
				margin-bottom: 50rpx;
				font-size: 32rpx;
			}
			button{
				font-size: 32rpx;
			}
		}
	}
</style>
