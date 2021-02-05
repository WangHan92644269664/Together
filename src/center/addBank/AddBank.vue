<template>
	<view>
		<view class="content lighter-icon">
			<view class="row">
				<view class="item">
					<text class="nominal" :class="{
              'font-green': reg_name === 1,
              'font-red': reg_name === 2,
            }">账户名</text>
					<view class="input">
						<input placeholder="请输入账户名" type="text" v-model="name" placeholder-class="inputF" />
					</view>
				</view>
			</view>
			<view class="row">
				<view class="item">
					<text :class="{
              'font-green': reg_bank === 1,
              'font-red': reg_bank === 2,
            }">开户银行</text>
					<view class="input">
						<picker @change="bindPickerChange" :value="index" :range="array">
							<view class="uni-input">{{ array[index] }}</view>
						</picker>
					</view>
				</view>
			</view>
			<view class="row">
				<view class="item">
					<text :class="{
              'font-green': reg_bankSite === 1,
              'font-red': reg_bankSite === 2,
            }">开户支行地址</text>
					<view class="input">
						<input placeholder="请输入开户行地址" type="text" v-model="address" placeholder-class="inputF" />
					</view>
				</view>
			</view>
			<view class="row">
				<view class="item">
					<text :class="{
              'font-green': reg_bank_num === 1,
              'font-red': reg_bank_num === 2,
            }">银行卡号</text>
					<view class="input">
						<input placeholder="输入银行卡号" type="number" v-model="no_id" placeholder-class="inputF" />
					</view>
				</view>
			</view>
		</view>
		<view class="tips u-f u-f-ac" v-if="!id">
			<checkbox-group @change="Check">
				<checkbox :checked="is_agree" style="transform: scale(0.7);" color="#000000" />
			</checkbox-group>
			<text>我已同意并阅读遵守</text>
			<text @tap="Protocol">《会员协议》</text>
		</view>
		<view class="save " @tap="Save">
			<view class="btn background-text">完成</view>
		</view>

	</view>
</template>

<script>
	export default {
		data() {
			return {
				array: ["请选择开户银行"],
				index: 0,
				ids: [0],
				no_id: "", //银行卡账号
				reg_bank_num: "",
				tip_bank_num: "",
				name: "", //账户名
				reg_name: "",
				tip_name: "",
				user_bank_name: "", //开户银行
				tip_bank: "",
				reg_bank: "",
				site: "", //开户银行所在地
				tip_bankSite: "",
				reg_bankSite: "",
				address:'',
				is_agree: false,
				id:'',    //判断是修改还是添加
			};
		},
		mounted() {},
		methods: {
			bindPickerChange: function(e) {
				this.index = e.target.value;
			},
			/* 获取银行卡列表和地区列表 */
			getBanks() {
				this.$utils.postUrl("GET", "banks").then((res) => {
					let i = 0;
					for (let item of res.data) {
						i++;
						/* 判断用户以前选择的银行卡名称是否与现有的一致 */
						if (item.bank_name === this.user_bank_name) {
							this.index = i;
						}
						this.array.push(item.bank_name);
						this.ids.push(item.bank_id);
					}
				});
			},
			// 勾选协议
			Check(e) {
				this.is_agree = !this.is_agree
			},
			Protocol() {
				uni.navigateTo({
					url: '/center/protocol/Protocol'
				})
			},
			Save() {
				if (!this.name) {
					this.$store.state.is_error = true;
					this.reg_name = 2;
					this.$utils.Toast("请输入账号名");
					return;
				}
				if (this.ids[this.index]===0) {
					this.$utils.Toast("请选择开户银行");
					return;
				}
				//判断用户是否选择开户行地址
				if (!this.address) {
					this.reg_bankSite = 2;
					this.tip_bankSite = "请输入开户行所在地";
					return;
				}
				if (!this.no_id) {
					this.$store.state.is_error = true;
					this.reg_bank_num = 2;
					this.$utils.Toast("请输入银行卡号");
					return;
				}
				// 只有第一次的时候才会选择会员协议
				if (!this.is_agree&&!this.id) {
					return this.$utils.Toast('请勾选会员协议')
				}
				let data = {
					memberinfo_bank_name: this.name,
					memberinfo_bank_id: this.ids[this.index],
					memberinfo_bank_branch: this.address,
					memberinfo_bank_no: this.no_id,
				};
				this.$utils.postUrl("PUT", "memberinfos/update-my", data).then((res) => {
					this.$utils.Toast(res.data.message);
					if (res.data.success) {
						this.$store.state.is_error = false;
						uni.setStorageSync("userInfo", res.data.info);
						uni.navigateTo({
							url: '/center/bank/Bank'
						})
					}
				});
			},
			// 获取个人资料
			async getUserinfo() {
				let name = this.area;
				await this.$api.getUserInfo().then((res) => {
					if (res.data.success) {
						if (res.data.info.memberinfo_bank_name) {
							this.name = res.data.info.memberinfo_bank_name;
						}
						if (res.data.info.memberinfo_bank_no) {
							this.no_id = res.data.info.memberinfo_bank_no;
						}
						if (res.data.data) {
							this.user_bank_name = res.data.data.bank_name;
						}
						this.address = res.data.info.memberinfo_bank_branch;
						this.getBanks()
					}
				});
			},
		},
		onLoad(e) {
			if(e.id){
				this.id = e.id
				uni.setNavigationBarTitle({
					title:'修改提现账户'
				})
			}
			//获取个人资料
			this.getUserinfo();
		},
	};
