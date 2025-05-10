<script lang="ts">
  import BoxList from './lib/BoxList.svelte';
  import SpaceControl from './lib/SpaceControl.svelte';
  import BoxControl from './lib/BoxControl.svelte';

  import type {State} from './state.svelte';
  import {boxMatches} from './state.svelte';

  import {RemoteState} from './network.svelte';

  let remoteState = new RemoteState(window.location.href);
  remoteState.fetchState();

  $effect(remoteState.maybePushUpdate);

  let _searchTerm = $state("");
  let searchTerm = $derived(_searchTerm.toLocaleLowerCase().trim());

  let _searchBox = $state("");
  let searchBox = $derived(parseInt(_searchBox))

  let tab : "item" | "recent" | "box" = $state("item");

  function nthMostRecent(boxState : State, n : number) : number {
    let ret = [];
    for (let key in boxState.spaces) {
      for (let box of boxState.spaces[key]) {
        ret.push(box.modificationTime);
      }
    }
    ret.sort();
    return ret[Math.max(0, ret.length - n)];
  }
  const numMostRecent = 5;
  let modifiedCutoff = $derived(nthMostRecent(remoteState.state, numMostRecent));
</script>

<main>
  {#if remoteState.error}
  <div id="error">
    {remoteState.error}
  </div>
  {/if}
  <div id="searches">
    <div class="search-field">
      <label for="search-item">Item:</label>
      <input bind:value={_searchTerm} id="search-item" />
    </div>
    <div class="search-field">
      <label for="searchBox">Box:</label>
      <input bind:value={_searchBox} id="search-box" />
    </div>
  </div>

  <div id="tab-select">
    <input bind:group={tab} type="radio" name="tab" value="item" id="r-item" />
    <label for="r-item">Search</label>
    <input bind:group={tab} type="radio" name="tab" value="recent" id="r-recent" />
    <label for="r-recent">Recent</label>
    <input bind:group={tab} type="radio" name="tab" value="box" id="r-box" />
    <label for="r-box">Box</label>
  </div>

  <div id="columns">
    <div class={tab == "item" ? "selected" : null}>
      <div class="col-header">Item search</div>
      <BoxList content={remoteState.state.spaces} highlight={searchTerm} filter={b => boxMatches(b, searchTerm)} />
    </div>
    <div class={tab == "recent" ? "selected" : null}>
      <div class="col-header">Recent boxes</div>
      <BoxList content={remoteState.state.spaces} highlight={searchTerm} filter={b => b.modificationTime >= modifiedCutoff} />
    </div>
    <div class={tab == "box" ? "selected" : null}>
      <div class="col-header">Box search</div>
      <BoxList content={remoteState.state.spaces} highlight={searchTerm} filter={b => Number.isNaN(searchBox) || b.idx + 1 === searchBox} />
    </div>
  </div>

  <div id="controls">
    <SpaceControl boxState={remoteState.state}/>
    <BoxControl boxState={remoteState.state}/>
  </div>
</main>

<style>
  #columns {
    display: flex;
    flex-direction: row;
    justify-content: center;
    align-items: flex-start;
    gap: 20px;
  }
  #columns > div {
    padding: 5px;
    background-color: #282828;
    border-radius: 5px;
    flex-grow: 1;
    flex-basis: 0px;
    max-width: 400px;
  }
  #searches {
    display: flex;
    justify-content: center;
    gap: 10px;
    padding: 5px;
    background-color: #282828;
    border-radius: 5px;
    max-width: 600px;
    flex-grow: 1;
  }
  #controls {
    display: flex;
    justify-content: space-around;
    max-width: 1000px;
    border-radius: 5px;
    background-color: #282828;
    padding: 5px;
  }
  main {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 100%;
    gap: 20px;
  }
  .col-header {
    margin-top: 5px;
    margin-bottom: 9px;
  }
  main > div {
    width: 100%;
  }
  #tab-select {
    display: none;
  }

  @media (max-width: 700px) {
    #tab-select {
      display: block;
    }
    #columns > div:not(.selected) {
      display: none;
    }
    #searches,#controls {
      flex-direction: column;
      max-width: 300px;
    }
    .col-header {
      display: none;
    }
  }
</style>
