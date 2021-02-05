<template>
	<view class="header-box">
		<image class="logo" :src="img_url+'logo.png'" mode="widthFix"></image>
		<view class="input-box u-f u-f-ac" @tap="toSearch(currentIndex)">
			<image class="search" :src="search" mode="widthFix"></image>
			<text>搜索商品</text>
		</view>
		<image class="notice" :src="notice" @tap="gotoNotice"></image>
	</view>
</template>

<script>
	export default {
		props: {
			currentIndex: Number
		},
		data() {
			return {
				search:require('@/static/index/search_grey.png'),
				notice:require('@/static/index/notice.png'),
				img_url:this.$utils.webImg2
			};
		},
		methods: {
			toSearch(index) {
				uni.navigateTo({
					url: '/home/search/Search?index=' + index
				});
			},
			gotoNotice() {
				uni.navigateTo({
					url: '/home/notice/Notice'
				});
			}
		}
	};
</script>

<style scoped lang="scss">
	.header-box {
		display: flex;
		align-items: center;
		// height: 60rpx;
		padding: 0 0 20rpx;

		.logo {
      width: 12%;
      height: 100%;
      margin-right: 20rpx;
		}

		.input-box {
			flex: 1;
			background: #FFFFFF;
			height: 70rpx;
			border-radius: 20px;
			color: #bbbbbb;
			font-size: 26rpx;
			display: flex;
			justify-content: center;
			align-items: center;

			.search {
				margin-right: 10rpx;
			}

			image {
				width: 26rpx;
				height: 26rpx;
			}
		}

		.notice {
			height: 60rpx;
			width: 40rpx;
			margin: 0 20rpx;
		}
	}
</style>
