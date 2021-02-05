<template>
	<view class="box">
		<view class="contents u-f">
			<scroll-view class="group-left u-f u-f-fdc">
				<text v-for="(item, index) in groups" :key="index" :class="{'active':index===groupIndex}" @click="changeGroupIndex(index, item.product_group_id)">{{item.product_group_name}}</text>
			</scroll-view>
			<scroll-view class="item-box" scroll-y="true" v-if="products.length > 0">
				<view class="item" v-for="(item, index) in products" :key="index">
					<view class="u-f u-f-jdc top">
						<image :src="item.groupRulesProduct.product_image|getProductImg" mode="aspectFill" class="left"></image>
						<view class="right u-f">
						 <text class="font-one">{{item.groupRulesProduct.product_name}}</text>
						 <view class="price">
							 <text class="font-text new-price">￥{{item.group_rules_product_price[0].product_sku_price|Fixed}}</text>
							 <text class="old-price">￥{{item.group_rules_product_price[0].product_sku_market|Fixed}}</text>
						 </view>
						 <view class="time u-f u-f-ac"><span class="text">仅剩</span> 
						 <uni-countdown class="count-down" :show-day="item.day>0" :show-colon="true" splitor-color="#999999" color="#999999" background-color="#ffffff" border-color="#CFB47E" :day="item.day" :hour="item.hours" :minute="item.minutes" :second="item.seconds"></uni-countdown>
						 </view>
						 <view class="open u-f u-f-jsb u-f-ac">
							 是否开启自动拼团 <switch :checked="item.isAddAuto" @change="switchChange($event, item.group_rules_id)" color="#CFB47E" style="transform: scale(.7);"/>
						 </view>
						 <!-- <button class="pin-btn" size="mini" type="warn">我要拼</button> -->
						</view>
					</view>
					<!-- 拼团用户 -->
					<view class="avatar u-f u-f-ac u-f-jsb" v-if="userBox.length>0">
						<text></text>
						<view class="avatar-right u-f u-f-ac">
							<view class="img-box">
								<image :src="img.groupMemberMemberinfoAccount.memberinfo_avatar_image?img_url + 'avatar/' + img.groupMemberMemberinfoAccount.memberinfo_avatar_image:logo" alt="" v-for="(img, index) in userBox">
								</image>
							</view>
							<span class="count">已拼{{item.group_product_count}}件</span>
						</view>
					</view>
					<!-- 开启拼团 -->
					<view class="open u-f u-f-ac u-f-jsb">
						<span></span>
						<button class="pin-btn" size="mini" type="warn"  @click="Detail(item.groupRulesProduct.product_id)">我要拼</button>
					</view>
				</view>
			</scroll-view>
			<view class="item-box nodata u-f u-f-ac u-f-jsc" v-else>
				暂无数据
			</view>
		</view>
		<uni-popup ref="popup">
			<uniPopupDialog type="bottom" :content="content" @close="close" @confirm="confirm"></uniPopupDialog>
		</uni-popup>
	</view>
</template>

