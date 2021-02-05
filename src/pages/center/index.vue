<template>
	<view class="box">
		<view class="header" :class="[token?'':'header-padd']">
			<view class="infor">
				<view class="user u-f u-f-ac">
					<image :src="avatar" @tap="Go('/center/info/Info')"></image>
					<view v-if="token" class="u-f u-f-ac u-f-jsb top-avatar">
						<view class="left">
							<view class="name">{{user.memberinfo_nickname}}</view>
							<view class="id">
								<text>ID：{{user.memberinfo_account}}</text>
								<text v-if="user.memberinfo_recommend_account">推荐人ID：{{user.memberinfo_recommend_account}}</text>
							</view>
						</view>
						<text class="right iconfont icon-shezhi" @click="Go('/center/set/Set')"></text>
					</view>
					<template v-else>
						<view class="grade grade-login" v-if="is_login" @tap="Login">
							<text class="words">去登录</text>
						</view>
						<view class="grade grade-login grade-gray"  v-else>
							<text class="words">去登录</text>
						</view>
					</template>
				</view>
			</view>
		</view>
		<!-- 资金 -->
		<view class="assets u-f u-f-ac u-f-jsa" v-if="token" :style="{backgroundImage:bg}">
			<block v-for="(item,index) in finances" :key="index">
				<view class="item"  @tap="goFinance(item.finance_type)">
					<text class="words" v-if="item.financeType">{{item.financeType.finance_type_name}}</text>
					<text class="number lighter-icon" v-if="item.finance_award">{{item.finance_award|Money}}</text>
				</view>
			</block>
		</view>
		<view class="tabs u-f u-f-jsa u-f-ac">
			<view class="item" v-for="(item, index) in lists" :key="index" @tap="Go(item.url)">
				<text class="iconfont" :class="item.icon"></text>
				<text class="text">{{item.text}}</text>
			</view>
		</view>
		<view class="bodyer">
		<!-- 	<view class="home-infos u-f u-f-jsc">
				<image :src="imgUrl+'mobile/home_info.png'" mode="widthFix"></image>
			</view> -->
			<!-- 订单列表 -->
			<view class="order">
				<view class="title u-f u-f-ac">
					<text class="text">我的订单</text>
					<text class="whole" @tap="Go('/orders/orders/Orders?tbIndex=0')">查看全部 <text class="iconfont icon-arrow-right"></text></text>
				</view>
				<view class="wait u-f u-f-jsa">
					<block v-for="(item,index) in orders" :key="index">
						<view class="wrap" @tap="Go(item.url)">
							<text class="iconfont font-text" :class="item.icon"></text>
							<text class="text">{{item.text}}</text>
							<uni-badge :text="item.badge" v-if="item.badge>0"></uni-badge>
						</view>
					</block>
				</view>
			</view>
			<!-- 菜单列表 -->
			<view class="order service">
				<view class="title">
					<text class="text">我的服务</text>
				</view>
				<view class="wait u-f u-f-jsa">
					<block v-for="(item,index) in service" :key="index">
						<view class="wrap" @tap="Go(item.url)">
							<text class="iconfont font-text" :class="item.icon"></text>
							<text class="text">{{item.text}}</text>
						</view>
					</block>
				</view>
			</view>
		</view>
    <view class="com">河南发爵商贸有限公司</view>
	</view>
</template>

