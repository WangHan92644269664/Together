<template>
	<view class="box lighter-icon">
		<form @submit="formSubmit" class="form">
			<view class="uni-form-item uni-column">
				<view class="title">手机号码</view>
				<input class="uni-input" focus name="memberinfo_mobile" maxlength="11" placeholder="请输入手机号码" placeholder-class="pla" :class="{'font-red': errorIndex === 0}" v-model="form.memberinfo_mobile"/>
			</view>
			<view class="uni-form-item uni-column code">
				<view class="title">手机验证码</view>
				<view class="u-f u-f-ac u-f-jsb">
          <input class="uni-input" maxlength="6" placeholder="请输入手机验证码" placeholder-class="pla" v-model="form.mobileVerifyCode" name="mobileVerifyCode" :class="{'font-red': errorIndex === 5}"/>
          <button :disabled="button.msg!=='发送验证码'" :class="{'disabled': button.msg!=='发送验证码'}" @click="getCode()" class="codes">{{button.msg}}</button>
        </view>
			</view>
			<view class="uni-form-item uni-column">
				<view class="title">登录密码</view>
				<input class="uni-input" name="memberinfo_password" :password="true" placeholder="请输入登录密码" placeholder-class="pla" :class="{'font-red': errorIndex === 1}" v-model="form.memberinfo_password"/>
			</view>
			<view class="uni-form-item uni-column">
				<view class="title">确认登录密码</view>
				<input class="uni-input" name="memberinfo_password_repeat" :password="true" placeholder="请再次输入登录密码" placeholder-class="pla" v-model="form.memberinfo_password_repeat" :class="{'font-red': errorIndex === 2}"/>
			</view>
			<!-- <view class="uni-form-item uni-column">
				<view class="title">昵称</view>
				<input class="uni-input" name="memberinfo_nickname" placeholder="请输入昵称" placeholder-class="pla"v-model="form.memberinfo_nickname" :class="{'font-red': errorIndex === 3}" maxlength="4"/>
			</view> -->
			<view class="uni-form-item uni-column">
				<view class="title">邀请码</view>
				<input class="uni-input" name="memberinfo_recommend_account" placeholder="请输入邀请码" placeholder-class="pla" v-model="form.memberinfo_recommend_account" :class="{'font-red': errorIndex === 4}"/>
			</view>
			<view class="protocol u-f u-f-ac">
				<checkbox-group @change="changeBox">
					<checkbox value="protocol" :checked="true" style="transform:scale(0.7)"/>我已阅读并同意 <text class="font-text" @tap="Go('./Protocol')">【注册协议】</text>
				</checkbox-group>
			</view>
			<view class="uni-btn-v">
				<button form-type="submit">注册</button>
				<text class="u-f u-f-jsc samll font-text login" @tap="Login">已有账号请直接登录</text>
				<text class="u-f u-f-jsc small font-text" @tap="Go('./Download')">下载APP</text>
			</view>
		</form>
	<!-- 	<view v-else>
			<view class="uni-form-item uni-column">
				<view class="title">手机验证码</view>
				<input class="uni-input" placeholder="请输入手机验证码" placeholder-class="pla" v-model="form.mobileVerifyCode"/>
			</view>
			<button @tap="Register">注册</button>
			
		</view> -->
	</view>
</template>

