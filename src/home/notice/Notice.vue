<template>
	<view class="notice lighter-icon">
		<view class="list u-f u-f-jsb" v-for="(item, index) in data" :key="index" @click="Detail(item.announcement_id)">
			<view class="left u-f u-f-jsb">
				<view class="title font-one">{{ item.announcement_title }}</view>
				<view class="time u-f">{{ item.announcement_add_datetime }}</view>
			</view>
			<view class="content" v-html="item.announcement_content"></view>
		<!-- 	<view class="header u-f u-f-ac">
				
			</view>
			<view class="content" v-html="item.announcement_content"></view>
			<view class="time u-f">{{ item.announcement_add_datetime }}</view> -->
		</view>
		<text v-if="data.length===0" class="no-data u-f u-f-jsc">暂无消息记录</text>
	</view>
</template>
<script>
	export default {
		name: "Notice",
		data() {
			return {
				data: [],
			};
		},
		created() {
			this.getNotice()
		},
		methods: {
			async getNotice() {
				const res = await this.$api.getAccount()
				this.data = res.data
			},
			Detail (id) {
				uni.navigateTo({
					url: '../noticeDetail/NoticeDetail?id='+id
				})
			}
		},
	};
</script>
<style lang="scss" scoped>
	.notice {
		background: #f7f8fa;
		min-height: 100vh;
		overflow: auto;

		.list {
			background: #fff;
			width: 94%;
			margin: 20rpx auto;
			border-radius: 0.1rem;
			padding: 30rpx;
			box-sizing: border-box;
			text-align: left;
			margin-bottom: 20rpx;
			.left{
				flex-direction: column;
				text-align: left;
				flex: 1;
				padding: 20rpx;
				box-sizing: border-box;
				.time{
					color: #999999;
				}
			}
			.title {
				color: #000;
				font-size: 34rpx;
				font-weight: bold;
				width: 400rpx;
			}
			/deep/ img {
				width: 200rpx!important;
				height: 200rpx!important;
				display: block!important;
				margin: 20rpx!important;
			}
			.content {
				color: #666;
				font-size: 30rpx;
				width: 200rpx;
				line-height: 40rpx!important;
			}
		}
	}
	.no-data{
		font-size: 28rpx;
		color: #999999;
		padding-top: 40rpx;
	}
</style>
