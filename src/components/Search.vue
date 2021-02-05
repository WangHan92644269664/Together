
<template>
		<!-- 搜索框 -->
		<view class="search u-f u-f-jsb u-f-ac" @click='search'>
			<!-- <input type="text" placeholder="搜索商品" v-model="search_info"/> -->
			<view class="ipt u-f u-f-ac">
				<text class="iconfont icon-sousuo1"></text>
				<text></text>
			</view>
			<view class="searchBtn u-f u-f-jsc u-f-ac">
				立即搜索
			</view>
		</view>
</template>

<script>
	export default {
		data() {
			return {
				search_info:''
			};
		},
		methods:{
			search(){
				// if(!this.search_info){
				// 	uni.showToast({
				// 			title:"请输入关键字",
				// 			icon:'none'
				// 	})
				// 	return
				// }
				this.$emit('searchInfo')
			},
			// Go(){
			// 	uni.navigateTo({
			// 		url:'../pages/home/search/Search',
			// 		animationType: 'pop-in',
			// 		animationDuration: 200
			// 	})
			// }
		}
	}
</script>
<style lang="scss">
	.search{
			width: 94%;
			padding: 10px 3%;
			border-radius: 4rpx;
			margin:50rpx 0;
			font-size: 31rpx;
			background-color: #fff;
			margin: 10px 0;
			.ipt{
				padding-left: 10rpx;
				height: 65rpx;
				color: #999;
				background: #E9ECF1;
				flex: 1;
			}
			.searchBtn{
				background-color: #5BC21B;
				color: #fff;
				padding:12rpx 20rpx;
				font-size: 30rpx;
			}
		}
</style>
