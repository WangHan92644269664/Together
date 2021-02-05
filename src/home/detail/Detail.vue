<template>
	<view class="categoryBox lighter-icon">
		<!-- 基本信息,购买记录 -->
		<view class="basic-info u-f u-f-jsc">
			<view class="grid u-f u-f-ac">
				<block v-for="(grid, tbIndex) in orderType" :key="tbIndex">
					<text @click="showType(tbIndex)" class="text" :class="[tbIndex == tabbarIndex ? 'on font-text' : '']">{{
				    grid
				  }}</text>
				</block>
			</view>
		</view>

		<view v-if="tabbarIndex===0">
			<!-- 商品详情 -->
			<view class="shop-item">
				<!-- <view class="pc-container">
					<image :src="imgurl" mode="aspectFill" @tap="saveImage"></image>
					<canvas canvas-id="firstCanvas" style="width: 590rpx;height:1000rpx;" v-show="canvasShow"></canvas>
				</view> -->
				<view class="video">
					<!-- 商品主图轮播 -->
					<view class="swiper-box" @tap="canvasImage">
						<swiper circular="true" @change="swiperChange">
							<swiper-item v-for="(swiper, index) in goodsInfo.product_image" :key="index">
								<image :src="img_url + swiper" @tap="imgMap(img_url + swiper)" mode="widthFix"></image>
							</swiper-item>
						</swiper>
						<view class="indicator" v-if="goodsInfo.product_video !==null">{{ current_swiper + 1 }}/{{ product_image.length}}</view>
						<view class="indicator" v-else>{{ current_swiper + 1 }}/{{ product_image.length }}</view>
					</view>
					<!-- 拼团 -->
					<view class="group-box u-f u-f-ac u-f-jsb" v-if="goodsInfo.productGroupRules">
						<view class="left">
							<text>￥<text>{{goodsInfo.productGroupRules.group_rules_product_price[0].product_sku_price|Two}}</text></text>
							<text class="num">{{goodsInfo.productGroupRules.group_rules_complete_number}}人团</text>
						</view>
						<view class="right">
							<text>距活动结束仅剩</text>
							<uni-countdown class="count-down" :show-day="goodsInfo.productGroupRules.day>0" :show-colon="false" splitor-color="#FFFFFF" color="#CFB47E" background-color="#ffffff" border-color="#ffffff" :day="goodsInfo.productGroupRules.day" :hour="goodsInfo.productGroupRules.hours" :minute="goodsInfo.productGroupRules.minutes" :second="goodsInfo.productGroupRules.seconds"></uni-countdown>
						</view>
					</view>
					<!-- 秒杀 -->
					<view class="spike u-f u-f-jsb u-f-ac" v-if="!goodsInfo.productGroupRules">
						<!-- 没有sku的价格显示 -->
						<view class="prices" v-if="goodsInfo.product_is_specs===0">
							<text class="one font-red">￥</text>
							<text class="two lighter-icon font-red">{{goodsInfo.product_price}}</text>
							<text class="three">￥</text>
							<text class="four lighter-icon">{{goodsInfo.product_market_price}}</text>
							<text class="five" v-if="goodsInfo.product_voucher_number>0"><text class="background-text lighter-icon">{{goodsInfo.product_voucher_number|Fixed}}元券+{{goodsInfo.product_price-goodsInfo.product_voucher_number|Fixed}}元现金</text></text>
						</view>
						<!-- 带sku的价格显示 -->
						<view class="prices" v-else>
							<text class="one">￥</text>
							<text class="two lighter-icon">{{goodsInfo.product_price_min}}</text>
						</view>
						<!-- 右边 -->
						<view class="Remain-time u-f u-f-fdc u-f-jsc u-f-ac" v-if="goodsInfo.productSeckill && goodsInfo.productSeckill.length >0">
							<text>距离本活动结束还剩:</text>
							<view class="rest u-f u-f-jsc u-f-ac">
								{{restTime.h}} : {{restTime.m}} : {{restTime.s}}
							</view>
						</view>
					</view>
				</view>
				<view class="shop-title u-f u-f-jsb">
					<text>{{goodsInfo.product_name}}</text>
					<text class="font-grey" v-if="goodsInfo.productMonthSale && goodsInfo.productGroupRules">月拼团量：{{goodsInfo.productGroupRules.group_rules_number + goodsInfo.productMonthSale.product_month_sale_group_count}}</text>
				</view>
			</view>
			<!-- 商品简介 -->
			<view class="goods-detail">
				<strong class="title">商品详情</strong>
				<rich-text :nodes="goodsInfo.product_info|formatRichText"></rich-text>
				<!-- <view v-html="goodsInfo.product_info" class="goods-img"></view> -->
			</view>
		</view>

		<template v-if="tabbarIndex===1&&goodsInfo.length>0">
			<view class="recomment">
				<ShopItem :goodsList="goodsInfo"></ShopItem>
			</view>
		</template>
		<!-- 购买记录 -->
		<view v-if="tabbarIndex===1&&goodsInfo.length===0">
			暂无推荐商品
		</view>
		<!-- 底部导航按钮 -->
		<view class="nav-btns u-f u-f-ac u-f-jsb" v-if="!goodsInfo.productGroupRules">
			<view class="left u-f">
				<!--  #ifdef MP-WEIXIN -->
				<view class="nav-btns-btm" @tap="openShare">
					<text class="iconfont icon-zhuanfa"></text>
				</view>
				<view class="nav-btns-btm">
					<button type="default" open-type="contact"><text class="iconfont icon-kefu"></text></button>
				</view>
				<!--  #endif -->
				<!--  #ifdef APP-PLUS || H5 -->
				<view class="nav-btns-btm" @tap="Go('../../pages/home/index')" style="width: 50%;">
					<text class="iconfont icon-shouye1"></text>
          <text>首页</text>
				</view>
				<!--  #endif -->
				<view class="nav-btns-btm" @tap="Cart">
					<text class="iconfont icon-gouwuc"></text>
          <text>购物车</text>
				</view>
			</view>
			<view class="nav-btns-right u-f u-f-ac">
				<!-- @click="joinCart" -->
				<text class="add-car u-f u-f-ac u-f-jsc background-text" @tap="joinCart">加入购物车</text>
				<text class="rapid-buy u-f u-f-ac u-f-jsc" @click="Buy(goodsInfo.product_id)">立即购买</text>
			</view>
		</view>
		<!-- 拼团 -->
		<view class="nav-btns nav-group u-f u-f-ac u-f-jsb" v-if="goodsInfo.productGroupRules">
			<view class="left u-f">
				<view class="nav-btns-btm" @tap="Go('../../pages/home/index')">
					<text class="iconfont icon-shouye1"></text>
          <text>首页</text>
				</view>
				<view class="nav-btns-btm" @tap="Go('../../pages/center/index')">
					<text class="iconfont icon-renwu"></text>
          <text>个人中心</text>
				</view>
			</view>
			<view class="nav-btns-right u-f u-f-ac">
				<text class="add-car u-f u-f-ac u-f-jsc background-text" @click="Buy(goodsInfo.product_id)">一键参团</text>
			</view>
		</view>
		<view class="pc-container">
		</view>
		<!-- 分享 -->
		<shoproShare :show_share="show_share" @cancel="Cancel" :goodsInfo="goodsInfo" :posterObj="posterObj"></shoproShare>
		<!-- 规格-模态层弹窗 -->
		<echone-sku :show="popupShow" :spu_type="spu_type" :theme-color="themeColor" :combinations="combinations"
		 :specifications="specifications" :default-select-index="selectedIndex" :combinations-props="combinationsProps"
		 :specifications-props="specificationsProps" @close="handleClose" @confirm="handleConfirm" v-if="goodsInfo.product_is_specs"></echone-sku>
		<!-- 规格-模态层弹窗 -->
		<view class="popup spec" :class="spec_class" @touchmove.stop.prevent="Discard" @tap="hideSpec" v-else>
			<!-- 遮罩层 -->
			<view class="mask"></view>
			<view class="layer lighter-icon" @tap.stop="Discard">
				<view class="content">
					<view class="imgs">
						<image :src="img_url + product_image[0]" v-if="product_image && product_image.length > 0"></image>
						<view class="right">
							<text v-if="select_spec === null" class="price">￥{{ product_price }}</text>
							<text v-else class="price">￥{{ product_sku[select_spec].product_sku_price }}</text>
							<text class="sele" v-if="product_sku[0]">库存: {{ product_sku[0].stock }}</text>
							<text v-if="sku_sale === 1 && select_spec !== null" class="sele">
								已选 :
								<text v-for="(item, index) in product_sku[select_spec]
                    .product_sku_spes" :key="index"
								 style="margin-left: 10rpx;">
									<text>{{ item.value }} ,</text>
								</text>
							</text>
						</view>
					</view>
					<view class="length">
						<view class="text">数量</view>
						<view class="number">
							<view class="sub" @tap.stop="Sub">
								<view class="icon jian">-</view>
							</view>
							<view class="input" @tap.stop="Discard">
								<input type="number" v-model="number" @blur="Change(number)" />
							</view>
							<view class="add" @tap.stop="Add">
								<view class="icon jia">+</view>
							</view>
						</view>
					</view>
				</view>
				<view class="btn">
					<view class="button background-text" @tap="Finish">完成</view>
				</view>
			</view>
		</view>

	</view>
