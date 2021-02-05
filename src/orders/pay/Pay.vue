<template>
	<view class="container lighter-icon">
		<!-- 头部导航 -->
		<view class="app">
			<view class="step">
				<view class="first u-f u-f-jsb u-f-ac">
					<text>1</text>
					<view><text></text></view>
					<text>2</text>
				</view>
				<view class="second u-f u-f-jsb">
					<text>提交订单</text>
					<text>付款</text>
				</view>
			</view>
			<view class="pay-type-list">
				<view class="box">
					<view>订单金额</view>
					<view>￥{{money}}</view>
					<view>订单提交成功，请在10分钟内完成支付。</view>
					<view class="u-f u-f-jsc">
						<text>支付方式：</text>
						<view class="right u-f u-f-jdc">
							<view v-for="(item,index) in config" :key="index" class="u-f u-f-ac u-f-jsb">
                <!-- 币种支付 -->
                <template v-if="item.type===1">
                  <view v-if="item.financeType===1" class="u-f u-f-ac u-f-jsb">
                  	<text>余额( ￥{{balance}} )</text>
                  	<radio-group @change="radioChange(item)">
                  		<radio :value="String(finance_type)" :disabled="balance === 0.00" color="#E0BF6A" :checked="finance_type==='1'" :class="{'disabled':balance === '0.00'}"/>
                  	</radio-group>
                  </view>
                  <template v-if="item.financeType===2">
                  	<text>积分( ￥{{integral}} )</text>
                  	<radio-group @change="radioChange(item)">
                  		<radio :value="String(finance_type)" :disabled="integral === '0.00'" color="#E0BF6A" :checked="finance_type==='2'" :class="{'disabled':integral === '0.00'}"/>
                  	</radio-group>
                  </template>
                </template>
                <!-- 微信公众号支付 -->
								<!-- #ifndef APP-PLUS -->
                <template v-if="item.type==='4'&&$utils.isWeixin()">
                  <text>微信支付</text>
                  <radio-group @change="radioChange(item)">
                    <radio :value="type" :checked="type==='4'" color="#E0BF6A"/>
                  </radio-group>
                </template>
								<!-- #endif -->
                <!-- 微信app支付 -->
                <template v-if="item.type==='5'">
                	<text>微信支付</text>
                	<radio-group @change="radioChange(item)">
                		<radio :value="type" :checked="type==='5'" color="#E0BF6A"/>
                	</radio-group>
                </template>
                <template v-if="item.type==='6'">
                	<text>支付宝支付</text>
                	<radio-group @change="radioChange(item)">
                		<radio :value="type" :checked="type==='6'" color="#E0BF6A" />
                	</radio-group>
                </template>
							</view>
						</view>

					</view>
				</view>
			</view>
			<button class="mix-btn" @click="Pay">去付款</button>
		</view>
		<uni-keyboard @completed="Confirm" ref="keyboard" title="支付"></uni-keyboard>
	</view>
</template>

