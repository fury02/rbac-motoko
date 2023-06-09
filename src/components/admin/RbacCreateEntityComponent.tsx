import {Button, Col, Container, Form, InputGroup, Row} from "react-bootstrap";
import React, {useEffect, useState} from "react";
import {useAppDispatch, useAppSelector} from "../../redux/app/Hooks";
import {IConnectContext, selectConnectContextValues} from "../../redux/features/connect/ConnectContextSlice";
import {
    IHttpAgentIdentity,
    selectHttpAgentIdentityContextValue
} from "../../redux/features/connect_identity/HttpAgentIdentityContextSlice";
import {
    IParticipantsContext,
    selectParticipantsContextValues, set_participants_context_values
} from "../../redux/features/participants/ParticipantsContextSlice";
import {Principal} from "@dfinity/principal";
import {Actor} from "@dfinity/agent";
import {_SERVICE as service_auth_rbac} from "../../declarations/rbac/rbac.did";
import {idlFactory as idl_auth_rbac} from "../../declarations/rbac/index";
import {render} from "@testing-library/react";
import {AlertDialog} from "../alert/AlertDialog";
import {CANISTER_RBAC, LOCAL_CANISTER_RBAC, NODE_ENV} from "../../const";
import {selectActorIdentityContextValue} from "../../redux/features/connect_actor/ActorIdentityContextSlice";

const template_principal = "*****-*****-*****-*****-*****-*****-*****-*****-*****-*****-***";
const template_azat = "***********";

