import React, { useState } from "react";
import { Button } from "react-bootstrap";
import { Actor, ActorSubclass, HttpAgent, HttpAgentOptions, Identity, SignIdentity } from "@dfinity/agent";
// @ts-ignore
import { StoicIdentity as StoicIdentityImport } from 'ic-stoic-identity';
import { useAppDispatch, useAppSelector } from "../../../redux/app/Hooks";
import {
    IConnectContext,
    selectConnectContextValues,
    set_connect_context_values
} from "../../../redux/features/connect/ConnectContextSlice";
import {
    selectHttpAgentIdentityContextValue,
    set_http_agent_identity_context_value
} from "../../../redux/features/connect_identity/HttpAgentIdentityContextSlice";

import CSS from "csstype";
import { Navigate, useNavigate } from "react-router-dom";
import { set_participants_context_values } from "../../../redux/features/participants/ParticipantsContextSlice";
import {
    CANISTER_FRONTEND,
    CANISTER_RBAC,
    IC_URL,
    LOCAL_CANISTER_RBAC,
    LOCAL_URL,
    NODE_ENV,
    PLUG,
    LOCAL_REPLICA_PORT, II
} from "../../../const";
import {
    selectActorIdentityContextValue,
    set_actor_identity_context_value
} from "../../../redux/features/connect_actor/ActorIdentityContextSlice";
import { _SERVICE as service_auth_rbac } from "../../../declarations/rbac/rbac.did";
import { createActor, idlFactory as idl_auth_rbac } from "../../../declarations/rbac";
import { ECDSAKeyIdentity, WebAuthnIdentity } from "@dfinity/identity";
import {AuthClient} from "@dfinity/auth-client";
import {Principal} from "@dfinity/principal";
import {_SERVICE} from "ic-mops/declarations/main/main.did";

interface ActorSubclassCreate{
    actor: ActorSubclass<service_auth_rbac>;
    create: boolean;
}

const ButtonStyles: CSS.Properties = {
    backgroundColor: 'beige',
    color: 'black',
    right: 0,
    fontFamily: "serif",
    width: '80px',
};

const ConnectButtonStyles: CSS.Properties = {
    backgroundColor: 'palegreen',
    color: 'black',
    right: 0,
    fontFamily: "serif",
    width: '80px',
};

//**Stoic**//
export type StoicIdentityStaticTypes = {
    disconnect(): Promise<void>;
};
//**Stoic**//
export const StoicIdentity: StoicIdentity & StoicIdentityStaticTypes = StoicIdentityImport;
//**Stoic**//
export interface StoicIdentity extends SignIdentity {
    connect(): Promise<StoicIdentity>;
    load(host?: string): Promise<StoicIdentity | undefined>;
}
//**Stoic**//
function createStoicHttpAgentLocal(identity: StoicIdentity): HttpAgent | undefined  {
    const host = LOCAL_URL;
    try {
        const agentOptions: HttpAgentOptions = {
            host: host,
            identity: identity,
        };
        const agent = new HttpAgent(agentOptions);
        agent.fetchRootKey();//Local
        return agent;
    }
    catch (error) {
        console.log(error);
        alert(error);
        return undefined;
    }
}
//**Stoic**//
function createStoicHttpAgent(identity: StoicIdentity): HttpAgent | undefined {
    try {
        const host = IC_URL;
        const agentOptions: HttpAgentOptions = {
            host: host,
            identity: identity,
        };
        const agent = new HttpAgent(agentOptions);
        return agent;
    }
    catch (error) {
        console.log(error);
        alert(error);
        return undefined;
    }

}
//**Plug**//
async function createPlugActorLocal(): Promise<ActorSubclassCreate>  {
    let canister_id = LOCAL_CANISTER_RBAC.toString();
    const host = LOCAL_URL;
    let list = [canister_id];
    try {
        const connect = await (window as any)?.ic?.plug?.requestConnect({ whitelist: list, host: host });//error parse???
        await (window as any)?.ic?.plug?.createAgent({ whitelist: list, host: host });//error parse??? local???
        await (window as any)?.ic?.plug?.agent.getPrincipal();
        let root_key = await (window as any)?.ic?.plug?.agent.fetchRootKey();//Local
        const plug_actor = await (window as any)?.ic?.plug?.createActor({
            canisterId: canister_id,
            interfaceFactory: idl_auth_rbac
        });
        return {actor: plug_actor, create: true};
    }
    catch (error) {
        console.log(error);
        alert(error);
        let options = {};
        const agentOptions = { ...options, host: host };
        const agent = new HttpAgent(agentOptions);
        agent.fetchRootKey();//Local
        const actor_empty = Actor.createActor<service_auth_rbac>(idl_auth_rbac, {
            agent,
            canisterId: canister_id
        });
        return {actor: actor_empty, create: false};
    }
}
//**Plug**//
async function createPlugActor(): Promise<ActorSubclassCreate> {
    let canister_id = CANISTER_RBAC.toString();
    let canister_frontend = CANISTER_FRONTEND.toString();
    const host = IC_URL;
    // let list = [canister_id, canister_frontend];
    let list = [canister_id];
    try {
        const connect = await (window as any)?.ic?.plug?.requestConnect({ whitelist: list, host: host });//error parse???
        await (window as any)?.ic?.plug?.createAgent({ whitelist: list, host: host });//error parse??? local???
        await (window as any)?.ic?.plug?.agent.getPrincipal();
        const plug_actor = await (window as any)?.ic?.plug?.createActor({
            canisterId: canister_id,
            interfaceFactory: idl_auth_rbac
        });
        return {actor: plug_actor, create: true};
    }
    catch (error) {
        console.log(error);
        alert(error);
        let options = {};
        const agentOptions = { ...options, host: host };
        const agent = new HttpAgent(agentOptions);
        const actor_empty = Actor.createActor<service_auth_rbac>(idl_auth_rbac, {
            agent,
            canisterId: canister_id
        });
        return {actor: actor_empty, create: false};
    }
};
//**II**//
const days = BigInt(1);
const hours = BigInt(24);
const nanoseconds = BigInt(3600000000000);

