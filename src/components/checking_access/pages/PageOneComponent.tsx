import React, {useEffect, useState} from "react";
import {useAppDispatch, useAppSelector} from "../../../redux/app/Hooks";
import {IConnectContext, selectConnectContextValues} from "../../../redux/features/connect/ConnectContextSlice";
import {
    IHttpAgentIdentity,
    selectHttpAgentIdentityContextValue
} from "../../../redux/features/connect_identity/HttpAgentIdentityContextSlice";
import {Actor} from "@dfinity/agent";
import {_SERVICE as service_auth_rbac} from "../../../declarations/rbac/rbac.did";
import {idlFactory as idl_auth_rbac} from "../../../declarations/rbac/index";
import {Principal} from "@dfinity/principal";
import {Button, Col, Container, Form, InputGroup, Row} from "react-bootstrap";
import {
    IParticipantsContext,
    selectParticipantsContextValues, set_participants_context_values
} from "../../../redux/features/participants/ParticipantsContextSlice";
import {CANISTER_RBAC, LOCAL_CANISTER_RBAC, NODE_ENV} from "../../../const";
import {selectActorIdentityContextValue} from "../../../redux/features/connect_actor/ActorIdentityContextSlice";

export const PageOneComponent: React.FC = () => {
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
    const participants_context_stored: IParticipantsContext = useAppSelector(selectParticipantsContextValues);
    //Redux - store get values
    const principal = connect_context.Principal;
    // const actor = process.env.NODE_ENV === 'production' ? new Actor_ic().actor_service : new Actor_local().actor_service;
    let canister_id = NODE_ENV.toString() == 'production' ? CANISTER_RBAC.toString() : LOCAL_CANISTER_RBAC.toString();
    //Redux - store get values
    const agent = http_agent_context_stored.HttpAgent;
    const [caller, setCaller] = useState<string>('');
    const [access_right, setAccessRight] = useState<boolean>(false);

    useEffect(() => {
        async function AsyncAction() {
            try {
                if (provider == 'Stoic' &&  canister_id != null && agent != undefined && canister_id != undefined){
                    const actor = Actor.createActor<service_auth_rbac>(idl_auth_rbac, {
                        agent,
                        canisterId: Principal.fromText(canister_id)
                    });

                    setAccessRight(await actor.access_right_one_page());
                }
                if ((provider == 'Plug' || provider == 'II') &&  canister_id != null && actor_identity_stored != undefined && canister_id != undefined){
                    setAccessRight(await actor_identity_stored.access_right_one_page());
                }

            }
            catch (e) {
                console.log(e);
            }
        }
        AsyncAction();
    }, [])

    let access_right_view = access_right == false?
        <>
            <div>
                <h6 className="text-danger">access failed</h6>
            </div>
        </> :
        <>
            <div>
                <h6 className="text-success">access permission is present</h6>
            </div>
        </>


    return (
        <Container>
            <Row>
                <Col>
                    <>
                        {access_right_view}
                    </>
                </Col>
            </Row>
        </Container>
    );
}