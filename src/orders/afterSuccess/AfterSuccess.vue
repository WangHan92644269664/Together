<template>
  <view class="order lighter-icon">
    <view class="top u-f">
      <text class="iconfont icon-order-success"></text>
      <text class="title">售后服务单申请成功</text>
      <text class="time"> 预计 <text class="red">1小时40分钟</text>内为您审核，请保持手机畅通，耐心等待</text>
      <view class="btn">
        <!-- <text @tap="Go(data.order_id)">查询详情</text> -->
        <text @tap="Detail">售后主页</text>
      </view>
    </view>
    <view class="center">
      <view><text>服务类型: </text> <text>{{type===0?'退货':'售后'}}</text></view>
      <view><text>返件方式: </text> <text>原支付返还</text></view>
    </view>
    <view class="bottom">
      <view><text>联系人: </text> <text>{{name}}</text></view>
      <view><text>联系电话: </text> <text>{{phone}}</text></view>
      <text class="info">
        服务单审核通过后，请在规定时间内完成发货并在服务单详情页内填写运单号，否则服务单将会自动关闭，
        您可在服务单详情页查看商品寄回地址。
      </text>
    </view>
  </view>
</template>

<script>
  export default {
    name: "Order",
    data() {
      return {
        name:'',
        phone:'',
        data:'',
        type:'',
        id:'',
        rid:''
      }
    },
    onLoad(option) {
      let user = uni.getStorageSync('userInfo')
      this.name = user.memberinfo_realname ? user.memberinfo_realname : "未填"
      this.phone = user.memberinfo_mobile.substr(0, 3) + "****" + user.memberinfo_mobile.substr(7)
      let type = Number(option.type)   //0是退货  1是售后
      this.type = type
      let id = option.id
      this.id = id
      let rid = option.rid
      this.rid = rid

    },
    methods: {
      Go(){
        uni.navigateTo({
            url:`/orders/detail/Detail?id=${this.id}&status=3&type=${this.type}&rid=${this.rid}`
        })
      },
      Detail(){
        uni.navigateTo({
            url:'/orders/afterSale/AfterSale?index=3'
        })
      }
    }
  }
</script>

<style lang="scss" scoped>
@import '@/common/css/mixin';
  .order{
    .top{
      margin: 50rpx auto 0;
      flex-direction: column;
      border-bottom: 1px solid #eeeeee;
      text-align: center;
      .title{
        margin:20rpx 0;
        font-weight: bold;
        font-size: 28rpx;
      }
      .time{
        margin:0 30rpx;
        font-size: 26rpx;
        .red{
          color: red;
        }
      }
      .iconfont{
        color: $themeColor;
        font-size: 100rpx;
      }
      .btn{
        margin-top: 80rpx;
        margin-bottom: 50rpx;
        text{
          padding: 8rpx 30rpx;
          border-radius: 50rpx;
          border:1px solid #aaaaaa;
          font-size: 28rpx;
        }
        text:first-of-type{
          margin-right: 20rpx;
        }
      }
    }
    .center,.bottom{
      margin:0 50rpx;
      padding: 50rpx 0;
      font-size: 28rpx;
      view>text:first-of-type{
        color: #aaaaaa;
      }
      view{
        line-height: 40rpx;
      }
    }
    .center{
      border-bottom: 1px solid #eeeeee;
    }
    .bottom{
      .info{
        color: #bbbbbb;
        font-size: 24rpx;
        margin-top: 30rpx;
        display: inline-block;
        line-height: 40rpx;
      }
    }
  }
</style>
