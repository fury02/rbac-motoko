import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Error "mo:base/Error";
module {
    public type Admin = Principal;
    public type User = Principal;
    public type Role = Text;
    public type Permission = Text;

    public type Action = {
        #Add;
        #Delete;
    };

    public type Errors = {
        #rejected_parameters;
        #adding_user_failed;
        #adding_admin_failed;
        #adding_role_failed;
        #adding_permission_failed;
        #delete_admin_failed;
        #delete_user_failed;
        #error_delete_permission_used;
        #delete_role_failed;
        #error_delete_role_not_empty;
        #error_delete_role_used;
        #delete_permission_failed;
        #bind_permission_failed;
        #unbind_permission_failed;
        #permission_does_not_exist;
        #role_does_not_exist;
        #user_does_not_exist;
        #bind_role_failed;
        #unbind_role_failed;
    };

    public type Id = Principal;
    public type CanisterSettings = {
        controllers : [Principal];
        compute_allocation : Nat;
        memory_allocation : Nat;
        freezing_threshold : Nat;
    };
    public type InternetComputer = actor {
        canister_status : ({ canister_id : Id }) -> async ({
            status : { #running; #stopping; #stopped };
            settings : CanisterSettings;
            module_hash : ?Blob;
            memory_size : Nat;
            cycles : Nat;
            freezing_threshold : Nat;
        });
        update_settings : ({
            canister_id : Principal;
            settings : CanisterSettings;
        }) -> async ();
    };
};
