import Types "../rbac/types/types";
import Text "mo:base/Text";
import Result "mo:base/Result";

module {
    type Errors = Types.Errors;
    type Admin = Types.Admin;
    type User = Types.User;
    type Role = Types.Role;
    type Permission = Types.Permission;
    type Action = Types.Action;
    public type IActor = actor {
        add_admin : (admin : Admin) -> async Result.Result<?Admin, Errors>;
        add_permission : (permission : Permission) -> async Result.Result<?Permission, Errors>;
        add_role : (role : Role) -> async Result.Result<?Role, Errors>;
        add_user : (user : User) -> async Result.Result<?User, Errors>;
        admins : () -> async [Admin];
        bind_permission : (role : Role, permission : Permission) -> async Result.Result<?Permission, Errors>;
        bind_role : (user : User, role : Role) -> async Result.Result<?Role, Errors>;
        demand_permissions : (role : Role) -> async Result.Result<?[Permission], Errors>;
        demand_permissions_unsafe : (role : Role) -> async Result.Result<?[Permission], Errors>;
        demand_user_permissions : () -> async [Permission];
        demand_user_permissions_unsafe: (user : User) -> async [Permission];
        demand_roles : () -> async Result.Result<?[Role], Errors>;
        demand_roles_unsafe : (user : User) -> async Result.Result<?[Role], Errors>;
        unbind_permission : (role : Role, permission : Permission) -> async Result.Result<?[Permission], Errors>;
        unbind_role : (user : User, role : Role) -> async Result.Result<?[Role], Errors>;
        canister_id : () -> async Principal;
        controllers : () -> async [Admin];
        delete_admin : (admin : Admin) -> async Result.Result<Bool, Errors>;
        delete_permission : (permission : Permission) -> async Result.Result<Bool, Errors> ; //??? Test
        delete_role : (role : Role) -> async Result.Result<Bool, Errors> ; //??? Test
        delete_user : (user : User) -> async Result.Result<Bool, Errors>;
        initialization : () -> async ();
        permissions : () -> async [Permission];
        roles : () -> async [Role];
        users : () -> async [User];
        whoami_caller : () -> async Text;
    };
};
