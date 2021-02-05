<template>
	<view class="infoBox lighter-icon">
		<view class="content">
			<view class="item">
				<view class="input">
					<input type="number" placeholder="请输入手机号" v-model="phone" focus="true"  @blur="regInput('username')" />
					<text class="iconfont" :class="{'icon-dui':reg_username===1,'icon-cuo':reg_username===2}"></text>
				</view>
				<view class="err-tips" v-if="tip_username">{{tip_username}}</view>
			</view>
			<view class="item">
				<view class="input">
					<input type="text" placeholder="请输入验证码" v-model="code" class="code-input" />
					<text class="iconfont" :class="{'icon-dui':reg_verifyCode===1,'icon-cuo':reg_verifyCode===2}"></text>
					<text @tap="getCode" :style="{'background':getCodeBackColor}" class="font-size code">{{getCodeText}}</text>
				</view>
				<view class="err-tips" v-if="tip_verifyCode">{{tip_verifyCode}}</view>
			</view>
			<view class="item">
				<view class="input">
					<input type="password" placeholder="输入新密码" v-model="newPwd" @blur="regInput('password')"/>
					<text class="iconfont" :class="{'icon-dui':reg_password===1,'icon-cuo':reg_password===2}"></text>
				</view>
				<view class="err-tips" v-if="tip_password">{{tip_password}}</view>
			</view>
			<view class="item">
				<view class="input">
					<input type="password" placeholder="确认新密码" v-model="renewPwd"  @blur="regInput('repeat_password')" />
					<text class="iconfont" :class="{'icon-dui':reg_repeat_password===1,'icon-cuo':reg_repeat_password===2}"></text>
				</view>
				<view class="err-tips" v-if="tip_repeat_password">{{tip_repeat_password}}</view>
			</view>
		</view>

		<text class="mix-btn" @click="Confirm">确 定</text>
		 <!-- 弹出层 -->
    <tips></tips>
	</view>
</template>

<script>
	export default {
		data() {
			return {
				phone: '',		//手机号
				reg_username:'',  //手机号验证
				tip_username:'',  //手机号错误提示
				code:'', // 验证码
				reg_verifyCode:'',
				tip_verifyCode:'',
				newPwd:'', // 密码
				reg_password:'',
				tip_password:'',
				renewPwd:'',// 确认
				reg_repeat_password:'',
				tip_repeat_password:'',
				getCodeText:'发送验证码', // 发送验证码
				getCodeisWaiting:false,
				getCodeBackColor:'#B7BECC'
			};
		},
		computed: {

		},
		onLoad(options) {

		},
		mounted() {
		},

		methods: {
			// 失焦验证字段
			regInput(value){
			  // 为了避免失焦事件与点击事件冲突，延迟验证，先触发点击事件
			  setTimeout(()=>{
				switch(value){
				  // 验证手机号，调用验证事件
				  case 'username':
					if(!this.phone){
						this.reg_username=2;
						this.tip_username='请输入手机号';
						return;
					}
					if(!this.$verify.isPhone(this.phone)){
						this.reg_username=2;
						this.tip_username='请输入正确的手机号';
						return;
					}
					this.Submit1('validate','username');
					this.reg_username=1;
					this.tip_username=false;
					break;
				  case 'password':
					if(this.newPwd){
					  this.Submit1('validate','password');
					  this.reg_password=1;
					  this.tip_password=false;
					}else{
					  this.reg_password=2;
					  this.tip_password='请输入新密码';
					}
					
					break;
				  case 'repeat_password':
					if(this.renewPwd){
					  this.Submit1('validate','repeat_password');
					  this.reg_repeat_password=1;
					  this.tip_repeat_password=false;
					}else{
					  this.reg_repeat_password=2;
					  this.tip_repeat_password='请确认新密码';
					}
					break;
				}
			  },250)
			},
			// 验证函数
			Submit1(v1,v2){
				let data = {
					'username': this.phone,
					'password': this.newPwd,
					'repeat_password': this.renewPwd,
					'ajax':'validate'
				}
				this.$api.patchForget(data)
				.then(res => {
					for(let i in res.data){
						if(v2===i){
							switch(i){
							case 'username':
								this.reg_username=2;
								this.tip_username=res.data[i][0];
								break;
							case 'verifyCode':
								this.reg_verifyCode=2;
								this.tip_verifyCode=res.data[i][0];
								break;
							case 'password':
								this.reg_password=2;
								this.tip_password=res.data[i][0];
								break;
							case 'repeat_password':
								this.reg_repeat_password=2;
								this.tip_repeat_password=res.data[i][0];
								break;
							}
						}
					}
			  })
			},
			// 获取验证码
			getCode(){
				if(this.getCodeisWaiting){
					return
				}
				if(!this.$verify.isPhone(this.phone)){
					return this.$utils.Toast('请填写正确手机号码');
				}
				this.getCodeText = "发送中..."
				this.$api.getCodeVerify(this.phone,'forget','sms').then(res=>{
					if(res.data.success){
						this.$store.state.is_error = false
						this.getCodeisWaiting = true;
						this.getCodeBackColor = '#408CE2'
						setTimeout(()=>{
						 this.$utils.Toast( res.data.message);
							this.setTimer();
						},1000)
					}else{
						 this.$utils.Toast(res.data.message);
					}
				})
				
			},
			setTimer(){
				let holdTime = 60;
				this.getCodeText = "重新获取(60s)"
				this.Timer = setInterval(()=>{
					if(holdTime<=0){
						this.getCodeisWaiting = false;
						this.getCodeText = "获取验证码";
						this.getCodeBackColor='#B7BECC';
						clearInterval(this.Timer);
						return ;
					}
					this.getCodeText = "重新获取("+holdTime+"s)"
					holdTime--;
					
				},1000)
			},
			//确认
			 async Confirm() {
				let data = {
					'username':this.phone,
					'password':this.newPwd,
					'repeat_password':this.renewPwd,
					'verifyCode': this.code,
					'type': 'sms'
				}
				for(let i in data){
					if(data[i]===''){
					return	 this.$utils.Toast('请输入完整信息');
					}
				}
				this.$api.patchForget(data).then(res=>{
					if(res.data.success){
							this.$store.state.is_error = false
						 this.$utils.Toast(res.data.message);
						 
						 
					}else{
						 this.$utils.Toast( res.data.message);
					}
				})
			},
			
		},
		components: {
			
		}
	}
</script>

<style lang='scss'>
	.infoBox{
		padding: 40rpx 40rpx 0 40rpx;
		.item {
			height: 120rpx;
			
			.input{
				display: flex;
				border-bottom: 1px solid #F2F3F3;
				align-items: center;
			}
			input{
				width: 97%;
			}
			.code-input{
				width: 65%;
			}
			.code{
				background: #B7BECC;
				color: #FFFFFF;
				padding: 4px 10px;
				border-radius: 3px;
				width: 35%;
				text-align: center;
			}
		}
	}
</style>
