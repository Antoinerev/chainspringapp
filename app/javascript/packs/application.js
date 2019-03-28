import Vue from 'vue/dist/vue.esm'

import TurbolinksAdapter from 'vue-turbolinks'
Vue.use(TurbolinksAdapter)

import Axios from 'axios';
Vue.use(Axios);
Vue.prototype.$http = Axios;

import D3Network from 'vue-d3-network'
Vue.component('d3-network', D3Network)

import App from '../app.vue'
Vue.component('app', App)



const app = new Vue({
  el: '[data-behavior="vue"]'
})

