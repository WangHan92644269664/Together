<template>
	<view class="content lighter-icon">
		<view class="header u-f u-f-ac">
			<view class="money">{{finances[0].finance_award|two}}</view>
			<view class="words">总资产 (元)</view>
		</view>
		<view class="bottom u-f">
			<block v-for="(item,index) in finances" :key="index">
				<view class="item" @tap="Go('/center/financesDetail/FinancesDetail?type='+item.finance_type)">
					<view class="number">{{item.finance_award|two}}</view>
					<view class="words">{{item.financeType.finance_type_name}}</view>
				</view>
			</block>
		</view>
		<div class="tabs u-f u-f-jsa u-f-ac">
			<view class="item" v-for="(item, index) in lists" :key="index" @tap="Go(item.url)">
				<text class="iconfont" :class="item.icon"></text>
				<text class="text">{{item.text}}</text>
			</view>
		</div>
		<view class="bodyer">
			<view class="item" v-for="(item, index) in details" :key="index" @tap="Go(item.url)">
				<view class="left u-f u-f-ac">
					<text class="iconfont" :class="item.icon"></text>
					<text class="text">{{item.text}}</text>
				</view>
				<text class="iconfont icon-arrow-right"></text>
			</view>
		</view>
	</view>
</template>

<script>
	export default {
		data(){
			return{
				finances:uni.getStorageSync('finances'),
				imgUrl:this.$utils.imgUrl,
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
				],
				details: [
					{
						text: '我的钱包',
						url: '/center/bank/Bank',
						icon: 'icon-qianbao1'
					},
					{
						text: '提现记录',
						url: '/center/financesDetail/FinancesDetail?type=withdraw',
						icon: 'icon-tixianjilu1'
					},
					{
						text: '充值记录',
						url: '/center/transferList/TransferList?type=3',
						icon: 'icon-chongzhijilu'
					},
					{
						text: '互转记录',
						url: '/center/transferList/TransferList',
						icon: 'icon-jilu'
					},
					{
						text: '兑换记录',
						url: '/center/transferList/TransferList?type=2',
						icon: 'icon-jilu3'
					}
				]
			}
		},
		onLoad(){
			console.log(this.finances)
		},
		onShow(){
			this.finances = uni.getStorageSync('finances')
		},
		methods:{
			Go(url){
				uni.navigateTo({
					url:url
				})
			}
		}
	};
</script>

<style lang="scss" scoped>
	.content {
		height: 100vh;
		font-size: 30rpx;
		background-color: #f6f6f6;
	}

	.header {
		color: #fff;
		background-size: 100% 100%;
		padding: 80rpx 0;
		flex-direction: column;
		background: #000000;
		.money{
			font-size: 45rpx;
			margin-bottom: 30rpx;
		}
	}
	.bottom {
		background: #FFFFFF;
		margin: 20rpx 0;
		padding: 30rpx 0;
		.item {
			flex: 1;
			box-sizing: border-box;
			text-align: center;
			.number{
				font-size: 34rpx;
			}
			.words {
				margin-top: 8rpx;
				color: #999999;
				font-size: 28rpx;
			}
		}
	}
	.tabs{
		background: #FFFFFF;
		margin-bottom: 20rpx;
		padding: 30rpx;
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
	.bodyer {
		.item {
			display: flex;
			align-items: center;
			justify-content: space-between;
			padding: 10rpx 30rpx;
			height: 100rpx;
			background-color: #FFFFFF;
			.left{
				.iconfont{
					font-size:60rpx;
					display: inline-block;
					margin-right: 20rpx;
				}
			}
			.icon-arrow-right{
				color: #999999;
				font-size: 32rpx;
			}
		}
	}

	.footer {
		display: flex;
		justify-content: space-between;
		padding: 0 40rpx;

		.button {
			position: fixed;
			bottom: 30rpx;
			left: 30rpx;
			right: 30rpx;
			height: 95rpx;
			flex: 1;
			display: flex;
			justify-content: center;
			align-items: center;
			border-radius: 8rpx;
		}

		.color {
			color: #fff;
		}
	}
</style>
