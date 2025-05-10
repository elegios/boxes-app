import type {State} from './state.svelte';

export class RemoteState {
  clock : number = -1;
  error : undefined | string = $state(undefined);
  state : State = $state(undefined);

  _suppressNextUpdate = true;
  _updateInFlight = false;
  _updateQueued = false;

  url : string;

  constructor(url : string) {
    this.url = url;

    // TODO(vipa, 2025-06-01): Remove this and fetch actual stuff
    this.state = {
      spaces : {
        // "blub" : [
        //   {idx : 0, items: [], modificationTime: Date.now()},
        //   {idx : 1, items: ["some stuff"], modificationTime: Date.now()},
        //   {idx : 2, items: ["some stuff", "and more"], modificationTime: Date.now()},
        // ],
        // "blab" : [
        //   {idx : 0, items: [], modificationTime: Date.now()},
        //   {idx : 1, items: ["some staff"], modificationTime: Date.now()},
        //   {idx : 2, items: ["some staff", "and mare"], modificationTime: Date.now()},
        // ],
      },
    };
  }

  maybePushUpdate = () => {
    // NOTE(vipa, 2025-06-01): It's important that we read the `state`
    // variable whether we send the update or not, so we re-run this
    // effect whenever it changes. Ideally we'd just say we're
    // listening on the entire object, without needing to create the
    // actual snapshot here, but I'm not sure how to do that, and this
    // implementation is quite clearly correct, and probably fast
    // enough for my use-cases.
    const current = $state.snapshot(this.state);
    if (this._suppressNextUpdate) {
      console.log("Suppressed update");
      this._suppressNextUpdate = false;
      return;
    }

    this._doPushUpdate(current);
  }

  _doPushUpdate = async (s : State) => {
    if (this._updateInFlight) {
      this._updateQueued = true;
      return;
    }

    try {
      this._updateInFlight = true;
      const params = new URLSearchParams();
      params.append("clock", this.clock);
      const response = await fetch(`${this.url}set-state?${params}`, {
        method: "POST",
        body: JSON.stringify(s),
      });
      if (!response.ok) {
        throw new Error(`Error ${response.status}: ${await response.text()}`);
      }

      const json = await response.json();
      if (typeof json !== 'number')
        throw new Error(`Invalid update response from server, expected integer, got: ${json}`);

      this.clock = json;
      this.error = undefined;
      this._updateInFlight = false;
      if (this._updateQueued) {
        this._updateQueued = false;
        await this._doPushUpdate($state.snapshot(this.state));
      }
    } catch (error) {
      this.error = error.message;
      this._updateInFlight = false;
      this._updateQueued = false;
    }
  }

  fetchState = async () => {
    try {
      const response = await fetch(`${this.url}get-state`);
      if (!response.ok)
        throw new Error(`Response status: ${response.status}`);

      const json = await response.json();
      console.log("Updating state from request");
      this._suppressNextUpdate = true;
      console.log(json);
      this.clock = json.clock;
      this.state = json.state; // TODO(vipa, 2025-06-01): Validate the shape of this data
      this.error = undefined;
    } catch (error) {
      this.error = error.message;
    }
  }
}
