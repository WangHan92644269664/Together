<template>
	<!-- 授权优惠券 -->
	<uni-popup ref="popup" type="center" :maskClick="false" v-if="popup">
		<view class="coupon-bg u-f u-f-jsc">
			<image :src="type==='auth'?coupon:''" mode="widthFix"></image>
			<view class="btns u-f u-f-jsb">
				<button open-type="share">分享好友</button>
				<button @tap="Close">立即使用</button>
			</view>
			<text class="iconfont icon-guanbi" @tap="Close"></text>
		</view>
	</uni-popup>
</template>

<script>
	import uniPopup from '@/components/uni-popup/uni-popup.vue';
	export default {
		name: 'rate',
		props: {
			title: '',
			page: '',
			type: 'share',
			popup: false
		},
		data() {
			return {
				coupon: this.$utils.webImg2 + 'coupon.png',
				is_popup: false,
				code_text: uni.getStorageSync('userInfo').memberinfo_account,
			};
		},
		watch: {
			popup(newVal) {
				this.is_popup = newVal
			}
		},
		// 转发
		onShareAppMessage(options) {
			let that = this;
			return {
				title: '爱拼',
				path: '/pages/home/index?scene=' + that.code_text
			}
		},
		created() {

		},
		components: {
			uniPopup
		},
		methods: {
			Close() {
				this.$refs.popup.close()
				this.is_popup = false
			},
		}
	}
</script>

<style lang="scss" scoped>

</style>
