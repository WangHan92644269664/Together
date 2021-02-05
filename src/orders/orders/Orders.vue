<template>
	<view class="orders-box lighter-icon">
		<!-- 顶部导航 -->
		<view class="topTabBar">
			<view class="u-f u-f-jsa">
				<view class="grid" v-for="(grid, tbIndex) in orderType" :key="tbIndex" @tap="showType(tbIndex)">
					<view class="text" :class="[tbIndex == tabbarIndex ? 'font-text on' : '']">
						{{grid}}
					</view>
				</view>
			</view>
		</view>
		<!-- 考虑非APP端长列表和复杂的DOM使用scroll-view会卡顿，所以漂浮顶部选项卡使用page本身的滑动 -->
		<view class="order-list">
			<view class="list" v-if="list.length>0">
				<view class="all" v-for="(item,index) in list" :key="index">
					<OrderStatus :status="item.order_status" type="1" :oid="item.order_id" :time="item.order_update_datetime"></OrderStatus>
					<!-- 商品信息 -->
					<view class="goods u-f u-f-fdc" v-for="(box,i) in item.orderOrderProducts" :key="i">
						<view class="u-f u-f-jsb u-f-ac">
							<view class="goods-left u-f u-f-ac">
								<view class="goods-img">
									<image :src="productImg+box.order_product_image_url"></image>
								</view>
								<view class="goods-info">
									<strong class="goods-info-top">{{box.order_product_name}}</strong>
									<view class="goods-info-bottom u-f u-f-fdc u-f-jsb">
										<!-- <text>提货时间</text> -->
										<view class="second">
											<text class="lighter-icon  font-text">￥{{box.order_product_price}}</text>
											<text class="lighter-icon">￥{{box.order_product_market_price}}</text>
										</view>
									</view>
								</view>
							</view>
							<view class="goods-right">
								<text>x{{box.order_product_count}}</text>
							</view>
						</view>
						<view class="total-money u-f u-f-jsb">
							<!-- <text v-if="Number(item.order_voucher_number).toFixed(0)!=='0'" class="lighter-icon">使用消费券抵扣{{item.order_voucher_number}}元</text> -->
							<text></text>
							<text class="lighter-icon">共支付{{item.order_amount_pay_money|two}}元</text>
						</view>
					</view>
					<!-- 按钮 -->
					<OrderStatus :status="item.order_status" type="2" @isBuy="Buy" @Delete="Delete" :oid="item.order_id" :item="item" @confirmRece="confirmRece"></OrderStatus>
				</view>
				<text class="nodata-text u-f u-f-jsc">{{loading_text}}</text>
			</view>
			<view class="nodata" v-else>
				<i class="iconfont icon-dingdan4"></i>
				<text>您还没有相关的订单</text>
				<navigator url="/category/productList/ProductList" open-type="navigate" class="background-text">马上去购物</navigator>
			</view>
		</view>
	</view>
