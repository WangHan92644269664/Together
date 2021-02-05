<template>
	<view class="container">
		<view class="contents" v-if="data.orderOrderProducts&&data.orderOrderProducts.length>0">
		<view class="item u-f">
			<text class="iconfont icon-shouhuodizhi"></text>
			<view class="right">
				<text>{{data.order_ship_realname}} {{data.order_ship_mobile}}</text>
				<view class="font-grey">地址：{{data.order_ship_provience|getAreaName}}/{{data.order_ship_area|getAreaName}}/{{data.order_ship_county|getAreaName}} {{data.order_ship_detail}}</view>
			</view>
		</view>
			<view class="item u-f">
				<image :src="data.orderOrderProducts[0].order_product_image_url|getProductImg" mode="widthFix" class="left" v-if="data.orderOrderProducts"></image>
				<view class="right u-f u-f-fdc" v-if="data.orderOrderProducts">
					<text class="name">名称：{{data.orderOrderProducts[0].order_product_name}}</text>
					<text class="time">数量：x{{data.orderOrderProducts[0].order_product_count}}</text>
					<text class="price">价格：
						<text>￥{{data.orderOrderProducts[0].order_product_price}}</text>
						<text class="text-through font-grey">￥{{data.orderOrderProducts[0].order_product_market_price}}</text>
					</text>
				</view>
			</view>
			<view class="item order-no">
				<view><text class="font-grey">服务单号：</text>{{data.order_ship_realname}}</view>
				<view><text class="font-grey">下单时间：</text>{{data.order_add_datetime}}</view>
				<!-- <view><text class="font-grey">结束时间：</text>
				<uni-countdown class="count-down" :show-day="data.day>0" :show-colon="true" splitor-color="#999999" color="#999999" background-color="#ffffff" border-color="#CFB47E" :day="data.day" :hour="data.hours" :minute="data.minutes" :second="data.seconds"></uni-countdown>
				</view> -->
			</view>
			<view class="item money">
				<view class="u-f u-f-jsb u-f-ac"><text class="font-grey">商品总额：</text>￥{{data.order_amount_money}}</view>
				<view class="u-f u-f-jsb u-f-ac"><text class="font-grey">运费：</text>+ ￥{{data.order_ship_tax}}</view>
				<view class="u-f u-f-jsb u-f-ac"><text class="font-grey">实付款：</text><text class="font-text">￥{{data.order_amount_pay_money}}</text></view>
			</view>
		</view>
		<view class="btn u-f" v-if="data.orderOrderProducts&&data.orderOrderProducts.length>0&&data.orderOrderProducts[0].orderProductGroupMember.length===0">
			<button plain size="mini" type="warn" @click="Pay(data.order_id)">立即支付</button>
		</view>
	</view>
</template>
<script>
	import uniCountDown from '@/components/uni-countdown/uni-countdown.vue'
	export default {
		data() {
			return {
				data: {},
				status: 2
			}
		},
		components: {
			uniCountDown
		},
		onLoad (options) {
			console.log(options.id)
			this.getLists(options.id)
		},
		onShow() {
		},
		methods: {
			// 去支付
			Pay (id) {
				uni.navigateTo({
					url: '../../orders/pay/Pay?id='+id
				})
			},
			async getLists (id) {
				const data = {
					expand: 'orderOrderProducts, orderOrderProducts.orderProductGroupMember,orderOrderProducts.orderProductGroupMember.groupMemberMemberinfoAccount',
				}
				const res = await this.$api.reqOrders(data, 'get', id)
				console.log(res)
				this.data = res.data
			}
		},
	};
</script>

<style lang="scss" scoped>
.container{
	background: #f5f5f5;
	height: 100vh;
	overflow-y: scroll;
}
.contents{
	background: #FFFFFF;
	.order-no, .money{
		font-size: 32rpx;
		view:nth-child(2){
			margin: 20rpx 0;
		}
	}
	.order-no{
		view:last-child{
			margin-bottom: 0;
		}
	}
	.item{
		border-bottom: 20rpx solid #f5f5f5;
		padding: 30rpx;
		box-sizing: border-box;
		image.left{
			width: 180rpx;
			height: 180rpx;
		}
		.right{
			font-size: 34rpx;
			margin-left: 20rpx;
			.name{
				font-weight: bold;
				flex: 1;
				width: 540rpx;
				text-overflow: ellipsis;
				overflow: hidden;
				white-space: nowrap;
			}
			.time{
				margin: 10rpx 0 0;
				color: #999999;
			}
			.price{
				text:first-child{
					color: #CFB47E;
					font-size: 40rpx;
					margin-right: 20rpx;
				}
			}
		}
	}
}
.btn{
	position: fixed;
	bottom: 0;
	width: 100%;
	margin-top: 40rpx;
	background: #FFFFFF;
	padding: 20rpx 40rpx;
	box-sizing: border-box;
	justify-content: flex-end;
	button{
		margin: 0;
		padding: 0 30rpx;
		line-height: 2;
	}
}
</style>
