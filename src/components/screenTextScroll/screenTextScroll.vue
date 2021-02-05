<!-- 
展示屏幕文字滚动效果
 
使用方法：

 -->
<!-- 
展示屏幕文字滚动效果

usage:
 list:数组数据
 @getCurrentIndex  获取当前swiper的下标
 <textscroll :list="list" @getCurrentIndex="getIndex"/>

 -->

<template>
	<view class="_notice">
		<swiper class="_swiper tc" :indicator-dots="false" autoplay="true" :interval="interval" circular="true"
		 display-multiple-items="1" :duration="duration">
			<swiper-item>
				<view></view>
			</swiper-item>
			<swiper-item v-for="(item,index) in list" :key="index">
				<view>{{item}}</view>
			</swiper-item>
		</swiper>
	</view>
</template>

<script>
	export default {
		props: {
			//显示数据
			list: {
				type: Array,
				defual:function(){
					return [];
				}
			},
		},
		data() {
			return {
				interval:3000,
				duration:15000,
			};
		},
		methods:{
		}

	};
</script>

<style lang="scss" scoped>
	._notice {
		position: fixed;
		left: 0;
		top: 0;
		/* #ifdef H5 */
		top: 100upx;
		/* #endif */
		z-index: 9;
		width: 100%;
		background:rgba($color: #dbc291, $alpha: 0.9);
		font-size: 30upx;
		height: 70upx;
		color: #ffffff;
		overflow: hidden;
		box-sizing: border-box;
		/deep/ swiper{
			height: 70rpx;
		}

	}

	._swiper {
		line-height: 70upx;
	}
</style>
