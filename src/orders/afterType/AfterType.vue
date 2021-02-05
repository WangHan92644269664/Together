<template>
	<view class="type lighter-icon">
        <view class="box">
            <view class="top">
                <view class="serve">本次服务将由<text>爱拼</text>为您服务</view>
                <view class="goods u-f u-f-jsa">
                    <view class="img-box">
                        <image :src="data.order_product_image_url  | getProductImg" >
                    </view>
                    <view class="info">
                        <view class="title">{{data.order_product_name}}</view>
                        <view class="des">
                            <text>单价: {{data.order_product_price|two}}</text>
                            <view>购买数量：{{data.order_product_count}}</view>
                            <view>申请数量：{{data.order_product_count}}</view>
                        </view>
                    </view>
                </view>
            </view>
            <view class="options">
                <view class="option option1  u-f u-f-jsa">
                    <view>
                        <i class="iconfont icon-huanhuo"></i>
                        <text>退货</text>
                    </view>
                    <view @click="toReturn(0)" v-if="is_back">
						<text>退回收到的商品</text>
						<text class='iconfont icon-youjiantou'></text>
					</view>
                    <view v-else>
						<text>退回收到的商品</text>
						<text class='iconfont icon-youjiantou'></text>
					</view>
                </view>
				<view class="option  u-f u-f-jsa">
				    <view>
				        <i class="iconfont icon-huanhuo"></i>
				        <text>售后</text>
				    </view>
				    <view @click="toReturn(1)" v-if="is_back1">
						<text>更换收到的商品</text>
						<text class='iconfont icon-youjiantou'></text>
					</view>
                    <view v-else>
						<text>更换收到的商品</text>
						<text class='iconfont icon-youjiantou'></text>
					</view>
				</view>
            </view>
        </view>
    </view>
</template>
<script>
	export default {
		data() {
			return {
                data: {},
                id: "",
                is_back:true,
                is_back1:true,
                pid: ""
			};
		},
		onLoad(option) {
            let id = option.id
            this.id = id
            let pid = Number(option.pid)
            this.pid = pid
            let is_back = option.is_back   //是否可退货
            this.is_back = is_back
            let is_after = option.is_after  //是否可售后
            this.is_back1 = is_after
            this.getOrder()
		},
		mounted() {
        },
        computed: {
        },
		methods: {
            // 去退货
            toReturn(index) {
                uni.navigateTo({
                    url:'/orders/return/Return?index=' + index + "&id=" + this.id + "&pid=" + this.pid
                })
            },
            async getOrder() {
				uni.showLoading()
                let data = {
                    "expand": "orderOrderProducts"
                }
                const res =await this.$api.reqOrders(data,'get',this.id)
				uni.hideLoading()
                for (let i in res.data.orderOrderProducts) {
                    if (res.data.orderOrderProducts[i].order_product_product_id === this.pid) {
                        this.data = res.data.orderOrderProducts[i]
                    }
                }
            }
		}
	}
</script>

<style lang="scss">
@import '@/common/css/mixin';
.type{
    .box{
        min-height: 100vh;
        background: #f6f6f6;
        .top{
            background: #ffffff;
            .serve{
                font-size: 28rpx;
                text-align: center;
                width:60%;
                background: #eeeeee;
                color: #666666;
                margin: 50rpx auto;
				display: block;
                border-radius: 20px;
                text{
                    color: $themeColor;
                }
            }
            .goods{
                padding: 0 30rpx;
                .img-box{
                    image{
                        width: 200rpx;
                        height: 200rpx;
                    }
                }
                .info{
                    width: 60%;
                    .title{
                        font-size: 30rpx;
                        overflow: hidden;
                        text-overflow: ellipsis;
                        white-space: nowrap;
						margin-bottom: 30rpx;
                    }
                    .des{
                        font-size: 26rpx;
                        color: #999999;
                        text{
                            margin-right: 20rpx;
                        }
                    }
                }
            }
        }
        .options{
            margin: 50rpx 30rpx;
            background: #FFFFFF;
            border-radius: 20rpx;
            padding: 0 30rpx;
            .option{
                line-height: 100rpx;
                i{
                    color: #ff913a;
                    font-weight: bold;
                    margin-right: 20rpx;
                }
                view:first-child{
                    text-align: left;
                    width: 30%;
                    text{
                        font-size: 30rpx;
                    }
                }
                view:last-child{
                    text-align: right;
                    width: 70%;
                    text:first-child{
                        font-size: 28rpx;
                        color: #666666;
                    }
                }
            }
            .option1{
                border-bottom: 1px solid #eeeeee;
                i{
                    color: #dbc291;
                }
            }

        }
    }
}

</style>
