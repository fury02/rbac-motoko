import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface _SERVICE {
  'client' : ActorMethod<[], undefined>,
  'notify' : ActorMethod<[], undefined>,
  'valid' : ActorMethod<[], undefined>,
}
