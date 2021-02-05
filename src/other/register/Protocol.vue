<template>
	<view class="box lighter-icon">
		<rich-text :nodes="nodes"></rich-text>
	</view>
</template>

<script>
	export default {
		data() {
			return {
				nodes: ''
			};
		},
		onShow (options) {
			this.getConfig()
		},
		methods: {
			async getConfig () {
				uni.showLoading()
				const res = await this.$api.getConfig()
				this.nodes = res.data.regExplain.replace(/\n/g, "<br/>")
				uni.hideLoading()
			}
		}
	};
</script>

<style lang="scss" scoped>
	.box {
		background: #FFFFFF;
		padding: 30rpx;
		box-sizing: border-box;
	}
</style>
