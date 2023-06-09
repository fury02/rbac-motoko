import { createAsyncThunk, createSlice, PayloadAction } from '@reduxjs/toolkit';
import { RootState, AppThunk } from '../../app/Store';
import {HttpAgentIdentityContext} from "./HttpAgentIdentityContext";
import { HttpAgent } from '@dfinity/agent';
//HttpAgent (Stoic)
export interface IHttpAgentIdentity{
    HttpAgent: HttpAgent | undefined;
};
//HttpAgent (Stoic)
export interface HttpAgentIdentityContextState {
    http_agent_identity_context: IHttpAgentIdentity;
    status: 'idle' | 'loading' | 'failed';
}


const initialState: HttpAgentIdentityContextState = {
    http_agent_identity_context: {
        HttpAgent: undefined
    },
    status: 'idle',
};

export const httpAgentIdentityContextSlice = createSlice({
    name: 'http agent identity context',
    initialState,
    reducers: {
        set_http_agent_identity_context_value: (state, action) => {
            state.http_agent_identity_context = action.payload;
        },
    },
});

export const { set_http_agent_identity_context_value } = httpAgentIdentityContextSlice.actions;
export const selectHttpAgentIdentityContextValue = (state: RootState) => state.http_agent_identity_context_value.http_agent_identity_context;

export default httpAgentIdentityContextSlice.reducer;
