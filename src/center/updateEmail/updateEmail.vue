<template>
  <view class="info-box lighter-icon">
    <template v-if="old_email && !next">
      <text class="wain">为确认身份,我们仍需验证您的邮箱地址</text>
      <view class="info">
        点击发送验证码,将会发送一条有验证码的邮件至邮箱<text
          class="font-text"
          >{{ old_email }}</text
        >
      </view>
      <view class="code u-f u-f-jsb u-f-ac">
        <input type="text" v-model="code" placeholder="输入验证码" />
        <text class="font-text" @tap="getCodeVerify">{{ timerText }}</text>
      </view>
      <text class="mix-btn u-f u-f-jsc" @click="Next">下一步</text>
    </template>
    <view v-else class="update">
      <view class="u-f u-f-jsb u-f-ac">
        <text>邮箱地址</text>
        <input
          v-model="new_email"
          placeholder="输入邮箱地址"
          placeholder-class="pinput"
          @blur="phoneVerify('memberinfo_email')"
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
          v-model="new_code"
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
      old_email: "",
      new_email: "",
      timerText: "发送验证码",
      timer: 0,
      next: false,
      new_code: "",
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
    // 验证邮箱
    phoneVerify(val) {
      setTimeout(() => {
        switch (val) {
          case "memberinfo_email":
            if (!this.new_email) {
              this.tips_phone = "请输入邮箱地址";
              this.isPhone = false;
              return;
            } else if (!this.$verify.isEmail(this.new_email)) {
              this.tips_phone = "请输入正确的邮箱地址";
              this.isPhone = false;
              return;
            }

            this.Confirm("validate", "memberinfo_email");
            this.tips_phone = "";
            this.isPhone = true;
            break;
        }
      }, 250);
    },
    // 获取会员信息
    async getUserInfo() {
      const res = await this.$api.getUserInfo();
      this.old_email = res.data.info.memberinfo_email;
    },
    // 获取旧手机验证码
    async getCodeVerify() {
      if (this.timer !== 0) {
        return this.$utils.Toast( "请务重复发送");
      }
      const res = await this.$api.getCodeVerify(
        this.old_email,
        "change",
        "smtp"
      );
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
        phone: this.old_email,
        code: this.code,
        method: "smtp",
      };
      this.$api.getVerifyChange(data).then((res) => {
        if (res.data.success) {
          this.next = true;
        } else {
          this.$utils.Toast( res.data.message);
          this.code = "";
          this.next = false;
        }
      });
    },
    // 获取新手机号验证码
    async getNewCode() {
      this.phoneVerify("memberinfo_email");
      if (!this.new_email) {
        return;
      }
      if (this.newTimer !== 0) {
        return this.$utils.Toast("请务重复发送");
      }
      const res = await this.$api.getCodeVerify(
        this.new_email,
        "verify",
        "smtp"
      );
      if (res.success) {
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
        if (!this.new_email || !this.new_code) {
          return this.$utils.Toast("请输入完整信息");
        }
      }
      let data = {
        memberinfo_email: this.new_email,
        emailVerifyCode: this.new_code,
        emailChangeCode: this.code,
      };
      if (v1 === "validate") {
        data.ajax = "validate";
      }
      this.$api.putUpdateMy(data).then((res) => {
        if (v1 === "validate") {
          for (let i in res.data) {
            if (i === v2) {
              switch (i) {
                case "memberinfo_email":
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
