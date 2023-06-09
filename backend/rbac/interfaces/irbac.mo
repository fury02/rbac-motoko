import Types "../types/types";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Bool "mo:base/Bool";
import Result "mo:base/Result";

module {
    type Errors = Types.Errors;
    type Duration = Types.Duration;
    type Scaner = Types.Scaner;
    type Admin = Types.Admin;
    type User = Types.User;
    type Role = Types.Role;
    type Permission = Types.Permission;
    type Admins = Types.Admins;
    type Users = Types.Users;
    type Roles = Types.Roles;
    type Permissions = Types.Permissions;
    type ListRelatedRP = Types.ListRelatedRP;
    type ObjectRef = Types.ObjectRef;
    type CountRef = Types.CountRef;
    type RelatedRP = Types.RelatedRP;
    type JTI = Types.JTI;
    type Token = Types.Token;
    type AuthClient = Types.AuthClient;
    public type IRbac = actor {
        //dev
        _users_ : () -> async Result.Result<Users, Errors>;
        //init rbac
        init : () -> async Result.Result<Admins, Errors>;
        //others
        whoami_caller : () -> async Text;
        canister_id : () -> async Principal;
        //user
        add_admin : (user : User) -> async Result.Result<User, Errors>;
        delete_admin : (user : User) -> async Result.Result<User, Errors>;
        add_user : (user : User, client : AuthClient) -> async Result.Result<User, Errors>;
        delete_user : (user : User, client : AuthClient) -> async Result.Result<User, Errors>;
        contains_user : (user : User, client : AuthClient) -> async Result.Result<User, Errors>;
        users : (client : AuthClient) -> async Result.Result<Users, Errors>;
        //role
        add_role : (role : Role, client : AuthClient) -> async Result.Result<Role, Errors>;
        delete_role : (role : Role, client : AuthClient) -> async Result.Result<Role, Errors>;
        get_role : (role : Role, client : AuthClient) -> async Result.Result<ObjectRef, Errors>;
        roles : (client : AuthClient) -> async Result.Result<Roles, Errors>;
        //permission
        add_permission : (permission : Permission, client : AuthClient) -> async Result.Result<Permission, Errors>;
        delete_permission : (permission : Permission, client : AuthClient) -> async Result.Result<Permission, Errors>;
        get_permission : (permission : Permission, client : AuthClient) -> async Result.Result<ObjectRef, Errors>;
        permissions : (client : AuthClient) -> async Result.Result<Permissions, Errors>;
        //(un)bind
        bind_permission : (permission : Permission, role : Role, client : AuthClient) -> async Result.Result<Permissions, Errors>;
        unbind_permission : (permission : Permission, role : Role, client : AuthClient) -> async Result.Result<Permissions, Errors>;
        bind_role : (user : User, role : Role, client : AuthClient) -> async Result.Result<Roles, Errors>;
        unbind_role : (user : User, role : Role, client : AuthClient) -> async Result.Result<Roles, Errors>;
        //client
        request_client : () -> async Result.Result<AuthClient, Errors>;
        new_client : () -> async Result.Result<AuthClient, Errors>;
        delete_client : (client : AuthClient) -> async Result.Result<Bool, Errors>;
        valid_client : () -> async Bool;
        //scaner
        status_scaner : () -> async Scaner;
    };
};
