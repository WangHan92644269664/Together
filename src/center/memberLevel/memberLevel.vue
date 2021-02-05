<template>
	<view class="info-box lighter-icon">
		<view class="contents">
			<view class="infos">
			<!-- 	<view class="item" v-html="configs.rightsAndInterests.shopkeeper"></view>
				<view class="item" v-html="configs.rightsAndInterests.chainstore"></view>
				<view class="item" v-html="configs.rightsAndInterests.partner"></view>
				<view class="item" v-html="configs.rightsAndInterests.thanksgiving"></view> -->
				<!-- <block v-for="(item,index) in configs.rightsAndInterests" :key="index">
					<view class="item" v-html="item"></view>
				</block> -->
			</view>
			<view class="item u-f u-f-jsb u-f-ac" v-for="(item,index) in levels.gaplevel" :key="index">
				<text>{{item.level_name}}</text>
				<text class="money">还需{{item.level===1?'分享':'团队'}}业绩{{item.gap|two}}元（累计业绩{{item.level===1?levels.membermap.membermap_recommend_order:levels.membermap.membermap_recommend_under_order}}）</text>
			</view>
			<template v-if="levels.gaplevel.length===0">
				<view class="btn">已是最高级别</view>
			</template>
		</view>
	</view>
</template>

<script>
	export default {
		data() {
			return {
				levels: '',
				level: uni.getStorageSync('userInfo').memberinfo_memberlevel_level,
				infos:[],
				configs: ''
			};
		},
		onLoad() {},
		onShow() {
			// this.getConfig()
			this.getLevels()
		},
		methods:{
			async getLevels(){
				const res = await this.$api.getMemberView()
				console.log(res)
				this.levels = res.data
			},
			async getConfig(){
				uni.showLoading()
				const res = await this.$api.getConfig()
				this.configs = res.data
				console.log(this.configs)
				let upgrade = res.data.memberUpgrade
				uni.hideLoading()
				let team = res.data.awardCalc.team
				let teacher  = Number(res.data.awardCalc.teacher.award_default_money*100).toFixed(0)
				this.infos = []
			},
		}
	}
</script>

<style lang='scss' scoped>
	.info-box {
		background: #f5f5f5;

		.contents {
			background: #ffffff;
			padding: 0 30rpx;
			.infos{
				margin:60rpx 0;
				.item{
					color: #999999;
					text-indent: 2em;
				}
			}
		}

		.item {
			padding: 30rpx 0;
			color: #444444;
			font-size: 30rpx;
			border-top: 1px solid #f5f5f5;

			>text {
				color: #000000;
				font-size: 30rpx;
			}

			.money {
				color: #666666;
				font-size: 28rpx;
			}
		}
		.btn{
			width: 40%;
			margin:100rpx auto;
			border:1px solid #f5f5f5;
			color: #666666;
			padding: 20rpx 0;
			text-align: center;
		}
	}
</style>
