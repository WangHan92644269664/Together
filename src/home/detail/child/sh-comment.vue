<template>
	<view class="comment-box">
		<view class="head u-f u-f-jsb u-f-ac">
			<view class="u-f">
				<image class="avatar" :src="img_url+'avatar/'+comment.memberInfo.memberinfo_avatar_image" mode="aspectFill" v-if="comment.memberInfo.memberinfo_avatar_image"></image>
				<image class="avatar" :src="img_url+'mobile/user.png'" mode="aspectFill" v-else></image>
				<view class="user-name">{{ comment.product_comment_account }}</view>
				<!-- 黄色星星 -->
				<view class="u-f star-box">
					<text class="iconfont icon-start star-active" v-for="(s,index) in comment.product_comment_star" :key="index"></text>
				</view>
				<!-- 灰色星星 -->
				<view class="u-f star-box">
					<text class="iconfont icon-start" v-for="(z,index2) in (5 - comment.product_comment_star)" :key="index2"></text>
				</view>
			</view>
			<text class="time">{{ comment.product_commend_update_datetime}}</text>
		</view>
		<view class="detail">{{ comment.product_comment_content }}</view>
		<view class="img-box" v-if="comment.product_comment_images">
			<view class="mask"></view>
			<scroll-view class="nav" scroll-x scroll-with-animation :scroll-left="scrollLeft">
				<image v-for="(item,index3) in imgs" :key="index3" @tap="imgSelect(index)" @tap.stop="$tools.previewImage(imgs, index)" class="comment-img" :src="item"
				 mode="aspectFill"></image>
			</scroll-view>
		</view>
	</view>
</template>

<script>
	export default {
		components: {},
		data() {
			return {
				scrollLeft: 0,
				tools: this.$tools,
				img_url: this.$utils.imgUrl,
				imgs:[],
				
			};
		},
		props: {
			comment: {}
		},
		created() {
			if(this.comment.product_comment_images){
				let imgs = this.comment.product_comment_images;
				for(let item of imgs.split(';')){
					item = this.img_url+'product-comment/'+item
					this.imgs.push(item)
				}
			}
		},
		methods: {
			imgSelect(current) {
				this.scrollLeft = current * 60;
			}
		}
	};
</script>

<style lang="scss">
	.comment-box {
		padding: 30rpx 20rpx;
		border-bottom: 1rpx solid #eee;
		background: #fff;

		.head {
			margin-bottom: 20rpx;

			.avatar {
				width: 52rpx;
				height: 52rpx;
				border-radius: 50%;
			}

			.user-name {
				font-size: 26rpx;
				color: #999;
				margin: 0 20rpx;
			}

			.star-box {
				.icon-start {
					font-size: 30rpx;
					color: #dedede;
					 fill: currentColor
				}
				.star-active {
					color: #ffba00;
				}
			}
			.time {
				font-size: 24rpx;
				color: #c4c4c4;
			}
		}

		.detail {
			font-size: 26rpx;
			font-family: PingFang SC;
			font-weight: 500;
			color: rgba(102, 102, 102, 1);
			line-height: 42rpx;
		}

		.img-box {
			margin-top: 30rpx;
			position: relative;
			.mask {
				background: linear-gradient(270deg, rgba(255, 255, 255, 0.8) 0%, rgba(255, 255, 255, 0) 100%);
				width: 100rpx;
				height: 100%;
				position: absolute;
				z-index: 10;
				right: 0;
			}

			.comment-img {
				width: 166rpx;
				height: 166rpx;
				background: #ccc;
				margin-right: 19rpx;
				margin-bottom: 19rpx;
			}
		}
	}
</style>
