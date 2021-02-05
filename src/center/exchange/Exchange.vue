<template>
	<view class="messageBox lighter-icon">
		<view class="types u-f u-f-ac">
			<text class="label">转出类型</text>
			<picker @change="bindSrcChange" :value="srcIndex" :range="src" range-key="name">
					<view class="uni-input" v-if="src[srcIndex]">{{src[srcIndex].name}}
					<text v-if="src.length >0">({{src[srcIndex].money|two}})</text></view>
			</picker>
		</view>
		<view class="types u-f u-f-ac">
			<text class="label">转入类型</text>
			<picker @change="bindDstChange" :value="dstIndex" :range="dst" range-key="name">
					<view class="uni-input" v-if="dst[dstIndex]">{{dst[dstIndex].name}} 
					<text v-if="dst.length >0">({{dst[dstIndex].money|two}})</text></view>
			</picker>
		</view>
		<form @submit="formSubmit">
				<view class="item u-f u-f-ac" :class="{'font-red': errorIndex === 0}" >
					<text class="label">兑换金额</text>
					<input class="uni-input" placeholder="请输入兑换金额" focus v-model="formRule.exchange_currency" @blur="Input(formRule)" name="exchange_currency" placeholder-class="pla" type="digit"/>
				</view>
				<view class="item u-f u-f-ac" >
					<text class="label">留 言</text>
					<input class="uni-input" placeholder="请输入留言内容" v-model="formRule.exchnage_remark" @blur="Input(formRule)" name="exchnage_remark" placeholder-class="pla"/>
				</view>
			<button class="mix-btn background-text" form-type="submit">确 定</button>
		</form>
		<!-- <view class="u-f font-text u-f-jsc details" @click="Detail">兑换明细</view> -->
		<uni-keyboard @completed="Confirm" ref="keyboard"  title="兑换"></uni-keyboard>
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
				src: [],
				srcIndex: 0,
				dst: [],
				dstIndex: 0,
				config: uni.getStorageSync('notConfigs'),
				vconfigs: uni.getStorageSync('configs'),
				formRule: {
					exchange_currency: '',
					exchnage_remark: '',
					exchange_src_finance_type: '',
					exchange_dst_finance_type: ''
				},
				errorIndex: '',
				finances: [],
				rule: [
					{name:"exchange_currency", checkType: "notnull", errorMsg:"兑换金额不能为空"}
				]
			};
		},
		onLoad(options) {
			this.$api.getFinances().then(res => {
				uni.setStorageSync('finances', res.data)
			})
			this.init()
		},
		watch: {
			srcIndex (newVal) {
				console.log(newVal)
			}
		},
		methods: {
			init () {
				// 转出类型
				for (const i in this.vconfigs.exchangeConfig) {
					this.src.push({
						type: this.vconfigs.exchangeConfig[i].src_finance_type,
						name: this.getFinance(this.vconfigs.exchangeConfig[i].src_finance_type, 'name'),
						money: this.getFinance(this.vconfigs.exchangeConfig[i].src_finance_type, 'money')
					})
				}
				// 转入类型
				const data = this.vconfigs.exchangeConfig[0].dst_finance_type
				this.dst = []
				for (const i in data) {
					this.dst.push({
						type: data[i],
						name: this.getFinance(data[i], 'name'),
						money: this.getFinance(data[i], 'money')
					})
				}
				this.formRule.exchange_src_finance_type = this.src[0].type
				this.formRule.exchange_dst_finance_type = this.dst[0].type
			},
			// Detail () {
			// 	uni.navigateTo({
			// 		url: '../transferList/TransferList'
			// 	})
			// },
			bindSrcChange (e) {
				this.srcIndex = e.target.value
				const data = this.vconfigs.exchangeConfig[e.target.value].dst_finance_type
				this.dst = []
				for (const i in data) {
					this.dst.push({
						type: data[i],
						name: this.getFinance(data[i], 'name'),
						money: this.getFinance(data[i], 'money')
					})
				}
				this.formRule.exchange_src_finance_type = this.src[e.target.value].type
			},
			bindDstChange (e) {
				this.dstIndex = e.target.value
				this.formRule.exchange_dst_finance_type = this.dst[e.target.value].type
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
				if (err === '兑换金额不能为空') {
					this.errorIndex = 0
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
					this.getUserInfo()
					this.$refs.keyboard.show()
				} else {
					this.Check(graceChecker.error)
				}
			},
			// 获取币种
			getFinance(type, name) {
				for (const item of uni.getStorageSync('finances')) {
					if (item.finance_type === Number(type)) {
						return name === 'name' ? item.financeType.finance_type_name : item.finance_award
					}
				}
			},
			// 提交
			async Confirm(password) {
				this.pwd = password;
				uni.setStorageSync('pwd', this.pwd)
				await this.$api.postExchanges(this.formRule, 'post').then(res => {
					this.$utils.Toast(res.data.message, res.data.success ? 'success':'none');
					this.$refs.keyboard.hide();
					if (res.data.success) {
						setTimeout(() => {
							uni.navigateTo({
								url: '/center/transferList/TransferList?type=2'
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
