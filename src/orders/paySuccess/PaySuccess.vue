<template>
	<view class="content lighter-icon">
		<!-- 头部导航 -->
		<!-- 支付成功标志 -->
		<view class="pay-success u-f u-f-fdc u-f-ac">
			<!-- 查看订单 -->
			<navigator url="/orders/orders/Orders?tbIndex=2" open-type="redirect" class="check-order u-f u-f-ac u-f-jsc">
				<text>查看订单</text>
				<text class="iconfont icon-arrow-right1"></text>
			</navigator>
			<view class="success-logo iconfont icon-zhifuchenggong">
			</view>
			<text>支付成功</text>
		</view>
		<view class="pay-next u-f u-f-jsa u-f-ac">
			<text class="continue-buy u-f u-f-jsa u-f-ac" @click="Go('/pages/home/index')">继续购物</text>
			<text class="alert-boss  u-f u-f-jsa u-f-ac" @tap="Call">提醒老板接单</text>
		</view>

		<view class="alert-info">点击上面的<text class="strong">"提醒老板接单"</text>按钮,将提醒消息发送到自提店微信群,提醒老板及时处理您的订单。</view>
	</view>
</template>

<script>
	export default {
		data() {
			return {
				title: '下单成功'
			}
		},
		methods: {
			Go(url) {
				uni.switchTab({
					url: url,
					animationType: 'pop-in',
					animationDuration: 200
				});
			},
			// 提醒老板接单
			Call(){
				this.$utils.Toast('已提醒，请耐心等待包裹')
			}
		},
		mounted() {

		},
	}
</script>

<style lang='scss'>
	.content {
		.pay-success {
			position: relative;
			width: 100%;
			height: 370rpx;
			margin-top: 180rpx;

			.check-order {
				font-size: 30rpx;
				color: #FFFFFF;
				position: absolute;
				top: -130rpx;
				right: -20rpx;
				width: 226rpx;
				height: 70rpx;
				border-radius: 50rpx 0 0 50rpx;
				background-color: #E0BF6A;
			}

			.success-logo {
				font-size: 100px;
				color: #E0BF6A;
			}
		}

		.pay-next {
			width: 100%;
			height: 130rpx;

			.alert-boss,
			.continue-buy {
				width: 200rpx;
				color: #E0BF6A;
				font-size: 30rpx;
				font-weight: 550rpx;
				border: 1px solid #E0BF6A;
				border-radius: 90rpx;
				padding: 15rpx 30rpx;
			}

			.alert-boss {
				color: #fff;
				background-color: #E0BF6A;
			}
		}

		.alert-info {
			width: 90%;
			height: 100rpx;
			margin: 30rpx auto;
			font-size: 30rpx;
			color: #727272;

			.strong {
				color: #E0BF6A;
			}
		}

		.safe-alert {
			width: 90%;
			margin: 60rpx auto;
			color: #ACACAC;
			font-size: 30rpx;
		}
	}
</style>
