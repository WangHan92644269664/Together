<template>
  <view class="bank-box lighter-icon">
    <view class="content-box">
      <view class="item" v-if="flag">
        <uni-icons type="email-filled" size="25" color="#fff"></uni-icons>
        <view class="right">
          <view class="title">
            <text>{{ user_info.data.bank_name }}</text>
            <!-- <text @tap="Del(user_info.data.bank_id)">删除</text> -->
            <text @tap="toDetail(user_info.data.bank_id)">修改</text>
          </view>
          <text class="name"
            >持卡人：{{ user_info.info.memberinfo_bank_name }}</text
          >
          <text>{{ bank_no }}</text>
        </view>
      </view>
      <navigator
        class="add u-f u-f-ac u-f-jsc"
        url="../addBank/AddBank"
        hover-class="none"
        v-if="!flag"
      >
        <uni-icons type="plus" size="20" color="#555"></uni-icons>
        <text>添加银行卡</text>
      </navigator>
    </view>
  </view>
</template>

<script>
import uniIcons from "@dcloudio/uni-ui/lib/uni-icons/uni-icons.vue";
export default {
  data() {
    return {
      user_info: null,
      bank_no: "",
      flag: false,
    };
  },
  computed: {},
  onLoad(options) {},
  onShow() {
    this.getUserInfo();
  },
  mounted() {},
  methods: {
    getUserInfo() {
      this.$utils.postUrl("GET", "/site/contact").then((res) => {
        console.log(res);
        let user_info = res.data;
        this.user_info = user_info;
        let bank_no = user_info.info.memberinfo_bank_no;
        if (bank_no) {
          this.flag = true;
          this.bank_no = this.$utils.sliStr(bank_no);
        }
      });
    },
    Del(id) {
      console.log(id);
      let data = {
        memberinfo_bank_name: "",
        memberinfo_bank_id: "",
        memberinfo_bank_branch: "",
        memberinfo_bank_no: "",
      };
      this.$utils.postUrl("PUT", "/memberinfos/update-my", data).then((res) => {
		this.$utils.Toast(res.data.message);
        if (res.data.success) {
          this.$store.state.is_error = false;
          setTimeout(() => {
            uni.navigateBack();
          }, 1000);
        } 
      });
    },
    toDetail(id) {
      uni.navigateTo({
        url: "/center/addBank/AddBank?id=" + id,
      });
    },
  },
  components: {
    uniIcons,
  },
};
</script>

<style lang="scss">
.content-box {
  margin: 0 20rpx;

  .item {
    margin-top: 20rpx;
    background: linear-gradient(to right, #21b472, #11a45c, #029448);
    border-radius: 20rpx;
    padding: 20rpx;
    display: flex;
    justify-content: space-between;

    .right {
      margin-left: 20rpx;
      display: flex;
      flex-direction: column;
      text-align: left;
      width: 100%;
      color: #ffffff;

      .title {
        display: flex;
        justify-content: space-between;

        text:last-child {
          font-size: 24rpx;
        }
      }

      text.name {
        margin: 20rpx 0;
        font-size: 28rpx;
      }
    }
  }

  .add {
    margin: 40rpx auto;
    color: #555555;
    text-align: center;
	font-size: 28rpx;

    text {
      margin-left: 20rpx;
    }
  }
}
</style>
