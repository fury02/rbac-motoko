import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface _SERVICE {
  'test' : ActorMethod<[], undefined>,
  'test_acces_rbac' : ActorMethod<[], undefined>,
}