<script>
	import graceChecker from '../../common/js/check.js'
	export default {
		data() {
			return {
				errorIndex: '',
				form: {
					memberinfo_mobile: '',
					memberinfo_password: '',
					memberinfo_password_repeat: '',
					memberinfo_nickname: '昵称',
					memberinfo_recommend_account: '',
					mobileVerifyCode: ''
				},
				rule: [
					{name:"memberinfo_mobile", checkType: "phoneno", errorMsg:"手机号码不正确"},
					{name:"memberinfo_password", checkType: "notnull", errorMsg:"登录密码不能为空"},
					{name:"memberinfo_password_repeat", checkType: "repwd", errorMsg:"两次密码输入不一致"},
					{name:"memberinfo_recommend_account", checkType: "notnull", errorMsg:"邀请码不能为空"},
					{name:"mobileVerifyCode", checkType: "notnull", errorMsg:"手机验证码不能为空"}
				],
				protocol: ['protocol'],
				next: '',
				button: {
					msg: '发送验证码',
					time: 60,
					state: false
				}
			};
		},
		onLoad(options) {
			if (options.acc || uni.getStorageSync('acc')) {
				this.form.memberinfo_recommend_account = options.acc || uni.getStorageSync('acc')
			}
		},
		methods: {
			Go (url) {
				uni.navigateTo({
					url: url
				})
			},
			// 是否选中注册协议
			changeBox (e) {
				this.protocol = e.detail.value
			},
			Login () {
				uni.navigateTo({
					url: '/other/userLogin/PhoneLogin'
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
				if (err === '手机号码不正确') {
					this.errorIndex = 0
				} else if (err === '登录密码不能为空') {
					this.errorIndex = 1
				} else if (err === '两次密码输入不一致') {
					this.errorIndex = 2
				} else if (err === '邀请码不能为空') {
					this.errorIndex = 4
				} else if (err === '手机验证码不能为空') {
					this.errorIndex = 5
				}
				uni.showToast({ title: err, icon: "none", duration: 2500 })
			},
			// 提交时候触发
			formSubmit (e) {
				//进行表单检查
				var formData = e.detail.value;
				var checkRes = graceChecker.check(formData, this.rule);
				if(checkRes) {
					this.errorIndex = ''
					if (this.protocol.length === 0) {
						uni.showToast({ title: '请勾选注册协议', icon: "none", duration: 2500 });
					}
					this.Register()
				} else {
					this.Check(graceChecker.error)
				}
			},
			getCode () {
				const reg = /^1[0-9]{10,10}$/
				if (!this.form.memberinfo_mobile || !reg.test(this.form.memberinfo_mobile)) {
					return this.$utils.Toast('手机号码不正确!')
				}
				this.$api.getCodeVerify(this.form.memberinfo_mobile, 'verify', 'sms').then((res) => {
					if (res.data.success) {
						uni.showToast({ title: res.data.message, icon: "success", duration: 2500 })
						// 设置一个计时器用来计算获取验证码的时间
						this.next = 1
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
						if (res.data.message === '手机号已存在') {
							this.errorIndex = 0
						}
						uni.showToast({ title: res.data.message, icon: "none", duration: 2500 })
					}
				})
			},
			Register () {
				this.$api.postMemberinfos(this.form).then(res => {
					if (res.data.success) {
						this.$utils.Toast(res.data.message,'success')
						setTimeout(() => {
							uni.navigateTo({
								url: '../userLogin/PhoneLogin'
							})
						}, 1000)
					} else {
						if (res.data.message === '验证码错误') {
							this.errorIndex = 5
						}
						this.$utils.Toast(res.data.message,'none')
					}
				})
			}
		},
	};
</script>

<style lang="scss" scoped>
	.small{
		font-size: 28rpx;
	}
	.box {
		background: #FFFFFF;
		height: 100%;
		overflow: scroll;
		padding:0 30rpx 30rpx;
		.uni-form-item{
			margin-bottom: 40rpx;
			color: #CFB47E;
			.title{
				font-size: 34rpx;
			}
			.uni-input{
				margin-top: 10rpx;
				border: 1rpx solid #e3e3e3;
				padding: 16rpx;
				border-radius: 10rpx;
				box-shadow: 0 0 4rpx #e3e3e3;
			}
			.font-red{
				border: 1px solid red;
			}
			.pla{
				color: #e3e3e3;
				font-size:30rpx;
			}
		}
		.code{
			position: relative;
      input{
        width: 45%;
      }
			.codes{
				border-radius: 10rpx;
				width: 45%;
        position: relative;
        top: 4rpx;
        font-size: 30rpx;
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
			background: #CFB47E;
			color: #FFFFFF;
			width: 90%;
		}
		.disabled{
			background: #e6e6e6;
		}
		.uni-btn-v{
			margin-top: 30rpx;
			.login{
				margin: 40rpx 0;
			}
		}
	}
</style>
