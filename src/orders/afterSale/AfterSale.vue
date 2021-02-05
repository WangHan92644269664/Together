<template>
	<view class="sale lighter-icon">
		<!-- 顶部导航 -->
		<view class="topTabBar">
			<view class="u-f u-f-jsa">
				<view class="grid" v-for="(grid, tbIndex) in orderType" :key="tbIndex" @tap="showType(tbIndex)">
					<view class="text" :class="[tbIndex == tab_index ? 'font-text on' : '']">
						{{grid}}
					</view>
				</view>
			</view>
		</view>
		<div class="refund-list">
			<view class="tab1" v-if='tab_index===0'>
				<view class="box">
					<view class="item u-f u-f-jsa" v-for="(item,index) in lists" :key="index">
							<view class="img-box">
								<image :src="item.order_product_image_url  | getProductImg">
							</view>
							<view class="info">
								<view class="title">{{item.order_product_name}}</view>
								<text class="btn" v-if="!item.isBack"  @click="toRefund(item.order_product_order_id,item.order_product_product_id, item.order_product_product_sku_id, item.order_product_count)">申请退货</text>
								<text class="btn" v-else>该商品已超过退货期</text>
							</view>
					</view>
				</view>
			</view>
			<view class="goodsLists" v-for="(item,index) in lists" :key="index" v-if="tab_index!==0">
				<view class="first u-f u-f-ac u-f-jsb">
					<text>服务单号: {{item.refund_sn}}</text>
				</view>
				<view class="content">
					<image :src="item.refundProduct.product_image  | getProductImg">
					<view class="rightBox">
						<view class="name">{{item.refundProduct.product_name}}</view>
						<view class="bot">
							<text class="num">数量: {{item.refund_product_count}}</text>
						</view>
					</view>
				</view>
				<view class="status" v-if="tab_index===1">
					<template v-if="item.refund_status===1">
						<text>待审核</text> <i>等待商家进行审核</i>
					</template>
					<template v-else-if="item.refund_status===2">
						<text>已确认</text> <i>商家已经确认</i>
					</template>
					<template v-else-if="item.refund_status===3">
						<text>处理中</text> <i>商家正在处理中</i>
					</template>
					<template v-else-if="item.refund_status===4">
						<text>完成</text> <i>退货已完成,感谢您的支持</i>
					</template>
				</view>
			</view>
			<text class="nodata">{{loading_text}}</text>
		</div>
	</view>
</template>
<script>
	export default {
		data() {
			return {
				headerPosition: "fixed",
				headerTop: "0px",
				orderType: ['申请退货', '处理中'],
				tab_index: 0,
				lists:[],
				account: "",
				back_deadline: parseInt(uni.getStorageSync('notConfigs').shop_product_back_deadline),
				page: 1,
				sum_total: 0,
				loading_text: '没有数据哦',
				isLoading: true,
				status: 'more',
				contentText: {
					contentdown: '查看更多',
					contentrefresh: '加载中',
					contentnomore: '没有更多',
				}
			};
		},
		onLoad(option) {
			let index = Number(option.index)
			if (index) {
				this.tab_index = index
				if (index === 1) {
					this.getRefundGoods(1)
				}
			} else {
				this.getOrder(1, 4)
			}
		},
		onReachBottom() {
			if (this.lists.length < 	Number(this.sum_total)) {
				this.loading_text = '加载中...'
				this.page++
				if (this.tab_index === 0) {
					this.getOrder(this.page, 4)
				} else if (this.tab_index === 1) {
					this.getRefundGoods(this.page)
				}
			} else {
				this.loading_text =Number( this.sum_total) === 0 ? '没有数据哦' : '已经加载完毕'
			}
		},
		methods: {
			showType(index) {
				this.tab_index = index
				this.page = 1
				this.sum_page = 1
				this.lists = []
				if (index === 0) {
					this.getOrder(1, 4)
				} else if (index === 1) {
					this.getRefundGoods(1)
				}
			},
			// 选择售后类型 id 订单id
			toRefund(id, pid, sku, count) {
				const data = {
					refund_images: [],
					refund_merchant_account: 'default',
					refund_order_id: id,
					refund_product_count: count,
					refund_product_id: pid,
					refund_product_sku_id: sku,
					refund_reason: 'default'
				}
				this.$api.postRefunds(data).then(res => {
					if (res.data.success) {
						this.tab_index = 1
						this.lists = []
						this.getRefundGoods(1)
					}
				})
			},
			// 获取所有售后信息
			async getRefundGoods(page) {
				uni.showLoading({
					title: '加载中'
				})
				let sumCount
				let user = uni.getStorageSync('userInfo').memberinfo_account
				let data1 = {
					"refund_memberinfo_account": user,
					'page':page,
					'expand':'refundProduct'
				}
				const res = await this.$api.getRefunds(data1)
				for (let i in res.data) {
					res.data[i].status = 0   //定义状态来区分是售后还是退货
				}
				this.lists = this.lists.concat(res.data)
				this.sum_total = res.header["x-pagination-total-count"] ? res.header["x-pagination-total-count"] : res.header[
					'X-Pagination-Total-Count'];
				if (this.lists === 0) {
					this.loading_text = '没有数据哦'
				} else if (res.data.length === Number(this.sum_total)) {
					this.loading_text = '已经加载完成'
				}
				this.isLoading = true
				uni.hideLoading()
			},
			// 可以申请售后的数据
			async getOrder(page, status) {
				uni.showLoading({
					title: '加载中'
				})
				let data = {
					"page": page,
					"order_status": status
				}
				const res = await this.$api.reqOrders(data,'get')
				let item = res.data
				this.sum_total = res.header["x-pagination-total-count"] ? res.header["x-pagination-total-count"] : res.header[
					'X-Pagination-Total-Count'];
				for (let i in item) {
					let item2 = item[i].orderOrderProducts
					for (let j in item2) {
						if (item2[j].order_product_refund_status === 0) {
							//计算退货和售后的时间期限
							let val = item[i].order_update_datetime
							val = (new Date(val.replace(/-/g, "/"))).getTime()
							let startDate = new Date().getTime()
							let use_back = (this.back_deadline)* 60 * 60 * 24 * 1000
							let end_back = val + use_back  //退货时间
							item2[j].isBack = startDate > end_back    // false  可退货
							this.lists = this.lists.concat(item2[j])
						}
					}
				}
				if (this.lists === 0) {
					this.loading_text = '没有数据哦'
				} else if (res.data.length === Number(this.sum_total)) {
					this.loading_text = '已经加载完成'
				}
				this.isLoading = true
				uni.hideLoading()
			}
		}
	}