</template>

<script>
	import uniPopup from '@/components/uni-popup/uni-popup.vue'
	import uniPopupMessage from '@/components/uni-popup/uni-popup-message.vue'
	import uniPopupDialog from '@/components/uni-popup/uni-popup-dialog.vue'
	import echoneSku from "@/components/echone-sku/echone-sku";
	import moment from "moment";
	import shPrice from './child/sh-price.vue';
	import shComment from './child/sh-comment.vue';
	import shoproParse from '@/components/parse/parse.vue';
	import shoproEmpty from '@/components/shopro-empty/shopro-empty.vue';
	import ShopItem from '@/components/ShopItem.vue';
	import shoproShare from '@/components/shopro-share.vue';
	import uniCountDown from '@/components/uni-countdown/uni-countdown.vue'
	export default {
		components: {
			uniPopup,
			uniPopupMessage,
			uniPopupDialog,
			echoneSku,
			shPrice,
			shoproParse,
			shoproEmpty,
			shComment,
			ShopItem,
			shoproShare,
			uniCountDown
		},
		data() {
			return {
				popupShow: false,
				orderType: ["商品", "推荐"],
				tabbarIndex: 0,
				// 商品详情
				goodsInfo: {},
				mains: [],
				loadingText: "",
				page: 1,
				img_url: this.$utils.productImg,
				// 商品分类id
				id: "",
				total_num: 0,
				restTime: {},
				number: 1,
				spu_type: 'spu', //用来判断是点击规格按钮还是加入购物车和立即购买按钮
				spec_text: "选择规格",
				themeColor: "#408CE2",
				combinations: [],
				specifications: [],
				selectedIndex: 0,
				// 规格选择
				combinationsProps: {
					id: "skuId",
					value: "skuValue",
					image: "skuImage",
					price: "skuPrice",
					stock: "skuStock",
				},
				specificationsProps: {
					id: "id",
					list: "skuList",
					name: "skuName",
				},
				select_spec: null, //选中规格
				product_price: 0,
				sku_sale: 0, //是否下架
				product_sku: [],
				product_image: [],
				product_is_specs: 0, //是否有规格
				product_info: "产品描述", //产品详情
				spec_class: "", //规格弹窗css类，控制开关动画
				detail: "", //配置按钮颜色
				tabCurrent: 'tab0',
				current_swiper: 0,
				emptyData: {
					img: '',
					tip: '暂无评价~'
				},
				currentSkuText: '', //规格选中之后
				spu_obj: '', //如果是点击规格的时候，记录选中的规格
				token: uni.getStorageSync('token'),
				show_share: false,
				code_text: '',
				// 生成海报有关
				posterObj: {},
				posterData: { //主板版海报
					marginLR: 40,
					marginTB: 40,
					radius: 0.03,
					innerLR: 20,
					innerTB: 20,
					posterRatio: 1.3,
					posterImgUrl: "",
					title: "",
					titleFontSize: 14,
					titleLineHeight: 30,
					posterCodeUrl: "",
					codeWidth: 0.4,
					codeRatio: 1,
					codeRadius: 0.5,
					codeMT: 20,
					codeName: "爱拼",
					codeNameMT: 20,
					tips: "扫描识别查看商品",
					posterBgUrl: '',
				},
				code_url: this.$utils.imgUrl,
				code_img: ''
			};
		},
		filters: {
			formatRichText(html) { //控制小程序中图片大小
				if (html) {
					let newContent = html.replace(/\<img/gi,
						'<img style="max-width:100%;height:auto;display:inline-block;margin:10rpx auto;"');
					return newContent;
				}
			}
		},
		onHide() {
			// uni.removeStorageSync('person-card');
		},
		onLoad(option) {
			this.id = option.id;
			this.getProduct(this.id);
			// 场景值
			if (option.scene) {
				uni.setStorageSync('scene', option.scene)
			}
			if (this.token) {
				this.getCode()
			}
		},
		onShow() {
			this.token = uni.getStorageSync('token')
			if (this.token) {
				// #ifdef MP-WEIXIN
				uni.showShareMenu({
					withShareTicket: true,
					menus: ['shareAppMessage', 'shareTimeline']
				})
				// #endif
				this.getUserInfo()
			} else {
				// #ifdef MP-WEIXIN
				uni.hideShareMenu()
				// #endif
			}
		},
		onShareAppMessage() {
			let that = this;
			return {
				title: that.goodsInfo.product_name,
				path: '/home/detail/Detail?scene=' + that.code_text+'&id='+that.id,
				imageUrl: that.img_url + that.goodsInfo.product_image[0],
			}
		},
		onShareTimeline() {
			let that = this;
			return {
				title: that.goodsInfo.product_name,
				path: '/home/detail/Detail?scene=' + that.code_text+'&id='+that.id,
				imageUrl: that.img_url + that.goodsInfo.product_image[0]
			}
		},
		methods: {
			Go (url) {
				uni.switchTab({
					url: url
				})
			},

			// 获取二维码
			async getCode() {
				const res = await this.$api.getCode()
				if (res.data.success) {
					this.code_img = res.data.info
				}
			},
			Cart() {
				uni.switchTab({
					url: '/pages/cart/index'
				})
			},
			// 取消
			Cancel(e) {
				this.show_share = e
				console.log(e)
			},
			// 获取个人信息
			async getUserInfo(){
				const res = await this.$api.getMemberView()
				uni.setStorageSync('userInfo',res.data)
				this.code_text = res.data.memberinfo_account
			},
			//打开分享模态框
			openShare() {
				this.show_share = true
				this.posterObj = this.posterData
				this.posterObj.posterImgUrl = this.img_url + this.goodsInfo.product_image[0]
				this.posterObj.posterBgFlag = this.img_url + this.goodsInfo.product_image[0]
				this.posterObj.posterCodeUrl = this.code_url + this.code_img
				this.posterObj.title = this.goodsInfo.product_name
				this.deliveryFlag = true
			},
			// 根据产品id获取产品信息
			async getProduct(id) {
				uni.showLoading()
				const datas = {
					'expand': 'productSku,productSeckill,productGroupRules,productProductAuction,productAuctionRecord,productComment,productComment.memberInfo,productProductdata,productMonthSale'
				}
				const {data: res} = await this.$api.getProduct(datas, id)
				this.goodsInfo = res
				if (res.product_info) {
					res.product_info = res.product_info.replace(/figure/g, 'div')
				}
				// 拼团数据倒计时
				if (res.productGroupRules) {
					if (moment(res.productGroupRules.group_rules_end_time).format('X') - moment().format('X') > 0) {
						const timeS = moment(res.productGroupRules.group_rules_end_time).format('X') - moment().format('X')
						res.productGroupRules.day = Math.floor(timeS/(3600*24))
						res.productGroupRules.hours = Math.floor(timeS/3600)
						res.productGroupRules.minutes = Math.floor(timeS/60%60)
						res.productGroupRules.seconds = Math.floor(timeS%60)
					}
				}
				
				if (this.tabbarIndex === 0) {
					this.sku_sale = Number(res.product_is_sale);
					this.product_sku = res.productSku;
					this.product_is_specs = res.product_is_specs;
					this.product_info = res.product_info;
					let sku_id = res.productSku[0].product_sku_id
					this.sku_id = sku_id;
					this.product_image = res.product_image = res.product_image.split(
						";"
					);
					this.product_price = res.product_price = Number(
						res.product_price
					).toFixed(2);
					for (let item of res.productSku) {
						item.product_sku_price = Number(item.product_sku_price).toFixed(2);
					}
					let all = [];
					let attributes = [];
					if (res.product_is_specs === 1) {
						for (let item of res.productSku) {
							let attribute = item.product_sku_spes;
							let value = "";
							for (let item2 of attribute) {
								value += item2.value + ",";
								// console.log(value+=item2.value)
								attributes.push(item2.attribute);
								if (item2.attribute === attributes[0]) {
									all.push({
										att: attributes[0],
										val: item2.value,
									});
								}
								if (item2.attribute === attributes[1]) {
									all.push({
										att: attributes[1],
										val: item2.value,
									});
								}
								if (item2.attribute === attributes[2]) {
									all.push({
										att: attributes[2],
										val: item2.value,
									});
								}
							}
							this.combinations.push({
								skuId: item.product_sku_id,
								skuValue: value.substr(0, value.length - 1),
								skuImage: `${this.img_url}${this.product_image[0]}`,
								skuPrice: item.product_sku_price,
								skuStock: item.stock,
							});
						}
						let newArr = [];
						let arrVal = [];
						for (let i in all) {
							if (arrVal.indexOf(all[i]["val"]) === -1) {
								arrVal.push(all[i]["val"]);
								newArr.push(all[i]);
							}
						}
						let map = {},
							dest = [];
						for (let item of newArr) {
							if (!map[item.att]) {
								dest.push({
									skuName: item.att,
									skuList: [item.val],
								});
								map[item.att] = item;
							} else {
								for (let item2 of dest) {
									if (item2.skuName === item.att) {
										item2.skuList.push(item.val);
										break;
									}
								}
							}
						}
						this.specifications = dest;
						attributes = [...new Set(attributes)];
						// 如果商品带有sku参数,计算商品最高价和最低价
					}
				}
				uni.hideLoading()
			},
			// tab切换
			showType(tbIndex) {
				this.tabbarIndex = tbIndex;
				if (tbIndex === 1) {
					this.getProduct()
				} else {
					this.getProduct(this.id);
				}
			},
			hideSpec() {
				this.specCallback = false;
				this.number = 1;
				this.select_spec = null;
				if (this.goodsInfo.product_is_specs !== 1) {
					this.spec_class = "hide";
					setTimeout(() => {
						this.spec_class = "none";
					}, 200);
				}
			},
			Discard() {
				//丢弃
			},
			Go(url) {
				uni.switchTab({
					url: url,
					animationType: 'pop-in',
					animationDuration: 200
				})
			},
			//规格弹窗
			showSpec(fun, type) {
				this.spu_type = type
				if (this.goodsInfo.product_is_specs === 1) {
					this.popupShow = true;
				} else {
					this.spec_class = "show";
				}
				this.specCallback = fun;
			},
			// 加入购物车
			joinCart() {
				let that =this;
				if (this.token) {
					this.number = 1;
					this.spu_type = "add";
					if (this.goodsInfo.product_is_specs == 1) {
						this.showSpec(true, 'add');
					} else {
						this.spec_text = "选择数量";
						this.showSpec(true, 'add');
					}
				} else {
					uni.showModal({
						title:'提示',
						content:'请先登录之后才能加入购物车',
						success(res) {
							if(res.confirm){
								that.$author.auth()
							}else{
								console.log('请先登录')
							}
						}
					})
				}
			},
			//立即购买
			Buy(ids) {
				let that = this;
				if (this.token) {
					this.spu_type = "buy";
					this.number = 1;
					this.select_spec = null;
					if (this.goodsInfo.product_is_specs === 1) {
						this.spec_text = "选择规格";
					} else {
						this.spec_text = "选择数量";
					}
					this.showSpec(true, 'buy');
					this.popupShow = true;
				} else {
					uni.showModal({
						title:'提示',
						content:'登录之后才能加入购物车',
						success(res) {
							if(res.confirm){
								that.$author.auth()
							}else{
								console.log('请先登录')
							}
						}
					})
				}
			},
			// 点击规格确定的时候
			handleConfirm(obj) {
				this.popupShow = false;
				this.spu_obj = obj
				if (this.spu_type === 'spu') {
					this.currentSkuText = obj.skuValue

				} else {
					this.Finish(obj);
				}
			},
			Change(number) {
				console.log(number);
			},
			//跳转锚点
			toAnchor(index) {
				this.select_anchor = index;
				console.log(index);
				uni.pageScrollTo({
					scrollTop: this.anchorlist[index].top,
					duration: 200,
				});
			},
			handleClose() {
				this.popupShow = false;
			},
			//增加数量
			Add() {
				if (this.number >= this.goodsInfo.productSku[0].stock) {
					this.$utils.Toast("达到最大库存量");
				} else {
					this.number++;
				}
			},
			// 减少数量
			Sub() {
				if (this.number >= 1) {
					this.number--;
				} else {
					return;
				}
			},
			//加入购物车完成的时候
			Finish(obj) {
				if (this.spu_type === "buy") {
					let datas = [
						{
							order_product_product_sku_id: this.goodsInfo.product_is_specs ? obj.skuId : this.goodsInfo.productSku[0].product_sku_id,
							order_product_count: this.goodsInfo.product_is_specs ? obj.count : this.number
						}
					]
					// 拼团
					if (this.goodsInfo.productGroupRules) {
						datas[0].order_product_group_rules_id = this.goodsInfo.productGroupRules.group_rules_id
						datas[0].order_product_type = 1
					}
					uni.setStorageSync('params', JSON.stringify(datas))
					uni.navigateTo({
						url: '/orders/createOrder/CreateOrder?type=0'
					})
				} else {
					let data = {
						cart_type: 0,
						// cart_product_count: this.number,
						cart_product_count: obj.count,
						cart_product_id: this.goodsInfo.product_id,
						'cart_sku_id': this.sku_id,
						// 'cart_account':
					};
					if (this.goodsInfo.product_is_specs === 1) {
						data["cart_sku_id"] = obj ?
							obj.skuId :
							this.goodsInfo.productSku[this.select_spec].product_sku_id;
					} else {
						data["cart_sku_id"] = this.sku_id;
					}
					this.$api.reqCarts('put', data).then(res => {
						if (res.data.success) {
							this.$store.state.is_error = false;
							this.$utils.Toast(res.data.message);
							this.spec_class = "hide";
						} else if (res.errors.cart_product_count) {
							this.$utils.Toast(
								"setTips",
								res.errors.cart_product_count[0]
							);
						} else {
							this.$utils.Toast("不能重复添加");
						}
					})
				}
			},
			// 轮播图事件
			//轮播图指示器
			swiperChange(event) {
				this.current_swiper = event.detail.current;
			},
			// 点击查看轮播图片
			imgMap(url) {
				uni.previewImage({
					urls: [url],
				});
			},

		},
		//上拉加载，需要自己在page.json文件中配置"onReachBottomDistance"
		onReachBottom() {
			let len = this.mains.length;
			if (len >= this.total_num) {
				return (this.loadingText = "已经加载完毕");
			} else {
				uni.showToast({
					title: "正在加载",
					icon: "none"
				});
			}
			setTimeout(() => {
				this.getProduct(this.id, {
					page: this.page++
				});
				uni.hideToast();
			}, 1000);
		},

	};