<script>
	import uniKeyboard from '@/components/uni-keyboard.vue'
	export default {
		data() {
			return {
				type: '1',
				currentMethod: 1,
				finance_type: '1',
				orderInfo: {},
				money: 0,
				balance: 0,
				integral: 0,
				id: null,
				userinfo: uni.getStorageSync('userInfo'),
				config: '',
				othertype: '',
				title: '在线支付',
			};
		},
		computed: {},
		components: {
			uniKeyboard
		},
		onLoad(options) {
			console.log(options)
			let id = options.id;
			this.id = id;
			this.getOrder(id)
			this.getFinances()
			this.getNoConfig()
		},
		mounted() {},
		methods: {
			// 去支付页面
			Go(url) {
				uni.navigateTo({
					url: url,
					animationType: 'pop-in',
					animationDuration: 200
				});
			},
			//获取配置信息
			async getNoConfig() {
				const res = await this.$api.getConfig();
				this.config = res.data.payMethod
				console.log(this.config)
			},
			//选择支付方式
			radioChange (item) {
				console.log(item)
        if (item.financeType) {
          this.finance_type = item.financeType
        } else {
          this.finance_type = ''
        }
        this.type = '' + item.type
			},
			//确认支付
			async WX() {
				let data = {
					'order_id': this.id,
					'type': this.othertype
				}
				await this.$api.postPays(data).then(res => {
					this.$utils.wainToast(res.data.message)
					if (res.data.success) {
						uni.requestPayment({
							provider: 'wxpay',
							timeStamp: res.data.info.returnInfo.timeStamp + '',
							nonceStr: res.data.info.returnInfo.nonceStr,
							package: res.data.info.returnInfo.package,
							signType: res.data.info.returnInfo.signType,
							paySign: res.data.info.returnInfo.paySign,
							success: function(res) {
								uni.showToast({
									title: '支付成功',
									duration: 3000,
									icon: 'none',
								})
								setTimeout(function() {
									uni.redirectTo({
										url: '/orders/paySuccess/PaySuccess',
									})
								}, 1500)
							},
							fail: function(err) {
								uni.showModal({
									content: '支付失败',
									showCancel: false,
								})
							},
						})
					}
				})
			},
			getOrder(id) {
				this.$api.reqOrders('', 'get', id).then(res => {
					console.log(res)
					this.money = Number(res.data.order_amount_pay_money).toFixed(2)
				})
			},
			getFinances() {
				this.$api.getFinances().then(res => {
					console.log(res)
					for (let item of res.data) {
						if (item.finance_type === 1) {
							this.balance = Number(item.finance_award).toFixed(2)
						} else if (item.finance_type === 2) {
							this.integral = Number(item.finance_award).toFixed(2)
						}
					}
				})
			},
			// 余额支付
			Pay(){
				const userInfo = uni.getStorageSync('userInfo')
				console.log(userInfo)
				if (!userInfo.existTradePassword) {
					return uni.showModal({
						title: '提示',
						content: '请先设置交易密码!',
						success(res) {
							if (res.confirm) {
								uni.navigateTo({
									url: '../../center/pwd/Pwd?type=2'
								})
							}
						}
					})
				}
        // 支付宝只有在app中才可以支付
        if (!window.cordova) {
          uni.showToast({title: '下载APP可以使用支付宝支付', icon: 'none'})
        } else {
         this.$refs.keyboard.show()
        }
			},
			// 提交
			async Confirm(password) {
				let data = {
					'order_id': this.id,
					'type': this.type,
					'financeType': this.finance_type
				}
        const that = this
        console.log(data)
				this.pwd = password;
				uni.setStorageSync('pwd', this.pwd)
				await this.$api.postPays(data).then(res => {
					this.$refs.keyboard.hide();
          if(res.data.code!=='401.7') {
          	this.$utils.Toast(res.data.message);
          }
					if (res.data.success) {
            // 币种支付
						if (this.finance_type) {
              uni.navigateTo({
              	url: '/orders/paySuccess/PaySuccess'
              })
            } else {
             // APP支付
              if (window.cordova) {
                 // 支付宝APP支付
                if (this.type == '6') {
                  window.cordova.plugins.alipay.payment(res.data.info.returnInfo, function success (e){
                    console.log('支付成功')
                    uni.navigateTo({
                      url: '../paySuccess/PaySuccess'
                    })
                  }, function error (e) {
                    uni.showToast({title: '支付失败', icon: 'none'})
                  })
                  // this.$utils.alipayPay(res.data.info.returnInfo)
                   //微信app支付
                } else if (this.type === '5') {
                  window.Wechat.sendPaymentRequest(res.data.info.returnInfo, function (e) {
                    console.log(234)
                    console.log('success', e)
                    that.$utils.Toast('支付成功')
                  }, function (err) {
                    console.log('err', err)
                    that.$utils.Toast('支付失败')
                  })
                }
              } else {
                
              }
            }
					} else {
            uni.showToast({title: res.data.message, icon: 'none'})
          }
				})
			},
		},
	}
</script>
<style lang='scss' scoped>
	/deep/.uni-steps__row-title {
		font-size: 16px;
	}
	/deep/.disabled .uni-radio-input{
		background: #aaaaaa!important;
	}

	.container {
		.app {
			background: #E9ECF1;
			padding: 0 30rpx;
			height: 100vh;
			overflow: hidden;

			.step {
				padding: 50rpx 0;
				width: 80%;
				margin: 0 auto;

				.first {
					text {
						background: #E0BF6A;
						width: 38rpx;
						height: 38rpx;
						line-height: 42rpx;
						text-align: center;
						border-radius: 100%;
						color: #FFFFFF;
						font-size: 28rpx;
					}

					view {
						flex: 1;
						height: 6rpx;
						background: #ddd;
						margin: 0 10rpx;
						border-radius: 10rpx;
						position: relative;

						text {
							height: 6rpx;
							position: absolute;
							background: #E0BF6A;
							width: 50%;
							display: inline-block;
						}
					}
				}

				.second {
					font-size: 28rpx;
					color: #aaa;
					margin-top: 15rpx;

					text:first-child {
						position: relative;
						left: -30rpx;
					}

					text:last-child {
						position: relative;
						left: 10rpx;
					}
				}
			}

			.pay-type-list {
				background-color: #fff;
				border-radius: 10rpx;
				padding: 50rpx 0;

				.box {
					text-align: center;
					font-size: 34rpx;

					>view:nth-child(2) {
						color: #e22222;
						font-size: 70rpx;
						margin: 20rpx 0;
					}

					>view:nth-child(4) {
						margin-top: 30rpx;

						.icon-weixin {
							color: #149545;
							font-size: 44rpx;
							margin: 0 10rpx;
						}

						.right {
							font-size: 34rpx;
							flex-direction: column;
						}
					}

				}

				.type-item {
					height: 100rpx;
					padding: 0 30rpx;
					display: flex;
					justify-content: space-between;
					align-items: center;
					font-size: 15px;
					position: relative;
				}

				.tit {
					margin-bottom: 2px;
				}

				.con {
					flex: 1;
					display: flex;
					flex-direction: column;
					margin-left: 10px;
				}
			}

			.mix-btn {
				font-size: 34rpx;
				background: #dbc291;
			}

			radio {
				transform: scale(0.7);
			}
		}
	}
</style>
