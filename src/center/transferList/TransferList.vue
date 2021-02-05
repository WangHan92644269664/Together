<template>
	<view class="messageBox lighter-icon">
		<text class="u-f u-f-jsc nodata" v-if="lists.length === 0">暂无{{type === 2 ? '兑换' : type === 3 ? '充值' : '互转'}}记录</text>
		<view class="contents" v-else>
			<view class="item u-f u-f-ac u-f-jsb" v-for="(item, index) in lists" :key="index">
				<template v-if="type === 2">
					<text>{{item.exchange_src_finance_type|getFinanceName}} → {{item.exchange_dst_finance_type|getFinanceName}}</text>
					<view class="u-f u-f-fdc">
						<text class="font-text size36">{{item.exchange_currency}}</text>
						<text class="time-gray">{{item.exchange_add_date}}</text>
					</view>
				</template>
				<template v-else>
					<text>{{item.transfer_dst_account}}</text>
					<view class="u-f u-f-fdc">
						<text class="font-red size36">-{{item.transfer_currency}}</text>
						<text class="time-gray">{{item.transfer_add_date}}</text>
					</view>
				</template>
			</view>
		</view>
	</view>
</template>
<script>
	export default {
		data() {
			return {
				lists: [],
				type: ''
			};
		},
		onLoad(options) {
			// type: 2 是兑换记录
			this.type = Number(options.type)
			this.getLists()
		},
		methods: {
			// 提交
			async getLists() {
				let res
				if (this.type === 2) {
					res = await this.$api.postExchanges({}, 'get')
					uni.setNavigationBarTitle({
						title: '兑换记录'
					})
				}  else if (this.type === 3) {
					res = await this.$api.reqCharges({}, 'get')
					uni.setNavigationBarTitle({
						title: '充值记录'
					})
				} else {
					res = await this.$api.postTransfers({}, 'get')
				}
				console.log(res)
				this.lists = res.data
			}
		},
		onReachBottom() {
			let that = this;
			if (Number(this.length) < this.contents.length) {
				return
			}
			if (Number(this.length) === this.contents.length) {
				return this.loadingText = '已经加载完毕'
			}
			// this.timer = setTimeout(() => {
			// 	if (that.timer !== null) {
			// 		clearTimeout(that.timer);
			// 	}
			// 	that.page++
			// 	if (this.type === 'dis_money') {
			// 		that.getAwardPeriodSums()
			// 	} else if (this.type === 'dis_order') {
			// 		that.getOrderDistribute()
			// 	} else if (this.type === 'team') {
			// 		that.getRecommend()
			// 	} else if (this.type === 'team_per' || this.type === 'awards') {
			// 		that.getAwardPeriods()
			// 	} else {
			// 		that.getFinancesLog();
			// 	}
			// }, 1000);
		},
		onPageScroll(e) {
			if (e.scrollTop > 70) {
				this.flag = true;
			} else {
				this.flag = false;
			}
		}
	}
</script>

<style lang='scss' scoped>
	.item{
		border-bottom: 1px solid #EEEEEE;
		padding: 25rpx 40rpx;
		text-align: right;
	}
</style>
