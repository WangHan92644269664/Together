<template>
	<view class="messageBox lighter-icon">
		<view class="content">
			<view class="tabs1">
					<template v-if="exist_trade_password">
						<view class="list u-f" v-for="(item,index) in deal_pwd" :key="index">
							<view class="con u-f u-f-ac">
								<view class="item u-f u-f-jsb u-f-ac">
									<input type="password" v-model="item.model" :placeholder="item.placeholder" />
								</view>
							</view>
						</view>
					</template>
					<template v-else>
						<view class="list u-f" v-for="(item,index) in create_deal_pwd" :key="index">
							<view class="con u-f u-f-ac">
								<view class="item u-f u-f-jsb u-f-ac">
									<input type="password" v-model="item.model" :placeholder="item.placeholder" maxlength="6"/>
								</view>
							</view>
						</view>
					</template>
					<text class="tips">{{error_text}}</text>
					<button class="mix-btn u-f u-f-jsc" @click="submit">提 交</button>
					<!-- <text class="mix-btn" @click="submit">提 交</text> -->
					<text class="tips info u-f u-f-jsc">{{info}}</text>
			</view>
		</view>
	</view>
</template>

<script>
	export default {
		data() {
			return {
				titles: "修改交易密码",
				active: 1,
				deal_pwd: [{
						message: "旧交易密码",
						model: "",
						can: "memberinfo_password2_old",
						type: "password",
						reg: "",
						tip: "",
						placeholder: "输入旧交易密码"
					},
					{
						message: "新交易密码",
						model: "",
						can: "memberinfo_password2",
						type: "password",
						reg: "",
						tip: "",
						placeholder: "输入新交易密码"
					},
					{
						message: "确认新交易密码",
						model: "",
						can: "memberinfo_password2_repeat",
						type: "password",
						reg: "",
						tip: "",
						placeholder: "再次输入新密码"
					}
				],
				errData: [],
				create_deal_pwd: [{
						message: "新交易密码",
						model: "",
						can: "memberinfo_password2",
						type: "password",
						reg: "",
						tip: "",
						placeholder: "输入新交易密码"
					},
					{
						message: "确认新交易密码",
						model: "",
						can: "memberinfo_password2_repeat",
						type: "password",
						reg: "",
						tip: "",
						placeholder: "再次输入新密码"
					}
				],
				exist_trade_password: false,
				title: "修改交易密码",
				type:'',
				error_text:'',
				info:'密码必须是6位数字组成'
			};
		},
		computed: {},
		onLoad(options) {
			if (options.type === '2') {
				this.type = options.type
				this.active = 1;
				this.getUserInfo();
				this.titles = '设置交易密码'
			}
			if(this.active===1){
				this.getUserInfo();
				this.titles = '设置交易密码'
			}
		},
		mounted() {},

		methods: {
			// 获取会员信息
			async getUserInfo() {
				const res = await this.$api.getUserInfo();
				uni.setStorageSync('userInfo',res.data.info)
				if (res.data.success) {
					this.exist_trade_password = res.data.info.existTradePassword;
					console.log(this.exist_trade_password)
					if (!res.data.info.existTradePassword) {
						uni.setNavigationBarTitle({
							title: '设置交易密码'
						})
					}
				}
			},
			/**
			 * @desc 提交数据
			 * @param v1 是否需要验证
			 * @param v2 表单的参数名
			 */
			submit() {
				if(this.active===0){
					if(this.type==='2'){
						if (!this.create_deal_pwd[0].model || !this.create_deal_pwd[1].model) {
							this.$utils.Toast('请输入完整信息');
							return;
						}
					}else{
						if (
							!this.deal_pwd[0].model ||
							!this.deal_pwd[1].model ||
							!this.deal_pwd[2].model
						) {
							this.$utils.Toast('请输入完整信息');
							return;
						}
					}
				}
					
				let data;
				if (this.exist_trade_password) {
					data = {
						memberinfo_password2_old: this.deal_pwd[0].model,
						memberinfo_password2: this.deal_pwd[1].model,
						memberinfo_password2_repeat: this.deal_pwd[2].model
					};
				} else {
					data = {
						memberinfo_password2: this.create_deal_pwd[0].model,
						memberinfo_password2_repeat: this.create_deal_pwd[1].model
					};
				}
				this.$api.patchChangePwd(data).then(res => {
					uni.showToast({
						title: res.data.message,
						icon: 'none'
					})
					if (res.data.success) {
						this.$store.state.is_error = false
						this.getUserInfo()
						setTimeout(()=>{
							uni.navigateBack({
								delta:1
							})
						},1000)
					}else{
						this.error_text = res.data.message
					}
				});

			}
		},
	};
</script>

<style lang='scss' scoped>
	.titles {
		display: flex;
		justify-content: space-around;
		align-items: center;
		font-size: 34rpx;

		text {
			width: 30%;
			text-align: center;
			padding: 30upx;
		}

		text:last-child {
			border-right: none;
		}

		text.active {
			border-bottom: 2px solid #000;
			font-weight: bold;
		}
	}

	.content {
		padding: 0 40rpx;

		.tabs1 {
			.list {
				margin-top: 20rpx;
				flex-direction: column;
				width: 100%;

				.con {
					border-bottom: 1px solid #f2f3f3;
					justify-content: space-between;
				}

				.lable {
					font-size: 34rpx;
					color: #333;
					// width: 300rpx;
				}

				.item {
					display: flex;
					padding: 20rpx;

					input {
						color: #555;
						font-size: 32rpx;
						//   width: 450rpx;
					}
				}
			}
		}
	}

	.icon-cuo {
		color: red;
	}

	.icon-right {
		color: #019a46;
	}

	.tips{
		color: red;
		font-size: 30rpx;
		margin-top: 40rpx;
	}
	.mix-btn{
		height: 80rpx;
		line-height: 80rpx;
		font-size: 30rpx;
		width: 90%;
		background: #CFB47E;
		margin: 50rpx auto;
		border-radius: 0;
	}
</style>
