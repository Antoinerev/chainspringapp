<template>
  <div id="app">
  <div class="title">
    <h1>Laure Merlin </h1>

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
        nodes: [
          { id: 1, name: 'kitesurfing', _color: 'yellow'},
          { id: 2, name: 'cooking recipes'},
          { id: 3, name:'sociology', _color: 'purple' },
          { id: 4, name:'Laure Merlin', _color: 'red' }
        ],
        links: [
          { sid: 4, tid: 1 },
          { sid: 4, tid: 2 },
          { sid: 4, tid: 3 },
          { sid: 2, tid: 3 }
        ],
        nodeSize:40,
        canvas:false

      }
    },
    computed:{
      options(){
        return{
          force: 4000,
          size:{ w:600, h:600},
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
