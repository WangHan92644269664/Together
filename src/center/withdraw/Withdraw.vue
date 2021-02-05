<template>
	<view class="messageBox lighter-icon">
		<view class="account u-f u-f-jsb u-f-ac" @tap="Open" v-if="finances.length>0">
			<text>{{finances[typeIndex].financeType.finance_type_name}}
				<i style="font-style: normal;">(￥{{finances[typeIndex].finance_award|two}})</i></text>
			<text class="iconfont icon-arrow-right"></text>
		</view>
		<view class="content">
			<view class="tabs1">
        <view class="list u-f u-f-ac">
        	<text class="lable">到账方式</text>
          <radio-group @change="radioType" class="u-f u-f-ac">
              <label class="u-f u-f-ac" v-for="(item, index) in items" :key="item.value">
                  <radio :value="item.value" :checked="index === current" style="transform: scale(.7);" color="#CFB47E"/>
                  <view>{{item.name}}</view>
              </label>
          </radio-group>
        </view>
				<view class="list">
					<text class="lable">提现金额<text class="gray"> (手续费: {{tax}})</text></text>
					<view class="money u-f u-f-ac">
						<text>￥</text><input type="number" v-model="money" focus="true" />
					</view>
				</view>
			</view>
		</view>
		<uni-keyboard @completed="Confirm" ref="keyboard"  title="提现"></uni-keyboard>
		<button class="mix-btn background-text" @click="confirmPwd">提现</button>
		<!-- <view class="u-f font-text u-f-jsc" @click="Go('/center/financesDetail/FinancesDetail?type=withdraw')">提现明细</view> -->
		<uni-popup ref="popup" type="bottom">
			<view class="popup-content u-f">
				<view class="first u-f u-f-ac">
					<text></text>
					<text>请选择资金账户</text>
					<text class="iconfont icon-guanbi" @tap="Close"></text>
				</view>
				<view class="uni-list"  v-if="finances.length>0">
					<radio-group @change="radioChange($event)">
						<block v-for="(item, index) in finances" :key="index">
							<label class="uni-list-cell uni-list-cell-pd u-f  u-f-ac u-f-jsb" v-if="item.finance_type!==3">
								<view>{{item.financeType.finance_type_name}}(￥{{item.finance_award|two}})<text v-if="Number(item.finance_award).toFixed(0)==='0'">资金不足</text></view>
								<view>
									<radio :value="String(index)" :checked="index === Number(typeIndex)" color="#E0BF6A" :disabled="Number(item.finance_award).toFixed(0)==='0'"
									 :class="[Number(item.finance_award).toFixed(0)==='0'?'gray':'']" />
								</view>
							</label>
						</block>
					</radio-group>
				</view>
			</view>
		</uni-popup>
	</view>
