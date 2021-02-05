<template>
	<view class="page_box lighter-icon">
		<view class="head_box u-f">
			<button :class="{ 'btn-active': typeCurrent === t.type }" class="cu-btn type-btn" @tap="selType(t.type)" v-for="(t,index) in commentTypeList"
			 :key="index">
				{{ t.text }}
			</button>
		</view>
		<view class="content_box">
			<scroll-view scroll-y="true" @scrolltolower="loadMore" class="scroll-box">
				<view class="comment-list">
					<block v-for="comment in commentList" :key="comment.product_comment_id">
						<sh-comment :comment="comment"></sh-comment>
					</block>
				</view>
			</scroll-view>
		</view>
		<view class="foot_box"></view>
		<!-- load -->
		<shoproLoad :status="status" :content-text="contentText"></shoproLoad>
	</view>
</template>

<script>
	import shComment from './child/sh-comment.vue';
	import shoproEmpty from '@/components/shopro-empty/shopro-empty.vue';
	export default {
		components: {
			shComment,
			shoproEmpty
		},
		data() {
			return {
				typeCurrent: 0,
				commentList: [],
				commentTypeList: [{
						text: '全部',
						type: 0,
						value: 0
					},
					{
						text: '好评',
						type: 5,
						value: 0
					},
					{
						text: '中评',
						type: 3,
						value: 0
					},
					{
						text: '差评',
						type: 1,
						value: 0
					}
				],
				id: '',
				page: 1,
				status: 'more',
				contentText: {
					contentdown: '查看更多',
					contentrefresh: '加载中',
					contentnomore: '没有更多'
				},
				total_count: 0,
			};
		},
		computed: {},
		onLoad(options) {
			this.id = options.id
			this.getCommentList();
		},
		// 上拉加载更多
		onReachBottom() {
			if (this.commentList.length >= this.total_count) {
				return this.status = 'nodata'
			}
			this.status = 'loading'
			uni.showNavigationBarLoading()
			setTimeout(() => {
				this.status = 'more'
				this.page = this.page + 1
				this.getCommentList()
				uni.hideNavigationBarLoading()
			}, 1000)
		},
		methods: {
			selType(index) {
				console.log(index)
				this.typeCurrent = index;
				this.commentList = [];
				this.getCommentList();
			},
			// 商品评论
			async getCommentList() {
				let data = {
					'page':this.page
				}
				if(this.typeCurrent!==0){
					data['product_comment_star'] = this.typeCurrent
				}
				let res = await this.$api.getComments(data,this.id)
				this.total_count = Number(res.header['x-pagination-total-count'])
				for(let item of res.data){
					this.commentList.push(item)
				}
				if(this.total_count===this.commentList.length){
					this.status ='nodata'
				}
			},
		}
	};
</script>

<style lang="scss">
	.empty-box {
		position: fixed;
		left: 50%;
		top: 50%;
		transform: translate(-50%, -50%);
	}

	.head_box {
		padding: 20rpx;

		.type-btn {
			width: 130rpx;
			height: 60rpx;
			line-height: 60rpx;
			border-radius: 30rpx;
			border: 0.5rpx solid #f4f4f4;
			background: #FFFFFF;
			font-size: 28rpx;
			font-family: PingFang SC;
			color: #000000;
			padding: 0;
			margin-right: 10rpx;
		}

		.btn-active {
			border: 0.5rpx solid #f39200;
			color: #f39200;
		}
	}

	.comment-list {
		margin-top: 20rpx;
	}
</style>
