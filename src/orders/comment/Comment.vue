<template>
	<view class="comment lighter-icon">
		<!-- 顶部导航 -->
		<view class="topTabBar u-f u-f-jsa" :style="{position:headerPosition,top:headerTop}">
			<view class="grid u-f u-f-jsa u-f-ac" v-for="(grid,tbIndex) in orderType" :key="tbIndex" @tap="showType(tbIndex)">
				<view class="text" :class="[tbIndex==tabbarIndex?'on':'']">{{grid}}</view>
			</view>
		</view>
		<!-- 未评价 -->
		<view class="tab1" v-if="tabbarIndex===0">
			<view class="box">
				<view class="item u-f" v-for="(item,index) in detail.orderOrderProducts" :key="index">
					<view class="img-box">
						<image :src="item.order_product_image_url  | getProductImg">
					</view>
					<view class="title u-f u-f-ac font-one">{{item.order_product_name}}</view>
					<view class="btns u-f">
						<text class="btn" v-if="detail.is_comment" @click="toDetail(detail.order_id,item.order_product_product_id)">去评价</text>
						<text class="btn" v-else>已过期</text>
					</view>
				</view>
			</view>
		</view>
		<!-- 已评价 -->
		<view class="tab2" v-if="tabbarIndex===1">
			<view class="item" v-for="(item,index) in lists1" :key="index">
				<view class="goods u-f">
					<view class="imgs" v-if="item.product">
						<image :src="item.product.product_image | getProductImg">
					</view>
					<view class="right-box">
						<view class="title" v-if="item.product">{{item.product.product_name}}</view>
						<view class="star">
							评分
							<text>
								<small v-for="(item2,index2) in item.product_comment_star" :key="index2" class="iconfont icon-start"></small>
							</text>
						</view>
					</view>
				</view>
				<view class="commentDet" v-if="item.product_comment_content">{{item.product_comment_content}}</view>
				<scroll-view class="commentImg" scroll-x="true" >
					<block v-for="(item2,index2) in $utils.getImageLists(item.product_comment_images)" :key="index2">
						<image  :src="img_url+'product-comment/'+item2">
					</block>
				</scroll-view>
			</view>
			<!-- load -->
			<shoproLoad :status="status" :content-text="contentText"></shoproLoad>
		</view>
	</view>
</template>
<script>
	import moment from 'moment'
	export default {
		data() {
			return {
				headerPosition: "fixed",
				headerTop: "0px",
				orderType: ['待评价', '已评价'],
				tabbarIndex: 0,
				detail: '', //未评价
				lists1: [], //已评价
				id: '', //订单id
				config: '', //获取后台的配置
				page: 1,
				status: 'more',
				contentText: {
					contentdown: '查看更多',
					contentrefresh: '加载中',
					contentnomore: '没有更多'
				},
				total_count: 0,
				img_url: process.env.VUE_APP_IMG_URL
			};
		},
		// 上拉加载更多
		onReachBottom() {
			if (this.lists1.length >= this.total_count) {
				return this.status = 'nodata'
			}
			this.status = 'loading'
			uni.showNavigationBarLoading()
			setTimeout(() => {
				this.status = 'more'
				this.page = this.page + 1
				this.getCommitData()
				uni.hideNavigationBarLoading()
			}, 1000)
		},
		onLoad(option) {
			this.id = option.id
			//从编辑评论跳转过来的
			if (option.index) {
				this.tabbarIndex = Number(option.index)
				this.getCommitData()
			} else {
				this.getData(option.id);
			}
			this.getConfig()
			//兼容H5下排序栏位置
			// #ifdef H5
			let Timer = setInterval(() => {
				let uniHead = document.getElementsByTagName('uni-page-head');
				if (uniHead.length > 0) {
					this.headerTop = uniHead[0].offsetHeight + 'px';
					clearInterval(Timer); //清除定时器
				}
			}, 1);
			// #endif
		},
		mounted() {},
		onPageScroll(e) {
			return;
			//兼容iOS端下拉时顶部漂移
			this.headerPosition = e.scrollTop >= 0 ? "fixed" : "absolute";
		},
		methods: {
			async getConfig(){
				const res = await this.$api.getConfig()
				console.log(res)
				this.config = res.data
			},
			showType(tbIndex) {
				this.tabbarIndex = tbIndex;
				this.detail = {}
				this.lists1 = []
				if (tbIndex === 0) {
					this.getData(this.id)
				} else {
					this.getCommitData();
				}
			},
			// 去评价
			toDetail(id, pid) {
				uni.navigateTo({
					url: `/orders/editComment/EditComment?id=${id}&pid=${pid}`
				})
			},
			formatTime(time) {
				// 订单时间截取
				let str = time.split('-')
				let str2 = str[2].split(' ')
				// 订单的时间
				let year = str[0]
				let month = str[1].length < 2 ? '0' + str[1] : str[1]
				let day = str2[0].length < 2 ? '0' + str2[0] : str2[0]
				let comment_day = moment([Number(year), Number(month), Number(day)]).add(this.config.shop_comment_deadline, 'day').date() //订单更新时间加上评价的时间
				console.log(comment_day)
				// 现在的时间
				let now_month = moment().month() < 10 ? '0' + (moment().month() + 1) : moment().month() + 1
				let now_day = moment().date() < 10 ? '0' + moment().date() : moment().date()
				let now = moment().year() + '-' + now_month + '-' + now_day
				return moment(now).isBefore(`${year}-${month}-${comment_day}`)
			},
			async getData(id) {
				let data = {
					'expand': 'orderOrderProducts'
				}
				const res = await this.$api.reqOrders(data,'get',id);
				console.log(this.formatTime(res.data.order_update_datetime))
				if (this.formatTime(res.data.order_update_datetime)) {
					res.data.is_comment = true
				}
				if(res.data.order_status!==11){
					this.detail = res.data
				}
			},
			//获取已评价数据
			async getCommitData() {
				let data = {
					'page': this.page,
					"per-page": 3,
					'expand': "product"
				};
				const res = await this.$api.getComments(data);
				this.total_count = Number(res.header['x-pagination-total-count'])
				let images = []
				for (let i in res.data) {
					this.lists1.push(res.data[i])
				}
			},
		}
	}
