<template>
	<view class="uni-popup-share">
		<view class="uni-share-title"><text class="uni-share-title-text">{{title}}</text></view>
		<view class="uni-share-content">
			<view class="uni-share-content-box">
				<view class="uni-share-content-item u-f u-f-fdc u-f-ac u-f-jsa" v-for="(item,index) in bottomData" :key="index" @click.stop="select(item,index)">
          <template v-if="index === 2">
            <button type="button" class="code" v-if="!account">
              <image class="uni-share-image" :src="item.icon" mode="aspectFill"></image>
              <text class="uni-share-text">{{item.text}}</text>
             </button>
            <button v-else type="button" class="code" v-clipboard:copy="share_url" v-clipboard:success="onCopy">
              <image class="uni-share-image" :src="item.icon" mode="aspectFill"></image>
              <text class="uni-share-text">{{item.text}}</text>
             </button>
          </template>
          <template v-else>
            <image class="uni-share-image" :src="item.icon" mode="aspectFill"></image>
            <text class="uni-share-text">{{item.text}}</text>
          </template>
				</view>
			</view>
		</view>
		<view class="uni-share-button-box">
			<button class="uni-share-button" @click="close">取消</button>
		</view>
	</view>
</template>

<script>
  import Vue from 'vue'
  import VueClipboard from 'vue-clipboard2'
  Vue.use(VueClipboard)
	export default {
		name: 'UniPopupShare',
		props: {
			title: {
				type: String,
				default: '分享到'
			}
		},
		inject: ['popup'],
    components: {
      VueClipboard
    },
		data() {
			return {
        share_url: `${process.env.VUE_APP_RECOMMEND_URL}#/other/register/Register?acc=${uni.getStorageSync('userInfo').memberinfo_account}`,
				bottomData: [{
						text: '微信好友',
						icon: this.$utils.webImg2+'wx.png',
						name: 'wx'
					},
					{
						text: '朋友圈',
						icon: this.$utils.webImg2+'pyq.png',
						name: 'wx'
					},
					{
						text: '复制链接',
						icon: this.$utils.webImg2+'code.png',
						name: 'link'
					}
				],
        account: uni.getStorageSync('userInfo')
			}
		},
		created() {},
		methods: {
			/**
			 * 选择内容
			 */
      // select (e) {
      //   console.log(e)
      //   const that = this
      //   // e.index: 0, 微信， 1：朋友圈， 2：复制链接  3：保存到本地
      //   if (e.index === 0 || e.index === 1) {
      //     console.log(window.cordova)
      //     if (window.cordova) {
      //       window.Wechat.share({
      //         message: {
      //           title: '爱拼拼',
      //           description: '幸福爱拼拼，有米有你',
      //           thumb: 'https://img.210112.youtuosoft.com/mobile/logo.png',
      //           media: {
      //             type: window.Wechat.Type.WEBPAGE,
      //             webpageUrl: `${process.env.VUE_APP_RECOMMEND_URL}`
      //           }
      //         },
      //         scene: e.index === 0 ? window.Wechat.Scene.SESSION : window.Wechat.Scene.TIMELINE
      //       }, function () {
      //         uni.showToast({
      //           title: '分享成功'
      //         })
      //       }, function () {
      //         uni.showToast({
      //           title: '分享失败',
      //           icon: 'none'
      //         })
      //       })
      //     } else {
      //       uni.showToast({
      //         title: '请点击右上角进行分享',
      //         icon: 'none'
      //       })
      //     }
      //   } else if (e.index === 2) {
      //     uni.showToast({
      //       title: '复制成功'
      //     })
      //   }
      // },
      // app中分享
      appShare (index) {
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
          scene: index === 0 ? window.Wechat.Scene.SESSION : window.Wechat.Scene.TIMELINE
        }, function () {
          uni.showToast({title: '分享成功'})
        }, function () {
          uni.showToast({title: '分享失败', icon: 'none'})
        })
      },
      // 微信公众号分享
      async wxPublicShare () {
        const data = {
          url: window.location.href
        }
        const res = await this.$api.getWeixinConfig(data)
        consoel.log(res)
        window.wx.config({
          debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
          appId: res.info.appId, // 必填，公众号的唯一标识
          timestamp: res.info.timestamp, // 必填，生成签名的时间戳
          nonceStr: res.info.nonceStr, // 必填，生成签名的随机串
          signature: res.info.signature, // 必填，签名
          jsApiList: ['updateAppMessageShareData', 'updateTimelineShareData', 'onMenuShareTimeline', 'onMenuShareAppMessage'] // 必填，需要使用的JS接口列表
        })
        // 检测api是否注入
        window.wx.checkJsApi({
          jsApiList: ['updateAppMessageShareData', 'updateTimelineShareData'],
          success: function (res) {
            window.wx.ready(function () {
              window.wx.updateAppMessageShareData({
                title: '爱拼拼', // 分享标题
                desc: '', // 分享描述
                link: '', // 分享链接，该链接域名或路径必须与当前页面对应的公众号JS安全域名一致
                imgUrl: '',
                success: function () {
                  uni.showModal({
                    title: '提示',
                    content: '点击右上角【 … 】进行分享',
                    success(res) {
                      console.log(res)
                    }
                  })
                }
              })
            })
          }
        })
      },
      // 选择哪种方式
			select(item, index) {
        // e.index: 0, 微信， 1：朋友圈， 2：复制链接 
        // if (index === 0 || index === 1) {
        //   if (window.cordova) {
        //     this.appShare(index)
        //   } else if (this.$utils.isWeixin()) {
        //     this.wxPublicShare()
        //   } else {
        //     uni.showToast({title: 'H5中不支持分享', icon: 'none'})
        //   }
        // } else if (index === 2) {
        //   uni.showToast({title: '复制成功'})
        // }
				this.$emit('select', {
					item,
					index
				}, () => {
					this.popup.close()
				})
			},
			/**
			 * 关闭窗口
			 */
			close() {
				this.popup.close()
			},
      onCopy: function (e) {
        uni.showToast({
          title: '复制成功'
        })
      }
		}
	}
