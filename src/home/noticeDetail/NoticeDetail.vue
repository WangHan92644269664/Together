<template>
	<view class="notice lighter-icon">
		<view class="list u-f u-f-fdc">
			<view class="title">{{ data.announcement_title }}</view>
			<view class="time u-f">{{ data.announcement_add_datetime }}</view>
			<view class="content" v-html="data.announcement_content" @click="showImg(data.announcement_content)"></view>
		</view>
    <div class="imgDolg u-f u-f-ac u-f-jsc" v-if="imgPreview.show" @click.stop="imgPreview.show = false">
      <div class="img-box u-f u-f-ac u-f-jsc">
        <img @click.stop="imgPreview.show = false" :src="imgPreview.img" />
      </div>
    </div>
    <button class="btn-popup" @click="Share" hover-class="none" v-if="account && account.membermap && account.membermap.membermap_vip_level!==0">分享到</button>
    <uni-popup ref="popup" type="share">
      <uni-popup-share title="分享到" @select="select"></uni-popup-share>
    </uni-popup>
	</view>
</template>
<script>
  import Popup from '../../components/uni-popup/uni-popup.vue'
  import uniPopupShare from '../../components/uni-popup/uni-popup-share.vue'
	export default {
		name: "Notice",
		data() {
			return {
        data: '',
        id: '',
        imgPreview: {
          img: "",
          show:false
        },
        account: uni.getStorageSync('userInfo')
			};
		},
		onLoad (options) {
			this.getNotice(options.id)
      this.id = options.id
		},
    components:{
      Popup,
      uniPopupShare
    },
		methods: {
			async getNotice(id) {
				const res = await this.$api.getAccount({}, id)
				this.data = res.data
			},
       showImg(e) {
        if (e.indexOf('img')!==-1) {
          console.log(e.split('src="')[1].split(' style')[0].split('"')[0])
        }
        if (e.split('src="')[1].split(' style')[0].split('"')[0]) {
          const url = e.split('src="')[1].split(' style')[0].split('"')[0]
          this.imgPreview.img = url
          this.imgPreview.show = true
        }
      },
      Share () {
        this.$refs.popup.open()
      },
      select (e) {
        console.log(this.account)
        if (this.account) {
          const that = this
          // e.index: 0, 微信， 1：朋友圈， 2：复制链接  3：保存到本地
          if (e.index === 0 || e.index === 1) {
            console.log(window.cordova)
            console.log(`${process.env.VUE_APP_RECOMMEND_URL}#/home/noticeDetail/NoticeDetail?id=${that.id}`)
            if (window.cordova) {
              window.Wechat.share({
                message: {
                  title: that.data.announcement_title,
                  description: that.data.announcement_content,
                  thumb: that.imgPreview.img,
                  media: {
                    type: window.Wechat.Type.WEBPAGE,
                    webpageUrl: `${process.env.VUE_APP_RECOMMEND_URL}#/home/noticeDetail/NoticeDetail?id=${that.id}`
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
          }
        } else {
          uni.showModal({
            title: '提示',
            content: '请先注册之后才能分享',
            success(res) {
              if (res.confirm) {
                uni.navigateTo({
                  url: `../../other/register/Register?acc=${that.account.memberinfo_account}`
                })
              }
            }
          })
        }
      },
		},
	};
</script>
<style lang="scss" scoped>
  .imgDolg {
    height: 100vh;
    width: 100%;
    overflow-y: auto;
    position: fixed;
    z-index: 9999;
    background-color: rgba(140, 134, 134, 0.6);
    top: 0;
    left: 0;
    right: 0;
    img{
      width: 80%;
    }
  }
	.notice {
		background: #f7f8fa;
		min-height: 100vh;
		overflow: auto;
		.list {
			background: #fff;
			width: 94%;
			margin: 20rpx auto;
			border-radius: 0.1rem;
			padding: 30rpx;
			box-sizing: border-box;
			text-align: left;
			margin-bottom: 20rpx;
			.time{
				color: #999999;
				margin: 20rpx 0;
			}
			.title {
				color: #000;
				font-size: 34rpx;
				font-weight: bold;
			}

			/deep/ img {
				width: 200rpx!important;
				height: 200rpx!important;
				display: block!important;
				margin-bottom: 20rpx;
			}
			.content {
				color: #666;
				font-size: 30rpx;
			}
		}
	}
  .btn-popup{
    position: fixed;
    bottom: 0;
    background: #FFFFFF;
    border: none!important;
    border-radius: 0!important;
    height: 100rpx;
    width: 100%;
    font-size: 40rpx;
  }
  .btn-popup:after{
    border-radius: 0;
  }
</style>
