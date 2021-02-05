<template>
  <view class="info-box lighter-icon">
    <template v-if="!next">
      <text class="wain">为确认身份,我们仍需验证您的手机号</text>
      <view class="info">
        点击发送验证码,将会发送一条短信到您的手机<text class="font-text">{{
          phone
        }}</text>
      </view>
      <view class="code u-f u-f-jsb u-f-ac">
        <input type="text" v-model="code" placeholder="输入验证码" />
        <text class="font-text" @tap="getCodeVerify">{{ timerText }}</text>
      </view>
      <text class="mix-btn u-f u-f-jsc" @click="Next">下一步</text>
    </template>
    <view v-else class="update">
      <view class="u-f u-f-jsb u-f-ac">
        <text>手机号</text>
        <input
          type="number"
          maxlength="11"
          v-model="newPhone"
          placeholder="输入新手机号"
          placeholder-class="pinput"
          @blur="phoneVerify('memberinfo_mobile')"
        />
        <text
          class="iconfont"
          :class="[{ 'icon-right': isPhone, 'icon-cuo': isPhone === false }]"
        ></text>
      </view>
      <text class="fail">{{ tips_phone }}</text>
      <view class="u-f u-f-jsb u-f-ac">
        <text>验证码</text>
        <input
          type="text"
          v-model="newCode"
          placeholder="输入验证码"
          placeholder-class="pinput"
        />
        <text class="font-text" @tap="getNewCode">{{ newTimerText }}</text>
      </view>
      <text class="mix-btn u-f u-f-jsc" @click="Confirm">确 定</text>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      code: "",
      phone: "",
      timerText: "发送验证码",
      timer: 0,
      next: false,
      newCode: "",
      newPhone: "",
      newTimerText: "发送验证码",
      newTimer: 0,
      tips_phone: "",
      isPhone: null,
    };
  },
  components: {},
  onLoad() {
    this.getUserInfo();
  },
  onShow() {},
  mounted() {},

  methods: {
    // 验证手机号
    phoneVerify(val) {
      setTimeout(() => {
        switch (val) {
          case "memberinfo_mobile":
            if (!this.newPhone) {
              this.tips_phone = "请输入手机号";
              this.isPhone = false;
              return;
            } else if (!this.$verify.isPhone(this.newPhone)) {
              this.tips_phone = "请输入正确的手机号";
              this.isPhone = false;
              return;
            }

            this.Confirm("validate", "memberinfo_mobile");
            this.tips_phone = "";
            this.isPhone = true;
            break;
        }
      }, 250);
    },
    // 获取会员信息
    async getUserInfo() {
      const res = await this.$api.getUserInfo();
      this.phone = res.data.info.memberinfo_mobile;
    },
    // 获取旧手机验证码
    async getCodeVerify() {
      if (this.timer !== 0) {
        return this.$utils.Toast( "请务重复发送");
      }
      const res = await this.$api.getCodeVerify(this.phone, "change", "sms");

      if (res.data.success) {
        this.$store.state.is_error = false;
        this.$utils.Toast(res.data.message);
        this.timer = 60;
        const timer = setInterval(() => {
          if (this.timer === 0) {
            this.timerText = "发送验证码";
            clearInterval(timer);
          } else {
            this.timer -= 1;
            this.timerText = `(${this.timer}s)后重新发送`;
          }
        }, 1000);
      } else {
        this.$utils.Toast(res.data.message);
      }
    },
    //下一步
    Next() {
      let data = {
        phone: this.phone,
        code: this.code,
        method: "sms",
      };
	  if (!this.code) {
		  return this.$utils.Toast('请先输入验证码')
	  }
	  console.log(data)
      this.$api.getVerifyChange(data).then((res) => {
		  // this.$utils.Toast(res.data.message);
		  console.log(res)
        // if (res.data.success) {
        //   this.next = true;
        // } else {
        //   this.$utils.Toast(res.data.message);
        //   this.next = false;
        // }
      });
    },
    // 获取新手机号验证码
    async getNewCode() {
      if (!this.$verify.isPhone(this.newPhone)) {
        this.$utils.Toast("请输入正确的手机号");
        return;
      }
      if (this.newTimer !== 0) {
        return this.$utils.Toast("请务重复发送");
      }
      const res = await this.$api.getCodeVerify(this.newPhone, "verify", "sms");
      if (res.data.success) {
        this.$store.state.is_error = false;
        this.$utils.Toast(res.data.message);
        this.newTimer = 60;
        const timer = setInterval(() => {
          if (this.newTimer === 0) {
            this.newTimerText = "发送验证码";
            clearInterval(timer);
          } else {
            this.newTimer -= 1;
            this.newTimerText = `(${this.newTimer}s)后重新发送`;
          }
        }, 1000);
      } else {
        this.$utils.Toast(res.data.message);
      }
    },
    // 确定
    Confirm(v1, v2) {
      if (!v1 === "validate") {
        if (!this.newPhone || !this.newCode) {
          return this.$utils.Toast( "请输入完整信息");
        }
      }
      let data = {
        memberinfo_mobile: this.newPhone,
        mobileVerifyCode: this.newCode,
        mobileChangeCode: this.code,
      };
      if (v1 === "validate") {
        data.ajax = "validate";
      }
      this.$api.putUpdateMy(data).then((res) => {
        if (v1 === "validate") {
          for (let i in res.data) {
            if (i === v2) {
              switch (i) {
                case "memberinfo_mobile":
                  this.isPhone = false;
                  this.tips_phone = res.data[i][0];
                  break;
              }
            }
          }
          return;
        }
        if (res.data.success) {
          this.$store.state.is_error = false;
          this.$utils.Toast(res.data.message);
          this.getUserInfo();
          setTimeout(() => {
            uni.navigateTo({
              url: "/center/set/Set",
            });
          }, 1000);
        } else {
          this.$utils.Toast(res.data.message);
        }
      });
    },
  },
};
</script>

<style lang="scss">
.info-box {
  padding: 30rpx;
  font-size: 34rpx;
  .wain {
    font-weight: bold;
  }
  .info {
    margin: 30rpx 0;
  }
  .code {
    input {
      border: 1px solid #eeeeee;
      width: 60%;
      font-size: 32rpx;
      padding: 20rpx;
    }
    text {
      font-size: 28rpx;
    }
  }
  .mix-btn {
    margin-top: 100rpx;
    width: 90%;
  }
}
.update > view {
  border-bottom: 1px solid #eeeeee;
  font-size: 32rpx;
  padding: 36rpx 0;
  .pinput {
    color: #999999;
  }
  input {
    font-size: 32rpx;
    padding-left: 30rpx;
    flex: 1;
  }
}
.fail {
  color: red;
  font-size: 30rpx;
}
.icon-cuo {
  color: red;
}
.icon-right {
  color: #019a46;
}
</style>