<script>
	import uniBadge from '@/components/uni-badge'
	export default {
		data() {
			return {
				service: [
					{
							icon: "icon-tuandui1",
							text: "我的推广",
							url: "/center/recommend/Recommend"
						},
						{
							icon: "icon-dizhi",
							text: "地址信息",
							url: "/center/address/Address"
						},
						{
							icon: "icon-huodongtuiguang",
							text: "我要推广",
							url: "/center/code/Code"
						},
						{
							icon: "icon-pintuanjilu",
							text: "拼团记录",
							url: "/center/groupLists/groupLists"
						},
						{
								icon: "icon-tixianjilu",
								text: "提现记录",
								url: "/center/financesDetail/FinancesDetail?type=withdraw"
							},
							{
								icon: "icon-recharge-log",
								text: "充值记录",
								url: "/center/transferList/TransferList?type=3"
							},
							{
								icon: "icon-zhanghuhuzhuan",
								text: "互转记录",
								url: "/center/transferList/TransferList"
							},
							{
								icon: "icon-huzhuan",
								text: "兑换记录",
								url: "/center/transferList/TransferList?type=2"
							},
				],
				user: uni.getStorageSync('userInfo'),
				level: '',
				code_text: '',
				finances: [],
				imgUrl: this.$utils.imgUrl,
				mobile_url: this.$utils.webImg2,
				avatar: '',
				orders: [{
						icon: "icon-daifukuan",
						text: "待付款",
						url: "/orders/orders/Orders?tbIndex=1",
						badge: 0,
					},
					{
						icon: "icon-daifahuo",
						text: "待发货",
						url: "/orders/orders/Orders?tbIndex=2",
						badge: 0,
					},
					{
						icon: "icon-daishouhuo",
						text: "待收货",
						url: "/orders/orders/Orders?tbIndex=3",
						badge: 0,
					},
					{
						icon: "icon-tuikuanshouhou",
						text: "退货",
						url: "/orders/afterSale/AfterSale",
						badge: 0
					},
				],
				token: uni.getStorageSync('token'),
				bg: `url(${this.$utils.webImg2}bg_homepic.png)`,
				is_login:true, //用来防止多次点击
				lists: [
					{
						text: '提现',
						url: '/center/withdraw/Withdraw',
						icon: 'icon-tixian'
					},
					{
						text: '充值',
						url: '/center/recharge/Recharge',
						icon: 'icon-3'
					},
					{
						text: '互转',
						url: '/center/transfer/Transfer',
						icon: 'icon-zhuanhuan1'
					},
					{
						text: '兑换',
						url: '/center/exchange/Exchange',
						icon: 'icon-zhuanhuan'
					}
				]
			};
		},
		components: {
			uniBadge
		},
		watch: {
			user(newVal) {
				let level = newVal.memberinfo_memberlevel_level
				this.level = !level && level < 1 ? '游客' : 'VIP'
			}
		},
		filters: {
			Money (num) {
				let c = (num.toString().indexOf ('.') !== -1) ? num.toLocaleString() : num.toString().replace(/(\d)(?=(?:\d{3})+$)/g, '$1,');
				return num.toString().indexOf ('.') !== -1 ? `${c.split('.')[0]}.${c.split('.')[1].slice(0,2)}` : c
			}
		},
		onShow() {
			this.token = uni.getStorageSync('token')
			this.is_login = true
			for (let item of this.orders) {
				item.badge = 0
			}
			if (this.token) {
				this.code_text = uni.getStorageSync('userInfo').memberinfo_account
				this.getFinances()
				this.getOrders()
				this.getMemberLevel()
				this.getRefunds(4)
				// #ifdef MP-WEIXIN
				uni.showShareMenu()
				// #endif
			} else {
				this.avatar = this.$utils.webImg2 + 'logo.png'
				// #ifdef MP-WEIXIN
				uni.hideShareMenu()
				// #endif
			}
		},
		// 点击右上角的转发
		onShareAppMessage(options) {
			let that = this;
			let shareObj = {
				title: '爱拼',
				path: '/pages/home/index?scene=' + that.code_text
			}
			return shareObj
		},
		methods: {
			async getMemberLevel() {
				const res = await this.$api.getMemberView()
				this.user = res.data
				// #ifdef MP-WEIXIN
				if (res.data.memberinfo_avatar_image.indexOf('https') !== -1) {
					this.avatar = res.data.memberinfo_avatar_image
				} else {
					this.avatar = this.imgUrl + 'avatar/' + res.data.memberinfo_avatar_image
				}
				// #endif
				// #ifdef APP-PLUS || H5
				if (res.data.memberinfo_avatar_image) {
					this.avatar = this.imgUrl + 'avatar/' + res.data.memberinfo_avatar_image
				} else {
					this.avatar = `${this.mobile_url}logo.png`
				}
				// #endif
			},
			async getRefunds(status) {
				let data = {
					"page": 1,
					"order_status": status,
					'per-page': 10000
				}
				const res = await this.$api.reqOrders(data,'get')
				let item = res.data
				let lists = []
				for (let i in item) {
					let item2 = item[i].orderOrderProducts
					for (let j in item2) {
						if (item2[j].order_product_refund_status === 0) {
							//计算退货和售后的时间期限
							lists = lists.concat(item2[j])
						}
					}
				}
				this.orders[3].badge = lists.length
			},
			async getFinances() {
				uni.showLoading()
				const res = await this.$api.getFinances()
				let finances = uni.setStorageSync("finances", res.data);
				uni.hideLoading()
				this.finances = res.data
			},
			async getOrders() {
				let data = {
					'per-page': 10000
				}
				const res = await this.$api.reqOrders(data)
				for (let item of res.data) {
					if (item.order_status === 0) {
						this.orders[0].badge++
					} else if (item.order_status === 2) {
						this.orders[1].badge++
					} else if (item.order_status === 3) {
						this.orders[2].badge++
					}
				}
			},
			Go(url) {
        if (url === '/center/code/Code') {
          if (this.user.membermap.membermap_vip_level === 0){
            return this.$utils.Toast('拼团之后才可以分享')
          }
        }
				let that = this;
				if (this.token) {
					if (!url) {
						uni.showToast({
							title: '该功能正在开发中',
							icon: 'none'
						})
					} else if (url === 'contact') {

					} else {
						uni.navigateTo({
							url: url
						})
					}
				} else {
					uni.showModal({
						title:'提示',
						content:'请先登录后才能查看',
						success(res) {
							if(res.confirm){
								that.$author.auth()
							}else{
								console.log('请先登录')
							}
						}
					})
				}
			},
			// 去登陆
			Login() {
				this.is_login = false
				this.$author.auth();
			},
			// 跳转到币种明细
			goFinance(type) {
        if (type !== 5){
          uni.navigateTo({
          	url: '../../center/financesDetail/FinancesDetail?type=' + type
          })
        }
			},
		}
	};