</script>
<style lang="scss" scoped>
	.uni-popup-share {
		background-color: #fff;
	}
  .code{
    background: transparent;
    margin: 0;
    padding: 0;
    position: relative;
    top: 10rpx;
    display: flex;
    flex-direction: column;
    text-align: center;
    justify-content: center;
    image{
      margin: 0 auto;
    }
  }
  .code::after{
    border: none;
  }
	.uni-share-title {
		/* #ifndef APP-NVUE */
		display: flex;
		/* #endif */
		flex-direction: row;
		align-items: center;
		justify-content: center;
		height: 40px;
	}
	.uni-share-title-text {
		font-size: 14px;
		color: #666;
	}
	.uni-share-content {
		/* #ifndef APP-NVUE */
		display: flex;
		/* #endif */
		flex-direction: row;
		justify-content: center;
		padding: 10px 0;
	}
	
	.uni-share-content-box {
		/* #ifndef APP-NVUE */
		display: flex;
		/* #endif */
		flex-direction: row;
		flex-wrap: wrap;
		width: 360px;
	}
	
	.uni-share-content-item {
		padding: 10px 0;
    flex: 1;
	}
	
	.uni-share-content-item:active {
		background-color: #f5f5f5;
	}
	
	.uni-share-image {
		width: 26px;
		height: 26px;
	}
	
	.uni-share-text {
		margin-top: 10px;
		font-size: 14px;
		color: #3B4144;
	}
  .icon-weixin1{
    color: #00e200;
  }
	
	.uni-share-button-box {
		/* #ifndef APP-NVUE */
		display: flex;
		/* #endif */
		flex-direction: row;
		padding: 10px 15px;
	}
	
	.uni-share-button {
		flex: 1;
		border-radius: 50px;
		color: #666;
		font-size: 16px;
	}
	
	.uni-share-button::after {
		border-radius: 50px;
	}
</style>
