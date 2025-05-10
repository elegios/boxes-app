export type BoxState = {
  idx : number;
  items : string[];
  modificationTime : number;
};

export type State = {
  spaces : {
    [space : string] : BoxState[];
  };
};

export let boxState : State = $state({
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
});

export function itemMatches(item : string, highlight? : string) : boolean {
  return !!highlight && item.toLocaleLowerCase().includes(highlight);
}

export function boxMatches(box : BoxState, highlight? : string) : boolean {
  if (highlight == undefined)
    return false;
  if (highlight == "")
    return true;
  return box.items.find(i => i.toLocaleLowerCase().includes(highlight)) !== undefined;
}

export function exactMatchIdx(box : BoxState, highlight : string) : number | undefined {
  const idx = box.items.findIndex(i => i.toLocaleLowerCase() == highlight);
  if (idx < 0)
    return undefined;
  return idx;
}

export default boxState;
