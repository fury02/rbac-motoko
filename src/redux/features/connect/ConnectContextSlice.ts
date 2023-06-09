import { createAsyncThunk, createSlice, PayloadAction } from '@reduxjs/toolkit';
import { RootState, AppThunk } from '../../app/Store';
import {ConnectContext} from "./ConnectContext";
import {IConnector} from "@connect2ic/core";

//Connect2IC
export interface IConnectContext{
    Principal: string | undefined;
    isConnected: boolean;
    activeProvider: IConnector | undefined;
    nameProvider: undefined;
};
//Connect2IC
export interface ConnectContextState {
    connect_context: IConnectContext;
    status: 'idle' | 'loading' | 'failed';
};

const initialState: ConnectContextState  = {
    connect_context: {
        Principal: undefined,
        isConnected: false,
        activeProvider: undefined,
        nameProvider: undefined
    },
    status: 'idle',
};

export const connectContextSlice = createSlice({
    name: 'connect context',
    initialState,
    reducers: {
        set_connect_context_values: (state, action) => {
            state.connect_context = action.payload;
        },
    },
});

export const { set_connect_context_values } = connectContextSlice.actions;
export const selectConnectContextValues = (state: RootState) => state.connect_context_values.connect_context;

export default connectContextSlice.reducer;
