<template>
	<view class="shop-detail u-f u-f-jsb lighter-icon">
		<block v-for="(item,index) in goodsList" :key="index">
			<view class="item">
				 <view class="top-box u-f u-f-ac">
					 <image :src="item.groupRulesProduct.product_image|getProductImg" mode="widthFix" class="left"></image>
					 <view class="right" @click="Detail(item.groupRulesProduct.product_id)">
						 <view class="top">
							 <image :src="item_url + 'drop@2x.png'" mode="scaleToFill"></image>
							 <text class="new-price">活动价:<text class="price">{{item.group_rules_product_price[0].product_sku_price|Fixed}}</text>元</text>
							 <text class="old-price">日常价:<text class="price">{{item.group_rules_product_price[0].product_sku_market|Fixed}}</text>元</text>
							 <view class="center-price u-f">
								 <text>到手价</text>
								 <text><text>{{item.group_rules_product_price[0].product_sku_price|Fixed}}</text>元</text>
							 </view>
							 <view class="bottom u-f u-f-ac u-f-jsb">
								 <text class="font-one">{{item.groupRulesProduct.product_name}}</text>
								 <text class="small add-btn">我要拼</text>
							 </view>
						 </view>
					 </view>
				 </view>
				 <view class="group u-f u-f-ac u-f-jsb">
					 <text v-if="item.groupRulesProduct.product_product_group_id[0]">{{item.groupRulesProduct.product_product_group_id[0]|getGroupName}}</text>
					 <text v-else></text>
					 <text class="small num-people">已有{{item.group_product_count ?item.group_product_count:0}}人排队</text>
				 </view>
			</view>
		</block>
	</view>
</template>

<script>
	export default {
		props: {
			goodsList: {
				default: [],
				type: Array
			},
			type: '', //商品列表展示是一行还是两行
		},
		data() {
			return {
				img_url: this.$utils.productImg,
				Lists: [],
				token: uni.getStorageSync('token'),
				code_text: uni.getStorageSync('userInfo').memberinfo_account,
				item_url: this.$utils.webImg2
			};
		},
		watch: {
			goodsList(newVal) {
				this.Lists = newVal
			}
		},
		onShareAppMessage(options) {
			let that = this;
			let shareObj = {
				title: '爱拼',
				path: '/pages/home/index?scene=' + that.code_text
			}
			return shareObj
		},
		created () {
			this.token = uni.getStorageSync('token')
		},
		methods: {
			// 点击右边的每个商品跳转到商品详情
			Detail(id) {
				console.log(id)
				uni.navigateTo({
					url: `/home/detail/Detail?id=${id}`,
					animationType: 'pop-in',
					animationDuration: 200
				});
			},
			addCart(index, type, index1) {
				let that = this;
				let item = []
				if (!this.token) {
					uni.showModal({
						title:'提示',
						content:'登录之后才能加入购物车',
						success(res) {
							if(res.confirm){
								that.$author.auth()
							}else{
								console.log('请先登录')
							}
						}
					})
				} else {
					if (this.home) {
						item = that.Lists[index1].product[index]
					} else {
						item = that.Lists[index]
					}
					if (type === 'cart') {
						let data = {
							cart_product_id: item.product_id,
							cart_product_count: 1,
							cart_sku_id: item.product_sku_attribute.data[0].sku_id,
							cart_type: 0,
						}
						that.$api.reqCarts('put', data).then(res => {
							// 操作之后设置数据，用$set强制在页面上展示最新数据
							console.log(item)
							that.$set(that.Lists, index, {
								product_id: item.product_id,
								product_image: item.product_image,
								product_name: item.product_name,
								product_price: item.product_price,
								product_market_price: item.product_market_price,
								product_sku_attribute: item.product_sku_attribute,
								cart_product_count: res.data.info.cart_product_count,
								cart_id: res.data.info.cart_id,
								product_is_specs: item.product_is_specs,
								product_price_min: item.product_price_min,
								product_voucher_number: item.product_voucher_number
							})
						})
					} else {
						let data = {};
						if (type === 'add') {
							data['cart_product_count'] = ++item.cart_product_count
						} else {
							data['cart_product_count'] = --item.cart_product_count
							if (item.cart_product_count === 0) {
								return that.$api.delCarts(item.cart_id)
							}
						}
						that.$api.patchCarts(item.cart_id, data)
					}
					that.$forceUpdate()
				}
			}
		},
	};
</script>

<style lang="scss" scoped>
	.small{
		font-size: 26rpx;
	}
	.shop-detail{
		flex-wrap: wrap;
		.item{
			background: #FFFFFF;
			width: 100%;
			border-radius: 10rpx;
			padding: 20rpx;
			margin-bottom: 30rpx;
			image.left{
				width: 180rpx;
				height: 180rpx;
				margin-right: 20rpx;
			}
			.right{
				flex: 1;
				position: relative;
				image{
					width: 340rpx;
					height: 140rpx;
					margin-left: 40rpx;
				}
				.new-price, .old-price, .center-price{
					position: absolute;
					transform: scale(0.7);
					color: #FF1AD5;
					font-weight: bold;
					text.price{
						font-size: 34rpx;
					}
				}
				.new-price{
					left: -26rpx;
					top: 50rpx
				}
				.old-price{
					right: -20rpx;
					top: 40rpx;
				}
				.center-price{
					right: 44%;
					top: 33rpx;
					flex-direction: column;
					text{
						text-align: center;
						color: #FFFFFF;
					}
					text:first-child{
						width: 90rpx;
					}
					text:last-child{
						margin-top: 2rpx;
						text{
							font-size: 46rpx;
						}
					}
				}
				.bottom{
					.font-one{
						width: 340rpx;
					}
				}
			}
		}
	}
	.add-btn{
		background: red;
		color: #FFFFFF;
		border-radius: 10rpx;
		padding:4rpx 14rpx 10rpx;
	}
	.group{
		margin-top: 20rpx;
		.num-people{
			background: #FF9999;
			color: #ffffff;
			font-size: 30rpx;
			transform: scale(.85);
			border-radius: 10rpx;
			padding:4rpx 14rpx 10rpx;
		}
	}
</style>
