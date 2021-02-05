<template>
  <view class="message lighter-icon">
    <view class="wrap chatvc" ref="chat">
      <block v-for="(item,index) in data" :key="index">
        <!--左边-->
        <view v-if="item.messages_is_reply===1" class="date">{{getTime(item.messages_add_datetime)}}</view>
        <view class="chat-cell animated u-f-ac" v-if="item.messages_sender_account===null">
          <img :src="img_url+'logo.png'" class="left image" />
          <view class="chat-content">
            <text class="title">{{item.messages_content}}</text>
          </view>
        </view>
        <!--右边-->
        <view :class="['chat-cellr','fadeInRight']" v-else class="animated u-f-ac">
          <view :class="['image','right']">
            <img :src="avatar+userInfo.memberinfo_avatar_image" class="image" />
          </view>
          <view :class="['chat-contentr']">
            <text class="titler">{{item.messages_content}}</text>
          </view>
        </view>
      </block>
    </view>
    <view class="operate-section u-f u-f-jsb u-f-ac member">
      <textarea
        class="input"
        cols="50"
        rows="1"
        v-model="keyword"
        ref="element"
        @keyup.enter="messageBtnClick"
      ></textarea>
      <text @click="messageBtnClick" class="btn background-text">发送</text>
    </view>
  </view>
</template>

<script>
export default {
  name: "Message",
  data() {
    return {
      data: [], // 记录
      page: 1,
      sum_page: 1,
      more: false,
      err_data: [],
      keyword: "",
      userInfo: "",
      avatar: this.$utils.imgUrl + "avatar/",
	  img_url:this.$utils.webImg2
    };
  },
  components: {},
  onLoad() {
    this.getMessage();
    this.postMessage();
    this.getUserInfo();
  },
  computed: {},
  methods: {
    //时间格式化
    getTime(val) {
      val = val.replace(/-/g, "/");
      let date1 = val.split(" ")[0];
      date1 = Date.parse(date1);
      let nowDate = new Date(); //获取当前时间
      let full =
        nowDate.getFullYear() +
        "/" +
        (nowDate.getMonth() + 1) +
        "/" +
        nowDate.getDate();
      let date = Date.parse(full); //获取当前时间的年月日
      if (date1 === date) {
        //今天
        return val.split(" ")[1];
      } else if (
        Date.parse(nowDate) - Date.parse(val) ===
        1000 * 60 * 60 * 24
      ) {
        //昨天
        return "昨天 " + val.split(" ")[1];
      } else if (
        Date.parse(nowDate) - Date.parse(val) ===
        1000 * 60 * 60 * 24 * 2
      ) {
        //前天
        return "前天 " + val.split(" ")[1];
      } else {
        return val.replace(/-/g, "/"); //很多天前
      }
    },
    // 获取留言
    async getMessage(page) {
      if (page > this.sum_page) {
        this.more = true;
        return;
      }
      let data = {
        page: page,
        "per-page": 200000
      };
      const res = await this.$api.getMessages(data);
      this.data = this.data.concat(res.data);
      console.log(res)
        this.sum_page = res.header["x-pagination-page-count"];
        let sumCount = res.header["x-pagination-total-count"];
        if (sumCount === this.length) {
          this.more = true;
        }
    },
    // 获取会员信息
    async getUserInfo() {
      const res = await this.$api.getUserInfo();
      if (res.data.success) {
        this.userInfo = res.data.info;
      }
    },
    //提交已经看过消息
    postMessage() {
      let data = {
        memberinfo_new_message: 0
      };
    this.$api.putUpdateMy(data)
    },
    //发送消息
    messageBtnClick() {
      if (this.keyword === "") {
						 this.$utils.Toast('发送内容不能为空');
        return false;
      }
      this.data.push({
        messages_sender_account: this.account,
        messages_content: this.keyword
      });
      let data = {
        messages_content: this.keyword
      };
      this.$api.postMessage(data).then(res => {
        if (res.data.success) {
          this.keyword = "";
        }
      });
    }
  }
};
</script>

<style lang="scss" scoped>
.message {
  display: flex;
  flex-direction: column;
  margin-top: 20rpx;
}
.date {
  font-size: 30rpx;
}

.chat-cell,
.chat-cellr {
  position: relative;
  height: auto;
  display: flex;
  flex-direction: row;
  margin-bottom: 30rpx;
  padding: 20rpx 80rpx;
}

.chat-content,
.chat-contentr {
  background: #dddddd;
  padding: 15rpx;
  border-radius: 10rpx;
  box-shadow: 0 0 10rpx 0 #999999;
  white-space: normal;
  word-break: break-all;
  position: relative;
  font-size: 34rpx;
  margin-left: 35rpx;
}

.chat-content:after {
  position: absolute;
  width: 0;
  height: 0;
  content: "";
  top: 10rpx;
  left: -38rpx;
  border-right: 20rpx solid #dddddd;
  border-top: 20rpx solid transparent;
  border-left: 20rpx solid transparent;
  border-bottom: 20rpx solid transparent;
}

.left {
  left: 0;
}

.image {
  width: 90rpx;
  height: 90rpx;
  position: absolute;
  border-radius: 100%;
}

.chat-cellr {
  padding: 0;
}

.fadeInRight {
  flex-direction: row-reverse;
}

.chat-contentr {
  background: #a6d4f2;
  margin: 0 115rpx;
}

.chat-contentr:after {
  position: absolute;
  width: 0;
  height: 0;
  content: "";
  top: 20%;
  right: -36rpx;
  border-right: 20rpx solid transparent;
  border-top: 20rpx solid transparent;
  border-left: 20rpx solid #a6d4f2;
  border-bottom: 20rpx solid transparent;
}

.right {
  right: 0;
}

.title,
.titler {
  line-height: 20rpx;
  text-align: left;
}

.wrap {
  flex: 1;
  padding: 0 20rpx;
  overflow-y: auto;
  overflow-x: hidden;
  flex-basis: 0%;
  flex-grow: 1;
  flex-shrink: 1;
}

.operate-section {
  position: fixed;
  bottom: 0;
  display: flex;
  width: 100%;
  box-shadow: 0 0 10rpx 0 #cccccc;
  padding: 18rpx 35rpx;
  background: #ffffff;

  .input {
    border: 1px solid #dddddd;
    width: 65%;
    padding: 0 20rpx;
    border-radius: 10rpx;
    color: #333333;
    height: 70rpx;
    line-height:70rpx;
    font-size: 30rpx;
  }

  .btn {
    width: 20%;
    font-size: 30rpx;
    color: #ffffff;
    padding: 17rpx 0;
    border-radius: 60rpx;
    box-sizing: border-box;
    margin-right: 40rpx;
    text-align: center;
  }
}
</style>