</script>

<style lang="scss">
	@import '@/common/css/mixin';

	.comment {
		padding-top: 100rpx;
	}

	// 头部的tabbar
	.topTabBar {
		width: 100%;
		position: fixed;
		z-index: 10;
		background-color: #fff;
		padding: 20rpx 0 15rpx;
		border-top: 1px solid #F2F3F3;
		border-bottom: 1px solid #F2F3F3;
		font-size: 30rpx;

		.grid {
			color: #444;

			.text {
				display: flex;
				align-items: center;

				&.on {
					color: #000;
					border-bottom: solid 2px #000;
					font-weight: bold;
					padding-bottom: 10rpx;
				}
			}
		}
	}

	.tab1 {
		.box {
			.item {
				padding: 0 30rpx 20rpx;
				border-bottom: 1px solid #EEEEEE;
				margin-top: 30rpx;
				position: relative;

				.img-box {
					image {
						width: 200rpx;
						height: 200rpx;
					}
				}

				.title {
					font-size: 16px;
					flex: 1;
					margin-left: 30rpx;
				}

				.btns {
					position: absolute;
					bottom: 30rpx;
					right: 30rpx;
					font-size: 32rpx;

					.btn {
						color: $themeColor;
						border: 1px solid $themeColor;
						padding: 2px 10px;
						border-radius: 50px;
					}
				}

			}
		}
	}

	.tab2 {
		.item {
			border-bottom: 1px solid #eeeeee;
			padding: 0 30rpx;
			margin-top: 40rpx;

			.goods {
				.imgs {
					image {
						width: 140rpx;
						height: 140rpx;
						border: 1px solid #F5F5F5;
						padding: 4rpx;
						margin-right: 30rpx;
					}
				}

				.right-box {
					flex: 1;
					font-size: 32rpx;
					color: #555;

					.title {
						margin: 10rpx 0 30rpx;
						color: #000000;
					}

					.star {
						font-size: 30rpx;
					}

					.icon-start {
						color: #ffba00;
						font-size: 27rpx;
						margin-left: 6rpx;
					}
				}
			}

			.commentDet {
				margin: 10rpx 0 30rpx;
				color: #555;
				font-size: 32rpx;
			}

			.commentImg {
				white-space: nowrap;
				width: 100%;

				image {
					width: 140rpx;
					height: 140rpx;
					margin-right: 20rpx;
					margin-bottom: 20rpx;
				}

				image:last-child {
					margin-right: 0;
				}
			}
		}
	}
</style>
