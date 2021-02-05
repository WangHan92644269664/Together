<template>
	<view class="return lighter-icon">
        <view class="box">
			<view class="top">
				<view class="goods u-f u-f-jsa">
					<view class="img-box">
						<image :src="data.order_product_image_url  | getProductImg" >
					</view>
					<view class="info">
						<view class="title">{{data.order_product_name}}</view>
						<view class="des">
							<rate @change="onChange0" :value='star'></rate><text>{{goods_star}}</text>
						</view>
					</view>
				</view>
			</view>
			<view class="edit">
				<view class="content">
					<textarea v-model="content" maxlength="100"  placeholder="写出您的感受,可以帮助更多的小伙伴哦"/>
				</view>
				<view class="upload-box">
					<view class="item">
						<easy-upload
						:dataList="imageList"  :types="category" :uploadCount="9"
						@successImage="successImage"
						></easy-upload>
					</view>
				</view>
			</view>
			<view class="type">
				<view class="title u-f u-f-jsb">
                    <text>物流服务评价</text>
                    <text>满意给5星好评哦</text>
                </view>
                <view class="star"><text>快递包装</text><rate @change="onChange1"></rate><text>{{wrap_star}}</text></view>
                <view class="reason u-f" v-show="wrap_star1<4">
                    <text v-for="(item,index) in wrap_content" :key="index" :class="{active:item.selected}" @click="chooseReason(1,index)">{{item.name}}</text>
                </view>
                <view class="star"><text>送货速度</text><rate @change="onChange2"></rate><text>{{speed_star}}</text></view>
                <view class="reason u-f" v-show="speed_star1<4">
                    <text v-for="(item,index) in speed_content" :key="index" :class="{active:item.selected}" @click="chooseReason(2,index)">{{item.name}}</text>
                </view>    
                <view class="star"><text>配送员服务</text><rate @change="onChange3"></rate><text>{{serve_star}}</text></view>
                <view class="reason u-f" v-show="serve_star1<4">
                    <text v-for="(item,index) in serve_content" :key="index" :class="{active:item.selected}" @click="chooseReason(3,index)">{{item.name}}</text>
                </view>
			</view>
			<button type="default" @click="comment">提交</button>
		</view>
        <tips></tips>
    </view>
</template>
<script>
import easyUpload from '@/components/easy-upload/easy-upload'
import rate from '@/components/rate.vue'
	export default {
		data() {
			return {
                data: {},
                user_name:'',//当前用户
                id: "",//订单id
                content: "",  //评价的内容
                checked:false,
                pid:'',   //订单产品id
                star:5,//产品本身评分
                goods_star:'',  //商品
                wrap_star:'',   //快递包装
                wrap_star1:5,   //快递包装
                speed_star:'',  //送货速度
                speed_star1:5,  //送货速度
                serve_star:'',   //配送员服务
                serve_star1:5,   //配送员服务
                wrap_content:[
                    {name:'快递包装破损',selected:false},
                    {name:'包裹内填充物过少',selected:false},
                    {name:'快递包装脏污',selected:false},
                    {name:'快递包装简陋',selected:false}
                ],
                speed_content:[
                    {name:'送货速度慢',selected:false},
                    {name:'发货速度慢',selected:false},
                    {name:'预计送达时间不准确',selected:false}
                ],
                serve_content:[
                    {name:'附近没有自提点/柜',selected:false},
                    {name:'私自退货',selected:false},
                    {name:'服务态度不好',selected:false},
                    {name:'未收货已签收',selected:false},
                    {name:'不送货上门',selected:false},
                    {name:'未经允许私放自提',selected:false}
                ],
                isWrap:null,
                imageList:[],
                category: 'image',
                
			};
        },
        components:{
            easyUpload,
			rate
        },
		onLoad(option) {
            let id = option.id
            this.id = id
            let pid = Number(option.pid)
            let type = Number(option.type)
            this.pid = pid
            this.type = type   //type 1区分是从退货那边过来的，2区分是从追加评论那边过来的
            this.getOrder()
		},
		mounted() {
		},
		methods: {
            // 成功上传图片
			successImage(e){
                this.fileList=e
			},
            // 匿名评价
            change(){
                this.checked=!this.checked;
            },
            // 打分
			onChange0(d){
                this.goods_star=d.attitude
                this.star=d.value
            },
            onChange1(d){
                this.wrap_star=d.attitude
                this.wrap_star1=d.value
            },
            onChange2(d){
                this.speed_star=d.attitude
                this.speed_star1=d.value
            },
            onChange3(d){
                this.serve_star=d.attitude
                this.serve_star1=d.value
            },
            // 选择原因
            chooseReason(id,index){
                if(id===1){
                    this.wrap_content[index].selected=!this.wrap_content[index].selected
                }else if(id===2){
                    this.speed_content[index].selected=!this.speed_content[index].selected
                }else if(id===3){
                    this.serve_content[index].selected=!this.serve_content[index].selected
                }
            },
            // 获取订单数据
            async getOrder() {
                let data = {
                    "expand": "orderOrderProducts"
                }
                const res =await this.$api.reqOrders(data,'get',this.id)
                for (let i in res.data.orderOrderProducts) {
                    if (res.data.orderOrderProducts[i].order_product_product_id === this.pid) {
                        this.data = res.data.orderOrderProducts[i]
                    }
                }
            },
            // 添加评价数据
            comment(){
                if(!this.content){
					this.$utils.Toast('评论内容不能为空');
                }
                let checked
                if(this.checked){
                    checked=1
                }else{
                    checked=0
                }
                let data = {
                    'product_comment_orders_id':this.id,//订单id
                    'product_comment_product_id':this.pid,//产品评分
                    'product_comment_star':this.star,//产品评分
                    'product_comment_content':this.content,//评论内容
                    'product_comment_is_hidden':checked,//是否匿名
                    'product_comment_images':this.fileList,//评论图片
                    'product_comment_pack_star':this.wrap_star1,//快递包装评分
                    'product_comment_service_star':this.speed_star1,//送货速度评分
                    'product_comment_speed_star':this.serve_star1,//配送员服务评分
                    'product_comment_detail':this.data,//商品数据
                }
                this.$api.postComments(data,'post').then(res=>{
					this.$utils.Toast(res.data.message);
                    if(res.data.success){
                        this.$store.state.is_error = false
                        uni.navigateTo({
                            url:`/orders/comment/Comment?index=1&id=${this.id}`
                        })
                    }else{
                        this.$store.state.is_error = true
                    }
                })
            }
		}
	}
