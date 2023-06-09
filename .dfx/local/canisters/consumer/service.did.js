export const idlFactory = ({ IDL }) => {
  return IDL.Service({
    'client' : IDL.Func([], [], []),
    'notify' : IDL.Func([], [], []),
    'valid' : IDL.Func([], [], []),
  });
};
export const init = ({ IDL }) => { return []; };
