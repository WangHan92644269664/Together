<template>
	<view class="container" :style="{backgroundImage: 'url('+share_bg+')'}">
		<!-- <view class="first u-f u-f-jsb u-f-ac"> -->
			<!-- <image :src="code_avatar|getImg" mode="aspectFill"></image> -->
			<!--  #ifdef MP-WEIXIN || APP-PLUS -->
			<!-- <text @tap="Copy" class="background-text">复制分享码</text> -->
			<!--  #endif -->
			<!--  #ifdef H5 -->
			<!-- <button v-clipboard:copy="code_text" v-clipboard:success="Copy" class="background-text">复制分享码</button> -->
			<!--  #endif -->
		<!-- </view> -->
		<view class="code u-f u-f-jsc">
			<!--  #ifdef MP-WEIXIN -->
			<image :src="img_url+code_img" mode="widthFix"></image>
			<!--  #endif -->
			<!--  #ifdef APP-PLUS || H5 -->
			<tki-qrcode ref="qrcode"
			class="qrcode"
			:val="share_url"
			:icon="imgLogo"
			:size="size"
			:onval="onval"
			@result="Result"
			:loadMake="loadMake">
			</tki-qrcode>
			<!--  #endif -->
		</view>
		<!--  #ifdef MP-WEIXIN -->
		<button class="share" type="primary" open-type="share" hover-class="none">分享</button>
		<!--  #endif -->
		<!--  #ifdef APP-PLUS || H5 -->
		<button class="share" type="primary" @tap="saveCode" hover-class="none">分享</button>
		<!--  #endif -->
    <uni-popup ref="popup" type="share">
        <uni-popup-share title="分享到" @select="select"></uni-popup-share>
    </uni-popup>
    <!-- <hchPoster ref="hchPoster" :simpleFlag="true" :posterBgFlag="false" :canvasAttr.sync="canvasAttr" /> -->
	</view>
