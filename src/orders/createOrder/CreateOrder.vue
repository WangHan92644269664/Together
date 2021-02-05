<template>
	<view class="createBox lighter-icon">
		<view class="address-section">
			<view class="order-content" @tap="edit(address.address_id)">
				<uni-icons type="location-filled" size="24" class="icon-shouhuodizhi"></uni-icons>
				<view class="cen" v-if="address">
					<view class="top">
						<text class="name">{{address.address_realname}}</text>
						<text class="mobile lighter-icon">{{address.address_mobile}}</text>
						<text v-if="address.address_is_default===1" class="default background-text">默认</text>
					</view>
					<text class="address">{{address.address_provience|getAreaName}}/{{address.address_area|getAreaName}}/{{address.address_county|getAreaName}}{{address.address_detail}}</text>
				</view>
				<uni-icons type="arrowright" size="25" color="#777"></uni-icons>
			</view>
			<image class="a-bg" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAu4AAAAFCAYAAAAaAWmiAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNiAoV2luZG93cykiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6Rjk3RjkzMjM2NzMxMTFFOUI4RkU4OEZGMDcxQzgzOEYiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6Rjk3RjkzMjQ2NzMxMTFFOUI4RkU4OEZGMDcxQzgzOEYiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpGOTdGOTMyMTY3MzExMUU5QjhGRTg4RkYwNzFDODM4RiIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpGOTdGOTMyMjY3MzExMUU5QjhGRTg4RkYwNzFDODM4RiIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PrEOZlQAAAiuSURBVHjazJp7bFvV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"></image>
		</view>
		<!-- 购物车结算 -->
		<view class="goods-section">
			<!-- 商品列表 -->
			<view class="g-item" v-for="(item,index) in lists.orderOrderProducts" :key="index">
				<image :src="imgUrl+item.order_product_image_url[0]"></image>
				<view class="right">
					<text class="title font-one">{{item.order_product_name}}</text>
					<view class="spec" v-if="item.order_product_sku!==null">
						<text v-for="(item2,index2) in item.order_product_sku" :key="index2">{{item2.attribute}} : {{item2.value}}</text>
					</view>
					<view class="price-box">
						<text class="price lighter-icon">￥{{item.order_product_price|two}}</text>
						<text class="number lighter-icon">x {{item.order_product_count}}</text>
					</view>
				</view>
			</view>
		</view>

		<view class="money">
			<view class="item">
				<template v-if="orders[0].order_product_group_rules_id">
					<text>活动价格</text><text class="lighter-icon">￥{{lists.order_amount_money|two}}</text>
				</template>
				<template v-else>
					<text>商品金额</text><text class="lighter-icon">￥{{lists.order_amount_money|two}}</text>
				</template>
			</view>
				<view class="item"><text>运费</text><text class="lighter-icon">￥{{lists.order_ship_tax|two}}</text></view>
			<!-- <view class="item u-f u-f-ac lighter-icon" v-if="Number(lists.order_voucher_number).toFixed(0)!=='0'">
				<text class="lighter-icon">可用消费券抵扣{{lists.order_voucher_number|two}}</text>
				<checkbox-group @change="ChangeCheck">
					<checkbox :checked="is_check" color="#000000" style="transform: scale(0.7);"/>
				</checkbox-group>
			</view> -->
		</view>
		<view class="remark-box">
			<view class="item-title">
				备注:
				<text class="remark-notice">(100字以内)</text>
			</view>
			<textarea class="remark-inp" maxlength="100" v-model="memo" placeholder="请填写备注信息" />
			</view>
		<view class="footer u-f u-f-jsb u-f-ac">
			<view class="price-content" >
				<text>合计：</text>
				<text class="price-tip">￥</text>
				<text class="price lighter-icon">{{fin_money|two}}</text>
			</view>
			<text class="submit background-text" @click="submit">提交订单</text>
		</view>
	</view>
</template>

