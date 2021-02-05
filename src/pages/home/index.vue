<template>
	<view class="content">
		<view class="header">
			<!-- <view class="scroll">
				<screenTextScroll :list="list"></screenTextScroll>
			</view> -->
			<HeaderSearch></HeaderSearch>
			<Swiper></Swiper>
		</view>
		<view class="bodyer">
			<swiper circular="true" autoplay="true" :vertical="true" class="announce-box">
				<swiper-item v-for="(swiper,index) in announces" :key="index" @tap="Go(index+1)">
					<view class="u-f u-f-ac">
						<text class="u-f u-f-ac"><text class="iconfont icon-gonggao"></text>公告</text>
						<text class="announce">{{swiper.announcement_title}}</text>
					</view>
				</swiper-item>
			</swiper>
			<!-- 导航列表 -->
			<view class="classification">
				<block v-for="(item,index) in classes" :key="index">
					<view class="sort" @tap="goDetail(item)">
						<image :src="img_url+'tab'+(index+1)+'.png'" mode="widthFix"></image>
						<text class="class-name">{{item.product_class_name}}</text>
					</view>
				</block>
			</view>
			<view class="product">
				<view class="home-infos u-f u-f-jsc">拼团专区</view>
				<view class="tabs">
					<text v-for="(item, index) in tabs" :key="index" :class="{'font-text active':index === tabIndex}" @click="changeTab(index, 'tab1')">
						{{item.product_class_name}}
					</text>
				</view>
				<view class="tabs2">
					<text v-for="(item, index) in secondLists" :key="index" :class="{'font-text active':index === secondIndex}" @click="changeTab(index, 'tab2')">
						{{item.product_class_name}}
					</text>
				</view>
				<ShopTogether :goodsList="products" v-if="products.length > 0"></ShopTogether>
				<text class="nodata" v-else>{{loading_text}}</text>
			</view>
		</view>
		<!-- 授权优惠券 -->
		<uni-popup ref="popup" type="center" :maskClick="false">
			<view class="coupon-bg u-f u-f-jsc">
				<image :src="coupon" mode="widthFix"></image>
				<view class="btns u-f u-f-jsb">
					<button open-type="share">分享好友</button>
					<button @tap="Close">立即使用</button>
				</view>
				<text class="iconfont icon-guanbi" @tap="Close"></text>
			</view>
		</uni-popup>
	</view>
</template>

<script>
	import HeaderSearch from '@/components/HeaderSearch.vue';
	import ShopTogether from '@/components/ShopTogether.vue';
	import Swiper from '@/components/Swiper.vue';
	import uniPopup from '@/components/uni-popup/uni-popup.vue';
	import screenTextScroll from '@/components/screenTextScroll/screenTextScroll.vue';
	import moment from 'moment'
	export default {
		components: {
			HeaderSearch,
			ShopTogether,
			Swiper,
			uniPopup,
			screenTextScroll
		},
		data() {
			return {
				classes: [
					{
						product_class_id: 1,
						product_class_name: '商学院',
						url: '../../home/notice/Notice'
					},
					{
						product_class_id: 2,
						product_class_name: '积分兑换',
						url: '../../category/productList/ProductList'
					},
					{
						product_class_id: 3,
						product_class_name: '我要分享',
						url: '../../center/code/Code'
					},
					{
						product_class_id: 4,
						product_class_name: '我要签到',
            url: '../../home/calendar/Calendar'
					}
				],
				img_url:this.$utils.webImg2,
				products: [],
				page: 1,
				sum_total: 0,
				token: uni.getStorageSync('token'),
				loading_text: '没有数据哦',
				bg: {
					backgroundImage: 'url(' + this.$utils.webImg2 + 'coupon.png)'
				},
				coupon: this.$utils.webImg2 + 'coupon.png',
				tabs: [],
				tabIndex: 0,
				announces: [],
				secondLists: [],
				secondIndex: 0,
        userInfo: ''
			};
		},
		onLoad(option) {
			if (option.scene) {
				uni.setStorageSync('scene', option.scene)
			}
			this.getNotice()
		},
		onShow() {
			this.token = uni.getStorageSync('token')
			// 是否授权,第一次登录进入小程序显示消费券
			let coupon = uni.getStorageSync('coupon');
			if (coupon) {
				this.$refs.popup.open()
				uni.removeStorageSync('coupon')
			}
			if (this.token) {
				this.getUserInfo()
				// #ifdef MP-WEIXIN
				uni.showShareMenu()
				// #endif
			} else {
				// #ifdef MP-WEIXIN
				uni.hideShareMenu()
				// #endif
			}
		},
		onReachBottom() {
			if (this.products.length < Number(this.sum_total)) {
				this.loading_text = '加载中...'
				this.page++
				this.getProducts(this.secondLists[this.secondIndex].product_class_id)
			} else {
				this.loading_text = Number(this.sum_total )=== 0 ? '没有数据哦' : '已经加载完毕'
			}
		},
		// 点击右上角的转发
		onShareAppMessage(options) {
			let that = this;
			let code_text = uni.getStorageSync('userInfo').memberinfo_account
			let shareObj = {
				title: '爱拼',
				path: '/pages/home/index?scene=' + code_text
			}
			return shareObj
		},
		methods: {
			swiperChange () {
				
			},
      goDetail (item) {
        if (item.product_class_id === 3) {
          if (this.userInfo.membermap.membermap_vip_level === 0){
            return this.$utils.Toast('拼团之后才可以分享')
          }
        }
        if (item.product_class_id === 1 || item.product_class_id ===2){
          uni.navigateTo({
          	url: item.url
          })
        } else {
          	if (!this.token) {
          		return this.$author.auth()
          	} else {
              uni.navigateTo({
              	url: item.url
              })
            }
        }
      },
			async getNotice() {
				const res = await this.$api.getAccount()
				this.announces = res.data
			},
			changeTab (index, tab) {
				if (tab === 'tab1') {
					this.tabIndex = index
					this.getCategory(this.tabs[index].product_class_id)
				} else {
					this.secondIndex = index
					this.getProducts(this.secondLists[this.secondIndex].product_class_id)
				}
			},
			Close() {
				this.$refs.popup.close()
			},
			async getCategory(id) {
				const data = {
					'per-page': 50,
					product_class_parent_id: id
				}
				const res = await this.$api.getCategory(data)
				this.secondLists = res.data
				this.getProducts(res.data[this.secondIndex].product_class_id)
			},
			// 获取个人信息
			async getUserInfo(){
				const res = await this.$api.getMemberView()
				uni.setStorageSync('userInfo',res.data)
        this.userInfo = res.data
				// 获取分类
				const data = {
					'per-page': 50
				}
				this.tabs = []
				const res2 = await this.$api.getCategory(data)
				for (const item of res2.data) {
					if (!item.product_class_parent_id) {
						this.tabs.push(item)
					}
				}
				// 获取有父分类的分组
				this.getCategory(this.tabs[0].product_class_id)
			},
			goTo(index) {
				uni.navigateTo({
					url: '/category/productList/ProductList?id=' + index
				})
			},
			async Go(url) {
        uni.navigateTo({
        	url: url
        })
			},

			async getProducts(id) {
				uni.showLoading()
				let data = {
					page: this.page,
					group_rules_product_class_id: id
				}
				const res = await this.$api.getGroupLists(data)
				this.sum_total = res.header["x-pagination-total-count"] ? res.header["x-pagination-total-count"] : res.header[
					'X-Pagination-Total-Count'];
					// 获取拼团数量
				if (res && res.data) {
					for (const item of res.data) {
						if (item.group_rules_type === 1) {
							await this.$api.getGroupProductCount(item.group_rules_product_id).then(res1 => {
								item.group_product_count = res1.data.count // 团购商品购买总数量
							})
							this.products = this.page === 1 ? res.data : this.products.concat(res.data)
						}
					}
				}
				if (res.data.length === 0) {
					this.products = res.data
				}
				console.log(this.products)
				uni.hideLoading()
			}
		},
	};
