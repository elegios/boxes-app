<script lang="ts">
  import { type BoxState, exactMatchIdx, itemMatches } from '../state.svelte';

  type Props = {
    box : BoxState;
    highlight? : string;
  };
  let p : Props = $props();

  function onclick() {
    if (!p.highlight) return;
    const idx = p.box.items.findIndex(i => i.toLocaleLowerCase().trim() == p.highlight);
    if (idx < 0) {
      p.box.items.push(p.highlight);
    } else {
      p.box.items.splice(idx, 1);
    }
    p.box.modificationTime = Date.now();
  }
</script>

<div class="idx">{p.box.idx + 1}</div>
<div class="items">
  {#each p.box.items as item, idx}
    {#if idx != 0},&nbsp{/if}
      <span class={itemMatches(item, p.highlight) ? "highlight" : null}>{item}</span>
    {/each}
  </div>
<button disabled={!p.highlight} {onclick}>
  {#if p.highlight && exactMatchIdx(p.box, p.highlight) !== undefined}
    -
  {:else}
    +
  {/if}
</button>

<style>
  .idx {
    grid-column-start: start;
    background: #303030;
    font-size: 18px;
    min-width: 40px;
    min-height: 40px;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .items {
    grid-column-start: items;
    flex-grow: 1;
    vertical-align: center;
  }
  .highlight {
    grid-column-start: button;
    font-weight: bold;
  }
</style>
