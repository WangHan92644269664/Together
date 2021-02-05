<template>
	<view class="categoryBox lighter-icon">
		<input type="text" v-model="searchInfo" class="search" placeholder="请输入要搜索的内容" placeholder-class="search-pla"
		 @input="getProduct">
		<view class="category-list">
			<ShopItem :goodsList="goodsList"></ShopItem>
			<text class="nodata">{{loading_text}}</text>
		</view>
	</view>
</template>

<script>
	import Search from "@/components/Search.vue";
	import ShopItem from "@/components/ShopItem.vue";
	export default {
		components: {
			Search,
			ShopItem
		},
		data() {
			return {
				// 要搜索的内容
				searchInfo: "",
				categoryList: [], //分类列表
				showCategoryIndex: 0,
				img_url: this.$utils.productImg,
				page: 1,
				goodsList: [],
				index: 0,
				id: '',
				title: '分类',
				is_back: false,
				length: 0,
				loading_text: '没有数据哦',
				sum_total:0,
			};
		},
		onLoad(options){
			this.id=options.id
			this.getProduct()
		},
		onReachBottom() {
			if (this.goodsList.length < Number(this.sum_total)) {
				this.loading_text = '加载中...'
				this.page++
				this.getProduct()
			} else {
				this.loading_text = Number(this.sum_total )=== 0 ? '没有数据哦' : '已经加载完毕'
			}
		},
		mounted() {},
		methods: {
			async getProduct(){
				uni.showLoading()
				let data={
					page: this.page
				};
				if(this.searchInfo){
					data['product_name']=this.searchInfo
				}else{
					data['product_product_class_id'] = this.id
				}
				const res = await this.$api.getProduct(data)
				uni.hideLoading()
				this.sum_total = res.header["x-pagination-total-count"] ? res.header["x-pagination-total-count"] : res.header[
					'X-Pagination-Total-Count'];
				this.goodsList = this.page === 1 ? res.data : this.goodsList.concat(res.data)
				console.log(this.goodsList.length, this.sum_total)
				if(this.goodsList.length ===  Number(this.sum_total)) {
					this.loading_text = '已经加载完毕'
				} 
				if (this.goodsList.length===0) {
					this.loading_text = '没有数据哦'
				}
			},
		},
	};
</script>

<style lang="scss">
	input{
		background: #FFFFFF;
	}
	page{
		background: #f5f5f5;
	}

	.categoryBox {
		padding:20rpx 2% 30rpx;
		// height: 100vh;
		// overflow: scroll;

		.search {
			width: 75%;
			margin: 0 auto 20rpx;
			padding: 14rpx 0;
			text-align: center;
			border-radius: 100rpx;
		}

		.search-pla {
			color: #AAAAAA;
			font-size: 30rpx;
		}
		.category-list {
			border-top: 1px solid #f5f5f5;
			/deep/.shop-item{
				border:none;
			}
		}
	}
</style>
