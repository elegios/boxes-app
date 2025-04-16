<script lang="ts">
  import boxState from '../state.svelte.ts';
  let count: number = $state(0)
  const increment = () => {
    count += 1;
    boxState.boxes.push({items : [], modificationTime : new Date()});
  }
</script>

<button onclick={increment}>
  count is {count}
</button>
