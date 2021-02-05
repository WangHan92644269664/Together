<template>
	<view class="container">
		<view class="tabs u-f u-f-jsc">
			<text v-for="(item, index) in tabs" :key="index" :class="{'active':tabIndex === index}" @click="changeTab(index)">{{item}}</text>
		</view>
		<view class="contents">
			<view class="nodata" v-if="lists.length === 0">暂无数据</view>
			<view class="item u-f" v-for="(item, index) in lists" :key="index" v-else>
				<image :src="item.groupMemberGroup.groupProduct.product_image|getProductImg" mode="widthFix" class="left"></image>
				<view class="right u-f u-f-fdc">
					<text class="name">名称：{{item.groupMemberGroup.groupProduct.product_name}}</text>
					<text class="time">时间：{{item.group_member_add_time}}</text>
					<text class="price">价格：<text>￥{{item.groupMemberGroup.group_price|two}}</text></text>
					<view class="btn u-f">
						<button plain size="mini" type="warn" @click="Pay(item.group_member_order)" class="pay" v-if="item.group_member_status === 0">立即支付</button>
						<button plain size="mini" @click="Detail(item.group_member_order)" class="detail">查看记录</button>
					</view>
				</view>
			</view>
		</view>
	</view>
</template>
<script>
	export default {
		data() {
			return {
				tabs: ['正在拼团', '参团成功'],
				tabIndex: 0,
				lists: [],
				status: 2
			}
		},
		onLoad: function() {
			this.getLists()
		},
		onShareAppMessage(options) {
		},
		methods: {
			// 去支付
			Pay (id) {
				uni.navigateTo({
					url: '../../orders/pay/Pay?id='+id
				})
			},
			Detail (id) {
				uni.navigateTo({
					url: '../groupDetail/groupDetail?id='+ id
				})
			},
			changeTab (index) {
				this.tabIndex = index
				if (this.tabIndex === 0) {
					this.status = 2
				} else {
					this.status = 1
				}
				this.getLists()
			},
			async getLists () {
				// group_member_is_success: 2 未开奖也就是正在拼团， 0失败  1成功
				const data = {
					group_member_is_success: this.status,
					expand: 'groupMemberGroup.memberInfo, groupMemberGroup.groupProduct',
					// group_member_status: 1
				}
				const res = await this.$api.getGroups(data)
				console.log(res)
				this.lists = res.data
			}
		},
	};
</script>

<style lang="scss" scoped>
.container{
	background: #f5f5f5;
	height: 100vh;
	overflow-y: scroll;
}
.tabs{
	padding: 30rpx 0;
	text{
		background: #ffffff;
		font-size: 30rpx;
		padding: 26rpx 60rpx;
	}
	text:first-child{
		border-bottom-left-radius: 60rpx;
		border-top-left-radius: 60rpx;
	}
	text:last-child{
		border-bottom-right-radius: 60rpx;
		border-top-right-radius: 60rpx;
	}
	.active{
		background: #000000;
		color: #FFFFFF;
	}
}
.contents{
	.item{
		background: #FFFFFF;
		margin-bottom: 30rpx;
		padding: 20rpx;
		box-sizing: border-box;
		image.left{
			width: 180rpx;
			height: 180rpx;
		}
		.right{
			font-size: 34rpx;
			margin-left: 20rpx;
			.name{
				font-weight: bold;
				flex: 1;
				width: 540rpx;
				text-overflow: ellipsis;
				overflow: hidden;
				white-space: nowrap;
			}
			.time{
				margin: 10rpx 0;
			}
			.price{
				text{
					color: #CFB47E;
					font-size: 40rpx;
				}
			}
			.btn{
				margin-top: 40rpx;
				justify-content: flex-end;
				button.detail{
					border: 1px solid #dddddd;
					color: #aaaaaa;
				}
				button{
					margin: 0;
					padding: 0 30rpx;
					line-height: 2;
				}
				button:nth-child(2) {
					margin-left: 20rpx;
				}
			}
		}
	}
}
</style>