</template>
<script>
	import OrderStatus from './child/OrderStatus.vue'
	import Search from '@/components/Search.vue'
	export default {
		components: {
			OrderStatus,
			Search,
		},
		data() {
			return {
				title: '我的订单',
				is_back: true,
				headerPosition: 'fixed',
				headerTop: '0px',
				orderType: [
					'全部',
					'待付款', '待发货', '待收货', '已完成'
				],
				//订单列表 演示数据
				list: [],
				tabbarIndex: 0,
				productImg: this.$utils.productImg,
				page: 1,
				sum_total: 0,
				loading_text: '没有数据哦',
				loading: false,
				isLoading: true,
				status: 'more',
				contentText: {
					contentdown: '查看更多',
					contentrefresh: '加载中',
					contentnomore: '没有更多',
				},
				is_buy: false
			}
		},
		onReachBottom() {
			if (this.list.length < this.sum_total) {
				this.loading_text = '加载中...'
				this.page++
				if (this.tabbarIndex === 0) {
					this.getAlls('', this.page)
				} else if (this.tabbarIndex === 1) {
					this.getAlls(0, this.page)
				} else {
					this.getAlls(this.tabbarIndex, this.page)
				}
			} else {
				this.loading_text = this.sum_total === 0 ? '没有数据哦' : '已经加载完毕'
			}
		},
		onLoad(option) {
			//option为object类型，会序列化上个页面传递的参数
			let tbIndex = parseInt(option.tbIndex)
			this.tabbarIndex = tbIndex
			if (tbIndex) {
				this.showType(tbIndex)
			} else {
				this.getAlls('', 1)
			}
		},
		// 监听返回键
		onUnload: function() {
			//相当于监听返回按钮
			// let pages = getCurrentPages();
			// console.log(pages)
			// let prevPage = pages[pages.length - pages.length]; //上一个页面
			// prevPage.setData({
			// 	activeCategoryId: 0,
			// })
			if(!this.is_buy) {
				uni.switchTab({
					url:'/pages/center/index'
				})
			}
		},
		methods: {
			Buy(e) {
				this.is_buy = e
			},
			Delete (e) {
				if (e) {
					this.list = []
					this.page = 1
					this.tabbarIndex = 1
					this.getAlls(0, this.page)
				}
			},
			// 获取所有订单
			getAlls(id, page) {
				uni.showLoading({
					title: '加载中'
				})
				let url = {
					page: page,
					expand: 'orderOrderProducts,orderOrderProducts.orderProductGroup.groupGroupRules'
				}
				if (this.tabbarIndex !== 0) {
					url['order_status'] = id
				}
				this.isLoading = true
				this.$api.reqOrders(url, 'get').then((res) => {
					this.sum_total = res.header["x-pagination-total-count"] ? res.header["x-pagination-total-count"] : res.header[
						'X-Pagination-Total-Count'];
					uni.hideLoading()
					for (let item of res.data) {
						this.list.push(item)
						for (let item2 of item.orderOrderProducts) {
							if (item2.order_product_image_url) {
								item2.order_product_image_url = item2.order_product_image_url.split(';')[0]
							}
						}
					}
				})
			},
			// 切换tab
			showType(tbIndex) {
				this.tabbarIndex = tbIndex
				this.list = []
				this.page = 1
				if (tbIndex === 0) {
					this.getAlls('', this.page)
				} else if (tbIndex === 1) {
					this.getAlls(0, this.page)
				} else {
					this.getAlls(tbIndex, this.page)
				}
			},
			// 确认收货
			confirmRece(e) {
				console.log(e)
				if (e) {
					this.tabbarIndex = 4
					this.showType(4)
					console.log(this.tabbarIndex)
				}
			},
			showLogistics(row) {},
			remindDeliver(row) {
				uni.showToast({
					title: '已提醒商家发货',
				})
			},
			// 取消订单
			cancelOrder(id) {
				uni.showModal({
					title: '取消订单',
					content: '确定取消此订单？',
					success: (res) => {
						if (res.confirm) {
							this.$api.reqOrders('', 'del', id).then((res) => {
								this.$store.state.is_error = false
								this.$utils.Toast(res.data.message)
								if (res.data.success) {
									if (this.tabbarIndex === 0) {
										this.tabbarIndex === 0
										this.getAlls()
									} else {
										this.tabbarIndex = 1
										this.getAlls(0)
									}
								}
							})
						} else if (res.cancel) {
							console.log('用户点击取消')
						}
					},
				})
			},
			// 确认收货
			patchConfirm(id) {
				this.$api.patchConfirm(id).then((res) => {
					console.log(res)
					if (res.data.success) {
						this.$store.state.is_error = false
						this.$utils.Toast(res.data.message)
						setTimeout(() => {
							this.tabbarIndex = 4
							this.getAlls(4)
						}, 1000)
					} else {
						this.$store.state.is_error = true
						this.$utils.Toast(res.data.message)
					}
				})
			},
			viewLogistics(index) {
				// let id = this.orderList[this.tabbarIndex][index].order_id;
				this.$utils.wainToast('正在完善')
			},
			// 去搜索
			getSinfo() {
				uni.navigateTo({
					url: '/home/search/Search',
					animationType: 'pop-in',
					animationDuration: 200
				});
			},
		},
	}
</script>

