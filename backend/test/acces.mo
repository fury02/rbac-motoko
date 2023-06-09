import Types "../rbac/types/types";
import IRbac "../rbac/interfaces/irbac";

import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Debug "mo:base/Debug";
import Array "mo:base/Array";
import Principal "mo:base/Principal";

import Fuzz "mo:fuzz";
import Prng "mo:prng";
 

actor AccesTest {

    type Errors = Types.Errors;
    type Admin = Types.Admin;
    type User = Types.User;
    type Role = Types.Role;
    type Permission = Types.Permission;
    type Admins = Types.Admins;
    type Users = Types.Users;
    type Roles = Types.Roles;
    type Permissions = Types.Permissions;
    type ListRelatedRP = Types.ListRelatedRP;
    type RelatedRP = Types.RelatedRP;
    type JTI = Types.JTI;
    type Token = Types.Token;
    type AuthClient = Types.AuthClient;

    //#1: dfx canister update-settings rbac --add-controller <canister_id_test>
    //#2: dfx canister update-settings rbac --add-controller <canister_id_rbac>
    //#3: dfx canister rbac init()

    let rbac_canister_id = "be2us-64aaa-aaaaa-qaabq-cai";

    let user = "jg232-gb2jq-fxffi-fctj6-daeup-4gwlb-2z5vk-6hpgr-3vlxy-pwm2m-aqe";
    let role : Role = "_Role";
    let permission : Permission = "_Permission";
    let rbac : IRbac.IRbac = actor (rbac_canister_id);

    public func test() : async () {
        Debug.print("start #1" # debug_show ("test_acces_rbac"));
        await test_acces_rbac();
    };

    public func test_acces_rbac() : async () {
        //#1 caller (ping)
        let caller = await rbac.whoami_caller();
        Debug.print("caller: " # debug_show (caller));

        //add auth
        var auth_client = await rbac.request_client();
        assert (await rbac.valid_client());
        Debug.print("auth_client " # debug_show (auth_client));

        switch (auth_client) {
            case (#err(e)) {Debug.print("auth_client " # debug_show (e));};
            case (#ok(authclient)) {
                var u1 = await rbac.add_user(Principal.fromText(user), authclient);
                Debug.print("add_user " # debug_show (u1));
                var rt = await rbac.add_role(role, authclient);
                Debug.print("add_role " # debug_show (rt ));
                var pt = await rbac.add_permission(permission, authclient);
                Debug.print("add_permission " # debug_show (pt));
            };
        };
        Debug.print("end #1" # debug_show ());
    };
};