<script>
	import uniIcons from '@dcloudio/uni-ui/lib/uni-icons/uni-icons.vue'
	import uniPopup from '@/components/uni-popup/uni-popup.vue'
	export default {
		data() {
			return {
				lists: {},
				userinfo: uni.getStorageSync('userInfo').memberinfo_account,
				address: null,
				imgUrl: this.$utils.imgUrl + '/product/',
				ids: '',
				memo: '',
				type: 0,
				pay_value: 0, //支付方式
				quan_value: 0, //消费券面值
				pay_list: [], //支付方式数据
				coupons: [], //可用的消费券数据
				disabledCoupons: [], //不可用的消费券数据
				quan_show: false, //是否显示消费券列表
				pay_show: false, //是否显示支付方式列表
				quan_id: 0, //是否显示支付方式列表
				fin_money: 0, //优惠后的价格
				all_money: 0, //优惠前的价格
				theme_color:uni.getStorageSync('theme_color'),
				is_check:false,
				orders: []
			}
		},
		onLoad(options) {
			this.type = Number(options.type) // 0 通过购物车提交，1通过商品提交
			const orders = JSON.parse(uni.getStorageSync('params'))
			this.orders = orders
			console.log(orders)
		},
		watch: {
			quan_value() {
				console.log(this.all_money)
				this.fin_money = this.all_money - this.quan_value;
				this.quan_show = false;
			},
		},
		onShow() {
			this.getAddress()
			this.is_check = false
		},
		mounted() {},
		methods: {
			// 选择消费券
			ChangeCheck(e){
				this.is_check = !this.is_check
				if(this.is_check){
					this.fin_money = this.all_money - Number(this.lists.order_voucher_number).toFixed(2)
				}else{
					this.fin_money = this.all_money
				}
			},
			edit(id) {
				console.log(id)
				uni.navigateTo({
					url: '/center/editAddress/EditAddress?id=' + id+'&type=order'
				})
			},
			// 获取地址
			async getAddress() {
				let data = {
					'address_account': this.userinfo
				}
				await this.$api.getAddresses(data).then(res => {
					if (res.data.length === 0) {
						this.$utils.Toast('请先添加收货地址')
						setTimeout(() => {
							uni.navigateTo({
								url: '/center/address/Address?type=order'
							})
						}, 1000)
					} else {
						this.address = res.data[0];
						this.getLists();
					}

				})

			},
			// 获取商品结算列表和整理消费券数据
			getLists() {
				uni.showLoading()
				let data = {
					'order_type': this.type, //0通过商品提交，1通过购物车
					'order_address_id': this.address.address_id,
					'orderOrderProducts': this.orders
				}
				this.$api.postOrdersSettle(data).then(res => {
					uni.hideLoading()
					if (res.data.success) {
						for (let item of res.data.info.orderOrderProducts) {
							item.order_product_image_url = item.order_product_image_url.split(';')
						}
						this.all_money = res.data.info.order_amount_money;
						this.fin_money = res.data.info.order_amount_pay_money;
						this.lists = res.data.info;
					} else {
						if(res.data.errors&&res.data.errors.orderOrderProducts){
							this.$utils.Toast(res.data.errors.orderOrderProducts[0].errors[0])
							setTimeout(() => {
								uni.switchTab({
									url:'/pages/home/index'
								})
							}, 1000)
						}else{
							this.$utils.Toast(res.data.message)
						}
					}
				})
			},
			// 创建订单
			submit() {
				let data = {
					'order_type': this.type, //0通过商品提交，1通过购物车
					'order_address_id': this.address.address_id,
					'orderOrderProducts': this.orders
				}
				if (this.is_check) {
					data['order_voucher_number'] = this.lists.order_voucher_number;
				}
				this.$api.reqOrders(data,'post').then(res => {
					if (res.data.success) {
						setTimeout(() => {
							uni.navigateTo({
								url: '/orders/pay/Pay?id=' + res.data.info.order_id
							})
						}, 1000)
					} else {
						this.$utils.Toast(res.data.message)
					}
				})
			}
		},
		components: {
			uniIcons,
			uniPopup
		}
	}
</script>

