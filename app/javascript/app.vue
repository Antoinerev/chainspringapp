<template>
  <div id="app" >
  <div class="title">
    <h1>{{name}}</h1>
  </div>
  <div id="controls">
    <a href="/users">Choose demo user</a>
    <form @submit.prevent="search(keyword)">
      <input name="search" v-model="keyword"/>
      <button type="submit">Search</button>
      <transition name="fade">
        <div v-if="flash.show" class="notice-msg">{{flash.text}}</div>
      </transition>
    </form>
  </div>
    <d3-network ref='net' :net-nodes="nodes" :net-links="links" :options="options"  @node-click="refreshMap"/>
  </div>
</template>

<script>

export default {
  props: ['d3-network', 'user'],
  created() {
    // this.getMapFromApi()
    this.nodes = this.user.nodes;
    this.links = this.user.links;
  },
  data () {
    return {
      name: "",
      nodes:[],
      links: [],
      nodeSize:20,
      canvas:false,
      keyword: "",
      alternative_nodes: [],
      flash: {text: "", show: false}
    }
  },
  computed:{
    options(){
      return{
        force: 2000,
        size:{ w:1200, h:600},
        nodeSize: this.nodeSize,
        nodeLabels: true,
        canvas: this.canvas
      }
    }
  },
  methods: {
    refreshMap(event, node) {
      this.getMapFromApi(node.object_id, node.object_type)
    },
    search(keyword) {
      console.log({keyword});
      var api_url = '/api/v1/map/search';
      var requestParams = {
            params: {
              keyword: keyword
            }
          }
      this.$http
        .get(api_url, requestParams)
        .then(response => {
          console.log({response});
          return response.data;
        })
        .then(data => {
          if (data.map.name != "") {
            this.name = data.map.name;
            this.nodes = data.map.nodes;
            this.links = data.map.links;
            this.alternative_nodes = data.alternative_nodes;
          } else {
            this.flash.text = "searching " + this.keyword + ": " + data.map.message;
            this.flash.show = true;
            setTimeout(() => {
              this.flash.show = false;
            }, 3000);
          }
        });
      window.scrollTo(0,1000);
    },
    getMapFromApi(object_id, object_type) {
      // console.log(object_id);
      // console.log(object_type);
      var api_url = '/api/v1/map/build';
      var requestParams = {
            params: {
              node_id: object_id,
              node_class: object_type
            }
          }
      this.$http
        .get(api_url, requestParams)
        .then(response => {
          // console.log({response});
          return response.data;
        })
        .then(data => {
          this.name = data.map.name;
          this.nodes = data.map.nodes;
          this.links = data.map.links;
          this.alternative_nodes = data.alternative_nodes;
        });
      window.scrollTo(0,1000);
    }
  }
}
</script>

<style scoped>
</style>
