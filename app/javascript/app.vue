<template>
  <div id="app">
  <div class="title">
    <h1>{{user.name}}</h1>

    <ul class="menu">
      <li>
        <label> Node size  </label>
        <input type="range" min="1" max="100" v-model='nodeSize' /> {{ options.nodeSize }}
      </li>
      <li>
        <label>Render as  </label>
      <input type="radio" :value='false' v-model='canvas' />
      <label>SVG</label>
      <input type="radio" :value='true' v-model='canvas' />
      <label>Canvas</label>
      </li>
    </ul>
    </div>
    <d3-network ref='net' :net-nodes="nodes" :net-links="links" :options="options" />
  </div>
</template>

<script>

export default {
  props: ['d3-network', 'user'],
  data () {
    return {
      nodeSize:40,
      canvas:false
    }
  },
  computed:{
    nodes(){
      return this.user.nodes
    },
    links(){
      return this.user.links
    },
    options(){
      return{
        force: 4000,
        size:{ w:1200, h:800},
        nodeSize: this.nodeSize,
        nodeLabels: true,
        canvas: this.canvas
      }
    }
  }
}
</script>

<style scoped>
</style>