</script>

<style lang="scss" scoped>
	page {
		background: #f4f4f4;
		overflow-x: hidden;
		width: 100%;


		.recomment {
			padding: 100rpx 26rpx;
			background: #f5f5f5;
		}
	}

	.categoryBox {
		width: 100%;
		position: relative;

		.basic-info {
			position: fixed;
			z-index: 100;
			top: 0;
			text-align: center;
			// padding: 20rpx 0;
			height: 80rpx;
			line-height: 80rpx;
			width: 100%;
			background: #ffffff;
			border-bottom: 1px solid #dddddd;

			.grid {
				color: #444;
				font-size: 32rpx;
				flex: 1;
				margin-left: 36%;
				font-weight: bold;

				text:first-child {
					margin-right: 60rpx;
				}
			}

			.iconfont {
				margin-right: 30rpx;
				font-size: 70rpx;
			}
		}

		// 商品详情样式
		.shop-item {
			width: 100%;
			background-color: #fff;
			border-bottom: 20rpx solid #E9ECF1;
			/* #ifdef MP-WEIXIN */
			// padding-top: 80rpx
			/* #endif */

			.provider {
				text-align: center;
				font-size: 28rpx;
				height: 20px;
				line-height: 20px;
				color: #7F7F7F;
			}

			.video {
				position: relative;
				width: 100%;

				// 轮播图
				.swiper-box {
					position: relative;

					swiper {
						width: 100%;
						height: 750rpx;

						swiper-item {
							image {
								width: 100%;
							}

							video {
								width: 100%;
								height: 100%;
							}
						}
					}

					.indicator {
						display: flex;
						justify-content: center;
						align-items: center;
						padding: 6rpx 20upx 0;
						border-radius: 40upx;
						font-size: 24upx;
						position: absolute;
						bottom: 20upx;
						right: 20upx;
						color: #ffffff;
						background-color: rgba(0, 0, 0, 0.2);
					}
				}

				image {
					width: 100%;
					height: 100%;
				}
				.spike {
					width: 94%;
					padding: 20rpx 3% 0;

					.prices {
						.one {
							font-size: 30rpx;
						}

						.two {
							font-size: 36rpx;
							font-weight: bold;
							padding-right: 10rpx;
						}

						.three,
						.four {
							font-size: 32rpx;
							color: #999999;
							text-decoration: line-through;
						}

						.five {
							font-size: 24rpx;
							padding: 6rpx 20rpx 0 !important;
							font-weight: lighter !important;
							color: #999999;

							text {
								border-radius: 60rpx;
								color: #ffffff;
								padding: 6rpx 10rpx 0;
								font-weight: lighter !important;
							}

							.lighter-icon {
								font-size: 24rpx;
								font-weight: normal;
							}

						}
					}

					.Remain-time {
						height: 100rpx;
						width: 300rpx;

						text {
							font-size: 26rpx;
							color: #fff;
						}

						.rest {
							margin-top: 10rpx;
							border-radius: 50rpx;
							background-color: #fff;
							width: 280rpx;
							color: #E60012;
						}
					}
				}
			}

			.shop-title {
				padding: 10rpx 30rpx 20rpx;

				text:first-child {
					font-size: 30rpx;
					font-weight: 600;
				}
			}
		}

		// 商品详情
		/deep/.goods-detail {
			text-align: center;
			width: 96%;
			margin: 0 auto;
			overflow-x: hidden;
			background: #FFFFFF;
			padding: 30rpx 20rpx 100rpx;

			.title {
				font-size: 32rpx;
				padding-bottom: 30rpx;
				display: block;
			}

			/deep/.image {
				width: 100% !important;
				height: 100% !important;
				
			}
			/deep/ .image img{
				width: 710rpx!important;
				margin: 0 10rpx 0 0!important;
			}
		}

		.shop-bottom-left {
			width: 250rpx;
			height: 150rpx;

			.times {
				color: #ED9963;
				font-size: 30rpx;
			}

		}

		.shop-bottom {
			width: 96%;
			height: 77px;
			padding: 0 2%;

			.shop-bottom-right {
				height: 100rpx;

				.xianliang {
					color: #ED9963;
					font-size: 30rpx;
				}

				.today_sale {
					font-size: 30rpx;
					font-weight: 550;

					text {
						color: #EA0505;
					}
				}

				.startTime {
					color: #249DE8;
					font-size: 28rpx;
				}

				.add-shopcar {
					padding: 15rpx 25rpx;
					background-color: #0D9DFE;
					border-radius: 100rpx;
					color: #fff;

					text:first-child {
						font-size: 35rpx;
					}

					text:last-child {
						font-size: 25rpx;
						padding: 3rpx 20rpx;
						border-radius: 50rpx;
						background-color: #8AC9FF;
						color: #0786DB;
					}
				}
			}
		}
	}
	.nav-btns {
		position: fixed;
		bottom: 0;
		width: 100%;
		background-color: #fff;
		font-size: 26rpx;
		box-shadow: 0 0 20rpx #f5f5f5;
    border-top: 1px solid #f5f5f5;

		.left {
			flex: 1;
		}

		.nav-btns-btm {
			font-size: 24rpx;
			width: 33.33%;
			flex-direction: column;
			display: flex;
			text-align: center;

			.iconfont {
				font-size: 42rpx;
				color: #4F4F51;
				margin-bottom: 4rpx;
			}
		}

		button {
			background: none;
			margin: 0;
			padding: 0;
			color: #4F4F51;
			line-height: 1;
		}

		button::after {
			border: none;
			line-height: 1;
		}

		.nav-btns-right {
			color: #fff;
			font-size: 30rpx;

			.add-car {
				width: 220rpx;
				height: 90rpx;
				color: #FFFFFF;
			}

			.rapid-buy {
				width: 220rpx;
				height: 90rpx;
				background-color: #000000;
				color: #FFFFFF;
			}
		}
	}
	.nav-group {
		.nav-btns-btm{
			width: 40%;
		}
		.nav-btns-right{
			.add-car{
				width: 320rpx;
			}
		}
	}

	.add-car {
		width: 100%;
		height: 800rpx;
	}


	@keyframes hidePopup {
		0% {
			opacity: 1;
		}

		100% {
			opacity: 0;
		}
	}

	@keyframes showLayer {
		0% {
			transform: translateY(0);
		}

		100% {
			transform: translateY(-100%);
		}
	}

	// @keyframes hideLayer {
	// 	0% {
	// 		transform: translateY(-100%);
	// 	}

	// 	100% {
	// 		transform: translateY(0);
	// 	}
	// }





	.info-box {
		width: 92%;
		padding: 20upx 4%;
		background-color: #fff;
		margin-bottom: 20upx;
	}

	.spec {
		.row {
			width: 100%;
			display: flex;
			align-items: center;
			margin: 0;

			.text {
				font-size: 24upx;
				color: #a2a2a2;
				margin-right: 20upx;
			}

			.content {
				font-size: 28upx;
				display: flex;
				flex-wrap: wrap;

				.serviceitem {
					margin-right: 10upx;
				}

				.sp {
					width: 100%;
					display: flex;

					view {
						margin-top: 10rpx;
						background-color: #f6f6f6;
						padding: 5upx 10upx;
						color: #999999;
						margin-right: 15upx;
						font-size: 32upx;
						border-radius: 5upx;

						&.on {
							border: solid 1upx #f47952;
							padding: 4upx 8upx;
						}
					}
				}

				.color-box {
					font-size: 32rpx;
					color: #555555;
					margin-top: 10rpx;

					view {
						line-height: 40rpx;
						margin-top: 20rpx;
					}
				}
			}

			.arrow {
				position: absolute;
				right: 4%;

				.icon {
					color: #ccc;
				}
			}
		}
	}



	.popup {
		position: fixed;
		top: 0;
		width: 100%;
		height: 100%;
		z-index: 100;
		display: none;

		.mask {
			position: fixed;
			top: 0;
			width: 100%;
			height: 100%;
			z-index: 21;
			background-color: rgba(0, 0, 0, 0.6);
		}

		.layer {
			position: fixed;
			z-index: 999;
			bottom: -70%;
			width: 92%;
			padding: 0 4%;
			height: 70%;
			border-radius: 20upx 20upx 0 0;
			background-color: #ffffff;
			display: flex;
			flex-wrap: wrap;
			align-content: space-between;

			.content {
				width: 100%;
				padding: 20upx 0;
			}

			.btn {
				width: 100%;
				height: 100upx;

				.button {
					width: 100%;
					height: 80upx;
					border-radius: 40upx;
					color: #ffffff;
					display: flex;
					align-items: center;
					justify-content: center;
					font-size: 28upx;
				}
			}
		}

		&.show {
			display: block;

			.mask {
				animation: showPopup 0.2s linear both;
			}

			.layer {
				animation: showLayer 0.2s linear both;
			}
		}

		&.hide {
			display: block;

			.mask {
				animation: hidePopup 0.2s linear both;
			}

			.layer {
				animation: hideLayer 0.2s linear both;
			}
		}

		&.none {
			display: none;
		}

		&.spec {
			.title {
				font-size: 30upx;
				margin: 30upx 0;
			}

			.sp {
				display: flex;
				flex-direction: column;

				view {
					font-size: 28upx;
					padding: 5upx 20upx;
					border-radius: 8upx;
					margin: 0 30upx 20upx 0;
					background-color: #f6f6f6;

					&.on {
						padding: 3upx 18upx;
						border: solid 1upx #f47952;
					}
				}

				.stock {
					margin-left: 50rpx;
				}
			}

			.length {
				margin-top: 30upx;
				border-top: solid 1upx #aaaaaa;
				display: flex;
				justify-content: space-between;
				align-items: center;
				padding-top: 20upx;

				.text {
					font-size: 30upx;
				}

				.number {
					display: flex;
					justify-content: center;
					align-items: center;

					.input {
						width: 80upx;
						height: 60upx;
						margin: 0 10upx;
						background-color: #f3f3f3;
						display: flex;
						justify-content: center;
						align-items: center;
						text-align: center;

						input {
							width: 80upx;
							height: 60upx;
							display: flex;
							justify-content: center;
							align-items: center;
							text-align: center;
							font-size: 26upx;
						}
					}

					.sub,
					.add {
						width: 60upx;
						height: 60upx;
						background-color: #f3f3f3;
						border-radius: 5upx;

						.icon {
							font-size: 30upx;
							width: 60upx;
							height: 60upx;
							display: flex;
							justify-content: center;
							align-items: center;
						}
					}
				}
			}
		}
	}

	.share {
		display: none;

		&.show {
			display: block;

			.mask {
				animation: showPopup 0.15s linear both;
			}

			.layer {
				animation: showLayer 0.15s linear both;
			}
		}

		&.hide {
			display: block;

			.mask {
				animation: hidePopup 0.15s linear both;
			}

			.layer {
				animation: hideLayer 0.15s linear both;
			}
		}

		&.none {
			display: none;
		}

		.mask {
			background-color: rgba(0, 0, 0, 0.5);
			position: fixed;
			width: 100%;
			height: 100%;
			top: 0;
			z-index: 11;
		}

		.layer {
			width: 92%;
			position: fixed;
			z-index: 12;
			padding: 0 4%;
			top: 100%;
			background-color: rgba(255, 255, 255, 0.9);

			.list {
				width: 100%;
				display: flex;
				padding: 10upx 0 30upx 0;

				.box {
					width: 25%;
					display: flex;
					justify-content: center;
					flex-wrap: wrap;

					image {
						width: 13.8vw;
						height: 13.8vw;
					}

					.title {
						margin-top: 10upx;
						display: flex;
						justify-content: center;
						width: 100%;
						font-size: 26upx;
					}
				}
			}

			.btn {
				width: 100%;
				height: 100upx;
				display: flex;
				justify-content: center;
				align-items: center;
				font-size: 28upx;
				border-top: solid 1upx #666666;
			}

			.h1 {
				width: 100%;
				height: 80upx;
				display: flex;
				justify-content: center;
				align-items: center;
				font-size: 34upx;
			}
		}
	}

	.imgs {
		display: flex;

		image {
			width: 200upx;
			height: 200upx;
			border-radius: 10rpx;
		}

		.right {
			margin-left: 30rpx;
			display: flex;
			flex-direction: column;
			margin-top: 50rpx;

			.price {
				color: red;
				margin-bottom: 10rpx;
			}

			.sele {
				color: #777777;
				font-size: 30rpx;
				margin-bottom: 10rpx;
			}
		}
	}

	.group-box {
		background: linear-gradient(to left, #BA9C50, #FCA649);
		padding: 10rpx 20rpx;
		color: #fff;
		.left{
			text:first-child{
				text{
					font-size: 40rpx;
				}
			}
			text.num{
				margin-left: 20rpx;
				background: #ffffff;
				color: #CFB47E;
				font-size: 26rpx;
				padding: 6rpx 16rpx;
				border-radius: 40rpx;
			}
		}
		.right{
			text-align: center;
			font-size: 26rpx;
		}
	}

	// 标题
	.goods-title {
		color: #000000;
		font-weight: 700;
		padding: 20rpx;
	}

	// 规格卡片
	.sku-box {
		line-height: 82rpx;
		background: #fff;
		border-top: 20rpx solid #f5f5f5;
		border-bottom: 20rpx solid #f5f5f5;
		padding: 0 20rpx;
		font-size: 28rpx;

		.title {
			color: #999;
			margin-right: 20rpx;
		}
	}
</style>
