<template>
	<view class="box" :style="{background: 'url('+bg+')'}">
		<image :src="logo" mode="widthFix" class="logo-img logo"></image>
		<image :src="login_bg" mode="widthFix" class="login_bg"></image>
		<view class="login">
			<view class="tabs u-f u-f-jsa">
				<text v-for="(item, index) in tabs" :key="index" @tap="changeTab(index)" :class="{'active':index===tabIndex}" class="cursor">{{item}}</text>
			</view>
			<form @submit="formSubmit">
			<view class="login-box" v-if="tabIndex===1">
				<view class="item u-f u-f-ac" :class="{'font-red': errorIndex === 0}">
					<text class="iconfont icon-shouji"></text>
					<input class="uni-input" type="number" focus placeholder="请输入手机号" v-model="form.phone" name="phone"/>
				</view>
					<view class="item u-f u-f-jsb u-f-ac" :class="{'font-red': errorIndex === 1}">
						<view class="u-f u-f-ac">
							<text class="iconfont icon-mima"></text>
							<input class="uni-input" placeholder="请输入验证码" v-model="form.code" name="code"/>
						</view>
						<button @click="getCode">{{button.msg}}</button>
					</view>
				</view>
				<view class="login-box" v-else>
					<view class="item u-f u-f-ac" :class="{'font-red': errorIndex === 0}" >
						<text class="iconfont icon-shouji"></text>
						<input class="uni-input" focus placeholder="请输入手机号" v-model="form.phone" name="phone"/>
					</view>
					<view class="item u-f u-f-ac" :class="{'font-red': errorIndex === 2}" >
						<text class="iconfont icon-mima"></text>
						<input class="uni-input" password placeholder="请输入密码" v-model="form.pwd" name="pwd"/>
					</view>
				</view>
				<button class="wx" form-type="submit">登录</button>
			</form>
			<text class="u-f u-f-jsc small font-text" @tap="Register">还没有账号 ? 去注册</text>
		</view>
		<view class="u-f u-f-jsc user small font-white" @tap="Go('../register/Protocol')">登录即表示同意爱拼《用户协议》</view>
	</view>
</template>

