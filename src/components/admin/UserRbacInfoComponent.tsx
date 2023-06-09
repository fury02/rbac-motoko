import React, {useEffect, useState} from "react";
import {useAppDispatch, useAppSelector} from "../../redux/app/Hooks";
import {IConnectContext, selectConnectContextValues} from "../../redux/features/connect/ConnectContextSlice";
import {
    IHttpAgentIdentity,
    selectHttpAgentIdentityContextValue
} from "../../redux/features/connect_identity/HttpAgentIdentityContextSlice";
import {Actor} from "@dfinity/agent";
import {_SERVICE as service_auth_rbac} from "../../declarations/rbac/rbac.did";
import {idlFactory as idl_auth_rbac} from "../../declarations/rbac/index";
import {Principal} from "@dfinity/principal";
import {Button, Col, Container, Form, InputGroup, Row} from "react-bootstrap";
import {
    IParticipantsContext,
    selectParticipantsContextValues,
    set_participants_context_values
} from "../../redux/features/participants/ParticipantsContextSlice";
import {render} from "@testing-library/react";
import {AlertDialog} from "../alert/AlertDialog";
import {CANISTER_RBAC, LOCAL_CANISTER_RBAC, NODE_ENV} from "../../const";
import {selectActorIdentityContextValue} from "../../redux/features/connect_actor/ActorIdentityContextSlice";
export const UserRbacInfoComponent: React.FC = () => {
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
    const [user_roles, setUserRoles] = useState<Array<string>>([]);
    const [user_roles_str, setUserRolesStr] = useState<string>('');
    const [permission , setPermission ] = useState<string>('');
    const [selected_permission , setSelectedPermission ] = useState<string>('');
    const [permissions , setPermissions ] = useState<Array<string>>([]);
    const [user_permissions , setUserPermissions ] = useState<Array<string>>([]);
    const [user_permissions_str , setUserPermissionsStr ] = useState<string>('');

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

    let principals_jsx_element = roles.length == 0 ?
        <>
            <div className="spinner-border text-secondary my-xxl-5" role="status">
                <span>Rbac...</span>
            </div>
        </> :
        <>
            <div>
                <h4>User rbac information</h4>
            </div>
            <h6>Users:</h6>
            <Form.Select className="mb-4" onChange={ u => {selectedPrincipals(u.target.value)}}>
                {
                    principals?.map((i) => (
                        <option key={i.toString()} value={i.toString()}>
                            {i.toString()}
                        </option>
                    ))
                }
            </Form.Select>

        </>

    let user_roles_jsx_element = user_roles.length == 0?
        <>

        </> :
        <>
            <h6 className="mall">Roles:</h6>
            <h6 className="text-muted fst-italic small">
                {user_roles_str}
            </h6>
        </>

    let user_permissions_jsx_element = user_permissions.length == 0?
        <>

        </> :
        <>
            <h6 className="mall">Permissions:</h6>
            <h6 className="text-muted fst-italic small">
                {user_permissions_str}
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

    const selectedPrincipals = async (u: any) => {
        setSelectedPrincipal(u);
        setUserRoles([]);
        setUserPermissions([]);
        setUserRolesStr('');
        setUserPermissionsStr('');
        if(provider == 'Stoic' && agent != undefined && canister_id != undefined){
            const actor = Actor.createActor<service_auth_rbac>(idl_auth_rbac, {
                agent,
                canisterId: Principal.fromText(canister_id)
            });
            let user_roles = await actor.demand_roles_unsafe(Principal.fromText(u));
            if(Object.keys(user_roles)[0] == "ok"){
                    var result = Object.values(user_roles) ;
                    setUserRoles(result);
                    setUserRolesStr(arrToStr(result));
            };
            let user_permissions = await actor.demand_user_permissions_unsafe(Principal.fromText(u));
            setUserPermissions(user_permissions);
            setUserPermissionsStr(arrToStr(user_permissions));
        }
        if((provider == 'Plug' || provider == 'II') && actor_identity_stored != undefined && canister_id != undefined){
            let user_roles = await actor_identity_stored.demand_roles_unsafe(Principal.fromText(u));
            if(Object.keys(user_roles)[0] == "ok"){
                var result = Object.values(user_roles) ;
                setUserRoles(result);
                setUserRolesStr(arrToStr(result));
            };
            let user_permissions = await actor_identity_stored.demand_user_permissions_unsafe(Principal.fromText(u));
            setUserPermissions(user_permissions);
            setUserPermissionsStr(arrToStr(user_permissions));
        }
    }

    return (
        <Container>
            <Row className="p-5">
                <Col>
                    <>
                        {principals_jsx_element}
                    </>
                </Col>
                <Col>
                    <>
                        {user_roles_jsx_element}
                        {user_permissions_jsx_element}
                    </>
                </Col>
            </Row>
        </Container>
    );
}