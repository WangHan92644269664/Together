<template>
	<view class="shop-car lighter-icon">
		<template v-if="!token">
			<view class="u-f u-f-jsc u-f-ac login background-text" @tap="Login">请先登录</view>
		</template>
		<template v-else>
			<view class="car-hd" v-if="shop_lists.length>0">
				<view class="car-address  u-f u-f-jsc u-f-ac">
          <text class="edit" v-if="!is_delete" @click="is_delete = !is_delete">编辑</text>
          <text class="edit" v-else @click="is_delete = !is_delete">完成</text>
				</view>
			</view>
			<!-- 购物车列表 -->
			<view class="shop-lists u-f u-f-fdc u-f-ac">
				<template v-if="shop_lists.length>0">
					<block v-for="(item,index) in shop_lists" :key="index">
						<view class="shop-item u-f u-f-ac u-f-jsa">
							<!-- 复选框 -->
							<checkbox-group @click="selectItem(index)">
								<label class="checkboxs">
									<checkbox value="" color="E30010" style="transform:scale(0.7)" :checked="item.is_checked" />
								</label>
							</checkbox-group>
							<!-- 商品图片 -->
							<view class="shop-img" @click="Detail(item.cart_product_id)">
								<image :src="img_url + item.cartProduct.product_image"></image>
							</view>
							<!-- 右边部分 -->
							<view class="u-f u-f-fdc u-f-jsa right">
								<strong class="right-top">{{item.cartProduct.product_name}}</strong>
								<view class="right-middle" v-if="item.cartProductSku">
									<text v-for="(sku_item,index) in item.cartProductSku.product_sku_spes" :key="index">{{sku_item.value }} </text>
								</view>
								<view class="right-bottom u-f u-f-jsb u-f-ac">
									<view class="price">
										<text>￥</text>
										<text class="lighter-icon">{{item.cartProductSku.product_sku_price}}</text>
									</view>
									<!-- 商品数量 -->
									<view class="shop-count u-f u-f-ac">
										<view class="btn" @click="operateCart(item,index,'plus')">-</view>
										<text>{{item.cart_product_count}}</text>
										<view class="btn" @click="operateCart(item,index,'add')">+</view>
									</view>
								</view>
							</view>
						</view>
					</block>
				</template>
				<!-- 没有数据的时候 -->
				<view v-else class="u-f u-f-ac nodata">
					<text class="iconfont icon-gouwuche1"></text>
					<text>您还没有添加任何商品哦~</text>
					<navigator url="/pages/home/index" open-type="switchTab" hover-class="none">去逛逛</navigator>
				</view>
			</view>
			<!-- 结算部分 -->
			<view class="total u-f u-f-jsb u-f-ac" v-if="shop_lists.length>0">
				<view class="u-f total-right u-f-ac u-f-jsb">
					<checkbox-group @change='selectAll'>
						<label class="">
							<checkbox value="" color="E30010" style="transform:scale(0.7)" :checked="is_checkedAll" />
							<text class="checkAll">全选</text>
						</label>
					</checkbox-group>
					<text v-if="is_delete"></text>
					<view class="sum u-f u-f-ac">
						<text>合计：</text>
						<text>￥</text>
						<text class="lighter-icon">{{sum_price}}</text>
					</view>
					<view class="settle-gray" :class="sum_count>0?'settle-red':''" v-if="!is_delete">
						<text @click="toSettle">去结算({{sum_count}})</text>
					</view>
					<text @click="deleteGoodsItem" class="delete" v-else>删除({{sum_count}})</text>
				</view>
			</view>
			<!-- 删除弹出框 -->
			<uni-popup ref="popup" type="center" :maskClick="false">
				<uni-popup-dialog type="input" title="确认删除" content="您确定要删除商品吗?" :duration="2000" :before-close="true" @close="Close"
				 @confirm="Delete"></uni-popup-dialog>
			</uni-popup>
		</template>
	</view>
