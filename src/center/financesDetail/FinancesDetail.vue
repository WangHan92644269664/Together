<template xlang="wxml">
	<view class="financesBox">
		<view class="contents" v-if="contents.length > 0">
			<view class="item" v-for="(item, index) in contents" :key="index" @tap="Change(index)">
				<view class=" u-f u-f-jsb u-f-ac">
					<view class="first u-f">
						<!-- 余额明细 -->
						<text>{{ type==='withdraw'?item.withdrawals_sn:item.finance_log_info }}</text>
            <text v-if="type==='withdraw'" class="time with-type">到账方式: {{item.withdrawals_type===1?'银行卡':item.withdrawals_type===2?'支付宝':'微信'}}</text>
						<text v-if="type==='1'||type==='3'||type==='4'" class="time">{{ item.finance_log_add_datetime }}</text>
						<!-- 我的战队 -->
						<image :src="item.data.avatar|getImg" mode="widthFix" v-else-if="type==='team'"></image>
						<!-- 团队佣金 -->
						<image :src="item.awardPeriodSumOrder.orderAccount.memberinfo_avatar_image|getImg" mode="widthFix" v-else-if="type==='team_per'||type==='awards'"></image>
						<!-- 分销佣金 -->
						<template v-else-if="type==='dis_money'">
							<image :src="item.awardPeriodSumOrder.orderAccount.memberinfo_avatar_image|getImg" mode="widthFix" v-if="item.awardPeriodSumOrder"></image>
							<image :src="img_url" mode="widthFix" v-else></image>
						</template>
						<!-- 分销订单 -->
						<image :src="item.orderAccount.memberinfo_avatar_image|getImg" mode="widthFix" v-else-if="type==='dis_order'"></image>
					</view>
					<view class="second u-f">
						<template v-if="type==='1'||type==='3'||type==='4'">
							<text></text>
						</template>
						<template v-else-if="type==='team'">
							<view>
								<text>{{item.data.nickname?item.data.nickname:'未授权'}}</text>
								<text>{{item.data.memberlevel?item.data.memberlevel:'未授权'}}</text>
							</view>
							<text>{{item.data.mobile?item.data.mobile:'未授权'}}</text>
						</template>
						<template v-else-if="type==='dis_money'">
							<text>{{item.awardPeriodSumAwardPeriods[0].award_period_src_account}}</text>
							<block v-for="(item2,index2) in item.awardPeriodSumAwardPeriods" :key="index2">
								<text v-if="index2===0">{{item2.awardPeriodType.award_type_name}}</text>
							</block>
						</template>
						<template v-else-if="type==='team_per'||type==='awards'">
							<text>{{item.award_period_sum_account}}</text>
						</template>
						<template v-else-if="type==='dis_order'">
							<text>{{item.order_account}}</text>
							<text>{{item.order_sn}}</text>
						</template>
						<template v-if="type==='withdraw'">
							<text></text>
						</template>
					</view>
					<view class="right u-f">
						<template v-if="type==='team'">
							<text class="right">{{item.data.add_datetime}}</text>
						</template>
						<template v-else-if="type==='team_per'||type==='awards'">
							<text class="money">{{item.award_period_sum_currency|two}}</text>
							<text class="time">{{item.award_period_sum_add_date}}</text>
						</template>
						<template v-else-if="type==='dis_money'">
							<text class="money">{{item.award_period_sum_currency|two}}</text>
							<text class="time">{{item.award_period_sum_add_date}}</text>
						</template>
						<template v-else-if="type==='dis_order'">
							<text class="money">{{item.order_amount_pay_money|two}}</text>
							<text class="time">{{item.order_add_datetime}}</text>
						</template>
						<template v-if="type==='1'||type==='3'||type==='4'">
							<text v-if="item.finance_log_new-item.finance_log_old>0" class="blue">+ {{ item.finance_log_currency|two}}</text>
							<text v-else class="red">- {{ Math.abs(item.finance_log_currency)|two}}</text>
							<text>余额: {{ item.finance_log_new|two }}</text>
						</template>
						<!-- 提现金额 -->
						<template v-if="type==='withdraw'">
							<text class="red size36">-{{ Math.abs(item.withdrawals_currency)|two }}</text>
							<text class="time">{{item.withdrawals_add_datetime}}</text>
						</template>
					</view>
					<template v-if="type==='dis_money'||type==='team_per'||type==='awards'||type==='dis_order'">
					<view class="iconfont four" :class="[index===desc_index?'icon-arrow':'icon-arrow-left']"></view>
					</template>
				</view>
				<template v-if="type==='dis_money'||type==='team_per'||type==='awards'||type==='dis_order'">
					<view class="desc u-f u-f-jsb" v-if="index===desc_index">
						<template v-if="type==='dis_order'">
							<text></text>
							<text>分享佣金: {{item.orderAwardPeriodSum.award_period_sum_currency|two}}</text>
						</template>
						<template v-else>
							<text>订单编号: {{item.awardPeriodSumOrder.order_sn}}</text>
							<text>订单金额: {{item.awardPeriodSumOrder.order_amount_pay_money|two}}</text>
						</template>
					</view>
				</template>

			</view>
			<view class="loading">{{ loadingText }}</view>
			<view class="topBox" :hidden="!flag" @tap="toTop">
				<uni-icons type="arrowup" size="29" color="#333" class="icon"></uni-icons>
			</view>
		</view>
		<view class="loading" v-else>没有数据</view>
	</view>
