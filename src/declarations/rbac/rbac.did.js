export const idlFactory = ({ IDL }) => {
  const List = IDL.Rec();
  const User = IDL.Principal;
  const Users = IDL.Vec(User);
  const Errors = IDL.Variant({
    'invalid_caller' : IDL.Null,
    'contain' : IDL.Null,
    'access_error' : IDL.Null,
    'invalid_client' : IDL.Null,
    'error_add' : IDL.Null,
    'unbind_failed' : IDL.Null,
    'not_contain' : IDL.Null,
    'error_delete' : IDL.Null,
    'invalid_token' : IDL.Null,
  });
  const Result = IDL.Variant({ 'ok' : Users, 'err' : Errors });
  const User__1 = IDL.Principal;
  const Result_6 = IDL.Variant({ 'ok' : User__1, 'err' : Errors });
  const Permission__1 = IDL.Text;
  const JTI = IDL.Text;
  const Permission = IDL.Text;
  const Permissions = IDL.Vec(Permission);
  const Role = IDL.Text;
  const RelatedRP = IDL.Record({ 'permissions' : Permissions, 'role' : Role });
  List.fill(IDL.Opt(IDL.Tuple(RelatedRP, List)));
  const ListRelatedRP = IDL.Opt(IDL.Tuple(RelatedRP, List));
  const Payload = IDL.Record({
    'aud' : IDL.Text,
    'exp' : IDL.Int,
    'iat' : IDL.Text,
    'iss' : IDL.Text,
    'jti' : JTI,
    'lrp' : ListRelatedRP,
    'nbf' : IDL.Text,
    'sub' : IDL.Text,
    'principal' : IDL.Principal,
  });
  const Alg = IDL.Variant({ 'NONE' : IDL.Null });
  const TypeToken = IDL.Variant({ 'JWT' : IDL.Null, 'UJWT' : IDL.Null });
  const Header = IDL.Record({ 'alg' : Alg, 'typ' : TypeToken });
  const Token = IDL.Record({ 'payload' : Payload, 'header' : Header });
  const Participant = IDL.Variant({ 'User' : IDL.Null, 'Admin' : IDL.Null });
  const AuthClient = IDL.Record({
    'token' : Token,
    'participant' : Participant,
  });
  const Result_8 = IDL.Variant({ 'ok' : Permission__1, 'err' : Errors });
  const Role__1 = IDL.Text;
  const Result_7 = IDL.Variant({ 'ok' : Role__1, 'err' : Errors });
  const Permissions__1 = IDL.Vec(Permission);
  const Result_2 = IDL.Variant({ 'ok' : Permissions__1, 'err' : Errors });
  const Roles = IDL.Vec(Role);
  const Result_1 = IDL.Variant({ 'ok' : Roles, 'err' : Errors });
  const Result_9 = IDL.Variant({ 'ok' : IDL.Bool, 'err' : Errors });
  const Admin = IDL.Principal;
  const Admins = IDL.Vec(Admin);
  const Result_5 = IDL.Variant({ 'ok' : Admins, 'err' : Errors });
  const Result_4 = IDL.Variant({ 'ok' : AuthClient, 'err' : Errors });
  const definite_canister_settings = IDL.Record({
    'freezing_threshold' : IDL.Nat,
    'controllers' : IDL.Vec(IDL.Principal),
    'memory_allocation' : IDL.Nat,
    'compute_allocation' : IDL.Nat,
  });
  const Result_3 = IDL.Variant({
    'ok' : IDL.Record({
      'status' : IDL.Variant({
        'stopped' : IDL.Null,
        'stopping' : IDL.Null,
        'running' : IDL.Null,
      }),
      'freezing_threshold' : IDL.Nat,
      'memory_size' : IDL.Nat,
      'cycles' : IDL.Nat,
      'settings' : definite_canister_settings,
      'module_hash' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    }),
    'err' : Errors,
  });
  const Scaner = IDL.Variant({ 'ON' : IDL.Null, 'OFF' : IDL.Null });
  return IDL.Service({
    '_users' : IDL.Func([], [Result], []),
    'add_admin' : IDL.Func([User__1], [Result_6], []),
    'add_permissions' : IDL.Func([Permission__1, AuthClient], [Result_8], []),
    'add_role' : IDL.Func([Role__1, AuthClient], [Result_7], []),
    'add_user' : IDL.Func([User__1, AuthClient], [Result_6], []),
    'bind_permissions' : IDL.Func(
        [Permission__1, Role__1, AuthClient],
        [Result_2],
        [],
      ),
    'bind_role' : IDL.Func([User__1, Role__1, AuthClient], [Result_1], []),
    'canister_id' : IDL.Func([], [IDL.Principal], []),
    'delete_admin' : IDL.Func([User__1], [Result_6], []),
    'delete_client' : IDL.Func([AuthClient], [Result_9], []),
    'delete_permissions' : IDL.Func(
        [Permission__1, AuthClient],
        [Result_8],
        [],
      ),
    'delete_role' : IDL.Func([Role__1, AuthClient], [Result_7], []),
    'delete_user' : IDL.Func([User__1, AuthClient], [Result_6], []),
    'init' : IDL.Func([], [Result_5], []),
    'new_client' : IDL.Func([], [Result_4], []),
    'permissions' : IDL.Func([AuthClient], [Result_2], []),
    'request_client' : IDL.Func([], [Result_4], []),
    'roles' : IDL.Func([AuthClient], [Result_1], []),
    'status' : IDL.Func([], [Result_3], []),
    'status_scaner' : IDL.Func([], [Scaner], []),
    'test_start_scaner' : IDL.Func([], [], ['oneway']),
    'unbind_permission' : IDL.Func(
        [Permission__1, Role__1, AuthClient],
        [Result_2],
        [],
      ),
    'unbind_role' : IDL.Func([User__1, Role__1, AuthClient], [Result_1], []),
    'users' : IDL.Func([AuthClient], [Result], []),
    'valid_client' : IDL.Func([], [IDL.Bool], []),
    'whoami_caller' : IDL.Func([], [IDL.Text], []),
  });
};
export const init = ({ IDL }) => { return []; };
