<template xlang="wxml">
	<view class="financesBox lighter-icon">
		<view class="contents" v-if="contents.length>0">
			<view class="item" v-for="(item,index) in contents" :key="index">
				<view class="first">
					<text>{{item.award_period_sum_sum_type===1?'余额':'商城消费'}}</text>
					<text class="money">{{item.award_period_sum_currency|two}}</text>
				</view>
				<view class="first sec" v-for="(item2,index) in item.awardPeriodSumAwardPeriods" :key="index">
					<text>{{item2.awardPeriodType.award_type_name}}：
						 <text :class="Number(item2.award_period_currency)<0?'':'zong'">{{item2.award_period_currency|two}}</text></text>
				</view>
				<view class="second">
					<text>{{item.award_period_sum_add_date}}</text>
				</view>
			</view>
			<view class="loading">{{loadingText}}</view>
			<view class="topBox" :hidden="!flag" @tap="toTop">
				<uni-icons type="arrowup" size="29" color="#333" class="icon" ></uni-icons>
			</view>
		</view>
		<view class="loading" v-else>没有数据</view>
	</view>
</template>
<script>
import uniIcons from '@dcloudio/uni-ui/lib/uni-icons/uni-icons.vue'
export default {
	data() {
		return {
			contents:[],
			loadingText:'加载更多',
			page:1,
			timer:null,
			flag:false,
			length:0
			
		}
	},
	components:{
		uniIcons
	},
	methods: {
		getFinancesLog(){
			let data={
				'per-page':9,
				'sort':'-finance_log_add_datetime',
				'page':1
			}
			this.$api.getAwardPeriodSums(data).then(res=>{
				const length=res.header['x-pagination-total-count'];
				this.length=length;
				this.contents = res.data;
				uni.setNavigationBarTitle({
					title:'佣金明细('+Number(res.data[0].award_period_sum_currency).toFixed(2)+')',
				})
				if(res.data.length<9){
					this.loadingText = '已经加载完毕'
					return
				}
			})
		},
		getMore(){
			if(this.loadingText === '已经加载完毕'){
				return
			}
			uni.showLoading({
				title:'加载中...'
			})
			this.loadingText = '加载中...'
			let data={
				'per-page':9,
				'sort':'-finance_log_add_datetime',
				'page':this.page
			}
			this.$api.getAwardPeriodSums(data).then(res=>{
				uni.hideLoading();
				this.contents = this.contents.concat(res.data);
				uni.stopPullDownRefresh();
				if(res.data.length<9){
					this.loadingText = '已经加载完毕'
					return
				}
				this.loadingText = '加载更多';
				uni.hideLoading();
			})
		},
		toTop(){
			uni.pageScrollTo({
			    scrollTop: 0,
			    duration: 200
			});
		},
		
	},
	components: {
		
	},
	onLoad: function (options) { 
		uni.setNavigationBarColor({
		    frontColor: '#000000',
		    backgroundColor: '#f3f3f3',
		    animation: {
		        duration: 400,
		        timingFunc: 'easeIn'
		    }
		})
		this.getFinancesLog();
		
	},
	onReachBottom() {
		let that= this;
		this.timer = setTimeout(()=>{
			if(that.timer!==null){
				clearTimeout(that.timer)
			}
			if(this.length!==this.contents.length){
				that.getMore(that.page++)
			}else{
				this.loadingText = '已经加载完毕'
			}
		},1000)
	},
	onPageScroll(e) {
		if(e.scrollTop>70){
			this.flag = true;
		}else{
			this.flag = false
		}
	}
}
</script>

<style lang="scss">
	page{
		background: #fff;
	}
.financesBox{
	padding: 0 40rpx;
	.item{
		padding: 20rpx 0;
		border-bottom: 1rpx solid #f1f1f1;
		.first,.second{
			display: flex;
			justify-content: space-between;
		}
		.first{
			margin-bottom: 15rpx;
			font-size: 34rpx;
			text:first-child{
				width: 70%;
				text-overflow: hidden;
				white-space: nowrap;
				overflow: hidden;
			}
			.money{
				color: #2A9838;
			}
		}
		.sec{
			font-size: 31rpx;
			color: #777777;
		}
		.second{
			font-size: 28rpx;
			color: #999999;
		}
	}
	.zong{
		color: #fAC339;
	}
}
.loading{
	line-height: 2em;
	text-align: center;
	color: #888;
	padding: 10rpx;
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
	.img{
		width: 65%;
		position: relative;
		top:12%;
	}
}

</style>
