<template>
	<view>
		<view class="content lighter-icon">
			<form @submit="formSubmit">
				<view class="uni-form-item uni-column">
					<view class="title">收件人</view>
					<input class="uni-input" focus name="address_realname" placeholder="请输入收件人" placeholder-class="pla" :class="{'font-red': errorIndex === 0}" @blur="Input(form)" v-model="form.address_realname"/>
				</view>
				<view class="uni-form-item uni-column">
					<view class="title">手机号码</view>
					<input class="uni-input" name="address_mobile" maxlength="11" placeholder="请输入手机号码" placeholder-class="pla" :class="{'font-red': errorIndex === 1}" @blur="Input(form)" v-model="form.address_mobile"/>
				</view>
				<view class="uni-form-item uni-column">
					<view class="title">所在地区</view>
					<view class="uni-input" @tap="openPicker()" :class="{'font-red': errorIndex === 2, 'pla': !form.address_provience, 'font-text': form.address_provience}">
						<template v-if="editType==='edit'">
							{{form.address_provience|getAreaName}} - {{form.address_area|getAreaName}} - {{form.address_county|getAreaName}}
						</template>
						<template v-else>{{ region }}</template>
					</view>
				</view>
				<view class="uni-form-item uni-column">
					<view class="title">详细地址</view>
					<input class="uni-input" name="address_detail" placeholder="请输入详细地址" placeholder-class="pla" :class="{'font-red': errorIndex === 3}" @blur="Input(form)" v-model="form.address_detail"/>
				</view>
				<view class="switch u-f u-f-jsb u-f-ac">
					<text class="font-text">设置默认地址</text>
					<switch color="#E0BF6A" :checked="isDefault" @change="isDefaultChange" style="transform: scale(0.7);" />
				</view>
				<view class="uni-btn-v">
					<button form-type="submit" class="btn background-text" v-if="editType !== 'edit'">保存地址</button>
					<template v-else>
						<button form-type="submit" class="btn background-text">修改地址</button>
						<button class="btn background-text del" @tap="del">删除收货地址</button>
					</template>
				</view>
			</form>
		</view>
		<simple-address v-on:choseVal="choseValue" :lotusAddressData="lotusAddressData"></simple-address>
	</view>
</template>

<script>
	import simpleAddress from "@/components/simpleAddress/simpleAddress.vue";
	import graceChecker from '../../common/js/check.js'
	export default {
		components: {
			simpleAddress,
		},
		data() {
			return {
				editType: "edit",
				id: "",
				form: {
					address_realname: '',
					address_mobile: '',
					address_detail: '',
					address_is_default: 1,
					address_account: uni.getStorageSync('userInfo').memberinfo_account,
					address_provience: '',
					address_area: '',
					address_county: ''
				},
				errorIndex: '',
				rule: [
					{name:"address_realname", checkType: "notnull", errorMsg:"收件人不能为空"},
					{name:"address_mobile", checkType: "phoneno", errorMsg:"手机号码不正确"},
					{name:"address_detail", checkType: "notnull", errorMsg:"详细地址不能为空"}
				],
				// 收件人
				name: "",
				reg_name: "",
				tip_name: "",
				// 手机号
				tel: "",
				reg_tel: "",
				tip_tel: "",
				// 详细地址
				detailed: "",
				reg_detailed: "",
				tip_detailed: "",
				isDefault: true,
				themeColor: "#007AFF",
				// region:{label:"请点击选择地址",value:[],cityCode:""},
				address: null,
				lotusAddressData: {
					visible: false,
					provinceName: "",
					cityName: "",
					townName: "",
				},
				region: "请选择省市区",
				regionTown: "选择街道（乡镇）",
				townList: [],
				townIndex: 0,
				addAddress: null,
				account: uni.getStorageSync('userInfo').memberinfo_account,
				type: '',
				is_order: '' // 从订单过来的
			};
		},
		mounted() {},
		async onLoad(e) {
			//获取传递过来的参数
			let id = e.id;
			this.type = e.type
			if (e.is_order) {
				this.is_order = e.is_order
			}
			if (e.id) {
				this.id = id
				this.editType = "edit"
				this.getAdd(e.id)
			} else {
				this.editType = "add"
				uni.setNavigationBarTitle({
					title: "新增收货地址",
				})
			}
		},
		methods: {
			async getAdd (id) {
				const res = await this.$api.getAddresses1(id)
				this.isDefault = res.data.address_is_default === 1
				this.form = res.data
			},
			// 失去焦点触发
			Input (form) {
				var checkRes = graceChecker.check(form, this.rule);
				if(checkRes) {
					this.errorIndex = ''
				} else {
					this.Check(graceChecker.error)
				}
			},
			// 表单验证
			Check (err) {
				if (err === '收件人不能为空') {
					this.errorIndex = 0
				} else if (err === '手机号码不正确') {
					this.errorIndex = 1
				} else if (err === '详细地址不能为空') {
					this.errorIndex = 3
				}
				uni.showToast({ title: err, icon: "none" })
			},
			// 提交时候触发
			formSubmit (e) {
				//进行表单检查
				var formData = e.detail.value;
				var checkRes = graceChecker.check(formData, this.rule);
				if(checkRes) {
					if (!this.form.address_provience) {
						this.errorIndex = 2
						return this.$utils.Toast("请先选择地区")
					} else {
						this.errorIndex = ''
						this.save()
					}
				} else {
					this.Check(graceChecker.error)
				}
			},
			// 地区操作
			choseValue (res) {
				console.log(234)
				console.log(res)
				//res数据源包括已选省市区与省市区code
				this.lotusAddressData.visible = res.visible; //visible为显示与关闭组件标识true显示false隐藏
				if (res.province && res.province.area_name) {
					this.region = `${res.province.area_name}-${res.city.name}-${res.town.name}` //region为已选的省市区的值
				}
				this.form.address_provience = res.province.area_id
				this.form.address_area = res.city.value
				this.form.address_county = res.town.value
			},
			openPicker() {
				this.lotusAddressData.visible = true;
				this.lotusAddressData.provinceName = "" //省
				this.lotusAddressData.cityName = "" //市
				this.lotusAddressData.townName = "" //区
			},
			// 默认地址
			isDefaultChange (e) {
				this.isDefault = e.detail.value
				this.form.address_is_default = e.detail.value ? 1 : 0
			},
			// 删除地址
			del() {
				uni.showModal({
					title: "删除提示",
					content: "你将删除这个收货地址",
					success: (res) => {
						if (res.confirm) {
							this.$api.reqAddress('del', {}, this.id).then((res) => {
								this.$utils.Toast(res.data.message)
								if (res.data.success) {
									setTimeout(() => {
										uni.navigateTo({
											url: '../address/Address'
										})
									}, 1000)
								}
							})
						}
					}
				})
			},
			// 保存提交的地址
			save () {
				uni.showLoading({ title: "正在提交" })
				this.$api.reqAddress(this.id?'put':'post', this.form, this.id?this.id:'').then(res => {
					uni.hideLoading()
					this.$utils.Toast(res.data.message, res.data.success ? 'success' : 'none')
					if (res.data.success) {
						setTimeout(() => {
							if (this.type === 'order' || this.is_order) {
								uni.navigateTo({
									url: '/orders/createOrder/CreateOrder'
								})
							} else {
								uni.navigateTo({
									url: '../address/Address'
								})
							}
						}, 1000)
					}
				})
			}
		}
	};
