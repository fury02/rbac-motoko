import { createAsyncThunk, createSlice, PayloadAction } from '@reduxjs/toolkit';
import { RootState, AppThunk } from '../../app/Store';
import {ActorIdentityContext} from "./ActorIdentityContext";
import {ActorSubclass, HttpAgent} from '@dfinity/agent';
import {_SERVICE as service_auth_rbac} from "../../../declarations/rbac/rbac.did";
//HttpAgent (Stoic)
export interface IActorIdentity{
    ActorIdentity: ActorSubclass<service_auth_rbac> | undefined;
};
//HttpAgent (Stoic)
export interface ActorIdentityContextState {
    actor_identity_context: IActorIdentity;
    status: 'idle' | 'loading' | 'failed';
}


const initialState: ActorIdentityContextState = {
    actor_identity_context: {
        ActorIdentity: undefined
    },
    status: 'idle',
};

export const actorIdentityContextSlice = createSlice({
    name: 'actor identity context',
    initialState,
    reducers: {
        set_actor_identity_context_value: (state, action) => {
            state.actor_identity_context = action.payload;
        },
    },
});

export const { set_actor_identity_context_value } = actorIdentityContextSlice.actions;
export const selectActorIdentityContextValue = (state: RootState) => state.actor_identity_context_value.actor_identity_context;

export default actorIdentityContextSlice.reducer;
