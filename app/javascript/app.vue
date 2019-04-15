<template>
  <div id="app" >
    <div id="right-control-button" @click="switchRightPan">⬌</div>
    <transition name="slideLeft">
      <div id="controls" v-if="showRightPan" class="side-pan side-pan-right" >
        <a v-if="mapParams.user_id" href="../users/sign_out" data-method="delete">log out</a>
        <a v-else href="../users/sign_in">login</a>
        <a v-if="mapParams.user_id" href="/">Show my map</a>
        <a href="/users">Choose demo user</a>
        <form @submit.prevent="search(keyword)" id="search_form">
          <input name="search" v-model="keyword"/>
          <button type="submit">Search</button>
          <transition name="fade">
            <div v-if="flash.show" class="notice-msg">{{flash.text}}</div>
          </transition>
        </form>
        <button v-if="currentUser" @click="switchAddKI">{{newKIButton}}</button>
      </div>
    </transition>

    <transition name="slideRight">
      <form class="reference-form side-pan side-pan-left" v-if="addKI || editKI" @submit.prevent="addInfo(newKnowledgeItem), addKI=false, editKI=false" id="add_form">
        <div @click="addKI=false, editKI=false" class="close-btn">x</div>
        <label>Reference title (keep it short !)</label>
        <input type="text" name="title" v-model="newKnowledgeItem.title" />
        <label>Topics Names (separated by commas)</label>
        <input type="text" name="domain" v-model="newKnowledgeItem.domain_name" />
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
    <transition name="slideRight">
      <div class="side-pan side-pan-left" v-show="showInfoPan">
        <div @click="showInfoPan=false" class="close-btn">x</div>
        <button v-if="currentUserItem" @click="switchEditKI">editKI</button>
        <div>Title: {{selectedKnowledgeItem.title}}</div>
        <div> Kind: {{selectedKnowledgeItem.kind}}</div>
        <div>Time needed: {{selectedKnowledgeItem.time_needed}}</div>
        <div>Topics: {{selectedKnowledgeItem.topics}}</div>
        <div>
          <a v-if="selectedKnowledgeItem.link" :href="selectedKnowledgeItem.link" target='new'>external link</a>
          <div v-else>No link</div>
        </div>
      </div>
    </transition>
    <d3-network ref='net' :net-nodes="nodes" :net-links="links" :options="options"  @node-click="toggleMenu"/>
  </div>
</template>

<script>

