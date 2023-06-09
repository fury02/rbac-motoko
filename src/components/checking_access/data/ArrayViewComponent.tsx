import React, {useEffect, useState} from "react";
import {useAppDispatch, useAppSelector} from "../../../redux/app/Hooks";
import {IConnectContext, selectConnectContextValues} from "../../../redux/features/connect/ConnectContextSlice";
import {
    IHttpAgentIdentity,
    selectHttpAgentIdentityContextValue
} from "../../../redux/features/connect_identity/HttpAgentIdentityContextSlice";
import {
    IParticipantsContext,
    selectParticipantsContextValues
} from "../../../redux/features/participants/ParticipantsContextSlice";
import {Actor} from "@dfinity/agent";
import {_SERVICE as service_auth_rbac} from "../../../declarations/rbac/rbac.did";
import {idlFactory as idl_auth_rbac} from "../../../declarations/rbac/index";
import {Principal} from "@dfinity/principal";
import {Col, Container, Row} from "react-bootstrap";
import {render} from "@testing-library/react";
import {AlertDialog} from "../../alert/AlertDialog";
import {CANISTER_RBAC, LOCAL_CANISTER_RBAC, NODE_ENV} from "../../../const";
import {selectActorIdentityContextValue} from "../../../redux/features/connect_actor/ActorIdentityContextSlice";

export const ArrayViewComponent: React.FC = () => {
    //Redux dispatch
    const dispatch = useAppDispatch();
    //Redux connect context
    const connect_context: IConnectContext = useAppSelector(selectConnectContextValues);
    //Redux agent whith identity (Stoic)
    const http_agent_context_stored = useAppSelector(selectHttpAgentIdentityContextValue);
    //Redux actor whith identity (Plug)
    const actor_identity_context_stored = useAppSelector(selectActorIdentityContextValue);
    //Redux - store get values
    const http_agent_stored = http_agent_context_stored.HttpAgent;
    const actor_identity_stored = actor_identity_context_stored.ActorIdentity;
    //Redux - store get values
    const provider = connect_context.nameProvider;
    //Redux - store get values HttpAgent
    const agent = http_agent_context_stored.HttpAgent;
    const participants_context_stored: IParticipantsContext = useAppSelector(selectParticipantsContextValues);
    //Redux - store get values
    const principal = connect_context.Principal;
    // const actor = process.env.NODE_ENV === 'production' ? new Actor_ic().actor_service : new Actor_local().actor_service;
    let canister_id = NODE_ENV.toString() == 'production' ? CANISTER_RBAC.toString() : LOCAL_CANISTER_RBAC.toString();

    const [caller, setCaller] = useState<string>('');

    const [array, setArray] = useState<bigint[]>([]);
    const [array_str, setArrayStr] = useState<string>('');

    useEffect(() => {
        async function AsyncAction() {
            try {

                if (provider == 'Stoic' &&  canister_id != null && agent != undefined && canister_id != undefined){
                    const actor = Actor.createActor<service_auth_rbac>(idl_auth_rbac, {
                        agent,
                        canisterId: Principal.fromText(canister_id)
                    });

                    let response = await actor.read_array();

                    if(Object.keys(response)[0] == "ok"){
                        var result = Object.values(response);
                        setArray(result);
                        setArrayStr(arrToStr(result));
                    }
                    else {
                        alert("Access array failed");
                        // render(<AlertDialog text_alert={"Access array failed"}/>);
                    }
                }
                if ((provider == 'Plug' || provider == 'II') &&  canister_id != null && actor_identity_stored != undefined && canister_id != undefined){
                    let response = await actor_identity_stored.read_array();

                    if(Object.keys(response)[0] == "ok"){
                        var result = Object.values(response);
                        setArray(result);
                        setArrayStr(arrToStr(result));
                    }
                    else {
                        alert("Access array failed");
                        // render(<AlertDialog text_alert={"Access array failed"}/>);
                    }
                }
            }
            catch (e) {
                console.log(e);
            }
        }
        AsyncAction();
    }, [])

    let print_array_view = array.length == 0?
        <>

        </> :
        <>
            <h6 className="small">Array:</h6>
            <h6 className="text-muted fst-italic small">
                {array_str}
            </h6>
        </>

    const arrToStr = (arr: string[]) => {
        var s = '';
        if(arr.length != 0){
            arr.forEach(i=>{
                    s += i.toString()+ ';' + ' '
                }
            )
        }
        return s;
    }

    return (
        <Container>
            <Row>
                <Col>
                    <>
                        {print_array_view}
                    </>
                </Col>
            </Row>
        </Container>
    );
}