</template>
<script>
	import uniIcons from "@dcloudio/uni-ui/lib/uni-icons/uni-icons.vue";
	export default {
		data() {
			let that;
			return {
				titles: ["时间", "变动", "金额", "明细"],
				contents: [],
				loadingText: "加载更多",
				page: 1,
				timer: null,
				flag: false,
				type: 1,
				avatar: '',
				img_url: this.$utils.webImg2 + 'logo.png',
				desc_index: null
			};
		},
		components: {
			uniIcons
		},

		onLoad: function(options) {
			let type = options.type;
			console.log(type)
			let finances = uni.getStorageSync("finances");
			let money, name;
			for (let item of finances) {
				if (item.finance_type == type) {
					name = item.financeType.finance_type_name;
					money = Number(item.finance_award).toFixed(2);
				}
			}
			this.type = type;
			console.log(type === 'dis_order')
			if (type === 'withdraw') {
				uni.setNavigationBarTitle({
					title: "提现记录",
				});
				this.getFinancesLog()
			} else if (type === 'dis_money'||type === 'team_per' || type === 'awards') {
				uni.setNavigationBarTitle({
					title:  type === 'team_per' ? '团队佣金' :type==='dis_money'? "分享佣金":'感恩奖',
				});
				this.getAwardPeriodSums()
			} else if (type === 'dis_order') {
				uni.setNavigationBarTitle({
					title: "分享订单",
				});
				this.getOrderDistribute()
			} else if (type === 'team') {
				uni.setNavigationBarTitle({
					title: "我的战队",
				});
				this.getRecommend()
			} else {
				//type  1 余额  3消费券
				this.getFinancesLog();
				uni.setNavigationBarTitle({
					title: name + "记录(" + money + ")",
				});
			}
		},
	
		filters: {
			getFiance(type) {
				let finances = uni.getStorageSync("finances");
				let value;
				for (let item of finances) {
					if (type === item.finance_type) {
						value = item.financeType.finance_type_name;
					}
				}
				return value;
			},
			getMoney(val) {
				let value = Math.abs(val).toFixed(2);
				console.log(value)
				return value;
			},
			getAccount(val) {
				let value = val.split("\n")[0].split(":")[1];
				return value;
			},

		},
		methods: {
			// 获取分销佣金
			async getAwardPeriodSums() {
				// 1 分销佣金   2 团队   4 感恩奖
				let data = {
					award_period_sum_sum_type: this.type === 'dis_money' ? 1 : this.type === 'team_per' ? 2 : 4,
					"per-page": 10,
					page: this.page,
				}
				uni.showLoading()
				const res = await this.$api.getAwardPeriodSums(data)
				this.length = res.header["x-pagination-total-count"] ? res.header["x-pagination-total-count"] : res.header[
					'X-Pagination-Total-Count'];
					console.log(this.length)
				this.contents = this.contents.concat(res.data);
				uni.hideLoading()
				if (res.data.length < 10) {
					this.loadingText = "已经加载完毕";
					return;
				}
			},
			// 点击显示详情
			Change(index) {
				if (index === this.desc_index) {
					this.desc_index = null
				} else {
					this.desc_index = index
				}
			},
			// 获取分销订单
			async getOrderDistribute() {
				let data = {
					"per-page": 10,
					page: this.page,
				};
				uni.showLoading()
				const res = await this.$api.getOrderDistribute(data)
				this.length = res.header["x-pagination-total-count"] ? res.header["x-pagination-total-count"] : res.header[
					'X-Pagination-Total-Count'];
				this.contents = this.contents.concat(res.data);
				uni.hideLoading()
				if (res.data.length < 10) {
					this.loadingText = "已经加载完毕";
					return;
				}
			},
			// 获取战队
			async getRecommend() {
				uni.showLoading()
				const res = await this.$api.getRecommend()
				if(res.data.children){
					this.contents = this.contents.concat(res.data.children);
				}
				uni.hideLoading()
			},
			
			// 获取资金明细
			async getFinancesLog() {
				let data = {
					finance_log_type: this.type,
					sort: "-finance_log_add_datetime",
					"per-page": 10,
					page: this.page,
				};
				let res;
				uni.showLoading()
				if (this.type === 'withdraw') {
					res = await this.$api.reqWithdrawals()
				} else {
					res = await this.$api.getFinanceLog(data)
				}
				this.length = res.header["x-pagination-total-count"] ? res.header["x-pagination-total-count"] : res.header[
					'X-Pagination-Total-Count'];
				this.contents = this.contents.concat(res.data);
				uni.hideLoading()
				if (res.data.length < 10) {
					this.loadingText = "已经加载完毕";
					return;
				}
			},
			toTop() {
				uni.pageScrollTo({
					scrollTop: 0,
					duration: 200,
				});
			},
		},
		components: {},

		onReachBottom() {
			let that = this;
			if (Number(this.length) < this.contents.length) {
				return
			}
			if (Number(this.length) === this.contents.length) {
				return this.loadingText = '已经加载完毕'
			}
			this.timer = setTimeout(() => {
				if (that.timer !== null) {
					clearTimeout(that.timer);
				}
				that.page++
				if (this.type === 'dis_money') {
					that.getAwardPeriodSums()
				} else if (this.type === 'dis_order') {
					that.getOrderDistribute()
				} else if (this.type === 'team') {
					that.getRecommend()
				} else if (this.type === 'team_per' || this.type === 'awards') {
					that.getAwardPeriods()
				} else {
					that.getFinancesLog();
				}
			}, 1000);
		},
		onPageScroll(e) {
			if (e.scrollTop > 70) {
				this.flag = true;
			} else {
				this.flag = false;
			}
		},
	};