export default {
  props: ['d3-network', 'map-params'],
  created() {
    this.initialNodes = this.mapParams.nodes;
    this.initialLinks = this.mapParams.links;
    this.allKinds = this.mapParams.allKinds;
    this.build_version = this.mapParams.build_version;
    // this.setInitialMap();
    this.nodes = this.initialNodes;
    this.links = this.initialLinks;

    // // Static test example
    // this.nodes = [
    //   {name: 'test', id: 'u_1', _color: '#26a424'},
    //   {name: 'topic 1', id: 't_1', _color: '#fc770a'},
    //   {name: 'ref 1', id: 'r_1', _color: '#42c4ef'},
    //   {name: 'topic 2', id: 't_2', _color: '#fc770a'}
    // ];
    // this.links = [
    // {id: 'l_1', sid: 'u_1', tid: 't_1'},
    // {id: 'l_2', sid: 't_1', tid: 'r_1'},
    // {id: 'l_3', sid: 'u_1', tid: 't_2'},
    // {id: 'l_4', sid: 'r_1', tid: 't_2'}
    // ];
  },
  data () {
    return {
      api_version:"v1",
      name: "",
      initialNodes: [],
      initialLinks: [],
      nodes:[],
      links: [],
      allKinds: {},
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
        link: 'no link',
        topics: ''
      },
      showRightPan: false,
      showInfoPan: false,
      savedColor: ''
    }
  },
  computed:{
    options(){
      return{
        force: 1000,
        forces:{
          Center: false,
          X: 0.5,
          Y: 0.1,
          ManyBody: true,
          Link: true
        },
        size:{ w: window.innerWidth, h:innerHeight * 1.5},
        nodeSize: this.mapParams.nodesize / 1,
        nodeLabels: true,
        canvas: this.canvas,
        // offset: {x: 0, y: - innerHeight/4},
        strLinks: true
        // noNodes: true
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
      return  this.mapParams.user_id != null;
    },
    currentUserItem() {
      return this.currentUser //&& this.nodes.includes(this.selectedNode)
    }
  },
  methods: {
    switchRightPan() {
      if(this.showRightPan == false) {
        this.addKI=false;
        this.editKI=false;
      }
      this.showRightPan = !this.showRightPan;
    },
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
        let newKiNode = {id: Date.now(), _color: "#42c4ef", object_type: "KnowledgeItem",
          name: newInfo.title, kind: newInfo.kind, time_needed: newInfo.time_needed, link: newInfo.link};
        this.nodes.push(newKiNode);
        let domainNames = newInfo.domain_name.split(/[,;\t]/).map(w => w.trim());
        domainNames.forEach(domainName => {

          var domainNode = this.nodes.filter(node => (node.name == domainName && node.object_type == "Domain"));

          if(domainNode.length  < 1) {
            domainNode = [{id: Date.now()+1, _labelClass: 'test-class', _color: "#fc770a", name: domainName, object_type: "Domain"}];
            this.nodes.push(domainNode[0]);
            var userNodes = this.nodes.filter(node => node.object_type == "User");
            if(userNodes.length > 0) {
              this.links.push({sid: userNodes[0].id, tid: domainNode[0].id});
            }
          }
          this.links.push({sid: domainNode[0].id, tid: newKiNode.id});
        });
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
      newInfo.user_id = this.mapParams.user_id;

      var requestParams = {
              newInfo: newInfo
          }
      this.$http
        .post(api_url, requestParams)
        .then(response => {
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
      this.selectNode(node);
      if (node.object_type == 'KnowledgeItem') {
        this.selectedKnowledgeItem = {
          title: node.name,
          kind: node.kind,
          time_needed: node.time_needed,
          link: node.link,
          topics: node.topics
        };
        this.showInfoPan = true;
      } else {
        this.refreshMap(event, node);
        this.showInfoPan = false;
      }
    },
    selectNode(node) {
      if(this.selectedNode.id) {
        this.selectedNode["_color"] = this.savedColor;
      }
      this.savedColor = node["_color"];
      node["_color"] = '#FF0000';
      this.selectedNode = node;
    },
    setInitialMap() {
      let node = this.initialNodes[0];
      let descendantLinks = this.initialLinks.filter(link => link.sid == node.id);
      let descendantNodes = [];
      descendantLinks.forEach(link => {
        descendantNodes = descendantNodes.concat(this.initialNodes.filter(node => node.id == link.tid));
      });
      this.nodes = descendantNodes;
      this.nodes.unshift(node);
      this.links = descendantLinks;
    },
    refreshMap(event, node) {
      if(this.links.filter(link => link.sid == node.id).length > 0) {
        console.log('api call');
        this.updateMapFromApi(node.id, node.object_type);
      } else {
        console.log('refresh from cache');
        this.remapFromMemory(node);
      }
    },
    remapFromMemory(node) {
        let descendantLinks = [];
        let remainingLinks = [];
        let descendantNodes = [];
        let remainingNodes = [];
        let descendantLinks2 = [];
        let descendantNodes2 = [];
        // gets nodes directly linked to origin node
        this.initialLinks.forEach(link => {
          if(link.sid == node.id) {
            descendantLinks.push(link);
          } else {
            remainingLinks.push(link);
          }
        });
        descendantLinks.forEach(link => {
          this.initialNodes.forEach(node => {
            if(node.id == link.tid) {
              descendantNodes.push(node);
            } else {
              remainingNodes.push(node);
            }
          });
        });
        // gets links from 2nd degree nodes
        descendantNodes.forEach(node => {
          descendantLinks2 = descendantLinks2.concat(remainingLinks.filter(link => node.id == link.tid));
        });
        // gets nodes of 3rd degree
        descendantLinks2.forEach(link => {
          descendantNodes2 = descendantNodes2.concat(remainingNodes.filter(node => node.id == link.sid ));
        });
        // sets base nodes and links
        this.setInitialMap();
        this.nodes = this.nodes.concat(descendantNodes).concat(descendantNodes2);
        // this.nodes.unshift(node);
        this.links = this.links.concat(descendantLinks).concat(descendantLinks2);
      // }
    },
    search(keyword) {
      var api_url = '/api/v1/map/search';
      var requestParams = {
            params: {
              keyword: keyword
            }
          }
      this.$http
        .get(api_url, requestParams)
        .then(response => {
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
    updateMapFromApi(node_id, object_type) {
      var api_url = `/api/${this.api_version}/map/build`;
      var requestParams = {
            params: {
              node_id: node_id.split('_')[1],
              node_class: object_type,
              build_version: this.build_version
            }
          }
      this.$http
        .get(api_url, requestParams)
        .then(response => {
          return response.data;
        })
        .then(data => {
          this.name = data.map.name;
          this.setInitialMap()
          this.addNodeIfNew(data.map.nodes);
          this.addLinkIfNew(data.map.links);
          this.alternative_nodes = data.alternative_nodes;
        });
      // window.scrollTo(0,1000);
    },
    addNodeIfNew(nodes) {
      // let node_ids = this.nodes.map(node => node.id);
      let node_ids = this.initialNodes.map(node => node.id);
      let refreshedNodes = [];
      nodes.forEach(node => {
        if(!node_ids.includes(node.id)) {
          refreshedNodes.push(node);
        }
      });
      this.nodes = this.initialNodes.concat(refreshedNodes);
    },
    addLinkIfNew(links) {
      // let link_ids = this.links.map(link => link.id);
      let link_ids = this.initialLinks.map(link => link.id);
      let refreshedLinks = [];
      links.forEach(link => {
        if(!link_ids.includes(link.id)) {
          refreshedLinks.push(link);
        }
      });
      this.links = this.initialLinks.concat(refreshedLinks);
    }
  }
}
</script>

<style scoped>

</style>
