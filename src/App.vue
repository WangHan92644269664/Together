
<script>
	import Vue from 'vue';
	import axios from 'axios'
	export default {
		onLaunch: function(options) {
			this.setAppInfo()
			this.getConfigs()
      // this.Init()
		},
		onShow: function(options) {
			this.$utils.Toast(options)
      if (window.cordova) {
        this.Init()
      }
		},
		methods: {
      Init () {
        document.addEventListener('resume', this.onResume, false)
        this.onDeviceReady()
      },
      onResume () {
        this.onDeviceReady()
      },
			onDeviceReady () {
				const that = this
				axios.get(`${process.env.VUE_APP_RECOMMEND_URL}version.json`).then(res => {
					const version = res.data.APP_VERSION
					console.log('version:', process.env.VUE_APP_VERSION)
					const appVersion = process.env.VUE_APP_VERSION
					console.log(version, appVersion)
					console.log(version !== appVersion)
					// 后台进程杀掉之后才能检测到大版本的更改
					if (version.split('.')[0] !== appVersion.split('.')[0]) {
						navigator.notification.confirm(
							'有新版本改变，是否需要重新安装?',
							that.onUpdate,
							'应用更新!',
							['确定', '取消']
						)
					} else if (version !== appVersion) {
						// 每次从后台进入前台的时候都会执行
						console.log(444444)
						codePush.sync(that.syncStatus, {
							installMode: 2,
							mandatoryInstallMode: 2,
							minimumBackgroundDuration: process.env.NODE_ENV === 'production' ? 300 : 10 // 产品模式切入后台超过5分钟以上才强制安装，开发模式是10秒
						})
					}
				})
			},
			onUpdate (buttonIndex) {
				if (buttonIndex === 1) {
					// eslint-disable-next-line no-undef
					cordova.InAppBrowser.open(`${process.env.VUE_APP_RECOMMEND_URL}#/other/register/Download`, '_system')
				}
			},
			syncStatus (status) {
				const that = this
				switch (status) {
					case 1:
						break
				}
			},
			async getConfigs () {
				const res = await this.$api.getConfig()
				uni.setStorageSync('notConfigs', res.data)
			},
			// 获取系统栏高度
			setAppInfo() {
				let platform = '';
				uni.getSystemInfo({
					success: function(e) {
						Vue.prototype.StatusBar = e.statusBarHeight;
						// #ifdef H5
						Vue.prototype.CustomBar = e.statusBarHeight + 45;
						// #endif
						// #ifdef APP-PLUS
						platform = 'App';
						if (e.platform == 'android') {
							uni.setStorageSync('isAndroid', true);
							Vue.prototype.CustomBar = e.statusBarHeight + 50;
						} else {
							Vue.prototype.CustomBar = e.statusBarHeight + 45;
							uni.setStorageSync('isAndroid', false);
						}
						// #endif

						// #ifdef MP-WEIXIN
						platform = 'wxMiniProgram';
						let custom = wx.getMenuButtonBoundingClientRect();
						Vue.prototype.Custom = custom;
						Vue.prototype.CustomBar = custom.bottom + custom.top - e.statusBarHeight;
						// #endif
					}
				});
				uni.setStorageSync('platform', platform);
			},
		}
	}
</script>

<style lang="scss">
	/*每个页面公共css */
	@import "./common/css/uni.css";
	@import "./common/css/common.css";
	@import "./common/css/icon.css";
	@import "./common/css/mixin.scss";
	// @import "./common/css/lighter.css";

	.lighter-icon {
		font-family: DIN Condensed !important;
		font-size: 30rpx;
	}

	.noticeBox img {
		width: 100% !important;
	}

	.home-detail .content {
		img {
			max-width: 100% !important;
		}
	}

	page {
		-webkit-overflow-scrolling: touch; //ios滑动不流畅
		height: 100%;
	}

	// 滚动条
	::-webkit-scrollbar {
		width: 0;
		height: 0;
		color: transparent;
		display: none;
	}
</style>

















































>>>>>>> .theirs