<script>
	import graceChecker from '../../common/js/check.js'
	export default {
		data() {
			return {
				bg: this.$utils.webImg2+'love_spell_login_bg.png',
				logo: this.$utils.webImg2+'logo.png',
				login_bg: this.$utils.webImg2+'lobin_bg1.png',
				account: '',
				is_auth:false,
				tabs: ['密码登录', '验证码登录'],
				tabIndex: 0,
				form: {
					phone: '',
					pwd: ''
				},
				rule: [
					{name:"phone", checkType: "notnull", errorMsg:"手机号码不能为空"},
					{name:"pwd", checkType: "notnull", errorMsg:"登录密码不能为空"}
				],
				errorIndex: '',
				button: {
					msg: '发送验证码',
					time: 60,
					state: false
				},
			};
		},
		onLoad(options) {
			console.log(this.logo)
			if (options.account) {
				this.account = options.account
			}
		},
		methods: {
			async getAreas () {
				const res = await this.$api.getAllAreas()
				uni.setStorageSync('areas', res.data)
			},
			Go (url) {
				uni.navigateTo({
					url: url
				})
			},
			async getGroups () {
				const res = await this.$api.getProductGroup()
				uni.setStorageSync('groups', res.data)
				console.log(res)
			},
			changeTab (index) {
				this.tabIndex = index
				this.errorIndex = ''
				this.form.phone = this.form.pwd = this.form.code = ''
				if (index === 1) {
					this.form = {
						phone: '',
						code: ''
					}
					this.rule = [
						{name:"phone", checkType: "phoneno", errorMsg:"手机号码不正确"},
						{name:"code", checkType: "notnull", errorMsg:"验证码不能为空"}
					]
				} else {
					this.form = {
						phone: '',
						pwd: ''
					}
					this.rule = [
						{name:"phone", checkType: "notnull", errorMsg:"手机号码不能为空"},
						{name:"pwd", checkType: "notnull", errorMsg:"登录密码不能为空"}
					]
				}
			},
			Register () {
				uni.navigateTo({
					url: '/other/register/Register'
				})
			},
			// 失去焦点触发
			Input (form) {
				var checkRes = graceChecker.check(form, this.rule);
				if(checkRes) {
					this.errorIndex = ''
				} else {
					this.Check(graceChecker.error)
				}
			},
			// 表单验证
			Check (err) {
				if (err === '手机号码不能为空' || (this.tabIndex === 1 && err === '手机号码不正确')) {
					this.errorIndex = 0
				} else if (err === '验证码不能为空') {
					this.errorIndex = 1
				} else if (err === '登录密码不能为空') {
					this.errorIndex = 2
				}
				uni.showToast({ title: err, icon: "none", duration: 2500 })
			},
			formSubmit (e) {
				//进行表单检查
				var formData = e.detail.value;
				var checkRes = graceChecker.check(formData, this.rule)
				if(checkRes) {
					this.errorIndex = ''
					this.Login()
				} else {
					this.Check(graceChecker.error)
				}
			},
			// 获取短信验证码
			getCode () {
				if (!this.form.phone) {
					this.errorIndex = 0
					uni.showToast({ title: '请输入正确手机号', icon: "none", duration: 2500 })
					return
				}
				this.errorIndex = ''
				if (this.button.state) { // 为真表示已发送验证码
					return
				}
				this.$api.getCodeVerify(this.form.phone, 'login', 'sms').then((res) => {
					if (res.data.success) {
						uni.showToast({ title: res.data.message, icon: "success", duration: 2500 })
						this.button.state = true
						// 设置一个计时器用来计算获取验证码的时间
						const time = setInterval(() => {
							if (this.button.time === 0) {
								window.clearInterval(time)
								this.button.msg = '发送验证码'
								this.button.time = 60
								this.button.state = false
							} else {
								this.button.msg = `( ${this.button.time} s )后重新发送`
								this.button.time -= 1
							}
						}, 1000)
					} else {
						uni.showToast({ title: res.data.message, icon: "none", duration: 2500 })
					}
				})
			},
			async getConfigs() {
				const res = await this.$api.getVconfig()
				uni.setStorageSync('configs', res.data)
			},
			Login () {
				let data = {
					username: this.form.phone
				}
				if (this.tabIndex === 1) {
					data.type = 'phone'
					data.phoneCode = this.form.code
				} else {
					data.password = this.form.pwd
				}
				uni.showLoading()
				this.$api.postPhoneLogin(data).then(res => {
					uni.hideLoading()
					if (res.data.success) {
						this.$utils.Toast('登录成功','success')
						this.$store.commit("setToken", res.data.token)
						uni.setStorageSync("token", res.data.token)
						uni.setStorageSync("userInfo", res.data.info)
						this.getAreas()
						this.getGroups()
						this.getConfigs()
						setTimeout(() => {
							uni.switchTab({
								url: '/pages/home/index'
							})
						}, 1000)
					} else {
						if (res.data.errors.type) {
							this.$utils.Toast(res.data.errors.type[0],'none')
						} else {
							this.$utils.Toast(res.data.message)
						}
					}
				})
			}
		},
	};
</script>

<style lang="scss" scoped>
	/deep/ uni-input{
		width: 100%!important;
	}
	.small{
		font-size: 28rpx;
	}
	.box {
		background: rgb(203,3,3);
		height: 100vh;
		overflow: hidden;
		.logo-img{
			width: 130rpx;
			height: 130rpx;
			margin: 130rpx auto 0;
			z-index: 2;
		}
		.login_bg{
			margin: -70rpx 0;
			z-index: 0;
			width: 100%;
		}

		.title {
			text-align: center;
			font-weight: bold;
		}

		.login {
			margin: -260rpx 30rpx 0;
			box-sizing: border-box;
			padding: 80rpx;
			background: #FFFFFF;
			border-radius: 20rpx;
			z-index: 2;
			position: relative;
			.tabs{
				text-align: center;
				text{
					padding-bottom: 20rpx;
					font-weight: bold;
				}
				.active{
					border-bottom: 3px solid rgb(203,3,3);
				}
			}
			.login-box{
				margin: 80rpx auto 100rpx;
				.item{
					border-bottom: 1px solid #e6e6e6;
					padding-bottom: 20rpx;
					margin-top: 30rpx;
					.iconfont{
						margin-right: 20rpx;
					}
				}
				.font-red{
					border-bottom: 1px solid red;
				}
				button{
					font-size: 26rpx;
					height: 50rpx;
					line-height: 50rpx;
				}
			}

			.wx {
				border: none !important;
				margin-bottom: 20rpx;
				font-size: 32rpx;
			}
			button{
				font-size: 32rpx;
				border-radius: 60rpx;
				background: rgb(203,3,3);
				color: #FFFFFF;
			}
		}
		.user{
			margin-top: 30rpx;
		}
	}
</style>
