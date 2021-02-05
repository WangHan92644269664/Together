<template>
	<view class="coupon lighter-icon">
        <!-- 顶部导航 -->
		<view class="topTabBar" :style="{position:headerPosition,top:headerTop}">
			<view class="grid" v-for="(grid,tbIndex) in orderType" :key="tbIndex" @tap="showType(tbIndex)">
				<view class="text" :class="[tbIndex==tabbarIndex?'on':'']">{{grid}}</view>
			</view>
		</view>
        <view class="search u-f">
            <view class="int">
                <input v-model="code" type="text" placeholder="请输入兑换码">
            </view>
            <text class="exchange" @click="onExchange">兑换</text>
        </view>
        <view v-if="coupons.length>0">
            <view class="list u-f" v-for="(item,index) in coupons" :key="index">
                <view class="left">
                    <view class="money" v-if="item.couponCouponType.coupon_type_result.money"><text>￥</text><text>{{item.couponCouponType.coupon_type_result.money}}</text></view>
                    <view class="money" v-else-if="item.couponCouponType.coupon_type_result.discount"><text>打</text><text>{{item.couponCouponType.coupon_type_result.discount}}</text>折</view>
                    <view class="use" v-if="item.couponCouponType.use_reason">{{item.couponCouponType.use_reason}}</view>
                    <view class="use" v-else>无门槛使用</view>
                    <view class="use-if" @tap="Help(item.couponCouponType.couponCondition)"><i class='iconfont icon-wenti'></i>使用条件</view>
                </view>
                <view class="center">
                    <view class="title">{{item.couponCouponType.coupon_type_name}}</view>
                    <template v-if="tabbarIndex===0">
                        <view class="time">有效期截止至</view>
                        <view class="time1">{{item.couponCouponType.coupon_type_end_datetime}}</view>
                    </template>
                    <template v-else-if="tabbarIndex===1">
                        <view class="time">使用时间为</view>
                        <view class="time1">{{item.coupon_use_datetime}}</view>
                    </template>
                    <template v-else-if="tabbarIndex===2">
                        <view class="time">失效时间为</view>
                        <view class="time1">{{item.coupon_expire_datetime}}</view>
                    </template>
                </view>
                <view class="right">
                    <view @click="Receive" v-if="tabbarIndex===0">去使用</view>
                    <view v-else-if="tabbarIndex===1" class="gray">已使用</view>
                    <view v-else-if="tabbarIndex===2" class="gray">已失效</view>
                </view>
            </view>
        </view>
        <view v-else class="no-data">暂无数据</view>
        <uni-popup ref="popup" type="bottom">
            <scroll-view :scroll-y='true' class="if">
                <view class="top"><i class='iconfont icon-wenti'></i>需同时满足以下条件才能使用消费券</view>
                <view class="li" v-for="(item,index) in limitList" :key="index">
                    <view class="title">{{index+1}}.使用条件：{{item.condition_name}}</view>
                    <view class="if-if" v-for="(item1,index1) in item.condition" :key="index1">
                        <template v-if="item1">
                            <view v-show="item1.product_class_name">• {{item1.product_class_name}}</view>
                            <view v-show="item.condition_params">购买数量需满足（大于或等于）{{item.condition_params.num}}</view>
                            <view v-show="item1.product_name">• {{item1.product_name}}</view>
                        </template>
                    </view>
                </view>
            </scroll-view>
        </uni-popup>
        <tips></tips>
	</view>
</template>

