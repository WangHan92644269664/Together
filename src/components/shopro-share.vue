<template>
	<view class="content" v-if="show_share">
		<view class="bottoms">
			<text class="u-f u-f-jsc title">分享到</text>
			<view class="bottom u-f u-f-jsc">
				<block v-for="(item,index) in lists" :key="index">
					<button class="item u-f u-f-ac" :open-type="index===0&&token?'share':''" @tap="Change(index)">
						<text class="iconfont" :class="item.icon"></text>
						<text>{{item.text}}</text>
					</button>
				</block>
			</view>
			<text class="cancel u-f u-f-jsc" @tap="Cancel">
				取消
			</text>
		</view>
		<hchPoster class="poster" ref="hchPoster" @cancel="canvasCancel" :simpleFlag="simpleFlag" :posterBgFlag="posterBgFlag"
		 :canvasAttr.sync="posterObj" />
	</view>
</template>

<script>
	import hchPoster from "@/components/hch-poster.vue"
	export default {
		data() {
			return {
				shareData: {}, //组装海报分享信息
				lists: [{
						text: '微信',
						icon: 'icon-weixin'
					},
					{
						text: '生成海报',
						icon: 'icon-iconfont19'
					},
					{
						text: '复制口令',
						icon: 'icon-kouling'
					}
				],
				is_show: false,
				img_url: this.$utils.productImg,
				code_text: '',
				token: '',
				simpleFlag: false, //是否展示简单版海报
				posterBgFlag: true, //是否展示海报背景图
				deliveryFlag: false,
			};
		},
		components: {
			hchPoster
		},
		props: {
			show_share: false,
			goodsInfo: {},
			posterObj: {}
		},
		watch: {
			show_share(newVal) {
				this.is_show = newVal
			}
		},
		updated() {
			this.token = uni.getStorageSync('token')
			this.code_text = uni.getStorageSync('userInfo').memberinfo_account
		},
		// 点击右上角的转发
		onShareAppMessage(options) {
			let that = this;
			return {
				title: that.goodsInfo.product_name,
				path: '/home/detail/Detail?scene=' + that.code_text+'&id='+that.goodsInfo.product_id,
				imageUrl: that.img_url + that.goodsInfo.product_image[0]
			}
		},
		methods: {
			// 取消
			Cancel() {
				this.is_show = false
				this.$emit('cancel', false)
			},
			// 生成海报有关
			handleShowPoster() {

			},
			closeShareEvn() {
				this.deliveryFlag = false
			},
			canvasCancel(val) {
				// this.canvasFlag = val
			},

			Change(index) {
				let that = this;
				if (this.token) {
					if (index === 1) {
						this.$refs.hchPoster.posterShow()
						this.deliveryFlag = false
					} else if (index === 2) {
						uni.setClipboardData({
							data: `复制汇帑口令，打开汇帑即可访问【${this.goodsInfo.product_name}】`,
							success: function() {
								that.$utils.Toast('请去微信粘贴给好友')
							}
						})
					}
				} else {
					uni.showModal({
						title:'提示',
						content:'请先登录',
						success(res) {
							if(res.confirm){
								that.$author.auth()
							}else{
								console.log('请先登录')
							}
						}
					})
				}

			},
			saveImgToLocal() {
				let that = this
				uni.downloadFile({
					url: this.img_url + this.goodsInfo.product_image[0],
					success: (res) => {
						if (res.statusCode === 200) {
							uni.saveImageToPhotosAlbum({
								filePath: res.tempFilePath,
								success: (res) => {
									that.$utils.Toast('保存成功')
									that.$emit('cancel', false)
								},
								fail: (err) => {
									that.$utils.Toast('保存失败')
									that.$emit('cancel', false)
									if (err.errMsg === 'saveImageToPhotosAlbum:fail auth deny') {
										uni.openSetting({
											success(set) {
												if (set.authSetting['scope.writePhotosAlbum']) {
													console.log('获取权限成功，给出再次点击图片保存到相册的提示。')
												} else {
													console.log('获取权限失败，给出不给权限就无法正常使用的提示')
												}
											}
										})
									}
								}
							})
						}
					}
				})
			}
		}
	};
