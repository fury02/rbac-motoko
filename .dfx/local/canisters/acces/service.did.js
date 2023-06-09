export const idlFactory = ({ IDL }) => {
  return IDL.Service({
    'test' : IDL.Func([], [], []),
    'test_acces_rbac' : IDL.Func([], [], []),
  });
};
export const init = ({ IDL }) => { return []; };
