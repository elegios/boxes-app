<script lang="ts">
  import { type BoxState } from '../state.svelte';
  import Box from './Box.svelte';

  type Props = {
    content : { [space : string] : BoxState[] };
    filter? : (b: BoxState) => boolean;
    highlight? : string;
  };
  let p : Props = $props();
</script>

<div class="spaces">
  {#each Object.entries(p.content) as [space, boxes] (space)}
    <div class="header">
      {space}
    </div>
    {#each p.filter ? boxes.filter(p.filter) : boxes as box (box.idx)}
      <Box {box} highlight={p.highlight} />
    {:else}
      <div class="msg">No matching boxes.</div>
    {/each}
  {:else}
    <div class="msg">No spaces, add one below.</div>
  {/each}
</div>

<style>
  .spaces {
    display: grid;
    grid-template-columns: [start] min-content [items] 1fr [button] min-content [end];
    column-gap: 5px;
    row-gap: 5px;
    align-items: center;
  }
  .header {
    grid-column: start / end;
    text-align: left;
    background: #303030;
    margin-top: 10px;
    padding: 0px 3px;
  }
  .header:first-child {
    margin-top: 0px;
  }
  .msg {
    grid-column-end: span 3;
    color: rgba(255, 255, 255, 0.3);
  }
</style>