</script>

<style lang="scss" scoped>
	.box{
		padding-bottom: 60rpx;
		background: #f5f5f5;
	}

	.header-padd {
		padding-bottom: 30rpx;
	}

	.header {
		color: #fff;
		font-size: 30rpx;
		background-color: #272727;
    background: url(../../static/index/bg-header.png);
		.infor {
			display: flex;
			align-items: center;
			justify-content: space-between;
			padding: 50rpx 0 120rpx;
			margin-bottom: 45rpx;
			.user {
				display: flex;
				width: 100%;
				padding: 0 40rpx;
				image {
					width: 140rpx;
					height: 140rpx;
					border-radius: 50%;
					margin-right: 20rpx;
				}
				.top-avatar{
					flex: 1;
					.name {
						font-weight: bold;
						font-size: 34rpx;
					}
					.id{
						margin-top: 10rpx;
						color: #eeeeee;
						text:first-child{
							margin-right: 20rpx;
						}
					}
					.icon-shezhi{
						font-size: 46rpx;
					}
				}
				.grade {
					color: #e6be6e;
					background-color: #FFFFFF;
					border-radius: 50rpx;
					padding: 5rpx 15rpx;
					margin-top: 10rpx;
					display: inline-block;

					.iconfont {
						margin-right: 8rpx;
						font-size: 34rpx;
					}
				}
				.grade-login {
					padding: 10rpx 35rpx;
				}
				.grade-gray{
					background: #AAAAAA;
					color: #000000;
				}
			}
		}
	}

.assets {
	text-align: center;
	padding: 20rpx 30rpx 30rpx;
	margin-top: -70rpx;
	background: #FFFFFF;
	border-radius: 10rpx;
	margin: -110rpx 20rpx 0;
	flex-wrap: wrap;
	justify-content: flex-start;

	.item {
		display: flex;
		flex-direction: column;
		border-right: 1px solid #eeeeee;
		// flex: 1;
		width: 32%;

		.number {
			font-weight: bold;
			margin: 0 40rpx;
			font-size: 34rpx;
			color: #000000;
		}

		.words {
			color: #A1A1A1;
			font-size: 28rpx;
			margin: 2px 0 10rpx;
		}
	}
	.item:first-child, .item:nth-child(2) {
		width: 49%;
	}

	.item:last-child, .item:nth-child(2) {
		border: none
	}
	.item:nth-child(4), .item:nth-child(5), .item:nth-child(3) {
		margin-top: 50rpx;
	}
}
.tabs{
	background: #FFFFFF;
	margin: 20rpx;
	padding: 30rpx;
	border-radius: 10rpx;
	.item{
		color: #FFFFFF;
		padding: 20rpx 0;
		text-align: center;
		flex: 1;
		margin-right: 30rpx;
		border-radius: 10rpx;
		font-size: 26rpx;
		.iconfont{
			margin-right: 10rpx;
		}
	}
	.item:first-child{
		background: linear-gradient(to right, #FD7451, #F5382E);
	}
	.item:nth-child(2) {
		background: linear-gradient(to right, #FEA053, #EF8C44);
	}
	.item:nth-child(3) {
		background: linear-gradient(to right, #4BA0FE, #867FF2);
	}
	.item:nth-child(4) {
		background: linear-gradient(to right, #D683F7, #C636FF);
	}
	.item:last-child{
		margin-right: 0;
	}
}
.com{
  margin: 40rpx auto;
  padding-bottom: 40rpx;
  font-size: 30rpx;
  color: #999999;
  text-align: center;
}
	.bodyer {
		font-size: 30rpx;
		// margin-bottom: 100rpx;
		.title {
			display: flex;
			justify-content: space-between;
			border-bottom: 1px dashed #eeeeee;
			padding-bottom: 20rpx;
			.text {
				font-size: 34rpx;
				color: #333333;
			}
			.whole {
				color: #999999;
				font-size: 26rpx;

				.iconfont {
					font-size: 26rpx;
				}
			}
		}
		.home-infos {
			margin-bottom: 0;
		}

.order {
	background: #FFFFFF;
	margin: 20rpx;
	border-radius: 10rpx;
	padding: 20rpx 30rpx;
	.wait {
		margin: 30rpx 0 20rpx;
		.wrap {
			display: flex;
			flex-direction: column;
			align-items: center;
			position: relative;
			.text {
				font-size: 26rpx;
				color: #000000;
			}
			.iconfont {
				font-size: 60rpx;
				color: #ead5b0;
			}
		}
	}
}
.service{
	margin: 20rpx 20rpx 0;
	.wait{
		flex-wrap: wrap;
		.wrap{
			width: 25%;
			margin-bottom: 20rpx;
			.text{
				margin-top: 10rpx;
			}
		}
		.wrap:nth-child(1), .wrap:nth-child(2), .wrap:nth-child(3), .wrap:nth-child(4) {
			margin-bottom: 40rpx;
		}
	}
}
}
</style>