</script>

<style lang="scss" scoped>
	.poster {

		/* 按钮去掉边框 */
		button::after {
			border: none;
		}

		button {
			margin-left: 0;
			margin-right: 0;
			padding-left: 0;
			padding-right: 0;
			line-height: 1;
			color: #1c1c1c;
			font-size: 28rpx;
			background: none;
		}

		.button-hover {
			color: #1c1c1c;
			background: none;
		}

		.poster-img {
			width: 40%;
		}

		/*每个页面公共css */
		.content {
			text-align: center;
			height: 100%;
		}

		.share-btn {
			padding: 30rpx 60rpx;
			background-color: #dbc291;
			color: #000000;
		}

		.share-pro {
			display: flex;
			align-items: center;
			justify-content: flex-end;
			flex-direction: column;
			z-index: 5;
			line-height: 1;
			box-sizing: border-box;

			.share-pro-mask {
				width: 100%;
				height: 100%;
				position: fixed;
				top: 0;
				right: 0;
				bottom: 0;
				left: 0;
				background: rgba(0, 0, 0, 0.5);
			}

			.share-pro-dialog {
				width: 750rpx;
				height: 310rpx;
				overflow: hidden;
				background-color: #fff;
				border-radius: 24rpx 24rpx 0px 0px;
				position: relative;
				box-sizing: border-box;
				position: fixed;
				bottom: 0;

				.close-btn {
					padding: 20rpx 15rpx;
					position: absolute;
					top: 0rpx;
					right: 29rpx;
				}

				.share-pro-title {
					font-size: 28rpx;
					color: #1c1c1c;
					padding: 28rpx 41rpx;
					background-color: #f7f7f7;
				}

				.share-pro-body {
					display: flex;
					flex-direction: row;
					justify-content: space-around;
					font-size: 28rpx;
					color: #1c1c1c;

					.share-item {
						display: flex;
						flex-direction: column;
						justify-content: center;
						justify-content: space-around;

						.share-icon {
							text-align: center;
							font-size: 70rpx;
							margin-top: 39rpx;
							margin-bottom: 16rpx;
							color: #42ae3c;
						}

						&:nth-child(2) {
							.share-icon {
								color: #ff5f33;
							}
						}
					}
				}
			}

			/* 显示或关闭内容时动画 */

			.open {
				transition: all 0.3s ease-out;
				transform: translateY(0);
			}

			.close {
				transition: all 0.3s ease-out;
				transform: translateY(310rpx);
			}
		}

		.canvas {
			position: fixed !important;
			top: 0 !important;
			left: 0 !important;
			display: block !important;
			width: 100% !important;
			height: 100% !important;
			z-index: 10;
		}

	}

	.content {
		position: fixed;
		top: 0;
		bottom: 0;
		width: 100%;
		background: rgba(0, 0, 0, 0.3);
		z-index: 100;

		.bottoms {
			position: fixed;
			bottom: 0;
			background: #FFFFFF;
			width: 100%;
			padding: 20rpx 0;

			.title {
				font-weight: bold;
				font-size: 30rpx;
			}

			.item {
				flex-direction: column;
				margin: 30rpx 0;
				flex: 1;
				line-height: 1;
				font-size: 30rpx;
				background: transparent;
				border: none;
				padding: 0;

				text:last-child {
					font-size: 28rpx;
					color: #666666;
				}
			}

			uni-button:after,
			button:after {
				border: none
			}

			.iconfont {
				width: 74rpx;
				height: 74rpx;
				line-height: 74rpx;
				background: #47d600;
				text-align: center;
				margin-bottom: 20rpx;
				font-size: 48rpx;
				color: #FFFFFF;
				border-radius: 50%;
			}

			.icon-iconfont19 {
				background: #4fc4e1;
			}

			.icon-kouling {
				background: #f9cc43;
			}

			.cancel {
				color: #000000;
				border-top: 1px solid #f1f1f1;
				padding-top: 20rpx;
				font-size: 30rpx;
			}
		}
	}
</style>
