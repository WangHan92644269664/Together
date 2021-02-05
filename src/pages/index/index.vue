<template>
	<view class="content">
		<view class="btn" @tap="showCalendar">选择日期：{{result.fullDate}} {{result.week}}</view>
		<wCalendar
			ref="calendar"
			:lunar="true" 
			:disabledBefore="false" 
			:disabledAfter="false" 
			@confirm="getResult">
		</wCalendar>
	</view>
</template>



<script>
	import wCalendar from "@/components/w-calendar/w-calendar.vue";
	export default {
		components:{
			wCalendar
		},
		data() {
			return {
				title: 'Hello',
				result:{}
			}
		},
		onLoad() {

		},
		methods: {
			showCalendar(){
				this.$refs.calendar.show();
			},
			getResult(res){
				console.log(res);
				this.result=res;
			}
		}
	}
</script>

<style>
	.btn{
		padding-top: 100rpx;
		text-align: center;
	}
</style>
