<template>
	<scroll-view :scroll-y="true" class="search-box lighter-icon">
		<!-- 搜索框 -->
		<view class="search u-f u-f-ac u-f-jsb">
			<view class="search-left u-f u-f-ac">
				<view class="u-f u-f-ac">
					<text class="iconfont icon-sousuo1"></text>
					<input type="text" v-model="searchInfo" placeholder="输入商品关键字" @blur="showDel" />
				</view>
				<text class="iconfont icon-close" v-if="is_delete" @click="emptyIpt"></text>
			</view>
			<text @click="getSearch">搜索</text>
		</view>
		<!-- 猜你喜欢 -->
		<view class="history u-f u-f-fdc" v-if="is_history">
			<text class="title">历史搜索</text>
			<view class="content u-f u-f-fw">
				<text class="item font-one" v-for="(item,index) in historys" :key="index" @click="searchHistory(item)">{{item}}</text>
			</view>
		</view>
		<!-- 商品列表 -->
		<view class="container">
			<view class="alert u-f u-f-fdc u-f-jsc u-f-ac" v-if="isShow">
				<text class="iconfont icon-wusousuojieguo"></text>
				<text class="two">抱歉！未搜索到与“<text>{{searchInfo}}</text>”相关的商品</text>
				<text class="three">请换一个关键词试试</text>
			</view>
			<ShopItem :goodsList="goodsList" v-else></ShopItem>
			<text class="load-finish u-f u-f-jsc" v-if="isFinished">~~加载完成~~</text>
		</view>

	</scroll-view>
</template>

<script>
	import ShopItem from "@/components/ShopItem.vue";
	export default {
		components: {
			ShopItem
		},
		data() {
			return {
				title: '搜索商品',
				is_back: true,
				searchInfo: '',
				// 商品列表
				goodsList: [],
				isShow: false,
				is_delete: false,
				isFinished: '',
				// 用于存放历史搜索记录
				historys: [],
				// 显示历史记录
				is_history: true,
				show_back: false,
				flag: true,
				mains: [],
				loading_text: '',
				page: 1,
				sum_page: 1, //总页码
				more: false, //是否加载更多
				gorup_id: 0,
				img_url: this.$utils.imgUrl + 'product/',
				len: 0,
				img_url2: this.$utils.imgUrl,
				show_header: true,
			}
		},
		methods: {
			// 显示清空按钮
			showDel() {
				if (this.searchInfo) {
					this.is_delete = true;
				} else {
					this.is_delete = false;
				}
			},
			emptyIpt() {
				this.searchInfo = '';
				this.is_delete = false;
				this.goodsList = [];
				this.isShow = false;
				this.is_history = true;
				this.isFinished = false;
			},
			// 获取商品搜索列表
			async getSearch() {
				this.goodsList = []
				let data = {
					product_name: this.searchInfo
				}
				if (!this.searchInfo.trim()) {
					uni.showToast({
						title: "请输入关键字",
						icon: 'none'
					})
					return
				}
				const res = await this.$api.getProduct(data)
				this.goodsList = res.data;
				for (let item of res.data) {
					item.product_image = item.product_image.split(';')[0]
				}
				if (this.goodsList.length === 0) {
					this.isShow = true;
					this.isFinished = false
				} else {
					this.isShow = false
					this.isFinished = true
				}
				this.is_history = false;
				// 每次点击搜索按钮之后都将搜索的记录存放在history数组,只存放6个历史记录
				if (this.historys.length === 6) {
					this.historys.pop()
				}
				this.historys.unshift(this.searchInfo)
				console.log(this.historys)
			},
			Back() {
				uni.navigateBack({
					delta: 1,
					animationType: 'pop-out',
					animationDuration: 200
				});
			},
			// 搜索历史关键词
			async searchHistory(item) {
				this.searchInfo = item;
				this.goodsList = [];
				let data = {
					product_name: item
				}
				const res = await this.$api.getProduct(data);
				this.goodsList = res.data;
				for (let item of res.data) {
					item.product_image = item.product_image.split(';')[0]
				}
				this.is_delete = true;
				if (this.goodsList.length === 0) {
					this.isShow = true;
					this.isFinished = false;
				} else {
					this.isShow = false;
					this.isFinished = true;
				}
				this.is_history = false;
				// 每次点击搜索按钮之后都将搜索的记录存放在history数组,只存放6个历史记录
				if (this.historys.length === 6) {
					this.historys.pop()
				}
				this.historys.unshift(this.searchInfo)
				console.log(this.historys)
			}
		},
	}
