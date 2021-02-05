<template>
	<view class="content">
		<view class="header u-f u-f-ac">
			<view class="money">{{length}}</view>
			<view class="words">团队总人数</view>
		</view>
		<view class="tabs u-f u-f-jsc">
			<text v-for="(item, index) in tabs" :key="index" :class="{'active':tabIndex === index}" @click="changeTab(index)">{{item}}</text>
		</view>
		<view class="contents" v-if="lists.length>0">
			<view class="item" v-for="(item, index) in lists" :key="index">
				<view class="first u-f u-f-jsb">
					<text>手机号：{{item.memberinfo_mobile}}</text>
					<text>账号：{{item.memberinfo_account}}</text>
				</view>
				<view class="second u-f u-f-jsb">
					<text>昵称：{{item.memberinfo_nickname}}</text>
					<text>{{item.memberinfo_verify_datetime}}</text>
				</view>
			</view>
			<view class="loading">{{loadingText}}</view>
		</view>
		<view class="loading" v-else>没有数据</view>
	</view>
</template>

<script>
	export default {
		data(){
			return{
				finances:uni.getStorageSync('finances'),
				imgUrl:this.$utils.imgUrl,
				tabs: ['一级', '二级'],
				tabIndex: 0,
				lists: [],
				loadingText:'加载更多',
				page:1,
				length:0,
				timer: null,
				status: '',
				layer: ''
			}
		},
		onLoad(){
			this.getMemberInfo()
		},
		methods:{
			changeTab (index) {
				this.lists = []
				this.tabIndex = index
				this.page = 1
				if (this.tabIndex === 0) {
					this.status = 2
					this.layer = ''
				} else {
					this.status = 1
					this.layer = 2
				}
				this.getMemberInfo()
			},
			Go(url){
				uni.navigateTo({
					url:url
				})
			},
			async getMemberInfo () {
				const data = {
					expand: 'membermap',
					page: this.page,
					'per-page': 5
				}
				if (this.layer) {
					data.layer = this.layer
				}
				const res = await this.$api.getMemberinfos(data)
				const length= Number(res.header['x-pagination-total-count'])
				this.length=length
				this.lists = this.page === 1 ? res.data : this.lists.concat(res.data)
				if(res.data.length<5){
					this.loadingText = '已经加载完毕'
					return
				}
			}
		},
		onReachBottom() {
			let that= this;
			this.timer = setTimeout(()=>{
				if(that.timer!==null){
					clearTimeout(that.timer)
				}
				console.log(this.length, that.lists.length)
				if(that.length!==that.lists.length){
					that.page++
					that.getMemberInfo()
				}else{
					that.loadingText = '已经加载完毕'
				}
			},1000)
		},
	};
</script>

<style lang="scss" scoped>
	.content {
		font-size: 30rpx;
		min-height: 100vh;
		background-color: #f6f6f6;
		.contents{
			.item{
				background: #FFFFFF;
				margin-bottom: 25rpx;
				padding: 30rpx;
				.first{
					margin-bottom: 20rpx;
				}
				.second{
					color: #666666;
				}
			}
		}
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
	.tabs{
		padding: 30rpx 0;
		text{
			background: #ffffff;
			font-size: 30rpx;
			padding: 26rpx 80rpx;
		}
		text:first-child{
			border-bottom-left-radius: 60rpx;
			border-top-left-radius: 60rpx;
		}
		text:last-child{
			border-bottom-right-radius: 60rpx;
			border-top-right-radius: 60rpx;
		}
		.active{
			background: #000000;
			color: #FFFFFF;
		}
	}
	.loading{
		padding-bottom: 30rpx;
		text-align: center;
		color: #999999;
	}
</style>
