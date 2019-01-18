<template>
  <div id="app" >
  <div class="title">
    <h1>{{name}}</h1>
  </div>
  <div id="controls">
    <a v-if="user.id" href="../users/sign_out" data-method="delete">log out</a>
    <a v-else href="../users/sign_in">login</a>
    <a v-if="user.id" href="/">Show my map</a>
    <a href="/users">Choose demo user</a>
    <form @submit.prevent="search(keyword)" id="search_form">
      <input name="search" v-model="keyword"/>
      <button type="submit">Search</button>
      <transition name="fade">
        <div v-if="flash.show" class="notice-msg">{{flash.text}}</div>
      </transition>
    </form>
    <form v-if="addKI" @submit.prevent="addInfo(newKnowledgeItem)" id="add_form" class="reference-form">
      <label>Topic Name</label>
      <input type="text" name="domain" v-model="newKnowledgeItem.domain_name" />
      <br>
      <label>Reference: title</label>
      <input type="text" name="title" v-model="newKnowledgeItem.title" />
      <label>Kind</label>
      <select v-model="newKnowledgeItem.kind">
        <option v-for="kind in allKinds" v-bind:value="kind">
          {{ kind }}
        </option>
      </select>
      <label>Time to allocate (in minutes)</label>
      <input type="text" name="time_needed" v-model="newKnowledgeItem.time_needed" />
      <label>Link</label>
      <input type="text" name="link" v-model="newKnowledgeItem.link" />
      <button type="submit">Save</button>
    </form>
      <button v-if="user.id && user.id == nodes[0].object_id && nodes[0].object_type == 'User'" @click="switchAddKI">{{newKIButton}}</button>
  </div>
    <d3-network ref='net' :net-nodes="nodes" :net-links="links" :options="options"  @node-click="selectAction"/>
  </div>
</template>

<script>

export default {
  props: ['d3-network', 'user'],
  created() {
    // this.getMapFromApi()
    this.nodes = this.user.nodes;
    this.links = this.user.links;
    this.allKinds = this.user.allKinds;
  },
  data () {
    return {
      name: "",
      nodes:[],
      links: [],
      allKinds: {},
      nodeSize:18,
      canvas:false,
      keyword: "",
      alternative_nodes: [],
      flash: {text: "", show: false},
      addKI: false,
      newKnowledgeItem: {
        user_id: '',
        domain_name: '',
        title: '',
        kind: '',
        time_needed: '',
        link: ''
      }
    }
  },
  computed:{
    options(){
      return{
        force: 2000,
        size:{ w:1200, h:700},
        nodeSize: this.nodeSize,
        nodeLabels: true,
        canvas: this.canvas
      }
    },
    newKIButton() {
      if(this.addKI){
        return "Hide form"
      } else {
        return "Add reference"
      }
    }
  },
  methods: {
    switchAddKI() {
      this.addKI = !this.addKI;
    },
    addInfo(newInfo) {
      if(this.addKI) {
        if(newInfo.link) {
          newInfo.link = this.checkLink(newInfo.link);
        }
        let newKiNode = {id: Date.now(), _size: 20, _color: "#42c4ef", object_type: "KnowledgeItem",
          name: newInfo.title, kind: newInfo.kind, time_needed: newInfo.time_needed, link: newInfo.link};
        this.nodes.push(newKiNode);
        var domainNode = this.nodes.filter(node => (node.name == newInfo.domain_name && node.object_type == "Domain"));

        if(domainNode.length  < 1) {
          domainNode = [{id: Date.now()+1, _size: 22, _labelClass: 'test-class', _color: "#fc770a", name: newInfo.domain_name, object_type: "Domain"}];
          this.nodes.push(domainNode[0]);
          var userNodes = this.nodes.filter(node => node.object_type == "User");
          if(userNodes.length > 0) {
            this.links.push({sid: userNodes[0].id, tid: domainNode[0].id});
          }
        }
        this.links.push({sid: domainNode[0].id, tid: newKiNode.id});
        this.sendUpdate(newInfo);
      }
    },
    checkLink(link) {
      if(!/^https?:\/\//.test(link)) {
        return 'http://' + link;
      } else {
        return link;
      }
    },
    sendUpdate(newInfo) {
      // console.log({newInfo});
      newInfo.user_id = this.user.id;
      console.log(newInfo);
      var api_url = '/api/v1/map/update';
      var requestParams = {
              newInfo: newInfo
          }
      this.$http
        .post(api_url, requestParams)
        .then(response => {
          // console.log({response});
          return response.data;
        });
    },
    selectAction(event, node) {
      if (node.object_type == 'KnowledgeItem') {
        if (node.link != '') {
          console.log(this.checkLink(node.link));
          window.open(this.checkLink(node.link), '_blank');
        }
      } else {
        this.refreshMap(event, node);
      }
    },
    refreshMap(event, node) {
      this.getMapFromApi(node.object_id, node.object_type)
    },
    search(keyword) {
      // console.log({keyword});
      var api_url = '/api/v1/map/search';
      var requestParams = {
            params: {
              keyword: keyword
            }
          }
      this.$http
        .get(api_url, requestParams)
        .then(response => {
          // console.log({response});
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