</script>

<style scoped lang="scss">
	.search-box {
		background-color: #FFFFFF;
		height: 100vh;

		.header {
			position: fixed;
			left: 0rpx;
			top: 0rpx;
			padding: 60rpx 0 0;
			height: 100rpx;
			width: 100%;
			background-color: #EEEEEE;
			z-index: 100;

			.iconfont {
				padding: 0 20rpx;
			}
		}

		.search {
			width: 90%;
			padding: 20rpx 5% 0;
			height: 80rpx;

			.search-left {
				margin-right: 10px;
				color: #ccc;

				view {
					flex: 1
				}
				input{
					color: #222;
				}

				.iconfont {
					padding: 0 20rpx;
				}

				background-color: #f6f6f6;
				flex: 1;
				height:70rpx;
				border-radius: 60rpx;
			}
		}

		.history {
			border-top: 14rpx solid #EEEEEE;
			margin-top: 10rpx;
			padding: 20rpx;

			.title {
				font-size: 34rpx;
				margin-bottom: 20rpx;
			}

			.content {
				text {
					width: 31%;
					background: #DEDEDE;
					font-size: 28rpx;
					border-radius: 10rpx;
					padding: 10rpx 0;
					margin: 0 6rpx;
					text-align: center;
					margin-bottom: 30rpx;
					display: inline-block;
					box-sizing: border-box;
					overflow: hidden;
					text-overflow: ellipsis;
					white-space: nowrap;
				}
			}
		}

		.container {
			margin-top: 20rpx;
			width: 94%;
			padding: 0 3%;
			padding-bottom: 10px;

			.load-finish {
				font-size: 24rpx;
				color: #464646;
				padding-bottom: 20rpx;
			}

			.alert {
				width: 100%;
				margin-top: 30rpx;
				color: #C4CDD2;

				.iconfont {
					font-size: 200rpx;

				}

				.two {
					font-size: 30rpx;
				}

				.three {
					font-size: 24rpx;
				}
			}
		}


	}

	.main-box {
		margin: 0 20rpx;

		.item {
			background: #FFFFFF;
			width: 48.5%;
			display: inline-block;
			margin-right: 3%;
			margin-bottom: 20rpx;
			border-radius: 10 rpx;

			.main {
				padding: 0 10rpx 20rpx;
			}

			.big-img {
				width: 100%;
				height: 320rpx;
			}

			.title {
				font-size: 28rpx;
				overflow: hidden;
				text-overflow: ellipsis;
				white-space: nowrap;
			}

			.market-price,
			.member-price {
				font-size: 26rpx;
				margin-top: 10rpx;
				color: #FEAD13;

				.btn {
					background: red;
					color: #FFFFFF;
					border-radius: 6rpx;
					font-size: 20rpx;
					margin-right: 20rpx;
					border: 1px solid red;
					display: inline-block;
					width: 90rpx;
					text-align: center;
					height: 34rpx;
					line-height: 34rpx;
				}

				text.price {
					font-weight: bold;
				}
			}

			.member-price {
				margin-top: 14rpx;
				overflow: hidden;

				.btn {
					background: none;
					color: red;
				}

				image {
					width: 26rpx;
					height: 26rpx;
					float: right;
					position: relative;
					top: 2px;
				}
			}

		}

		.item:nth-child(2n) {
			margin-right: 0;
		}

	}

	.loading-text {
		width: 100%;
		display: flex;
		justify-content: center;
		align-items: center;
		height: 60rpx;
		color: #979797;
		font-size: 30rpx;
		margin-top: 30rpx;
	}

	/* 加载更多 */
	/*.no-data {
        margin-top: 20rpx;
    }

    .more {
        padding: 10rpx;
        clear: both;
        font-size: 32rpx;
    }

    .loading,
    .no-data {
        color: #999999;
        margin: 10rpx 0;
        font-size: 32rpx;
        text-align: center;
    }*/
</style>