</script>

<style lang="scss" scoped>
	.financesBox {
		.desc {
			margin: 30rpx 20rpx 10rpx;
			text {
				color: #999999;
			}
		}

		.item {
			padding: 20rpx 40rpx;
			border-bottom: 1rpx solid #f1f1f1;

			.four {
				margin-left: 20rpx;
				color: #999999;
			}

			.first {
				font-size: 30rpx;
				flex-direction: column;

				.time {
					font-size: 26rpx;
					color: #999;
					display: block;
					margin-top: 10rpx;
				}
        .with-type{
          color: #000000;
          margin-top: 10rpx;
        }

				image {
					width: 110rpx;
					height: 110rpx;
					border-radius: 100%;
					margin-right: 30rpx;
					margin-bottom: 0;
				}
			}

			.second {
				flex: 1;
				flex-direction: column;
				color: #666666;
				font-size: 28rpx;
			}

			.right {
				font-size: 26rpx;
				color: #999;
				flex-direction: column;
				text-align: right;

				.money {
					font-size: 34rpx;
					color: #000000;
				}
			}
		}

		.blue {
			color: #007aff;
			font-size: 34rpx;
		}

		.red {
			color: red;
			font-size: 34rpx;
		}
	}

	.loading {
		text-align: center;
		color: #aaa;
		padding: 20rpx 0;
		font-size: 30rpx;
	}

	.topBox {
		width: 90rpx;
		height: 90rpx;
		position: fixed;
		right: 40rpx;
		bottom: 80rpx;
		border-radius: 50%;
		background: #fff;
		box-shadow: 0 5px 10px #aaa;
		text-align: center;

		.icon {
			line-height: 90rpx;
		}

		.img {
			width: 65%;
			position: relative;
			top: 12%;
		}
	}

	.details {
		.title {
			margin: 0 50rpx;
			padding: 80rpx 0;
			text-align: center;
			border-bottom: 1rpx solid #f1f1f1;
			display: flex;
			flex-direction: column;

			text:last-child {
				margin-top: 20rpx;
				font-size: 40rpx;
				font-weight: 700;
			}
		}

		.content {
			margin: 0 50rpx;
			padding-top: 30rpx;

			view {
				display: flex;
				margin-bottom: 20rpx;
				font-size: 32rpx;

				text:first-child {
					width: 20%;
					font-size: 30rpx;
					color: #999;
				}
			}
		}

		.bottom {
			background-color: #f1f1f1;
			position: fixed;
			bottom: 0;
			width: 100%;
			padding: 10rpx 0;
			text-align: center;
		}
	}
</style>