<script>
	import uniCountDown from '@/components/uni-countdown/uni-countdown.vue'
	import uniPopup from '@/components/uni-popup/uni-popup.vue'
	import uniPopupDialog from '@/components/uni-popup/uni-popup-dialog.vue'
	import moment from "moment"
	export default {
		data() {
			return {
				page: 1,
				products: [],
				userBox: [],
				img_url: this.$utils.imgUrl,
				logo: this.$utils.webImg2 + 'logo.png',
				isOpen: false,
				content: '',
				groupId: '',
				groups: [],
				groupIndex: 0
			};
		},
		onShow() {
			this.getGroups()
		},
		components: {
			uniCountDown,
			uniPopup,
			uniPopupDialog
		},
		methods: {
			async getGroups() {
				const res = await this.$api.getProductGroup()
				this.groups = res.data
				this.getProducts(res.data[0].product_group_id)
			},
			changeGroupIndex (index, id) {
				this.groupIndex = index
				this.products = []
				this.getProducts(this.groups[index].product_group_id)
			},
			close () {
				this.changeGroup()
			},
			confirm () {
				this.changeGroup()
			},
			switchChange (e, id) {
				this.groupId = id
				this.isOpen = e.target.value
				this.content = e.target.value?'您是否开启自动拼团':'您是否关闭自动拼团'
				this.$refs.popup.open()
			},
			changeGroup () {
				const data = {
					is_bind: this.isOpen ? 1 : 0 // 是否开启
				}
				this.$api.changeGroupStatus(this.groupId, data, true).then(res => {
					console.log(res)
					this.$utils.Toast(res.data.message, res.data.success? 'success':'none')
					this.$refs.popup.close()
					if (res.data.success) {
						this.getProducts(this.groups[this.groupIndex].product_group_id)
					}
				})
			},
			Detail(id) {
				console.log(id)
				uni.navigateTo({
					url: `/home/detail/Detail?id=${id}`,
					animationType: 'pop-in',
					animationDuration: 200
				});
			},
			async getProducts(id) {
				uni.showLoading()
				let data = {
					page: this.page,
					expand: 'groupRulesProduct.productMonthSale',
					'per-page': 10,
					group_rules_product_group_id: id
				}
				const res = await this.$api.getGroupLists(data)
				this.sum_total = res.header["x-pagination-total-count"] ? res.header["x-pagination-total-count"] : res.header[
					'X-Pagination-Total-Count'];
					// 获取拼团数量
				if (res && res.data) {
					for (const item of res.data) {
						if (moment(item.group_rules_end_time).format('X') - moment().format('X') > 0) {
							const timeS = moment(item.group_rules_end_time).format('X') - moment().format('X')
							item.day = Math.floor(timeS/(3600*24))
							item.hours = Math.floor(timeS/3600)
							item.minutes = Math.floor(timeS/60%60)
							item.seconds = Math.floor(timeS%60)
						}
						if (item.group_rules_type === 1) {
							await this.$api.getGroupProductCount(item.group_rules_product_id).then(res1 => {
								item.group_product_count = res1.data.count // 团购商品购买总数量
								this.userBox = res1.data.memberinfo.splice(0, 4)
							})
						}
						this.products = this.page === 1 ? res.data : this.products.concat(res.data)
					}
				}
				uni.hideLoading()
			}
		},
	};
</script>

<style lang="scss" scoped>
uni-page-body, body{
	background: #f6f6f6;
	min-height: 100%;
}
/deep/.uni-scroll-view-content{
	display: flex;
	flex-direction: column;
}
.group-left{
	width: 28%;
  min-height: 100vh;
  background: #f5f5f5;
	text{
		padding: 30rpx 0;
		font-size: 30rpx;
		border-bottom: 1px solid #FFFFFF;
		text-align: center;
	}
	.active{
		background: #CFB47E;
		color: #FFFFFF;
	}
}
.contents{
	padding-bottom: var(--window-bottom);
	.item-box{
		width: 72%;
    background: #FFFFFF;
		flex: 1;
    padding-bottom: 30rpx;
	}
  .nodata{
    margin: 0;
  }
	.item{
		padding: 30rpx 30rpx 10rpx;
		border-bottom: 20rpx solid #f5f5f5;
		.top{
			flex-direction: column;
		}
		image.left{
			display: block;
			width: 100%;
			height: 300rpx;
		}
		.right{
			flex-direction: column;
			width: 100%;
			.font-one{
				font-size: 34rpx;
				font-weight: bold;
			}
			.new-price{
				font-size: 40rpx;
				line-height: 60rpx;
			}
			.old-price{
				text-decoration: line-through;
				margin-left: 20rpx;
				line-height: 60rpx;
				font-size:32rpx;
				color: #999999;
			}
			.time{
				color: #999999;
				font-size: 30rpx;
				.text{
					margin-right: 20rpx;
				}
			}
		}
		.avatar{
			padding-bottom: 20rpx;
			.img-box{
				image{
					width: 50rpx;
					height: 50rpx;
					border-radius: 50%;
					border: 1px solid #e5e5e5;
					margin-right: 10rpx;
				}
			}
			.count{
				font-size: 32rpx;
				color: #333333;
				margin-left: 20rpx;
				padding-right: 30rpx;
			}
		}
	}
	.item:last-child{
		border: 0;
	}
}
.pin-btn{
		font-size: 30rpx;
		margin: 10rpx 0 20rpx;
		width: 180rpx;
		height: 55rpx;
		line-height: 55rpx;
		background: #CFB47E;
	}
.open{
	color: #333333;
	font-size: 32rpx;
	margin-bottom: 10rpx;
}
</style>