</template>
<script>
	import uniKeyboard from '@/components/uni-keyboard.vue'
	import uniPopup from '@/components/uni-popup/uni-popup.vue'
	export default {
		data() {
			return {
				money: '',
				reg_money: '',
				tip_money: '',
				content: '', //备注
				userInfo: uni.getStorageSync('userInfo'), //个人资料
				pwd: '', //交易密码
				finances: [], //币种
				errData: [],
				finance_type: 1,
				index: 0,
				config: uni.getStorageSync('notConfigs'),
				tax: '0.00',
        typeIndex: 0,
        items: [{
                value: '1',
                name: '银行卡',
                checked: 'true'
            },
            {
                value: '2',
                name: '支付宝'
            },
            {
                value: '3',
                name: '微信'
            }
          ],
        current: 0
			};
		},
		onLoad(options) {
			this.getFinance()
			if (this.config.withdrawalConfig) {
				this.tax = this.config.withdrawalConfig.tax
			}
		},
		methods: {
			Go (url) {
				uni.navigateTo({
					url: url
				})
			},
      // 到账方式
      radioType (e) {
        console.log(e)
        this.current = e.detail.value - 1
      },
			// 弹出层的单选
			radioChange (e) {
				this.typeIndex = e.detail.value
        this.$refs.popup.close()
			},
			Open() {
				this.$refs.popup.open()
			},
			Close() {
				this.$refs.popup.close()
			},
			// 验证正确弹出密码输入框
			confirmPwd() {
        console.log(this.items, this.current, this.typeIndex)
				if (!this.money) {
					return this.$utils.Toast('请输入提现金额')
				}
				let data = {
					'withdrawals_currency': this.money,
          'withdrawals_finance_type_id': this.finances[this.typeIndex].finance_type,
          'withdrawals_type': this.items[this.current].value,
					'ajax': 'validate'
				}
        // 银行卡
        if (this.current === 0) {
          if (!this.userInfo.memberinfo_bank_id) {
          	return uni.showModal({
          		title: '提示',
          		content: '先去添加银行卡?',
          		success(res) {
          			if (res.confirm) {
          				uni.navigateTo({
          					url: '/center/addBank/AddBank'
          				})
          			}
          		}
          	})
          }
        } else if (this.current === 1) {
          if (!this.userInfo.memberinfo_alipay_image) {
          	return uni.showModal({
          		title: '提示',
          		content: '先去添加支付宝收款码?',
          		success(res) {
          			if (res.confirm) {
          				uni.navigateTo({
          					url: '/center/info/Info'
          				})
          			}
          		}
          	})
          }
        } else if (this.current === 2) {
          if (!this.userInfo.memberinfo_wechat_image) {
          	return uni.showModal({
          		title: '提示',
          		content: '先去添加微信收款码?',
          		success(res) {
          			if (res.confirm) {
          				uni.navigateTo({
          					url: '/center/info/Info'
          				})
          			}
          		}
          	})
          }
        }
        console.log(data)
				this.$refs.keyboard.show();
			},
			// 获取币种
			async getFinance() {
				await this.$api.getFinances()
					.then(res => {
						console.log(res.data)
            for (const item of res.data) {
              if (item.finance_type !== 3) {
                this.finances.push(item)
              }
            }
					})
			},
			// 提交
			async Confirm(password) {
				this.pwd = password;
        // withdrawals_type 1银行卡 2支付宝 3微信
				let data = {
					'withdrawals_currency': this.money,
					'withdrawals_account': this.userInfo.memberinfo_account,
          'withdrawals_finance_type_id': this.finances[this.typeIndex].finance_type,
          'withdrawals_type': this.items[this.current].value
				}
				uni.setStorageSync('pwd', this.pwd)
				await this.$api.reqWithdrawals(data, 'post').then(res => {
					this.$utils.Toast(res.data.message);
					this.$refs.keyboard.hide();
					if (res.data.success) {
						setTimeout(() => {
							uni.navigateTo({
								url: '/center/financesDetail/FinancesDetail?type=withdraw'
							})
						}, 1000)
					} else {
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
	.gray{
		color: #888888;
	}
	page {
		background: #f5f5f5;
	}

	.account {
		background: #FFFFFF;
		padding: 30rpx;
		margin: 20rpx 0;
		font-size: 30rpx;
	}

	.content {
		.tabs1 {
			.list {
				background: #FFFFFF;
				padding: 30rpx;

				.lable {
					font-size: 30rpx;
				}

				.money {
					margin-top: 40rpx;
				}

				input {
					font-size: 40rpx;
				}
        uni-radio-group{
          margin-left: 40rpx;
          uni-label{
            margin-right:30rpx;
          }
        }
			}
		}
	}
 
	.mix-btn {
		display: flex;
		align-items: center;
		justify-content: center;
		width: 90%;
		height: 100rpx;
		line-height: 100rpx;
		margin: 20px auto 15px;
		font-size: 34rpx;
		color: #fff;
		border-radius: 10upx;
		box-shadow: 1px 2px 5px rgba(0, 0, 0, 0.3);
	}

	radio {
		transform: scale(0.8);
	}

	/* 弹出层 */
	.popup-content {
		background: #FFFFFF;
		flex-direction: column;
		padding: 30rpx 50rpx;
		border-top-left-radius: 40rpx;
		border-top-right-radius: 40rpx;

		.first {
			text:nth-child(2) {
				flex: 1;
				text-align: center;
				font-size: 34rpx;
				font-weight: bold;
			}
		}

		radio-group {
			margin-top: 40rpx;

			.uni-list-cell {
				padding: 20rpx 0;
				border-bottom: 1px solid #f5f5f5;
				font-size: 32rpx;
				color: #AAAAAA;
			}

			.gray {
				/deep/.uni-radio-input {
					border: 1px solid #EEEEEE;
					background: #EEEEEE;
				}
			}
		}
	}
</style>
