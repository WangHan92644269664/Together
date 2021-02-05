<template>
	<!-- 0未支付，1待确认，2待发货，3待收货，4已完成，5取消中，6已取消，7退款中，8已退货，9售后中，10退货中，11评论  12拼团 -->
	<view class="status lighter-icon" :class="type==='2'?'btns-status':''">
		<template v-if="type==='1'">
			<view class="first u-f u-f-jsb">
				<text>{{time}}</text>
				<template v-if="status===0">
					<text class="no-pay">
						待付款
					</text>
				</template>
				<template v-else-if="status===1||status===2">
					待发货
				</template>
				<template v-else-if="status===3">
					待收货
				</template>
				<template v-else-if="status>=3&&status!==6">
					已完成
				</template>
				<template v-else-if="status===6">
					已取消
				</template>
        <!-- <template v-if="status===12&&item.order_pay_status===0&&isGroupPay">
        	<text class="no-pay">
        		待付款
        	</text>
        </template> -->
			</view>
		</template>
		<template v-else>
			<view class="u-f u-f-jsb">
				<text></text>
				<view>
					<!-- 待支付 -->
					<template v-if="status===0">
						<text class="gray" @tap="Cancel(oid)">取消订单</text>
						<text class="pay" @tap="PayOrders(oid)">去支付</text>
					</template>
					<!-- 待发货 -->
					<template v-else-if="status===2">
						<!-- <text class="gray" @tap="Cancel(oid)">取消订单</text> -->
						<text class="gray" @tap="Call">提醒发货</text>
						<text class="buy" @tap="Buy">再次购买</text>
					</template>
					<!-- 待收货 -->
					<template v-else-if="status===3">
						<!-- <text class="gray" @tap="PayOrders(oid)">查看物流</text> -->
						<text class="buy" @tap="ConfirmRece(oid)">确认收货</text>
					</template>
					<!-- 已完成 -->
					<template v-else-if="status===4||status===6||isGroupPay===false">
						<!-- <text class="gray" @tap="GO('/orders/comment/Comment?id='+oid)">去评价</text> -->
						<text class="buy" @tap="Buy">再次购买</text>
					</template>
				  <template v-if="isGroupPay===true">
					<text class="pay" @tap="PayOrders(oid)">去支付</text>
				  </template>
				  <template v-if="isEnd&&isGroupPay===null&&item.orderOrderProducts[0].orderProductGroup">
            <text class="gray">拼团结束</text>
				  </template>
				</view>
			</view>
		</template>
	</view>
</template>
<script>
  import moment from 'moment'
	export default {
		data() {
			return {
				isGroupPay: null,
				isEnd: true
			};
		},
		props: {
			status: {
				type: Number,
				default: 0
			},
			time: {
				type: String,
				default: ''
			},
			// 用来区分是右上角的显示状态还是按钮  1是显示状态  2是按钮
			type: {
				type: String,
				default: '1'
			},
			item: {
				type: Object
			  },
			oid: '',
			tabIndex:null
		},
		mounted() {
		  if (this.status === 12 && this.item) {
			if (this.item.order_pay_status === 0) {
			  if (this.item.orderOrderProducts && this.item.orderOrderProducts[0].orderProductGroup && this.item.orderOrderProducts[0].orderProductGroup.groupGroupRules) {
				const end_time = this.item.orderOrderProducts[0].orderProductGroup.groupGroupRules.group_rules_end_time
				if (moment().format('x') - moment(end_time).format('x') < 0) {
				  this.isGroupPay = true
				} else {
				  this.isEnd = true
				}
			  }
			} else if (this.item.order_pay_status === 1) {
			  this.isGroupPay = false
			}
		  }
		},
		created () {
		  console.log(25)
		  console.log(this.item)
		},
		methods: {
			GO(url) {
				uni.navigateTo({
					url: url
				})
			},
			PayOrders(id) {
				uni.navigateTo({
					url: '/orders/pay/Pay?id=' + id
				})
			},
			ConfirmRece(id) {
				this.$api.patchConfirm(id).then(res => {
					if (res.data.success) {
						this.$emit('confirmRece', true)
					}
				})
			},
			// 取消订单
			Cancel(id){
				let that = this;
				uni.showModal({
					title:'提示',
					content:'您确定要删除该订单',
					success(res) {
						if(res.confirm){
							that.$api.reqOrders('','del',id).then(res=>{
								that.$utils.Toast(res.data.message)
								if(res.data.success){
									// uni.redirectTo({
									// 	url:'/orders/orders/Orders?tbIndex=1'
									// })
									that.$emit('Delete', true)
								}
							})
						}
					}
				})
			},
			// 提醒老板接单
			Call() {
				this.$utils.Toast('已提醒，请耐心等待包裹')
			},
			// 再次购买
			Buy() {
				let item = this.item
				for (let i in item.orderOrderProducts) {
					let data = {
						cart_product_id: item.orderOrderProducts[i].order_product_product_id,
						cart_product_count: item.orderOrderProducts[i].order_product_count,
						cart_sku_id: item.orderOrderProducts[i].order_product_product_sku_id,
						cart_type: 0,
					}
					this.$api.reqCarts('put',data).then((res) => {
						if (!res.data.success) {
							this.$utils.Toast(res.data.message)
						}
					})
				}
				this.$emit('isBuy', true)
				setTimeout(() => {
					uni.switchTab({
						url:'/pages/cart/index'
					})
				}, 200)
			}
		}
	};
</script>

<style lang="scss" scoped>
	.status {
		color: #AAAAAA;
		font-size: 28rpx;
		border-bottom: 1rpx solid #EEEEEE;
		padding-bottom: 20rpx;
		margin-bottom: 20rpx;

		.no-pay {
			color: #CFB47E;
		}

		.pay,
		.buy,
		.gray {
			font-size: 28rpx;
			border-radius: 50rpx;
			padding: 6rpx 26rpx 8rpx;
			display: inline-block;
			margin-right: 20rpx;
		}

		.buy,
		.pay {
			background: #CFB47E;
			color: #FFFFFF;
		}
    .pay{
      background: rgb(203,3,3);
    }

		.gray {
			border: 1px solid #AAAAAA;
			color: #999999;
		}
	}

	.btns-status {
		border-bottom: none;
		border-top: 1rpx solid #EEEEEE;
		margin-bottom: 0;
		padding-bottom: 0;
		padding-top: 20rpx;
	}
</style>
