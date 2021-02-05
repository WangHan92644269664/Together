import Vue from 'vue'
import Vuex from 'vuex'
Vue.use(Vuex)
const store = new Vuex.Store({
	state: {
		success_modal: false, //弹出框是否显示
		success_tips_content: '', //弹出框的内容
		is_error: true,
		token: ''
	},
	mutations: {
		// 设置弹出框显示与隐藏
		setTips(state, info) {
			state.success_modal = !this.success_modal;
			state.success_tips_content = info
		},
		// 设置弹出框显示与隐藏
		setToken(state, info) {
			state.token = info;
			uni.setStorageSync('token',info)
		}
	}
})

export default store
