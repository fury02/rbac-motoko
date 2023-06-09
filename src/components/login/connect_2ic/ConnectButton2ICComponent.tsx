import React, {PropsWithChildren} from "react";
import { defaultProviders } from "@connect2ic/core/providers"
import {Client, createClient} from "@connect2ic/core"
import {Connect2ICProvider,  ConnectButton, ConnectDialog, useConnect} from "@connect2ic/react"
import "@connect2ic/core/style.css"
import CSS from 'csstype';
import {useAppDispatch, useAppSelector} from "../../../redux/app/Hooks";
import {selectConnectContextValues, set_connect_context_values} from "../../../redux/features/connect/ConnectContextSlice";

// import * as counter from "canisters/counter"

const ButtonStyles: CSS.Properties = {
    backgroundColor: 'beige',
    color: 'black',
    right: 0,

};
const ConnectButtonStyles: CSS.Properties = {
    backgroundColor: 'palegreen',
    color: 'black',
    right: 0,

};
const client = createClient({
    canisters: { },
    // @ts-ignore
    providers: defaultProviders,
})

function AppConnectButton() {
    //Redux dispatch
    const dispatch = useAppDispatch();
    const { isConnected, principal, activeProvider }
        = useConnect({
            // Signed in
            onConnect: () => {
                // Backend:
                // Send the principal to the user ->
                // <- Get previously granted permissions and roles
            },
            // Signed out
            onDisconnect: () => {
                //Redux - store set values: undefined
                dispatch(set_connect_context_values({
                    Principal: undefined,
                    isConnected: false,
                    activeProvider: undefined}));
            }
        })

    //Redux - store set values
    dispatch(set_connect_context_values({
        Principal: principal,
        isConnected: isConnected,
        activeProvider: activeProvider
    }));

    React.useEffect(() => {
        if(principal != undefined && activeProvider != undefined){
            //Action
        }
    });

    return (
        <>
            <ConnectButton style={principal == undefined ? ButtonStyles : ConnectButtonStyles} />
            <ConnectDialog dark={false} />
        </>
    )
}

export default class  ConnectButton2ICComponent extends React.Component{
    render() {
        return (<Connect2ICProvider client={client}>
            <AppConnectButton />
        </Connect2ICProvider>);
    }
}

