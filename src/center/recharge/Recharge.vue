<template>
	<view class="messageBox lighter-icon">
		<view class="item u-f u-f-ac">
			<text>账户余额 <text class="font-text money">({{balance|two}})</text></text>
		</view>
		<form @submit="formSubmit">
			<view class="item u-f u-f-ac" :class="{'font-red': errorIndex === 0}">
				<text class="label">充值金额</text>
				<input class="uni-input" focus placeholder="请输入充值金额" v-model="formRule.member_charge_money"  @blur="Input(formRule)" name="member_charge_money" placeholder-class="pla"/>
			</view>
			<view class="item u-f u-f-ac">
				<text class="label">充值方式</text>
				<radio-group @change="radioChange">
					<view class="u-f u-f-ac">
						<label class="uni-list-cell uni-list-cell-pd" v-for="(item, index) in types" :key="item.value">
							<view class="u-f u-f-ac">
								<radio :value="item.value" :checked="index === current" style="transform: scale(0.7)" color="#CFB47E"/>
								<text>{{item.name}}</text>
							</view>
						</label>
					</view>
				</radio-group>
			</view>
			<button class="mix-btn background-text" form-type="submit">确 定</button>
		</form>
		<!-- <view class="u-f font-text u-f-jsc details" @click="Detail">充值明细</view> -->
	</view>
</template>
<script>
	import graceChecker from '@/common/js/check.js'
	export default {
		data() {
			return {
				userInfo: uni.getStorageSync('userInfo'), //个人资料
				pwd: '', //交易密码
				config: uni.getStorageSync('notConfigs'),
				vconfigs: uni.getStorageSync('configs'),
				formRule: {
					member_charge_money: ''
				},
				errorIndex: '',
				balance: '0.00',
				rule: [
					{name:"member_charge_money", checkType: "notnull", errorMsg:"充值金额不能为空"}
				],
				types: [{
							value: '1',
							name: '微信',
							checked: 'true'
					}
				],
				current: 0
			};
		},
		onLoad(options) {
			this.getFinance()
			// #ifdef APP-PLUS
			this.types.push({
				value: '2',
				name: '支付宝'
			})
			// #endif
		},
		methods: {
			Detail () {
				uni.navigateTo({
					url: '../transferList/TransferList'
				})
			},
			radioChange: function(evt) {
				for (let i = 0; i < this.types.length; i++) {
					if (this.types[i].value === evt.target.value) {
							this.current = i
							break
					}
				}
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
				if (err === '充值金额不能为空') {
					this.errorIndex = 0
				}
				uni.showToast({ title: err, icon: "none" })
			},
			// 提交时候触发
			formSubmit (e) {
				//进行表单检查
				var formData = e.detail.value;
				var checkRes = graceChecker.check(formData, this.rule);
				if(checkRes) {
					this.errorIndex = ''
					this.Confirm ()
				} else {
					this.Check(graceChecker.error)
				}
			},
			// 获取币种
			async getFinance() {
				const res = await this.$api.getFinances()
				for (const item of res.data) {
					if (item.finance_type === 1) {
						this.balance = item.finance_award
					}
				}
			},
			// 提交
			async Confirm() {
				console.log(this.current)
				// type: 0人工支付,1币种支付,2微信H5支付,3微信小程序支付,4微信公众号支付,5微信APP支付,6支付宝APP支付,7支付宝H5支付
				const data = {
					member_charge_money: this.formRule.member_charge_money,
					pay_type: 5
				}
				// this.current, 0: 微信 1: 支付宝
				if (this.current === 0) {
					// #ifdef APP-PLUS
					
					// #endif
					
					// #ifdef H5
					// 微信浏览器
					if (this.$utils.isWeixin()) {
						
					} else {
						// 普通浏览器
						
					}
					// #endif
				}
			}
		},
	}
</script>

<style lang='scss' scoped>
	.details{
		margin-top: 50rpx;
	}
	.item{
		border-bottom: 1px solid #EEEEEE;
		padding: 25rpx 40rpx;
		
		.pla{
			font-size: 26rpx;
		}
		.money{
			margin-left: 50rpx;
		}
		.uni-list-cell:first-child{
			margin-right: 60rpx;
		}
	}
	.types{
		margin: 40rpx 40rpx 20rpx;
		uni-picker{
			width: 70%;
			border: 1px solid #EEEEEE;
			padding: 10rpx 20rpx;
		}
	}
	.label{
		width: 160rpx;
	}
	.mix-btn{
		width: 90%;
		border-radius: 10rpx;
	}
</style>
