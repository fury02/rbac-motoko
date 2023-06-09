import React, {useEffect, useState} from "react";
import {Button, Col, Container, Form, Row} from "react-bootstrap";
import {Actor} from "@dfinity/agent";
import {_SERVICE as service_auth_rbac} from "../../declarations/rbac/rbac.did";
import {idlFactory as idl_auth_rbac} from "../../declarations/rbac/index";
import {Principal} from "@dfinity/principal";
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
import {render} from "@testing-library/react";
import {AlertDialog} from "../alert/AlertDialog";
import {CANISTER_RBAC, LOCAL_CANISTER_RBAC, NODE_ENV} from "../../const";
import {selectActorIdentityContextValue} from "../../redux/features/connect_actor/ActorIdentityContextSlice";

export const UserRolesComponent: React.FC = () => {
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
    const principal = connect_context.Principal == undefined ? '' : connect_context.Principal.toString();

    let canister_id = NODE_ENV.toString() == 'production' ? CANISTER_RBAC.toString() : LOCAL_CANISTER_RBAC.toString();

    const [admin, setAdmin] = useState<string>('');
    const [user, setUser] = useState<string>('');
    const [selected_admin , setSelectedAdmin ] = useState<string>('');
    const [users, setUsers] = useState<Array<string>>([]);
    const [selected_user, setSelectedUser ] = useState<string>('');
    const [admins, setAdmins] = useState<Array<Principal>>([]);
    const [principals, setPrincipals] = useState<Array<Principal>>([]);
    const [selected_principal , setSelectedPrincipal ] = useState<string>('');
    const [role, setRole] = useState<string>('');
    const [selected_role , setSelectedRole ] = useState<string>('');
    const [roles, setRoles] = useState<Array<string>>([]);
    const [permission , setPermission ] = useState<string>('');
    const [selected_permission , setSelectedPermission ] = useState<string>('');
    const [permissions , setPermissions ] = useState<Array<string>>([]);

    const stored_admins = participants_context_stored.admins;
    const stored_principals = participants_context_stored.principals;
    const stored_roles = participants_context_stored.roles;
    const stored_permissions = participants_context_stored.permissions;

    useEffect(() => {
        async function AsyncAction() {
            try {
                if(stored_admins?.length != 0){ setAdmins(stored_admins); }
                if(stored_principals?.length != 0){ setPrincipals(stored_principals); }
                if(stored_roles?.length != 0){ setRoles(stored_roles); }
                if(stored_permissions?.length != 0){ setPermissions(stored_permissions); }
                if(provider == 'Stoic' && agent != undefined && canister_id != undefined){

                    const actor = Actor.createActor<service_auth_rbac>(idl_auth_rbac, {
                        agent,
                        canisterId: Principal.fromText(canister_id)});

                    let _admins = Array<Principal>();
                    let _principals = Array<Principal>();
                    let _users = Array<string>();
                    let _roles = Array<string>();
                    let _permissions = Array<string>();

                    if(stored_admins?.length == 0 || stored_admins == undefined){
                        let saved_admins = await actor.admins();
                        saved_admins.unshift(Principal.anonymous());
                        setAdmins(saved_admins);
                        _admins = saved_admins;
                    };
                    if(stored_principals?.length == 0 || stored_principals == undefined){
                        let saved_principals = await actor.users();
                        saved_principals.unshift(Principal.anonymous());
                        setPrincipals(saved_principals);
                        _principals = saved_principals;
                    };
                    if(stored_roles?.length  == 0 || stored_roles == undefined){
                        let saved_roles = await actor.roles();
                        saved_roles.unshift('');
                        setRoles(saved_roles);
                        _roles = saved_roles;
                    };
                    if(stored_permissions?.length == 0 || stored_permissions == undefined){
                        let saved_permissions = await actor.permissions();
                        saved_permissions.unshift('');
                        setPermissions(saved_permissions);
                        _permissions = permissions;
                    };

                    dispatch(set_participants_context_values({
                        admins: _admins,
                        principals: _principals,
                        user: _users,
                        roles: _roles,
                        permissions: _permissions,
                    }))
                }
                if((provider == 'Plug' || provider == 'II') && actor_identity_stored != undefined && canister_id != undefined){
                    let _admins = Array<Principal>();
                    let _principals = Array<Principal>();
                    let _users = Array<string>();
                    let _roles = Array<string>();
                    let _permissions = Array<string>();

                    if(stored_admins?.length == 0 || stored_admins == undefined){
                        let saved_admins = await actor_identity_stored.admins();
                        saved_admins.unshift(Principal.anonymous());
                        setAdmins(saved_admins);
                        _admins = saved_admins;
                    };
                    if(stored_principals?.length == 0 || stored_principals == undefined){
                        let saved_principals = await actor_identity_stored.users();
                        saved_principals.unshift(Principal.anonymous());
                        setPrincipals(saved_principals);
                        _principals = saved_principals;
                    };
                    if(stored_roles?.length  == 0 || stored_roles == undefined){
                        let saved_roles = await actor_identity_stored.roles();
                        saved_roles.unshift('');
                        setRoles(saved_roles);
                        _roles = saved_roles;
                    };
                    if(stored_permissions?.length == 0 || stored_permissions == undefined){
                        let saved_permissions = await actor_identity_stored.permissions();
                        saved_permissions.unshift('');
                        setPermissions(saved_permissions);
                        _permissions = permissions;
                    };

                    dispatch(set_participants_context_values({
                        admins: _admins,
                        principals: _principals,
                        user: _users,
                        roles: _roles,
                        permissions: _permissions,
                    }))
                }
            }
            catch (e) {
                console.log(e);
            }
        }
        AsyncAction();
    }, [])


    let principals_roles_jsx_element_bind = roles.length == 0 ?
        <>
            <div className="spinner-border text-secondary my-xxl-5" role="status">
                <span>Rbac...</span>
            </div>
        </> :
        <>
            <div>
                <h4>Associate a user with roles</h4>
            </div>
            <h6>Users(principals):</h6>
            <Form.Select className="mb-4" onChange={ u => {selectedPrincipals(u.target.value)}}>
                {
                    principals?.map((i) => (
                        <option key={i.toString()} value={i.toString()}>
                            {i.toString()}
                        </option>
                    ))
                }
            </Form.Select>
            <h6>Roles:</h6>
            <Form.Select className="mb-4" onChange={ p => {selectedRole(p.target.value)}}>
                {
                    roles?.map((i) => (
                        <option key={i} value={i}>
                            {i}
                        </option>
                    ))
                }
            </Form.Select>
            <div className="container">
                <div className="row gx-5">
                    <div className="col">
                        <Button className="border" variant="outline-primary" id="button-update-role-permision" size={"sm"} onClick={() => BindRole()}>
                            Bind
                        </Button>
                    </div>
                    <div className="col">
                        <Button className="border" variant="outline-danger" id="button-update-role-permision" size={"sm"} onClick={() => UnbindRole()}>
                            Unbind
                        </Button>
                    </div>
                </div>
            </div>
        </>

    const BindRole = async () => {
        if(selected_role != '' && selected_principal != '' && provider == 'Stoic' && agent != undefined && canister_id != undefined){
            const actor = Actor.createActor<service_auth_rbac>(idl_auth_rbac, {
                agent,
                canisterId: Principal.fromText(canister_id)});

            //Action user-role bind
            let response = await actor.bind_role(Principal.fromText(selected_principal), selected_role);
            if(Object.keys(response)[0] == "ok"){
                var result = Object.values(response)[0];
                alert("Ok.");
                // render(<AlertDialog text_alert={"Ok."}/>);
            }
            else {
                alert("Error bind role for user.");
                // render(<AlertDialog text_alert={"Error bind role for user."}/>);
            }
        }
        else if(selected_role != '' && selected_principal != '' && (provider == 'Plug' || provider == 'II') && actor_identity_stored != undefined && canister_id != undefined){
            //Action user-role bind
            let response = await actor_identity_stored.bind_role(Principal.fromText(selected_principal), selected_role);
            if(Object.keys(response)[0] == "ok"){
                var result = Object.values(response)[0];
                alert("Ok.");
                // render(<AlertDialog text_alert={"Ok."}/>);
            }
            else {
                alert("Error bind role for user.");
                // render(<AlertDialog text_alert={"Error bind role for user."}/>);
            }
        }
        else {
            alert("Not selected user or role.");
            // render(<AlertDialog text_alert={"Not selected user or role."}/>);
        }
    }

    const UnbindRole = async () => {
        if(selected_role != '' && selected_principal != '' && provider == 'Stoic' && agent != undefined && canister_id != undefined){
            const actor = Actor.createActor<service_auth_rbac>(idl_auth_rbac, {
                agent,
                canisterId: Principal.fromText(canister_id)});

            //Action user-role bind
            let response = await actor.unbind_role(Principal.fromText(selected_principal), selected_role);
            if(Object.keys(response)[0] == "ok"){
                var result = Object.values(response)[0];
                alert("Ok.");
                // render(<AlertDialog text_alert={"Ok."}/>);
            }
            else {
                alert("Error unbind role for user.");
                // render(<AlertDialog text_alert={"Error unbind role for user."}/>);
            }
        }
        else if(selected_role != '' && selected_principal != '' && (provider == 'Plug' || provider == 'II') && actor_identity_stored != undefined && canister_id != undefined){
            //Action user-role bind
            let response = await actor_identity_stored.unbind_role(Principal.fromText(selected_principal), selected_role);
            if(Object.keys(response)[0] == "ok"){
                var result = Object.values(response)[0];
                alert("Ok.");
                // render(<AlertDialog text_alert={"Ok."}/>);
            }
            else {
                alert("Error unbind role for user.");
                // render(<AlertDialog text_alert={"Error unbind role for user."}/>);
            }
        }
        else {
            alert("Not selected user or role.");
            // render(<AlertDialog text_alert={"Not selected user or role."}/>);
        }
    }

    const selectedPrincipals = (u: any) => { setSelectedPrincipal(u); }
    const selectedRole = (r: any) => { setSelectedRole(r); }

    return (
        <Container>
            <Row className="p-5">
                <Col>
                    <>
                        {principals_roles_jsx_element_bind}
                    </>
                </Col>
                <Col>
                    <>
                        <div>
                            <h4></h4>
                        </div>
                    </>
                </Col>
            </Row>
        </Container>
    );
}