</template>
<script>
	import uniPopup from "@/components/uni-popup/uni-popup.vue";
	import uniPopupDialog from "@/components/uni-popup/uni-popup-dialog.vue";
	export default {
		components: {
			uniPopup,
			uniPopupDialog
		},
		data() {
			return {
				title:'购物车',
				is_back:false,
				shop_lists: [],
				// 图片地址
				img_url: this.$utils.productImg,
				sum_price: 0.00,
				// 选中商品总数
				sum_count: 0,
				is_checkedAll: false,
				header_position: "fixed",
				header_top: null,
				status_top: null,
				show_header: true,
				selected_list: [],
				is_all_selected: false,
				the_index: null, //控制滑动效果
				old_index: null,
				is_stop: false,
				specs: [],
				// 控制暗处按钮的显示与隐藏
				is_delete: false,
				selectedGoods: [], // 被选中的商品
				del_id:'', //需要删除的购物车id
				del_index:null,
				token:'',
				code_text: '',
			};
		},
		onShow() {
			this.goods_list = [];
			this.is_all_selected = false;
			this.sum_price = "0.00";
			this.selected_list = [];
			let token = uni.getStorageSync("token");
			this.token = token
			if(this.token){
				this.code_text = uni.getStorageSync('userInfo').memberinfo_account
				this.getCarts()
				// #ifdef MP-WEIXIN
				uni.showShareMenu()
				// #endif
			}else{
				// #ifdef MP-WEIXIN
				uni.hideShareMenu()
				// #endif
			}

		},
		// 点击右上角的转发
		onShareAppMessage(options) {
			let that = this;
			let shareObj = {
				title: '爱拼',
				path: '/pages/home/index?scene=' + that.code_text
			}
			return shareObj
		},
		onPageScroll(e) {
			//兼容iOS端下拉时顶部漂移
			this.header_position = e.scrollTop >= 0 ? "fixed" : "absolute";
			this.header_top = e.scrollTop >= 0 ? null : 0;
			this.status_top = e.scrollTop >= 0 ? null : -this.statusHeight + "px";
		},
		//下拉刷新，需要自己在page.json文件中配置开启页面下拉刷新 "enablePullDownRefresh": true
		onPullDownRefresh() {
			setTimeout(function() {
				uni.stopPullDownRefresh();
			}, 1000);
		},
		methods: {
			// 去登陆
			Login(){
				this.$author.auth()
			},
			// 获取购物车数据
			async getCarts() {
				uni.showLoading({
					title:'加载中'
				})
				const res = await this.$api.getCarts();
				this.shop_lists = res.data;
				uni.hideLoading()
				for (let item of res.data) {
					item.is_checked = false
					item.cartProduct.product_image = item.cartProduct.product_image.split(";")[0];
				}
			},

			// 点击按钮增减商品数量
			operateCart(item,index,type) {
				let data={};
				this.del_id = item.cart_id
				this.del_index = index
				if(type==='add'){
					data['cart_product_count'] = ++item.cart_product_count
				}else{
					data['cart_product_count'] = --item.cart_product_count
					if(item.cart_product_count===0){
						item.cart_product_count = 1
						return this.$refs.popup.open()
					}
				}
				this.$api.patchCarts(item.cart_id,data)
				this.getSum()
			},
			// 取消删除
			Close(){
				this.$refs.popup.close()
			},
			// 确认删除
			Delete(){
				this.$refs.popup.close();
				this.$api.delCarts(this.del_id).then(res=>{
					if(res.data.success){
						this.shop_lists.splice(this.del_index,1)
					}
				})
			},
			addCount(i) {
				this.shop_lists[i].cart_product_count++;
				this.getSum()
			},
			// 实现全选反选
			selectAll(e) {
				// 根据e.detail.value的长度判断复选框是否被选中
				if (e.detail.value.length === 0) {
					// 取消全选
					this.shop_lists.forEach(item => item.is_checked = false)
				} else {
					this.selectedGoods = []
					this.shop_lists.forEach(item => {
						item.is_checked = true
						// 把选中的所有商品的购物车id传给selectedGoods
						this.selectedGoods.push(item.cart_id)
					})
				}
				this.getSum()
			},
			selectItem(index) {
				this.shop_lists[index].is_checked = !this.shop_lists[index].is_checked;
				// 获取被选中的商品id
				this.selectedGoods = [];
				for (let i = 0; i < this.shop_lists.length; i++) {
					if (this.shop_lists[i].is_checked)
						this.selectedGoods.push(this.shop_lists[i].cart_id)
				}
				var count = 0;
				this.shop_lists.forEach(item => {
					if (item.is_checked)
						count++;
				})
				if (count === this.shop_lists.length) {
					this.is_checkedAll = true;
				} else {
					this.is_checkedAll = false;
				}
				this.getSum()
			},
			// 手动改变商品数量
			countChange(index) {
				this.shop_lists[index].cart_product_count = Number(this.shop_lists[index].cart_product_count.trim())
				this.getSum()
			},
			// 计算商品数量和总价
			getSum() {
				var count = 0;
				var money = 0;
				this.shop_lists.forEach(item => {
					if (item.is_checked) {
						count++;
						money += item.cartProductSku.product_sku_price * item.cart_product_count
					}
				})
				this.sum_count = count
				console.log(this.shop_lists)
				this.sum_price = money.toFixed(2)
			},
			// 跳转到指定页面
			Go(url) {
				this.shop_lists.forEach(item => {
					if (!item.is_checked) return;
					uni.navigateTo({
						url: url,
					});
				})
			},
			// 点击购物车列表图片跳转到商品详情页
			// 点击右边的每个商品跳转到商品详情
			Detail(id) {
				uni.navigateTo({
					url: `/home/detail/Detail?id=${id}`,
					animationType: 'pop-in',
					animationDuration: 200
				});
			},
			// 点击'管理'按钮,可以删除图片
			editGoods() {
				this.is_delete = !this.is_delete;
			},
			// 点击删除按钮删除指定的商品
			async deleteGoodsItem() {
				// 获取被选中的商品的id
				let data = this.selectedGoods
				const res = await this.$api.delCarts(data);
				if (res.statusCode !== 200) return;
				// 删除商品后将价格和数量都置为零
				this.sum_count = 0;
				this.sum_price = 0.00;
				this.getCarts()
			},
			// 去结算
			toSettle() {
				let is_selectShop = []; // 存放商品数量和规格id
				let buyList = []; //要购买的商品
				// 被选中的商品
				for (let i = 0; i < this.shop_lists.length; i++) {
					if (this.shop_lists[i].is_checked) {
						buyList.push(this.shop_lists[i]);
						is_selectShop.push({
							order_product_product_sku_id: this.shop_lists[i].cartProductSku.product_sku_id,
							order_product_count: this.shop_lists[i].cart_product_count,
						});
					}
				}
				if (buyList.length < 1) {
					this.$utils.Toast("请选择商品结算")
					return
				}
				console.log(is_selectShop)
				uni.setStorageSync('params', JSON.stringify(is_selectShop))
				uni.navigateTo({
					url: '/orders/createOrder/CreateOrder?type=0'
				})
			},
			//加入商品 参数 goods:商品数据
			joinGoods(goods) {
				/*
				 * 这里只是展示一种添加逻辑，模板并没有做从其他页面加入商品到购物车的具体动作，
				 * 在实际应用上，前端并不会直接插入记录到goodsList这一个动作，一般是更新列表和本地列表缓存。
				 * 一般商城购物车的增删改动作是由后端来完成的,
				 * 后端记录后返回前端更新前端缓存
				 */
				let len = this.goods_list.length;
				let isFind = false; //是否找到ID一样的商品
				for (let i = 0; i < len; i++) {
					let row = this.goods_list[i];
					if (row.id == goods.id) {
						//找到商品一样的商品
						this.goods_list[i].number++; //数量自增
						isFind = true; //找到一样的商品
						break; //跳出循环
					}
				}
				if (!isFind) {
					//没有找到一样的商品，新增一行到购物车商品列表头部
					this.goods_list[i].unshift(goods);
				}
			},
			//控制左滑删除效果-begin
			touchStart(index, event) {
				//多点触控不触发
				if (event.touches.length > 1) {
					this.is_stop = true;
					return;
				}
				this.old_index = this.the_index;
				this.the_index = null;
				//初始坐标
				this.initXY = [event.touches[0].pageX, event.touches[0].pageY];
			},
			touchMove(index, event) {
				//多点触控不触发
				if (event.touches.length > 1) {
					this.is_stop = true;
					return;
				}
				let moveX = event.touches[0].pageX - this.initXY[0];
				let moveY = event.touches[0].pageY - this.initXY[1];

				if (this.is_stop || Math.abs(moveX) < 5) {
					return;
				}
				if (Math.abs(moveY) > Math.abs(moveX)) {
					// 竖向滑动-不触发左滑效果
					this.is_stop = true;
					return;
				}

				if (moveX < 0) {
					this.the_index = index;
					this.is_stop = true;
				} else if (moveX > 0) {
					if (this.the_index != null && this.old_index == this.the_index) {
						this.old_index = index;
						this.the_index = null;
						this.is_stop = true;
						setTimeout(() => {
							this.old_index = null;
						}, 150);
					}
				}
			},
			touchEnd(index, $event) {
				//结束禁止触发效果
				this.is_stop = false;
			},
			//控制左滑删除效果-end
			//商品跳转
			toGoods(id) {
				// uni.showToast({title: '商品'+e.id,icon:"none"});
				uni.navigateTo({
					url: "../home/detail/Detail?id=" + id,
				});
			},
			//跳转确认订单页面
			toConfirmation() {
				let tmpList = [];
				let len = this.goods_list.length;
				let datas = [];
				for (let i = 0; i < len; i++) {
					if (this.goods_list[i].selected) {
						tmpList.push(this.goods_list[i]);
						datas.push({
							order_product_product_sku_id: this.goods_list[i].cartProductSku
								.product_sku_id,
							order_product_count: this.goods_list[i].cart_product_count,
						});
					}
				}
				if (tmpList.length < 1) {
					this.$utils.Toast("请选择商品结算");
					return;
				}
				uni.setStorage({
					key: "buylist",
					data: datas,
					success: () => {
						uni.navigateTo({
							url: "/orders/createOrder/CreateOrder?type=cart",
						});
					},
				});
			},
			//删除商品
			deleteGoods(type, id) {
				let ids = "";
				if (type === "singal") {
					ids = id;
				} else if (type === "all") {
					let len = this.selected_list.length;
					for (let index in this.selected_list) {
						if (len - 1 == index) {
							ids += this.selected_list[index];
						} else {
							ids += this.selected_list[index] + ",";
						}
					}
				}
				this.$utils.postUrl("DELETE", "/carts/" + ids).then((res) => {
					let len = this.goods_list.length;
					if (res.data.success) {
						this.$store.state.is_error = false;
						this.$utils.Toast( res.data.message);
						if (type === "all") {
							setTimeout(() => {
								for (let item of this.selected_list) {
									for (let i = 0; i < len; i++) {
										if (
											item == this.goods_list[i].cart_id &&
											this.goods_list[i]
										) {
											this.goods_list.splice(i, 1);
											break;
										}
									}
								}
								this.selected_list = [];
								this.sum_price = 0;
								this.is_all_selected =
									this.selected_list.length == this.goods_list.length &&
									this.goods_list.length > 0;
							}, 500);
						} else {
							this.$utils.Toast(res.data.message);
							setTimeout(() => {
								for (let i = 0; i < len; i++) {
									if (id == this.goods_list[i].cart_id) {
										this.goods_list.splice(i, 1);
										break;
									}
								}
								this.selected_list.splice(this.selected_list.indexOf(id), 1);
							}, 500);
						}
						this.old_index = null;
						this.the_index = null;
						this.Sum();
					}
				});
			},
			// 删除商品s
			deleteList() {
				this.deleteGoods("all", this.selected_list[0]);
			},
			// 选中商品
			selected(index) {
				this.goods_list[index].selected = this.goods_list[index].selected ?
					false :
					true;
				let i = this.selected_list.indexOf(this.goods_list[index].cart_id);
				i > -1 ?
					this.selected_list.splice(i, 1) :
					this.selected_list.push(this.goods_list[index].cart_id);
				this.is_all_selected =
					this.selected_list.length == this.goods_list.length;
				this.Sum();
			},
			// 合计
			Sum(e, index) {
				this.sum_price = 0;
				let len = this.goods_list.length;
				for (let i = 0; i < len; i++) {
					// console.log();
					if (this.goods_list[i].selected) {
						if (e && i == index) {
							this.sum_price =
								this.sum_price +
								e.detail.value *
								this.goods_list[i].cartProductSku.product_sku_price;
						} else {
							this.sum_price =
								this.sum_price +
								this.goods_list[i].cart_product_count *
								this.goods_list[i].cartProductSku.product_sku_price;
						}
					}
				}
				this.sum_price = this.sum_price.toFixed(2);
			},
			discard() {
				//丢弃
			},
			//旧代码-
		},
	};
