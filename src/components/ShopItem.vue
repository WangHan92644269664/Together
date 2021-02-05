<template>
	<view class="shop-detail u-f u-f-jsb lighter-icon">
		<block v-for="(item,index) in goodsList" :key="index">
			<template v-if="item.product_is_sale===1">
				<view class="shop-item u-f u-f-jsb"  @tap="Detail(item.product_id)">
				<!-- 	<image :src="item.product_image|getProductThumbImg" mode="widthFix" :lazy-load="true" v-if="type!=='1'"></image> -->
					<image :src="item.product_image|getProductImg" mode="widthFix" :lazy-load="true" ></image>
					<view class="shop-title font-one" :class="[type==='1'?'shop-title-cate':'']">
						{{item.product_name}}
					</view>
					<view class="shop-bottom" :class="[type==='1'?' u-f u-f-jsb u-f-ac shop-bottom-cate':'']">
						<view :class="[type==='1'?'shop-bottom-left':'']">
							<view class="coupon background-text" v-if="item.product_voucher_number>0">{{ Number(item.product_voucher_number).toFixed(0) }}元券</view>
							<!-- 不带有sku的价格展示 -->
							<view class="prices" v-if="item.product_is_specs===0">
								<text class="one">￥</text>
								<text class="two lighter-icon">{{item.product_price}}</text>
								<text class="four lighter-icon">￥{{item.product_market_price}}</text>
							</view>
							<!-- 带sku的价格展示 -->
							<view class="prices" v-else>
								<text class="one">￥</text>
								<text class="lighter-icon three">{{item.product_price_min}}</text>
							</view>
						</view>
						<view class="shop-bottom-right u-f u-f-fdc u-f-ac u-f-jsa" v-if="type==='1'">
							<view class="startTime">
								<view class="add-shopcar u-f u-f-fdc u-f-ac" @tap.stop="addCart(index,'cart')" v-if="!item.cart_product_count">
									<text>加入购物车</text>
								</view>
								<view class="inputs u-f  u-f-ac" v-else>
									<text @tap.stop="addCart(index,'plus')">-</text>
									<text class="count">{{item.cart_product_count}}</text>
									<text @tap.stop="addCart(index,'add')">+</text>
								</view>
							</view>
						</view>
					</view>
				</view>
			</template>
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
				code_text: uni.getStorageSync('userInfo').memberinfo_account
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
		onShow() {
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
	.shop-detail {
		flex-wrap: wrap;
		margin: 20rpx;
		.shop-item {
			width: 48.5%;
			margin-bottom: 20rpx;
			border-bottom: 1px solid #f5f5f5;
			box-shadow: 0 0 10rpx #bbbbbb;
			background: #FFFFFF;
			padding: 20rpx 20rpx 0 20rpx;
			border-radius: 10rpx;
			box-sizing: border-box;
			flex-direction: column;

			image {
				width: 100%;
				height: 100%;
				// height: 300rpx;
				// height: 300rpx;
			}

			.detail {
				position: absolute;
				bottom: 250rpx;
				right: 30rpx;
				font-size: 26rpx;
				color: #FFFFFF;
				background: rgba(100, 100, 100, 0.6);
				padding: 4rpx 16rpx;
				border-radius: 40rpx;
				font-weight: lighter;

				.iconfont {
					font-size: 24rpx;
					margin-left: 10rpx;
				}
			}

			.coupon {
				color: #fff;
				font-size: 24rpx;
				border-radius: 20rpx;
				padding: 0 10rpx 0.6rpx;
				margin:10rpx 0;
				display: inline-block;
			}

			.shop-title {
				word-break: break-all;
				font-size: 28rpx;
				color: #000000;
				margin-top: 10rpx;
			}
			.shop-title-cate{
				margin: 10rpx 0;
			}

			.shop-bottom {
				padding:10rpx 10rpx 20rpx 0;

				.prices {
					color: #E60012;
					font-size: 32rpx;

					.two {
						color: #E60012;
						font-size: 36rpx;
						padding-right: 10rpx;
						font-weight: bold;
					}

					.three,
					.four {
						font-size: 32rpx;
						color: #bbb;
						font-weight: lighter!important;
						text-decoration: line-through;
					}
				}
			}
			.shop-bottom-cate{
				padding: 0 10rpx 20rpx 0;
			}
		}

		.shop-bottom-right {
			.xianliang {
				color: #ED9963;
				font-size: 30rpx;
			}

			.startTime {
				color: #FFF;

				.add-shopcar {
					background-color: #DFBB76;
					border-radius: 60rpx;
					padding: 14rpx 20rpx;
					color: #FFFFFF;
					font-size: 30rpx;
				}

				.inputs {
					text {
						border: 1rpx solid #E70012;
						height: 46rpx;
						width: 46rpx;
						line-height: 38rpx;
						text-align: center;
						border-radius: 50%;
						color: #E70012;
					}

					.count {
						border: none;
						margin: 0 24rpx;
						color: #000;
						font-size: 40rpx;
					}

					text:last-child {
						background: #E70012;
						color: #FFFFFF;
					}
				}
			}
		}
	}
</style>