</script>

<style lang="scss" scoped>
	.nodata{
		font-weight: normal;
	}
	.content {
		font-size: 30rpx;
		background-color: #f6f6f6;
		padding-bottom: 110rpx;
	}

	.header {
		height: 100%;
		background: url('~@/static/index/bg-header.png') no-repeat top;
		background-size: 100% 75%;
		padding: 4%;
	}

	.bodyer {
		padding: 10rpx 0 10rpx;
		.announce-box{
			margin: 30rpx;
			background: #FFFFFF;
			height: 40rpx;
			line-height: 40rpx;
			border-radius: 10rpx;
			padding: 20rpx;
			font-weight: bold;
			.iconfont{
				margin-right: 10rpx;
			}
			.announce{
				border-left: 1px solid #666666;
				padding-left: 16rpx;
				margin-left: 16rpx;
				line-height: 36rpx;
				font-weight: normal;
			}
		}

		.classification {
			display: flex;
			padding: 30rpx 0;
			margin: 0 30rpx;

			.sort {
				display: flex;
				flex-direction: column;
				align-items: center;
				font-size: 30rpx;
				flex: 1;

				image {
					width: 74rpx;
					height: 74rpx;
					margin-bottom: 18rpx;
				}

				.class-name {
					font-size: 24rpx;
					color: #363636;
				}
			}
		}

		.ad {
			border-radius: 15rpx;
			height: 300rpx;
			width: 92%;
			margin: 0 auto;
		}

		.product-class {
			margin: 26rpx 30rpx 0;
			height: auto;
			display: flex;
			align-items: center;
			justify-content: space-between;

			.product-class-item {
				width: 48%;

				image {
					width: 100%;
				}
			}

		}

		.product {
			margin: 16rpx 0 40rpx;
			.tabs, .tabs2{
				margin: 40rpx 30rpx 50rpx;
				.active{
					background: #211A1D;
					border-radius: 30rpx;
					padding: 5rpx 20rpx;
				}
				text:last-child{
					margin-left: 50rpx;
				}
				text{
					padding:0;
					display: inline-block;
				}
			}
			.tabs2{
				overflow-x: auto;
				white-space: nowrap;
				text{
					margin-left: 0!important;
					color: #999999;
					width: 25%;
					text-align: center;
				}
				.active{
					background: #dddddd;
					color: #CFB47E;
				}
			}
			.title {
				text-align: center;
				background: #ffffff;
				padding: 20rpx 0;
				margin-bottom: 30rpx;
				font-weight: bold;
				color: #333333;
			}

			.shop-detail {
				margin: 0 30rpx;
			}
		}


		.list {
			flex-wrap: wrap;
		}
	}
	.home-infos{
		font-weight: bold;
		background: transparent;
	}
	.home-infos::before{
		content: '---';
		margin-right: 10rpx;
	}
	.home-infos::after{
		content: '---';
		margin-left: 10rpx;
	}
</style>