<style lang="scss" scoped>
	.nodata {
		margin: 30% auto;
		text-align: center;
		font-size: 28rpx;
		color: #999;

		i {
			font-size: 150rpx;
			color: #D6DBE1;
		}

		text {
			margin: 50rpx 0;
			display: block;
		}

		navigator {
			width: 40%;
			padding: 24rpx 0;
			color: #FFFFFF;
			border-radius: 100rpx;
			margin: 0 auto;
			font-size: 32rpx;
		}
	}

	.nodata-text {
		margin: 30rpx auto;
		color: #999999;
	}

	.orders-box {
		min-height: 100vh;
		background: #e9ecf1;
	}

	.topTabBar {
		width: 100%;
		position: fixed;
		z-index: 10;
		background-color: #fff;
		padding-bottom: 8rpx;

		.grid {
			width: 20%;
			display: flex;
			justify-content: center;
			align-items: center;
			color: #666;
			font-size: 30rpx;
			font-weight: 600;

			.text {
				height: 76rpx;
				display: flex;
				align-items: center;

				&.on {
					border-bottom: solid 2px #E0BF6A;
				}
			}
		}

		/deep/ .search[data-v-7cb41050] {
			padding: 3%;
			margin: 0;
		}

		/deep/ .search uni-input[data-v-7cb41050] {
			background-color: #f3f3f3;
		}
	}

	.order-list {
		width: 100%;
		padding-top: 80rpx;
		padding-bottom: 20rpx;

		.list {
			width: 96%;
			margin: 0 auto;

			.all {
				margin-top: 20rpx;
				background-color: #fff;
				border-radius: 10rpx;
				padding: 20rpx;
				box-sizing: border-box;

				.all-head {
					padding: 10rpx;
					border-bottom: 1px solid #ececee;
					margin-bottom: 30rpx;

					text:first-child {
						color: #949494;
						font-size: 30rpx;
					}

					text:last-child {
						color: #000;
						font-size: 35rpx;
					}

					.pick-goods {
						color: #e60514 !important;
					}
				}

				.goods {
					font-size: 30rpx;
					padding-bottom: 20rpx;

					.goods-left {
						.goods-img {
							width: 170rpx;
							height: 170rpx;
							border-radius: 10rpx;

							image {
								width: 100%;
								height: 100%;
							}
						}

						.goods-info {
							padding-left: 30rpx;
							display: flex;
							justify-content: space-between;
							flex-direction: column;

							.goods-info-top {
								font-size: 30rpx;
							}

							.goods-info-bottom {
								margin-top: 30rpx;

								.second {
									text:first-child {
										font-size: 38rpx;
										font-weight: 550;

										small {
											font-weight: lighter;
										}
									}
								}

								.second text:nth-child(2) {
									color: #aaa;
									margin-left: 20rpx;
									text-decoration: line-through;
								}
							}
						}
					}

					.goods-right {
						text {
							font-size: 30rpx;
							color: #666666;
						}
					}

					.re-buy {
						align-self: flex-end;
						color: #e86317;
						padding: 5rpx 30rpx;
						border: 2px solid #e86317;
						border-radius: 50rpx;
						font-weight: 550;
					}
				}

				.btn-box {
					border-top: 1px solid #ececee;
					text-align: right;
					padding-top: 20rpx;

					text {
						color: #e86317;
						padding: 5rpx 30rpx;
						border: 2px solid #e86317;
						border-radius: 50rpx;
						font-weight: 550;
						font-size: 30rpx;
					}
				}
			}

			.wait-pay {
				width: 90%;
				margin: 350rpx auto;

				.have-order {
					font-size: 30rpx;
					color: #ccc;
				}

				.go-shop {
					margin-top: 30rpx;
					padding: 20rpx 40rpx;
					background-color: #e60213;
					border-radius: 50rpx;
					color: #fff;
				}
			}

			.onorder {
				width: 100%;
				height: 50vw;
				display: flex;
				justify-content: center;
				align-content: center;
				flex-wrap: wrap;

				.text {
					width: 100%;
					height: 60rpx;
					font-size: 32rpx;
					color: #555;
					display: flex;
					justify-content: center;
					align-items: center;
				}
			}

			.row {
				width: calc(100% - 40rpx);
				padding: 10rpx 20rpx;
				border-radius: 10rpx;
				background-color: #fff;
				margin-top: 30rpx;

				.type {
					font-size: 26rpx;
					color: #039157;
					height: 50rpx;
					display: flex;
					align-items: center;
					font-weight: bold;
					margin-bottom: 2px;
				}

				.date {
					margin-bottom: 20rpx;
					font-size: 30rpx;
					color: #444;
				}

				.order-info {
					justify-content: flex-start;

					.left {
						image {
							width: 140rpx;
							height: 140rpx;
							border-radius: 20rpx;
						}
					}

					.right {
						margin-left: 40rpx;
						flex-direction: column;
						width: 100%;

						.name {
							font-size: 32rpx;
							display: -webkit-box;
							-webkit-box-orient: vertical;
							-webkit-line-clamp: 2;
							overflow: hidden;
							font-weight: bold;
							margin: 10rpx 0;
						}

						.spec {
							color: #a7a7a7;
							font-size: 30rpx;

							text {
								margin-right: 20rpx;
							}
						}
					}
				}

				// 金额
				.detail {
					justify-content: flex-end;
					height: 60rpx;
					font-size: 26rpx;
					color: #999999;

					.sum {
						margin-left: 20rpx;
						font-size: 30rpx;

						.price {
							color: #333;
							margin-left: 10rpx;
						}
					}
				}

				// 按钮
				.btns {
					padding: 20rpx 0 15rpx;
					justify-content: flex-end;
					border-top: 1px solid #eeeeee;

					span {
						display: flex;
					}
				}
			}
		}
	}

	.total-money {
		margin-top: 20rpx;
		color: #666;
		font-size: 28rpx;
	}
</style>
