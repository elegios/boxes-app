<script lang="ts">
  import { type State } from '../state.svelte';

  type Props = {
    boxState : State;
  };
  let p : Props = $props();

  let spaceChoice : undefined | string = $state(undefined)
  let validChoice = $derived(spaceChoice && p.boxState.spaces[spaceChoice]);
  let selectedSpace = $derived(spaceChoice ? p.boxState.spaces[spaceChoice] : undefined);
  let remEmpty = $derived(selectedSpace && selectedSpace.length ? !selectedSpace[selectedSpace.length - 1].items.length : undefined)

  function add() {
    if (!selectedSpace) return;
    selectedSpace.push({
      idx: selectedSpace.length,
      items: [],
      modificationTime: Date.now(),
    });
  }
  function remove() {
    if (!selectedSpace || !remEmpty) return;
    selectedSpace.pop();
  }
</script>

<div>
  <select bind:value={spaceChoice} disabled={!Object.keys(p.boxState.spaces).length}>
    {#each Object.keys(p.boxState.spaces) as space}
      <option value={space}>{space}</option>
    {:else}
      <option>No spaces</option>
    {/each}
  </select>
  <button onclick={add} disabled={!validChoice}>+</button>
  <button onclick={remove} disabled={!validChoice || !remEmpty}>-</button>
</div>
