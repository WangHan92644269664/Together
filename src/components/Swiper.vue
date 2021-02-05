<template>
	<!-- 轮播图 -->
	<view class="swiper">
		<view class="swiper-box box-shadow">
			<swiper circular="true" autoplay="true" @change="swiperChange" :indicator-dots="true">
				<swiper-item v-for="(swiper,index) in swiperList" :key="index" @tap="Go(index+1)">
					<image :src="web_img + 'swiper1.png'" mode="widthFix"></image>
				</swiper-item>
			</swiper>
		</view>
	</view>
</template>

<script>
	export default {
		data() {
			return {
				currentSwiper: 0,
				// 轮播图片
				swiperList: [1],
				web_img: this.$utils.webImg2
			}
		},
		methods: {
			//轮播图指示器
			swiperChange(event) {
				this.currentSwiper = event.detail.current;
			},
			Go(index){
				if(index===1||index===2){
					uni.navigateTo({
						url:'/home/detail/Detail?id=28'
					})
				}else{
					uni.navigateTo({
						url:'/home/detail/Detail?id=15'
					})
				}
			}
		}
	}
</script>

<style lang="scss">
	uni-image>img{
		height: 350rpx;
	}
	.swiper {
		width: 100%;
		margin-top: 10upx;
		height: 350rpx;
		display: flex;
		justify-content: center;

		.swiper-box {
			width: 98%;
			height: 350rpx;
			overflow: hidden;
			border-radius: 15upx;
			//兼容ios，微信小程序
			position: relative;
			z-index: 1;

			swiper {
				width: 100%;
				height: 350rpx;

				swiper-item {
					image {
						width: 100%;
						height:inherit;
					}
					img{
						width: 100%;
						height: inherit;
					}
				}
			}

			.indicator {
				position: absolute;
				bottom: 20rpx;
				left: 20rpx;
				background-color: rgba(150, 150, 150, 0.8);
				width: 150rpx;
				height: 10rpx;
				border-radius: 10rpx;
				overflow: hidden;
				display: flex;

				.dots {
					width: 0upx;
					background-color: rgba(255, 255, 255, 1);
					transition: all 0.3s ease-out;

					&.on {
						width: (100%/2);
					}
				}
			}
		}
	}
</style>
