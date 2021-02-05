<template>
	<view class="protocol-box lighter-icon">
		<view class="tabs">
			<block v-for="(item,index) in tabs" :key="index">
				<text class="item" @tap="ChangeTab(index)" :class="[index===tab_index?'on':'']">
					{{item}}
				</text>
			</block>
		</view>
		<rich-text :nodes="tab_index===0?user:merchant"></rich-text>
	</view>
</template>

<script>
	export default {
		data() {
			return {
				tabs: ['隐私协议', '代理商协议'],
				tab_index: 0,
				user: '',
				merchant: ''
			};
		},
		onLoad(options) {
			this.getConfig()
		},
		mounted() {

		},
		methods: {
			ChangeTab(index) {
				this.tab_index = index
			},
			async getConfig() {
				const res = await this.$api.getConfig()
				this.user = res.data.regExplain.replace(/\n/g, '<br/>')
				this.merchant = res.data.shopExplain.replace(/\n/g, '<br/>')
			}
		},
	};
</script>

<style lang="scss">
	.protocol-box {
		padding: 130rpx 30rpx 30rpx;
		margin: 0 auto;

		.tabs {
			position: fixed;
			top: 100rpx;
			width: 100%;
			padding: 30rpx 0;
			box-sizing: border-box;
			background: #FFFFFF;

			.item {
				color: #ffffff;
				font-size: 32rpx;
				width: 46%;
				display: inline-block;
				text-align: center;
				background: #AAAAAA;
				height: 80rpx;
				line-height: 80rpx;
			}

			.on {
				background: #000000;
			}
		}

		.content {
			font-size: 30rpx;
			color: #666666;
			text-indent: 2em;
			padding-top: 20rpx;
		}
	}

	/deep/strong {
		font-weight: bold;
		font-size: 34rpx;
		margin: 30rpx 0 !important;
		color: #000000 !important;
	}
</style>
