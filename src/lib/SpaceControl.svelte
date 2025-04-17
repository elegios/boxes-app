<script lang="ts">
  import { type State } from '../state.svelte';

  type Props = {
    boxState : State;
  };
  let p : Props = $props();

  let name = $state("");

  function onclick() {
    if (p.boxState.spaces.hasOwnProperty(name)) {
      delete p.boxState.spaces[name];
    } else {
      p.boxState.spaces[name] = [];
    }
  }
</script>

<div>
  <input bind:value={name} />
  <button disabled={!name || p.boxState.spaces[name] && !!p.boxState.spaces[name].length} {onclick}>
    {#if p.boxState.spaces[name]}
      Remove
    {:else}
      Add
    {/if}
  </button>
</div>