</template>
<script>
	import tkiQrcode from '../../components/tki-qrcode/tki-qrcode.vue'
  import Popup from '../../components/uni-popup/uni-popup.vue'
  import uniPopupShare from '../../components/uni-popup/uni-popup-share.vue'
  // import hchPoster from "@/components/hch-poster/hch-poster.vue"
	export default {
		data() {
			return {
				userInfo: uni.getStorageSync('userInfo'),
        share_bg: this.$utils.webImg2 + 'share_bg.jpg',
				img_url: this.$utils.imgUrl,
				code_img: '',
				share_url: `${process.env.VUE_APP_RECOMMEND_URL}#/other/register/Register?acc=${uni.getStorageSync('userInfo').memberinfo_account}`,
				code_avatar:uni.getStorageSync('userInfo').memberinfo_avatar_image,
				imgLogo: '',
				size: 280,
				loadMake: true,
				onval: true,
        resultImg: ''
        // canvasAttr:{
        //   marginLR: 40,
        //   marginTB: 40,
        //   radius: 0.03,
        //   fillColor: '#ffffff',
        //   innerLR: 20,
        //   innerTB: 20,
        //   posterRatio: 1.3,
        //   posterImgUrl: "https://www.baidu.com/img/flexible/logo/pc/result@2.png",
        //   title: "今日上新水果，牛奶草莓，颗粒饱满，每盒 200g",
        //   titleFontSize: 16,
        //   titleLineHeight: 25,
        //   posterCodeUrl: "https://www.baidu.com/img/flexible/logo/pc/result@2.png",
        //   codeWidth: 0.3,
        //   codeRatio: 1,
        //   codeRadius: 0.5,
        //   codeMT: 20,
        //   codeName: "记忆之王",
        //   codeNameMT: 20,
        //   tips: "长按/扫描识别查看商品",
        //   posterBgUrl:'https://www.baidu.com/img/flexible/logo/pc/result@2.png',
        //   codeML:140,
        //   desTextMT:70,
        //   desTextML:240,
        // }
			};
		},
		onLoad: function() {
			this.getCode()
			console.log(this.share_url)
			console.log(this.imgLogo)
		},
		components: {
			tkiQrcode,
      uniPopupShare,
      Popup
		},
		onShow() {
			// #ifdef MP-WEIXIN
			uni.showShareMenu()
			// #endif
		},
		onShareAppMessage(options) {
			let that = this;
			let shareObj = {
				title: '爱拼',
				path: '/pages/home/index?scene=' + that.userInfo.memberinfo_account
			}
			return shareObj
		},
		methods: {
			Result (e) {
        this.resultImg = e
			},
      select (e) {
        console.log(235)
        console.log(e)
        const that = this
        // e.index: 0, 微信， 1：朋友圈， 2：复制链接  3：保存到本地
        if (e.index === 0 || e.index === 1) {
          console.log(window.cordova)
          if (window.cordova) {
            window.Wechat.share({
              message: {
                title: '爱拼拼',
                description: '幸福爱拼拼，有米有你',
                thumb: 'https://img.210112.youtuosoft.com/mobile/logo.png',
                media: {
                  type: window.Wechat.Type.WEBPAGE,
                  webpageUrl: `${process.env.VUE_APP_RECOMMEND_URL}`
                }
              },
              scene: e.index === 0 ? window.Wechat.Scene.SESSION : window.Wechat.Scene.TIMELINE
            }, function () {
              uni.showToast({
                title: '分享成功'
              })
            }, function () {
              uni.showToast({
                title: '分享失败',
                icon: 'none'
              })
            })
          } else {
            uni.showToast({
              title: '请点击右上角进行分享',
              icon: 'none'
            })
          }
        } else if (e.index === 2) {
          uni.showToast({
            title: '复制成功'
          })
        } else if (e.index === 3) {
          
          this.$refs.qrcode._saveCode()
          // uni.saveImageToPhotosAlbum({
          //   filePath: that.resultImg,
          //   success: function () {
          //     that.$util.Toast('保存成功')
          //   }
          // })
        }
      },
			saveCode (e) {
        // membermap_vip_level 0 1vip 2svip  只有1和2的时候才可以分享
        this.$refs.popup.open()
			},
			Share () {
				console.log(345)
				uni.navigateTo({
					url: '../../other/register/Register?acc=' + this.userInfo.memberinfo_account
				})
			},
			Copy () {
				let that = this
				// #ifndef H5
				uni.setClipboardData({
					data: this.userInfo.memberinfo_account,
					success() {
						that.$utils.Toast('复制成功')
					}
				})
				// #endif
				// #ifdef MP-WEIXIN || H5
				that.$utils.Toast('复制成功')
				// #endif
			},
			async getCode() {
				uni.showLoading()
				// #ifdef MP-WEIXIN
				const res = await this.$api.getCode()
				if (res.data.success) {
					this.code_img = res.data.info
				}
				// #endif
				uni.hideLoading()
			}
		},

	};
</script>

<style lang="scss" scoped>
	.container {
		overflow: hidden;
		margin: 0 auto;
    min-height: 100%;
    background-size: 100% 100%;
    background-repeat: no-repeat;
		.first {
			margin: 50rpx 50rpx;
			background: #f5f5f5;
			font-size: 32rpx;
			border-radius: 60rpx;
			padding: 10rpx 20rpx;
			image{
				width: 100rpx;
				height: 100rpx;
				border-radius: 50%;
				margin-top: 0;
				margin-right: 20rpx;
			}

			.code{
				flex: 1;
				text-align: left;
			}

			text:last-child {
				color: #FFFFFF;
				border-radius: 60rpx;
				padding: 20rpx 30rpx;
			}
		}

		image {
			width: 400rpx;
			margin-top: 20%;
		}

		button.share {
			position: fixed;
			bottom: 0;
			background: #CFB47E;
      color: #FFFFFF;
			height: 90rpx;
			line-height: 90rpx;
			left: 0;
			right: 0;
			border-radius: 0;
			border: none;
			font-size: 34rpx;
		}
		button.background-text{
			background: #dbc291;
			height: 60rpx;
			border: none;
			line-height: 60rpx;
			font-size: 20rpx;
			border-radius: 40rpx;
			color: #FFFFFF;
		}
	}
	.code{
		background: url(../../static/user/share_qr_bg.png);
		background-size: 100% 100%;
		background-repeat: no-repeat;
		position: fixed;
		bottom: 300rpx;
		width: 400rpx;
		height: 400rpx;
		padding-top: 9.2%;
		margin-left: 25%;
		box-sizing: border-box;
	}
</style>
