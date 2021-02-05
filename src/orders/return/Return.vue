<template>
	<view class="return lighter-icon">
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
							<text>购买数量：{{data.order_product_count}}</text>
							<text>申请数量：{{value}}</text>
						</view>
					</view>
				</view>
				<view class="numbers u-f u-f-jsa">
					<view class="name">
						申请数量
					</view>
                    <view class="number">
                        <view class="sub" @tap.stop="Sub">
                            <view class="icon jian">-</view>
                        </view>
                        <view class="input" @tap.stop="discard">
                            <input type="number" v-model="value" @input="Sum($event,index)" :max='max_value' />
                        </view>
                        <view class="add" @tap.stop="Add">
                            <view class="icon jia">+</view>
                        </view>
                    </view>
				</view>
			</view>
			<view class="edit">
				<view class="title u-f u-f-jsa">
					<view class="name">
						申请原因
					</view>
					<view class="choose">
                        <picker mode="selector" @change="selectChange" :range="selectContents">
                            <text v-if="selectRadio">{{selectRadio}}</text>
                            <text v-else>请选择申请原因</text>
						    <i class='iconfont icon-more'></i>
                        </picker>
					</view>
				</view>
				<view class="content">
					<textarea v-model="content" maxlength="100"  placeholder="请描述申请售后服务的具体原因"/>
                    <text>{{content.length}}/100</text>
				</view>
				<view class="upload-box">
					<view class="item">
						<easy-upload
						:dataList="imageList"  :types="category" :uploadCount="9"
						@successImage="successImage"
						></easy-upload>
					</view>
					<view class="wain">为了帮您更好的解决问题，请务必上传照片凭证</view>
				</view>
			</view>
			<view class="types u-f u-f-jsa" v-if="index===0">
				<text>退款方式</text>
				<text>{{type}}</text>
			</view>
            <view class="types1" v-if="index===1">
                <view class="title u-f u-f-jsb">
                    <text class="name">返回方式</text>
                    <view class="choose">
                        <picker mode="selector" @change="typeChange" :range="typeContents">
                            <text>{{typeContents[typeRadio]}}</text>
						    <i class='iconfont icon-more'></i>
                        </picker>
                    </view>
                </view>
                <view class="address u-f u-f-jsb">
                    <text class="iconfont icon-dizhi"></text>
                    <view class="center u-f u-f-fdc">
                        <text>{{big_data.order_ship_realname}} {{big_data.order_ship_mobile}}</text>
                        <text>地址: {{big_data.order_ship_provience}} {{big_data.order_ship_area}} {{big_data.order_ship_county}} {{big_data.order_ship_detail}}</text>
                    </view>
                    <text class="iconfont icon-youjiantou"></text>
                </view>
                <view class="date u-f u-f-jsb">
                    <view class="center">
                        <text class="iconfont icon-riqi"></text>
                        <text class="dates">{{dateRadio!==''?dateContents[dateRadio]:date}}</text>
                    </view>
                    <text class="iconfont icon-more" @click="showPopup"></text>
                </view>
            </view>
			<button type="default" @click="afterSales">提交</button>
            <!-- 时间 -->
            <uni-popup ref="popup" type="bottom" :maskClick=false>
                <view class="date_content u-f u-f-jsb">
                    <i class="iconfont icon-cuo" @tap='closeTime'></i>
                    <view class="left u-f">
                        <text v-for="(item,index) in dates" :key="index" :class="{'active':active===index}" @tap="changeSpan(index)">{{item}}</text>
                    </view>
                    <view class="right">
                        <template v-if="active===0">
                            <view class="u-f" v-for="(item,index) in times1" :key="index">
                                <text class="title">{{item.title}}</text>
                                <text class="active">{{item.time}}</text>
                            </view>
                        </template>
                        <template v-else>
                                <view class="u-f" v-for="(item,index) in times" :key="index">
                                    <text class="title">{{item.title}}</text>
                                    <text :class="{'active':index===time_active}" @tap="changeTime(index)">{{item.time}}</text>
                                </view>
                        </template>
                    </view>
                </view>
            </uni-popup>
		</view>
    </view>
