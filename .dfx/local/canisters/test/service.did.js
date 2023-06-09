export const idlFactory = ({ IDL }) => {
  return IDL.Service({
    'add_user' : IDL.Func([], [], []),
    'test' : IDL.Func([], [], []),
    'test_rbac' : IDL.Func([], [], []),
  });
};
export const init = ({ IDL }) => { return []; };