</script>
<style lang="scss">
	.inputF {
		font-size: 28rpx;
	}
	.tips {
		margin-top: 40rpx;
		padding: 0 30rpx;
		color: #AAAAAA;
		font-size: 30rpx;
	
		text:last-child {
			color: #000000;
		}
	}

	.save {
		view {
			display: flex;
		}

		width: 100%;
		height: 120rpx;
		display: flex;
		justify-content: center;
		align-items: center;
		margin-top: 40rpx;

		.btn {
			box-shadow: 0rpx 5rpx 10rpx rgba(0, 0, 0, 0.4);
			width: 70%;
			height: 80rpx;
			border-radius: 80rpx;
			color: #ffffff;
			justify-content: center;
			align-items: center;
			margin-top: 40rpx;

			.icon {
				height: 80rpx;
				color: #ffffff;
				font-size: 30rpx;
				justify-content: center;
				align-items: center;
			}

			font-size: 36rpx;
		}
	}

	.content {
		display: flex;
		flex-wrap: wrap;

		view {
			display: flex;
		}

		.row {
			width: 94%;
			margin: 0.2rem 3%;
			line-height: 1.4rem;
			display: block;

			/*height: 1.2rem;*/
			.item {
				border-bottom: 0.5px solid #f1eded;
				padding: 20rpx 0;
				width: 100%;
				display: flex;
				align-items: center;
				justify-content: space-between;

				text {
					font-size: 30rpx;
					display: inline-block;
					text-align: left;
				}

				text:nth-of-type(1) {
					width: 30%;
				}

				.input {
					border: none;
					/*width: 65%;*/
					flex: 1;
					text-align: left;
					padding: 0.2rem 0.2rem 0;

					input {
						line-height: 1rem;
						width: 100%;
					}
				}
			}

			.err-tips {
				display: block;
			}

			/*.nominal {
      width: 40%;
      height: 120rpx;
      font-size: 35rpx;
      align-items: center;
      color: #000000;
    }

    .input {
      width: 70%;
      padding: 20rpx 0;
      align-items: center;
      font-size: 34rpx;

      &.switch {
        justify-content: flex-end;
      }

      input {
        font-size: 34rpx;
      }

      .textarea {
        margin: 20rpx 0;
        min-height: 120rpx;
      }
    }

    .del {
      width: 100%;
      height: 100rpx;
      justify-content: center;
      align-items: center;
      font-size: 36rpx;
      color: #333;
      background-color: rgba(3, 145, 87, 0.2);
      border-bottom: solid 1px #EEEEEE;
    }*/
		}
	}

	.uni-input,
	.uni-input-input,
	.input {
		font-size: 30upx;
		color: #555;
		// width: 100%;
	}
</style>