export const AuthComponent: React.FC = () => {
    //Redux dispatch
    const dispatch = useAppDispatch();
    //Redux connect context
    const connect_context: IConnectContext = useAppSelector(selectConnectContextValues);
    const provider = connect_context.nameProvider;
    //Redux agent
    const http_agent_context_stored = useAppSelector(selectHttpAgentIdentityContextValue);
    const actor_identity_context_stored = useAppSelector(selectActorIdentityContextValue);
    //Redux - store get values
    const http_agent_stored = http_agent_context_stored.HttpAgent;
    const actor_identity_stored = actor_identity_context_stored.ActorIdentity;
    const navigate = useNavigate();

    const [stylePlug, setStylePlug] = useState<CSS.Properties>(ButtonStyles);
    const [styleStoic, setStyleStoic] = useState<CSS.Properties>(ButtonStyles);
    const [styleII, setStyleII] = useState<CSS.Properties>(ButtonStyles);
    //**Stoic**//
    const ButtonClickStoic = async () => {
        //**
        //You can bypass Redux
        //and use Stoic Storage
        //but this limits the integration of other providers
        //const stoicIdentity = await StoicIdentity.load();
        // **//
        //disconnect
        if (http_agent_stored) {
            await DisconnectStoic();
            await DisconnectPlug();
            await DisconnectII();
            await GoHome();
        }
        //connect
        else {
            await DisconnectStoic();
            await DisconnectPlug();
            await DisconnectII();
            await ConnectStoic();
            await GoHome();
        }
    }
    //**Plug**//
    const ButtonClickPlug = async () => {
        if (actor_identity_stored) {
            await DisconnectStoic();
            await DisconnectPlug();
            await DisconnectII();
            if(provider === 'II'){
                await ConnectPlug();
            }
            await GoHome();
        }
        //connect
        else {
            await DisconnectStoic();
            await DisconnectPlug();
            await DisconnectII();
            await ConnectPlug();
            await GoHome();
        }
    };
    //**II**//
    /*Only IC Network */
    const ButtonClickII = async () => {
        //disconnect
        if (actor_identity_stored) {
            await DisconnectStoic();
            await DisconnectPlug();
            await DisconnectII();
            if(provider === 'Plug'){
                await ConnectII();
            }
            await GoHome();
        }
        //connect
        else {
            await DisconnectPlug();
            await DisconnectStoic();
            await DisconnectII();
            await ConnectII();
            await GoHome();
        }
    };
    //**II**//
    /*Only IC Network */
    const ConnectII = async () => {
        const options = {
            createOptions: {
                idleOptions: { disableIdle: false, },
            },
            loginOptions: { identityProvider: II, },
        };
        const authClient = await AuthClient.create(options.createOptions);
        await authClient.login({
            ...options.loginOptions,
            onSuccess: () => {
                HandlerConnectII(authClient);
            },
            onError: (error) => {
                console.error('Login Failed: ', error);
                alert(error);
            }
        });
    };
    //**II**//
    /*Only IC Network */
    async function HandlerConnectII(authClient: AuthClient) {
        try {
            let canister_id = CANISTER_RBAC.toString();
            let identity = (await authClient.getIdentity()) as unknown as Identity;
            let principal = identity.getPrincipal();
            const host = IC_URL;
            const agentOptions: HttpAgentOptions = {
                host: host,
                identity: identity,
            };
            let actor = createActor(canister_id, {
                agentOptions: agentOptions
            });

            //**My test**//
            // let whoami = await actor.whoami_caller();
            // if(principal.toString() === whoami ) { setStyleII(ConnectButtonStyles);}

            if (actor) {
                dispatch(set_actor_identity_context_value({
                    ActorIdentity: actor,
                }));
                //Redux set values (Principal)
                dispatch(set_connect_context_values({
                    Principal: principal.toString(),
                    isConnected: true,
                    activeProvider: undefined,
                    nameProvider: 'II'
                }));
                setStyleII(ConnectButtonStyles);
            }
            else {
                await DisconnectII();
            }
        }
        catch (error) {
            console.log(error);
            alert(error);
        };
    };
    //**Plug**//
    const DisconnectII = async () => {
        dispatch(set_actor_identity_context_value({
            ActorIdentity: undefined,
        }));
        //Redux set values (Principal)
        dispatch(set_connect_context_values({
            Principal: undefined,
            isConnected: false,
            activeProvider: undefined,
            nameProvider: undefined
        }));
        dispatch(set_participants_context_values({
            user: [],
            roles: [],
            permissions: [],
        }));
        setStyleII(ButtonStyles);
    };
    //**Stoic**//
    const ConnectStoic = async () => {
        try {
            StoicIdentity.connect().then(identity => {

                    // const agent = process.env.DFX_NETWORK === ic ? createStoicHttpAgent(identity) : createStoicHttpAgentLocal(identity);
                    const agent = NODE_ENV.toString() == 'production' ? createStoicHttpAgent(identity) : createStoicHttpAgentLocal(identity);
                    // const agent = createStoicHttpAgent(identity);

                    if (agent) {
                        //Redux set HttpAgent (Stoic Identity)
                        dispatch(set_http_agent_identity_context_value({
                            HttpAgent: agent,
                        }));
                        //Redux set values (Principal)
                        dispatch(set_connect_context_values({
                            Principal: identity.getPrincipal().toString(),
                            isConnected: true,
                            activeProvider: undefined,
                            nameProvider: 'Stoic'
                        }));
                        setStyleStoic(ConnectButtonStyles);
                    }
                }
            );
        }
        catch (error) {
            console.log(error);
            alert(error);
        }
    };
    //**Stoic**//
    const DisconnectStoic = async () => {
        //Redux set HttpAgent (Stoic Identity)
        dispatch(set_http_agent_identity_context_value({
            HttpAgent: undefined,
        }));
        //Redux set values (Principal)
        dispatch(set_connect_context_values({
            Principal: undefined,
            isConnected: false,
            activeProvider: undefined,
            nameProvider: undefined
        }));
        dispatch(set_participants_context_values({
            user: [],
            roles: [],
            permissions: [],
        }));
        await StoicIdentity.disconnect();
        setStyleStoic(ButtonStyles);
    };
    //**Plug**//
    const ConnectPlug = async () => {
        try {
            if (!(window as any).ic?.plug) {
                window.open(PLUG, '_blank');
                return;
            }

            // let plug: ActorSubclassCreate = process.env.DFX_NETWORK === ic ? await createPlugActor() : await createPlugActorLocal();
            let plug: ActorSubclassCreate = NODE_ENV.toString() == 'production' ? await createPlugActor() : await createPlugActorLocal();
            // let plug: ActorSubclassCreate = await createPlugActor();
            const principal = await (window as any)?.ic?.plug?.agent.getPrincipal();

            if (plug.create) {
                dispatch(set_actor_identity_context_value({
                    ActorIdentity: plug.actor,
                }));
                //Redux set values (Principal)
                dispatch(set_connect_context_values({
                    Principal: principal.toString(),
                    isConnected: true,
                    activeProvider: undefined,
                    nameProvider: 'Plug'
                }));
                setStylePlug(ConnectButtonStyles);
            }
            else {
                await DisconnectPlug();
            }
        }
        catch (error) {
            console.log(error);
            alert(error);
        }
    };
    //**Plug**//
    const DisconnectPlug = async () => {
        dispatch(set_actor_identity_context_value({
            ActorIdentity: undefined,
        }));
        //Redux set values (Principal)
        dispatch(set_connect_context_values({
            Principal: undefined,
            isConnected: false,
            activeProvider: undefined,
            nameProvider: undefined
        }));
        dispatch(set_participants_context_values({
            user: [],
            roles: [],
            permissions: [],
        }));
        setStylePlug(ButtonStyles);
    };

    const GoHome = async () =>{
        // home navigate
        navigate("/");
    }

    return (
        <div className="row gx-2">
            <div className="col">
                <Button disabled={false}
                    onClick={() => ButtonClickStoic()}
                    style={styleStoic}> Stoic
                </Button>
            </div>
            <div className="col">
                <Button disabled={false}
                        onClick={() => ButtonClickII()}
                        style={styleII}> IIdentity
                </Button>
            </div>
            {/*Plug don't  work https://forum.dfinity.org/t/creating-a-web-canister/20460/29
             fetchRootKey() */}
            <div className="col">
                <Button disabled={true}
                        onClick={() => ButtonClickPlug()}
                        style={stylePlug}> Plug
                </Button>
                {/*<Button disabled={false}*/}
                {/*        onClick={() => ButtonClickPlug()}*/}
                {/*        style={stylePlug}> Plug*/}
                {/*</Button>*/}
            </div>
        </div>);

}