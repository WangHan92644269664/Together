import Vue from 'vue'
import App from './App'
import utils from './common/js/utils.js'
import verify from './common/js/verify.js'
import VueClipboard from 'vue-clipboard2'
Vue.use(VueClipboard)

import author from './common/js/author.js'
import api from './common/js/api.js'
import tools from './common/js/tools.js'
import shoproLoad from '@/components/shopro-load.vue';
// 门店头部
Vue.prototype.$api = api
Vue.prototype.$tools = tools
Vue.prototype.$author = author
// import Vant from 'vant'
// Vue.use(Vant)

import filter from './common/js/filters'
Object.keys(filter).forEach(key=>Vue.filter(key,filter[key]))

Vue.config.productionTip = false
Vue.prototype.$utils = utils;
Vue.prototype.$verify = verify;
Vue.component('shoproLoad', shoproLoad)

Vue.filter('phoneFilter',(val)=>{
	val =val.slice(0,3)+'****'+ val.slice(7,11)
  return val
})

Vue.filter('two',(val)=>{
	return Number(val).toFixed(2)
})

// 挂载vuex
import store from './store/index'
Vue.prototype.$store = store

function loading(info){
    store.commit('setTips',info)
}
Vue.prototype.$loading = loading;

App.mpType = 'app'

// APP热更新
if (window.cordova) {
  document.addEventListener('deviceready', function () {
    console.log(222222)
    codePush.notifyApplicationReady() // 更新后首次启动必须调用该方法，否者更新会回退(执行codePush.sync()时会自动执行该方法)
  })
}
const app = new Vue({
    ...App
})
app.$mount()
