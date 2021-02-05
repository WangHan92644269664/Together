<template>
	<view class="box lighter-icon">
			<view class="logo u-f u-f-jsc">
				<image :src="img_url + 'logo.png'" mode="widthFix"></image>
				<text>爱拼</text>
			</view>
			<view class="box-down">
				<a href="/together.apk" download="爱拼.apk" 
				class="per-btn flex flex-item-center flex-justify-center" v-if="isAndroid"
				><text class="icon-anzhuo iconfont"></text>安卓下载</a>
				<a :href="ios_downlink" class="per-btn flex flex-item-center flex-justify-center"
						@click="getApp" v-if="isClick==='false' && isIos">
						<text class="icon-pingguo iconfont"></text>苹果下载
				</a>
			</view>
			<text class="font-grey version">版本号:{{ version }}</text>
			<view class="infos u-f" v-if="isClick==='true' && isIos">
				<text class="active">1. 正在安装，请按 Home 键在桌面查看</text>
				<text class="active">2. 安装进度完成之后，如果是首次安装点击下方的【安装证书】按钮，在出现的对话框中点击【允许】</text>
				<button class="btn flex flex-item-center flex-justify-center cer background-text" @click="Cer">
					<text class="iconfont icon-pingguo"></text>安装证书
				</button>
			</view>
	</view>
</template>
<script>
	import axios from 'axios'
	export default {
		data() {
			return {
				img_url: this.$utils.webImg2,
				ios_downlink: `itms-services://?action=download-manifest&url=${process.env.VUE_APP_RECOMMEND_URL}together.plist`,
				version: '1.0.0', // 版本号
				isWeixin: this.$utils.isWeixin(),
				isClick: uni.getStorageSync('isClick'),
				isIos: this.$utils.isIos(),
				url: `${process.env.VUE_APP_RECOMMEND_URL}together.mobileprovision`,
				isAndroid: this.$utils.isAndroid(),
				isLoading: false,
				cer_href: `${process.env.VUE_APP_RECOMMEND_URL}together.mobileprovision`
			};
		},
		onShow (options) {
			
		},
		beforeCreate () {
			uni.setStorageSync('isClick', 'false')
		},
		onLoad () {
			axios.get(`${process.env.VUE_APP_RECOMMEND_URL}version.json`).then(res => {
				this.version = res.data.APP_VERSION
			})
		},
		methods: {
			getApp () {
				this.isLoading = true
				uni.showLoading({
					title: '加载中...'
				})
				setTimeout(() => {
					this.isClick = 'true'
					this.isLoading = false
					uni.setStorageSync('isClick', 'true')
					uni.hideLoading()
				}, 5000)
			},
			Cer () {
				const that = this
				uni.showModal({
					title: '提示',
					content: '请确认是否下载完成?',
					success(result) {
						if (result.confirm) {
							const a = document.createElement('a')
							a.setAttribute('href', that.cer_href)
							a.setAttribute('id', 'startTel')
							if (document.getElementById('startTel')) {
								document.body.removeChild(document.getElementById('startTel'))
							}
							document.body.appendChild(a)
							a.click()
						} else {
							console.log('取消')
						}
					}
				})
			},
			Load () {
				const blobUrl = new Blob([], { type: 'application/zip' })
				console.log(blobUrl.size)
				const a = document.createElement('a')
				const url = window.URL.createObjectURL(blobUrl)
				a.href = url
				a.download = '采访稿'
				a.click()
				window.URL.revokeObjectURL(url)
			}
		}
	};
</script>

<style lang="scss" scoped>
	.box {
		background: #CCB17C;
		box-sizing: border-box;
		color: #FFFFFF;
		min-height: 100vh;
		overflow: hidden;
		text-align: center;
		.logo{
			flex-direction: column;
			margin: 100rpx auto 150rpx;
			image{
				width: 150rpx;
				height: 150rpx;
				margin: 30rpx auto;
			}
		}
		.version{
			margin-top: 20rpx;
			display: block;
		}
		a{
			color: #CFB47E;
			background: #FFFFFF;
			font-size: 32rpx;
			width: 36%;
			margin: 0 auto 20rpx;
			padding: 20rpx 0;
			border-radius: 60rpx;
			text-decoration: none;
			display: block;
			.iconfont{
				margin-right: 10rpx;
				font-size: 40rpx;
			}
		}
	}
	.infos{
		flex-direction: column;
		text-align: left;
		font-size: 28rpx;
		padding: 20rpx 50rpx;
	}
	.cer{
		background: #FFFFFF;
		margin-top: 50rpx;
		font-size: 30rpx;
		border-radius: 40rpx;
		height: 70rpx;
		line-height: 70rpx;
		color: #CFB47E;
		.iconfont{
			font-size: 40rpx;
			margin-right: 10rpx;
		}
	}
</style>
