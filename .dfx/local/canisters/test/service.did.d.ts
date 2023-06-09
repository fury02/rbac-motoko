import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface _SERVICE {
  'add_user' : ActorMethod<[], undefined>,
  'test' : ActorMethod<[], undefined>,
  'test_rbac' : ActorMethod<[], undefined>,
}
