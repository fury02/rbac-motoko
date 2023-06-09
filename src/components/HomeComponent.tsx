import React, {useEffect, useState} from "react";
import {useAppDispatch, useAppSelector} from "../redux/app/Hooks";
import {IConnectContext, selectConnectContextValues} from "../redux/features/connect/ConnectContextSlice";
import {Button, Col, Container, Form, InputGroup, Row} from "react-bootstrap";
import {
    IHttpAgentIdentity,
    selectHttpAgentIdentityContextValue
} from "../redux/features/connect_identity/HttpAgentIdentityContextSlice";
import {Actor} from "@dfinity/agent";
import {_SERVICE as service_auth_rbac} from "../declarations/rbac/rbac.did";
import {idlFactory as idl_auth_rbac} from "../declarations/rbac/index";
import {Principal} from "@dfinity/principal";
import {CANISTER_RBAC, LOCAL_CANISTER_RBAC, NODE_ENV} from "../const";
import {selectActorIdentityContextValue} from "../redux/features/connect_actor/ActorIdentityContextSlice";
import {set_participants_context_values} from "../redux/features/participants/ParticipantsContextSlice";
import CSS from "csstype";

export const HomeComponent: React.FC = () => {
    //Redux dispatch
    const dispatch = useAppDispatch();
    //Redux connect context
    const connect_context: IConnectContext = useAppSelector(selectConnectContextValues);
    //Redux agent
    const http_agent_context_stored = useAppSelector(selectHttpAgentIdentityContextValue);
    const actor_identity_context_stored = useAppSelector(selectActorIdentityContextValue);
    //Redux - store get values
    const http_agent_stored = http_agent_context_stored.HttpAgent;
    const actor_identity_stored = actor_identity_context_stored.ActorIdentity;
    //Redux - store get values
    const principal = connect_context.Principal;
    const provider = connect_context.nameProvider;
    const [canister_id, setCanisterId]
        = useState<string | undefined>(NODE_ENV.toString() == 'production' ? CANISTER_RBAC.toString() : LOCAL_CANISTER_RBAC.toString());
    const [caller, setCaller] = useState<string>('');

    const ButtonClick = async () =>{
        const principal = connect_context.Principal;
        //Redux - store get values
        const agent = http_agent_context_stored.HttpAgent;
        let canister_id = NODE_ENV.toString() == 'production' ? CANISTER_RBAC.toString() : LOCAL_CANISTER_RBAC.toString()
        if(provider == 'Stoic' && agent != undefined && canister_id != undefined){
            const actor = Actor.createActor<service_auth_rbac>(idl_auth_rbac, {
                agent,
                canisterId: Principal.fromText(canister_id)});
            let result = await actor.whoami_caller();
            setCaller(result);
        }
        if(provider == 'Plug' && actor_identity_stored != undefined && canister_id != undefined){
            let result = await actor_identity_stored.whoami_caller();
            setCaller(result);
        }
        if(provider == 'II' && actor_identity_stored != undefined && canister_id != undefined){
            let result = await actor_identity_stored.whoami_caller();
            setCaller(result);
        }
    }

    let canister_command = principal == undefined ?
        <></> :
        NODE_ENV.toString() == 'production' ?
        <div>
            <h4>Execute commands before starting using:</h4>
            <h6>1) Run command dfx</h6>
            <h6>dfx canister --network=ic update-settings rbac --add-controller {canister_id}</h6>
        </div> :
            <div>
                <h4>Execute commands before starting using:</h4>
                <h6>1) Run command dfx</h6>
                <h6>dfx canister update-settings rbac --add-controller {canister_id}</h6>
            </div>

    let principal_command = principal == undefined ?
        <></> :
        NODE_ENV.toString() == 'production' ?
        <div>
            <h6>3) Run command dfx</h6>
            <h6>dfx canister --network=ic call rbac add_admin "(principal \"{principal}\")"</h6>
        </div> :
            <div>
                <h6>3) Run command dfx</h6>
                <h6>dfx canister call rbac add_admin "(principal \"{principal}\")"</h6>
            </div>

    let initialization_command = principal == undefined ?
        <></> :
        NODE_ENV.toString() == 'production' ?
        <div>
            <h6>2.1) Run commands dfx:</h6>
            <h6>dfx canister --network=ic call rbac initialization</h6>
            {/*<h6>2.2) Or you can check the test data:</h6>*/}
            {/*<h6>dfx canister --network=ic call rbac initialization_unsafe</h6>*/}
        </div> :
            <div>
                <h6>2.1) Run commands dfx:</h6>
                <h6>dfx canister call rbac initialization</h6>
                {/*<h6>2.2) Or you can check the test data:</h6>*/}
                {/*<h6>dfx canister call rbac initialization_unsafe</h6>*/}
            </div>

    let verifyinig_auth = principal == undefined ?
        <></> :
        <div>
            <div>
                <h4>Verifying an authenticated call (test):</h4>
                <Button onClick={() => ButtonClick()} className={"btn-secondary"}>Auth-Whoami</Button>
            </div>
        </div>

    let caller_auth = principal == undefined ?
        <></> :
        <div>
            <div>
                {caller}
            </div>
        </div>

    return (
        <div>
            <Container>
                <Row className="p-5">
                    <Col>
                        <>
                            <h4>
                                Role-Based Authentication Class
                            </h4>
                            <a href="https://forum.dfinity.org/t/open-icdevs-org-bounty-62-role-based-authentication-class-motoko-8-000/19452">
                                https://forum.dfinity.org/t/open-icdevs-org-bounty-62-role-based-authentication-class-motoko-8-000/19452
                            </a>
                            <h6>
                                @Safik
                            </h6>
                        </>
                    </Col>
                </Row>
                <Row className="start-100">
                    <Col className="start-100">
                        <>
                            <div>
                                <h6>
                                    {canister_command}
                                </h6>
                                <h6>
                                    {initialization_command}
                                </h6>
                                <h6>
                                    {principal_command}
                                </h6>
                            </div>
                        </>
                    </Col>
                    <Col>
                        <>
                            {verifyinig_auth}
                        </>
                    </Col>
                </Row>
                <Row>
                    <Col>
                        <>
                            <div>
                                <h4></h4>
                            </div>
                        </>
                    </Col>
                    <Col>
                        <>
                            <h6>
                                {caller_auth}
                            </h6>
                        </>
                    </Col>
                </Row>
            </Container>

        </div>
    );
}