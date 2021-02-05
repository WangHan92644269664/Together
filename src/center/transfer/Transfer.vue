<template>
	<view class="messageBox lighter-icon">
		<view class="types u-f u-f-ac">
			<text class="label">互转类型</text>
			<picker @change="bindPickerChange" :value="index" :range="types">
					<view class="uni-input">{{types[index]}} <text v-if="finances.length >0">({{finances[index].finance_award|two}})</text></view>
			</picker>
		</view>
		<form @submit="formSubmit">
			<view class="item u-f u-f-ac" :class="{'font-red': errorIndex === 0}">
				<text class="label">对方账户</text>
				<input class="uni-input" focus placeholder="请输入对方账户" v-model="formRule.transfer_dst_account"  @blur="Input(formRule)" name="transfer_dst_account" placeholder-class="pla"/>
			</view>
				<view class="item u-f u-f-ac" :class="{'font-red': errorIndex === 1}" >
					<text class="label">互转金额</text>
					<input class="uni-input" placeholder="请输入互转金额" v-model="formRule.transfer_currency" @blur="Input(formRule)" name="transfer_currency" placeholder-class="pla" type="digit"/>
				</view>
				<view class="item u-f u-f-ac" >
					<text class="label">留 言</text>
					<input class="uni-input" placeholder="请输入留言内容" v-model="formRule.transfer_remark" @blur="Input(formRule)" name="transfer_remark" placeholder-class="pla"/>
				</view>
			<button class="mix-btn background-text" form-type="submit">确 定</button>
		</form>
		<!-- <view class="u-f font-text u-f-jsc details" @click="Detail">互转明细</view> -->
		<uni-keyboard @completed="Confirm" ref="keyboard"  title="互转"></uni-keyboard>
	</view>
</template>
<script>
	import uniKeyboard from '@/components/uni-keyboard.vue'
	import uniPopup from '@/components/uni-popup/uni-popup.vue'
	import graceChecker from '@/common/js/check.js'
	export default {
		data() {
			return {
				userInfo: uni.getStorageSync('userInfo'), //个人资料
				pwd: '', //交易密码
				types: [], //币种
				vconfigs: uni.getStorageSync('configs'),
				formRule: {
					transfer_dst_account: '',
					transfer_currency: '',
					transfer_remark: '',
					transfer_src_finance_type: ''
				},
				errorIndex: '',
				index: 0,
				finances: [],
				rule: [
					{name:"transfer_dst_account", checkType: "notnull", errorMsg:"对方账户不能为空"},
					{name:"transfer_currency", checkType: "notnull", errorMsg:"互转金额不能为空"}
				]
			};
		},
		onLoad(options) {
			for (const i in this.vconfigs.transferConfig.src) {
				this.types.push(this.vconfigs.transferConfig.src[i])
			}
			console.log(this.types)
			this.getFinance()
		},
		methods: {
			Detail () {
				uni.navigateTo({
					url: '../transferList/TransferList'
				})
				console.log(23)
			},
			bindPickerChange (e) {
				this.index = e.target.value
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
				if (err === '对方账户不能为空') {
					this.errorIndex = 0
				} else if (err === '互转金额不能为空') {
					this.errorIndex = 1
				}
				uni.showToast({ title: err, icon: "none" })
			},
			async getUserInfo() {
				const res = await this.$api.getUserInfo();
				uni.setStorageSync('userInfo',res.data.info)
				if (res.data.success) {
					if (!res.data.info.existTradePassword) {
						return uni.showModal({
							title: '提示',
							content: '请先设置交易密码!',
							success(res) {
								if (res.confirm) {
									uni.navigateTo({
										url: '../pwd/Pwd?type=2'
									})
								}
							}
						})
					}
				}
			},
			// 提交时候触发
			formSubmit (e) {
				//进行表单检查
				var formData = e.detail.value;
				var checkRes = graceChecker.check(formData, this.rule);
				if(checkRes) {
					this.errorIndex = ''
					this.formRule.transfer_src_finance_type = this.index + 1
					this.getUserInfo()
					this.$refs.keyboard.show()
				} else {
					this.Check(graceChecker.error)
				}
			},
			// 获取币种
			async getFinance() {
				const res = await this.$api.getFinances()
				this.finances = res.data
			},
			// 提交
			async Confirm(password) {
				this.pwd = password;
				uni.setStorageSync('pwd', this.pwd)
				await this.$api.postTransfers(this.formRule, 'post').then(res => {
					this.$utils.Toast(res.data.message, res.data.success ? 'success':'none');
					this.$refs.keyboard.hide();
					if (res.data.success) {
						setTimeout(() => {
							uni.navigateTo({
								url: '/center/transferList/TransferList'
							})
						}, 1000)
					} else {
						if (res.data.errors.transfer_dst_account) {
							this.errorIndex = 0
						} else if (res.data.errors.transfer_currency) {
							this.errorIndex = 1
						}
						this.$store.state.is_error = true;
						this.pwd = '';
					}
				})
			},

		},
		components: {
			uniKeyboard,
			uniPopup
		}
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
