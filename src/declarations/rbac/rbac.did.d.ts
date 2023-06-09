import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export type Admin = Principal;
export type Admins = Array<Admin>;
export type Alg = { 'NONE' : null };
export interface AuthClient { 'token' : Token, 'participant' : Participant }
export type Errors = { 'invalid_caller' : null } |
  { 'contain' : null } |
  { 'access_error' : null } |
  { 'invalid_client' : null } |
  { 'error_add' : null } |
  { 'unbind_failed' : null } |
  { 'not_contain' : null } |
  { 'error_delete' : null } |
  { 'invalid_token' : null };
export interface Header { 'alg' : Alg, 'typ' : TypeToken }
export type JTI = string;
export type List = [] | [[RelatedRP, List]];
export type ListRelatedRP = [] | [[RelatedRP, List]];
export type Participant = { 'User' : null } |
  { 'Admin' : null };
export interface Payload {
  'aud' : string,
  'exp' : bigint,
  'iat' : string,
  'iss' : string,
  'jti' : JTI,
  'lrp' : ListRelatedRP,
  'nbf' : string,
  'sub' : string,
  'principal' : Principal,
}
export type Permission = string;
export type Permission__1 = string;
export type Permissions = Array<Permission>;
export type Permissions__1 = Array<Permission>;
export interface RelatedRP { 'permissions' : Permissions, 'role' : Role }
export type Result = { 'ok' : Users } |
  { 'err' : Errors };
export type Result_1 = { 'ok' : Roles } |
  { 'err' : Errors };
export type Result_2 = { 'ok' : Permissions__1 } |
  { 'err' : Errors };
export type Result_3 = {
    'ok' : {
      'status' : { 'stopped' : null } |
        { 'stopping' : null } |
        { 'running' : null },
      'freezing_threshold' : bigint,
      'memory_size' : bigint,
      'cycles' : bigint,
      'settings' : definite_canister_settings,
      'module_hash' : [] | [Uint8Array | number[]],
    }
  } |
  { 'err' : Errors };
export type Result_4 = { 'ok' : AuthClient } |
  { 'err' : Errors };
export type Result_5 = { 'ok' : Admins } |
  { 'err' : Errors };
export type Result_6 = { 'ok' : User__1 } |
  { 'err' : Errors };
export type Result_7 = { 'ok' : Role__1 } |
  { 'err' : Errors };
export type Result_8 = { 'ok' : Permission__1 } |
  { 'err' : Errors };
export type Result_9 = { 'ok' : boolean } |
  { 'err' : Errors };
export type Role = string;
export type Role__1 = string;
export type Roles = Array<Role>;
export type Scaner = { 'ON' : null } |
  { 'OFF' : null };
export interface Token { 'payload' : Payload, 'header' : Header }
export type TypeToken = { 'JWT' : null } |
  { 'UJWT' : null };
export type User = Principal;
export type User__1 = Principal;
export type Users = Array<User>;
export interface definite_canister_settings {
  'freezing_threshold' : bigint,
  'controllers' : Array<Principal>,
  'memory_allocation' : bigint,
  'compute_allocation' : bigint,
}
export interface _SERVICE {
  '_users' : ActorMethod<[], Result>,
  'add_admin' : ActorMethod<[User__1], Result_6>,
  'add_permissions' : ActorMethod<[Permission__1, AuthClient], Result_8>,
  'add_role' : ActorMethod<[Role__1, AuthClient], Result_7>,
  'add_user' : ActorMethod<[User__1, AuthClient], Result_6>,
  'bind_permissions' : ActorMethod<
    [Permission__1, Role__1, AuthClient],
    Result_2
  >,
  'bind_role' : ActorMethod<[User__1, Role__1, AuthClient], Result_1>,
  'canister_id' : ActorMethod<[], Principal>,
  'delete_admin' : ActorMethod<[User__1], Result_6>,
  'delete_client' : ActorMethod<[AuthClient], Result_9>,
  'delete_permissions' : ActorMethod<[Permission__1, AuthClient], Result_8>,
  'delete_role' : ActorMethod<[Role__1, AuthClient], Result_7>,
  'delete_user' : ActorMethod<[User__1, AuthClient], Result_6>,
  'init' : ActorMethod<[], Result_5>,
  'new_client' : ActorMethod<[], Result_4>,
  'permissions' : ActorMethod<[AuthClient], Result_2>,
  'request_client' : ActorMethod<[], Result_4>,
  'roles' : ActorMethod<[AuthClient], Result_1>,
  'status' : ActorMethod<[], Result_3>,
  'status_scaner' : ActorMethod<[], Scaner>,
  'test_start_scaner' : ActorMethod<[], undefined>,
  'unbind_permission' : ActorMethod<
    [Permission__1, Role__1, AuthClient],
    Result_2
  >,
  'unbind_role' : ActorMethod<[User__1, Role__1, AuthClient], Result_1>,
  'users' : ActorMethod<[AuthClient], Result>,
  'valid_client' : ActorMethod<[], boolean>,
  'whoami_caller' : ActorMethod<[], string>,
}
