<template>
	<view class="info-box lighter-icon">
		<view class="contents">
			<view class="item u-f u-f-jsb u-f-ac" v-for="(item,index) in lists" :key="index">
				<text>{{item.name}}</text>
				<view class="right u-f u-f-ac">
					<template v-if="item.name==='姓名'">
						<input type="text" v-model="item.value">
					</template>
					<template v-if="item.name==='手机号码'">
						<input type="text" v-model="item.value">
					</template>
					<!-- 性别 -->
					<picker @change="bindPickerChange" :value="index" :range="array" v-else-if="item.name==='性别'" mode="selector">
						{{item.value}}
					</picker>
					<!-- 生日 -->
					<picker class="date" @change="bindDateChange" :value="date" :start="startDate" :end="endDate" v-else-if="item.name==='生日'" mode="date">
						{{date}}
					</picker>
					<template v-else>
						<text v-if="!item.isedit">{{item.value}}</text>
					</template>
          <template v-if="item.imgUrl">
            <img :src="avatar" @tap="uploadImg('avatar')" v-if="item.type==='avatar'">
            <img :src="alipay" @tap="uploadImg('alipay')" v-if="item.type==='alipay'">
            <img :src="wx" @tap="uploadImg('wx')" v-if="item.type==='wx'">
          </template>
					<text class="iconfont icon-arrow-right" v-if="item.isedit||item.imgUrl"></text>
				</view>
			</view>
		</view>
		<button class="mix-btn u-f u-f-jsc" @click="Confirm">保存</button>
	</view>
</template>

