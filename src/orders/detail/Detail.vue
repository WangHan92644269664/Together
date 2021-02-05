<template>
	<view class="Detail lighter-icon">
        <uni-nav-bar left-icon="back" title="导航栏组件"></uni-nav-bar>
    </view>
</template>
<script>
import uniNavBar from "@/components/uni-nav-bar/uni-nav-bar.vue"
	export default {
		data() {
			return {
               
			};
        },
        components:{
           uniNavBar
        },
		onLoad(option) {
          
		},
		mounted() {
		},
		methods: {
		}
	}
</script>

<style lang="scss">
@import '@/common/css/mixin';
	
</style>