</script>

<style lang="scss">
@import '@/common/css/mixin';
.box{
	min-height: 100vh;
    background: #f6f6f6;
	.top{
		background: #ffffff;
		margin-top: 20rpx;
		.serve{
			font-size: 14px;
			text-align: center;
			width:60%;
			background: #eeeeee;
			color: #666666;
			margin: 20rpx auto;
			border-radius: 20px;
			text{
				color: $themeColor;
			}
		}
		.goods{
			padding: 0 30rpx;
			.img-box{
				image{
					width: 150rpx;
					height: 150rpx;
				}
			}
			.info{
				width: 70%;
				.title{
					font-size: 16px;
					overflow: hidden;
					text-overflow: ellipsis;
					white-space: nowrap;
					line-height: 80rpx;
				}
				.des{
					font-size: 12px;
					color: #666666;
					text{
						margin-left: 20rpx;
					}
				}
			}
        }
    }
    .edit{
        background: #FFFFFF;
        margin: 30rpx;
        font-size: 16px;
        padding: 20rpx;
        border-radius: 20rpx;
        .content{
            width: 100%;
            height: 150rpx;
            padding: 20rpx 0;
            textarea{
                width: 100%;
                height: 100%;
                background: #f6f6f6;
                border-radius: 10rpx;
                box-sizing: border-box;
                padding:20rpx;
                font-size: 14px;
            }
        }
        .upload-box{
            item{

            }
            .wain{
                font-size: 18rpx;
            }
        } 
    }
    .type{
        background: #FFFFFF;
        font-size: 32rpx;
        margin: 0 30rpx;
        border-radius: 20rpx;
        line-height: 80rpx;
        padding: 0 30rpx;
        .title{
            text:last-child{
                font-size: 28rpx;
                color: #666666;
            }
        }
        .star{
			color: #666;
            text:first-child{
                display: inline-block;
                width: 26%;
            }
            text:last-child{
                margin-left: 20rpx;
            }
        }
        .reason{
            flex-wrap:wrap;
            text{
                background: #f6f6f6;
                line-height: 60rpx;
                margin-top: 10rpx;
                padding: 0 10rpx;
                border-radius: 10rpx;
				margin-right: 10rpx;
				font-size: 20rpx;
				color: #AAAAAA;
            }
            .active{
                background: #FFD7E0;
                color: red;
            }
        }
    }
    button{
        margin: 30rpx;
        line-height: 80rpx;
        background: #000;
        color: #FFFFFF;
        border: none;
    }
}
	
</style>