<script>
	import {
		pathToBase64,
		base64ToPath
	} from '@/common/js/image-base64.js'
	export default {
		data() {
			const currentDate = this.getDate({
				format: true
			})

			return {
				avatar: '',
				userInfo: '',
				focu: false,
				lists: [{
						name: '头像',
						value: '',
						imgUrl: true,
            type: 'avatar'
					},
					{
						name: '登录账号',
						value: ''
					},
					{
						name: '手机号码',
						value: ''
					},
					{
						name: '姓名',
						value: '',
						isedit: 'true'
					},
					{
						name: '性别',
						value: '',
						isedit: 'true',
					},
					{
						name: '生日',
						value: '',
						isedit: 'true',
					},
					{
						name: '推荐人',
						value: ''
					},
          {
            name: '支付宝收款码',
            value: '',
            imgUrl: true,
            type: 'alipay'
          },
          {
            name: '微信收款码',
            value: '',
            imgUrl: true,
            type: 'wx'
          },
				],
				array: ['男', '女'],
				index: 0, //性别所选中的
				date: currentDate,
				recom_avatar:'',
				mobile_url: this.$utils.webImg2,
        alipay: '',
        wx: ''
			};
		},
		components: {},
		onLoad() {
			this.getUserInfo()
		},
		computed: {
			startDate() {
				return this.getDate('start')
			},
			endDate() {
				return this.getDate('end')
			}
		},

		methods: {
			// 绑定性别改变
			bindPickerChange(e) {
				console.log(e)
				this.index = e.target.value
				this.lists[4].value = this.array[e.target.value]
				console.log(this.lists[4].value)
			},
			// 绑定日期改变
			bindDateChange(e) {
				this.date = e.target.value
				console.log(this.date)
			},
			// 格式化日期
			getDate(type) {
				const date = new Date();
				let year = date.getFullYear();
				let month = date.getMonth() + 1;
				let day = date.getDate();
				if (type === 'start') {
					year = year - 60;
				} else if (type === 'end') {
					year = year + 2
				}
				month = month > 9 ? month : '0' + month
				day = day > 9 ? day : '0' + day
				return `${year}-${month}-${day}`
			},

			// 获取会员信息
			async getUserInfo() {
				const res = await this.$api.getMemberView()
				this.lists[1].value = res.data.memberinfo_account
				this.lists[2].value = res.data.memberinfo_mobile
				console.log(this.lists[3].value)
				this.lists[3].value = res.data.memberinfo_realname ? res.data.memberinfo_realname : '未填'
				this.lists[4].value=res.data.memberinfo_sex?res.data.memberinfo_sex:'未知'
				this.date=res.data.memberinfo_birthday?res.data.memberinfo_birthday:'请选择'
				this.lists[6].value = res.data.memberinfo_recommend_account ? res.data.memberinfo_recommend_account :
					'root'
				this.userInfo = res.data;
				if (this.userInfo) {
					let avatar = this.userInfo.memberinfo_avatar_image
          const alipay = this.userInfo.memberinfo_alipay_image
          const wx = this.userInfo.memberinfo_wechat_image
					// #ifdef MP-WEIXIN
					if (avatar.indexOf('https') !== -1) {
						this.avatar = avatar
					} else {
						this.avatar = this.$utils.imgUrl + 'avatar/' +avatar 
					}
					// #endif
					// #ifdef APP-PLUS || H5
					if (avatar) {
						this.avatar = this.$utils.imgUrl + 'avatar/' + avatar
					} else {
						this.avatar = `${this.mobile_url}logo.png`
					}
          if (alipay) {
            this.alipay = this.$utils.imgUrl + 'avatar/' + alipay
          }
          if (wx) {
            this.wx = this.$utils.imgUrl + 'avatar/' + wx
          }
					// #endif
				}
			},
			//确认修改
			Confirm() {
				let data = {
					'memberinfo_realname': this.lists[3].value === '未填' ? '' : this.lists[3].value,
          'memberinfo_sex': this.lists[4].value === '未知' ? '' : this.lists[4].value,
          'memberinfo_birthday': this.date === '请选择' ? '' :this.date
				}
				if (this.avatar) {
					pathToBase64(this.avatar).then(base64 => {
						data['memberinfo_avatar_image'] = base64
            console.log(base64)
            this.UpdateMy(data)
					})
				}
        if (this.alipay) {
          pathToBase64(this.alipay).then(base64 => {
          	data['memberinfo_alipay_image'] = base64
            this.UpdateMy(data)
          })
        }
        if (this.wx) {
          pathToBase64(this.wx).then(base64 => {
          	data['memberinfo_wechat_image'] = base64
            this.UpdateMy(data)
          })
        }
        console.log(data)
			},
			UpdateMy(data){
				this.$api.putUpdateMy(data).then(res => {
					if (res.data.success) {
						this.$store.state.is_error = false
						uni.setStorageSync('userInfo', res.data.info)
						this.$utils.Toast('修改成功', 'success')
						setTimeout(() => {
							uni.navigateBack({
							  delta: 1
							})
						}, 1000)
					} else {
						this.$utils.Toast(res.data.message, 'none')
					}
				})
			},
			// 上传图片,转化为base64
			uploadImg(e) {
				let that = this
				uni.chooseImage({
					count: 1, //默认9
					sourceType: ['album'], //从相册选择
					success: function(res) {
            if (e === 'avatar') {
              that.avatar = res.tempFilePaths[0]
            } else if (e === 'alipay') {
              that.alipay = res.tempFilePaths[0]
              console.log(res)
            } else {
              that.wx = res.tempFilePaths[0]
            }
					}
				})
			}
		},
	}
</script>

<style lang='scss' scoped>
	.date {
		position: relative;
		top: 8rpx;
	}
	.info-box {
		background: #f5f5f5;
		min-height: 100vh;
		.contents{
			background: #ffffff;
			padding: 0 30rpx;
		}

		img {
			width: 100rpx;
			height: 100rpx;
			border-radius: 100%;
		}

		.item {
			padding: 30rpx 0;
			color: #444444;
			font-size: 30rpx;
			border-bottom: 1px solid #f5f5f5;
			>text{
				color: #000000;
			}

			.right {
				color: #999999;

				input {
					text-align: right;
					font-size: 28rpx;
				}
				.icon-arrow-right{
					font-size: 28rpx;
					color: #777777;
				}
			}
		}
	}
	picker{
		font-size: 28rpx;
	}

	.par {
		padding-right: 30rpx;
		font-size: 30rpx;
	}
	.mix-btn{
		height: 80rpx;
		line-height: 80rpx;
		font-size: 30rpx;
		width: 90%;
		background: #CFB47E;
		margin: 50rpx auto;
		border-radius: 0;
	}
</style>
