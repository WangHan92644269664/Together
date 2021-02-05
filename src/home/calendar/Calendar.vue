<template>
	<view class="notice">
    <view class="cal-title u-f u-f-jsb">
      <text>每日签到</text>
      <text class="day">已签 <text class="font-text">{{num}}</text> 天</text>
    </view>
    <template v-if="show">
      <uni-calendar
         :insert="true"
         :lunar="false" 
         :selected="selected"
         :showMonth="false"
          >
        </uni-calendar>
    </template>
       <view class="calbtn u-f u-f-jsc">
         <button size="mini" class="background-text" @click="Submit" v-if="!isSign">签到</button>
         <button size="mini" class="background-text disabled" v-else>已签到</button>
       </view>
	</view>
</template>
<script>
  import uniCalendar from '@/components/uni-calendar/uni-calendar.vue'
  import moment from 'moment'
	export default {
		name: "Notice",
		data() {
			return {
				data: [],
        selected: [],
        num: 0,
        show: false,
        isSign: false
			};
		},
		created() {
      this.getLists()
		},
    components:{
      uniCalendar
    },
		methods: {
      async getLists () {
        const data = {
          'per-page': 1000
        }
        const res = await this.$api.reqSigns(data, 'get')
        this.num = res.header['x-pagination-total-count']
        this.data = res.data
        const month = moment().month() +1 < 10 ? `0${moment().month() + 1}` : moment().month() + 1
        const day = moment().date() < 10 ? `0${moment().date() }` : moment().date()
        const now = `${moment().year()}-${month}-${day}`
        for (const i in res.data) {
          if (res.data[i].sign_add_datetime.split(' ')[0] === now) {
            this.isSign = true
          }
          console.log(res.data[i].sign_add_datetime.split('-')[1], month)
          if (res.data[i].sign_add_datetime.split('-')[1] === month) {
            this.selected.push({
              date: res.data[i].sign_add_datetime.split(' ')[0],
              info: '已签'
            })
          }
        }
        this.show = true
      },
      async Submit () {
        const res = await this.$api.reqSigns({}, 'post')
        this.$utils.Toast(res.data.message, res.data.success ? 'success' : 'none')
        if (res.data.success) {
          this.selected = []
          this.getLists()
        }
      }
		},
	};
</script>
<style lang="scss" scoped>
.cal-title{
  font-size: 30rpx;
  padding: 30rpx;
  border-bottom: 1px solid #c8c7cc;
  .day{
    color: #AAAAAA;
    text{
      margin: 0 10rpx;
    }
  }
}
.calbtn{
    margin: 50rpx 0;
    button{
      color: #FFFFFF;
      width: 30%;
      border-radius: 60rpx;
    }
    .disabled{
      background: #bbbbbb;
    }
  }
</style>