</script>
<style lang="scss" scoped>
	.nodata {
		flex-direction: column;
		margin-top: 40%;
		font-size: 34rpx;
		color: #666;

		.iconfont {
			font-size: 130rpx;
			color: #bbb;
		}

		text:nth-of-type(2) {
			margin: 50rpx 0;
		}

		navigator {
			color: #000000;
			border: 1px solid #000000;
			padding: 10rpx 60rpx;
			border-radius: 40rpx;
			font-size: 32rpx;
		}
	}
	.login{
		color: #FFFFFF;
		width: 40%;
		position: absolute;
		top:50%;
		left: 30%;
		padding: 20rpx 0;
		font-size: 32rpx;
		border-radius: 60rpx;
	}

	.shop-car {
		width: 100%;
		background-color: #E9ECF1;
		min-height: 100vh;
		padding:0 0 100rpx;
		box-sizing: border-box;

		.car-hd {
			background-color: #F2F2F2;
			// padding: 26rpx 0 30rpx;
      z-index: 1000;
      position: fixed;
      top: var(--window-top);
      width: 100%;
      height: 10px;
      padding: 30rpx 0;

			.car-address {
				width: 100%;
				font-size: 28rpx;
				.edit {
					position: fixed;
					right: 30rpx;
				}
			}
		}

		.shop-lists {
      padding-top: var(--window-top);
      padding-left: 30rpx;
      padding-right: 30rpx;

			.shop-item {
				width: 100%;
				padding: 10rpx;
				border-radius: 10rpx;
				background-color: #fff;
				margin-top: 20rpx;

				.shop-img {
					image {
						width: 170rpx;
						height: 170rpx;
						border-radius: 10rpx;
						margin-right: 20rpx;
					}
				}

				.right {
					flex: 1;
					height: 100%;

					.right-top {
						font-size: 30rpx;
						margin-bottom: 20rpx;
					}

					.right-middle {
						font-size: 28rpx;
						color: #989898;
					}

					.right-bottom {
						.price {
							color: #E80113;
							font-weight: 700;
							font-size: 32rpx;
							.lighter-icon{
								font-size: 38rpx;
							}
						}

						.shop-count {
							padding-right: 10rpx;
							view:first-child {
								font-weight: 520;
								color: #000;
							}

							view:last-child {
								color: #fff;
								background-color: #000;
								border:1px solid #000
							}

							text{
								width: 60rpx;
								text-align: center;
							}

							.btn {
								width: 40rpx;
								height: 40rpx;
								line-height:38rpx;
								text-align: center;
								border-radius: 50%;
								border: 1px solid #000;
							}
						}
					}
				}
			}
		}

		//底部结算
		.total {
			.checkAll {
				color: #9E9E9E;
				font-size: 26rpx;
				flex: 1;
			}

			.total-right {
				position: fixed;
				bottom: calc(var(--window-bottom) + 1rpx);
				width: 96%;
				background: #FFFFFF;
				padding: 0 4%;
				.sum {
					margin-right: 40rpx;
					font-size: 30rpx;
					color: #333;

					text:nth-child(2) {
						color: #DFBB76;
						font-size: 32rpx;
					}

					text:nth-child(3) {
						color: #DFBB76;
						font-size: 50rpx;
					}
				}

				.settle-gray {
					background: #d0d2d6;
					color: #fff;
					height: 100rpx;
					line-height: 100rpx;
					width: 220rpx;
					text-align: center;
				}

				.settle-red {
					background-color: #CFB47E;
				}
				.delete{
					height: 60rpx;
					line-height: 60rpx;
					margin:15rpx;
					color: #CFB47E;
					border:1rpx solid #CFB47E;
					border-radius: 40rpx;
					width: 180rpx;
					text-align: center;
				}
			}
		}
	}

	/deep/ uni-checkbox .uni-checkbox-input {
		margin-right: 5px;
		-webkit-appearance: none;
		appearance: none;
		outline: 0;
		border: 1px solid #d1d1d1;
		border-radius: 12px !important;
		width: 22px;
		height: 22px;
		position: relative;
	}

	/deep/ uni-checkbox .uni-checkbox-input.uni-checkbox-input-checked {
		color: #ffffff;
		background-color: #000;
		border: 1px solid #000;
	}

	/deep/uni-checkbox:not([disabled]) .uni-checkbox-input:hover {
		border-color: #d1d1d1;
	}
</style>