<style lang="scss" scoped>
	page {
		background: #F7F8FA;
	}
	/deep/ uni-checkbox .uni-checkbox-input,/deep/ uni-checkbox:not([disabled]) .uni-checkbox-input:hover{
		transform: scale(0.8);
		border-radius: 50%;
		border:1px solid #000;
	}

	.createBox {
		padding-bottom: 110rpx;
	}

	.address-section {
		padding: 10px 0;
		background: #fff;
		position: relative;
		margin: 5px 0 10px;

		.default {
			margin-left: 20rpx;
			padding:0 20rpx;
			height:38rpx;
			line-height: 42rpx;
			display: inline-block;
			color: #fff;
			border-radius: 10rpx;
			font-size: 28rpx;
		}

		.order-content {
			display: flex;
			align-items: center;
		}

		.icon-shouhuodizhi {
			width: 45px;
			color: #E0BF6A;
		}

		.cen {
			display: flex;
			flex-direction: column;
			flex: 1;
			font-size: 15px;
			color: #777;
		}

		.name {
			font-size: 16px;
			margin-right: 10px;
		}

		.address {
			margin-top: 8px;
			margin-right: 10px;
			font-size: 28rpx;
		}

		.icon-you {
			margin-right: 30upx;
		}

		.a-bg {
			position: absolute;
			left: 0;
			bottom: 0;
			display: block;
			width: 100%;
			height: 5upx;
		}
	}

	.goods-section {
		margin-top: 8px;
		background: #fff;



		.g-header {
			display: flex;
			align-items: center;
			height: 42px;
			padding: 0 15px;
			position: relative;
		}

		.logo {
			display: block;
			width: 25px;
			height: 25px;
			border-radius: 50%;
		}

		.name {
			font-size: 14px;
			margin-left: 12px;
			font-weight: bold;

		}

		.g-item {
			display: flex;
			border-bottom: 3rpx solid #efefef;
			padding: 30rpx;


			image {
				flex-shrink: 0;
				display: block;
				width: 70px;
				height: 70px;
				border-radius: 2px;
			}

			.right {
				flex: 1;
				padding-left: 12px;
				overflow: hidden;
			}

			.title {
				font-size: 30rpx;
				font-weight: bold;
			}

			.spec {
				font-size: 30rpx;
				color: #555;
				margin-top: 10rpx;

				text {
					margin-right: 20rpx;
				}
			}

			.price-box {
				display: flex;
				align-items: center;
				padding-top: 5px;
				color: #F0AD4E;

				.price {
					margin-bottom: 2px;
				}

				.number {
					font-size: 34rpx;
					margin-left: 10px;
					color: #666;
					text-align: right;
					display: inline-block;
				}
			}
			.step-box {
				position: relative;
			}
		}
	}

	.money {
		margin-top: 20rpx;

		/*padding: 20rpx;*/
		.item {
			background: #FFFFFF;
			display: flex;
			justify-content: space-between;
			font-size:26rpx;
			margin-bottom: 20rpx;
			padding: 20rpx 20rpx;

			text:last-child {
				color: red;
				font-size: 32rpx;

				i {
					padding-left: 0.2rem;
					color: #AAAAAA;
				}
			}
		}
	}

	.memo {
		margin-top: 20rpx;

		input {
			background: #fff;
			padding: 15rpx;
		}
	}

	.footer {
		position: fixed;
		left: 0;
		bottom: 0;
		z-index: 995;
		display: flex;
		align-items: center;
		width: 100%;
		height: 100rpx;
		line-height: 100rpx;
		justify-content: space-between;
		font-size: 15px;
		background-color: #fff;
		z-index: 998;
		box-shadow: 0 -1px 5px rgba(0, 0, 0, .1);

		.price-content {
			padding-left: 15px;
			color: red;
		}

		.price-tip {
			margin-left: 4px;
		}

		.price {
			font-size: 18px;

		}

		.submit {
			width: 140px;
			height: 100rpx;
			line-height: 100rpx;
			color: #fff;
			font-size: 16px;
			text-align: center;
		}
	}
	// 备注
	.remark-box {
		margin-bottom: 20rpx;
		background: #fff;
		padding: 25rpx;
		font-size: 28rpx;
		.remark-notice {
			font-size: 24rpx;
			color: #c4c4c4;
			padding: 0 20rpx;
		}
		.remark-inp {
			font-size: 26rpx;
			padding: 20rpx;
			height: 200rpx;
			background: #f5f5f5;
			border-radius: 20rpx;
			margin: 25rpx auto 0;
			width: 94%;
		}
	}
</style>