</script>
<style lang="scss" scoped>
	page {
		background: #fff;
	}

	.inputF {
		font-size: 30rpx;
	}

	.save {
		view {
			display: flex;
		}

		position: fixed;
		bottom: 10px;
		width: 100%;
		height: 120upx;
		display: flex;
		justify-content: center;
		align-items: center;

		.btn {
			box-shadow: 0upx 5upx 10upx rgba(0, 0, 0, 0.4);
			width: 70%;
			height: 80upx;
			border-radius: 80upx;
			color: #FFFFFF;
			justify-content: center;
			align-items: center;

			.icon {
				height: 80upx;
				color: #FFFFFF;
				font-size: 30upx;
				justify-content: center;
				align-items: center;
			}

			font-size: 32upx;
		}
	}

	.content {
		padding: 20rpx 40rpx 100rpx;

		.list {
			height: 180rpx;

			.lable {
				font-size: 30rpx;
				margin-bottom: 10rpx;
				display: block;
			}

			.item {
				display: flex;
				padding: 20rpx;
				border: 1px solid #f2f3f3;

				text {
					font-size: 30rpx;
					width: 35%;
					color: #333;

					i {
						color: red;
						margin-right: 5px;
					}
				}

				input,
				textarea {
					width: 100%;
					color: #555;
					font-size: 30rpx;
				}

				picker {
					width: 100%;
				}

				.uni-input {
					color: #555;
					font-size: 30rpx;
				}

				.input {
					width: 100%;
					font-size: 30rpx;
				}
			}
		}

		.row {
			width: 100%;
			overflow: hidden;
			line-height: 100rpx;
			display: flex;
			justify-content: space-between;

			.nominal {
				width: 70%;
				display: inline-block;
				font-size: 30rpx;
				color: #666666;
			}

			.switch {
				width: 20%;
				display: inline-block;
				overflow: hidden;

				switch {
					transform: scale(0.8);
					float: right;
				}
			}

			.del {
				width: 100%;
				height: 80upx;
				line-height: 80upx;
				justify-content: center;
				align-items: center;
				font-size: 30rpx;
				color: #777;
				background-color: #eee;
				border-bottom: solid 1rpx #eee;
				text-align: center;
			}
		}

		.del-con {
			padding-bottom: 100rpx;
		}
	}
	.uni-form-item{
			margin-bottom: 40rpx;
			color: #CFB47E;
			.title{
				font-size: 32rpx;
			}
			.uni-input{
				margin-top: 10rpx;
				border: 1rpx solid #e3e3e3;
				padding: 16rpx;
				border-radius: 10rpx;
				box-shadow: 0 0 4rpx #e3e3e3;
			}
			.font-red{
				border: 1px solid red;
			}
			.pla{
				color: #e3e3e3;
			}
		}
		.uni-btn-v{
			button{
				border-radius: 40rpx;
				font-size: 30rpx;
				margin-top: 60rpx;
				width: 80%;
				color: #FFFFFF;
			}
			.del{
				background: #e3e3e3;
				color: #333333;
			}
		}
</style>