<script>
import uniPopup from '@/components/uni-popup/uni-popup.vue'
	export default {
        components: {
            uniPopup
        },
		data() {
			return {
                headerPosition: "fixed",
				headerTop: "0px",
                orderType: ['未使用', '已使用', '已失效'],
                tabbarIndex: 0,
                coupons:[],
                code:'',
                limitList:''
			}
		},
        onPageScroll(e) {
			return;
			//兼容iOS端下拉时顶部漂移
			this.headerPosition = e.scrollTop >= 0 ? "fixed" : "absolute";
		},
		onLoad() {
			//兼容H5下排序栏位置
			// #ifdef H5
			let Timer = setInterval(() => {
				let uniHead = document.getElementsByTagName('uni-page-head');
				if (uniHead.length > 0) {
					this.headerTop = uniHead[0].offsetHeight + 'px';
					clearInterval(Timer); //清除定时器
				}
			}, 1);
            // #endif
            this.getUserCoupon(this.tabbarIndex+1)
		},
		onShow() {
		},
		methods: {
            showType(tbIndex) {
				this.tabbarIndex = tbIndex;
				this.getUserCoupon(tbIndex+1)	
            },
            //显示详情页面
            Help(data){
                this.$refs.popup.open();
                console.log(data);
                this.limitList=data;
            },
             //兑换消费券
            onExchange() {
                this.$api.getCodeCoupon(this.code).then(res=>{
					this.$utils.Toast(res.data.message);
                    if(res.data.success){
                        this.$store.state.is_error = false
                    }else{
                        this.$store.state.is_error = true
                    }
                })
            },
            //跳转到首页进行购物
            Receive(){
                uni.switchTab({
                    url:'/pages/home/index'
                })
            },
            // 获取消费券数据
            async getUserCoupon(id) {
                this.coupons=[];
                let data={
                    'status':id
                }
                const res = await this.$api.reqCoupon(data)
                let datas=res.data
                for(let i in datas){
                    this.coupons.push(datas[i]);
                }
            },
		}
	}
</script>

<style lang='scss'>
.coupon{
    padding-top: 250upx;
}
.topTabBar {
    width: 100%;
    position: fixed;
    top: 0;
    z-index: 10;
    background-color: #fff;
    height: 80upx;
    display: flex;
    justify-content: space-around;
    border-top: 3px solid #F2F3F3;

    .grid {
        width: 20%;
        height: 80upx;
        display: flex;
        justify-content: center;
        align-items: center;
        color: #444;
        font-size: 30rpx;

        .text {
            height: 76upx;
            display: flex;
            align-items: center;

            &.on {
                color: #000;
                border-bottom: solid 3px #000;
                font-size: 34rpx;
            }
        }

    }
}
.search{
    position: fixed;
    top: 170upx;
    width: 100%;
    box-sizing: border-box;
    padding: 40upx 30upx;
    background: #FFFFFF;
    .int{
        width: 75%;
        input{
            border: 1px solid #000;
            height: 70upx;
            padding: 0 20upx;
        }
    }
    .exchange{
        color: #FFFFFF;
        background: #000;
        text-align: center;
        display: inline-block;
        width: 25%;
        line-height: 70upx;
    }
}
.list{
    margin: 0 30upx;
    padding: 20upx;
    box-shadow: -5px 0 2px #eeeeee,
                0px 0px 2px #eeeeee, 
                -5px -5px 2px #eeeeee,
                5px 5px 2px #eeeeee;
    .left{
        width: 25%;
        font-size: 26upx;
        line-height: 40upx;
        border-right: 2px dashed #999999;
        .money{
            color: red;
            text:last-child{
                font-size: 40upx;
            }
        }
        .use{
            color: #666666;
        }
        .use-if{
            color: #999999;
        }
    }
    .center{
        width: 50%;
        font-size: 26upx;
        color: #999999;
        line-height: 45upx;
        padding-left: 30upx;
        .title{
            font-size: 32upx;
            color: #333;
            font-weight: bold;
        }
    }
    .right{
        width: 20%;
        view{
            font-size: 28upx;
            background: #039157;
            color: #FFFFFF;
            text-align: center;
            line-height: 70upx;
            height: 70upx;
            border-radius: 10upx;
            margin-top: 20upx;
            
        }
        .gray{
            background: #eee;
        }
    }
}
.no-data{
    text-align: center;
    font-size: 30upx;
    color: #666666;
}
.if{
    background: #FFFFFF;
    width: 100%;
    height: 600upx;
    .top{
        font-size: 32upx;
        color: #BD8E3E;
        text-align: center;
        border-bottom: 1px solid #eeeeee;
        line-height: 100upx;
    }
    .li{
        padding: 0 30upx;
        .title{
            font-size: 30upx;
            line-height: 60upx;
        }
        .if-if{
            font-size: 26upx;
            color: #666666;
            view{
                line-height: 40upx;
                padding: 10upx;
                margin: 10upx 0;
                -webkit-box-shadow: 0 0 10upx #ccc;
                box-shadow: 0 0 10upx #ccc;
            }
        }
    }
}
</style>