</script>

<style lang="scss">
@import '@/common/css/mixin';
	.sale{
		min-height: 100vh;
		background: #e9ecf1;
	}
	.refund-list{
		width: 100%;
		padding-top: 90rpx;
		padding-bottom: 20rpx;
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
	.tab1{
		.box{
			.item{
				text-align: left;
				border-radius: 10rpx;
				padding: 20rpx;
				box-sizing: border-box;
				background: #FFFFFF;
				margin: 20rpx 20rpx 0;
				.img-box{
					image{
						width: 200rpx;
						height: 200rpx;
					}
				}
				.info{
					height: 200rpx;
					width: 65%;
					position: relative;
					.title{
						font-size: 30rpx;
						margin-top: 30rpx;
					}
					.btn{
						position: absolute;
						bottom: 20rpx;
						right: 0;
						color: $themeColor;
						border: 1px solid $themeColor;
						padding: 2px 10px;
						border-radius: 50px;
						font-size: 28rpx;
						margin-right: 0;
					}
				}
			}
		}
	}
	.goodsLists {
		text-align: left;
		border-radius: 10rpx;
		padding: 20rpx;
		box-sizing: border-box;
		background: #FFFFFF;
		margin: 20rpx 20rpx 0;
		image {
			width: 150rpx;
			height: 150rpx;
			border-radius: 20rpx;
		}

		.first {
			border-bottom: 1px solid #f5f5f5;
			padding-bottom: 20rpx;
			margin-bottom: 20rpx;
			text:first-of-type {
				color: #999999;
				font-size: 28rpx;
			}
			text:last-child{
				font-size: 30rpx;
			}
		}

		.status {
			background: #eeeeee;
			padding: 20rpx;
			border-radius: 10rpx;
			margin-top: 20rpx;

			text {
				font-size: 30rpx;
			}

			i {
				color: #999999;
				font-size: 28rpx;
				margin-left: 20rpx;
			}
		}

		.rightBox {
			float: right;
			width: 70%;

			.name {
				font-size:30rpx;
				line-height: 40rpx;
				margin-top:20rpx;
				overflow: hidden;
				text-overflow: ellipsis;
				white-space: nowrap;
			}

			.bot {
				margin-top: 20rpx;
				line-height: 40rpx;

				.num {
					font-size: 30rpx;
					color: #666666;
				}

				.sum {
					float: right;
					color: #666666;
					font-size: 30rpx;
				}

				.sumprice {
					float: right;
					font-size: 34rpx;
					color: #DE3926;
				}
			}
		}
	}
	.btn {
		justify-content: flex-end;
		margin-right: 30rpx;
		font-size: 28rpx;
		.white-btn {
			line-height: 50rpx;
			border-radius: 50rpx;
			padding: 0 15rpx;
			width: 30%;
			justify-content: center;
			text-align: center;
			border: 1px solid $themeColor;
			color: $themeColor;
		}
		.deal-btn{
			opacity: .4;
		}
		i{
			text-align: left;
			flex: 1;
			font-size: 28rpx;
			color: #999999;
		}
	}

	.badge {
		color: red;

		i {
			font-size: 30rpx;
			margin-right: 10rpx;
		}
	}

	.shou_hou {
		color: #ffab03;
	}
</style>
