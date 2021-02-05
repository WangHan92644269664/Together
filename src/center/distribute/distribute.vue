<template>
	<view class="info-box lighter-icon">
		<view class="code u-f u-f-ac">
			<text class="iconfont icon-yaoqingma"></text>我的分享码：{{code_text|getCode}}
		</view>
		<!-- 可提现佣金 -->
		<view class="moneys u-f">
			<view class="item u-f">
				<view class="left  u-f">
					<text class="money">{{withdraw_money|two}}</text>
					<text>成功提现佣金(元)</text>
				</view>
			</view>
			<view class="item u-f u-f-ac u-f-jsb">
					<view class="left  u-f">
						<text class="money">{{finances.finance_award|two}}</text>
						<text>可提现佣金(元)</text>
					</view>
					<template v-if="finances.finance_award!=='0.0000'">
						<text class="btn"  @tap="Go('/center/withdraw/Withdraw')">佣金提现</text>
					</template>
			</view>
		</view>
		<!-- 明细 -->
		<view class="details u-f">
			<block v-for="(item,index) in lists" :key="index">
				<view class="item u-f u-f-ac" @tap="Detail(item.url)">
					<text class="iconfont" :class="item.icon"></text>
					<view class="right u-f">
						<text>{{item.text}}</text>
						<text>{{item.money}}</text>
					</view>
				</view>
			</block>
		</view>
		<!-- 推广二维码 -->
		<view class="codes u-f u-f-ac u-f-jsb" @tap="Go('/center/code/Code')">
			<view class="left　u-f u-f-ac">
				<text class="iconfont icon-qrcode"></text>
				<text class="code-text">推广分享码</text>
			</view>
			<text class="iconfont icon-arrow-right"></text>
		</view>
	</view>
</template>

<script>
	export default {
		data() {
			return {
				lists:[
					{
						icon:'icon-qianbao',
						text:'分享佣金',
						money:'0.00 元',
						url:'dis_money'
					},
					{
						icon:'icon-fenxiaodingdan',
						text:'分享订单',
						money:'0 笔',
						url:'dis_order'
					},
					{
						icon:'icon-tuandui',
						text:'团队佣金',
						money:'0.00 元',
						url:'team_per'
					},
					{
						icon:'icon-iconfonttuandui',
						text:'我的战队',
						money:'0 人',
						url:'team'
					},
					{
						icon:'icon-jiangjinchi',
						text:'感恩奖',
						money:'0.00 元',
						url:'awards'
					},
					{
						icon:'icon-tixianmingxi',
						text:'提现明细',
						money:'0 笔',
						url:'withdraw'
					}
				],
				finances:uni.getStorageSync('finances')[0],
				withdraw_money:0,
				code_text:uni.getStorageSync('userInfo').memberinfo_account,
			};
		},
		onLoad() {
		},
		onShow(){
			this.getCharts()
		},
		filters:{
			getCode(val){
				return val.replace(/ep/g,'HT')
			}
		},
		methods: {
			Go(url){
				uni.navigateTo({
					url:url
				})
			},
			Detail(url){
				uni.navigateTo({
					url:`/center/financesDetail/FinancesDetail?type=${url}`
				})
			},
			async getCharts(){
				const res = await this.$api.getWithdrawChart()
				console.log(res)
				this.withdraw_money = res.data.yesWithdrawals
				this.lists[0].money = Number(res.data.distributionMoney).toFixed(2)+' 元'
				this.lists[1].money = res.data.distributionOrder+' 笔'
				this.lists[2].money = Number(res.data.teamMoney).toFixed(2)+' 元'
				this.lists[3].money = res.data.recommendCount+' 人'
				this.lists[4].money = Number(res.data.teacherMoney).toFixed(2)+' 元'
				this.lists[5].money = res.data.withdrawalsCount+' 笔'
			}
		},
	};
</script>

<style lang="scss" scoped>
	.info-box{
		background: #f5f5f5;
		padding-top:4rpx;
		height: 100%;
	}
	.code,.moneys,.details,.codes{
		background: #FFFFFF;
		margin-top: 30rpx;
		padding: 20rpx 30rpx;
		font-size: 28rpx;
	}
	.code{
		padding: 40rpx 30rpx;
		.icon-yaoqingma{
			font-size: 36rpx;
			margin-right: 20rpx;
			color: #F1A652;
		}
	}
	.moneys{
		padding: 0;
		flex-direction: column;
		.item{
			border-bottom: 1px solid #f5f5f5;
			padding: 40rpx 30rpx;
			.left{
				flex-direction: column;
				.money{
					color: #F1A652;
					font-size: 40rpx;
					font-weight: bold;
					margin-bottom: 10rpx;
				}
				text:last-child{
					font-size: 28rpx;
				}
			}
			.btn{
				background: #cccccc;
				color: #FFFFFF;
				border-radius: 60rpx;
				padding: 10rpx 30rpx;
				font-size: 28rpx;
			}
		}
		.item:last-child{
			border:none;
		}
	}
	.details{
		flex-wrap: wrap;
		padding: 0;
		.item{
			width: 50%;
			padding: 24rpx 30rpx;
			border-right: 1px solid #f5f5f5;
			border-bottom: 1px solid #F5F5F5;
			box-sizing: border-box;
			.right{
				flex-direction: column;
				text:last-child{
					color: #999999;
					font-size: 28rpx;
					margin-top: 4rpx;
				}
			}
			.iconfont{
				font-size: 60rpx;
				margin: 20rpx;
			}
			.icon-qianbao{
				color: #EB535C;
			}
			.icon-fenxiaodingdan{
				color: #A6C8F0;
			}
			.icon-tixianmingxi{
				color: #F5C04F;
			}
			.icon-iconfonttuandui{
				color: #ED772F;
				font-size: 70rpx;
			}
			.icon-tuandui{
				color: #ff9d00;
				font-size: 65rpx;
				font-weight: bold;
			}
			.icon-jiangjinchi{
				color: #c5ff86;
				font-size: 65rpx;
			}
		}
		.item:nth-child(2n){
			border-right: none;
		}
		.item:nth-child(3),.item:nth-child(4){
			border-bottom: none;
		}
	}
	.codes{
		padding: 30rpx;
		color: #333333;
		.code-text{
			font-weight: bold;
		}
		.icon-qrcode{
			font-size: 50rpx;
			margin-right: 20rpx;
			color: #F1A652;
		}
	}
</style>
