<template>
  <div id="app" >
    <div id="right-control-button" @click="switchRightPan">
      <i v-if="showRightPan" class="fas fa-chevron-right"></i>
      <i v-else class="fas fa-chevron-left"></i>
    </div>
    <transition name="slideLeft">
      <div id="controls" v-show="showRightPan" class="side-pan side-pan-right" >
        <a v-if="mapParams.user_id" href="../users/sign_out" data-method="delete">log out</a>
        <a v-else href="../users/sign_in">login</a>
        <span @click="takeScreenshot">
          <i class="fas fa-share-alt"></i>
          share
        </span>
        <a v-if="currentUser" @click="switchAddKI">{{newKIButton}}</a>
        <a v-if="mapParams.user_id" href="/">Show my map</a>
        <a href="/users">Choose demo user</a>
        <form @submit.prevent="search(keyword)" id="search_form">
          <input name="search" v-model="keyword"/>
          <button type="submit">Search</button>
          <transition name="fade">
            <div v-if="flash.show" class="notice-msg">{{flash.text}}</div>
          </transition>
        </form>
      </div>
    </transition>


    <transition name="slideRight">
      <form id="add_form" class="reference-form side-pan side-pan-left" v-if="addKI || editKI"
        @submit.prevent="addInfo(newKnowledgeItem), addKI=false, editKI=false" >
        <div @click="showInfoPan=false, addKI=false, editKI=false" class="close-btn" id="left-close-button" >
          <i class="fas fa-chevron-left"></i>
        </div>
        <label>Reference title<br>(keep it short !)</label>
        <input type="text" name="title" v-model="newKnowledgeItem.title" />
        <label>Topics Names<br>(separated by commas)</label>
        <input type="text" name="domain" v-model="newKnowledgeItem.domain_name" />
        <label>Format</label>
        <select v-model="newKnowledgeItem.kind">
          <option v-for="kind in allKinds" v-bind:value="kind">
            {{ kind }}
          </option>
        </select>
        <label>Link</label>
        <input type="text" name="link" v-model="newKnowledgeItem.link" />
        <button type="submit">Save</button>
      </form>

      <div id="show-ki-pan" class="side-pan side-pan-left" v-show="showInfoPan">
        <div @click="showInfoPan=false" class="close-btn" id="left-close-button" >
          <i class="fas fa-chevron-left"></i>
        </div>
        <button v-if="currentUserItem" @click="switchEditKI">editKI</button>
        <div>Title:<br> <span class="refText"> {{selectedKnowledgeItem.title}}</span></div>
        <div> Format:<br> <span class="refText"> {{selectedKnowledgeItem.kind}}</span></div>
        <div>Topics:<br> <span class="refText"> {{selectedKnowledgeItem.topics}}</span></div>
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
    this.colorMap();

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
        return "Close pan"
      } else {
        return "Add content"
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
    takeScreenshot() {
      this.$refs.net.screenShot("my_map.png");
    },
    switchRightPan() {
      if(this.showRightPan == false) {
        this.addKI = false;
        this.editKI = false;
        this.showInfoPan = false;
      }
      this.showRightPan = !this.showRightPan;
    },
    switchAddKI() {
      this.addKI = !this.addKI;
      if (this.addKI == true) {
        this.showRightPan = false;
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
      newInfo.time_needed = "";
      if(this.addKI) {
        const userNode = this.nodes.find(node => node.object_type == "User");
        let domainNames = [];
        if(newInfo.domain_name) {
          domainNames = newInfo.domain_name.split(/[,;\t]/).map(w => w.trim());
        } else {
          domainNames = [""];
        }
        let newTopicNodes = [];
        if(this.validTopic(domainNames)) {
          let newDomainNode = {};
          domainNames.forEach(domainName => {
            var domainNode = this.nodes.filter(node => (node.name == domainName && node.object_type == "Domain"));

            if(domainNode.length  < 1) {
              newDomainNode = {id: Date.now()+1, _labelClass: 'test-class', _color: "#fc770a", name: domainName, object_type: "Domain"};
              this.nodes.push(newDomainNode);
              if(userNode) {
                this.links.push({sid: userNode.id, tid: newDomainNode.id});
              }
            }
            newTopicNodes.push(newDomainNode);
          });
        }
        if(this.validReference(newInfo.title)) {
          if(newInfo.link) {
            newInfo.link = this.checkLink(newInfo.link);
          }
          let newKiNode = {id: Date.now(), _color: "#42c4ef", object_type: "KnowledgeItem",
            name: newInfo.title, kind: newInfo.kind, time_needed: newInfo.time_needed, link: newInfo.link};
          this.nodes.push(newKiNode);
          if(newTopicNodes.length > 0) {
            newTopicNodes.forEach(topicNode => {
              this.links.push({sid: topicNode.id, tid: newKiNode.id});
            });
          } else {
            this.links.push({sid: userNode.id, tid: newKiNode.id});
          }
        }
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
    validTopic(topicNames) {
      if(topicNames[0].length > 1) {
        return true;
      } else {
        return false;
      }
    },
    validReference(refTitle) {
      if(refTitle.length > 1) {
        return true;
      } else {
        return false;
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
        this.showRightPan = false;
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
    colorMap() {
      const topicColors = [
        'rgb(0,0,130)','rgb(0,130,0)','rgb(130,0,0)','rgb(0,130,130)','rgb(130,130,0)','rgb(130,0,130)',
        'rgb(0,0,220)','rgb(0,220,0)','rgb(220,0,0)','rgb(0,220,220)','rgb(220,220,0)','rgb(220,0,220)',
        'rgb(130,0,220)','rgb(130,220,0)','rgb(220,130,0)','rgb(130,220,220)','rgb(220,220,130)','rgb(220,130,220)'
      ];
      let topicNodes = this.nodes.filter(node => node.id[0] == "d");
      let cont = 0;
      topicNodes.forEach(topic => {
        topic["_color"] = topicColors[cont];
        this.colorRefs(topic);
        if(cont == topicColors.length - 1) {
          cont = 0;
        } else {
          cont++
        }
      });
    },
    colorRefs(topicNode) {
      const topicSpecificRefsColor = this.lightenColor(topicNode["_color"]);
      let links = this.links.filter(link => link.sid == topicNode.id);
      links.forEach(link => {
        let ref = this.nodes.find(node => node.id == link.tid);
        ref["_color"] = topicSpecificRefsColor;
      });
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
    },
    lightenColor(rgbColor) {
      const m = rgbColor.match(/^rgb\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)$/i);
      if( m) {
        const incr = 60;
        const newR = Math.min(parseInt(m[1])+incr, 255);
        const newG = Math.min(parseInt(m[2])+incr, 255);
        const newB = Math.min(parseInt(m[3])+incr, 255);
        return 'rgb(' + newR + ',' + newG + ',' + newB + ')';
      } else {
        return rgbColor;
      }
    }//,
    // randomShadeOfColor(rgbColor) {
    //   const m = rgbColor.match(/^rgb\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)$/i);
    //   if( m) {
    //     let baseR = m[1];
    //     let baseG = m[2];
    //     let baseB = m[3];
    //     let incr = 20;
    //     let topBase = Math.max(baseR, baseG, baseB);
    //     let randCol = (Math.floor((Math.random() * Math.floor(255-topBase))/incr))*incr;
    //     return 'rgb(' + (baseR+randCol) + ',' + (baseG+randCol) + ',' + (baseB+randCol) + ')';
    //   } else {
    //     return rgbColor;
    //   }
    // }
  }
}
</script>

<style scoped>

</style>
