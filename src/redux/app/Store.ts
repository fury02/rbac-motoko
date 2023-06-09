import { configureStore, ThunkAction, Action} from '@reduxjs/toolkit';
import storage from 'redux-persist/lib/storage';
import { combineReducers } from 'redux';
import thunk from 'redux-thunk';
import { persistReducer } from 'redux-persist';

import connectContextReducer from '../features/connect/ConnectContextSlice';
import httpAgentIdentityContextSlice from '../features/connect_identity/HttpAgentIdentityContextSlice';
import participantsContextSlice from '../features/participants/ParticipantsContextSlice';
import actorIdentityContextSlice from '../features/connect_actor/ActorIdentityContextSlice';
import AsyncStorage from "@react-native-async-storage/async-storage";

const reducers = combineReducers({
    connect_context_values: connectContextReducer,
    http_agent_identity_context_value: httpAgentIdentityContextSlice,
    actor_identity_context_value: actorIdentityContextSlice,
    participants_context_values: participantsContextSlice,

});

// const persistConfig = {
//   key: 'root',
//   storage: AsyncStorage ,
//   blacklist: [
//       'navigation',
//       'connect_context_values',
//       'http_agent_identity_context_value'
//   ],
//   whitelist: ['participants_context_values'],
// };

const persistConfig = {
    key: 'root',
    storage: AsyncStorage ,
    blacklist: [
        'navigation',
        'connect_context_values',
        'http_agent_identity_context_value'
    ],
    whitelist: [],
};


const persistedReducer = persistReducer(persistConfig, reducers);

export const store = configureStore({
  reducer: persistedReducer,
  middleware: [thunk],
});

export type AppDispatch = typeof store.dispatch;
export type RootState = ReturnType<typeof store.getState>;
export type AppThunk<ReturnType = void> = ThunkAction<ReturnType, RootState, unknown, Action<string>>;