</template>
<script>
import easyUpload from '@/components/easy-upload/easy-upload'
import uniPopup from '@/components/uni-popup/uni-popup.vue'
	export default {
		data() {
			return {
                big_data: {},  //返回的所有数据
                data:{},   //产品数据
                name: "友拓",
                index: "",  //是退货还是换货
                id: "",  //订单id
                select: "请选择申请原因",
                type: "原支付返还",
                returnType: "上门取件",
                content: "",  //申请原因内容
                fileList: [], //上传的图片
                uploadNum: "上传凭证",
                isSelect: false,
                selectRadio: '',
                selectContents: ["发错货", "商品损坏", "不想要了", "商品与页面描述不符", "缺少见", "质量问题", "其他"],
                isType: false,
                typeContents: ["上门取件", "送货至自提点", "快递至友拓"],
                typeRadio: 0,
                title: "",
                date: "",
                isD: false,
                dateContents: [],
                dateRadio: '',
                pid:'',   //产品id
                value:1,   //换货的数量
                max_value:0,   //最大值
                num:'',
				imageList:[],
                category: 'image',
                dates:[],
                active:0,
                times1:[
                    {title:'下午',time:'15:00-19:00'}
                ],
                times:[
                    {title:'上午',time:'9:00-15:00'},
                    {title:'下午',time:'15:00-19:00'}
                ],
                time_active:0,
                show:false
			};
        },
        components:{
            easyUpload,
            uniPopup
        },
		onLoad(option) {
            let index = Number(option.index)
            let id = option.id
            this.id = id
            this.index = index
            let pid = Number(option.pid)
            this.pid = pid
			uni.setNavigationBarTitle({
				title:index === 0 ? "退货" : "售后"
			})
            this.getOrder()
            this.date = `${this.$utils.getDate(0)} 15:00-19:00`
		},

		methods: {
            // 选择原因
            selectChange(e){
                this.selectRadio=this.selectContents[e.detail.value]
            },
            // 返回方式
            typeChange(e){
                this.typeRadio=e.detail.value
            },
            // 时间
            showPopup(){
                let list = [0,1,2,3,4,5,6]
                for(let i in list){
                    this.dates.push(this.$utils.getDate(list[i]))
                }
                this.$refs.popup.open();
            },
            changeSpan(index){
                this.active = index
            },
            changeTime(index){
                this.time_active =index;
            },
            closeTime(){
                this.date =this.active===0?`${this.dates[this.active]} ${this.times1[0].time}`:`${this.dates[this.active]} ${this.times[this.time_active].time}`
                this.$refs.popup.close();
            },
			// 成功上传图片
			successImage(e){
                this.fileList=e
			},
            // 获取订单数据
            async getOrder() {
                let data = {
                    "expand": "orderOrderProducts"
                }
                const res =await this.$api.reqOrders(data,'get',this.id)
                this.big_data = res.data;
                for (let i in res.data.orderOrderProducts) {
                    if (res.data.orderOrderProducts[i].order_product_product_id === this.pid) {
                        this.data = res.data.orderOrderProducts[i]
                        this.max_value = res.data.orderOrderProducts[i].order_product_count
                    }
                }
            },
            // 减少数量
			Sub() {
                if(this.value>1){
                    this.value--
                }

			},
			// 增加数量
			Add() {
                if(this.value<this.max_value){
                    this.value++
                }
			},
			// 合计
			Sum(e, index) {

			},
			discard() {
				//丢弃
            },
            //添加售后
            afterSales(){
                if(!this.content){
                    this.$store.state.is_error = true
                    return  this.$utils.Toast('请填写退货原因');
                }
                let data;
                if(this.index===0){
                    data = {
                        'refund_merchant_account':'default',
                        'refund_order_id':this.id,
                        'refund_product_id':this.pid,
                        'refund_product_sku_id':this.data.order_product_product_sku_id,
                        'refund_product_count':this.value,
                        'refund_reason':this.content,
                        'refund_images':this.fileList
                    }
                    this.$api.postRefunds(data,'post').then(res=>{
                        if(res.data.success){
                            this.$store.state.is_error = false
                            this.$utils.Toast( res.data.message);
                            uni.navigateTo({
                                url:`/orders/afterSuccess/AfterSuccess?type=0&id=${this.id}&rid=${res.data.info.refund_id}`
                            })
                        }else{
                            this.$store.state.is_error = true
                            this.$utils.Toast(res.data.message);
                        }
                    })
                }else{
                    data = {
                        'aftersale_order_id':this.id,
                        'aftersale_product_count':this.value,
                        'aftersale_product_sku_code':this.data.order_product_sku_code,
                        'aftersale_reason':this.content,
                        'aftersale_images':this.fileList,
                    }
                    this.$api.postAftersales(data).then(res=>{
                        if(res.data.success){
                            this.$store.state.is_error = false
                            this.$utils.Toast("setTips", res.data.message);
                            uni.navigateTo({
                                url:`/orders/afterSuccess/AfterSuccess?type=0&id=${this.id}&rid=${res.data.info.aftersale_id}`
                            })
                        }else{
                            this.$store.state.is_error = true
                            this.$utils.Toast(res.data.message);
                        }
                    })
                }

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
					width: 150rpx;
					height: 150rpx;
				}
			}
			.info{
				width: 70%;
				.title{
					font-size: 30rpx;
					overflow: hidden;
					text-overflow: ellipsis;
					white-space: nowrap;
					line-height: 80rpx;
				}
				.des{
					font-size:26rpx;
					color: #666666;
					text{
						margin-right: 20rpx;
					}
				}
			}
        }
        .numbers{
            padding:30rpx;
            .name{
                text-align: left;
                width: 70%;
                font-size: 30rpx;
            }
            .number {
                width: 30%;
                display: flex;
                justify-content: center;
                align-items: flex-end;
                position: relative;
                bottom: 10rpx;
                .input {
                    width: 45upx;
                    height: 45upx;
					line-height: 50rpx;
                    margin: 0 10upx;
                    background-color: #f3f3f3;

                    input {
                        width: 45upx;
                        height: 45upx;
						line-height: 50rpx;
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        text-align: center;
                        font-size: 30upx;
                    }
                }

                .sub,
                .add {
                    width: 45upx;
                    height:45upx;
					line-height: 50rpx;
                    background-color: #f3f3f3;
                    border-radius: 5upx;

                    .icon {
                        font-size: 50upx;
                        width: 45upx;
						line-height: 50rpx;
                        height: 45upx;
                        display: flex;
                        justify-content: center;
                        align-items: center;
                    }
                }
            }
        }
    }
    .edit{
        background: #FFFFFF;
        margin: 30rpx 20rpx;
        font-size: 30rpx;
        padding: 20rpx;
        border-radius: 10rpx;
        .title{
            .name{
                text-align: left;
                width: 25%;
                font-size: 28rpx;
                color: #666666;
            }
            .choose{
                width: 75%;
                text-align:right;
                font-size: 28rpx;
                i{
                    margin-left: 10rpx;
                }
            }
        }
        .content{
            width: 100%;
            height: 250rpx;
            padding: 20rpx 0;
            position: relative;
            textarea{
                width: 100%;
                height: 100%;
                background: #f6f6f6;
                border-radius: 10rpx;
                box-sizing: border-box;
                padding:20rpx;
                font-size: 28rpx;
            }
            text{
                position: absolute;
                right: 20rpx;
                bottom: 30rpx;
            }
        }
        .upload-box{
            .wain{
                font-size: 26rpx;
                color: red;
				margin-top: 20rpx;
            }
        }
    }
    .types{
        background: #FFFFFF;
        font-size: 28rpx;
        margin: 0 30rpx;
        border-radius: 20rpx;
        line-height: 80rpx;
        padding: 0 30rpx;
        text:first-child{
            text-align: left;
            width: 25%;
            color: #666666;
        }
        text:last-child{
            text-align: right;
            width: 75%;
            font-weight: bold;
        }
    }
    .types1{
        background: #FFFFFF;
        font-size:28rpx;
        margin: 0 30rpx;
        border-radius: 20rpx;
        line-height: 80rpx;
        padding: 0 30rpx;
        .title{
            .name{
                text-align: left;
                width: 25%;
                font-size: 28rpx;
                color: #666666;
            }
            .choose{
                width: 75%;
                text-align:right;
                font-size:28rpx;
                i{
                    margin-left: 10rpx;
                }
            }
        }
        .address {
            margin: 10rpx 0;
            .center {
                text-align: left;
                font-size: 26rpx;
                margin-left: 20rpx;
                flex: 1;
                line-height: 50rpx;
                text:first-of-type {
                    color: #000000;
                    font-weight: 600;
                }
                text:last-of-type {
                    color: #aaaaaa;
                }
            }
            .icon-youjiantou {
                color: #000000;
                font-weight: 600;
                font-size: 24px;
            }
        }
        .date{
            .icon-riqi{
                font-size: 32rpx;
                margin-right: 10rpx;
            }
            .dates{
                font-size: 14px;
            }
        }
    }
    button{
        margin:60rpx 30rpx 0;
        line-height: 80rpx;
        background: $themeColor;
        color: #FFFFFF;
        border: none;
    }
}
/*时间*/
.date_content{
    padding: 50rpx 40rpx 20rpx;
    background: #FFFFFF;
    height: 55vh;
    position: relative;
    i{
        position: absolute;
        right: 30rpx;
        top: 30rpx;
        font-size: 46rpx;
    }
    .left{
        width: 35%;
        flex-direction: column;
        font-size: 32rpx;
        text{
            line-height: 100rpx;
            height: 100rpx;
            background: #eeeeee;
            color: #bbbbbb;
        }
        .active{
            background: #ffffff;
            color: #000000;
        }
    }
    .right{
        flex: 1;
        margin-left: 20rpx;
        view{
           flex-direction: column;
            text{
                text-align: left;
                border-radius: 10rpx;
            }
            .title{
                font-size: 24rpx;
                color: #bbbbbb;
            }
            text:last-of-type{
                height: 100rpx;
                line-height: 100rpx;
                margin: 40rpx;
                display: inline-block;
                background: #eeeeee;
                color: #000000;
                width: 50%;
                text-align: center;
                font-size: 24rpx;
            }
            text.active{
                background: #ffd7e0;
                color: #ff4a4f;
                border: 1px solid #ff4a4f;
            }

        }
        view:first-of-type{
            margin-bottom: 40rpx;
        }
    }
}

</style>
