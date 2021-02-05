<template>
	<view class="info-box lighter-icon">
		<view class="contents">
			<view class="item u-f u-f-jsb u-f-ac" v-for="(item, index) in lists" :key="index" @tap="Go(item.url)">
				<text>{{ item.name }}</text>
				<view class="right u-f u-f-ac">
					<text v-if="item.value">{{ item.value }}</text>
					<text class="iconfont icon-arrow-right" v-if="item.url"></text>
				</view>
			</view>
		</view>
		<text class="btn u-f u-f-jsc" @tap="Logout">退出登录</text>
	</view>
</template>

<script>
	export default {
		data() {
			return {
				wain: false,
				name: "",
				phone: "",
				email: "",
				radio: null,
				url: this.$utils.url_api,
				token: uni.getStorageSync("token"),
				imgUrl: this.$utils.imgUrl,
				userInfo: "",
				lists: [{
						name: "个人资料",
						url: "../info/Info",
					}, {
						name: "银行卡管理",
						url: "../bank/Bank",
					},
					// {
					// 	name: "修改手机号",
					// 	value: "",
					// 	url: "../updatePhone/updatePhone",
					// },
					{
						name: "修改密码",
						url: "../pwd/Pwd?type=2",
					},
					{
						name: "邀请好友",
						url: "../code/Code",
					},
					// #ifdef MP-WEIXIN
					{
						name: "检查更新",
						url: "",
					},
					// #endif
				],
			};
		},
		computed: {},
		onLoad() {
			this.getUserInfo();
		},
		onShow() {},
		mounted() {},
		// 监听返回键
		onUnload: function() {
			//相当于监听返回按钮
			uni.switchTab({
				url:'/pages/center/index'
			})
		},
		methods: {
			radioChange: function(e) {
				let value = e.detail.value;
				this.radio = value;
			},
			Go(url) {
        if (url === '../code/Code') {
          console.log(this.userInfo)
          if (this.userInfo.membermap.membermap_vip_level === 0){
            return this.$utils.Toast('拼团之后才可以分享')
          }
        }
				if (url) {
					uni.navigateTo({
						url: url
					})
				} else {
					const that = this
					const updateManager = uni.getUpdateManager()
					// 检查更新
					updateManager.onCheckForUpdate(function (res) {
					  // 请求完新版本信息的回调
					  console.log('是否有新版本', res.hasUpdate)
						if (!res.hasUpdate) {
							that.$utils.Toast('已经是最新版本!')
						} else {
							// 当新版本下载完成
							updateManager.onUpdateReady(function (res) {
							  uni.showModal({
							    title: '更新提示',
							    content: '新版本已经准备好，是否重启应用？',
							    success(res) {
							      if (res.confirm) {
							        // 新的版本已经下载好，调用 applyUpdate 应用新版本并重启
							        updateManager.applyUpdate();
							      }
							    }
							  })
							});
							// 当新版本下载失败
							updateManager.onUpdateFailed(function (res) {
							  // 新的版本下载失败
								console.log('更新失败:', res)
							});
						}
					})
				}
			},
			// 获取个人资料
			async getUserInfo() {
				const res = await this.$api.getUserInfo();
				// this.lists[2].value = res.data.info.memberinfo_mobile ?
				// 	res.data.info.memberinfo_mobile :
				// 	"未填";
				this.userInfo = res.data
			},
			// 退出登录
			Logout() {
				let that = this;
				uni.showModal({
					title: '提示',
					content: '确定退出吗?',
					success(result) {
						if (result.confirm) {
							that.$api.getLogout().then(res => {
								if (res.data.success) {
									uni.clearStorage();
									that.$author.auth()
								}
							})

						} else {
							console.log('取消')
						}
					}
				})
			},
		},
	};
</script>

<style lang="scss">
	.info-box {
		background: #f5f5f5;
		height: 100vh;

		.contents {
			background: #ffffff;
			padding: 0 30rpx;

			.icon-arrow-right {
				color: #AAAAAA;
			}
		}

		.top {
			padding: 20rpx 0;
			border-bottom: 1px solid #eeeeee;

			image {
				width: 100rpx;
				height: 100rpx;
				border-radius: 100%;
			}

			.account {
				flex: 1;
				flex-direction: column;
				margin-left: 20rpx;

				text:last-child {
					color: #999999;
					font-size: 30rpx;
					margin-top: 10rpx;
					width: 100%;
				}
			}
		}

		.item {
			padding: 30rpx 0;
			border-bottom: 1px solid #f5f5f5;
			font-size: 30rpx;

			text:first-child {
				color: #666666;
			}
		}
	}

	.btn {
		background: #FFFFFF;
		margin: 50rpx auto;
		width: 90%;
		color: #000000;
		font-size: 30rpx;
		padding: 20rpx 0;
	}
</style>




































>>>>>>> .theirs
