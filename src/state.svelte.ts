type State = {
  boxes : {
    items : string[];
    modificationTime : Date;
  }[];
};

export let boxState : State = $state({boxes : []});
export default boxState;
