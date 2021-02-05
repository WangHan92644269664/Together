<template>
	<view class="box lighter-icon">
		<image :src="logo" mode="aspectFill" class="logo-img logo"></image>
		<view class="title">爱拼</view>
		<view class="login">
			<button open-type="getPhoneNumber" @getphonenumber="LoginWx" class="wx">微信一键登录</button>
			<button @click="back" v-if="!from">取消</button>
		</view>
		<!-- <view class="phone">
			<view class="phone-login u-f u-f-ac u-f-jsc">手机号登录</view>
			<view class="iconfont icon-shouji" @tap="PhoneLogin"></view>
		</view> -->
	</view>
</template>

<script>
	export default {
		data() {
			return {
				img_url:this.$utils.webImg2,
				logo: this.$utils.webImg2+'logo.png',
				account: '',
				from: ''
			};
		},
		onLoad(options) {
			this.account = options.account
			if (options.from) {
				this.from = options.from
			}
		},
		methods: {
			async getAreas () {
				const res = await this.$api.getAllAreas()
				uni.setStorageSync('areas', res.data)
			},
			// 获取手机号
			LoginWx(e) {
				console.log(e)
				if (e.detail.iv) {
					let data = {
						iv: e.detail.iv,
						edata: e.detail.encryptedData,
						wechat_account: this.account
					}
					uni.showLoading()
					this.$api.postAuthorize2(data)
						.then(res => {
							uni.hideLoading()
							if (res.data.success) {
								this.$utils.Toast('登录成功','success')
								this.$store.commit(
									"setToken",
									res.data.token
								);
								uni.setStorageSync("token", res.data.token);
								uni.setStorageSync("userInfo", res.data.info);
								this.getAreas()
								setTimeout(() => {
									uni.switchTab({
										url: '/pages/home/index'
									})
								}, 1000)
							} else {
								this.$utils.Toast(res.data.message)
							}
						})
				}
			},
			// 手机号登录
			// PhoneLogin() {
			// 	uni.navigateTo({
			// 		url: '../login/PhoneLogin'
			// 	})
			// },
			// 获取配置
			async getConfig() {
				const res = await this.$api.getConfig();
				uni.setStorageSync("notConfigs", res.data);
			},
			back() {
				uni.navigateBack()
			}
		},
	};
</script>

<style lang="scss">
	.box {
		padding-top: 240rpx;

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

		.phone {
			text-align: center;
			margin-top: 100rpx;
			color: #666666;

			view:first-child {
				font-size: 12px;
				margin-bottom: 20rpx;
			}
			.phone-login::after,.phone-login::before{
				content: '';
				border:1px solid #f1f1f1;
				width: 30%;
				display: inline-block;
			}
			.phone-login::after{
				margin-left: 20rpx;
			}
			.phone-login::before{
				margin-right: 20rpx;
			}
			.icon-shouji{
				font-size: 32px;
			}
		}
	}
</style>