export const RbacCreateEntityComponent: React.FC = () => {
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
    //Redux - store get values
    let canister_id = NODE_ENV.toString() == 'production' ? CANISTER_RBAC.toString() : LOCAL_CANISTER_RBAC.toString();
    const [admin, setAdmin] = useState<string>('');
    const [user, setUser] = useState<string>('');
    const [role, setRole] = useState<string>('');
    const [permission , setPermission ] = useState<string>('');

    const AddAdmin = async () =>{
        if(provider == 'Stoic'  && agent != undefined && canister_id != undefined){
            const actor = Actor.createActor<service_auth_rbac>(idl_auth_rbac, {
                agent,
                canisterId: Principal.fromText(canister_id)});
            let response = await actor.add_admin(Principal.fromText(admin));
            if(Object.keys(response)[0] == "ok"){
                var result = Object.values(response)[0];
                alert("Ok.");
                // render(<AlertDialog text_alert={"Ok."}/>);
            }
            else {
                alert("Error add admin.");
                // render(<AlertDialog text_alert={"Error add admin."}/>);
            }
        }
        else if((provider == 'Plug' || provider == 'II')  && actor_identity_stored != undefined && canister_id != undefined){
            let response =  await actor_identity_stored.add_admin(Principal.fromText(admin));
            if(Object.keys(response)[0] == "ok"){
                var result = Object.values(response)[0];
                alert("Ok.");
                // render(<AlertDialog text_alert={"Ok."}/>);
            }
            else {
                alert("Error add admin.");
                // render(<AlertDialog text_alert={"Error add admin."}/>);
            }
        }
        else {
            alert("Authorization failed. Log back into the system!");
            // render(<AlertDialog text_alert={"Authorization failed. Log back into the system!"}/>);
        }
    }

    const AddUser = async () =>{
        if(provider == 'Stoic' && agent != undefined && canister_id != undefined){
            const actor = Actor.createActor<service_auth_rbac>(idl_auth_rbac, {
                agent,
                canisterId: Principal.fromText(canister_id)});
            let response = await actor.add_user(Principal.fromText(user));
            if(Object.keys(response)[0] == "ok"){
                var result = Object.values(response)[0];
                alert("Ok.");
                // render(<AlertDialog text_alert={"Ok."}/>);
            }
            else {
                alert("Error add user.");
                // render(<AlertDialog text_alert={"Error add user."}/>);
            }
        }
        else if((provider == 'Plug' || provider == 'II') && actor_identity_stored != undefined && canister_id != undefined){
            let response =  await actor_identity_stored.add_user(Principal.fromText(user));
            if(Object.keys(response)[0] == "ok"){
                var result = Object.values(response)[0];
                alert("Ok.");
                // render(<AlertDialog text_alert={"Ok."}/>);
            }
            else {
                alert("Error add admin.");
                // render(<AlertDialog text_alert={"Error add admin."}/>);
            }
        }
        else {
            alert("Authorization failed. Log back into the system!");
            // render(<AlertDialog text_alert={"Authorization failed. Log back into the system!"}/>);
        }
    }

    const AddRole = async () =>{
        if(provider == 'Stoic' && agent != undefined && canister_id != undefined){
            const actor = Actor.createActor<service_auth_rbac>(idl_auth_rbac, {
                agent,
                canisterId: Principal.fromText(canister_id)});
            let response = await actor.add_role(role);
            if(Object.keys(response)[0] == "ok"){
                var result = Object.values(response)[0];
                alert("Ok.");
                // render(<AlertDialog text_alert={"Ok."}/>);
            }
            else {
                alert("Error add role.");
                // render(<AlertDialog text_alert={"Error add role."}/>);
            }
        }
        else if((provider == 'Plug' || provider == 'II') && actor_identity_stored != undefined && canister_id != undefined){
            let response =  await actor_identity_stored.add_role(role);
            if(Object.keys(response)[0] == "ok"){
                var result = Object.values(response)[0];
                alert("Ok.");
                // render(<AlertDialog text_alert={"Ok."}/>);
            }
            else {
                alert("Error add admin.");
                // render(<AlertDialog text_alert={"Error add admin."}/>);
            }
        }
        else {
            alert("Authorization failed. Log back into the system!");
            // render(<AlertDialog text_alert={"Authorization failed. Log back into the system!"}/>);
        }
    }

    const AddPermission = async () =>{
        if(provider == 'Stoic' && agent != undefined && canister_id != undefined){
            const actor = Actor.createActor<service_auth_rbac>(idl_auth_rbac, {
                agent,
                canisterId: Principal.fromText(canister_id)});
            let response = await actor.add_permission(permission);
            if(Object.keys(response)[0] == "ok"){
                var result = Object.values(response)[0];
                alert("Ok.");
                // render(<AlertDialog text_alert={"Ok."}/>);
            }
            else {
                alert("Error add permission.");
                // render(<AlertDialog text_alert={"Error add permission."}/>);
            }
        }
        else if((provider == 'Plug' || provider == 'II') && actor_identity_stored != undefined && canister_id != undefined){
            let response =  await actor_identity_stored.add_permission(permission);
            if(Object.keys(response)[0] == "ok"){
                var result = Object.values(response)[0];
                alert("Ok.");
                // render(<AlertDialog text_alert={"Ok."}/>);
            }
            else {
                alert("Error add admin.");
                // render(<AlertDialog text_alert={"Error add admin."}/>);
            }
        }
        else {
            alert("Authorization failed. Log back into the system!");
            // render(<AlertDialog text_alert={"Authorization failed. Log back into the system!"}/>);
        }
    }

    const textAdminHandlerForm = (e: string) => { setAdmin(e); }
    const textUserHandlerForm = (e: string) => { setUser(e); }
    const textRoleHandlerForm = (e: string) => { setRole(e); }
    const textPermissionHandlerForm = (e: string) => { setPermission(e); }

    return (
        <Container>
            <Row className="p-5 border">
                <Col>
                    <>
                        <div>
                            <h4>
                                Adding participants and delineation descriptions to the RBAC class
                            </h4>
                        </div>
                        <InputGroup className="mb-4">
                            <Button variant="outline-primary" id="button-add-admin" size={"sm"} onClick={() => AddAdmin()}>
                                Add Admin
                            </Button>
                            <Form.Control
                                aria-label="Example text with button addon"
                                aria-describedby="basic-addon1"
                                defaultValue={template_principal}
                                onChange={(event) => {textAdminHandlerForm(event.target.value)}}
                            >
                            </Form.Control>
                        </InputGroup>

                        <InputGroup className="mb-4">
                            <Button variant="outline-primary" id="button-add-user" size={"sm"} onClick={() => AddUser()}>
                                Add User
                            </Button>
                            <Form.Control
                                aria-label=""
                                aria-describedby="basic-addon1"
                                defaultValue={template_principal}
                                onChange={(event) => {textUserHandlerForm(event.target.value)}}
                            />
                        </InputGroup>

                        <InputGroup className="mb-4">
                            <Button variant="outline-primary" id="button-add-role" size={"sm"} onClick={() => AddRole()}>
                                Add Role
                            </Button>
                            <Form.Control
                                aria-label=""
                                aria-describedby="basic-addon1"
                                defaultValue={template_azat}
                                onChange={(event) => {textRoleHandlerForm(event.target.value)}}
                            />
                        </InputGroup>

                        <InputGroup className="mb-4">
                            <Button variant="outline-primary" id="button-add-permision" size={"sm"} onClick={() => AddPermission()}>
                                Add Permission
                            </Button>
                            <Form.Control
                                aria-label=""
                                aria-describedby="basic-addon1"
                                defaultValue={template_azat}
                                onChange={(event) => {textPermissionHandlerForm(event.target.value)}}
                            />
                        </InputGroup>
                    </>
                </Col>
            </Row>

            <Row>
                <Col>
                    <>

                    </>
                </Col>
                <Col>
                    <>

                    </>
                </Col>
            </Row>

        </Container>
    );
}