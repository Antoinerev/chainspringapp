<template>
  <div id="app" >
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
      <transition name="slide">
        <form v-if="addKI || editKI" @submit.prevent="addInfo(newKnowledgeItem)" id="add_form" class="reference-form left-pan">
          <div @click="addKI=false, editKI=false" class="close-btn">x</div>
          <label>Topic Name</label>
          <input type="text" name="domain" v-model="newKnowledgeItem.domain_name" />
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
      </transition>
      <button v-if="currentUser" @click="switchAddKI">{{newKIButton}}</button>
      <transition name="slide">
        <div class="left-pan" v-show="showInfoPan">
          <div @click="showInfoPan=false" class="close-btn">x</div>
          <button v-if="currentUserItem" @click="switchEditKI">editKI</button>
          <div>Title: {{selectedKnowledgeItem.title}}</div>
          <div> Kind: {{selectedKnowledgeItem.kind}}</div>
          <div>Time needed: {{selectedKnowledgeItem.time_needed}}</div>
          <div>
            <a v-if="selectedKnowledgeItem.link" :href="selectedKnowledgeItem.link" target='new'>external link</a>
            <div v-else>No link</div>
          </div>
        </div>
      </transition>
    </div>
    <d3-network ref='net' :net-nodes="nodes" :net-links="links" :options="options"  @node-click="toggleMenu"/>
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
    this.build_version = this.user.build_version
  },
  data () {
    return {
      api_version:"v1",
      name: "",
      nodes:[],
      links: [],
      allKinds: {},
      // nodeSize:18,
      canvas:false,
      keyword: "",
      alternative_nodes: [],
      flash: {text: "", show: false},
      addKI: false,
      editKI: false,
      newKnowledgeItem: {
        user_id: '',
        domain_name: '',
        title: '',
        kind: '',
        time_needed: '',
        link: ''
      },
      selectedNode: {},
      selectedKnowledgeItem: {
        title: 'default',
        kind: '',
        time_needed: '',
        link: 'no link'
      },
      showInfoPan: false
    }
  },
  computed:{
    options(){
      return{
        force: 4000,
        size:{ w: window.innerWidth, h:innerHeight / 1.2},
        nodeSize: 50,
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
    },
    currentUser() {
      // return  this.user.id && this.user.id == this.nodes[0].object_id && this.nodes[0].object_type == 'User'
      return  this.user.id != null;
    },
    currentUserItem() {
      return this.currentUser //&& this.nodes.includes(this.selectedNode)
    }
  },
  methods: {
    switchAddKI() {
      this.addKI = !this.addKI;
      if (this.addKI == true) {
        this.editKI = false;
        this.newKnowledgeItem = this.nodes[0];
        this.showInfoPan = false;
      }
    },
    switchEditKI() {
      this.editKI = !this.editKI;
      if (this.editKI == true) {
        this.addKI = false;
        this.newKnowledgeItem = this.selectedKnowledgeItem;
        this.showInfoPan = false;
      }
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
        this.sendNewKI(newInfo);
      } else if (this.editKI) {
        if(newInfo.link != this.selectedNode.link) {
          newInfo.link = this.checkLink(newInfo.link);
        }

        var editedKINode = this.nodes.find(node => {
          return node == this.selectedNode;
        });

        editedKINode.title = newInfo.title;
        editedKINode.kind = newInfo.kind;
        editedKINode.time_needed = newInfo.time_needed;
        editedKINode.link = newInfo.link;
        this.sendEditKI(editedKINode);
      }
    },
    checkLink(link) {
      if(!/^https?:\/\//.test(link)) {
        return 'http://' + link;
      } else {
        return link;
      }
    },
    sendNewKI(newInfo) {

      var api_url = '/api/v1/map/addki';
      this.sendUpdate(newInfo, api_url);
    },
    sendEditKI(editedKINode) {

      var api_url = '/api/v1/map/editki';
      this.sendUpdate(editedKINode, api_url);
    },
    sendUpdate(newInfo, api_url) {
      // console.log({newInfo});
      newInfo.user_id = this.user.id;
      // console.log({newInfo});

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
    // selectAction(event, node) {
    //   if (node.object_type == 'KnowledgeItem') {
    //     if (node.link != '') {
    //       console.log(this.checkLink(node.link));
    //       window.open(this.checkLink(node.link), '_blank');
    //     }
    //   } else {
    //     this.refreshMap(event, node);
    //   }
    // },
    toggleMenu(event, node) {
      if (node.object_type == 'KnowledgeItem') {
        // console.log({node});
        this.selectedNode = node;
        this.selectedKnowledgeItem = {
          title: node.name,
          kind: node.kind,
          time_needed: node.time_needed,
          link: node.link
        };
        this.showInfoPan = true;
      } else {
        this.refreshMap(event, node);
        this.showInfoPan = false;
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
      var api_url = `/api/${this.api_version}/map/build`;
      var requestParams = {
            params: {
              node_id: object_id,
              node_class: object_type,
              build_version: this.build_version
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
